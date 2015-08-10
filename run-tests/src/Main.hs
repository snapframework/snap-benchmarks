{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

module Main where

import Control.Applicative
import Control.Concurrent
import qualified Control.Concurrent.Async as Async
import Control.Monad
import Data.Bool
import qualified Data.ByteString.Char8 as B
import Data.Foldable
import Data.List
import Data.Maybe
import qualified Data.Csv as CSV
import qualified Data.Text as T
import GHC.Generics
import Options.Applicative
import Safe
import System.IO
import System.Directory
import System.FilePath
import System.Process

-- | Specification for a single benchmarking run, including commandline
--   options for the server and for httperf
data TestRun = TestRun
  { exe       :: !FilePath  -- ^ Name of the server executable
  , ghcDir    :: !FilePath  -- ^ GHC build directory
  , nCores    :: !Int
  , allocSize :: !String    -- ^ GHC allocation size flag (e.g. "-A5M")

  , hog       :: !Bool      -- ^ httperf "--hog" flag
  , numConns  :: !Int       -- ^ httperf "--num-connss"
  , numCalls  :: !Int       -- ^ httperf "--num-calls"
  } deriving (Eq, Show, Generic)

-- | Results for a single benchmarking run
data RunStats = RunStats
  { replyRate   :: !Double
  , replyStddev :: !Double
  } deriving (Show, Generic)

instance CSV.FromField Bool where
  parseField = CSV.parseField . read . B.unpack
instance CSV.ToField Bool where
instance CSV.FromRecord TestRun where
instance CSV.ToRecord   TestRun where
instance CSV.FromNamedRecord TestRun where
instance CSV.ToNamedRecord TestRun where

instance CSV.FromRecord RunStats where
instance CSV.ToRecord   RunStats where
instance CSV.FromNamedRecord RunStats where
instance CSV.ToNamedRecord RunStats where


------------------------------------------------------------------------------
runBenchmark :: Opts -> TestRun -> IO RunStats
runBenchmark o@Opts{..} t@TestRun{..} = do
  let ((s:ss),(h:hs)) = testCLICalls o t
  print $ unwords (s:ss)
  print $ unwords (h:hs)
  print $ "s: " ++ s
  print $ "ss: " ++ show ss
  threadDelay 1000000
  print "CALLING SERVER"
  serverHandle <- spawnProcess s (filter (not . null) ss)
  threadDelay 100000  -- 100 ms pause after server startup
  print "CALLING HTTPERF"
  res <- readProcess h (hs ++ ["--port","3000"]) ""
  terminateProcess serverHandle
  print "TERMINATED PROCESS"
  B.writeFile (reportsDir </> testToFileName t) (B.pack res)
  case getStats res of
    Nothing    -> error "Results read failure"
    Just stats -> return stats


------------------------------------------------------------------------------
getStats :: String -> Maybe RunStats
getStats s =
  let ts  = T.lines . T.pack $ s
      res = do
              replyLine <- listToMaybe $ filter (T.isPrefixOf "Reply rate") ts
              let replyWords = T.words replyLine
              avgInd <- succ <$> elemIndex "avg" replyWords
              avg    <- readMay (T.unpack $ replyWords !! avgInd)
              stDevInd <- succ <$> elemIndex "stddev" replyWords
              stddev <- readMay (T.unpack $ replyWords !! stDevInd)
              return $ RunStats avg stddev
  in res


------------------------------------------------------------------------------
testToFileName :: TestRun -> FilePath
testToFileName TestRun{..} =
  T.unpack
  . T.intercalate "."
  . map T.pack
  $ [exe, ghcDir, show nCores, allocSize, show numConns, show numCalls]


------------------------------------------------------------------------------
testCLICalls :: Opts -> TestRun -> ([String], [String])
testCLICalls Opts{..} TestRun{..} = (srvCall, httpCall)
  where srvCall  = [ exeBaseDir </> ghcDir </> exe, "+RTS"
                   , allocSize, "-N" <> show nCores]
        httpCall = [ "httperf", bool "" "--hog" hog, "--num-conns"
                   , show numConns, "--num-calls", show numCalls]


------------------------------------------------------------------------------
allGHC = ["ghc7.6.3", "ghc7.8.4", "ghc7.10.2"]


------------------------------------------------------------------------------
pongTests :: [TestRun]
pongTests = TestRun
    <$> ["snap-pong-1", "snap-pong-0", "warp-pong", "happstack-pong"]
    <*> allGHC
    <*> [1,4]
    <*> ["", "-A5M"]
    <*> [True]
    <*> [10,1000]
    <*> [1000]


------------------------------------------------------------------------------
fileTests :: [TestRun]
fileTests = TestRun
    <$> ["snap-file-1", "snap-file-0", "warp-file"]
    <*> allGHC
    <*> [1,4]
    <*> ["", "-A5M"]
    <*> [True]
    <*> [10,1000]
    <*> [1]


------------------------------------------------------------------------------
data Opts = Opts
  { exeBaseDir  :: FilePath
  , reportsDir  :: FilePath
  , dryRun      :: Bool
  } deriving (Show)


------------------------------------------------------------------------------
optsP :: Parser Opts
optsP = Opts
  <$> strOption (long "servers" <> short 's' <> help "Base dir of servers")
  <*> strOption (long "reports" <> short 'r' <> help "Reports directory")
  <*> switch (long "dry-run" <> help "Don't actually run server or httperf")


------------------------------------------------------------------------------
main :: IO ()
main = do
  putStrLn $ show (length tests) ++ " tests to run"
  r <- execParser fullOpts >>= \o -> flip mapM tests $ \t -> do
    r <- runBenchmark o t
    print (t,r)
    return (t,r)
  print r
  where tests    = pongTests ++ fileTests
        fullOpts = info (helper <*> optsP) fullDesc


------------------------------------------------------------------------------
showCommand :: [String] -> String
showCommand = unwords

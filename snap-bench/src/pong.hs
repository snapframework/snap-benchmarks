module Main where

import           System
import           Control.Applicative
import           Control.Monad.Trans
import           Snap.Http.Server
import           Snap.Iteratee
import           Snap.Types
import           Snap.Util.FileServe

site :: Snap ()
site = dir "pong" (writeBS "PONG") <|> fileServe "static"
--site = writeBS "PONG"

pongServer :: Snap ()
pongServer = --dir "pong" $
    modifyResponse $ setResponseBody (enumBS "PONG") .
        setContentType "text/plain" .
        setContentLength 4

main :: IO ()
main = do
    args <- getArgs
    let port = case args of
                   []  -> 3000
                   p:_ -> read p
        config = setPort port $
                 setAccessLog Nothing $
                 defaultConfig
    httpServe config site

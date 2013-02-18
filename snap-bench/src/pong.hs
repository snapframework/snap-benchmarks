module Main where

import           System.Environment
import           Control.Applicative
import           Control.Monad.Trans
import           Snap.Http.Server
import           Snap.Iteratee
import           Snap.Core
import           Snap.Util.FileServe

site :: Snap ()
site = writeBS "PONG"

main :: IO ()
main = do
    args <- getArgs
    let port = case args of
                   []  -> 3000
                   p:_ -> read p
        config = setBind "0.0.0.0" $
                 setPort port $
                 setAccessLog ConfigNoLog $
                 defaultConfig
    httpServe config site

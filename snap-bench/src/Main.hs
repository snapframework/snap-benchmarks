module Main where

import           System
import           Control.Applicative
import           Control.Monad.Trans
import           Snap.Http.Server
import           Snap.Iteratee
import           Snap.Types
import           Snap.Util.FileServe
import           Text.Templating.Heist

site :: Snap ()
site = dir "pong" (writeBS "PONG")

pongServer = --dir "pong" $
    modifyResponse $ setResponseBody (enumBS "PONG") .
        setContentType "text/plain" .
        setContentLength 4

main :: IO ()
main = do
    args <- getArgs
    let port = case args of
                   []  -> 8000
                   p:_ -> read p
    httpServe "*" port "myserver"
        Nothing -- (Just "access.log")
        Nothing -- (Just "error.log")
        pongServer

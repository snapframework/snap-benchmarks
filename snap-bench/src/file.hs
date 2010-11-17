module Main where

import           System
import           Control.Applicative
import           Control.Monad.Trans
import           Snap.Http.Server
import           Snap.Iteratee
import           Snap.Types
import           Snap.Util.FileServe

site :: Snap ()
site = fileServe "static"

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

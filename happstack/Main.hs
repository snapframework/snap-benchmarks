{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Control.Monad
import Happstack.Server
import System.Environment

handlers :: ServerPart Response
handlers = msum
    [ dir "pong" $ ok (toResponseBS "text/plain" "pong")
    , serveFile (asContentType "image/png") "FiringGeometry.png"
    ]

main :: IO ()
main = do
  args <- getArgs
  let p = if length args == 0 then 8000 else read $ head args

  simpleHTTP (nullConf {port = p, logAccess = Nothing}) handlers

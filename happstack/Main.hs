module Main where

import Happstack.Server
import System.Environment

handlers = dir "pong" $ anyRequest $ ok $ toResponse "PONG"

main = do
  args <- getArgs
  let p = if length args == 0 then 8000 else read $ head args

  simpleHTTP (nullConf {port = p}) handlers

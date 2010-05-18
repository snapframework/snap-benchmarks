module Main where

import Control.Monad
import Happstack.Server
import System.Environment

handlers = msum
    [dir "pong" $ anyRequest $ ok $ toResponse "PONG"
    ,fileServe ["FiringGeometry.png"] "."
    ]

main = do
  args <- getArgs
  let p = if length args == 0 then 8000 else read $ head args

  simpleHTTP (nullConf {port = p}) handlers

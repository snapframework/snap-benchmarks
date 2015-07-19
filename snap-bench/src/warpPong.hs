{-# LANGUAGE OverloadedStrings #-}

import Network.Wai (responseLBS)
import Network.Wai.Handler.Warp (run)
import Blaze.ByteString.Builder (fromByteString)
import Network.HTTP.Types (status200,hContentType, hContentLength)

main :: IO ()
main = run 3000 $ \_ f ->
       f (responseLBS
          status200
          [(hContentType, "text/plain"), (hContentLength, "4")]
          "PONG")

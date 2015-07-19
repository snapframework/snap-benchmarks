{-# LANGUAGE OverloadedStrings #-}
import Network.Wai
import Network.Wai.Handler.Warp
import Blaze.ByteString.Builder (fromByteString)
import Network.HTTP.Types (status200)

main = run 3000 $ \_ f -> f $ responseFile
    status200
    [("Content-Type", "image/png") ]
    "static/FiringGeometry.png"
    Nothing

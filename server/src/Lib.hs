{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module Lib
  ( someFunc,
    handler,
  )
where

import Aws.Lambda
import Data.Aeson
import Data.Maybe
import GHC.Generics

data Person = Person
  { name :: String,
    age :: Int
  }
  deriving (Generic, FromJSON, ToJSON)

someFunc :: IO ()
someFunc = putStrLn "someFunc"

handler :: ApiGatewayRequest () -> Context () -> IO (Either (ApiGatewayResponse String) (ApiGatewayResponse String))
handler person context =
  pure $ Right $ ApiGatewayResponse 200 [] "Hello World" False

-- handler :: ApiGatewayRequest person -> Context () -> IO (Either String String)
-- handler person context =
--   if isJust (apiGatewayRequestBody person)
--     then pure $ Right $ "asdf"
--     else pure $ Left $ "fef"

-- then pure $ Right $ ApiGatewayResponse 200 [] "asdf" True
-- else pure $ Left $ ApiGatewayResponse 200 [] "A person's age must be positive" False
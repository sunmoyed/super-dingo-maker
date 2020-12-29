{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Aws.Lambda
import Lib

-- Use this action if you want to have context that is shared between lambda calls.
-- It is called once per every cold start. We do not wish to have a shared context for our lambda, so we simply use Unit.
initializeContext :: IO ()
initializeContext = return ()

-- generateLambdaDispatcher StandaloneLambda defaultDispatcherOptions
generateLambdaDispatcher UseWithAPIGateway defaultDispatcherOptions
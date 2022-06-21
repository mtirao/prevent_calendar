{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module HospitalController where

import Domain
import Views
import Hospitals
import Db

import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)


import Control.Monad.IO.Class
import Database.PostgreSQL.Simple
import Data.Pool(Pool, createPool, withResource)
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T

import GHC.Int
import GHC.Generics (Generic)

import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger (logStdout)
import Network.HTTP.Types.Status

import Data.Aeson

---CREATE
createHospital pool = do
                        b <- body
                        hospital <- return $ (decode b :: Maybe Hospital)
                        case hospital of
                            Nothing -> status status400
                            Just _ -> hospitalResponse pool hospital

hospitalResponse pool hospital = do 
                                dbHospital <- liftIO $ insert pool hospital
                                case dbHospital of
                                        Nothing -> status status400
                                        Just a -> dbHospitalResponse 
                                                where dbHospitalResponse  = do
                                                                        jsonResponse a
                                                                        status status201

-- GET & LIST
listHospital pool =  do
                        hospitals <- liftIO $ (list pool :: IO [Hospital])
                        jsonResponse hospitals
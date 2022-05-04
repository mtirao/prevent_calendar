{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Controller.CalendarController where

import Domain
import Views
import Db.Calendars
import Db.Db

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
createCalendar pool = do
                        b <- body
                        calendar <- return $ (decode b :: Maybe Calendar)
                        case calendar  of
                            Nothing -> status status400
                            Just _ -> calendarResponse pool calendar 

calendarResponse pool calendar = do 
                                dbCalendar <- liftIO $ insert pool calendar
                                case dbCalendar of
                                        Nothing -> status status400
                                        Just a -> dbCalendarResponse 
                                                where dbCalendarResponse  = do
                                                                        jsonResponse a
                                                                        status status201
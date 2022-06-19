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

import Data.Time.Clock
import Data.Time.LocalTime
import Data.Time.Calendar

---CREATE
createCalendar pool = do
                        b <- body
                        calendar <- return $ (decode b :: Maybe Calendar)
                        case calendar  of
                            Nothing -> status status400
                            Just a -> dateValidation (date a) pool calendar
                                         
dateValidation lt pool calendar = do 
                                    valid <- liftIO $ isValidDate lt
                                    case valid of
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


-- GET & LIST
listCalendar pool =  do
                        b <- body
                        calendar <- return $ (decode b :: Maybe CalendarRequest)
                        case calendar of
                            Nothing -> status status400
                            Just _ ->  calendarListResponse pool calendar
                                        

calendarListResponse pool calendar = do
                                        calendars <- liftIO $ (findCalendar pool calendar :: IO [Calendar])
                                        jsonResponse calendars

-- HELPERS
--today :: IO (Integer,Int,Int) -- :: (year,month,day)
--today = getCurrentTime >>= return . toGregorian . utctDay

computeDiff lt = do
                    today <- getCurrentTime
                    timeZone <- getCurrentTimeZone
                    let localTime = utcToLocalTime timeZone today
                    return (diffLocalTime localTime lt)          

isValidDate lt = do
                 diff <- computeDiff lt
                 if (nominalDiffTimeToSeconds diff <= 0) then return $ Just True else return Nothing 
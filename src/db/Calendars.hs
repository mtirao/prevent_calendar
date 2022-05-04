{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module Db.Calendars where

import Db.Db
import Domain

import Web.Scotty.Internal.Types (ActionT)
import GHC.Generics (Generic)
import Control.Monad.IO.Class
import Database.PostgreSQL.Simple
import Data.Pool(Pool, createPool, withResource)
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text as T
import GHC.Int
import Data.Time.LocalTime



executeCalendar:: Pool Connection -> Calendar -> Query -> IO [(Maybe Integer, Integer, LocalTime)]
executeCalendar pool a queryy = do
                                fetch pool ((relCalendarDoctorId a), (date a)) queryy :: IO [(Maybe Integer, Integer, LocalTime)]



buildCalendar :: (Maybe Integer, Integer, LocalTime) -> Calendar
buildCalendar (calendarId, relCalendarDoctorId, date) = Calendar calendarId relCalendarDoctorId date


oneCalendar :: [(Maybe Integer, Integer, LocalTime)] -> Maybe Calendar
oneCalendar (a : _) = Just $ buildCalendar a
oneCalendar _ = Nothing



instance DbOperation Calendar where
    insert pool (Just a) = do
                res <- executeCalendar pool a "INSERT INTO calendars(doctor_id, date) VALUES(?,?) RETURNING id, doctor_id, date"
                return $ oneCalendar res

    list  pool = do
                    res <- fetchSimple pool "SELECT id, doctor_id, date FROM calendars" :: IO [(Maybe Integer, Integer, LocalTime)]
                    return $ map (\a -> buildCalendar a) res

    find  pool idd = do 
                        res <- fetch pool (Only idd) "SELECT id, doctor_id, date FROM calendars where id=?" :: IO [(Maybe Integer, Integer, LocalTime)]
                        return $ oneCalendar res


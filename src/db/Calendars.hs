{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module Calendars where

import Db
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



executeCalendar:: Pool Connection -> Calendar -> Query -> IO [(Maybe Integer, Integer, LocalTime, Integer)]
executeCalendar pool a queryy = do
                                fetch pool ((relCalendarDoctorId a), (date a), (relCalendarPatientId a)) queryy :: IO [(Maybe Integer, Integer, LocalTime, Integer)]



buildCalendar :: (Maybe Integer, Integer, LocalTime, Integer) -> Calendar
buildCalendar (calendarId, relCalendarDoctorId, date, relCalendarPatientId) = Calendar calendarId relCalendarDoctorId date relCalendarPatientId


oneCalendar :: [(Maybe Integer, Integer, LocalTime, Integer)] -> Maybe Calendar
oneCalendar (a : _) = Just $ buildCalendar a
oneCalendar _ = Nothing



instance DbOperation Calendar where
    insert pool (Just a) = do
                res <- executeCalendar pool a "INSERT INTO calendars(doctor_id, date) VALUES(?,?) RETURNING id, doctor_id, date"
                return $ oneCalendar res

    list  pool = do
                    res <- fetchSimple pool "SELECT id, doctor_id, date, patient_id FROM calendars" :: IO [(Maybe Integer, Integer, LocalTime, Integer)]
                    return $ map (\a -> buildCalendar a) res

    find  pool idd = do 
                        res <- fetch pool (Only idd) "SELECT id, doctor_id, date, patient_id FROM calendars where id=?" :: IO [(Maybe Integer, Integer, LocalTime, Integer)]
                        return $ oneCalendar res

findCalendar :: Pool Connection -> Maybe CalendarRequest -> IO [Calendar]
findCalendar pool (Just a)  = do 
                        res <- fetch pool ((fromDate a), (toDate a)) "SELECT id, doctor_id, date, patient_id FROM calendars WHERE date >= ? and date <= ?" :: IO [(Maybe Integer, Integer, LocalTime, Integer)]
                        return $ map (\a -> buildCalendar a) res


{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module Db.Doctors where

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


executeDoctor:: Pool Connection -> Doctor -> Query -> IO [(Integer, Integer, Float,  Integer, Maybe Integer, Float)]
executeDoctor pool a query = do
                                fetch pool ((availableDay a), (relDoctorDoctorId a), (endShift a), (relHospitalDoctorId a), (startShift a)) query :: IO [(Integer, Integer, Float,  Integer, Maybe Integer, Float)]



buildDoctor :: (Integer, Integer, Float,  Integer, Maybe Integer, Float) -> Doctor
buildDoctor (availableDay, relDoctorDoctorId, endShift, relHospitalDoctorId, doctorId, startShift) = Doctor availableDay relDoctorDoctorId endShift relHospitalDoctorId doctorId startShift


oneDoctor :: [(Integer, Integer, Float,  Integer, Maybe Integer, Float)] -> Maybe Doctor
oneDoctor (a : _) = Just $ buildDoctor a
oneDoctor _ = Nothing



instance DbOperation Doctor where
    insert pool (Just a) = do
                res <- executeDoctor pool a "INSERT INTO doctors(available_day, doctor_id, end_shift, hospital_id, start_shift) VALUES(?,?,?,?,?) RETURNING available_day, doctor_id, end_shift, hospital_id, id, start_shift"
                return $ oneDoctor res

    list  pool = do
                    res <- fetchSimple pool "SELECT available_day, doctor_id, end_shift, hospital_id, id, start_shift FROM doctors" :: IO [(Integer, Integer, Float,  Integer, Maybe Integer, Float)]
                    return $ map (\a -> buildDoctor a) res

    find  pool id = do 
                        res <- fetch pool (Only id) "SELECT available_day, doctor_id, end_shift, hospital_id, id, start_shift FROM doctors where id=?" :: IO [(Integer, Integer, Float,  Integer, Maybe Integer, Float)]
                        return $ oneDoctor res
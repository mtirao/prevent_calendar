{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE RecordWildCards       #-}


module Domain where

import Data.Text.Lazy
import Data.Text.Lazy.Encoding
import Data.Aeson
import Control.Applicative
import GHC.Generics
import Data.Time.LocalTime

-- Calendar
data Calendar = Calendar 
    {calendarId :: Maybe Integer
    , relCalendarDoctorId :: Integer
    , date :: LocalTime
    }

instance ToJSON Calendar where
    toJSON Calendar {..} = object [
        "id" .= calendarId,
        "doctorid" .= relCalendarDoctorId,
        "date" .= date
        ]

instance FromJSON Calendar where
    parseJSON (Object v) = Calendar <$>
        v .:?  "id" <*>
        v .:  "doctorid" <*>
        v .:  "date"

-- Doctor
data Doctor = Doctor
    {availableDay :: Integer
    , relDoctorDoctorId :: Integer
    , endShift :: Float
    , relHospitalDoctorId :: Integer
    , doctorId :: Maybe Integer
    , startShift :: Float
    }

instance ToJSON Doctor where
    toJSON Doctor {..} = object [
        "availableday" .= availableDay,
        "doctorid" .= relDoctorDoctorId,
        "endshift" .= endShift,
        "hospitalid" .= relHospitalDoctorId,
        "id" .= doctorId,
        "startshift" .= startShift
        ]

instance FromJSON Doctor where
    parseJSON (Object v) = Doctor <$>
        v .: "availableday" <*>
        v .: "doctorid" <*>
        v .: "endshift" <*>
        v .: "hospitalid" <*>
        v .:? "id" <*>
        v .: "startshift"

-- Hospital
data Hospital = Hospital
    {address :: Text
    , city :: Text
    , hospitalId :: Maybe Integer
    , name :: Text
    , state :: Text
    }

instance ToJSON Hospital where
    toJSON Hospital {..} = object [
        "address" .= address,
        "city" .= city,
        "id" .= hospitalId,
        "name" .= name,
        "state" .= state
        ]

instance FromJSON Hospital where
    parseJSON (Object v) = Hospital <$>
        v .: "address" <*>
        v .: "city" <*>
        v .:? "id" <*>
        v .: "name" <*>
        v .: "state"
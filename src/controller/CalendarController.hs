{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}


module CalendarController where

import Domain
import Views
import Db.Calendars
import Db.Doctors
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
import qualified Data.Text.Lazy.Builder as B
import qualified Data.Text.Lazy.Builder.Int as B

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
                            Just a -> dateValidation pool a


dateValidation pool calendar = do 
                                    valid <- liftIO $ isValidDate (date calendar)
                                    case valid of
                                        Nothing -> status status400
                                        Just _ -> validateDoctorAvailability pool calendar

validateDoctorAvailability pool calendar = do
                                                available <- liftIO $ (findDoctorDayAvailability pool (relCalendarDoctorId calendar) :: IO (Maybe Integer))
                                                case available of 
                                                    Nothing -> status status400
                                                    Just a -> checkDoctorAvailability (localDay (date calendar)) a
                                                                where checkDoctorAvailability day i =  if elem (dayOfWeek day) (getAvailableDay $ toZipList i)
                                                                                                        then calendarResponse pool (Just calendar) 
                                                                                                        else status status400



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

--isDoctorAvaible :: Pool Connection -> TL.Text -> DayOfWeek -> Maybe Bool
--isDoctorAvaible pool idd day = 

findDoctorDayAvailability:: Pool Connection -> Integer -> IO (Maybe Integer)
findDoctorDayAvailability pool idd = do 
                                        doctor <- findDoctor pool idd :: IO (Maybe Doctor)
                                        case doctor of
                                            Nothing -> return Nothing
                                            Just a -> return $ Just (availableDay a)



findDoctorDayStartShift pool idd = do 
                                    doctor <- find pool idd :: IO (Maybe Doctor)
                                    case doctor of
                                        Nothing -> return Nothing
                                        Just a -> return $ Just (startShift a)


findDoctorDayEndShift pool idd = do 
                                    doctor <- find pool idd :: IO (Maybe Doctor)
                                    case doctor of
                                        Nothing -> return Nothing
                                        Just a -> return $ Just (endShift a)

toBin 0 = []
toBin n | n > 127 = []
        | n `mod` 2 == 1 = toBin (n `div` 2) ++ [1]
        | n `mod` 2 == 0 = toBin (n `div` 2) ++ [0]

toDecimal :: [Integer] -> Integer
toDecimal [] = 0
toDecimal (x:xs) = (x * 2 ^(length xs)) + toDecimal xs

listOfN n = take n (repeat 0)

toBinaryList :: [Integer] -> [Integer]
toBinaryList l = listOfN (7 - (length l)) ++ l 

toZipList :: Integer -> [(Integer, DayOfWeek)]
toZipList i = zip (toBinaryList (toBin i)) [Sunday, Monday,Tuesday, Wednesday, Thursday, Friday, Saturday]

getAvailableDay :: [(Integer, DayOfWeek)] -> [DayOfWeek]
getAvailableDay [] = []
getAvailableDay (x:xs) = checkAvailability x ++ getAvailableDay xs
                                where checkAvailability (a,b) = if a == 1 then [b] else []

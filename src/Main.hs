module Main where

import Db as Db

import Domain
import Views

import HospitalController
import DoctorController
import CalendarController

import qualified Data.Configurator as C
import qualified Data.Configurator.Types as C
import qualified Data.Text.Lazy as TL
import Data.Pool(createPool)
import Data.Aeson

import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)

import Database.PostgreSQL.Simple

import Db as Db

import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger (logStdout)
import Network.HTTP.Types.Status

-- Parse file "application.conf" and get the DB connection info
makeDbConfig :: C.Config -> IO (Maybe DbConfig)
makeDbConfig conf = do
    dbConfname <- C.lookup conf "database.name" :: IO (Maybe String)
    dbConfUser <- C.lookup conf "database.user" :: IO (Maybe String)
    dbConfPassword <- C.lookup conf "database.password" :: IO (Maybe String)
    dbConfHost <- C.lookup conf "database.host" :: IO (Maybe String)
    return $ DbConfig <$> dbConfname
                    <*> dbConfUser
                    <*> dbConfPassword
                    <*> dbConfHost


main :: IO ()
main = do
    loadedConf <- C.load [C.Required "application.conf"]
    dbConf <- makeDbConfig loadedConf
    
    case dbConf of
        Nothing -> putStrLn "No database configuration found, terminating..."
        Just conf -> do      
            pool <- createPool (newConn conf) close 1 40 10
            scotty 3100 $ do
                middleware $ staticPolicy (noDots >-> addBase "static") -- serve static files
                middleware $ logStdout    

                -- HOSPITAL
                post "/api/prevent/hospital" $ createHospital pool
                get "/api/prevent/hospitals" $ listHospital pool
                get "/api/prevent/hospital/:id" $ do 
                                                    idd <- param "id" :: ActionM TL.Text
                                                    getHospital pool idd
                put "/api/prevent/hospital/:id" $ do 
                                                    idd <- param "id" :: ActionM TL.Text
                                                    updateHospital pool idd

                -- CALENDAR
                post "/api/prevent/calendar" $ createCalendar pool
                get "/api/prevent/calendars" $ listCalendar pool

                -- DOCTOR
                post "/api/prevent/doctor" $ createDoctor pool
                get "/api/prevent/doctors" $ listDoctor pool
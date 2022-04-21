{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Views where

import Domain
import GHC.Generics()
import Web.Scotty as WS
import Data.Monoid()
import Data.Text()
import Data.Aeson
import qualified Data.Text.Lazy as TL
import Control.Monad.IO.Class()
import Web.Scotty.Internal.Types()

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



jsonResponse :: ToJSON a => a -> ActionM ()
jsonResponse e = WS.json e


controllerInsertResponse :: (DbOperation a, ToJSON a) => Pool Connection -> Maybe a -> ActionM ()
controllerInsertResponse pool adult = do 
                                dbAdult <- liftIO $ insert pool adult
                                case dbAdult of
                                        Nothing -> status status400
                                        Just b -> do
                                                    WS.json b
                                                    status status201


--------------------------------------------------------------------------------

-- createdUser :: Maybe User -> ActionM ()
-- createdUser user = case user of
--                        Just u -> WS.json u
--                        Nothing -> WS.json (ErrorMessage "Something unexpected")

--------------------------------------------------------------------------------
--createdObject :: Maybe DbModels -> ActionM ()
--createdObject dbModels = case dbModelse of
--                            Just u -> json u
--                            Nothin -> json (ErrorMessage "Something unexpected") 
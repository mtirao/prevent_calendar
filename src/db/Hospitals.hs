{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module Hospitals where

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


executeHospital:: Pool Connection -> Hospital -> Query -> IO [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)]
executeHospital pool a query = do
                                fetch pool ((address a), (city a), (name a), (state a)) query :: IO [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)]



buildHospital :: (TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text) -> Hospital
buildHospital (address, city, hospitalId, name, state) = Hospital address city hospitalId name state


oneHospital :: [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)] -> Maybe Hospital
oneHospital (a : _) = Just $ buildHospital a
oneHospital _ = Nothing



instance DbOperation Hospital where
    insert pool (Just a) = do
                res <- executeHospital pool a "INSERT INTO hospitals(address, city, name, state) VALUES(?,?,?,?) RETURNING address, city, id, name, state"
                return $ oneHospital res

    list  pool = do
                    res <- fetchSimple pool "SELECT address, city, id, name, state FROM hospitals" :: IO [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)]
                    return $ map (\a -> buildHospital a) res

    update pool (Just a) id= do
                res <- fetch pool ((address a), (city a), (name a), (state a), id) "UPDATE hospitals SET address=?, city=?, name=?, state=? WHERE id=? RETURNING address, city, id, name, state" :: IO [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)]
                return $ oneHospital res


    find  pool id = do 
                        res <- fetch pool (Only id) "SELECT address, city, id, name, state FROM hospitals where id=?" :: IO [(TL.Text, TL.Text, Maybe Integer, TL.Text, TL.Text)]
                        return $ oneHospital res
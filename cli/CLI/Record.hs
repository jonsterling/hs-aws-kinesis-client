{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE UnicodeSyntax #-}

-- |
-- Module: CLI.Record
-- Copyright: Copyright © 2014 AlephCloud Systems, Inc.
-- License: MIT
-- Maintainer: Jon Sterling <jsterling@alephcloud.com>
-- Stability: experimental
--

module CLI.Record where

import Data.Aeson
import Data.Aeson.Types
import Data.Time
import qualified Data.Text as T
import qualified Data.ByteString as BS
import Control.Applicative
import Control.Applicative.Unicode
import Data.Hourglass
import Prelude.Unicode

data Record
  = Record
  { rTimestamp ∷ DateTime
  , rMessage ∷ T.Text
  } deriving (Show, Eq)

instance FromJSON DateTime where
  parseJSON =
    withText "DateTime" $
      maybe (fail "Invalid DateTime") return
      ∘ timeParse fmt
      ∘ T.unpack
    where
      fmt =
        [ Format_Year4
        , hyphen
        , Format_Month2
        , hyphen
        , Format_Day2
        , Format_Text 'T'
        , Format_Hour
        , colon
        , Format_Minute
        , colon
        , Format_Second
        ]
      hyphen = Format_Text '-'
      colon = Format_Text ':'

instance FromJSON Record where
  parseJSON =
    withObject "Record" $ \xs →
      Record <$> xs .: "time" ⊛ xs .: "message"

instance Ord Record where
  compare r1 r2 = compare (rTimestamp r1) (rTimestamp r2)


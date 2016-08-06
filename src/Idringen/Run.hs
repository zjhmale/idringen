module Idringen.Run where

import Idringen.Plugin (IdringenPlugin (..))

import System.Directory
import System.Process
import Data.String.Utils

plugin :: IdringenPlugin
plugin = IdringenPlugin $
  \args -> do
    files <- getDirectoryContents "."
    let pkgName = fst $ break (== '.') $ head $ filter (endswith ".ipkg") files
    rawSystem ("./" ++ pkgName) args
    return ()

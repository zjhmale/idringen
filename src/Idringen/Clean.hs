module Idringen.Clean where

import Idringen.Plugin (IdringenPlugin (..))

import Control.Monad
import System.Directory
import System.Process
import Data.String.Utils

plugin :: IdringenPlugin
plugin = IdringenPlugin $
  \args -> do
    files <- getDirectoryContents "."
    let pkgName = fst $ break (== '.') $ head $ filter (endswith ".ipkg") files
    removeFile pkgName
    setCurrentDirectory "./src"
    files <- getDirectoryContents "."
    let compiledFiles = filter (endswith ".ibc") files
    mapM_ removeFile compiledFiles

module Idringen.Clean where

import Idringen.Plugin (IdringenPlugin (..))

import Control.Monad
import System.Directory
import Data.String.Utils

plugin :: IdringenPlugin
plugin = IdringenPlugin $
  \_ -> do
    files <- getDirectoryContents "."
    let pkgName = fst $ break (== '.') $ head $ filter (endswith ".ipkg") files
    isExecExist <- doesFileExist pkgName
    when isExecExist $ removeFile pkgName
    setCurrentDirectory "./src"
    compiledFiles <- filter (endswith ".ibc") <$> getDirectoryContents "."
    mapM_ removeFile compiledFiles

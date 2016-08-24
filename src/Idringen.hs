module Idringen where

import Control.Monad
import Data.Char
import System.Directory
import Data.String.Utils

import qualified Idringen.New as New
import qualified Idringen.Build as Build
import qualified Idringen.Test as Test
import qualified Idringen.Run as Run
import qualified Idringen.Clean as Clean
import Idringen.Plugin

newtype Command = Command { unCommand :: String }
newtype CommandArgs = CommandArgs { unCommandArgs :: [String] }

openKeg :: Command -> CommandArgs -> IO ()
openKeg c a = do
  let command = toLower `fmap` unCommand c
      args = unCommandArgs a
      plugin = case command of
                 "new" -> New.plugin
                 "build" -> Build.plugin
                 "test" -> Test.plugin
                 "run" -> Run.plugin
                 "clean" -> Clean.plugin
                 c' -> error $ "not support subcmd " ++ c' ++ " yet"
  when (command `elem` ["build", "test", "run", "clean"]) $
    do files <- filter (endswith ".ipkg") <$> getDirectoryContents "."
       when (null files) $ error "can not find ipkg file"
  run plugin args

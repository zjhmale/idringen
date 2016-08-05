module Main where

import System.Environment (getArgs)
import Idringen

main :: IO ()
main = do
  args <- getArgs
  case args of
   (command:otherargs) -> openKeg (Command command) (CommandArgs otherargs)
   _ -> putStrLn "usage: idrin <cmd> <args*>"

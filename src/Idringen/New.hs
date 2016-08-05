module Idringen.New (plugin) where

import Idringen.Plugin (IdringenPlugin (..))

import Control.Applicative ((<|>))
import Control.Monad.Trans.Maybe (MaybeT (..), runMaybeT)
import qualified Data.ByteString.Lazy as L
import Data.List (intercalate, stripPrefix)
import Data.Maybe (catMaybes)
import Network.HTTP.Conduit (simpleHttp)
import System.Directory
import System.Exit
import System.FilePath
import System.IO
import System.Process

newtype UserDetails = UserDetails { unUserDetails :: (String,String) } deriving (Show, Eq)

userDetails :: IO UserDetails
userDetails = do
  Just details <- runMaybeT (readFromGitconfig <|> askDetails)
  return details
  where
    readFromGitconfig = MaybeT $ do

      username <- (head . lines) <$> readProcess "git" ["config", "--global", "--get", "user.name"] ""
      email    <- (head . lines) <$> readProcess "git" ["config", "--global", "--get", "user.email"] ""

      if null username || null email
        then return Nothing
        else return . Just $ UserDetails (username, email)

    askDetails = MaybeT $ do
      putStrLn "Enter name"
      name <- (head . lines) <$> getLine

      putStrLn "Enter email"
      email <- (head . lines) <$> getLine

      let details = UserDetails (name, email)

      return (Just details)

dependenciesIn :: [String] -> [String] -> [String]
dependenciesIn defs args =
  let startingWithPlus = catMaybes $ map (stripPrefix "+") args
      mapped = map ("--dependency=" ++) $ defs ++ startingWithPlus
  in mapped

plugin :: IdringenPlugin
plugin = IdringenPlugin
       $ \args -> do
         let packageName = head args

         putStrLn $ "Creating new project named " ++ packageName

         alreadyExists <- doesDirectoryExist packageName
         if (not alreadyExists) then createDirectory packageName else return ()

         setCurrentDirectory packageName

         UserDetails (user, email) <- userDetails
         let license = "BSD3"
             version = "0.0.1"
             brief = "\"Initial project template from idringen\""
             homepage = "https://github.com/githubuser/" ++ packageName
             sourceloc = "git@github.com:githubuser/" ++ packageName ++ ".git"
             bugtracker = homepage ++ "/issues"
             modules = "Main"
             executable = packageName
             main = "Main"
             sourceDir = "src"
             mainFile = "Main.idr"
             mainFilePath = sourceDir </> mainFile
             readmeFilePath = "README.md"
             ipkgFilePath = packageName ++ ".ipkg"

         writeFile ipkgFilePath $ intercalate "\n"
           [ "package " ++ packageName
           , ""
           , "version = " ++ version
           , "brief = " ++ brief
           , ""
           , "author = " ++ user ++ " <" ++ email ++ ">"
           , "license = " ++ license
           , "homepage = " ++ homepage
           , "sourceloc = " ++ sourceloc
           , "bugtracker = " ++ bugtracker
           , ""
           , "sourcedir = " ++ sourceDir
           , "modules = " ++ modules
           , "executable = " ++ executable
           , "main = " ++ main]

         createDirectoryIfMissing True sourceDir

         writeFile mainFilePath $ intercalate "\n"
           [ "module Main"
           , ""
           , "main : IO ()"
           , "main = putStrLn \"hello " ++ packageName ++ "!\""
           ]

         writeFile readmeFilePath $ intercalate "\n"
           ["#" ++ packageName ++ "!"]

         rawSystem "git" ["init"]

         simpleHttp "https://raw.githubusercontent.com/github/gitignore/master/Idris.gitignore" >>= L.writeFile ".gitignore"

         return ()

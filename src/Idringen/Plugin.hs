module Idringen.Plugin where

data IdringenPlugin = IdringenPlugin { run :: [String] -> IO () }

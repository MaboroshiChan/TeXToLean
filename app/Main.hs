{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Text.LaTeX.Base
import Data.Text (Text)
import Text.LaTeX.Base.Parser (parseLaTeX)
import TexToLean.Lean

main :: IO ()
main = do
    let tex :: Text = "\\sum_{x \\in S}"
    let res = parseLaTeX tex
    case res of
        Left _ -> return ()
        Right x -> do
            let y =  toLean x
            print x
            print y
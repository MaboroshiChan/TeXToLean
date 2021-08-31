{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module TexToLean.Lean where

import Data.ByteString (ByteString)
import Data.Text ( Text )
import qualified Data.Text as Text
import Text.LaTeX.Base.Syntax 
  (LaTeX(TeXSeq, TeXCommS, TeXComm, TeXRaw, TeXBraces), TeXArg (FixArg))

toLean :: LaTeX -> Text
toLean (TeXSeq expr1 (TeXSeq (TeXCommS "mapsto") expr2)) 
  = "λ " <> toLean expr1 <> " , " <> toLean expr2
toLean (TeXSeq (TeXCommS "sum") args) = handleBigOperator "∑" args
toLean (TeXSeq (TeXCommS "prod") args) = handleBigOperator "" args
toLean (TeXSeq (TeXCommS "bigcup") args) = handleBigOperator "" args
toLean (TeXSeq (TeXCommS "bigcap") args) = handleBigOperator "" args
toLean (TeXSeq tex1 tex2) = toLean tex1 <> toLean tex2
toLean (TeXComm str args) = texcomm str args
toLean (TeXCommS comm) = texcomms comm
toLean (TeXRaw raw) = raw
toLean err = error $  
  "This TeX node is not currently supported. " <> show err

handleBigOperator :: String -> LaTeX -> Text
handleBigOperator op
 (TeXSeq (TeXRaw "_") 
 (TeXSeq (TeXBraces (TeXRaw down)) (TeXBraces (TeXRaw up)))) = undefined

handleBigOperator op
 (TeXSeq (TeXRaw "_") 
 (TeXBraces (TeXSeq expr1 (TeXSeq (TeXCommS "in") expr2)))) 
   = Text.pack op <>" "<>toLean expr1 <> "in" <> toLean expr2

handleBigOperator op
 (TeXSeq (TeXRaw "_") 
 (TeXSeq (TeXSeq (TeXBraces (TeXRaw down)) (TeXBraces (TeXRaw up))) rest ) ) = undefined

handleBigOperator op (TeXSeq (TeXRaw "_") 
 (TeXSeq (TeXBraces (TeXSeq expr1 (TeXSeq (TeXCommS "in") expr2))) rest) )  
   = Text.pack op <>" "<>toLean expr1 <> "in" <> toLean expr2 <> " " <> toLean rest

texcomm :: String -> [TeXArg] -> Text
texcomm "frac" [FixArg numerator, FixArg denominator] 
  = "(" <> toLean numerator <> ")" <> "/" <> "(" <> toLean denominator <> ")"
texcomm "sqrt" [FixArg expr] = "√(" <> toLean expr <> ")"
texcomm "binom" [up, down] = undefined

texcomms :: String -> Text
texcomms "sigma" = "σ"
texcomms "theta" = "θ"
texcomms "phi" = "φ"
texcomms "varphi" = "ϕ"
texcomms "alpha" = "α"
texcomms "beta" = "β"
texcomms "le" = "≤"
texcomms "ge" = "≥"
texcomms "forall" = "∀"
texcomms "exists" = "∃"
texcomms "in" = "∈"
texcomms cmd = error $ 
  "This command is not currently supported" <> show cmd
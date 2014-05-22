--------------------------------------------------------------------------------
-- |
-- Module      : Project.Core.Factorization
-- Note        : Ein paar kleine Funktionen, um mit Faktorisierungen zu Arbeiten
--
--
--
--------------------------------------------------------------------------------
module Projekt.Core.Factorization
  ( toFact, unFact
  , potFact, appFact, aggFact
  , isTrivialFact
  -- Faktoriesierungen
  , obviousFactor, appObFact
  )where
import Projekt.Core.FiniteFields
import Projekt.Core.Polynomials

import Data.List

--------------------------------------------------------------------------------
-- Eine Faktoriesierung wird dargestellt als Liste von Paaren (Integer, Polynom a)
-- wobei ein Paar (i,f) den Faktor f^i repräsentiert.
--
-- Ein Faktoriesierungsalgorithmus ist also gegeben durch eine Funktion:
--      Polynom a -> [(Integer,Polynom a)]

-- |Erzeugt eine triviale Faktoriesierung zu einem Polynom
toFact :: Polynom a -> [(Integer,Polynom a)]
toFact f = [(1,f)]

-- |Multipliziert eine Faktoriesierung aus
unFact :: (FiniteField a, Num a, Fractional a) => [(Integer,Polynom a)] -> Polynom a
unFact fs = product $ map (\(i,f) -> f^i) fs

-- |Ersetzt eine Faktoriesierung, durch die n-te Potenz dieser Faktoriesierung
potFact :: (Num a) => Integer -> [(Integer,Polynom a)]
                                                           -> [(Integer,Polynom a)]
potFact _ []         = []
potFact n ((i,f):ts) = (i*n,f) : potFact n ts

-- |Nimmt eine Faktoriesierung und wendet auf diese einen gegebenen
-- Faktoriesierungsalgorithmus an
appFact :: (Num a) => 
  (Polynom a -> [(Integer,Polynom a)]) -> [(Integer,Polynom a)] -> [(Integer,Polynom a)]
appFact _ []           = []
appFact alg ((i,f):ts) = potFact i (alg f) ++ appFact alg ts

-- |Fasst in einer Faktoriesierung gleiche Funktionen Zusammen
aggFact :: (Num a, Eq a) => [(Integer,Polynom a)]
                                                            -> [(Integer,Polynom a)]
aggFact l = [(sum [i | (i,g) <- l , f==g],f) | f <- nub [f | (_,f) <- l], f /= P[1]]

isTrivialFact :: [(Integer,a)] -> Bool
isTrivialFact [] = error "[] is not a factorization"
isTrivialFact ms = sum (map fst ms) == 1

{-
getFirstTrivial :: (Num a) => [[(Integer,a)]] -> a
getFirstTrivial [] = error "no irred Poly found"
getFirstTrivial (m:ms) | isTrivialFact m = (snd . head) m
                       | otherwise       = getFirstTrivial ms
 -}

--------------------------------------------------------------------------------
--  Einfache / offensichtliche Faktorisierungen

obviousFactor :: (Num a, Eq a) => Polynom a -> [(Integer,Polynom a)]
obviousFactor (P[])      = [(1,P[])]
obviousFactor (P[m])     = [(1,P[m])]
obviousFactor (P[m0,m1]) = [(1,P[m0,m1])]
obviousFactor (P (0:ms)) = aggFact $ (1,P[0,1]) : obviousFactor (P ms)
obviousFactor f          = toFact f

appObFact :: (Num a, Eq a) => [(Integer,Polynom a)] -> [(Integer,Polynom a)]
appObFact = appFact obviousFactor

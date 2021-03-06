#!/bin/bash
################################################################################
# usage:
#    cPN.sh
#    cPN.sh TOP
#    cPN.sh TOP "PRIME1 PRIME2 ..."
#
# Last modified: Tue Sep 09, 2014  03:32

###############################################################################
# Config
PATHBASE="/tmp/cPNrel/"
if [ $# -eq 2 ]; then
  LIMIT=$1
  LIST=$2
elif [ $# -eq 1 ]; then
  LIST="2" # 3 5 7 11 13 17"
  LIMIT=$1
else
  LIST="2"
  LIMIT=4
fi
LISTm="5 6"

nCPUm1=3

###############################################################################
FAIL=0
mkdir -p $PATHBASE
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "${DIR}/cPNout/"
SRC="${DIR}/../src/"

genPathHS(){
  echo "${SRC}cPN${1}m${2}.hs"
}
genPathEx(){
  echo "${PATHBASE}cPN${1}m${2}"
}
genPathCSV(){
  echo "${DIR}/cPNout/CalcPrimNubersRel_p=${1}_m=${2}.csv"
}

genHS(){
  # genHS CHARAKTERISTIK BEGINN END
cat <<HS
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE BangPatterns #-}
module Main
  where
import System.Environment
import System.Directory
import Control.Monad
import Data.Time

import GalFld.GalFld
import GalFld.More.SpecialPolys

p = ${1}
\$(genPrimeField ${1} "PF")
outFile = "$(genPathCSV $1 $2)"

m = ${2}

pf = 1::PF

data T = T { ext :: Int -- Grad des Grundkörpers über dem Primkörper
           , deg :: Int -- Grad der Erweiterung
           , countP :: Int -- Anzahl primitiver Elemente
           , countN :: Int -- Anzahl normaler Elemente
           , countPN :: Int } -- Anzahl primitiv-normaler Elemente

genPrimNorm m n = (record, fac)
  where one    = extendFFBy m pf
        cyP    = cyclotomicPoly (p^(n*m)-1) one
        piP    = piPoly $ pTupUnsave [(n,one),(0,-1)]
        ggT    = ggTP cyP piP
        fac    = factorP ggT
        record = T m n (uDegP cyP) (uDegP piP) (uDegP ggT)

main = do
  args <- getArgs
  let indxs = [(read $ head args)..(read $ head $ tail args)]
  bool <- doesFileExist outFile
  unless bool $ putHeaderToFile p
  mapM_ (\n -> do
    let t = fst $ genPrimNorm m n
    putInfo t p
    getCurrentTime >>= print
    putToFile t p) indxs
      where putInfo !(T m n cP cN cPN) p = do
              putStrLn $ "In (F" ++ show p ++ "^" ++ show m ++ ")^" ++ show n
                ++ " über F" ++ show p ++ " gibt es:"
                ++ "\t" ++ show cP
                ++ "\t" ++ show cN
                ++ "\t" ++ show cPN
            putHeaderToFile p =
              writeFile outFile "p,m,n,#primitive,#normal,#primitivNormal\n"
            putToFile (T m n cP cN cPN) p =
              appendFile outFile $ show p ++ ","
                                     ++ show m ++ ","
                                     ++ show n ++ ","
                                     ++ show cP ++ ","
                                     ++ show cN ++ ","
                                     ++ show cPN ++ "\n"
HS
}

getDoneNumber(){
  csv=$(genPathCSV $1 $2)
  if [ -f $csv ]; then
    echo `expr $(tail -n1 $csv | cut -d',' -f2) + 1`
  else
    echo "1"
  fi
}

###############################################################################
# gen and compile HS
pushd $SRC

for m in $LISTm ; do
  for p in $LIST; do
    if [ ! -f $(genPathEx $p $m) ]; then
      genHS $p $m >$(genPathHS $p $m)
      mkdir -p "${PATHBASE}compileOut/"
      ghc -j \
        -outputdir "${PATHBASE}compileOut/" \
        -o "$(genPathEx $p $m)" \
        -O2 -isrc -threaded \
        "$(genPathHS $p $m)"
      rm $(genPathHS $p $m)
    fi
  done
done
popd

###############################################################################
for m in $LISTm ; do
  for p in $LIST; do
    if [ -f $(genPathEx $p $m) ]; then
      #echo $(getDoneNumber $p $m)
      $(genPathEx $p $m) $(getDoneNumber $p $m) $LIMIT &
    fi

    # limit subprocesses to 4
    while [ $(jobs -p | wc -l) -gt $nCPUm1 ] ; do
      sleep 1
    done
  done
done

###############################################################################
for job in `jobs -p` ; do
  wait $job || let "FAIL+=1"
done
if [ $FAIL -gt 0 ] ; then
  echo "fails: $FAIL"
fi

#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p $DIR/../out

ghc --make \
  -outputdir out \
  -o out/Spec \
  -threaded \
  -O2 \
  -fllvm \
    $DIR/../Spec.hs
  #-fforce-recomp \

if [ $? -eq 0 ]; then
  time $DIR/../out/Spec +RTS -N4
fi

# -fforce-recomp, -O2 and -fllvm are from:
# stackoverflow.com/questions/7017116/haskell-simple-way-to-cache-a-function-call

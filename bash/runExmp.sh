#!/bin/sh

if [[ $# != 0 ]]; then
  if [[ $1 == "-N" ]]; then
    shift
    N=$1
    shift
  fi
else
  N=1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
pushd $DIR
cabal configure \
  && cabal build \
  && time cabal run exmpPrimNorm
popd

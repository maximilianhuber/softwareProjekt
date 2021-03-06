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
mkdir -p ${DIR}/dist/Profiling
pushd $DIR

ghc \
  -outputdir ${DIR}/dist/Profiling \
  -o ${DIR}/dist/Profiling/AlgProfiling \
  -prof \
  -fprof-auto -rtsopts \
  -O2 \
  -isrc \
  ${DIR}/profiling/AlgProfiling.hs

if [ $? -eq 0 ]; then
  ${DIR}/dist/Profiling/AlgProfiling +RTS -sstderr -A536870912 -H67108864 
fi

popd

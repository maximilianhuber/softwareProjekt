#!/bin/bash

function myawk() {
  awk 'BEGIN {FS=","} $1 ~ /.*'$1' / {match($1, ".*@ ([0-9]+)", arr); print arr[1],$2}' \
    ${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.csv
}
function myawk2() {
  awk 'BEGIN {FS=","} $1 ~ /.*'$1' / {match($1, ".*@ ([0-9]+)", arr); print $2}' \
    ${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.csv
}
function getField() {
  awk 'BEGIN {FS=" "} NR==2 {print $2}' \
    ${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.csv
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
mkdir -p ${DIR}/dist/bench_out
STAMP=$( date +%Y-%m-%d_%H:%M:%S )

pushd $DIR
cabal configure --enable-benchmarks \
  && cabal build -j \
  && cabal bench benchBerlekamp \
  --benchmark-options="-u ${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.csv +RTS -N$( nproc )"

#STAMP=2014-07-10_13:06:22

#if [ $? -eq 0 ]; then
  echo -e "deg\tBerlekamp\tBerlekamp2" >${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.dat
  paste <(myawk Berlekamp) <(myawk2 Berlekamp2) \
    >>${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.dat

  gnuplot <<EOF
set samples 1001
set key below

set term push
set term post enh color lw 1 12 "Times-Roman"

set xlabel "Polynomgrad"
set ylabel "s (logarithmisch)"
set yrange [0.1:*]


set logscale y 2

set title "Vergleich Berlekamp-Varianten ueber  $( getField )"

set output "${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.eps"
plot for [col=2:3] "${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.dat" \
  using 1:col title columnheader with lines
EOF

  epstopdf "${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.eps" \
    --outfile "${DIR}/dist/bench_out/benchBerlekamp_${STAMP}.pdf"
#fi

popd

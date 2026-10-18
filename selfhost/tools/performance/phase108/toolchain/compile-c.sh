#!/bin/sh
# Input must already have the portable host dispatch adaptation.
set -eu
if test "$#" -ne 2; then
  echo 'usage: compile-c.sh INPUT.c OUTPUT' >&2
  exit 2
fi
repo=$(CDPATH= cd -- "$(dirname -- "$0")/../../../../.." && pwd)
build="$repo/selfhost/build/phase108/toolchain"
inc="$repo/selfhost/tools/performance/phase108/toolchain/include"
"$build/cproc-src/cproc" -I "$inc" -include "$inc/bend-cproc.h" -DWL_PORTABLE=1 \
  -c "$1" -o "$2.o"
gcc -no-pie "$2.o" "$build/atomic-shim.o" -pthread -lm -o "$2"

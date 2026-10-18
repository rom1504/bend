#!/bin/sh
# Bounded one-time acquisition; compiler requests use cproc/QBE after this.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/../../../../.." && pwd)
pin=d1c53ddf56571573a7025324c8dd5c6d547a4d1f
build="$repo/selfhost/build/phase108/toolchain"
src="$build/cproc-src"
qbe_base="$repo/selfhost/build/phase107/toolchain/qbe-1.3"
qbe_src="$build/qbe-1.3"
qbe="$qbe_src/qbe"
patches="$repo/selfhost/tools/performance/phase108/toolchain"
test -x "$qbe_base/qbe"
mkdir -p "$build"
if ! test -d "$src/.git"; then
  git clone --no-checkout https://git.sr.ht/~mcf/cproc "$src"
  git -C "$src" checkout --detach "$pin"
fi
test "$(git -C "$src" rev-parse HEAD)" = "$pin"
if test -z "$(git -C "$src" status --porcelain --untracked-files=no)"; then
  git -C "$src" apply "$patches/cproc-constructors.patch"
fi
git -C "$src" diff -- | cmp - "$patches/cproc-constructors.patch"
if ! test -d "$qbe_src"; then
  cp -R "$qbe_base" "$qbe_src"
  patch -d "$qbe_src" -p1 < "$patches/qbe-alignment.patch"
fi
make -C "$qbe_src" -j1 CC=gcc CFLAGS='-O2 -std=c99 -Wall -Wextra -Wpedantic'
(
  cd "$src"
  ./configure CC=gcc CFLAGS=-O2 --with-qbe="$qbe"
  make -j1
)
gcc -O2 -c "$repo/selfhost/tools/performance/phase108/toolchain/atomic-shim.c" \
  -o "$build/atomic-shim.o"
sha256sum "$src/cproc" "$src/cproc-qbe" "$qbe" "$build/atomic-shim.o" \
  > "$build/binaries.sha256"
printf '%s\n' "$pin" > "$build/cproc.commit"

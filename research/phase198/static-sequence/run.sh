#!/bin/sh
# Source-level ceilings. Each guard owns its fresh build/evidence directory.
set -eu
tag=${1:?Supply a fresh experiment name}
case "$tag" in *[!A-Za-z0-9-]*|'') exit 2;; esac
r=research/phase198
b=selfhost/build/phase198
for mode in gen stream; do
  n="$tag-$mode"
  set --
  if test "$mode" = stream; then set -- --stream; fi
  python3 -B "$r/qualification/job.py" "$n" 45 16 \
    python3 -B "$r/static-sequence/ceiling.py" "$@" --out "$b/$n"
  python3 -B "$r/qualification/job.py" "$n-time" 30 16 \
    python3 -B "$r/fusion/time-products.py" --emission "$b/$n/report.json" \
    --source-ceiling --out "$b/$n-time"
done

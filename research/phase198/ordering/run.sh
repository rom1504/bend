#!/bin/sh
# Run on the repository's single execution lane with a fresh, simple name.
set -eu
tag=${1:?Supply a fresh experiment name}
case "$tag" in *[!A-Za-z0-9-]*|'') exit 2;; esac
r=research/phase198
b=selfhost/build/phase198
python3 -B "$r/ordering/prepare.py" --out "$b/$tag-source"
python3 -B "$r/fusion/queue.py" --out "$b/$tag-queue" "$tag-api:$tag-source"
python3 -B "$r/qualification/job.py" --rss-mib 3072 "$tag-controls" 18 12 \
  selfhost/.assets/bin/bun "$r/ordering/controls.mjs" "$b/$tag-api/report.json" "$b/$tag-controls"
python3 -B "$r/qualification/job.py" --rss-mib 3072 "$tag-emit" 90 80 \
  selfhost/.assets/bin/bun "$r/quotient/emit.mjs" --api "$b/$tag-api/report.json" --out "$b/$tag-emit" \
  --cases coverage-unicode-text-64,test-map-set-ops,complete-generic-row32
python3 -B "$r/qualification/job.py" --rss-mib 3072 "$tag-time" 65 32 \
  python3 -B "$r/fusion/time-products.py" --emission "$b/$tag-emit/report.json" --out "$b/$tag-time"

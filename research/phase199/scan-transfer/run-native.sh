#!/bin/sh
# Repository root, after receipt of the Phase199 CPU3 handoff.
set -eu
name=${1:-transfer-native01}
python3 -B research/phase199/screen/job.py --rss-mib 3072 "$name" 25 12 \
  python3 -B research/phase199/scan-transfer/integrated.py --out "selfhost/build/phase199/$name" --time

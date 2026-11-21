#!/bin/sh
# The identical source already passed the pinned upstream checker in transfer-base02.
set -eu
name=${1:-transfer-base03}
python3 -B research/phase199/screen/job.py --rss-mib 3072 "$name" 15 48 \
  python3 -B research/phase199/scan-transfer/baseline.py --roles c --out "selfhost/build/phase199/$name"

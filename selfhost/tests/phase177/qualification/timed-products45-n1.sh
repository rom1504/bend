#!/usr/bin/env bash
# Exact timed-wrapper QBE products; no benchmark execution or new timing score.
set -euo pipefail
cd "$(dirname "$0")/../../../.."
python3 -B selfhost/tests/phase177/job.py timed-products45-n1 180 64 \
  python3 -B selfhost/tests/phase170/reemit-products.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase177/full-native-n1/program \
  --image-receipt selfhost/build/phase177/full-native-n1/image-binding.json \
  --host native --stage N1 --target qbe --mode cache \
  --reference selfhost/build/phase169/quality-six-native01/report.json \
  --reference selfhost/build/phase169/quality-remaining-native01/report.json \
  --reference-role candidate --expected-count 45 --seconds 60 \
  --out selfhost/build/phase177/timed-products45-n1

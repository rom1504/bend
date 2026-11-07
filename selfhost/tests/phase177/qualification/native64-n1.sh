#!/usr/bin/env bash
# Run only after the explicit N1 build receipt is complete. Root owns the lane.
set -euo pipefail
cd "$(dirname "$0")/../../../.."
python3 -B selfhost/tests/phase177/job.py native64-n1 240 96 \
  python3 -B selfhost/tools/build/qualification.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase177/full-native-n1/program \
  --image-receipt selfhost/build/phase177/full-native-n1/image-binding.json \
  --host native --stage N1 --target qbe --mode cache --suite all \
  --seconds 30 --build-seconds 30 --execute-seconds 10 \
  --out selfhost/build/phase177/native64-n1

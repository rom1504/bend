#!/usr/bin/env bash
# One serial candidate-first cold pair, same frozen source and exact QBE oracle.
# Each invocation owns its aggregate guard; do not wrap this script in a guard.
set -euo pipefail
cd "$(dirname "$0")/../../../.."
common=(python3 -B selfhost/tools/build/native.py
  --assets selfhost/manifests/assets-native.json --host native --target qbe
  --mode cache --source selfhost/build/phase170/source-final/compiler.bend
  --expected selfhost/build/phase170/native-chain-final/n2/program.ssa
  --seconds 240)
python3 -B selfhost/tests/phase177/job.py cold-candidate01 280 220 \
  "${common[@]}" --stage N1 \
  --image selfhost/build/phase177/full-native-n1/program \
  --image-receipt selfhost/build/phase177/full-native-n1/image-binding.json \
  --out selfhost/build/phase177/cold-candidate01
python3 -B selfhost/tests/phase177/job.py cold-baseline01 280 220 \
  "${common[@]}" --stage N2 \
  --image selfhost/build/phase175/full-native-n2/program \
  --image-receipt selfhost/build/phase175/full-native-n2/report.json \
  --out selfhost/build/phase177/cold-baseline01

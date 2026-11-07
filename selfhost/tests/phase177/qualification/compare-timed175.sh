#!/usr/bin/env bash
# Metadata/file comparison only. Root owns even this short aggregate guard.
set -euo pipefail
cd "$(dirname "$0")/../../../.."
python3 -B selfhost/tests/phase177/job.py timed-products45-v175 30 4 \
  python3 -B selfhost/tests/phase177/qualification/compare-timed175.py \
  --candidate selfhost/build/phase177/timed-products45-n1/report.json \
  --reference selfhost/build/phase175/timed-products45/report.json \
  --out selfhost/build/phase177/timed-products45-v175

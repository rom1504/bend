#!/bin/sh
# Run from the repository root after the qualification owner explicitly releases CPU3.
set -eu
src=${1:-selfhost/build/phase198/map-pivot-source05/report.json}
first=${2:-map-pivot02}
edge=${3:-map-pivot-edge01}
driver=research/phase198/map-key/snapshot-run.py
guard=research/phase198/qualification/job.py
python3 -B "$guard" --rss-mib 3072 "$first" 29 60 python3 -B "$driver" \
  --source "$src" --cases coverage-map-churn-128,coverage-record-aggregation-256 \
  --roles cached,stock --time --out "selfhost/build/phase198/$first"
python3 -B "$guard" --rss-mib 3072 "$edge" 14 60 python3 -B "$driver" \
  --source "$src" --cases map-edges --roles cached,stock --out "selfhost/build/phase198/$edge"

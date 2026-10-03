# Phase41 tree-only measurement recipe

This is a plan for a candidate that retains only the tree change. It does not run targets or compile anything. Root owns the resource queue and executes the commands after the complete Phase41 candidate bundle exists.

Use the maintained Phase37 catalog (45 points from 23 source files), Phase41's retained starting bundle, and a fresh candidate bundle containing all 45 emitted modules. The Phase41 starting bundle is `selfhost/tools/performance/phase41/baseline/manifest.json`; it labels the checked06 modules as `baseline` and carries the pinned TypeScript modules. Do not compare changed tree timings with Phase40 historical rows: time those points fresh against this starting bundle.

## 1. Check identities across all 45 points

Run the maintained execution runner in preflight-only mode. This verifies catalog/source hashes and all 45 baseline, TypeScript, and candidate module identities without executing a target. `--set full` selects the complete catalog; `--plan` prevents output creation and execution.

```sh
NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
CPU=3
CANDIDATE=selfhost/build/phase41/tree-candidate/manifest.json

python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase41/baseline/manifest.json \
  --candidate "$CANDIDATE" --node "$NODE" --cpu "$CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 600 --set full --plan
```

Compare candidate and Phase41-baseline `(sha256, bytes)` for every case in the manifests/reported plan. Expected tree-only changed-module set is `tree-bitonic`, `variation-tree-bitonic-6-17`, and `variation-tree-bitonic-9-123`; the latter two use the same tree module bytes. Every other candidate module should match the Phase41 baseline exactly. Stop and resolve any additional identity changes before timing; do not classify an unexpected change as a control.

## 2. Time only fresh changed points and unchanged controls

Run the three changed points together at the maintained 60-second protocol, then run three unchanged controls in a separate fresh output. The changed set matches the exact Phase40 changed tree inputs; the control set spans an unchanged structural workload, a long scalar workload, and a small numeric workload. All three roles are measured in rotated paired rounds: Phase41 baseline, candidate, and pinned TypeScript. No Phase40 timing is used as denominator for the changed points.

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase41/baseline/manifest.json \
  --candidate "$CANDIDATE" --node "$NODE" --cpu "$CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 60 \
  --cases tree-bitonic,variation-tree-bitonic-6-17,variation-tree-bitonic-9-123 \
  --out selfhost/build/phase41/tree-changed-run01

python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --baseline selfhost/tools/performance/phase41/baseline/manifest.json \
  --candidate "$CANDIDATE" --node "$NODE" --cpu "$CPU" \
  --rss-mib 2048 --available-mib 2048 --budget 60 \
  --cases local-pair,scalar-region-8192,coverage-numeric-recurrence-1024 \
  --out selfhost/build/phase41/unchanged-controls-run01
```

Each output directory must be new. Preserve incomplete/failed reports; do not pool partial rounds or historical rows. The 60-second preset means three rotations, three warmup calls, 350 ms warmup floor, 40 ms calibration and 150 ms timed target; it is a wall ceiling, not a promise that a run completes. If the largest tree point exhausts it, retain the report and use a fresh successor output with `--budget 300` (five rotations, 600 ms warmup, 250 ms target) for that point alone. Keep controls as a distinct run.

## Timing and cost expectations

Phase40's five paired rounds report medians of 10.26 ms baseline / 4.71 ms candidate for `tree-bitonic`, 1.62 / 0.80 ms for depth6, and 22.12 / 12.09 ms for depth9. The unchanged controls were about 3.78 ms (`local-pair`), 0.116 ms (`scalar-region-8192`), and 0.0224 ms (numeric recurrence 1024). These raw timings give a planning scale only. Phase41 changes its comparison baseline and hardware state may differ; they are not denominators or guarantees. Phase40's separate checked compiler-cost evidence reports roughly 2.47 s median candidate request time for `tree-bitonic` versus 1.98 s Phase39, and the complete cost campaign took about 258 s. Those figures are also planning context, not Phase41 cost forecasts.

`phase35/compiler-cost-plan.py` is not a drop-in cost runner for the Phase41 portable baseline. It hard-codes a Phase32 attempt for its baseline compiler binding and Phase35's baseline-preparation format/workflow; the Phase41 manifest repackages checked06 program modules and has no live compiler preparation receipt. Use it only if a Phase41-specific cost plan binds the retained checked06 compiler identity and a fresh candidate preparation, with source/API/runtime/base identities checked explicitly. Program execution timing can use the Phase41 bundle directly; compiler cost must keep its own compatible provenance and fresh compilation requests.

The existing `phase40/select-execution.py` is an evidence selector for Phase40's two audited summaries and checked06 attempt. Its fixed ray-replacement rules and Phase40 report schemas do not define a Phase41 selector. For this tree-only measurement, retain the ordinary `programs/run.py` receipts and compare their identities/statistics directly; do not feed Phase41 results to the Phase40 selector or reuse historical timing rows.

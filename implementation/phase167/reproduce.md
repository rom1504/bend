# Reproduce the bounded architecture experiment

Run from the repository root on `selfhost/bootstrap`, using the explicit pinned
assets in `selfhost/manifests/assets-native.json`. The maintained Phase152 source
identity must still match; extraction deliberately refuses a changed parent.
All compiler algorithms below are Bend. Python/JS scripts only transport inputs,
select an exported entry, measure, inspect or orchestrate.

The checked API used for the final pair is bound in
`evidence/observer-api02/report.json`; exact source snapshots and machine products
remain under `selfhost/build/phase167`, with guarded products archived and verified
through `selfhost/build-retention/phase167-*-close`. Source extraction manifests
record exact declarations and protected-parent checks. Never substitute the older
`qbe-n2` asset for the qualified Phase152 image merely because of its label.

The final source-only replay is [byte-identical](reproduction.json) to the
independently checked observer API source (`85f1b307…`).

Use fresh names. Do not nest guards or run another performance target concurrently.
The default 5GiB disk reserve remains active.

## Source-only extraction

```sh
python3 -B experiments/phase167/tools/prepare-final.py \
  --out selfhost/build/phase167/repro-source
python3 -B experiments/phase163/tools/prepare.py \
  --module selfhost/tests/phase167/verifier-workload.bend \
  --export main --export p167w_check \
  --out selfhost/build/phase167/repro-fixture
```

## Acquire the independently source-checked experimental API

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase167/repro-api-guard \
  --run-root selfhost/build/phase167/repro-api \
  --seconds 100 --disk-mib 32 --rss-mib 3072 --available-mib 16384 -- \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase167/repro-source/compiler.bend \
  --exports selfhost/build/phase167/repro-source/exports.json \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun --out selfhost/build/phase167/repro-api
```

Run `observer-controls.mjs API_RECEIPT OUT` under a fresh small guard; it requires
all 35 ordinary/projection controls to pass. This checks finite boundaries and
source types, not a new whole-compiler proof.

## Complete baseline and candidate builds

For each role `baseline` and `observers`, invoke the following with fresh guard
and artifact paths. `--preparation cache` authenticates the existing standard-Base
carrier through the maintained asset validator; source checking and all backend
work are fresh. `live` instead reparses/checks Base in both routes.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/phase167/repro-baseline-guard \
  --run-root selfhost/build/phase167/repro-baseline \
  --seconds 90 --disk-mib 16 --rss-mib 3072 --available-mib 16384 -- \
  python3 -B experiments/phase167/tools/one-build-v5.py \
  --receipt selfhost/build/phase167/repro-api/report.json \
  --source selfhost/build/phase167/repro-fixture/compiler.bend \
  --role baseline --preparation cache \
  --out selfhost/build/phase167/repro-baseline
```

Change all three `repro-baseline` path components and `--role baseline` to the
candidate equivalents for the other run. Compare complete time plus the combined
backend/render interval. Do not compare only `lowerVerifySeconds`: cursor and
materialized emission place rendering at different points. The machine receipt
contains separate `qbe`, `assemble` and `link` jobs. Input checking includes parsing,
dependency preparation and erasure; this pilot does not split those further.

Then use `runtime.py --build BASELINE/report.json --build CANDIDATE/report.json
--expected 768 --rounds 4 --out FRESH` under a 60s/4MiB/2GiB guard. It alternates
execution order and requires exact complete stdout and successful exit every time.
This small native workload has resolved runtimes; it is not the frozen45 score.

`inspect-observers.mjs` reproduces candidate counts separately from clean timing.
`reasons.mjs` and `admission-graph.py` reproduce the refusal/dependency diagnosis.
Their diagnostic work is not part of a clean build claim. The single-generic and
plain-demand contrasts have their own checked API04/source receipt and preserved
entry points; use their recorded guard commands, not silently changed policy.

The original harness versions remain as provenance. `request-v4.mjs` removed
unnecessary eager diagnostic JSON serialization; `request-v5.mjs` adds observer
selection without changing the clean baseline path. Corresponding QBE identities
remain exact. Earlier source-check failures and the original hidden-registry
renderer are retained as negative evidence.

Close every new guard with `selfhost/tools/build-retention/close.py`, using a
fresh path under `selfhost/build-retention` and `completed` or `failed` according
to the actual result. Do not classify this experiment as a qualified compiler.
`collect.py` reconstructs the committed metrics/evidence from the frozen Phase167
run names; it is an offline report collector, not another compiler or benchmark.

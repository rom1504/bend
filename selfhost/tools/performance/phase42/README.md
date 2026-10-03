# Phase42 portable performance guide

Run from the repository root. The maintained [Phase37 catalog](../phase37/catalog.json)
contains 45 input points across 23 sources. The retained
[Phase42 baseline](baseline/manifest.json) packages Phase41 checked01 and the
unchanged upstream TypeScript compiler pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`. Its relative archive paths work from
a fresh checkout without historical build directories or an upstream checkout.
Absolute paths inside acquisition receipts describe provenance, not replay inputs.
The archived pure entry points do not invoke the modules' lazy foreign IO paths.

This guide does not assert that a Phase42 candidate is installed or that a
`current/` bundle exists. Use a freshly prepared candidate now; after a reviewed
portable current bundle is published, the same commands accept
`selfhost/tools/performance/phase42/current/manifest.json`. Compiler installation,
semantic controls, acquisition, clean timing and profiling are separate steps.

## Select a time budget

| Ceiling | Selection | Points | Purpose |
| ---: | --- | ---: | --- |
| 20 seconds | `fast` | 5 | Quick rejection and unchanged scalar/pair/row controls |
| 60 seconds | `core` | 8 | Fast controls plus Mandelbrot, edit distance and RLE |
| 300 seconds | `broad` | 10 | Closures, list pipelines, Unicode, Map and numeric recurrence |
| 600 seconds per batch | Three consecutive 15-point slices of `full` | 45 total | Complete maintained catalog, including variations and holdouts |

Use Linux, Python 3.9+, `taskset`, Node 24+, an available CPU and fresh output
directories. Diagnostics specifically require recorded Node 24.18.0 and its
embedded Acorn 8.16.0. Pick an absolute Node executable and CPU on this host:

```sh
PHASE42_NODE=/absolute/path/to/node
PHASE42_CPU=3
PHASE42_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE42_BASELINE=selfhost/tools/performance/phase42/baseline/manifest.json
PHASE42_CANDIDATE=selfhost/build/phase42-live/candidate-NEW/manifest.json

run42() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE42_CATALOG" --baseline "$PHASE42_BASELINE" \
    --candidate "$PHASE42_CANDIDATE" \
    --node "$PHASE42_NODE" --cpu "$PHASE42_CPU" \
    --rss-mib 2048 --available-mib 2048 "$@"
}

run42 --budget 20 --set fast --plan
run42 --budget 20 --set fast --out selfhost/build/phase42-live/fast-NEW
run42 --budget 60 --set core --out selfhost/build/phase42-live/core-NEW
run42 --budget 300 --set broad --out selfhost/build/phase42-live/broad-NEW
```

`--plan` verifies inputs and prints the protocol without executing generated
programs. Omit `--candidate` from the function to replay only the retained
Phase41/TypeScript reference before a candidate is available. To replay a
published Phase42 bundle, change only `PHASE42_CANDIDATE` to its manifest.
No compiler is built or imported by the timing runner.

A ceiling is not a duration promise. The 600-second preset requests five fresh
rounds per role, except three for raytrace, with a one-second warmup floor per
process. All 45 points across three roles therefore require **669 one-second
warmups alone**. A single `--budget 600 --set full` cannot complete that protocol.
Use three serial 15-point batches, each with a fresh 600-second ceiling:

```sh
for PHASE42_BATCH in 0 1 2; do
  PHASE42_CASES=$(python3 - "$PHASE42_CATALOG" "$PHASE42_BATCH" <<'PYCASES'
import json, sys
cases = json.load(open(sys.argv[1]))['sets']['full']
assert len(cases) == 45 and len(set(cases)) == 45
start = 15 * int(sys.argv[2])
print(','.join(cases[start:start + 15]))
PYCASES
)
  run42 --budget 600 --cases "$PHASE42_CASES" \
    --out "selfhost/build/phase42-live/full-batch-${PHASE42_BATCH}-NEW" || break
done
```

The batch partition preserves catalog order and unchanged inputs. Complete
coverage requires all three reports to finish successfully; inspect any failed
batch before continuing with a new output directory. Total requested ceilings
are 1,800 seconds, plus small cleanup/reporting overhead. Even a 15-point batch
can exhaust its ceiling on a different host. Keep all work serial and stop other
builds/benchmarks during measurements. The execution lock and polled memory
supervisor protect the runner; they do not reserve host memory.

## Acquire a live candidate

Preparation is outside timing budgets. Use the
[checked development workflow](../../../../docs/PHASE5_DEVELOPMENT.md) to build a
fresh checked attempt after compiler edits. Supply that completed attempt:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog "$PHASE42_CATALOG" --attempt selfhost/build/my-checked-attempt \
  --set full --out selfhost/build/phase42-live/candidate-NEW \
  --node "$PHASE42_NODE" --cpu "$PHASE42_CPU" \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
```

For the currently installed verified release, omit `--attempt`; this tests the
installed release, not unbuilt working-tree edits. Preparation emits each distinct
source once and records checked compiler/source/module identities. Prepare `fast`,
`core`, `broad` or exact `--cases` instead of `full` when only that selection is
needed. A candidate must contain every selected point. The retained Phase42
baseline keeps Phase41 as the denominator even after a new release is installed.

## Profile and compare the exact generated programs

After a successful ordinary run, use its copied modules and receipt:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog "$PHASE42_CATALOG" --from-run selfhost/build/phase42-live/broad-NEW \
  --cases coverage-list-pipeline-128,coverage-list-pipeline-512 \
  --budget 60 --mode all --out selfhost/build/phase42-live/list-profiles-NEW \
  --node "$PHASE42_NODE" --cpu "$PHASE42_CPU" \
  --rss-mib 2048 --available-mib 2048
```

`--from-run` fixes the exact measured roles and module hashes; do not combine it
with `--baseline` or `--candidate`. Select any covered subset, or use `--mode cpu`
or `--mode allocation`. Profiling has its own budget and supplies no speed ratio.

For a structural comparison without importing the analyzed modules:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog "$PHASE42_CATALOG" --baseline "$PHASE42_BASELINE" \
  --candidate "$PHASE42_CANDIDATE" --set broad --budget 60 --mode static \
  --out selfhost/build/phase42-live/static-NEW \
  --node "$PHASE42_NODE" --cpu "$PHASE42_CPU" \
  --rss-mib 2048 --available-mib 2048
```

Open diagnostic `report.md`, `analysis/comparison.html` and `analysis/report.md`.
The side-by-side view maps generated definitions to source; AST counts describe
syntax sites, not executed allocations. Raw CPU and sampled-allocation profiles
remain under `profiles/`. Sampling can attribute inlined work to callers and zero
samples do not establish allocation-free execution. Confirm every performance
claim with separate unprofiled timing.

## Interpret and preserve results

Timing `report.json` and `report.md` retain full results, paired rounds, individual
samples, medians, import/first-call costs and drift. `candidate/typescript` is the
current slowdown; `baseline/candidate` is the improvement over Phase41. Ratios
require every requested round for that point. Failed, interrupted or incomplete
samples remain visible and supply no favorable ratio. Full-module byte counts
include runtime/Base support and are not a measure of export execution cost.

Retain the frozen modules, receipts, consumed tools and per-process logs with each
report. Focused semantic/mutation/admission controls under the Phase42 owner
folders are separate evidence; a catalog fixed-result timing pass does not replace
them. Read the [runner guide](../programs/README.md),
[diagnostics guide](../programs/DIAGNOSTICS.md), and
[evidence accounting tools](evidence/README.md) for protocol and accounting detail.
Installation-document updates are drafted separately in
[INSTALLATION-DOC-UPDATES.md](INSTALLATION-DOC-UPDATES.md).

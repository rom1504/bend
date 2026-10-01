# Phase39 generated-program performance tools

The original `selfhost/build/phase39` campaign is closed. The commands below
write into a separate `selfhost/build/phase39-replay` directory; use fresh output
names for each run and never modify the closed campaign tree.

Use this directory to compare the programs produced by the selected Phase39
compiler, the previous Phase37 compiler and pinned upstream TypeScript. The maintained
[runner](../programs/README.md) executes already compiled modules; ordinary timing
does not build, import or execute a compiler.

The frozen [Phase37 catalog](../phase37/catalog.json) contains **45 input points
in 23 source files**, including the original 15 points, 14 varied algorithm/input
points and 16 points across eight added application families. Several inputs
share a source and two sources wrap existing algorithms: these are not 45
independent programs or complete language coverage. The old
`coverage-holdout` group is a historical name; Phase39 studied its expression
workload, so it is no longer an unseen holdout.

The [baseline bundle](baseline/manifest.json) contains the previous Phase37 checked03
(API `ea5db4a2…`) and TypeScript at commit
`018751270e800bc222a93dad7f257083ee53a5f7`. The available [current bundle](current/manifest.json) contains
Phase39 checked05 API
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
The compiler is installed and release-verified. The current bundle contains all 45
points and retains checked emission provenance in a 1,326,874-byte archive. Both
portable bundles work without historical build directories; absolute paths in
receipts describe acquisition history, not execution dependencies. The archives
and catalog sources must be present.

`portable-smoke01` passed the five-point `fast` set against both portable bundles
in 17.444 seconds: **45 samples = 5 points × 3 roles × 3 rounds**. This verifies the
portable execution path, not all 45 catalog points or a separate performance claim.
The full 45-point candidate acquisition and final comparisons are recorded in the
[campaign report](../../../../implementation/phase39/README.md).

## Run at four depths

Run from the repository root with Linux, Python 3.9+, `taskset` and Node 24+.
Set an absolute Node path and an available CPU. Each output directory must be new.
The following shell helper only abbreviates the unchanged maintained runner:

```sh
PHASE39_NODE=/absolute/path/to/node
PHASE39_CPU=3
PHASE39_CANDIDATE=selfhost/tools/performance/phase39/current/manifest.json

run39() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog selfhost/tools/performance/phase37/catalog.json \
    --baseline selfhost/tools/performance/phase39/baseline/manifest.json \
    --candidate "$PHASE39_CANDIDATE" \
    --node "$PHASE39_NODE" --cpu "$PHASE39_CPU" \
    --rss-mib 2048 --available-mib 2048 "$@"
}

run39 --budget 20 --set fast --out selfhost/build/phase39-replay/fast-NEW
run39 --budget 60 --set core --out selfhost/build/phase39-replay/core-NEW
run39 --budget 300 --set broad --out selfhost/build/phase39-replay/development-NEW
run39 --budget 600 --set full --out selfhost/build/phase39-replay/full-NEW
```

| Budget ceiling | Selected set | Points | Fresh rounds per role/point | Warmup floor | Timed-block target |
|---:|---|---:|---:|---:|---:|
| 20 seconds | `fast` | 5 | 3 | 100 ms | 50 ms |
| 60 seconds | `core` | 8 | 3 | 350 ms | 150 ms |
| 300 seconds | `broad` | 10 | 5 | 600 ms | 250 ms |
| 600 seconds | `full` | 45 | 5 | 1,000 ms | 300 ms |

The case named `raytrace` uses at most three rounds and one warmup call; other points require
three warmup calls. Both also meet the warmup time floor. Budgets include
verification, extraction, process startup, import, first call, warmup,
calibration and measurement. They are ceilings, not duration promises. In
particular, **45 points may not finish within one 600-second run**. The runner
preserves incomplete work, exits nonzero and gives no ratio for an incomplete
point. It never reduces an input silently. Use the smaller groups below for
complete broad coverage, with a separate ceiling for each invocation.

`fast` and `core` are historical canaries; they do not include every newly
optimized workload. `broad` in this catalog means the ten development application
points, unlike the default historical catalog's meaning. A larger budget selects a
deeper preset; it does not spend unused time extending one case's warmup. Inspect
ranges and within-sample drift before accepting a small gain.

## Select the relevant workloads

```sh
python3 selfhost/tools/performance/programs/run.py \
  --catalog selfhost/tools/performance/phase37/catalog.json --list
run39 --budget 20 --set fast --plan

# A quick countdown rejection screen, then a deeper paired confirmation.
run39 --budget 20 \
  --cases coverage-numeric-recurrence-256,coverage-numeric-recurrence-1024 \
  --out selfhost/build/phase39-replay/numeric-screen-NEW
run39 --budget 300 \
  --cases coverage-numeric-recurrence-256,coverage-numeric-recurrence-1024 \
  --out selfhost/build/phase39-replay/numeric-confirm-NEW

# Explicit-stack producer and private-chooser work.
run39 --budget 60 --cases coverage-expression-32,coverage-expression-128 \
  --out selfhost/build/phase39-replay/expression-NEW
run39 --budget 300 \
  --cases variation-tree-bitonic-6-17,tree-bitonic,variation-tree-bitonic-9-123 \
  --out selfhost/build/phase39-replay/tree-confirm-NEW
```

`--cases` overrides `--set`; neither changes the fixed input or expected result.
`--plan` verifies the selected source and bundle identities and prints the plan
without executing a generated program. For a complete inventory split, run the
following four groups serially. They partition all 45 points without duplication:

```sh
PHASE39_GROUP=historical
PHASE39_CASES=$(python3 selfhost/tools/performance/phase37/catalog-cases.py "$PHASE39_GROUP")
run39 --budget 600 --cases "$PHASE39_CASES" \
  --out "selfhost/build/phase39-replay/${PHASE39_GROUP}-NEW"
```

Repeat with `coverage-variation` (14 points, 600 seconds),
`coverage-development` (10 points, 300 seconds) and `coverage-holdout`
(6 points, 300 seconds); `historical` has 15 points. These are per-run ceilings.
If a group exhausts its budget on another host, use smaller explicit selections
and retain the failed attempt. Do not substitute older timings as denominators.

## Profiles and generated-code comparison

Diagnostics are separate instrumented runs. They include syntax/function counts,
side-by-side generated code, CPU profiles and sampled allocation profiles for
all selected roles. They never enter clean timing ratios. For a small selection,
either append `--diagnostics all --diagnostic-budget 60` to `run39`, or reuse the
exact copied modules from a successful run:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --from-run selfhost/build/phase39-replay/numeric-confirm-NEW \
  --budget 60 --mode all \
  --out selfhost/build/phase39-replay/numeric-diagnostics-NEW \
  --node "$PHASE39_NODE" --cpu "$PHASE39_CPU" \
  --rss-mib 2048 --available-mib 2048
```

`--mode static` produces syntax analysis without executing analyzed programs;
`cpu` and `allocation` add their respective profiles. See the
[diagnostics guide](../programs/DIAGNOSTICS.md). Allocation samples estimate bytes
allocated during the window, not retained memory or exact object counts. A CPU
sample share is not a predicted speedup. Diagnostics have their own ceiling;
a timing budget plus a diagnostic budget can consume both.

## Prepare a new compiler candidate

A new compiler source revision needs a new checked development attempt. Prepare
only relevant points during development, then the full catalog for acceptance:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --attempt selfhost/build/MY_CHECKED_ATTEMPT --set full \
  --out selfhost/build/phase39-replay/MY_CANDIDATE \
  --node "$PHASE39_NODE" --cpu "$PHASE39_CPU" \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
PHASE39_CANDIDATE=selfhost/build/phase39-replay/MY_CANDIDATE/manifest.json
```

Preparation checks each distinct source once and binds emitted bytes to its
compiler and source receipts. It is outside execution budgets. Replace `--set
full` with `--cases ...` for a focused iteration. Portable publication uses
`freeze-candidate.py --from PREPARATION/manifest.json --attempt CHECKED_ATTEMPT
--out NEW_BUNDLE_DIRECTORY`; it requires all 45 points and copies provenance
without running a compiler or target program. Do not overwrite frozen bundles.

## Read results and preserve correctness

`report.md` gives per-point medians; `report.json` retains ranges, drift, first
call/import costs, all paired rounds, identities and failures. `baseline/candidate`
is the incremental Phase39 gain; `candidate/typescript` is the remaining slowdown.
The timed export includes exact result checking and checksum work. Import and
first call are reported separately. There is no claim that one average describes
all Bend programs.

The campaign's separate [compiler-cost report](../../../../implementation/phase39/compiler-cost.md)
measures normal checked compilation requests, not generated-program execution.
It requires checked attempt/cache artifacts and the pinned checkout; portable
execution bundles alone are insufficient. Its planner accepts the fresh,
unarchived candidate preparation. See
[compiler-cost preparation](../../../../implementation/phase39/compiler-cost-preparation.md).

Favorable execution results do not replace semantic gates. The campaign retains
versioned countdown, guard, structural-component and unary-producer controls,
including exact-entry, mutable host/dependency, error-order, alias and stack
witnesses. `new-owner-close-v4.py` and its pinned specification bind those actual
controls; `phase37-owner-plan.py` retains inherited native-cast/DataView/finite
controls. Consult the [campaign report](../../../../implementation/phase39/README.md)
for selected attempts and completed acceptance evidence.

The inherited Phase35 counter fixture predates scalar countdown admission.
`vector-counter-fixture-controls-v1.mjs` preserves its 35 independent input
oracles, escaping/observed/aliased predecessor refusals and five mutation
boundaries, but now requires the eligible scalar private loop to use Number.
`counter-owner-rebind-v2.py` records that explicit successor, binds its exact
successful supervised execution and consumed tool bytes, and creates a new
owner mapping after it passes. The original plan and failed old expectation stay
unchanged; the ordinary collector/auditor uses the new aggregate through
`--owner-controls`. This is an updated admission expectation, not permission to
accept changed results or weakened mutation/escaping-value controls.

Preparation, timing, diagnostics and compiler-cost tools own the shared resource
lock; invoke them serially and do not wrap them in another lock-owning supervisor.
These commands use a 1 GiB Node heap, 2 GiB process-tree RSS ceiling and 2 GiB
free-memory floor. The limits are sampled, so they are not a hard kernel memory
reservation. Preserve unsuccessful output directories and use a new name on
retry. Unrelated builds and benchmarks must not run alongside a measurement.

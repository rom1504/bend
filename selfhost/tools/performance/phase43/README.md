# Phase43 portable generated-program guide

Run from the repository root. The maintained [catalog](../phase37/catalog.json)
contains 45 points across 23 sources. The [baseline](baseline/manifest.json)
retains Phase42 checked16 plus upstream TypeScript pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`; the [current](current/manifest.json)
contains the installed Phase43 checked14 compiler's actual full acquisition.
Both portable archives have been independently reopened and hash checked.
Both bundles use relative archive/module paths and replay without historical
build directories or a compiler checkout. Original absolute receipt paths record
provenance. Phase42 baseline/current and its closed evidence remain unchanged.

The final [release evidence](evidence/selected-release.json) binds the selected
attempt, API, semantic owners, complete timing, costs, profiles and installed closure.
Installation, semantic controls, acquisition, timing and profiling are separate.
A portable smoke pass is not full-catalog performance evidence. This maintained
corpus is a regression corpus with varied inputs; it does not establish universal
parity with TypeScript. Historical holdout labels identify original catalog
partitions, not untouched holdouts after these workloads informed optimization.

| Ceiling | Selection | Points | Purpose |
| ---: | --- | ---: | --- |
| 20 seconds | Three explicit scalar/pair/row cases below | 3 | Compact rejection screen |
| 60 seconds | `fast` | 5 | Complete unchanged scalar/pair/row smoke |
| 60 seconds | `core` | 8 | Fast controls, Mandelbrot, edit distance and RLE |
| 300 seconds | `broad` | 10 | Closures, Unicode, Map, list pipelines and numeric recurrence |
| 600 seconds per batch | Three serial 15-point slices of `full` | 45 total | Full maintained regression inputs and variations |

Release smoke verification completed in 11.70 seconds for compact20 (3/3),
41.93 seconds for all five fast cases with budget60, and 25.81 seconds for the
three BST/Map/numeric targets with budget60. See the
[evidence index](evidence/selected-release.json) for exact receipts.

Use Linux, Python 3.9+, `taskset`, Node 24+, a free CPU, and new output directories.
Recorded diagnostics require Node 24.18.0 and its embedded Acorn 8.16.0. Set an
absolute Node executable and available CPU:

```sh
PHASE43_NODE=/absolute/path/to/node
PHASE43_CPU=3
PHASE43_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE43_BASELINE=selfhost/tools/performance/phase43/baseline/manifest.json
PHASE43_CANDIDATE=selfhost/tools/performance/phase43/current/manifest.json

run43() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE43_CATALOG" --baseline "$PHASE43_BASELINE" \
    --candidate "$PHASE43_CANDIDATE" --node "$PHASE43_NODE" \
    --cpu "$PHASE43_CPU" --rss-mib 2048 --available-mib 2048 "$@"
}
run43 --budget 20 --set fast --plan
run43 --budget 20 --cases local-pair,scalar-region-8192,complete-generic-row32 \
  --out selfhost/build/phase43-live/compact-NEW
run43 --budget 60 --set fast --out selfhost/build/phase43-live/fast-NEW
run43 --budget 60 \
  --cases coverage-bst-64,coverage-map-churn-128,coverage-numeric-recurrence-1024 \
  --out selfhost/build/phase43-live/targets-NEW
run43 --budget 60 --set core --out selfhost/build/phase43-live/core-NEW
run43 --budget 300 --set broad --out selfhost/build/phase43-live/broad-NEW
```

`--plan` checks inputs without executing generated programs. Timing imports no
compiler. Omit candidate to replay only retained Phase42/TypeScript references.
Ceilings are limits, not promised durations. The release five-case budget20 replay
exhausted its budget after four points; it is preserved as incomplete evidence.
Use the compact three-case screen for 20 seconds or give all five fast cases
60 seconds. These smoke timings are separate from the final 669-sample result.
Use three serial batches for full 45:

```sh
for PHASE43_BATCH in 0 1 2; do
  PHASE43_CASES=$(python3 - "$PHASE43_CATALOG" "$PHASE43_BATCH" <<'PYCASES'
import json,sys
ids=json.load(open(sys.argv[1]))['sets']['full']
assert len(ids)==45 and len(set(ids))==45
start=15*int(sys.argv[2]);print(','.join(ids[start:start+15]))
PYCASES
)
  run43 --budget 600 --cases "$PHASE43_CASES" \
    --out "selfhost/build/phase43-live/full-batch-${PHASE43_BATCH}-NEW" || break
done
```

All three reports must complete for full coverage. The 600-second preset requests
five fresh rounds per role, three for raytrace, with a one-second warmup floor:
all 45 points/three roles require 669 seconds of warmup alone. One 600-second full
run cannot complete that protocol. Batch ceilings sum to 1,800 seconds plus small
reporting/cleanup overhead and can still expire on another host. Keep other
builds/benchmarks stopped and preserve incomplete observations.

Acquire a live edited compiler outside timing using the checked development
workflow, then prepare its completed attempt into a fresh directory:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog "$PHASE43_CATALOG" --attempt selfhost/build/my-checked-attempt \
  --set full --out selfhost/build/phase43-live/candidate-NEW \
  --node "$PHASE43_NODE" --cpu "$PHASE43_CPU" \
  --heap-mib 1024 --rss-mib 2048 --available-mib 2048
```

Omit `--attempt` only to test the verified installed release. Preparation emits
once per source and freezes exact compiler/source/module receipts. Use fast/core/
broad or exact cases when full acquisition is unnecessary. Every timed point must
exist in the chosen candidate.

Profile the exact successfully measured modules with a separate budget:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog "$PHASE43_CATALOG" \
  --from-run selfhost/build/phase43-live/targets-NEW \
  --cases coverage-bst-64,coverage-map-churn-128 \
  --budget 60 --mode all --out selfhost/build/phase43-live/profiles-NEW \
  --node "$PHASE43_NODE" --cpu "$PHASE43_CPU" \
  --rss-mib 2048 --available-mib 2048
```

`--from-run` binds exact measured roles/hashes; do not combine it with baseline or
candidate. Modes `cpu`, `allocation`, `static` and `all` select separate investigations. Static
mode may instead take baseline/candidate manifests and does not import analyzed
programs. Inspect report.md, analysis/comparison.html and analysis/report.md.
Syntax counts describe emitted sites, sampled allocations describe attribution,
and zero samples do not prove zero allocation. Profiles supply no speed ratio.

Reports preserve all samples, paired rounds, medians, ranges, drift and import/
first-call costs. Candidate/TypeScript is current slowdown; baseline/candidate is
improvement over Phase42. Missing drift stays missing. Incomplete cases supply no
favorable ratio. Keep source/receipt/tool hashes and process logs alongside results.
Semantic mutation/alias/admission controls remain independent of fixed-result
catalog timing. Read the [runner](../programs/README.md) and
[diagnostic guide](../programs/DIAGNOSTICS.md).

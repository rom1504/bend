# Phase44 portable generated-program benchmarks

Run from the repository root. The [catalog](../phase37/catalog.json) has 45 points
across 23 sources. The verified [baseline](baseline/manifest.json) retains Phase43
checked14 and upstream TypeScript pinned to `018751270e800bc222a93dad7f257083ee53a5f7`;
the verified [current](current/manifest.json) contains selected Phase44 checked04.
Portable archives use relative module paths; original receipt paths record provenance.
The unchecked saved-JavaScript known-call experiment was rejected and is not current.
See the [Phase44 report](../../../../implementation/phase44/README.md) for results.

These commands reuse the maintained runner; they do not claim new Phase44 smoke
replays. This varied regression corpus does not establish universal program parity.

| Ceiling | Selection | Points | Purpose |
| ---: | --- | ---: | --- |
| 20 seconds | Three explicit cases below | 3 | Compact rejection screen |
| 60 seconds | `fast` | 5 | Scalar, pair and row controls |
| 60 seconds | `core` | 8 | Add Mandelbrot, edit distance and RLE |
| 300 seconds | `broad` | 10 | Closures, Unicode, Map, lists and recurrence |
| 600 seconds per batch | Three serial slices of `full` | 45 total | Full maintained corpus |

Use Linux, Python 3.9+, `taskset`, a free CPU and fresh output directories. Recorded
measurements use Node 24.18.0, CPU 3, 1,024 MiB Node heap, 2,048 MiB process-tree RSS
limit and 2,048 MiB minimum available memory. Change the executable for your host.
Keep builds, profiling and other benchmarks stopped while timing; run serially.

```sh
PHASE44_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE44_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE44_BASELINE=selfhost/tools/performance/phase44/baseline/manifest.json
PHASE44_CANDIDATE=selfhost/tools/performance/phase44/current/manifest.json
run44() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE44_CATALOG" --baseline "$PHASE44_BASELINE" \
    --candidate "$PHASE44_CANDIDATE" --node "$PHASE44_NODE" \
    --cpu 3 --rss-mib 2048 --available-mib 2048 "$@"
}
run44 --budget 20 --cases local-pair,scalar-region-8192,complete-generic-row32 --plan
run44 --budget 20 --cases local-pair,scalar-region-8192,complete-generic-row32 \
  --out selfhost/build/phase44-live/compact-NEW
run44 --budget 60 --set fast --out selfhost/build/phase44-live/fast-NEW
run44 --budget 60 --set core --out selfhost/build/phase44-live/core-NEW
run44 --budget 300 --set broad --out selfhost/build/phase44-live/broad-NEW
```

`--plan` verifies inputs without executing programs. Ceilings are limits, not promised
durations; incomplete cases supply no favorable ratio. For full coverage:

```sh
for PHASE44_BATCH in 0 1 2; do
  PHASE44_CASES=$(python3 - "$PHASE44_CATALOG" "$PHASE44_BATCH" <<'PYCASES'
import json,sys
ids=json.load(open(sys.argv[1]))['sets']['full']
assert len(ids)==45 and len(set(ids))==45
start=15*int(sys.argv[2]);print(','.join(ids[start:start+15]))
PYCASES
)
  run44 --budget 600 --cases "$PHASE44_CASES" \
    --out "selfhost/build/phase44-live/full-batch-${PHASE44_BATCH}-NEW" || break
done
```

All three reports must complete. Five fresh rounds per role, three for raytrace,
require 669 samples and at least 669 seconds of warmup alone; one 600-second full
run cannot complete. Batch ceilings total 1,800 seconds plus reporting overhead.
Combine completed reports with `summarize-runtime.py CATALOG BASELINE_MANIFEST
CANDIDATE_MANIFEST NEW_OUT_JSON REPORT1 REPORT2 REPORT3`; it verifies raw receipts
and reports both point-weighted and equal-source geometric means.

Program execution timing excludes compilation; import and first-call costs are
recorded separately. Candidate/TypeScript is current slowdown; baseline/candidate
is improvement over Phase43. Compiler request costs are a separate experiment in
the Phase44 report. Acquire an edited checked compiler with `programs/prepare.py`
before timing, using the [runner guide](../programs/README.md). Profiles and syntax
comparisons use `programs/diagnose.py --from-run YOUR_COMPLETED_RUN` with a separate
budget; see the [diagnostic guide](../programs/DIAGNOSTICS.md). Preserve input hashes,
raw samples and process logs; profiling supplies explanations, not timing ratios.

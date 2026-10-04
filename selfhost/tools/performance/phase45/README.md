# Phase45 portable generated-program benchmarks

**Selected and installed release: worker23.** The
[current bundle](current/manifest.json) contains its checked generated programs,
published after final qualification, installation verification and 42 CLI checks.
The complete campaign passed all 45 points and 669 fresh samples across 23 sources.
See the [Phase45 report](../../../../implementation/phase45/README.md) and
[full runtime summary](evidence/runtime-summary.json) for results and scope.

| Aggregation | Phase44 / TypeScript | Worker23 / TypeScript | Phase44 / Worker23 |
| --- | ---: | ---: | ---: |
| Equal weight per benchmark point | 6.0867× | 3.0787× | 1.9771× |
| Equal weight per source | 8.2713× | 4.1467× | 1.9947× |

These are geometric means from the same full campaign. Worker23 improved 32
point medians and regressed 13; small differences include measurement variation.
The aggregate is about twice as fast as Phase44, with substantial remaining
gaps to TypeScript. A separate portable replay of the three 20-profile cases
passed 27 samples in 10.21 seconds; it verifies the published bundle and does not
replace the full campaign.

The rejected worker17b bundle remains byte-for-byte at
[current-exchange23](current-exchange23/manifest.json). Its large generic-row
regression and historical receipts are retained for diagnosis. That directory's
old experimental labels record its original state; it is not the current release.

The [catalog](../phase37/catalog.json) contains 45 points across 23 sources.
The [baseline bundle](baseline/manifest.json) combines exact Phase44 checked04
outputs with pinned upstream TypeScript outputs from control01. The candidate
was frozen from the complete worker23 checked acquisition. Compiler identities:

| Role | Identity |
| --- | --- |
| Baseline: Phase44 checked04 | `0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea` |
| Selected candidate: worker23 API | `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c` |
| Selected candidate: worker23 runtime | `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26` |
| TypeScript upstream commit | `018751270e800bc222a93dad7f257083ee53a5f7` |

Current manifest SHA256:
`264c1097af34d13dc164717975c560bc1da7744f76784416916ee15014d8712f`.
Candidate archive SHA256:
`1c65fbc74960c453753d296d709f12f4d83a86bbd854e8088f7ce9ff2f51b1dd`
(1,609,996 bytes; 176 members).

Packaging performed no compilation or program execution. Runtime module paths
are relative and all archived members were reopened and verified by SHA-256.
The baseline has 48 runtime modules, 24 per role; the candidate has 24. There
are 23 sources plus a complete-row observation adapter per role. Original
absolute receipt paths document acquisition history; they are not runtime path
requirements. The maintained Phase44 freezer's original candidate manifest is
preserved in [freeze-candidate-manifest.json](current/freeze-candidate-manifest.json).
Its legacy role label is corrected by a [label-only derivation](current/label-derivation.json).
The [selection derivation](current/selection-derivation.json) binds the final
qualification and installed 42-check smoke; the earlier
[unselected manifest](current/unselected-manifest.json) is preserved. These
derivations change labels and provenance pointers; compiler identities, module
bytes, archive and acquisition provenance remain unchanged.

## Choose an iteration profile

Run serially from the repository root on Linux with Python 3.9+, `taskset`, Node,
a free CPU, and fresh output directories. The recorded environment uses Node
24.18.0, CPU 3, a 1,024 MiB Node heap, a 2,048 MiB process-tree RSS limit and at
least 2,048 MiB available memory. Set the Node executable for your machine.
Stop compiler builds and profiling before collecting timings.

| Nominal budget | Selection | Points | Purpose |
| ---: | --- | ---: | --- |
| 20 seconds | Three explicit cases below | 3 | Early scalar, pair and generic-row regression screen |
| 60 seconds | `fast` | 5 | Small mixed controls |
| 60 seconds | `core` | 8 | Add Mandelbrot, edit distance and RLE |
| 300 seconds | `broad` | 10 | Closures, Unicode, Map, lists and recurrence |
| 600 seconds per batch | Three serial slices of `full` | 45 total | Complete maintained corpus |

```sh
PHASE45_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE45_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE45_BASELINE=selfhost/tools/performance/phase45/baseline/manifest.json
PHASE45_CANDIDATE=selfhost/tools/performance/phase45/current/manifest.json
run45() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE45_CATALOG" --baseline "$PHASE45_BASELINE" \
    --candidate "$PHASE45_CANDIDATE" --node "$PHASE45_NODE" \
    --cpu 3 --rss-mib 2048 --available-mib 2048 "$@"
}
run45 --budget 20 --cases local-pair,scalar-region-8192,complete-generic-row32 --plan
run45 --budget 20 --cases local-pair,scalar-region-8192,complete-generic-row32 \
  --out selfhost/build/phase45-live/compact-NEW
run45 --budget 60 --set fast --out selfhost/build/phase45-live/fast-NEW
run45 --budget 60 --set core --out selfhost/build/phase45-live/core-NEW
run45 --budget 300 --set broad --out selfhost/build/phase45-live/broad-NEW
```

`--plan` verifies selected inputs without executing programs. The 20/60/300/600
presets select warmups, sample duration and rounds, with a deadline for sampling.
They are not hard end-to-end wall-time guarantees: preparation, cleanup and
reporting can add time. A run may exhaust its budget before completing all
points; incomplete points supply no passing comparison. Short warmups are
rejection screens, not steady-state measurements. Use fresh output paths for
each run; the completed 27-sample portable replay above is recorded separately.

## Complete corpus and diagnostics

Five rounds per role, three for raytrace, require 669 samples and at least
669 seconds of warmup alone. A single 600-second full run cannot complete.
Use three serial batches with nominal 600-second budgets; this is not a guarantee
of completion within 1,800 seconds:

```sh
for PHASE45_BATCH in 0 1 2; do
  PHASE45_CASES=$(python3 - "$PHASE45_CATALOG" "$PHASE45_BATCH" <<'PYCASES'
import json,sys
ids=json.load(open(sys.argv[1]))['sets']['full']
assert len(ids)==45 and len(set(ids))==45
start=15*int(sys.argv[2]);print(','.join(ids[start:start+15]))
PYCASES
)
  run45 --budget 600 --cases "$PHASE45_CASES" \
    --out "selfhost/build/phase45-live/full-batch-${PHASE45_BATCH}-NEW" || break
done
```

All three batches must complete before computing a full-corpus result. The
maintained `../phase44/summarize-runtime.py` accepts `CATALOG BASELINE_MANIFEST
CANDIDATE_MANIFEST NEW_OUT_JSON REPORT1 REPORT2 REPORT3` and checks every raw
sample, role, point and module identity before combining point-weighted and
source-weighted geometric means. Supply the exact manifests used by those runs;
the historical raw campaign's labels are retained separately from these portable
bundle labels.

Timing includes the exported invocation and result validation; it excludes
compilation and import. Import and first-call costs are recorded separately.
Candidate/TypeScript is slowdown; baseline/candidate is improvement over Phase44.
For separate syntactic comparisons, CPU profiles and sampled allocations, use:

```sh
run45 --budget 60 --set core --diagnostics all --diagnostic-budget 300 \
  --out selfhost/build/phase45-live/core-diagnostics-NEW
```

Diagnostics have a separate nominal budget and run after successful timing. Profiles and
instrumented controls explain behavior; they do not supply timing samples. See
the [runner guide](../programs/README.md) and [diagnostic guide](../programs/DIAGNOSTICS.md).
Use the existing checked `programs/prepare.py` acquisition for an edited compiler
before timing it. Preserve failures, receipt hashes and raw samples. Keep frozen
experiments immutable and publish a successor in a fresh directory.

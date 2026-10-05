# Phase47 portable generated-program benchmarks

**Published and installed: checked array06.** The portable bundles contain
array06, the Phase45 worker23 baseline and pinned upstream TypeScript outputs.
The final candidate passed its checked build, four independent Array control
groups, eight maintained semantic suites, the full runtime comparison,
installation verification and all 42 ordinary and relocated CLI checks. The
installed API and runtime match the exact identities below. The final data-only
release receipt also verified 103 protected files unchanged.
See the [phase report](../../../../implementation/phase47/README.md) for current
results and limitations.

The [catalog](../phase37/catalog.json) has45 points across23 Bend sources. It
includes a complete-row observation adapter, so each role has24 distinct runtime
modules. [current/manifest.json](current/manifest.json) identifies the candidate;
[baseline/manifest.json](baseline/manifest.json) contains worker23 plus TypeScript.
These are frozen
generated programs: benchmark replay does not require compiling Bend, an installed
compiler, or the ignored acquisition directories.

| Role | Exact identity |
| --- | --- |
| Starting baseline: worker23 API | `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c` |
| Starting baseline: worker23 runtime | `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26` |
| Candidate: array06 API | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` |
| Candidate: array06 runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| TypeScript upstream commit | `018751270e800bc222a93dad7f257083ee53a5f7` |

The final paired full-corpus run completed all 45 points and 669 fresh samples:

| Geometric mean of runtime / TypeScript | Fresh worker23 baseline | Array06 |
| --- | ---: | ---: |
| Equal weight per point | 3.085148× | 2.919418× |
| Equal weight per source | 4.169855× | 3.995808× |

These averages summarize this corpus, not every Bend program. Worker23's prior
3.07865× result is historical context, **not the fresh Phase47 denominator**.
The published bundles passed all 45 reader checks. The separate nominal 20s
portable screen passed 27 fresh samples in 9.370488 seconds; it verifies replay
and does not replace the full comparison.
Compiler request cost is separately covered by the
[compiler-cost protocol](../../../../implementation/phase47/compiler-cost-plan.md).

## Choose an iteration profile

Run from the repository root on Linux with Python3.9+, `taskset` and Node24+.
The recorded environment uses Node24.18.0, CPU3, a1024MiB Node heap,
2048MiB process-tree RSS limit and4096MiB available-memory floor. Stop compiler
builds, profiling and compression before timing. Every output directory must
be fresh; retain failed and interrupted runs.

| Nominal budget | Selection | Points | Purpose |
| ---: | --- | ---: | --- |
| 20s | Fold, scalar zero, complete generic row | 3 | Quick affected-path and boundary rejection screen |
| 60s | `fast` | 5 | Initial rejection screen with all five maintained canaries |
| 60s | `core` | 8 | Recommended for private/Array backend changes: canaries plus Mandelbrot, edit distance and RLE |
| 300s | `broad` | 10 | Two sizes each for closures, lists, Unicode, Map and numeric recurrence |
| 600s per batch | Three slices of `full` | 45 total | Complete maintained corpus |

```sh
PHASE47_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE47_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE47_BASELINE=selfhost/tools/performance/phase47/baseline/manifest.json
PHASE47_CANDIDATE=selfhost/tools/performance/phase47/current/manifest.json
run47() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE47_CATALOG" --baseline "$PHASE47_BASELINE" \
    --candidate "$PHASE47_CANDIDATE" --node "$PHASE47_NODE" \
    --cpu 3 --rss-mib 2048 --available-mib 4096 "$@"
}
run47 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 --plan
run47 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 \
  --out selfhost/build/phase47-live/compact-NEW
run47 --budget 60 --set fast --out selfhost/build/phase47-live/fast-NEW
run47 --budget 60 --set core --out selfhost/build/phase47-live/core-NEW
run47 --budget 300 --set broad --out selfhost/build/phase47-live/broad-NEW
```

For changes to private workers or Array backends, use the existing `core` set
before the full corpus. It contains all five `fast` canaries plus `mandelbrot`,
`editdist` and `test-rle-roundtrip`; edit distance adds a positive private-tree
composition case. Keep `fast` and the20-profile screen for initial rejection.
The five-canary screen missed Phase47's private-tree composition gap, leaving
that gap until after an approximately19-minute array04 full run. The broader
core screen is an earlier opportunity to catch such omissions; its60-second
profile still does not guarantee completion within60 seconds.

Private-path activation is a separate semantic gate. The
[v4 tree controls](controls/array-tree-controls-v4.mjs), described in the
[control plan](../../../../implementation/phase47/control-plan.md#array-tree-v4-private-leaf-composition),
check that positive-depth calls enter the private tree and execute its actual
private array leaves, and that mutated host hooks refuse that path. Include
these untimed activation counters with the applicable boundary controls;
matching outputs or passing a timing screen alone does not prove the intended
private path was exercised. Counter derivatives supply no throughput evidence.

The five canaries are `local-pair`, `local-fold`, `scalar-region-0`,
`scalar-region-8192` and `complete-generic-row32`. Explicit equivalent selection:

```sh
run47 --budget 60 \
  --cases local-pair,local-fold,scalar-region-0,scalar-region-8192,complete-generic-row32 \
  --out selfhost/build/phase47-live/five-canaries-NEW
```

`--plan` verifies the chosen inputs and reports the protocol without executing
generated programs. Presets select warmups, rounds and timed-block duration;
their deadlines are not hard end-to-end wall-time guarantees. Verification,
cleanup and reporting add work, and a budget can expire before all points finish.
Incomplete points supply no passing comparison. Three20-profile points require
27 fresh samples across three roles if the run completes. Short warmups are
rejection screens, not evidence of stabilized V8 performance.

## Full45 comparison and diagnostics

A complete full protocol uses five rounds per role, except three for raytrace:
669 fresh samples and at least669 seconds of warmup alone. One600-second run
cannot complete all45. Use three serial batches, retaining every report:

```sh
for PHASE47_BATCH in 0 1 2; do
  PHASE47_CASES=$(python3 - "$PHASE47_CATALOG" "$PHASE47_BATCH" <<'PYCASES'
import json,sys
ids=json.load(open(sys.argv[1]))['sets']['full']
assert len(ids)==45 and len(set(ids))==45
start=15*int(sys.argv[2]);print(','.join(ids[start:start+15]))
PYCASES
)
  run47 --budget 600 --cases "$PHASE47_CASES" \
    --out "selfhost/build/phase47-live/full-batch-${PHASE47_BATCH}-NEW" || break
done
```

All three batches must complete before combining them. The existing data-only
summary tool verifies every sample, role, point and module identity:

```sh
python3 selfhost/tools/performance/phase44/summarize-runtime.py \
  "$PHASE47_CATALOG" "$PHASE47_BASELINE" "$PHASE47_CANDIDATE" \
  selfhost/build/phase47-live/full-summary-NEW.json \
  selfhost/build/phase47-live/full-batch-0-NEW/report.json \
  selfhost/build/phase47-live/full-batch-1-NEW/report.json \
  selfhost/build/phase47-live/full-batch-2-NEW/report.json
```

Candidate/TypeScript is slowdown; baseline/candidate is improvement over
worker23. Timings include exported invocation and exact result validation,
exclude compilation and import, and report import/first-call costs separately.
Equal-point and equal-source geometric means answer different questions; report
both along with individual regressions and incomplete measurements.

For separate source analysis, CPU profiles and sampled allocations:

```sh
run47 --budget 60 --cases local-fold,local-pair --diagnostics all \
  --diagnostic-budget 300 --out selfhost/build/phase47-live/array-diagnostics-NEW
```

Diagnostics run after successful timing with a separate nominal budget. Their
instrumented call rates are not throughput evidence. See the
[runner guide](../programs/README.md), [diagnostic guide](../programs/DIAGNOSTICS.md)
and [outlier inventory](../../../../implementation/phase47/outlier-inventory.md).

## Publication procedure

The [freezer](freeze-current.py) invokes the unchanged, audited Phase44
candidate freezer. It accepts explicit acquisition/attempt/output paths and exact
API/runtime identities. It requires45 checked points, audits each source and
emission receipt plus the observation adapter, preserves the original method
manifest, and changes only the published candidate label through a separate
derivation. Runtime module paths are relative; historical absolute receipt paths
are provenance, not replay requirements.

The following records the **historical array06 publication method**. Its output
directories now exist and must not be overwritten. For a successor, use fresh
candidate, baseline-copy and method directories, bind its own attempt/API/runtime
and run **after timing stops**, on CPU0:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase47/freeze-current.py \
  --from selfhost/build/phase47/array06-full/manifest.json \
  --attempt selfhost/build/phase47/checked-array06 \
  --baseline selfhost/build/phase47/baseline/manifest.json \
  --out selfhost/tools/performance/phase47/current \
  --baseline-out selfhost/tools/performance/phase47/baseline \
  --method-out selfhost/build/phase47/portable-array06-method \
  --expected-api 28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f \
  --expected-runtime 880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b \
  --label 'Phase47 array06 checked Array optimization (portable benchmark candidate)'
```

The baseline manifest/archive/provenance are copied byte-for-byte from the
already verified worker23+TypeScript package. Phase45 bundles remain untouched.
The candidate archive is streamed with bounded members and reopened to verify
every hash; both published bundles then pass the maintained reader for all45
points. The [publication receipt](current/publication.json) records exact identities, copied files,
method outputs and preservation checks. Packaging performs no compiler or
generated-program execution and makes no installation claim.

The array06 nominal 20s portable screen is complete as reported above. For future
publications, repeat that screen in a fresh output directory and record its
result separately from the full timing campaign. Compiler qualification,
installation, CLI checks and the terminal experiment
[evidence capsule](evidence/README.md) remain separate evidence. Never overwrite
a consumed bundle: publish a successor in a fresh directory and make any later
selection explicit.

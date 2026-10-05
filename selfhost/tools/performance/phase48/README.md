# Phase48 generated-program benchmarks

**Published and verified:** the current compiler is installed RNFA04; the reference
is Phase47 array06 plus pinned upstream TypeScript. The `current/manifest.json`
and `baseline/manifest.json` bundles below were reopened and verified for all 45
points. A fresh three-point/27-sample replay passes. The full comparison measures
2.9024× → 2.6789× TypeScript execution time (8.34% faster).
See the [phase report](../../../../implementation/phase48/README.md) and
[selected qualification](evidence/selected-qualification.json) for exact scopes.

The unchanged [catalog](../phase37/catalog.json) contains **45 points across 23
Bend sources**. The complete-row observer produces a second output from one
source, so each compiler role has 24 distinct source/output pairs. The portable
bundles freeze generated JavaScript and checked provenance: replay needs neither
an installed Bend compiler nor the ignored historical acquisition directories.

| Role | Exact identity |
| --- | --- |
| Array06 baseline API | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` |
| Installed RNFA04 API | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` |
| Shared runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| TypeScript upstream commit | `018751270e800bc222a93dad7f257083ee53a5f7` |

## Choose a short iteration first

Run from the repository root on Linux with Python 3.9+, `taskset` and Node
24.18.0. The profile analyzer requires its recorded embedded Acorn version;
another Node build may fail that check. The measured resource settings are CPU 3,
a 1,024 MiB Node heap, 2,048 MiB polled process-tree RSS limit and 4,096 MiB
available-memory floor. Keep builds, compression and other target execution
stopped while timing, including work on CPU 3's SMT sibling. Resource limits are
polled safeguards, not a guarantee against every host OOM.

| Nominal budget | Selection | Points | Use |
| ---: | --- | ---: | --- |
| 20 s | Fold, scalar zero, complete generic row | 3 | Quick rejection screen |
| 60 s | `fast` | 5 | All maintained canaries |
| 60 s | `core` | 8 | Canaries plus Mandelbrot, edit distance and RLE |
| 300 s | `broad` | 10 | Two sizes each of closures, lists, Unicode, Map and numeric recurrence |
| 600 s per batch | Three 15-point slices of `full` | 45 total | Complete corpus comparison |

```sh
PHASE48_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE48_CATALOG=selfhost/tools/performance/phase37/catalog.json
PHASE48_BASELINE=selfhost/tools/performance/phase48/baseline/manifest.json
PHASE48_CANDIDATE=selfhost/tools/performance/phase48/current/manifest.json
run48() {
  python3 selfhost/tools/performance/programs/run.py \
    --catalog "$PHASE48_CATALOG" --baseline "$PHASE48_BASELINE" \
    --candidate "$PHASE48_CANDIDATE" --node "$PHASE48_NODE" \
    --cpu 3 --rss-mib 2048 --available-mib 4096 "$@"
}
run48 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 --plan
run48 --budget 20 --cases local-fold,scalar-region-0,complete-generic-row32 \
  --out selfhost/build/phase48-live/compact-NEW
run48 --budget 60 --set fast --out selfhost/build/phase48-live/fast-NEW
run48 --budget 60 --set core --out selfhost/build/phase48-live/core-NEW
run48 --budget 300 --set broad --out selfhost/build/phase48-live/broad-NEW
```

Every output directory must be fresh. Preserve failed/interrupted runs. `--plan`
verifies inputs and displays the selected protocol without executing generated
programs. `--cases` and `--set` choose coverage; `--budget` chooses warmup, rounds
and sample duration independently. The broad set is not a superset of the canaries:
run `fast` or `core` first, then the relevant broader cases.

The five canaries are `local-pair`, `local-fold`, `scalar-region-0`,
`scalar-region-8192` and `complete-generic-row32`. For private worker, array or
aggregate changes, follow them with `core`: edit distance exercises composition
inside a private tree, and generic row checks the complete returned array state.
Do not replace its observer with a smaller checksum to obtain a favorable result.

A nominal budget is a ceiling/profile choice, not a request to fill that time or
a portable completion promise. Verification, first calls and cleanup take time;
an exhausted run cannot supply a complete comparison. Short warmups are useful
for rejecting bad changes but do not establish stabilized V8 performance. Inspect
half-window drift and retain exact per-point results before accepting small gains.

## Full 45-point comparison

The full protocol uses five fresh rounds per role except three for raytrace:
**669 samples**, with at least 669 seconds of warmup alone. One 600-second run
cannot finish all 45 points. Run the following three batches serially:

```sh
for PHASE48_BATCH in 0 1 2; do
  PHASE48_CASES=$(python3 - "$PHASE48_CATALOG" "$PHASE48_BATCH" <<'PYCASES'
import json,sys
ids=json.load(open(sys.argv[1]))['sets']['full']
assert len(ids)==len(set(ids))==45
start=15*int(sys.argv[2]);print(','.join(ids[start:start+15]))
PYCASES
)
  run48 --budget 600 --cases "$PHASE48_CASES" \
    --out "selfhost/build/phase48-live/full-batch-${PHASE48_BATCH}-NEW" || break
done
```

Combine only after all three reports pass. The maintained data-only summarizer
checks complete coverage, raw samples/processes, role identities and rotations:

```sh
python3 selfhost/tools/performance/phase44/summarize-runtime.py \
  "$PHASE48_CATALOG" "$PHASE48_BASELINE" "$PHASE48_CANDIDATE" \
  selfhost/build/phase48-live/full-summary-NEW.json \
  selfhost/build/phase48-live/full-batch-0-NEW/report.json \
  selfhost/build/phase48-live/full-batch-1-NEW/report.json \
  selfhost/build/phase48-live/full-batch-2-NEW/report.json
```

The equivalent [campaign queue](run-corpus.py) preserves the same three serial
calls and summary command in a fresh Phase48 raw directory. It does not add a
second supervisor around the runner's existing execution lock. The prior Phase47
campaign took 18m55s across these batches on the recorded host; that is a planning
reference, not a promised Phase48 duration or a reused timing denominator.

`candidate/typescript` is slowdown; `baseline/candidate` is improvement over the
fresh array06 execution. Report equal-point, equal-source and equal-family
geometric means separately, together with regressions. These weights summarize
this finite, optimization-informed corpus, not the variability of every Bend
program. Timed work includes export invocation, exact result validation and any
catalog observation adapter; import and first-call costs are recorded separately.

## Profiles, allocations and generated-code comparison

Investigate a completed run without repeating its clean timing:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog "$PHASE48_CATALOG" --from-run selfhost/build/phase48-live/core-NEW \
  --cases local-pair,complete-generic-row32 --budget 60 --mode all \
  --node "$PHASE48_NODE" --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase48-live/row-diagnostics-NEW
```

Keep `--catalog` explicit: the older runner's default catalog is different.
`--from-run` binds the exact copied modules and successful timing receipt; do not
combine it with `--baseline` or `--candidate`. For a direct, syntax-only comparison
of the frozen bundles:

```sh
python3 selfhost/tools/performance/programs/diagnose.py \
  --catalog "$PHASE48_CATALOG" --baseline "$PHASE48_BASELINE" \
  --candidate "$PHASE48_CANDIDATE" --cases local-pair,complete-generic-row32 \
  --budget 60 --mode static --node "$PHASE48_NODE" \
  --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase48-live/row-syntax-NEW
```

`static` parses but never imports the analyzed programs. `cpu` and `allocation`
collect the named profile plus static attribution; `all` collects both in separate
processes. To request diagnostics immediately after a successful timing screen:

```sh
run48 --budget 60 --cases local-pair,complete-generic-row32 \
  --diagnostics all --diagnostic-budget 300 \
  --out selfhost/build/phase48-live/row-with-diagnostics-NEW
```

Diagnostics have a separate budget and never replace clean timing ratios.
Their outputs include:

- `analysis/comparison.html`: side-by-side mapped Bend definitions and generated
  TypeScript/Bend JavaScript, including the candidate.
- `analysis/report.json` and `.md`: AST counts, module/function sizes, branches,
  calls, object/array construction sites, runtime helpers and pairwise differences.
- Normalized token files: comments/whitespace removed; no equivalence claim.
- `profiles/CASE/ROLE-cpu/profile.cpuprofile`: raw CPU samples and frame mappings.
- `profiles/CASE/ROLE-allocation/profile.heapprofile`: sampled allocation data.
- Exact module hashes, point configurations, profile observations, warnings and
  supervisor receipts in the report and per-profile directories.

Static sites are not dynamic call counts. CPU samples do not prove which
instruction caused a cost. Allocation estimates are neither exact allocations
nor retained memory; keep missing/unattributed samples and accounting warnings
visible. Counter derivatives prove activation only and cannot supply speed ratios.
See the [diagnostic guide](../programs/DIAGNOSTICS.md) for interpretation.

## Prepare a successor and qualify it

Acquire the required source set once from a separately checked compiler attempt:

```sh
python3 selfhost/tools/performance/programs/prepare.py \
  --catalog "$PHASE48_CATALOG" --attempt selfhost/build/checked-successor \
  --set core --node "$PHASE48_NODE" --cpu 3 --heap-mib 1024 \
  --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase48-live/successor-core-NEW
PHASE48_CANDIDATE=selfhost/build/phase48-live/successor-core-NEW/manifest.json
run48 --budget 60 --set core --out selfhost/build/phase48-live/successor-screen-NEW
```

Use `--set full` when several later selections will reuse the same compiler.
Preparation is separate from execution budgets and does not build the compiler.
Applicable source, host-mutation and activation controls remain necessary before
promotion; matching catalog outputs alone is insufficient. The
[Phase48 validation report](../../../../implementation/phase48/validation.md)
lists those separate scopes.

Compiler latency uses the independent
[request-cost method](../../../../implementation/phase48/compiler-cost-plan.md),
not this execution runner. See the
[current request-cost report](../../../../implementation/phase48/compiler-cost-final.md)
and [static accounting](../../../../implementation/phase48/accounting.md) for
cost and size tradeoffs. Publication follows the
[verified bundle/archive plan](../../../../implementation/phase48/publication-plan.md)
after timing and explicit writer closure. Never overwrite a consumed portable
bundle or historical raw evidence.

# Phase43 checked validation commands

Run from repository root. Root schedules every command serially, under the
campaign ledger/resource lock. Fresh paths only; keep all old tools and raw
Phase42 evidence immutable. These helpers create no compiler source changes.

## Checked attempt

```sh
PHASE43_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
PHASE43_ATTEMPT=$PWD/selfhost/build/phase43/checked01
PHASE43_OUT=$PWD/selfhost/build/phase43/integration01
PHASE43_RECIPE=$PWD/selfhost/build/phase43/recipe01.json
python3 selfhost/tools/performance/phase32/bounded-run.py --seconds 900 \
  --rss-mib 2048 --available-mib 2048 selfhost/build/phase43/run-checked01 -- \
  taskset -c 3 "$PHASE43_NODE" --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/development/workflow.mjs run \
  selfhost/tools/performance/phase43/validation/checked-config-v1.json \
  "$PHASE43_ATTEMPT"
python3 selfhost/tools/performance/phase43/validation/prepare-recipe-v1.py \
  --attempt "$PHASE43_ATTEMPT" --out "$PHASE43_OUT" --recipe "$PHASE43_RECIPE"
```

Config retains equality derivative, strictExact, default36 focused frontend,
one worker/CPU3/heap1024. Build supervisor cap900s is a resource limit. The
adaptor verifies maintained attempt integrity but executes no compiler/target.
It pins the repaired Phase42 recipe07 and fresh checked-image provenance. It
creates OUT only for the fresh facts configuration. Recipe lies outside OUT.

For final integration supply `--extension` with a reviewed JSON object containing
`reviewed:true`, `steps` and `requirements`. Step names start `phase43-` and use
concrete argv or `${ATTEMPT}`, `${OUT}`, `${API}`, `${API_SHA}`, `${ATTEMPT_SHA}`,
`${RUNTIME_SHA}` bindings. Requirements follow unchanged close-release-v6 schema:
name/report/execution/assertions/bindings and optional producer/derivation/relations.
Require `/complete:true`, `/pass:true`, exact semantic totals/refusals and explicit
selected API/attempt binding. New owners cannot duplicate the inherited16 names.
The extension adds controls before close-phase42; the old collector's kind is
historical lineage. Final postinstall refuses a recipe lacking fresh new owners.

`run-recipe-v1.py RECIPE --stage semantic --check-only --ledger LEDGER --jobs JOBS
--prefix CHECK` audits recipe/tool provenance without executing its stages. To run
all semantic stages, omit `--check-only`. Individual affected steps can be queued
through Phase41 recipe-run.py using the exact recipe step names and fresh outputs.
Use `derive-frontend,derive-current-integration` before consumers of derived tools.
Prototype controls need no broad frontend sweep. Record all remaining obligations.

The adaptor retains old output-specific assertions. A changed runtime/emission can
fail scalar outside-region assertions or shape-sensitive owners. Retain failures;
freeze a reviewed successor after inspecting the actual code. Automatic output
hash acceptance is unsupported. Parent materialization/same-image repair receipts
remain historical provenance, never candidate PASS receipts.

## Retained baseline

```sh
python3 selfhost/tools/performance/phase43/validation/freeze-baseline-v1.py \
  --current selfhost/tools/performance/phase42/current/manifest.json \
  --reference selfhost/tools/performance/phase42/baseline/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/tools/performance/phase43/baseline \
  --expected-api 63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54
```

Root queues this archive/hash work away from timing. It retains current checked16
and reference pinned TS portable acquisition triplets; no recursive raw copy.
Full module/source/catalog validation and archive reopening remain intact.

## Clean final timing after semantic survival

```sh
python3 selfhost/tools/performance/phase43/validation/run-recipe-v1.py \
  "$PHASE43_RECIPE" --stage cost-prepare --ledger "$LEDGER" --jobs "$JOBS" \
  --prefix final-cost-prepare
python3 selfhost/tools/performance/phase43/validation/check-measurement-bindings-v1.py \
  "$PHASE43_RECIPE" --cost --receipt "$PHASE43_OUT/measurement-bindings.json"
python3 selfhost/tools/performance/phase43/validation/prepare-runtime-batches-v1.py \
  "$PHASE43_RECIPE" --binding "$PHASE43_OUT/measurement-bindings.json" \
  --plan "$PHASE43_OUT/runtime-batches.json"
python3 selfhost/tools/performance/phase41/recipe-run.py \
  "$PHASE43_OUT/runtime-batches.json" runtime-batch1-plan,runtime-batch2-plan,runtime-batch3-plan \
  --ledger "$LEDGER" --jobs "$JOBS" --prefix final-runtime-plan
python3 selfhost/tools/performance/phase41/recipe-run.py \
  "$PHASE43_OUT/runtime-batches.json" runtime-batch1,runtime-batch2,runtime-batch3 \
  --ledger "$LEDGER" --jobs "$JOBS" --prefix final-runtime
python3 selfhost/tools/performance/phase43/validation/close-runtime-batches-v1.py \
  "$PHASE43_OUT/runtime-batches.json" "$PHASE43_OUT/runtime-full45-close.json"
```

All45 points retain preset600 and669 balanced fresh samples, Node24.18 identity,
selected attempt/module receipts and checked16 baseline. Run compiler-cost
requests separately from runtime timing; no profiling overlap. One frozen release
integration is appropriate. A full45 single600s run cannot finish:669 one-second
warmup floors alone exceed its deadline. Three15-point serial batches retain the
published sampling protocol; allow about15–20min for runtime. Reducing warmup or
rounds would require a new frozen statistical design and changed claims.

For a quick changed-family screen use programs/run.py `--budget20 --cases IDs`
with Phase43 baseline and a freshly prepared candidate. Candidate-bearing fixtures
must be re-emitted by the selected attempt. Changed String/Map/components need
independent TS and fallback/callback/error boundaries beyond pure numeric points.
Run broad qualification only after smallest falsifiers pass; the final mandatory
inherited gates remain pending until actually closed on the selected image.

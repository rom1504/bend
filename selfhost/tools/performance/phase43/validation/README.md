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

## Frozen scalar precedence successor

Queue a static proposal after an early actual raytrace emission:

```sh
"$PHASE43_NODE" selfhost/tools/performance/phase43/validation/scalar-precedence-v1.mjs \
  propose selfhost/build/phase42/integration03/scalar-ray.mjs \
  EARLY_CANDIDATE_RAYTRACE.mjs "$PHASE43_ATTEMPT/attempt.json" \
  selfhost/build/phase43/scalar-contract-proposal01.json
```

The proposal pins both roles' checked emission receipts, exact selected snapshot
runtime fingerprints, Node/Acorn and every outside changed section. It remains
`reviewed:false` and changed-section classifications remain PENDING. Independently
inspect those changes, freeze a successor contract with explicit classifications,
and obtain a separate review JSON with `complete:true`, `staticReviewPassed:true`,
`contractSha256`, `producerSha256`, `approvedChangedSections` and
`approvedProtectedEnvelopeEdits`. Both approval lists must exactly match the
contract/source observations, including empty lists. No unknown output hash is
learned during a PASS gate.

Pass `--scalar-contract FROZEN_CONTRACT --scalar-review REVIEW` to recipe
preparation. This replaces only inherited scalar precedence step/collector
supplement. Final check reads the **canonical fresh** OUT/scalar-ray.mjs and its
own receipt; early proposal output must match its module SHA but cannot substitute
for canonical final acquisition. Both selected-image paths are checked.

Runtime comparison removes only exact consumed snapshot prefixes, with every AST
statement entirely inside/outside that boundary. Program differences must match
frozen reviewed section hashes exactly. Five protected executable scalar bodies
remain byte-identical. The sole permitted metadata envelope change is an exact
third literalfalse argument to `scalarCapture(name,unchangedBody,false)`; it is
recorded by owner and unchanged body SHA, with independent approval. Original
Nat refusal, private scalar leaf helper, dependency guards, proof entry/restoration,
host entry and scalar-root refusal remain mandatory. The report is `checked:false`
for the non-executable comparison; normalized code is never imported or emitted.
Existing actual activation/mutation/Error owners remain separate mandatory gates.

The runtime sum collector also pins the exact Phase43 batch-planner and
measurement-binder producers and the repaired recipe07 ancestry SHA; a merely
matching kind string cannot replace producer/recipe lineage.

## Actual new-owner wrappers and extension builder

Use `owner-extension-template-v1.json` as a configuration outline. It is deliberately
unreviewed and contains placeholders. Select only implemented mechanisms; supply
all applicable source/refusal/fixture owners. `steps` contains the root's exact
`phase43-*` acquisition/derivation/controller argv commands, each with its own
existing supervisor. `owners` names fixed policies from `owner-catalogue-v1.json`.
For each row provide canonical rawReport/rawExecution/rawCommandInput paths,
actual selected emittedModules and derivation manifests. Guards emit their raw JSON
to supervisor stdout: use that exact stdout file as rawReport. Compiler-only type
and admission proof controls require no emittedModules; admission requires its
inputs.json in auxiliaryInputs to bind the untouched selected API. This is a
proof-refusal scope, with emission explicitly suppressed.

```sh
python3 selfhost/tools/performance/phase43/validation/build-extension-v1.py \
  --config FINAL_REVIEWED_OWNER_CONFIG.json --attempt "$PHASE43_ATTEMPT" \
  --campaign "$PHASE43_OUT" --contracts selfhost/build/phase43/owner-contracts01 \
  --extension selfhost/build/phase43/owner-extension01.json
python3 selfhost/tools/performance/phase43/validation/prepare-recipe-v1.py \
  --attempt "$PHASE43_ATTEMPT" --out "$PHASE43_OUT" --recipe "$PHASE43_RECIPE" \
  --extension selfhost/build/phase43/owner-extension01.json \
  --scalar-contract FINAL_SCALAR_CONTRACT.json --scalar-review FINAL_SCALAR_REVIEW.json
```

The builder runs no target/compiler and freezes policy/controller snapshots plus
selected attempt identity. Contract directory lies outside absent campaign OUT.
It appends bounded canonical wrappers after raw controller steps. Each wrapper
requires the exact controller tool in a successful bounded raw execution receipt,
canonical controller input, exact source-policy counts/statuses, selected actual
checked source emission receipts, and actual derivation linkage. Derivation
manifests must pin the reviewed actual instrumentation tool; module/file hashes
are rechecked. A manually patched favorable module cannot substitute for genuine
selected emission. Failures retain raw evidence and write incomplete failed wrapper
reports; no failed raw report can become PASS. The extension adds these groups to
all16 inherited owners, without changing their controls.

Frozen counts include source-v4 String439/113/3; renamed9/30/2 and negative9/24/2;
fast-v7 compiler proof59; actual callback22/32; noncommutative-v2 fixture85;
admission refusal11; BST7results and pair15results/exact10controls. Actual U32
oracle requires82 cases in order (27 fixed +40 frozen baseline numeric hooks +15
protocol hooks), exact equality and clean proof for every case. Products use their
actual `passed` status rather than inventing raw complete/pass fields; wrapper
completion follows those exact assertions and provenance. New controller variants
or changed source policy need an independently reviewed catalogue successor.

Runtime preflight now mirrors the exact retained build.mjs concatenation of
core/base/effects/readback/foreign plus its header/newlines. Recipe preparation and
every stage reject selected snapshot fragment/bundle divergence; postinstall
therefore checks before the installation launch. The check reads fragments and
compares bytes; it does not execute runtime code. Check current source explicitly
with `runtime-agreement-v1.py --attempt ATTEMPT --current-src selfhost/src --receipt
NEW_REPORT` when root freezes the final source.

When the selected source includes mixed quantity(1/2) native Sigma admission, add
`--native-proof-review selfhost/tools/performance/phase43/review/native-proof-controls-v1-review.json`
to recipe preparation. This selects the independently reviewed **57-control**
successor, preserving the original43 order except the explicit Sigma(2,1) admission
and adding four exact admissions/four self-equalities/six quantity-distinct
refusals. Exact source/review/witness hashes and quantityDomain are required;
inherited counter/vector equality remains unchanged. The validation-owned smaller
43-control draft is unused retained investigation material; execute only the
selected stronger57 successor. Final native ABI/alias/runtime controls remain
mandatory separately.

String actual-source policy now selects source-controls-v4 plus scope-aware
source-instrument-v5 (same439/113/3). Guard refusal is checked for the exact lexical
root whose dependency guard contains the mutated binding; independently safe nested
roots may activate. Complete outer activation, full values/events, intermediate
owned trace and absence of ambient proof leakage remain required. Superseded actual08
controller failure remains evidence. Final owner config/controller versions need
independent review before publication.

Final product profiles select the frozen actual-oracle-v2, pair-source-oracle-v3
and pair-ignored-oracle-v3 tools. Ordinary BST qualification requires `pairState`
and `scalarWrapper` true and positive build/insert/fin/down worker counts for each
nonzero-size row. Pair target qualification requires `precedenceControl:false`
and actual global pair worker activation; original stronger scalar fixtures use
separate precedence owners requiring `true`, global pair zero and scoped scalar
activation. They cannot satisfy positive pair owners. Ignored-field targets and
precedence controls likewise use separate exact flag profiles. All input modules
still require selected checked emission/source/API/runtime/driver provenance.

String source-v4 supersedes v3's false baseline witness requirement (same439/113/3,
instrumentv5). Candidate affected roots must refuse their own mutated dependency;
a baseline root has the same obligation when present. Full value/event equivalence
and complete outer activation remain unchanged. If callback integer-host guard
source is selected, use callbacks-environment-numeric-guard (actual-guard-controls-v2,
22oracles/39boundaries); the previously qualified32-boundary profile remains
historical and does not replace new guard-specific String/Float/public callback
controls. Independent final config/count/controller review remains required.

The concrete `final-owner-config-v1.json` now contains37 supervised acquisition,
derivation and raw-control steps for15 new owners. It selects callback guard22/39
without duplicating the old32 profile, retains independent callback85/admission11,
and includes both ordinary and renamed literal String fixture graphs. Every path
except the supported `${ATTEMPT}`, `${OUT}`, `${NODE}` bindings is concrete.
Fresh checked16 baseline emissions for the pair targetv2 sources are included;
preserved failed v1 acquisitions cannot replace them. Ignored-field pair-v3
reports actual per-row fresh-pair/scalar counts, checked independently by the
wrapper as positive activation or original scalar precedence.

This config remains `reviewed:false` pending independent final configuration
review. The assembler `create-final-owner-config-v1.py` executes no targets and
must not be used to overwrite a subsequently reviewed immutable config. Once
reviewed, root can freeze a versioned configuration with `reviewed:true`, then run:

```sh
python3 selfhost/tools/performance/phase43/validation/build-extension-v1.py \
  --config FINAL_REVIEWED_CONFIG.json --attempt FINAL_ATTEMPT \
  --campaign selfhost/build/phase43/integration01 \
  --contracts selfhost/build/phase43/owner-contracts01 \
  --extension selfhost/build/phase43/owner-extension01.json
```

No owner is qualified by this static configuration. Map's actual-source gate must
be added through a reviewed successor when its frozen source controller is ready;
all inherited16 owners remain mandatory on the final selected image.

`final-owner-config-v2.json` is the pending successor after ordinary activation
failures in the independent plain pair target fixtures. It retains those failures
and uses the independently checked prefix BST fixture's actual `bst.down$tree`
pair path, with `--fixture --scalar-wrapper --pair-state`. Its report must have
fixture/scalarWrapper/pairState true and7 rows. Every ordinary row, including zero,
must execute the prefix build worker; every nonzero row must execute prefix insert,
insert.fin and bst.down. Existing ordinary BST qualification remains separate.
Original pair and ignored-field fixtures remain scalar precedence controls.
Use the matching v2 catalogue/wrapper/extension builder; v1 review inputs survive
unchanged. Map and an independent ignored-field BST derivative are still pending
actual-source controllers. The v2 config remains reviewed false.

The v2 successor now contains34steps14owners, including the frozen independent
ignored-field BST derivative. `products-bst-pair-ignored` binds exact controller
SHA, pairState/worker/marker,7 ordinary rows and all6 alias/freshness/conditional
retention/deep12000 private control records. Its wrapper requires actual build
activation on every row and actual insert/fin/down activation for every nonzero
row. Both source roles are freshly emitted against their explicit checked attempt,
with the baseline fixed to checked16. Original ignored-field scalar precedence
remains a separate owner. Map remains pending; no static config counts as a runtime
qualification.

The pending v3 configuration retains34steps14owners while replacing materialized
callback routes with actual-source fusion controls22/39 and independent fusion
fixture85. Admission11 remains unchanged, including malformed Type0/2 refusals.
The matching v3 catalogue pins both controller hashes; its wrapper additionally
requires the exact authentic actual-source-fusion derivation kind, complete and
certified. Fresh checked source modules precede this derivation. Historical saved
fusion performance and prior guard graph controls do not qualify the selected
source image. Use `build-extension-v3.py` with the eventually frozen reviewed
configuration; older v1/v2 inputs and review receipts remain intact. Independent
v3 static review is recorded, but final image/Map/fresh closures/cost are pending.

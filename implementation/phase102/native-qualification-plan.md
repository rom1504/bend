# Phase102 bounded native-chain qualification

This is a coordinator execution plan, prepared offline. It accepts the eventual
final source and recipe; no candidate hash is built into the method. All compiler,
Clang and generated-program executions remain serial and guarded. A successful
checked JS API or application screen does not qualify a native compiler image.

## Budget and ordering

Use a 45-minute qualification budget after freezing the final candidate. The
historical successful Phase98 raw process receipts give these planning anchors:

| Work | Historical target time | Reserve |
| --- | ---: | ---: |
| Upstream C acquisition plus native B1 build | about 4 min | 8 min |
| Independent current B2 reference plus candidate B1 self emission | about 4 min | 10 min |
| Native B2 build and exact self fixed point | about 7 min | 12 min |
| Live/cache/rejections, original broad45 and native69 for both images | 22 + 121 + 150 s | 6 min |
| Original five final-image controls | 12 s | 1 min |
| 45 runtime-batch continuity plus changed-product acquisition/timing | continuity 48 s; changes vary | 5 min |
| Final native source screen and evidence collection | historical six-source screen 37 s | 3 min |

Reserve values are stop/review budgets, not relaxed per-command guards or a
promise that every step fits. The retained failed `origin-conformance01` hit its
300 s limit; the successful successor took 150 s for both images plus diagnostics.
Inspect each failure instead of converting a budget miss into a pass.

Run the first useful native B1 requests immediately after B1 exists. Defer repeated
full-self timing: the old B2 self-pair campaign alone cost 589 s. One independent
reference, one B1 self emission, and one B2 exact reproduction establish the
needed chain consistency without those repeated performance samples. Both native
stages still need small matched timing before a compilation-speed claim.

## Freeze the exact source and changed-backend policy

Set these task-specific shell variables to concrete paths. Every result directory
must be fresh. `P102_B1_ROOT` is the completed Phase102 `acquire-native.py` directory,
which already contains the checked upstream receipt, native ELF and B1 binding.

```sh
P102_SOURCE=/absolute/path/to/final/compiler.bend
P102_RECIPE=/absolute/path/to/final/changes.json
P102_B1_ROOT=/absolute/path/to/selfhost/build/phase102/native-b1-01
P102_OUT=/absolute/path/to/selfhost/build/phase102/native-chain01
P102_Q=selfhost/tools/performance/phase99/qualification/reuse.py
P102_X=selfhost/tools/performance/phase102/qualification-method.py

python3 -B selfhost/tools/performance/phase99/qualification/prepare.py \
  --source "$P102_SOURCE" --recipe "$P102_RECIPE" \
  --acquisition "$P102_B1_ROOT/checked/report.json" \
  --reason 'Phase102 bounded branch/TRMC lowering, owning-observer NF composition, local NF calls and measured inline policy' \
  --out selfhost/build/phase99/phase102-final-plan01

P102_POLICY=selfhost/build/phase99/phase102-final-plan01/policy/policy.json
P102_NORMALIZED_RECIPE=selfhost/build/phase99/phase102-final-plan01/recipe.json
```

This preparation launches no target. It replays and reverses every edit and
authenticates unchanged request entry definitions. Its generated command list is
reference material; do not run its redundant B1 build or its repeated self-pair
timings. Commands below reuse the already acquired B1.

The baseline must be `phase99/qualification/baseline.json`: installed Phase98
source `2a72bbdc…`, B1 `099df960…`, B2 `c481bd2c…`. The wrapper loads the old
Phase92 context only to authenticate unchanged toolchain/request assets, then
replaces both producer roles with these exact Phase98 images. Calling the old
Phase98 B2 comparison directly can silently select native07; do not use it for
this comparison.

## Genuine B1 to B2, exact diagnostics and fixed point

```sh
python3 -B "$P102_Q" request --baseline b2 --source "$P102_SOURCE" \
  --purpose reference --out "$P102_OUT/reference"

python3 -B "$P102_Q" request --stage b1 \
  --binary "$P102_B1_ROOT/compiler" --compiler-source "$P102_SOURCE" \
  --build-receipt "$P102_B1_ROOT/b1.json" --source "$P102_SOURCE" \
  --purpose changed-backend --backend-policy "$P102_POLICY" \
  --oracle-report "$P102_OUT/reference/report.json" --out "$P102_OUT/b1-self"

python3 -B "$P102_Q" build \
  --emission-receipt "$P102_OUT/b1-self/report.json" \
  --binary "$P102_OUT/b2/compiler" --out "$P102_OUT/b2-build" \
  --seconds 420 --rss-mib 6144

python3 -B "$P102_Q" bind --stage b2 --binary "$P102_OUT/b2/compiler" \
  --source "$P102_SOURCE" --emission-receipt "$P102_OUT/b1-self/report.json" \
  --build-guard "$P102_OUT/b2-build" --out "$P102_OUT/b2.json"

python3 -B "$P102_Q" request --stage b2 \
  --binary "$P102_OUT/b2/compiler" --compiler-source "$P102_SOURCE" \
  --build-receipt "$P102_OUT/b2.json" --source "$P102_SOURCE" \
  --purpose compare --backend-policy "$P102_POLICY" \
  --oracle-report "$P102_OUT/b1-self/report.json" --out "$P102_OUT/b2-self"
```

The independent reference compiles the **final candidate source**, not its own
older source. B1's changed-backend purpose may differ in C only: the complete
diagnostic must equal that reference, including unsafe/foreign dependency counts.
B2 must reproduce every byte of B1's C and the same full diagnostic. All source,
request assets, output, binary, build flags and raw command receipts remain pinned.
This is a real upstream-TypeScript→C B1→own-C B2 chain. The fixed point proves
reproducibility of this product, not universal compiler correctness.

Ordinary requests retain the frozen 2 GiB RSS bound. If an actual candidate
**exact self-source** request exceeds it, retain that failure; the unchanged
`qualification-method.py request-v2 ... --rss-mib 4096` supports a fresh retry
with a 16 GiB available-memory floor. It does not authorize 4 GiB for the baseline
compiling a different candidate source, other requests, Clang or global guards.

## Unchanged semantic oracles

```sh
python3 -B "$P102_Q" backend-gates \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --backend-policy "$P102_POLICY" --suite controls --out "$P102_OUT/controls"

python3 -B "$P102_Q" backend-gates \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --backend-policy "$P102_POLICY" --suite broad45 --out "$P102_OUT/broad45"

python3 -B "$P102_Q" conformance \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --backend-policy "$P102_POLICY" --out "$P102_OUT/conformance"
```

The controls gate runs four original sources live/cached through both stages,
requiring full C cross-stage/cache agreement and exact historical diagnostics,
then three exact historical rejections per stage with no emitted C. Broad45
emits all 45 original sources through both stages, requires whole-C agreement,
builds each common unpatched C once at matched O2, and checks every stdout/stderr
byte. Historical C differences are recorded as differences, not waived failures.

Conformance preparation is data-only. Run the generated `commands.json` serially
through its integrity wrapper, then collect via that same wrapper:

```sh
P102_INTEGRITY=selfhost/build/phase98/qualification-methods17/methods/conformance_integrity.py
python3 -B "$P102_INTEGRITY" run --plan "$P102_OUT/conformance/plan.json" --role b1
python3 -B "$P102_INTEGRITY" run --plan "$P102_OUT/conformance/plan.json" --role b2
python3 -B "$P102_INTEGRITY" run --plan "$P102_OUT/conformance/plan.json" --role diagnostics
python3 -B "$P102_INTEGRITY" collect --plan "$P102_OUT/conformance/plan.json" \
  --out "$P102_OUT/conformance/collected.json"
```

The unchanged selection is **69 eligible native fixtures plus three rejections
per image, with 31 explicit exclusions**. Neither broad45 nor a fixed point
replaces these independently expected program results.

## Preserve old authority checks and test the new boundaries

The original final-image controls are five sources: real IO, generic array,
schema refusals, all 1,444 String corpus pairs/14 fields, and origin-swap refusal.
They require an exact final-source/backend-policy-specific evidence bridge:

```sh
P102_BACKEND_CONTROLS=/absolute/path/to/completed/phase102-backend-specific/report.json
python3 -B "$P102_X" final-controls \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --backend-policy "$P102_POLICY" --backend-controls "$P102_BACKEND_CONTROLS" \
  --out "$P102_OUT/final-controls"
```

That bridge is an outstanding data-consumer obligation, not a report to fabricate
before evidence exists. The old Phase98 origin collector accepts only its exact
one-function correction and cannot certify this change. A Phase102 successor
must replay the final recipe, check unchanged inherited authority/proof
declarations explicitly, and bind the actual final-source new controls:
ordered/aliased/dropped local calls; partial/dynamic/bang refusals; owning observer
empty/prefix/Unicode/long/shared results; generic TRMC constructors and fallback
refusals; and bounded branch behavior. Required cases must be frozen before
execution. Old raw/provider refusal evidence can be inherited only with exact
source-closure correspondence, not by replacing its source hash.

For final-image inheritance, emit each distinct new control source through B1
and B2, require exact C/diagnostics, build that common C once and run all payloads
against their frozen complete oracles. Reuse identical payload builds and existing
same-final-C executions; never infer runtime semantics from C syntax alone.
The complete old five-source gate still runs: these controls cover different
ownership boundaries from the new mechanism fixtures.

`native-inherit-v2.py` implements that narrow bridge, with optional app reports
and multiple complete control reports:

```sh
python3 -B selfhost/tools/performance/phase102/native-inherit-v2.py \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --backend-policy "$P102_POLICY" --controls FINAL_CHECK_EMITTED_REPORT ADDITIONAL_BRANCH_REPORT \
  --apps FINAL_APP_REPORT MORE_FINAL_FIXTURES_REPORT \
  --out "$P102_OUT/inheritance"
```

It authenticates the original Phase98 diagnostic request's actual command and
captures, each retained O3 build, and every prior candidate output byte against
its frozen oracle before running new emissions. Identical native C inherits that
exact binary and behavior; changed C gets one build and all original executions.
Inherited timing remains inherited, never labeled a fresh measurement. The
runner uses the versioned long-argument guard, preserving full runtime argv.
Its `--check-only` mode executes no targets. The offline evidence preflight on
`reuse-controls03` checked 11 sources and 48 candidate outputs successfully;
it used installed-image bindings for method validation and makes no final
candidate-inheritance claim.

## Compiled-program speed continuity, separately from broad45

The 45 Phase93 **batched timing sources** differ from the 45 plain broad semantic
sources above. Keep both sets and their flags/oracles distinct. The installed
Phase98 batch-continuity receipt proves its 45 products equal their historical
counterparts, which permits authenticated product reuse.

```sh
python3 -B "$P102_X" batch-continuity emit \
  --plan selfhost/build/phase98/batch-continuity-plan01/plan.json \
  --b2-build "$P102_OUT/b2.json" --backend-policy "$P102_POLICY" \
  --out "$P102_OUT/runtime-continuity"

python3 -B selfhost/tools/performance/phase99/runtime/run.py acquire \
  --changed-plan "$P102_OUT/runtime-continuity/changed-plan.json" \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --out selfhost/build/phase99/phase102-runtime-products01

python3 -B selfhost/tools/performance/phase99/runtime/run.py measure \
  --products selfhost/build/phase99/phase102-runtime-products01/phase98-products.json \
  --out selfhost/build/phase99/phase102-runtime-vs-phase9801

python3 -B selfhost/tools/performance/phase99/runtime/run.py measure \
  --products selfhost/build/phase99/phase102-runtime-products01/upstream-products.json \
  --out selfhost/build/phase99/phase102-runtime-vs-upstream01
```

That plan is the exact `plan.file` authenticated by the retained
`origin-batch-continuity01/report.json`.
The acquisition checks B1 C only for changed products, builds their common exact
C with the original C11/O3 recipe, and retains prior upstream binaries. Unchanged
C reuses its old runtime evidence. Measurement uses three balanced rounds and
the unchanged calibration; intervals below 100 ms require a fresh calibration,
not acceptance of short samples. With no changed measurable cases, skip measure.
Keep `scalar-region-0` as an exact-output zero-work control with undefined ratio.
If every C file changes only because of global inline/header policy, all changed
products still need this evidence; textual similarity is insufficient for reuse.

## Timing and final evidence collection

Use the unchanged six-source `reuse.py compare --stage b1|b2` screen once per
stage, with explicit build/policy arguments and a fresh Phase99 output path.
It supplies four balanced rounds and full product/diagnostic checks. Do not
confuse its request time with executable runtime, Clang image build time or
process startup/preparation. Defer the expensive `--mode self` timing campaign
until it would resolve a real compiler-speed decision.

If all required gates and the backend bridge pass, the existing collector remains
the final independent check:

```sh
python3 -B "$P102_X" admit \
  --b1-build "$P102_B1_ROOT/b1.json" --b2-build "$P102_OUT/b2.json" \
  --b1-self "$P102_OUT/b1-self/report.json" --b2-self "$P102_OUT/b2-self/report.json" \
  --source-recipe "$P102_NORMALIZED_RECIPE" \
  --controls "$P102_OUT/controls/report.json" --broad45 "$P102_OUT/broad45/report.json" \
  --conformance "$P102_OUT/conformance/collected.json" \
  --backend-policy "$P102_POLICY" --backend-controls "$P102_BACKEND_CONTROLS" \
  --final-controls "$P102_OUT/final-controls/report.json" \
  --out "$P102_OUT/admission.json"
```

The collector rechecks raw commands, full diagnostics, exact self C, actual
golden fields, source replay and evidence pins. It creates a nondefault admission;
it does not update the public selection. Runtime speed evidence is separately
required before claiming no compiled-program regression.

## Useful deliverable if the full chain does not earn promotion

Keep the installed Phase98 selection. Publish the exact final standalone source,
recipe, native ELF/build binding, app controls/results and a runnable explicit
private command using the authenticated request assets. Label each image by its
actual producer: upstream-built B1; candidate-B1-built B2; or JS-emitted discovery.
List completed and missing gates precisely. A B2 with fixed point and partial
controls is usable for experiments but remains **unqualified**. Do not substitute
the successful app evidence, guessed diagnostics or a copied parent admission
for remaining compiler-chain checks. Retain failures and the resumable command
plan so the next iteration starts from useful evidence rather than rebuilding.

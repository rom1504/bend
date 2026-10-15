# Phase98 private native qualification

These methods accept explicit candidate source/image/build receipts. They do not
edit the Phase90 public launcher, its admission manifest, or the historical D04
source. Source/emitter/build authentication is separate from semantic gates.
Only the root runs target commands, serially under the existing resource guard.

First run data-only `freeze.py --out selfhost/build/phase98/qualification-methods01`
from the repository root (using this script's full path), then execute all methods
from `qualification-methods01/methods/`. That immutable snapshot keeps evidence
valid if the development tools change later. Each run additionally snapshots its
method inputs. Never replace an existing snapshot or result path.

`bind.py` records a B1 built from the checked upstream acquisition or a B2 built
from the candidate B1's independently compared self-emission. The guarded Clang
input must be the exact unpatched emitted C and use matched `-O2` flags. New
source hashes are allowed. The existing `p86_*` transport definitions must remain
byte-identical so the authenticated Base/runtime/nine-provider/cache tuple and
the B1/B2 argv conventions can be reused privately.

The basic sequence (replace uppercase placeholders with concrete paths) is:

```
python3 bind.py --stage b1 --binary B1 --source SOURCE \
  --emission-receipt ACQUIRE/report.json --build-guard BUILD_GUARD --out B1.json
python3 gates.py --stage b1 --binary B1 --source SOURCE \
  --build-receipt B1.json --suite controls --out CONTROLS_B1
python3 request.py --baseline b2 --source SOURCE --purpose reference --out REF
python3 request.py --stage b1 --binary B1 --compiler-source SOURCE \
  --build-receipt B1.json --source SOURCE --purpose compare \
  --oracle-report REF/report.json --out SELF_B1
python3 build.py --emission-receipt SELF_B1/report.json --binary B2 --out BUILD_B2
python3 bind.py --stage b2 --binary B2 --source SOURCE \
  --emission-receipt SELF_B1/report.json --build-guard BUILD_B2 --out B2.json
python3 request.py --stage b2 --binary B2 --compiler-source SOURCE \
  --build-receipt B2.json --source SOURCE --purpose compare \
  --oracle-report REF/report.json --out SELF_B2
python3 gates.py --stage b2 --binary B2 --source SOURCE \
  --build-receipt B2.json --suite controls --out CONTROLS_B2
```

Run from this directory or use full script paths. Every output is fresh. The
reference is the actual admitted baseline native B2 compiling the **candidate**
source with identical request assets; D04 self-C is not used as the oracle for a
changed source. Exact candidate B1 and B2 self-C against this independent product
establishes backend fixed-point evidence, not ELF identity or a universal proof.
The `reference` purpose is explicitly not a semantic qualification claim.
Self sources legitimately report `SOME PROOFS FAIL` for their unsafe/foreign
dependencies. Reference creation accepts only that complete counted protocol or
the exact all-safe diagnostic, freezes every diagnostic byte, and records the
unsafe count. Candidate B1/B2 comparisons require exact equality with the
independent reference diagnostic and C, never an assumed all-safe result.

`gates.py --suite controls` runs four original sources live and cached, requiring
full C hash/size equality and exact diagnostics, followed by three historical
rejections with exact diagnostics and no C. `--suite broad45` compiles the exact
45 Phase92 catalog sources once each against their retained full-C identities.
Archived oracle files need not be materialized: their complete hash/size is bound
by the immutable successful historical receipt. No generated programs run in
these exact-output gates. Source-level compiler changes with unchanged generated
C can reuse the historical product behavior evidence; changed C fails this gate.

`conformance.py --b1-build B1.json --b2-build B2.json --out CONFORMANCE` is data-only.
It creates a plan and three root-only commands reusing the unchanged Phase92
adapter, golden judge, 69 eligible fixtures, 31 explicit exclusions and three
rejections per image. The plan keeps that adapter's historical schema name for
compatibility and explicitly records Phase98 candidate producers. Execute the
three commands in order, then use the unchanged Phase92 `conformance/collect.py`
with the new plan to check all observed golden outputs. No native100/100 or full
frontend/JS/GPU claim follows. The separate Phase98 six-source compiler screen
continues to own balanced timing comparisons.

Full Clang defaults to a420s deadline,6GiB RSS cap,16GiB available-memory
floor and CPU2,3. A larger allowance requires separate reviewed evidence after
an actual bounded failure; this method does not grant it. Ordinary
requests use 2GiB RSS, 4GiB available-memory floor, CPU3 and a 64MiB file cap.
This directory has been prepared offline; no target validation is implied until
the parent runner records successful observations.

Version note: immutable `qualification-methods01` retained the older10GiB build
default. Use `qualification-methods02/methods/build.py` (or an explicit6GiB guard)
for builds; snapshot01's existing binding evidence remains untouched. Historical
exact-C gates apply to source changes that preserve generated C. An intentional
emitter/permission change requires separately frozen independent output oracles
and actual generated-program execution; a failed historical-C comparison is never
relabeled as a pass.

## Explicit changed-backend qualification (snapshot04)

`backend-policy.py` is data-only. It requires an exact source recipe with
`source`, `candidate`, and offset-bearing `changes` containing `old`/`new` text;
it replays those edits in recorded order (offsets refer to each intermediate
source) and pins the existing45 full-output expectations
before target execution. Source, recipe and a concrete change reason are required.
It binds unchanged transport and historical semantic origins and does not admit
an image or excuse changed diagnostics.

```
python3 backend-policy.py --source SOURCE --recipe RECIPE --reason REASON --out POLICY
python3 request.py --baseline b2 --source SOURCE --purpose reference --out REF
python3 request.py --stage b1 --binary B1 --compiler-source SOURCE \
  --build-receipt B1.json --source SOURCE --purpose changed-backend \
  --backend-policy POLICY/policy.json --oracle-report REF/report.json --out SELF_B1
python3 build.py --emission-receipt SELF_B1/report.json --binary B2 --out BUILD_B2
python3 bind.py --stage b2 --binary B2 --source SOURCE \
  --emission-receipt SELF_B1/report.json --build-guard BUILD_B2 --out B2.json
python3 request.py --stage b2 --binary B2 --compiler-source SOURCE \
  --build-receipt B2.json --source SOURCE --purpose compare \
  --backend-policy POLICY/policy.json --oracle-report SELF_B1/report.json --out SELF_B2
python3 backend-gates.py --b1-build B1.json --b2-build B2.json \
  --backend-policy POLICY/policy.json --suite controls --out CONTROLS
python3 backend-gates.py --b1-build B1.json --b2-build B2.json \
  --backend-policy POLICY/policy.json --suite broad45 --out BROAD45
python3 conformance.py --b1-build B1.json --b2-build B2.json \
  --backend-policy POLICY/policy.json --out CONFORMANCE
```

Only a candidate B1 compiling its own exact source may use `changed-backend`.
It requires an independent maintained B2 reference for that same source and
exact complete diagnostic equality, while recording whether C differs. The new
B2 then must reproduce candidate B1's entire self C and diagnostic. A self fixed
point can share a backend defect: it is consistency evidence, not an independent
semantic oracle. The baseline self reference checks source admission/diagnostics;
the golden native69 and frozen broad45 outputs provide independent semantic checks.

The controls gate checks four live/cache sources across both images (16 exact
diagnostic requests, cross-stage and cache C agreement), then three unchanged
rejections per image. The broad gate compiles each unchanged original source
through both images, requires their entire C to agree, builds that common exact C
with the matched historical Clang O2 recipe, and executes it with the historical
thread/GPU arguments. Stdout includes its final newline and must match byte for
byte; stderr must be empty. All45 catalog workload arguments remain embedded in
the unchanged Phase88 sources. Historical C identities are recorded as same or
changed, not used as a waived acceptance requirement.90 emissions,45 Clang builds
and45 runtime checks are serial and retain raw records. These runtime clocks are
correctness telemetry; generated-program speed requires separate matched timing.

The unchanged native69 adapter already builds and runs actual candidate products;
its golden judge remains unchanged, with31 explicit exclusions. Execute its
generated commands and collect separately. No single successful request or gate
marks the image qualified; combine self, controls, broad45 and native69 evidence
and any backend-specific permission/refusal controls before a promotion decision.

Snapshot03 and `observer-backend-policy01` preserve an offline preparation failure:
the first policy replay treated recorded offsets as positions in the original
source. The producer records positions sequentially. Snapshot04 corrects that
replay interpretation; no target or expectation changed.

## Offline admission collection (snapshot06)

`admit.py` collects actual completed reports and writes one fresh admission file;
it runs no compiler and selects no default. Use two controls and two broad45
reports for ordinary exact-C qualification, or one combined report per suite
with the explicit backend policy for changed-C qualification:

```
python3 admit.py --b1-build B1.json --b2-build B2.json \
  --b1-self SELF_B1/report.json --b2-self SELF_B2/report.json \
  --source-recipe RECIPE --controls CONTROLS_B1/report.json CONTROLS_B2/report.json \
  --broad45 BROAD_B1/report.json BROAD_B2/report.json \
  --conformance CONFORMANCE/collected.json --out RELEASE/admission.json
```

For changed C, pass one combined controls report and one combined broad report,
plus `--backend-policy POLICY/policy.json --backend-controls BACKEND_CONTROLS`.
The latter is a completed `phase98-backend-specific-qualification` report with
`source`, `backendPolicy`, a pinned frozen `plan` containing `cases`, exactly
those `requiredCaseIds`, and passed `rows` carrying nonempty evidence-pin lists.
It also has `complete`, `passed`, `inputsUnchanged`, method and input pins. The
root creates that report from the actual permission/refusal/alias controls;
common45/native69 tests do not silently replace backend-specific obligations.

The collector replays and reverses the exact source recipe, authenticates both
builds, verifies guarded raw self/gate captures, checks exact cross-stage C and
diagnostics, and re-evaluates native69 observed fields against the unchanged
historical oracle. All31 exclusions remain. The seal contains selected assets
separately from the full evidence input closure so public requests need only
verify their source, selected image and request assets. `profileAssets` contains
the source derivation's pinned inputs for reproducible packaging. `qualified`
does not imply a default selection, public CLI control passes or a universal
compiler proof. Those remain separate release steps.

Snapshot05 also allows repeated identical old text in a source recipe when the
recorded sequential offset identifies the exact edit. The complete forward and
inverse source checks remain mandatory. This supports composed tag rewrites
without assuming each textual call is unique.

Snapshot06 strengthens the final collector's raw-command checks: request and
conformance records must name the selected binary and exact request assets.
Snapshot05 remains preserved; no target or accepted gate was changed.

Snapshot07 adds the actual native B2 paired screen and optional same-input self
comparison documented in [b2-comparison.md](b2-comparison.md). It also checks
explicit sequential offset bounds in source replay, accepting repeated call text
and end-of-source insertions. `support.backend_policy` verifies only the frozen
source and input pins; it contains no textual-uniqueness assumption.

Snapshot08 adds `backend-specific.py`, a data-only consumer of the independently
prepared declaration bridge and actual small/corpus execution records:

```
python3 -B selfhost/build/phase98/qualification-methods08/methods/backend-specific.py \
  --bridge selfhost/build/phase98/permission-declaration-bridge02/report.json \
  --backend-policy selfhost/build/phase98/combined-backend-policy02/policy.json \
  --documents selfhost/build/phase98/audited-documents01/receipt.json \
  --out selfhost/build/phase98/combined-backend-specific01
```

It verifies16 exact final permission declarations and five classified shared
dependencies, final7permission/6tag kernel laws and their exact source closure,
18 frozen Boolean cases, three emitted-control shapes, provider/raw refusals,
seven tiny program executions and three corpus executions. The1444-pair corpus
retains all14 observed fields and complete character arrays. Raw guard receipts
and actual full stdout/stderr are reread. Existing expectations remain unchanged.
Its29 evidence rows enumerate only these actual obligations, not every group in
the broader exploratory plan. Qualified-source execution, final composition
bridge and final-source laws remain separate receipt fields. `imageQualified`
stays false until the final same-source image gates pass and admit.py collects
them. No additional target is required merely to build this receipt.

Audited NATIVE_HOST/OBSERVERS documentation bytes are separately snapshotted with
original paths/pins/modes for isolated evidence replay. Perform admission before
updating those audited live documentation paths. The public request capsule
contains selected source/images/runtime assets and source replay inputs; it does
not need the full historical qualification input closure on every request.

Snapshot09 adds `request-v2.py --rss-mib 2048|4096`. Default behavior remains2GiB
RSS/4GiB available. The explicit4GiB option requires the input source pin equal
the authenticated compiler's own source and a16GiB available-memory floor; it
does not change ordinary request, build or global guard limits. This follows the
retained combined-b1-self01 tree-RSS stop. All diagnostic, output and provenance
checks remain unchanged. Snapshot09 also fixes a data-only backend-specific
preflight comparison: proof manifests retain one extra blank declaration
separator, so both exact strings are now parsed by the same frozen declaration
parser after verifying the complete manifest span occurs once in final source.
The failed combined-backend-specific01 preparation and snapshot08 remain intact.

Snapshot10 corrects the next data-only consumer assertion: the normal JS driver
deliberately reports permission=false for real-io because it uses print_err.
The original experiment separately authenticates every provider before granting
its checked API permission. The consumer now requires that exact false/true/true
driver-permission vector, authenticated authority and all original raw/false
entry controls. `combined-backend-specific03/report.json` passes29 evidence
rows; preparations01/02 remain failed evidence. No original target expectation
or execution changed.

`final-controls.py --b1-build B1.json --b2-build B2.json --backend-policy POLICY
--backend-controls BACKEND_REPORT --out FRESH` binds those original plans and
executes their four distinct Bend sources through the final images. The original
seven small executions contain three unique Bend programs and one raw forged
KTerm case; the three Bend sources plus the full1444-pair corpus are selected.
The raw API experiment remains separate. Four independent baseline B2 emissions
capture full diagnostics, including unsafe definitions. Eight final emissions
must match those diagnostics and agree on entire C. Each common C is built once
with matched O2 flags and run against every byte of the original stdout/stderr.
Permission/scalar flags are checked too. This is four full-output executions,
not a timing benchmark or a replacement for negative/provider controls.

The successor admission collector requires `--final-controls FRESH/report.json`
for changed backends. It independently rereads the original source/expectation
plans, raw commands, diagnostics, all emitted C, build/run captures, flags and
full outputs; its seal includes `receipts.finalImageControls`. Ordinary
source-preserving admission is unchanged.

`batch-continuity.py prepare --out FRESH` launches no target. It freezes all45
original Phase93 batch sources, complete native C/product pins, full expected
values, original workload arguments and44 retained calibration plans. Then the
root may run `batch-continuity.py emit --plan FRESH/plan.json --b2-build B2.json
--backend-policy POLICY --out EMISSIONS`. This emits each source once through
the authenticated final B2 and requires the exact original diagnostic. It records
whole-C equality without rebuilding historical executables. `passed` means all
45 emissions and diagnostics succeeded; `allHistoricalCExact` and the separate
changed/unchanged lists state whether runtime-product continuity holds.

The resulting `changed-plan.json` contains only changed products and their
unchanged calibration/oracle inputs. Those need B1 cross-check emission, one
matched C11/O3 build each, and the unchanged Phase93 runtime methodology before
new generated-program speed claims. Existing upstream executables can be reused.
Exact-C cases need neither rebuild nor fresh timing to preserve the previous
product comparison evidence; this is artifact continuity, not a fresh benchmark.
The zero-work scalar-region-0 point remains explicit and has no runtime ratio.

The cost-source successor uses `cost-backend-specific.py --parent-controls
combined-backend-specific03/report.json --bridge permission-cost-declaration-bridge01/report.json
--backend-policy cost-backend-policy01/policy.json --out FRESH`. This is data-only.
It independently replays both D04 and parent59 recipes into a025, requires exactly
two changed existing declarations and nine added cache helpers, preserves the16
permission declarations and prior safe proof closures, and binds the accepted
three-law redirect proof to its byte-identical final extraction. It rereads all
105 complete worker lists and60 complete schemas, including untouched metadata,
duplicates and NC_Text subtrees. Three actual cost-control C files must also
equal the exact previously executed qualify05 products byte for byte.

The resulting199 rows explicitly distinguish29 parent evidence rows from the
new source bridge, redirect proof and168 finite comparisons. Cached unsafe
planning correspondence remains source-audited and finitely tested; no universal
cached-schema or native-lifetime proof is claimed. Failed cost-controls01 values
are preserved; only its successful exact-source API build artifacts are reused.
The new report still has `imageQualified=false`. Existing final-controls.py and
admit.py authenticate source/policy/build pins dynamically and accept this a025
receipt without a source-hash exception or relaxed final-image gate.

Snapshot14 qualifies the minimal origin-ancestry termination correction, separately
from the unpromoted planning-cost candidate. `origin-backend-specific.py` takes
`--parent-controls`, `--bridge`, `--origin-controls`, `--backend-policy`, and
`--out`. It rereads the actual completed origin controls, exact one-function
source recipe, sixteen unchanged permission declarations, eleven complete origin
decisions, three exact previously executed C products, bounded parent failure,
and the actual owning-swap program output. Its46 evidence rows retain29 parent
rows with explicit inherited scope. Old/new universal equivalence is not claimed.

The resulting report pins three explicit original-plan selections for five
final-image programs: real IO, generic array, schema refusals, full string corpus,
and owning origin swap. Snapshot14 `final-controls.py` and `admit.py` consume
those exact selections, retaining original source and stdout/stderr expectations.
They require15 emissions (five independent references plus five per candidate
stage), five cross-stage whole-C equalities, and five actual full-output native
executions. The swapping function must remain declined by observer analysis.
No candidate source hash is special-cased in these final-image gates.

Snapshot14 also corrects active-flag reading: the six contiguous initial emitter
definitions establish the flags. Later `#ifndef NATIVE_SCALAR_ARRAYS` runtime
defaults do not override an already defined value. Earlier methods remain frozen;
the scalar expectations and generated code are unchanged.

Snapshot15 corrects the control diagnostic oracle. The independently retained
Phase90 file-IO controls report thirteen unsafe/foreign definitions while
successfully emitting C. `historical_diagnostics.py` binds their original guard,
stdout and stderr pins, checks the raw process and complete counted protocol,
then strips only transport clock lines. Both gate variants and admission compare
every remaining byte with that original text. The other six control diagnostics
and all90 historical broad45 observations retain the all-safe text. No diagnostic
check is waived. Public CLI controls already compare the accepted control's full
diagnostic, so their method needs no change. Failed origin-controls-native01 and
snapshot14 remain preserved; the corrected controls use a fresh output path.

Snapshot16 also corrects expected-rejection process interpretation, found during
the same source review before snapshot15 ran any target. ExecutionGuard marks
`complete` true only for exit zero. A valid expected exit one therefore has
`complete=false` but still has finished/wall timestamps and no error, resource
stop or interruption. The request checker and admission now require that exact
bounded exit-one shape, empty stdout, absent C and the unchanged complete original
diagnostic. Positive jobs still require exit zero and `complete=true`. Snapshot15
is retained as unused preparation; snapshot16 is the executable correction.

Snapshot17 separates conformance provenance from per-case execution inputs. The
full source/build/history/toolchain closure remains pinned as `provenanceInputs`
and is verified before and after each guarded stage suite, again at collection,
and by admission. A minimal adapter derivative changes only its three input-list
uses to the selected stage's `executionInputs`. This list retains the selected
compiler image/source, Base, runtime/template/parts, providers, carrier, all active
fixtures, selection, compiler manifest and adapter/harness methods. Node/Clang,
Bun acquisition history and prior C/proof/build provenance stay in suite checks.

Original69 fixtures,31 exclusions, golden judge, argv, isolated worker behavior,
three exact rejections per stage and300s/90s guard limits are unchanged. Diagnostic
runner changes only its adapter import path. The derivations are checked exactly
before execution and by admission. `conformance_integrity.py run --plan PLAN
--role b1|b2|diagnostics` wraps the three existing guarded commands; `collect
--plan PLAN --out RESULTS` runs the unchanged semantic collector then adds actual
suite integrity receipts. The failed300s conformance01 observation remains an
incomplete harness attempt, never a compiler semantic failure or qualification.

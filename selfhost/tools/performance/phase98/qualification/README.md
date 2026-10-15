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

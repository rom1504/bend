# P43-004 implementation status

Current correctness: checked13 genuine bounded Number/BigInt source PASS22 oracle groups/40 boundaries; fresh independent numeric noncommutative85 is pending. Checked11 fusion previously passed22/39+85.
Measurement: clean checked09 source screen gains4.20823/8.06899× original at64/256, at2.07519/1.010484×TS.
Decision: checked13 numeric source actual controls pass; independent numeric85, fresh source timing and finalselected owner freeze/release closure remain pending. Source v7 lowering failure is preserved; production uses corrected original App shells. Root owns all production integration and target execution.

The investigation below preserves earlier hypotheses, rejected variants and intermediate source failures.

Read Phase39 callback rejection before authoring. Its exactCode and per-edge
coverage costs explain a concrete difference from the current proposed boundary;
they do not establish the size of the recovery. Current tools preserve original,
same-admission generic, direct-unfused and TypeScript comparator roles.

Tools are in `selfhost/tools/performance/phase43/callbacks/`:

- `derive.mjs`: checked three-list fixture; explicit capture/value scalar worker,
  unchanged list construction and traversal, one default scalar wrapper admission.
- `controls.mjs`: inherited demand/host/error controls plus complete three-stage
  values, fresh capture arrays, and Error-hook alien callback invocation.
- `closure-derive.mjs`: actual checked scalar composition-chain ablation with
  complete chain materialization; no list/chain fusion or closed-form sum.
- `closure-controls.mjs`: complete captures, fresh descriptors/bound vectors,
  retained chain aliases, changed-code errors, entry/dependency/host controls.
- `SOURCE_PATCH.md`: generic source module/function proposal and proof grammar;
  no source-name allowlist or unconditional JPure function admission.

Independent reviewer found an active-flag proof-suspension gap before target
execution. The first draft could specialize an alien callback while `bad()`
suspended regionProof around Error construction. Repaired with exact nonnull
proof-token equality and added an Error-hook callback-map witness returning999
through its own code. Preserve this rejected boundary; it is not a source bug.

Root execution recipes (NODE is absolute Node24 path; fresh output dirs):

```sh
$NODE selfhost/tools/performance/phase43/callbacks/derive.mjs \
 selfhost/build/phase39/callback-baseline02/modules/callback-fixture-v2.mjs \
 selfhost/build/phase39/callback-typescript02/modules/callback-fixture-v2.mjs \
 selfhost/tools/performance/phase39/callback-catalog-v2.json \
 selfhost/build/phase43/callback-direct01
$NODE selfhost/tools/performance/phase43/callbacks/controls.mjs \
 selfhost/build/phase43/callback-direct01 selfhost/build/phase43/callback-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/callback-direct01/compare.json \
 selfhost/build/phase43/callback-screen01 --node "$NODE" --cpu 3 --budget 60
```

Derivation expected under1s; controls1–3s; three-round fixture screen around21s
(previous matching role screen20.586s). No new compiler acquisition required.

Actual closure recipe uses Phase42 checked16 full-preparation module and the
frozen Phase37 TypeScript module supplied by root:

```sh
$NODE selfhost/tools/performance/phase43/callbacks/closure-derive.mjs \
 selfhost/build/phase42/integration03/full-preparation/modules/closures.mjs \
 "$TS_CLOSURES" selfhost/tools/performance/phase37/catalog.json bench \
 selfhost/build/phase43/closure-direct01
```

Derivation is a static rewrite. Run `closure-controls.mjs DERIVED NEW_CONTROLS`
before clean timing. Expected
screen under20s; shared comparison budget60s. Broader source specialization only
follows a surviving actual-family result and source proof review.

## Actual materialized-chain result and next discriminant

Root reports `closures-controls01`PASS. `closures-screen01` clean medians in
milliseconds/call:

| Size | Original | Scoped | Direct | TS |
| --- | ---: | ---: | ---: | ---: |
| 64 | .0499174 | .0606455 | .0463065 | .00571189 |
| 256 | .191414 | .197006 | .157432 | .0227036 |

Direct application wins1.08/1.22×original, leaving about8.11/6.93×TS. This
supports a stronger construction discriminator, not parity or source promotion.
Original/scoped/direct tools and raw evidence stay frozen.

`environment-derive.mjs PREVIOUS_DERIVED NEW_OUT` creates a fourth role with
private first-order identity/scalar/composition objects. It preserves descending
fresh scalar capture construction, materializes base identity, then materializes
composition nodes in original ascending unwind order before invoking any scalar
callback. No closed-form sum, capture caching or fusion removes the chain.
Original generic construction machinery and fn/bound arrays disappear from this
private graph. Diagnostic counters separately count leaves, identities and
compositions. Full environments are exposed only in diagnostic modules.

```sh
$NODE selfhost/tools/performance/phase43/callbacks/environment-derive.mjs \
 selfhost/build/phase43/closures01 selfhost/build/phase43/closures-environment01
$NODE selfhost/tools/performance/phase43/callbacks/environment-controls.mjs \
 selfhost/build/phase43/closures-environment01 \
 selfhost/build/phase43/closures-environment-controls01
python3 selfhost/tools/performance/phase35/compare.py \
 selfhost/build/phase43/closures-environment01/compare.json \
 selfhost/build/phase43/closures-environment-screen01 \
 --node "$NODE" --cpu 3 --budget 60
```

New tool versions pass Node24 syntax checks. Target controls/timing pending root;
expected derive<1s, controls2–4s and five-role screen20–30s. Environment controls
include full captures/node shape, fresh objects, retained alias references,
repeated invocation, root activation/construction counts and actual environment
Error-hook proof suspension. Shared controls retain descriptor/host/raw/staged/
extra fallback and early/late generic callback errors.

## Complete construction discriminator

Root reports first-order environment controlsPASS. Fresh serial screen medians
(milliseconds/call) are:

| Size | Fresh original | Environment | TS | Gain vs original | Environment/TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64 | .0605238 | .0162541 | .00701719 | 3.72× | 2.32× |
| 256 | .229403 | .0276561 | .0261616 | 8.29× | 1.057× |

These are a stronger actual-family gain with complete private materialization;
source promotion and overall parity remain unestablished. Use each screen's
fresh original and TypeScript roles; do not cross-divide the first screen.

`callback-candidate.bend` and `callback-source.patch` now contain the generic
source implementation, not only a proposal. Source-facts input is
`selfhost/build/phase43/closures-facts01/source-facts.json`. It established source
composition arity5 versus emitted fn arity6, exact three Type&1/q0 binders and
live f/g/x quantities1, Nat factory predecessor quantity2 and capture Bind
quantity1. Source candidate matches those complete identities and specializes
three erased types to canonical U32 before checking the live function telescope.
No source benchmark name appears in selection.

Reviewer found and repaired incomplete erased-prefix/type proof and strict-&&
recursive proof hazards before source acquisition. Native scalar recursion now
uses kc shape/identity and child-success gates; factory/compose outer size bounds
are themselves kc-gated before scans. Exact Type&1 metadata is checked. The
source integration only augments projection's capture predicate; preserve any
concurrent String family's scalarCapture third argument when merging.

`noncommutative-fixture.bend` supplies two independent source kernels:
multiply-add and capture-minus-argument. `noncommutative-oracles.json` computes
72 scalar observations from independent ordered integer recurrences. Same-arity live
prefix, changing two-parameter captures and returned closure roots must refuse
specialization. Qualification and actual emitted-path counters remain pending
root's checked source build and fixture gates.

Run actual source fixture controls after checked emission:

```sh
$NODE selfhost/tools/performance/phase43/callbacks/source-fixture-controls.mjs \
 "$ACTUAL_NONCOMMUTATIVE_MODULE" "$REFERENCE_NONCOMMUTATIVE_MODULE" \
 selfhost/build/phase43/callback-source-fixture-controls01
```

The tool scopes private-root counters to actual G assignment syntax and requires
exactly the two eligible noncommutative roots to activate. Unsupported live
prefix, changing-capture factory and returned closure are refused, while their
full outputs still match the reference. Expected execution1–3s. This tool passes
Node24 syntax checks; no source checking or target was run by the callback owner.

## Checked05 source acquisition and ordinary-entry controller

Root repaired three affine-list inference annotations after checked04 refusal:
`vars`/`capture_env` are ListKTerm and `helpers` is ListKDef. Checked05 build and
36 selected checks passed. However static inspection of its actual closures
module shows no private environment marker; `bench` remains generic and `chain`
is uncaptured. This is a real source activation failure, not a saved-prototype
success. Source predicate tracing is queued before deriving/timing that image.

`proof-trace.mjs ATTEMPT SOURCE ROOT_EXPORT NEW_OUT` overlays the checked compiler
API, writes separate root/factory/compose admission subpredicates to report.json,
and intentionally stops before emission. It never supplies a favorable timing
or installs a compiler. Inputs and expected diagnostic stop are retained.

`actual-derive.mjs ACTUAL_MODULE PREVIOUS_CLOSURE_DERIVED NEW_OUT` requires a
marker-bearing checked module receipt and instruments its actual ordinary entry,
private source construction and application sites. It adds no private proof
flags or synthetic entry admission. `actual-controls.mjs DERIVED NEW_OUT`
compares original/actual full outputs, real activation/construction counts,
complete environments and fresh/retained references, post-success dependency
metadata mutations, raw/staged/extra calls, hostile argument-slot demand,
host reentry, retained/changed public callbacks and injected Error-hook alien
callback execution. Counter modules are never timed. Both tools pass Node syntax.

The noncommutative catalog is now frozen with84 scalar cases from one source:
`noncommutative-catalog.json`; four fast points cover two positive roots at64/256.
Checked acquisition commands (root alone; independent new output directories):

```sh
python3 selfhost/tools/performance/programs/prepare.py \
 --attempt selfhost/build/phase43/checked05 --role candidate \
 --catalog selfhost/tools/performance/phase43/callbacks/noncommutative-catalog.json \
 --set fast --out selfhost/build/phase43/callback-fixture-candidate05 \
 --node "$NODE" --cpu 3 --timeout 90
python3 selfhost/tools/performance/programs/prepare.py \
 --attempt selfhost/build/phase42/checked16 --role baseline \
 --catalog selfhost/tools/performance/phase43/callbacks/noncommutative-catalog.json \
 --set fast --out selfhost/build/phase43/callback-fixture-baseline01 \
 --node "$NODE" --cpu 3 --timeout 90
python3 selfhost/tools/performance/programs/prepare.py \
 --upstream selfhost/.bootstrap/upstream-phase23 --role typescript \
 --catalog selfhost/tools/performance/phase43/callbacks/noncommutative-catalog.json \
 --set fast --out selfhost/build/phase43/callback-fixture-typescript01 \
 --node "$NODE" --cpu 3 --timeout 90
```

All four roots and retained helper are library exports in that one checked source
module; the source-fixture controller checks its72 oracle points independently
of the acquisition's four fast benchmark points. Candidate05's activation failure
must be repaired before expecting its positive-root activation gate to pass.

The first predicate trace failed in5.53s with statusok/expectedStopfalse because
library mode does not call j_program_selected. Preserve its v1 tool and raw
`callback-proof-trace05` result. `proof-trace-v2.mjs` hooks the actual
j_library_selected(book,defs) library boundary; its Node syntax check passes.
The original hook failure supplies no predicate or activation evidence.

The successful v2 trace localizes refusal to compose's erased-body quantity:
all scalar/type/arity checks pass, live composition telescope passes, but erased
prefix false. v3 proves all three formal Allq0 and exact Type&1 domains pass,
while each lookup-supplied body Lam hasq1. This is the original source view, not
an erased-type relaxation: typed-driver lines516/529/564 pass original contextBook
and separately annotated defs to j_library_selected. Helper lookups return raw
`def compose(A,B,C,...)` default-q1 lambdas. Annotation's ka_lam derives bodyq0
from checked formal Allq0, explaining earlier annotated facts. j_lambda_bind
already uses formal type quantity to erase ordinary code.

`callback-erasure-v2.patch` corrects precisely that source-view boundary: retain
exact Type&1/Allq0 proof; require raw helper Lamq1; prove each erased binder absent
from runtime syntax under the established size bound; skip Ann type children.
Capture eligibility proves the exact original lookup rather than confusing
annotated d with original helper metadata. It preserves checked05 list annotation
repairs and makes no String projection change. `callback-candidate-v2.bend`
retains the complete successor. Root owns applying/checking this delta.

Actual checked06 source admission predicates and private marker pass, but the
first ordinary-entry runtime control fails with a root-local TDZ (x3460): the
private body references source binders whose aliases exist only after its guard
in generic fallback. This is a source implementation failure, not a passed
callback performance result. Preserve callback-actual-controls06/report.json.
`callback-root-alias-v3.patch` binds the exact admitted two root source locals
to already-read $s0/$s1 inside the proof try before the private body. Root owns
rebuilding and rerunning every actual control. No host slot is read twice.

`source-fixture-controls-v2.mjs` additionally validates both checked emission
receipts, module bytes and exact frozen fixture source bytes; its observation
policy remains85 groups and exactly two selected scalar roots.

Root ran actual06 forged-IR admission controls successfully: exact original
composition admitted, live formal quantities1/2, raw Lambda quantities0/2,
wrong universe quantities0/2, malformed extra universe child, erased runtime
use and invalid scalar shapes rejected. Preserve callback-admission06/report.json.
Actual06 noncommutative selection is exactly affine_result/reverse_result and
refuses live_result/seeded_result/retained, but runtime fixture also fails on the
missing root aliases before first complete observation; preserve
callback-source-fixture06/report.json. Neither is a runtime correctness PASS.

Root's actual checked08 callback controls now PASS22 oracle groups/32 boundaries;
independent noncommutative source fixture PASS85 groups with exact selection and
refusal. Fresh actual screen:64 original0.0526434/candidate0.0296902/TS0.00648357
ms, gain1.77× and4.58×TS;256 original0.196587/candidate0.0418538/TS0.0241735,
gain4.697× and1.73×TS. These source gains are weaker than saved whole-environment
screen, motivating a strictly scoped String guard ablation, not a generic guard
relaxation.

The generic compose telescope conservatively marks its public snapshot as String
family because erased type parameters remain generic. The exact callback root
proof separately establishes runtime U32-only specialization and scalar captures.
`string-guard-derive.mjs ACTUAL_DERIVED NEW_OUT` produces immutable actual/fullGuard
comparators. Only its proved private callback root supplies an inaccessible
identity capability to localGuard/scalarGuard, skipping conservative String
inventory while retaining full host/dependency/metadata checks. Public capture
family metadata and generic String consumers are unchanged.
`string-guard-controls.mjs DERIVED NEW_OUT` retains22/32 and adds3 irrelevant
String-host mutations with real private activation and1 foreign String-valued
public callback with live generic demand (expected22/36). Root alone executes.
`callback-string-guard-v4.patch` is the51-line generic candidate, pending the
scoped discriminator and independent source review.

Before execution, root requested a second independent factor for existing
total-U32 host guard selection. Preserve v1 unchanged. V2 derivative/controller
use the same CLI and compare five clean variants: original/fullGuard/stringOnly/
actual(String+existing U32 subset)/TS. Only the proven callback root adds
regionHostGuard(true); its checked grammar has no Float/DataView/String operation.
V2 controls additionally mutate unused DataView.setUint32, Math.sin and
Number.isFinite, require private root activation and unchanged empty traces, and
retain relevant host/dependency/protocol/Error guards (expected22/39).
`callback-string-u32-guard-v5.patch` is the51-line successor; no new U32 token.
Reviewer independently qualifies v4's narrow String capability for source
experiment, pending actual activation and live foreign String demand controls.

If the scoped v5 source guard is selected, `actual-guard-controls-v2.mjs
ACTUAL_DERIVED NEW_OUT` binds the ordinary actual-derive checked receipts and
requires the full22/39 policy without treating the saved derivative as checked
source. Report kind: phase43-actual-source-callback-guard-controls. Syntax PASS;
execution pending. Keep original actual-controls and saved v2 controllers frozen.
Actual08 private captures lower to Number(pred &0xffffffffn), ordinary U32 add;
affine fixture leaf uses Math.imul and reverse fixture leaf subtraction. There
is no getG/native callback edge inside the admitted private try block. The U32
host subset retains Number/BigInt globals and Math.imul.

Root's scoped saved-v5 discriminator PASS22/39. Fresh screen:64 fullGuard
0.03058/scoped String+U32 guard0.013215/TS0.006183ms, scoped2.31× faster
than actual08 full guard and2.14×TS;256 full0.03909/scoped0.023013/TS0.024444,
scoped1.70× faster and0.941×TS. These are saved derivative results; actual08
checked production still uses the original guard and its separately recorded
source screen. Root now integrates v5 and must qualify the fresh selected image
with actual-guard-controls-v2(22/39), independent noncommutative85 and exact
compiler erasure/admission11 controls before claiming the new source behavior.

Independent static review of v5 closed: exact grammar excludes runtime String
and Float operations, capture/leaf lowering is primitive-only, and existing U32
host subset retains Number/BigInt globals and Math.imul. Provenance/dependency
identities and public String snapshots are unchanged. Review receipt:
review/map-source-callback-guard-static-v1.json,
SHA256c01e9780f6f30962b4bbf6d527c05d7598cea98c7b1e8a83e50264cb43d9c586.
The static receipt and saved PASS do not replace final actual-source controls.

Fresh checked09 source with scoped String capability and existing total-U32 host
subset is now runtime-qualified: callback-actual09 derivation PASS;
callback-actual-controls09 PASS22 oracle groups/39 boundaries with real ordinary
activation, complete materialized environment, fresh captures and aliases, all
source/dependency/entry/host/Error refusals, ignored String/Float host hooks and
live foreign String callback demand. Independent callback-source-fixture09
PASS85 groups; selected affine_result/reverse_result, refused live_result/
seeded_result/retained. Receipts bind checked09 API
bff9f65506c078a5234d759ba837bb85556b1af7aa15b63acca499541fb9618b and runtime
e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb.
These are actual checked-source results, distinct from prior saved ablation.
Fresh checked09 timing and final selected-image owner acquisition/freeze remain
pending; earlier PASS reports cannot stand in for final release closure.

Fresh checked09 source timing now passes checked09-screen01: closure64
baseline0.056642357/candidate0.013459902/TS0.006486111ms per call,
4.20823× original gain and2.07519×TS; closure256
baseline0.191809446/candidate0.023771169/TS0.023524538ms,
8.06899× gain and1.010484×TS. This is clean actual checked-source timing,
not the manually edited ablation. The source recovers the materialized
environment win while preserving exact ordinary-entry admission and guards.
Final fresh selected-image acquisition/freeze still remains mandatory.

Zero/very small call performance is not measured by this screen. Guard work is
fixed per ordinary entry: two input slots, exact root/factory/compose metadata,
retained numeric/prototype/protocol checks and fresh materialized environment.
No root-level descriptor cache is installed. A straight line through the64/256
points suggests about10.0µs candidate fixed cost versus0.81µs TS, but this is
a diagnostic extrapolation, not a zero-size timing or regression claim; V8
tiering, branch behavior and generic shallow closure costs can differ. Small
workloads may therefore be guard-dominated even though the256 point is nearTS.
No additional experiment is authorized before final owner closure.

Optional saved-output fusion discriminator (root authorized while Map stabilizes):
`capture-fusion-derive-v1.mjs CHECKED_MODULE ACTUAL_DERIVED_OR_DASH NEW_OUT`.
For closure module use parent callback-actual09; for independent source fixture
use dash. The tool copies the exact capture and leaf source expressions and
combines their descending n→1 loops; it omits only the private unescaped pending
array/environment graph. It preserves real ordinary-entry admission, exact
source/code/metadata and scoped host guards, public generic fallbacks and
noncommutative application order. It emits no closed-form arithmetic.

This fusion is justified only under the exact total-U32 capture/application
grammar: captures depend solely on countdown, seed arithmetic is total, no
callback/host/error can observe the interleaving, and the root returns scalarU32.
Full source capture evaluation order across stages changes; excluded failure/
foreign-call/escape cases are essential, not inferred from purity alone.
`capture-fusion-fixture-controls-v1.mjs DERIVED BASELINE_MODULE NEW_OUT` requires
85 independent affine/reverse/changing/retained/refusal observations before
any timing. `capture-fusion-controls-v1.mjs DERIVED NEW_OUT` requires22/39;
complete ordered fresh capture traces replace graph object retention assertions
because the fused graph is absent. Public retained/mutated callbacks, demand,
Error reentry and String/Float guard controls remain unchanged. Counter modules
are never timed. Saved compare variants: original/materialized09/fused/TS.

`callback-capture-fusion-v6.patch` is a modest emission-only generic proposal;
source admission proof stays exact. Syntax and static apply checks pass. No
execution/result or production application is claimed. Existing checked09
materialized source remains the qualified owner until fresh fusion qualification.

Root's saved capture/application fusion discriminator now PASS22/39 plus
independent affine/reverse85. Fresh saved comparison:64 original0.0529087/
materialized09 0.0131789/fused0.0122049/TS0.00606965ms, fused1.080×
materialized and2.011×TS;256 original0.200935/materialized0.0242613/
fused0.0167037/TS0.0253663ms, fused1.452× materialized and0.6585×TS.
The optional discriminator wins; root selects the18-line generic v6 emitter
reduction alongside the next Map fix. Saved result is not fresh checked-source
fusion qualification. Materialized checked09 remains historical qualified state.

Fresh fusion owners are frozen separately: actual-fusion-derive-v1 verifies
real checked emission/source receipt and copies clean candidate bytes unchanged;
its instrumentation observes one real loop, complete ordered capture values,
application counts and zero private environment graphs. actual-fusion-controls-v1
requires22/39 plus authentic checked-source manifest/certifiedtrue. Independent
source-fusion-fixture-controls-v1 requires85 and both actual checked receipts,
exact positive activation and existing live-prefix/changing-capture/escape
refusals. No manual checked receipt or activation satisfies these profiles.
Final-owner-data-v2 contains minimal3 active profiles: callbacks-fusion,
callbacks-fusion-noncommutative and callbacks-admission(11). Historical materialized
profiles/tools/reports remain intact but cannot satisfy fusion owner closure.
Final selected-source qualification/fresh acquisition and timing remain pending.

Fresh checked11 genuine source fusion is now runtime-qualified: actual-fusion
derivation and callback-actual-controls11 PASS22/39; independent fresh
callback-source-fixture11 PASS85. APIc5266a4d42d458cdc0489efc70d65f014758dd35c050b7a4351c974200333b9c
and runtimee62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb
identify this checked image. Materialized09 remains historical; source11
actually omits private environment graphs and preserves complete ordered
capture/application values, source/provenance/entry/host/Error behavior and
public generic retained callbacks. Fresh source timing and selected-image final
owner acquisition/freeze still remain mandatory.

Last optional saved Number-count discriminator (no production change):
number-count-derive-v1 accepts only exact integer numeric count0..0xffffffff
for Number decrement; all other counts execute the copied original BigInt loop.
The admitted Nat predecessor appears only through canonical U32.from_nat(pred)
in capture expressions; numeric pred in0..0xfffffffe has exact IEEE arithmetic
and (pred>>>0) equals Number(pred&0xffffffffn). Other capture/leaf expressions
and U32 wrapping remain unchanged, no unchecked Nat conversion or algebraic
shortcut. number-count-controls-v1 expects22/40, including forced original
BigInt branch small witness; independent number-count-fixture-controls-v1
expects85 noncommutative/negative groups. No guard/public/provenance change.
Syntax PASS; root alone executes, null result stops this hypothesis.

Number-count saved discriminator PASS22/40 and independent85. Fresh screen:
64 original0.0552024/BigInt11 0.0124731/numeric0.0108737/TS0.00659922ms,
1.147× faster than11 and1.648×TS;256 original0.212189/BigInt11 0.0167871/
numeric0.01064894/TS0.0239055ms,1.5764× faster and0.4455×TS. Root requests
modest generic source integration, pending exact lowering proof and build.

Preserve rejected callback-number-count-v7.patch: its IR rewrite rebuilt a
synthetic Call from j_call_spine. j_expr emits original App shells and returns
null for Call, so that draft would corrupt actual captures; root caught this
static error before applying/building. Successor v8 recursively rebuilds
original App shells with k_with_children(h,..), preserves Ref/literal/Var nodes,
and replaces whole exact admitted fromNat App with predecessor. Both numeric
and BigInt emission paths share original capture/application loop lowering.
The prebuild number-count-lowering-probe-v1 mirrors the rewrite on actual source
IR through checked11 j_expr, records original/numeric expressions and invalid
synthetic Call, and compares five scalar predecessor images. It is explicitly
a forged lowering diagnostic(candidateCompiled:false), not candidate execution.

Genuine actual-number-count-derive-v1 copies unchanged checked source bytes and
requires two actual loops/capture sites, numeric/BigInt branch counters and no
owned graph. actual-number-count-controls-v1 requires22/40 with numeric ordinary
activation plus preserved originalBigInt small-count witness; independent
source-number-count-fixture-controls-v1 requires85/realcheckedreceipts.
Final-owner-data-v3 provides minimal3 successor profiles with strictgenuine
manifest/checked provenance. Syntax/apply checks PASS; source qualification and
final selected freeze remain pending. Prior fusion11 is the qualified source.

Root prebuild lowering probe PASS in callback-number-lowering12/report.json
(using checked11 API, despite output suffix12). Original capture emits
Number(pred&0xffffffffn); v8 preserved-App numeric capture emits pred directly
inside the same U32 add/wrap. Five predecessor values0/1/7/65535/4294967294
agree exactly; v7 synthetic Call emitsnull, recorded as rejected lowering.
CandidateCompiled remainsfalse: this diagnostic does not qualify builtv8.

Final numeric guard audit finds no additional semantic blocker: integer numeric
count bound gives exact decrement/pred U32 image; varsNil capture admission
permitsNat predecessor only insidefromNat, and leaf variables excludeNat.
Count/seed evaluateonce; numericEnvU32/originalBigIntEnvNat and native App shells
preserve source expression meaning. Relevant Number.isInteger/Number/BigInt/
Math.imul identities remain guarded. Finalprofile ordinary default entry uses
one maintained apply invocation, so genericcounter1 is required alongside
roots1/numbers1/bigints0, captures/direct=n and zero graph/proofclean. The
forcedBigInt small witness likewise generic1, roots1/numbers0/bigints1,
captures/direct7 and zero graph/proofclean. These counts follow runtime/
instrumentation structure, not values learned from a prototype report.
Optional experimentation is stopped; fresh source build/control/freeze pending.

Fresh checked13 genuine numeric source derivative and
callback-actual13-controls/report.json now PASS22/40, including real ordinary
numeric entry/capture/application counts, preserved host/source/provenance/
Error behavior and explicit originalBigInt fallback small witness.
APIe46928f077927745b2791ab2dc03c3b9850281069a893889991d44506a0045a6
and runtimee62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb
identify source13. V7 syntheticCall/null lowering remains rejected history;
actual13 uses preserved App-shell v8 lowering. Independent fresh numeric
noncommutative85 is queued after Map14; finalselected repeat still required.
No fresh actual numeric source timing claim follows from saved .4455×TS screen.

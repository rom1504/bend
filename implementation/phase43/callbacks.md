# P43-004 implementation status

Correctness: actual composition and first-order environment controls pass; checked source candidate qualification pending root. Saved-tool syntax checks pass.
Measurement: root completed both actual-family screens; no timings run by callback owner. Decision: investigate; no production
source change and no admission expansion.

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

# P43-004 known callbacks with explicit captures

**Final outcome:** selected changes are installed in Phase43 checked14. See the
[final release report](../../implementation/phase43/README.md); the notes below
preserve the experiment sequence and earlier pending or rejected states.

Owner: callback agent; executor/integrator: root. Started2026-10-04.
Saved-output correctness: PASS; environment screen: 3.72/8.29× original at64/256.
Actual-source correctness: checked13 numeric source PASS22/40; independent numeric85 pending; checked11 fusion22/39+85 and checked06 TDZ preserved.
Decision: checked13 numeric source controls pass; independent85/fresh timing/finalselected freeze pending.

[Design](../../design/phase43/callbacks.md),
[implementation and commands](../../implementation/phase43/callbacks.md).

Hypothesis: one scalar public admission plus constant-time private proof token
and known capture/value worker recovers callback overhead while retaining all
materialized intermediates. Phase39's rejected exactCode/per-site coverage
variant is the required negative comparator context. Current list512 fusion
success does not establish callback prevalence or justify a fusion retry.

First discriminant uses preserved checked affine callback source; actual
composition-chain discriminant follows with complete closure construction.
No compiler source change until full semantic/activation controls and clean
alternating direct-versus-scoped/original timings survive. Stop after an honest
null; do not widen JPure or add universal closure machinery to chase it.

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


Final installed outcome

Selected checked14 outcomes use the complete 45-point/669-sample campaign, not
exploratory screens. The [final table](../../implementation/phase43/results.md),
[raw aggregation](../../selfhost/build/phase43/final-results01/report.json) and
[raw runtime closure](../../selfhost/build/phase43/integration01/runtime-full45-close.json)
retain all observations. The [release report](../../implementation/phase43/README.md)
keeps compiler cost, source growth and release status separate. Checked14 is
installed; all 34 mechanism owners, 42 CLI checks, 15 postinstall groups,
227 source bindings and the 41-group composite installed closure pass. The corpus was
used during optimization; its historical holdout labels do not establish unseen
validation or universal TypeScript parity. Phase42 remains the comparison
baseline. The [portable current bundle](../../selfhost/tools/performance/phase43/current/manifest.json)
is complete: all 45 points were frozen and reopened byte-exact. Compact20,
full-fast60 and targeted60 smoke replays pass; all raw evidence is archived and
reopened with exact hashes, including the incomplete budget20 five-case attempt.

Both closure points improve: family geometric gain 9.43965×, geometric 0.910829×
TS. Size 64 gains 4.88238× and still costs 1.72809× TS; size 256 gains 18.2507× and
costs 0.480073× TS. Actual source fuses construction/application and removes the
unescaped environment graph; bounded Number countdown retains original BigInt
fallback and exact noncommutative application order. [Selected numeric closure](../../selfhost/build/phase43/integration01/phase43-close-callbacks-number-count/report.json)
and independent 85/admission 11 owners retain host, Error/reentry, retained public
callback and exact source/type controls. These results do not qualify escaping
closures or change public callback ownership.

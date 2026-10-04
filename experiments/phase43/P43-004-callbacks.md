# P43-004 known callbacks with explicit captures

Owner: callback agent; executor/integrator: root. Started2026-10-04.
Saved-output correctness: PASS; environment screen: 3.72/8.29× original at64/256.
Actual-source correctness: checked09 scoped guard PASS22/39 and noncommutative85; checked06 TDZ preserved.
Decision: checked09 scoped guard source-qualified; fresh timing and final owner freeze pending.

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

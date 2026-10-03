# Independent review: reuse existing JPure ownership boundary

> Contract clarification: [the executed preimport BigInt witness](returning-host-callback-assessment.md) falls outside the published standard-intrinsics-at-initialization contract (docs/BEND-IN-BEND-PERFORMANCE.md405–416, pre-Phase42). The earlier blanket promotion stop is superseded; retain the exact witness as boundary evidence. All43 static native-domain assertions passed, but supported postimport mutation, bounds and complete-value controls remain required.


The earlier matched-set document chose explicit ordinary/owned proof modes as a
conservative scoping mechanism. At the initial static review, inspection supported root's
smaller alternative: extend the *globally valid closed first-order source type
proof* with exact nondependent Sigma and List-of-closed-ADT, preserving the
existing runtime ownership boundary. No concrete counterexample was found in
that initial caller audit. The subsequent executed preimport host callback witness
shows a limit outside the published initialization contract, not a supported
domain failure. Static review remains conditional on supported controls.
The separate mode/cache hierarchy is not necessary if the following invariants
and controls hold.

`j_pure_type` proves a source type and all of its fields are closed first-order
shapes. It does not certify arbitrary public JavaScript arguments. Runtime
ownership is already established elsewhere: scalar-root exact saturation/input
validation, clean host/protocol and immutable complete descriptor guards, and a
complete source graph before `regionProofOpen`. `j_component_call` admits a
private call only while that proof is active and covers its entire original
graph. `j_direct_guarded` and `j_finite_named` likewise retain active proof
requirements. New public Sigma/List/ADT callers still run generic code.

With the stronger domain, a scalar root can prove its full graph and internally
construct those values. Ordinary generic G bodies use the shared expression
emitter: their saturated source calls already flow through finite/direct/
component named guards. Therefore generic build/insert residual bodies can call
new private down/up workers under root coverage without being rewritten into a
separate owned mode. G down's public descriptor need not itself invoke the
private worker; source callsites choose it. A host can directly invoke G down
with an alien argument only outside that source-owned root graph.

The capture-eligibility predicate may newly `scalarCapture` descriptor identities
for Sigma/List functions. Capture alone grants no private entry. Public Nat
workers retain their scalar-only input signature checks. Fold algorithms retain
separate zero-parameter/non-native owner and field restrictions. The new flat
lane checks zero type arguments and recursively checks every user field; native
Sigma/List containers remain excluded even when nested in an otherwise closed
user ADT. Do not loosen those checks accidentally while implementing this
extension. Existing public projection optimization keeps its generic project/
slice semantics and receives no ownership permission from a capture.

The ownership argument would fail if an admitted native operation called an
external observer, if arbitrary functions/foreign/Array/String/Char fields were
accepted, if a public ADT argument could open region proof, or if incomplete
helper coverage admitted mutated descriptor callbacks. None is intended or
allowed. Existing runtime bad/error handling suspends proof before mutable
exception hooks, and root scope closes in finally. Independent host/protocol/
mutation/external-ADT controls remain required; broad source purity is not a
replacement for them.

## Minimal type and equality obligations

Keep `j_list_ground_type` completely unchanged: it is also a grounded-U32
algorithm selector. Add distinct strict List/Sigma header/field proof helpers
under the current JPure visitor, consuming its shared fuel. User owner active
recursion remains only for parameterless canonical user ADTs; do not add an
active `List` or `Sigma` owner-name shortcut across different specializations.
A container recursively checks its actual element/fields every time, so a
List<Function> forbidden sibling cannot hide behind an active List<BFrame>.

List checks actual native owner, exact quantity2/element specialization,
canonical Nil/Con native ctor ABI and exact specialized fields/result. Sigma
initially checks observed quantity1/quantity1 and native Tuple arity2, its two
closed independent fields, unused family Lam binder and complete specialized
ctor result. Open Var, erased/removed fields, functions, Array, unknown native,
foreign, dependent families and malformed metadata refuse. Normalize Ref aliases
before comparing admitted field identities. Do not infer independence by one
witness application. A later wider quantity domain is a separate extension.

Strengthen `j_region_same_type` whenever either normalized side has Sigma or
List parameters: exact admitted header/quantity and recursively equal fields or
element. Existing scalar/parameterless user owners retain canonical identity
comparison. For closed independent Sigma families, binder alpha-renaming is
vacuous after checking no binder uses; compare the normalized body fields.
Refuse one-container/one-noncontainer or mismatched element/field quantities.
The confirmed current name-only Sigma true result must become false for distinct
specializations *before* new JPure admission is enabled.

All pure type/signature/constructor/call proofs then share one stronger logical
domain, so the existing request component/direct cache can retain exact original
plans with its existing separate plan-kind keys. No new cache authority, owned
mode or layout payload is needed. Source changes produce a new checked compiler
identity; there is no process-persistent old-plan reuse.

Frames-owner native emission obligations remain: Tuple is a transparent sole
arm with direct [0]/[1] fields, List remains tagged .$/.a, and construction starts
with existing exact native ctor semantics. Generic build's computed alias can
stay refused by structural planner while its source purity and guarded helper
calls operate under the complete root proof. Sequential inorder candidate04
still supplies the separate dependent traversal shape.

## Estimate and evidence required

Expected minimal source size is approximately 150–230 LOC for bounded native
container proof and exact type equality, 35–70 LOC matching/projection changes,
and the held63-line sequential continuation: roughly250–360 LOC total. This is
smaller than the earlier320–520 explicit-mode estimate and preserves current
architecture. Further reduction must not remove exact specialization or fuel/
coverage checks. No generic mutual SCC machinery/runtime change is needed.

Cheap falsifier remains a complete diagnostic API overlay of these rules, not a
type whitelist alone. Compile the original source with actual root-open and
private down/up/inorder counters, then compare complete native pairs, every
ordered zipper frame, tree node/value/alias and wrapped output. The original
probe02 supplies baseline refusals and the equality hazard. All independent
nested function/vector/dependentSigma negatives must target the new predicate,
with mismatched quantities/metadata/open fields and shared-fuel exhaustion.
External ADT inputs, changed relevant G code and added Array prototype observers
must produce zero private entries and original generic behavior. Entry and
complete-value evidence precede timing or source promotion.

Source16 compatibility correction: strict closed native equality is now called
directly by JPure Ann/Var/terminal checks and native-proof controller v02.
The shared local-region equality policy is restored exactly to Phase41 for
its existing qty2 vector/Sigma callers, whose layout gates remain separate.
The original broad shared-equality change caused a real lost-worker regression;
43 native assertions alone did not cover it. No native qty1/type/field/refusal
proof is weakened by the split. Frozen v01 evidence and source15 counts remain
retained as historical artifacts; source16 needs its own actual validation.

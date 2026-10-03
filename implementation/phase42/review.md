# Phase42 independent review

Status: prospective/static review only. No compiler, benchmark or semantic jobs
were run by this owner. Root's execution evidence must be linked separately.
Read repository AGENTS, experiments README/latest ledger frontier/STEERING,
checked B1 development rules, Phase41 tree source/independent review and corrected
actual/fixture controls. No distinct latestcode/facts file was found in the active
tree; active `selfhost/src/back/js/tree.bend` supplies code facts.

## First priorities

Whole-component calls must retain the complete typed transitive guard and never
revive a refused entry after getter reentry. Compact frames must capture original
parent values across left/right/join phases and retain stack safety. Private ADT
layout needs an explicit public/generic boundary, fresh constructor and alias
argument. Fusion needs full values, demand/error order and the current direct-
unfused denominator. The [minimum matrix](../../design/phase42/review.md) records
the exact discriminating witnesses.

## Initial concrete static inspection

`calls/derive.mjs` changes only private `$tree` bodies and keeps ordinary globals
and root guards. It adds handwritten warp-leaf/key helpers and separately removes
inner proof conditionals. This is a mechanism ablation, not generic source
admission. Its fixed tree dependency list must cover every bypassed primitive,
combiner and transitive dependency. Removing inner guards requires all private
worker entry paths to come from a root proof covering that closure; a diagnostic
direct worker adapter alone does not establish this invariant.

`frames/derive.mjs` extracts branch-specific right/join code, captures live `xN`
values in scalar frame fields, and switches on the original branch site. It keeps
`$next` vectors and the existing iterative worker. Its prototype only handles
binary sites. Unary phase2/phase3 continuations must remain unchanged/refused.
`ids` subtracts all declared names from all referenced names without lexical
scope analysis. This can serve the exact generated fixture only if generated
binder IDs are globally unique; source admission needs binder identity rather
than a textual approximation. A declaration in one sibling scope must not erase
a free use in another. The native recursive role is a ceiling experiment; its
deep failure cannot be omitted or counted as parity for the iterative survivor.

Concrete owners were sent these priorities and asked to supply frozen proposals.
No approval or production promotion is claimed by static inspection.

## Challenges and corrections

Calls controls initially labeled saved-JS rewrites `checked:true`. Reviewer
challenged this; owner reports correction to `checked:false,parentChecked:true`.
The guard-only role originally had no counter, so parity could not independently
show private refusal. Owner reports adding an actual warp_node worker entry
counter to every role and extending refusal assertions. Root must execute the
corrected concrete controls; these are reported author changes, not run results.

Layout's first marker proposal reads public `_p42` properties in generic
`project`, `fields` and slot helpers. This introduces demand on hostile public
getters even when representation is refused. Owner independently caught it
before execution and proposes bound private WeakSet membership. Reviewer asked
to retain the marker tool as a rejected pretest predecessor, bind membership
without public property demand, and document packed constructor ownership plus
generic fallback routing. Private diagnostic representation escape does not
establish public ABI admission.

Fusion rewrites the exact closed scalar bench root and retains generic/public
workers and proof cleanup. Its handwritten arbitrary-U32 fused helper is an
arithmetic witness only: actual producer values are limited to `seed % 16`.
Reviewer requested this distinction and an ordinary fused `bench(30000,max)`
oracle because the existing deep rows test unchanged producer/stage workers.
Tail-before-head filtering rules out general fusion with observable predicate
effects/errors unless the admitted scalar subset proves total inert operations.

Reviewer tool attempt `node --check review/oracles.mjs` could not launch:
`/bin/bash: line 1: node: command not found` (2026-10-03). A following independent
hash command succeeded; its shell status does not turn the missing syntax check
into a pass. No syntax or semantic pass is claimed for the new helper. Root may
use the campaign's configured Node binary. `rg` was unavailable as well, so this
review used `find`, `grep`, `sed` and direct reads.

Further read confirms calls' corrected metadata and every non-original role's
refusal counters. Layout `prepared02` replaces public marker reads with a bound
private WeakSet and records 40 complete-value / 59 boundary cases in
`controls02.json`; this is an owner-run report, not independent execution. Its
control report lacks consumed producer, derivation and module identities, and
the harness does not verify derivation hashes before import. Reviewer requested
a versioned successor with provenance plus recursive host input (the current
hostile flow case uses count zero). A future source solution must also justify
the new WeakSet/has/add/bind native assumptions at the host boundary.

Fusion owner reports adding ordinary depth30000 calls with actual root entry
counters and an independent renamed Chain fixture. Those statements are pending
root acquisition/execution; unchecked fixture refusals must remain exact. The
proposed source domain explicitly excludes callbacks, String/native hooks,
division and early termination rather than inferring totality from purity.

## Corrected saved-output tools

Calls derive-v1 actually fails nested AST edit overlap. The earlier first-pass
statement that its overlap assertions looked sound was incomplete: nested
discarded fallback guards create overlapping ranges. Owner retained derive-v1;
derive-v2 renders an admitted consequent before descending and therefore never
edits its discarded fallback. Static review finds no analogous overlap in v2.
This correction preserves the same mechanism/domain rather than widening it.
Root reports complete direct-call controls 191 oracle rows / 75 boundaries,
including deep results, and a 2.35–2.46x three-point screen; these are root-run
results, not this reviewer's independent execution or source admission.

Fusion v1 fails at the 30k diagnostic generic filter after 112 oracle rows /
79 boundaries / two admissions. The diagnostic invoked public non-tail filter
outside the original private proof. V2 validates the diagnostic scalar domain,
uses the existing full graph host/local guard and closes proof in `finally`.
Clean original/fused bytes remain unchanged. Static review accepts this as a
diagnostic route correction, provided the original stack failure remains retained;
it does not assert general public filter stack safety.

Layout successor controls now verify all six module hashes from derive.json
before import and again after observations, retain consumed producer identity,
refuse reused output paths, and test recursive host flow plus warp_node. The
old controls-v1/controls02 report remains retained. Successor execution was not
run by this reviewer. Existing regionHostGuard already snapshots WeakSet global,
has/add and Function.call-related assumptions; a source solution must use that
existing boundary consistently for private packed routing.

## Whole-private graph ceiling blocker

New layout `complete-v1.mjs` bundles direct private graph, flat named fields,
BigInt Nat and native recursion under depth12. It is explicitly a manual ceiling,
not isolated layout causation or source/deep-stack admission. Its independent
private flow/warp cases cover mismatched/uneven/shared shapes and fresh zero-flow
roots, with public fallback bodies retained.

Static blocker: the producer inserts `$s0<=12&&` before `$entered`, host guard
and original canonical scalar checks. A noncanonical host count object can now
demand `valueOf`/`Symbol.toPrimitive`; a Symbol count can throw sooner than the
original fallback. Thus the ceiling itself changes hostile entry demand/error
order. Reviewer requested a versioned successor retaining v1, moving the cap
after the existing guarded canonical domain, plus count-coercion/throw/reentry/
Symbol/raw-entry observations. No execution or admission is approved by this
static review pending that correction.

Complete-v2 moves the cap after the exact original host/canonical-U32/local
guards, fixing the coercion blocker by static inspection. Controls-v2 then
reports an unbounded bsort getter reentry causing stack-dependent trace counts;
owner retains that failure and controls-v3 bounds getter reentry once before the
nested call. It adds guarded/private entry counters and preserves exact finite
traces. These are owner/root-reported checkpoints; no independent run occurred.

## Checked source acquisition review

Reviewed `calls/helpers-v2.patch` SHA256
`c86194e887a49242b51b1be7285c9eb7a8eee73ce735ef629b00f519f6d0fd66`
and `frames/context-source.patch` SHA256
`0966c282aeb343774eaf3e81f5aff20589c15c492d2d8082383257fae237c5c4`.
No static semantic blocker found; root may acquire a checked candidate, subject
to runtime and independent fixture gates. This is not source promotion.

The helper plan starts from original typed JPure graph, then bounded active-name
DFS rejects self and transitive backedges. Native helper emission is limited to
the typed Bool.xor signature: the visit rejects other native definitions even
when JPure admits one. The context rewrite requires exact canonical/current
definition identity and exact complete callee-graph subset. It removes the
current owner from the context, so a callee whose closure returns to that owner
cannot erase its boundary. Current-owner self recursion remains under the
existing stack machine. Original definition/body remain the planning witnesses.

Partial, oversaturated and function-valued source calls are independently
excluded by JPure; private rewrite requires the original saturated call spine.
Original result annotations retain shared binder/argument typing. Inline finite
helpers use original left-to-right argument emission once and eager fresh tagged
constructors. No new runtime or public entry weakening is proposed. Guard
lifetime still depends on the original synchronous pure scalar-owned root and
its finally cleanup; hostile/refused public inputs remain generic.

Remaining cost risk: recursively inlining an acyclic graph can expand shared
callee bodies exponentially. Per-body256, graph8192 and depth16 bounds establish
finite analysis, but are not a practical emitted-byte budget. Root was notified
to disclose compiler/request/source costs and consider an expansion budget
before wider admission. Tests and a timing gain cannot prove universal validity.

`review/fixture-renamed.bend` independently supplies a renamed ADT map, U32 key
and pair helper, nested Bool.xor dependency, scalar public checksum, first-class
and partial-reference refusals, unsupported String signature and transitive
wrapper backedge. Its main oracle is 37035 (key(0)=12345, True flip reverses the
pair, score=3*12345). Fixture is unchecked; retain exact acquisition failures.

## Mandatory narrowing, expansion, fusion and constructors

Static reviewed patch identities:

| Proposal | SHA256 |
| --- | --- |
| calls expansion | `452f9748bdfbb02881ca4e62de6697e40a6c9d0fdea2619c5d11e2c2d35044a6` |
| calls annotation types | `c8f9aa4f61ff2e6e496a63a68e5edfde8ecaed124635cd73bce52b532d13d899` |
| fusion source-v1 | `a69d7fa232c87aadc93d3f695debaa8812013415b24a36545995fa1df5d36bd2` |
| owned constructors | `ff425a184f5d5274742a84a882bed805b71068c9f08d256d7a1028c2b10bcd7b` |
| owned helper activation | `9675ab9ad829208d9cf554bab0106a9846e20f2b05664be93d85073ad3c84b9d` |

Annotation-types is mandatory narrowing. The original helper walker could
rewrite source annotation type Apps although the typed graph validated source
values; tree-only checked01 observations did not cover that possibility. The
successor preserves Ann.type exactly and requires Def/positive arity before
rewriting a call. Explicit List/type-alias annotation regression was requested.

Expansion adds shared2048 fuel charged for every source node and every copied
nonprimitive callee at every saturated occurrence, including argument expansion
before callee expansion. Native helper emission is charged and cycles refuse.
Its conservative traversal of annotation types may reject extra shapes, but
does not admit uncharged emitted inline calls. This addresses the previously
reported repeated-callee expansion concern; emitted-byte and request costs
still require root measurement.

Fusion source-v1 replaces only the existing successful guarded root body. The
nested saturated producer/filter/map/fold syntax admits a single private scalar
use; returned/shared/let-bound intermediates and non-U32 root inputs refuse.
Owner proof requires exactly two constructors with U32 head/same-owner tail;
producer recursively uses the actual Nat predecessor, map/filter use the actual
structural tail, filter selector reconstructs True and aliases False, and fold
returns the original accumulator at empty. The scalar whitelist rejects
arbitrary calls, native hooks, early termination and floating/String operations.
Original primitive emission owns U32 wrapping/mod0, and source operand positions
are retained in the fold update. Producer head and next seed use an immutable
binding of the original seed. Number countdown requires exact native U32.to_nat
of a total scalar U32 operand after the unchanged canonical root guard.

No static semantic blocker was found in fusion. Required execution includes
independent Chain full-width/overflow cases, mod0, noncommutative accumulator,
zero count/nonzero initial accumulator, and sharing/returned/native/demand
refusals. This is approval for checked acquisition, not promotion or a proof.

Owned constructors mark only admitted component/helper source bodies and retain
Ctr shape plus original annotations for shared typing. Emission additionally
requires a closed nonnative ADT, exact constructor name/arity and valid pure type.
Runtime ctor's nonnative branch is exactly `{$:k,a}` and has no registration side
effect; the literal preserves tag/array/fresh-root/child-alias behavior. Shared
j_ctor_args retains erased slots and once left-to-right eager field evaluation.
Unary phase3 reconstruction uses the same resume arguments. The final patch
does not alter constructor_mode: deferred tail builds remain unchanged, so
metadata marker forgery cannot turn deferred construction eager. No static
blocker found; fresh/zero-alias/unary/deep/native/deferred execution remains
required. No runtime/production edits or execution jobs were done by reviewer.

## Flat lexical-clone architecture review

Reviewed `layout/source-proposal.md` prospectively. No architectural blocker if
the proposed negative normalized-emission audit is exhaustive and all-or-nothing.
JPure alone cannot admit layout. Existing j_region_signature indeed requires
native scalar inputs and result. Scoped metadata as a third BookCache child
preserves original lookup index, binder identities and cached planner facts;
fresh j_plan_context currently strips old payloads before preparing the request.

Required holes to close in the concrete patch: inspect actual unary combiner
emission (`j_linear_combiner_emit` can still emit callOwned/get-G), not merely
source/body JCall tags; type-directed JUnpack field reads; exact local clone
resolution for every normalized JCall/JDirectCall and closure; native vector,
pair/tuple bridge and standalone function refusals. Keeping native List `.a`
does not suffice if it can contain a flat user ADT; current ground List proof is
specifically U32-headed. Missing/stale third-child context must stay inactive
and a context tag alone must not become an admission proof.

Lexical same-name clone functions inside the successful proof try block can
shadow original helpers safely in emitted ES modules. Every use must remain in
that block; original declarations outside it and fallback must keep original
ABI. The matched scalar result cannot carry private ADT representation outside.
Request-local exact source definitions must be recovered via lookup, not from
transformed helper bodies. No duplicate full-graph planning is justified.

Sent these requirements to layout owner and root. Suggested independent Tree/
second Stats record/JUnpack and shared-helper flat/public-root cases, alongside
the native/data/observer/partial/backedge refusals in the design matrix. The
corrected renamed helper fixture is calls/fixture-renamed-v2.bend; the original
review fixture computed-match parser failure remains preserved. Concrete flat
patch is not yet available; no acquisition/admission or execution result claimed.

## Concrete flat audit and recursive-shell correction

Root reports a real unary keep_gt1 miscompile in checked03/05 complete-stage
controls: rewriting a combiner containing the worker self call to JDirectCall
hid the original App spine from j_linear_spine, yielding child32/undefined $u0.
Earlier tree-only static/acquisition review did not establish unary parity.
Owner-threaded rewriting preserves every App shell containing the original
worker reference while recursively lowering independent argument expressions.
Static review accepts that shape repair. Owner-thread-v1 also omitted the owner
parameter from j_covered_terms; reviewer flagged the concrete arity/free-variable
error, owner had already delivered the retained arity-fix successor. Root retains
the failed checked06 attempt. No successful rerun is asserted here.

Reviewed layout source-v1 SHA256
`83964233cd5bfea11444130343463fa302baba0e9406bcaaa8de9eaa60df2d2f`.
Its source graph/type, exact guard coverage, direct closure and structural self
checks are conservative; unary nonconstructor combiners refuse. Its normal
proof route matches the actual original j_tree_scope conditions exactly
(fold-root signature, residual helpers, pure graph valid). A speculative concern
about a stronger nonexistent j_tree_scope_valid API was withdrawn after direct
source inspection; no invented scope requirement applies.

Concrete v1 frontier gap: j_flat_local_audit checks normalized locals before
j_region_declarations calls j_region_inline_defs. That late transform can add
JInline/JInlineRead/JVirtual after the advertised negative audit. A nonnative
one-constructor Wrapper containing Tree can pass flat type checks while also
meeting j_region_local_vector. Even if plain late JInline happens to be
compatible, that compatibility was not established by the audit.

Owner retained predecessors and supplied source-v3 SHA256
`527789a02116f7fc5342a583c73b3641b640e7343e12ab835c38236a54b6dcab`.
V3 emits the exact audited locals through j_region_definitions, bypassing late
inline_defs. It also requires direct-call exact graph identity and saturation,
rejects native local JCall targets omitted by declaration emission, and updates
covered-term calls for the owner-aware API. Static review confirms the identified
frontier gap is closed. Native containers are rejected recursively; canonical
native scalar Bool/Nat/U32/F32 remain their original representations.

BookCache child0/child1 and rest retain their original objects/identities; child2
contains compiler-request-local original KDefs only. Missing/stale metadata
is inactive. Public program/library entry always prepares JSPlanContext; reviewer
nevertheless requested inactive flatBook => normal fallback rather than runtime
flat-context invariant failure to preserve uncached backend helper behavior.
No mutable representation test or conversion enters emitted user runtime.

Fixture-v2 has the intended native/data/partial/observer/backedge/container
refusals, but the added ReviewStat is not reached by a positive admitted scalar
root (bench still calls review.score). Reviewer requested stat_bench exercising
review.out/stat/map plus full values/entry witness. The observer negative root
duplicates depth without unrestricted binder; a welltyped refusal fixture needs
that fixed, while retaining any actual frontend failure. Checked acquisition
remains contingent on the final successor and these independent controls.

Correction to the preceding fixture concern: direct read of fixture-flat-v2
lines42–43 confirms bench had already been changed to review.out(review.stat(...)).
The missing-positive claim was a reviewer inspection error. Fixture-v3 adds
explicit stat_bench as a second ordinary positive and fixes the actual duplicated
depth binder issue. Source-v3 acquisition has no remaining concrete semantic
blocker found by static review; checked exact emission, complete values and
hostile boundaries remain mandatory. The inactive-context fallback recommendation
is limited to preserving uncached internal backend behavior, not a claim that
public program/library routes lack JSPlanContext.

## Global closed-type extension concept audit

A global JPure extension to exactly nondependent native Sigma and native
List of closed ADTs can reuse the existing ownership invariant. It does not
require a second runtime proof family: generated values originate in canonical
scalar inputs, the original entire source graph is checked, the unchanged
host/dependency gate opens the proof, and the public component wrapper demands
active proof plus its complete graph coverage. In the finite scalar-root route,
`force` explicitly runs inside the proof try/finally, including build field
thunks and global component dispatch. Returning a scalar cannot retain an
unforced data closure. Ordinary data callers have no proof and retain fallback.

This is conditional on coordinated source changes, not approval of a patch.
Current `j_region_same_type` compares non-List types solely by owner spelling;
it would identify differently specialized Sigma payloads. Current List identity
only accepts the U32 grounded selector. Full normalized parameter and quantity
identity must precede new type admission. Nondependency must reject use of the
Sigma first-field binder, and fuel must be shared through both fields and all
constructor siblings. The active owner-name shortcut remains appropriate only
for existing zero-parameter custom ADTs; native parameterized containers must
not gain a name-only recursive success shortcut.

The independent consumers keep additional gates. Structural fold and producer
admission still requires nonnative zero-parameter owners and U32/self fields.
Flat lexical cloning recursively rejects parameterized native container fields.
Finite and direct helper match gates currently refuse native Sigma and nonground
List even when the surrounding signature could become pure. Retaining those
refusals is sound; widening them requires updating `j_finite_emit_match`, also
used for direct helper emission, alongside the component matcher. A Tuple is a
native array, not a tagged `.a` record. List ground algorithm selection must stay
unchanged. The component origin proof can descend through native container
fields only after exact typed matching confirms the recursive first argument's
owner and parameter identity. No compiler or workload execution was performed
for this concept audit.

Matched native-container candidate02 static review found an aggregate-work
blocker in `j_pure_same_closed`. Its fuel64 is decremented by depth, then reused
independently for both Sigma fields. A compact closed alias family T0=U32 and
Tn=Sigma<1,1,Tn-1,(_)=>Tn-1> has small raw Ref bodies but normalized equality
expands both branches at each level. The raw family shape256 test cannot bound
this alias expansion. Exact-field equality occurs before shared512 type-proof
descent, so that separate type budget cannot bound the expensive comparison.
Requested one shared equality budget across siblings, or an equivalent single
bounded worklist; notified root and facts owner before acquisition.

The accompanying 27-line native emitter patch covers both component workers and
the shared finite/direct backend. Native Tuple binds dense [0]/[1] slots in
original order and drops only the impossible alternate arm of the fully proved
sole constructor; native List retains tagged .a slots. Candidate02 enforces
List quantity2, Sigma quantities1/1 with an unused family binder, canonical
constructor metadata, specialized field quantity1, and exact terminal type.
Sequential candidate04 retains the prior proper-child, exactly-two-self-call,
inert scalar-context constraints and restores parent arguments through a typed
unique result slot before popping its continuation. No further semantic blocker
was found in those matched patches by static review; no execution was performed.

Closed-types candidate03 resolves the equality blocker: `j_pure_same_closed`
wraps Maybe-returning `j_pure_same_check`; first Sigma field passes its remaining
fuel through `j_pure_same_next` to the second field. List descent consumes that
same budget; exhaustion is None. No sibling receives the original parent budget.
The alias-DAG refusal, unequal sibling, and small positive controls remain root
execution obligations, but no acquisition blocker remains in this correction.

Layout source-v5 fixes a confirmed identity-only mismatch: all five flat audit
gates were true and all14 helpers exact, while the annotated selected bench root
differed from the canonical source index. Only after those gates, v5 refreshes
the root entry in the metadata graph from canonical lookup. Full graph guards,
audits, clone bodies and normalized root emission remain unchanged. This is
sound under the existing compiler contract that the selected root is the current
request's annotated canonical root; the refresh itself does not establish
semantic equivalence for an arbitrary forged replacement root. Complete exact
helper coverage remains mandatory, and stale helper/context refusal must remain.
No workload or compiler execution was performed by this reviewer.

Candidate04 Sigma kind correction is limited to exact Typ[Qua1] or
Typ[Min(Qua1,Qua1)], with empty quantity leaves and exact child counts. It
matches the reported native specialization without broadening quantities or
dependency; candidate03 shared equality budget remains unchanged.

The proposed scalar-root generic proof bridge fits the existing architecture.
The current priority is tree worker, region root, U32 worker, then finite root;
region/flat/fusion successes therefore remain earlier selections. Existing
`j_finite_root` already verifies scalar input/result, exact entry permission,
null prior proof, host guard before canonical inputs, full original JPure graph
and full dependency guard, and forces the original generic body inside proof
try/finally. Its useful-work predicate can recognize an independently valid
structural component from that same graph rather than requiring local data IR
admission. This does not require widening fold/list selectors or private local
representation checks. Actual controls must prove worker activation, public data
fallback, complete mutated-dependency refusal, and proof cleanup/reentry; opening
a proof with no measured useful component is not an activation witness.

Concrete `calls/finite-component-root.patch` (+8 lines) matches that bridge:
only the existing non-scalar-signature useful-work branch changes. It admits a
finite selector or a definition with a positive bounded original self-reference
count and a valid canonical component cache result. Scalar signatures remain
excluded by the preceding branch. Root boundaries, graph proof, full guard,
forcing, finally cleanup and emission priority are byte-unchanged. Static
acquisition review found no blocker; activation and mutable inner-callee/public
data refusal remain required execution controls.

Nat.add candidate01 retains exact native Def/db/arity2/dx0/noForeign metadata,
quantity1 Nat/Nat->Nat signature, ordinary residual dispatch, and the original
`checkedNat(a+b)` implementation with maximum281474976710655n. It does not widen
direct or flat native emitters. Its registration change nevertheless has a
concrete pre-import observation gap: adding Nat.add to generic scalarCapture
invokes mutable Object.getOwnPropertyDescriptor, Number.isInteger and
Array.prototype.every during module loading, adding calls relative to the old
module before any runtime guard can refuse. A tracing Number.isInteger wrapper
installed before import is a minimum witness. Requested inert metadata from the
freshly constructed known native wrapper rather than additional mutable-hook
capture queries; candidate01 remains unapproved pending that issue.

Facts owner also identified initial BigInt wrapper reentry: an arbitrary wrapper
installed before import can become the guard's captured identity, then execute
inside an active proof during U32.to_nat. A one-shot callback entering public
ADT code must not inherit worker permission for foreign input. This requires
an actual boundary witness, not inference from unchanged intrinsic identity.
Nat.add itself uses checked primitive BigInt arithmetic without a host call.
Overflow controls must retain original exact error/order and confirm cleanup.
`bad` suspends inherited proof before Error hooks; a reentrant public data call
must fall back, while a fresh fully guarded scalar root may legitimately acquire
its own separate proof. The latter must not be falsely required to stay generic.

Nat.add candidate02 fixes registration observability using local inert
scalarNatAddSnapshot from the factory's fresh own code/bound fields; generic
scalarCapture whitelist and all other native registrations remain unchanged.
That metadata fix passes static review independently of the ownership failure.

Root actual `preimport-bigint-counterexample01` passed viability and broke
seq checked11 versus checked07: proxy inner fold26 became30, and mutation of
G.fold.code observed seven original events versus zero new events. Bridge
promotion is blocked by this actual failure. Public call suspension alone is
insufficient: callbacks can use exported raw G code, and an already running
worker with erased guards can continue stale inherited calls after mutation.
A general repair requires suspension/invalidation/resume checks at external
intrinsic boundaries or unforgeable owned-call permissions through generic
call/bounce paths. Neither is an eight-line policy adjustment.

A narrower scalar prefix staging rule might evaluate host conversions with
proof null, preserve original callee/argument resolution order and resolved
bindings, then acquire full proof for an independently checked remaining pure
pipeline. That requires a concrete new source rule and controls; it cannot be
assumed from arbitrary generic bodies. Reviewer recommends retaining exact
failure and withholding matched bridge promotion. Removing only useful-work
extension may leave new Sigma/List finite selectors activating existing proof
roots; treat the matched extension set as one experiment unless independent
activation audit proves narrower retention. Retained core/flat/fusion require
the same adapted pre-import callback witness before this boundary is claimed.

## Initialization contract classification and reassessment

The preceding unconditional promotion-blocker classification was provisional
and is superseded by direct inspection of the existing published contract.
`docs/BEND-IN-BEND-PERFORMANCE.md:405–406` states: “Standard host intrinsics are
part of the runtime contract; the finite tests do not establish equivalence under
arbitrary replacement of JavaScript builtins.” Git blame attributes those lines
to44a36083 on2026-09-30. Lines413–415 state: “The supported mutation controls
assume standard intrinsics at module initialization”; git blame attributes the
Phase35 paragraph to88619d9c on2026-10-01. Both predate Phase42; the same text is
present in the Phase40 release8582de7. This is an existing supported-environment
boundary, not a newly invented exclusion, weakened gate, or speed waiver.

The executed pre-import BigInt/Math.imul witnesses are viable observations with
real deltas, retained exactly. They install arbitrary host callbacks before
module initialization and therefore fall outside that established contract.
Core-boundary tree BigInt/imul mutation and fusion imul operand-order/dbl deltas
are diagnostic limits, not supported-contract promotion failures. Their existence
must remain visible; no report is relabeled as semantic parity. The inert Nat02
snapshot repair remains useful because it avoids additional registration hooks.

Under standard initialization, successful admitted operations use canonical
immutable intrinsics and cannot call unknown foreign code. Post-import
replacement/getters must fail captured host guards before canonical validation
or proof entry. Nat.add failure retains checkedNat and `bad` suspends proof
before Error hooks, then exception unwinding leaves no private continuation to
resume. With that contract, closedproof04, native matcher, seq04, finite bridge
and inert Nat02 have no remaining static blocker found. Actual supported controls
remain mandatory: exact component activation/full outputs; limits and error
order; public data/raw/partial fallback; changed G binding/code/arity/env/bound
and getters, including Nat.add; post-import host replacement; suspended public
data reentry through Error; proof cleanup; alias/freshness and deep frames.
No new native-family inlining or generic data selector widening is approved.

Validation working-v5 and optional-bst-v2 static review confirms prospective
`reviewed:false` is correct. Optional-v2 still awaits exact strict-native/Nat
owner contracts and frozen successful selected/rootGuard/hostControl lists;
partial BST activation must not stand in for a runtime-assembled actual winner.

Runtime batching v1 preserves45 catalog IDs and669 fresh samples with unchanged
per-case warmup/calibration/target/rounds and balanced roles. Closure requires
complete successful processes, exact identities/protocol and all45 cases once,
and does not infer performance admission. Reviewer found a Node binding gap:
path-only runtime comparison did not bind the timing executable's hash back to
the checked attempt. Immutable v2 successors add Node identity to measurement
receipt and batch plan, rehash at materialization/closure and require the actual
runner's unique Node input identity to match. Static review finds the v2 gap
resolved. An optional earlier realpath equality check for recipe NODE can fail
before timing rather than at closure; the latter already rejects mismatch.
No timing, controller or compiler execution was performed by this reviewer.

Hybrid-flat saved-JS v2 static review found no semantic blocker in the frozen
four-worker discriminator. Exhaustion delegates before state/match demand and
passes current arguments to the original iterative body. Recursive branches
reuse original phase0/phase1/join text, preserve left-right-combine order and
constructor freshness. The lexical function graph includes helpers and rejects
cycles; source integration must establish its own source-based bounded DAG proof,
not derive facts from emitted names. Budget16 resetting across worker edges is
sound only with bounded acyclic interworker depth. Flat-only activation and
original public fallback remain required. Independent controls include full
Tree/St values, uneven/shared arms, aliases and depth30000 iterative fallback.
This is static prototype review, not approval of an unseen source patch or
completion of final checked validation. Root reported a positive screen;
reviewer performed no execution.

Concrete hybrid-source-v1 (+58/-2) static review passes acquisition. Activation
requires flat-active metadata, positive original self references and binary
source shape; original typed component admission already proves independent
proper-child Let3 calls. Covered rewriting preserves own App shells. Phase4
reuses prefix emission; left finishes before right arguments, the combiner uses
original typed let binders and context. Existing j_apply_args emits its trailing
comma, so appending the budget argument is correct. Budget0 delegates before
nested slot initialization or prefix demand to suffix-only original iterative
body. Public/tagged declarations and root guard scope remain unchanged.

An additional DAG DFS is unnecessary here: each admitted component's full
reachable original graph rejects every other definition referring back to its
owner. Any intercomponent cycle violates that existing proof. JPure graph32 and
acyclic bounded direct-helper admission bound reset depth independently of input
tree depth. Actual checked hybrid markers, unary/sequential refusal, complete
values, and depth30000 budget0 iterative fallback remain mandatory controls.

Final-extension-matched-v3 (26 steps/14 groups) static review passes its existing
matched13 scope: exact activated BST/seq selected/rootGuard/host lists; strict
native43 complete observation array and API/runtime/Base/attempt bindings;
Nat10 oracle/9 boundary controls including8 mutation rows, TypeScript overflow
ABI and Error observer proofnull/publicalien0/freshroot2. prepare-final-v2 only
adds selected-attempt runtime/Base substitutions. Recipe remains prospective
until hybrid selection; accepting hybrid requires an actual source activation
and exhausted-budget fallback contract in an immutable successor, alongside
existing layout full-value/deep controls. No execution by reviewer.

Native-owned-v2 (+25 lines, emit-only) static acquisition review passes. Only a
marked original Ctr can select it. Canonical closed Sigma/native Tuple2 emits a
fresh dense pair; canonical closed native List Con2/Nil0 emits the same tagged
+a record; native Bool True/False0 emits the original primitive value. Exact
closed-type proof retains quantities and constructor metadata. Shared original
specialized j_ctor_args preserves evaluation order, erased slots and aliases.
Constructor_mode deferred build handling, nonnative owned gate and unary resume
logic remain unchanged; Nat/String/Array and other native families refuse.
Public/unmarked expressions cannot activate this path.

Existing BST216 full Tuple/List controls,24 pointer aliases, three deep shapes
and strict-native43 can validate behavior without a duplicate test framework.
The final selected source still needs checked private literal activation and
residual native ctor counts plus unchanged public worker bytes, bound to the
final attempt. Matched-v4 hybrid contract (28 steps/15 groups) explicitly adds
actual checked source activation, exact budget16, original iterative body hashes,
84 values/10 aliases/two deep cases, minBudget0/fallback2 and proof cleanup.
prepare-final-v3/close-release-v2 add only explicit derivationField selection
with unchanged exact derivation digest comparison and backward-compatible
old default. Static review finds no blocker; preserve v4 as a predecessor if
native15 selection requires a successor. No reviewer execution.

## Final selected15 review

Independent final review approves marking exact final-extension-matched-v5
reviewed and beginning mandatory final validation. It has29 steps/16 owner
contracts and all prior native/Nat/flat/hybrid behavioral requirements. New
native-owned assay assertions exactly match the passing checked15 report:
Tuple12/Con8/True4/False4 calls become zero; denseTuple12/taggedCon8/Boolfields8
appear. All bytes outside the six admitted private bodies retain identical
masked hash87865525935074f022c49597bfb130fe6b589c45b8edd582d27020bdde3f8283.
Exact file-output execution binding is checked by close-release-v3; preparation
v4 routes and pins that successor. Fixed selected15 attempt/API bindings prevent
rebinding this contract to another image.

Ten touched backend/runtime files, including assembled runtime, were independently
read and byte-compared to checked15 snapshot; all are exact. Evidence is
review/final15-source-identity.json and review/final-selected15-review.json.
The latter records draft extension SHA c8a52b9dc731e811e79d88bdabc398a39a90e986dbad368a81b00166dd4d4e1e
and contract SHA excluding only reviewed flag
ac3770a909d5565342d49f7cc20486141f6f1ace8a534d92219ac8315152b7f1.
Validation owner may toggle that flag with contract fields unchanged. Broad,
performance, compiler-cost, ordinary/relocated CLI and install gates remain root
execution obligations. This static review is not a claim those gates ran.
No reviewer compiler/target execution or production edits were performed.

Final prefreeze correction: root found that native-owned15 also changes exactly
two private flat bsort Bool constructor sites. The raw checked13 iterative body
therefore differs from checked15 fallback, so v5's inherited strict hybrid raw
byte-identity assertion is unsatisfiable. The selected15 source review and
behavioral reports stand; the v5 contract attestation is superseded pending an
immutable hybrid witness/contract successor. prepare-final01 was materialized
but no semantic execution began. Preserve v5 and that materialization history.

Reviewer supports exact AST normalization of only zero-argument
ctor('True',[])/ctor('False',[]) at those two baseline13 bsort body sites for the
identity witness. Keep executable original13 module byte-identical, so full
value/alias/deep controls still compare genuine compiler outputs against15.
Record rawbaseline, normalizedtemporarybody and candidateraw hashes plus exact
two site positions/kinds; other three fallback bodies remain raw-byte identical.
Retain the prior strict13->14 fallback witness and exact native Bool header proof.
This is a controlled semantic normalization, not a claim that raw13==15 or a
fabricated checked executable comparator. New final contract must bind all
witness inputs and actual control outputs before renewed reviewed marking.

Hybrid actual-derive-v2 narrow witness review passes. Temporary baseline bsort
body normalization is exactly one True and one False empty-field ctor call;
raw baseline3aaa8da35c3b60519210ee25dd3f12f610ae7ad0bd4f307f777bc118879f155b
normalizes to d83a345707a44867bb1411cee4500738e3133d178f808785939a944e351ede68,
which equals actual15 fallback raw body. Exact candidate literal AST starts,
values and text are checked. Other three fallbacks have zero normalized sites
and raw-body equality. Baseline executable files remain exact originals;
normalization is explicitly unchecked parentChecked nonexecutable metadata.
The old console unchangedIterativeBodies4 label counts three raw identities
plus one controlled witness and must not be read as four raw-byte identities.

Layout actual-source-controls-v5 likewise passes static review. The old v4
failure came from labeling private global bsort body identity as public worker
identity. V5 compares that entire private function against only two exact AST
Bool substitutions; the other four private functions remain raw-byte identical.
It separately asserts all five actual public G assignments raw-byte identical.
Baseline execution is untouched and full20/98/68/deep assertions remain.
This corrects identity accounting without relaxing behavioral gates. Exact
normalization receipts and new identity flags must enter final contract after
root's successful v5 control report. Original v4 stderr remains historical.

Final selected15 v6: independently matched exact layout v5 assertions to layout-actual15-retry01 PASS and hybrid v2 bindings to actual15 derivation. Executable baselines are unchanged; exactly two AST-proved zero-field native Bool comparison sites are normalized, whole expected bodies must match, other workers and all actual public bindings retain raw identity. Original checked14 strict witness remains required. V6 supersedes v5 approval; fresh final gates remain mandatory. Attestation: `selfhost/tools/performance/phase42/review/final-selected15-review-v6.json`.

Final inherited vector preflight found real source regression: shared equality routed original Sigma2/2 vector states into the new Sigma1/1 closed head. Thirty-five fallback oracles passing did not discharge mandatory optimized admission. Reviewed exact five-line equality-domain split: restore original Phase41 fold comparison; JPure Ann/Var/call-result use strict closed64 comparison directly. This retains legacy vector policy under original local-type proof and strict new container ownership. Fresh source16 validation required; selected15 receipts remain historical. No controller relaxation. See `review/equality-domains-v1-review.json`.

Final selected16 v7 approved statically after root fresh counter35/5+Number admission, strict native43, and Phase40/41 actual-tree focused passes. Exact5-line equality repair and5 inherited instrumentation replacements reviewed; ten relevant canonical sources byte-identical checked16 snapshot. Native proof successor changes only dedicated equality API and explicit64budget, preserving43 assertions. Historical14/15 normalization/schema witnesses remain labeled historical; fresh selected16 owner closures and all release gates mandatory. Review: `review/final-selected16-review-v7.json`.

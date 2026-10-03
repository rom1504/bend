# Phase42 generated JavaScript architecture

This reference describes the selected checked16 compiler source. Qualification,
measurement and installation status belong to the
[Phase42 implementation report](../implementation/phase42/README.md).
The [performance guide](BEND-IN-BEND-PERFORMANCE.md) defines the maintained host
contract. This document explains lowering decisions, not benchmark outcomes.

## Entry proof and private calls

[region.bend](../selfhost/src/back/js/region.bend) builds a typed scalar-root
region; [jpure.bend](../selfhost/src/back/js/jpure.bend) supplies `JPure` graph
and direct-helper plans. The ordinary public entry validates canonical scalar
arguments, original dependencies, callable metadata and captured host intrinsics
before opening a private proof. Its generic branch remains available. Raw,
partial and foreign entry do not acquire ownership merely by naming a function.

[tree.bend](../selfhost/src/back/js/tree.bend)'s `j_covered_term` rewrites
saturated component edges only when exact original definitions are covered by
the current graph. `j_direct_term` handles separately admitted small acyclic
helpers. These transformations avoid repeated closure dispatch and dependency
checks within one admitted operation. They do not cache host bindings across
public calls or make arbitrary source purity an ownership proof.

The rewrite threads the structural owner name. An original application shell
containing that owner's recursive reference stays intact for continuation
classification. Annotation values may change; annotation types remain original.
Partial calls, escaped functions, unsupported effects and uncovered backedges
retain their existing path. Expansion fuel bounds helper lowering.

## Owned construction and flat lexical graphs

`j_owned_term` marks eager constructors within proved private bodies.
`j_owned_ctor` checks their exact nonnative owner and constructor type before
emitting the existing tagged object with `a` fields directly. Typed argument
emission preserves evaluation order, erased slots, fresh allocation and aliases.
Deferred constructors continue through their existing generic representation.

[emit.bend](../selfhost/src/back/js/emit.bend)'s `j_owned_native_literal`
separately checks closed native ABI proofs before emitting Tuple arrays,
tagged Nil/Con objects, or Bool literals. This is not a generic native-family
shortcut: constructor identity, arity, quantities and grounded field/result
identity must satisfy `j_pure_closed_list`, `j_pure_closed_sigma` or the exact
Bool gate. Nat arithmetic and native String/Array families are not replaced.

Flat representation has a stronger boundary. `j_flat_root_select` audits the
entire normalized scalar-owned graph, local definitions and exact guard
coverage before `j_flat_root_emit` creates lexical private clones. Constructors
use one fresh tagged object with `_0`, `_1`, ... fields; reads use those fields.
The root arguments and result remain native scalars. Private ADTs cannot cross
an unsupported generic observer, constructor, call or public result boundary.

The emission audit includes structural unary-combiner paths and direct-call
saturation. Audited locals emit through `j_region_definitions`, avoiding a later
inline pass that could introduce unaudited nodes. Generic observers, returned or
public ADTs, callbacks, vectors and String/List crossings refuse this flat route.
Closed native components have their own proofs; they do not automatically join
flat user-ADT graphs.

`JSFlatContext` is request-local BookCache metadata. `j_flat_active` requires its
exact shape, original graph identities and existing `JSPlanContext`; missing,
stale, duplicate or malformed payloads select the normal route. Canonical root
identity is refreshed only after full audit of the selected root. This does not
assert equivalence of arbitrary forged root bodies. Public `G` bindings retain
the generic ABI; private global structural workers also retain array fields.

## List fusion

`j_fusion_root_body` in
[region.bend](../selfhost/src/back/js/region.bend) recognizes an immediately
consumed closed producer/filter/map/fold chain. It proves the original empty/link
owner, canonical U32 heads, structural Nat predecessor, recursive reconstruction,
selector and ordered accumulator update. Its scalar whitelist admits only total
native U32 operations with their existing wrap and modulo-zero semantics.

One loop computes the original head and next state, applies predicate and map,
and updates the fold accumulator in source order. A Number countdown requires an
exact U32.to_nat operand proof. Other Nat counters keep their existing distinct
bounds. Let-bound, retained, returned or shared intermediates and unsupported
scalar operations refuse. Purity alone does not justify changed traversal demand.
The public entry proof and fallback are retained.

## Structural continuations and bounded recursion

`j_sequence_context` and `j_sequence_finish` in
[tree.bend](../selfhost/src/back/js/tree.bend) admit sequential proper-child
continuations. Saved arguments, completed child values and resume phases preserve
prefix, child and reconstruction order. This supports down/up/inorder components
without relying on unbounded JavaScript recursion.

For eligible binary components inside an already admitted flat graph,
`j_hybrid_declaration` emits a wrapper, `$hybrid` body and `$stack` body. The
wrapper starts budget16. At budget zero, the hybrid calls the original iterative
worker with current parameters before any source prefix or field demand.
Recursive children decrement budget; their evaluation and combination order
remain original. The full graph excludes intercomponent cycles, so resets do
not permit input-dependent unbounded native recursion. Other components retain
the iterative emitter. Generic fallback has its own existing stack behavior.

## Exact facts and type-proof domains

`j_program_selected` and library preparation in
[emit.bend](../selfhost/src/back/js/emit.bend) create one request context.
`j_component_cached` and `j_direct_cached` in
[jpure.bend](../selfhost/src/back/js/jpure.bend) reuse canonical planner results,
including ordered graphs, remaining fuel and failure validity. BookCache child0
remains the source index; child1 carries `JSPlanContext`; flat context adds child2.
Original binder identity and source lookup are preserved. Fresh request preparation
strips old facts, and `book_put` in [index.bend](../selfhost/src/core/index.bend)
discards them. Missing facts run the unchanged logical planners. Runtime host
checks and coverage are never memoized as compiler facts.

Keep two equality domains distinct. `j_region_same_type` in
[fold.bend](../selfhost/src/back/js/fold.bend) retains legacy region/vector policy,
including its existing quantity-2 vector admission. `j_pure_same_closed` uses a
shared bounded work budget for strict closed-container annotation, variable and
call-result identity. The latter proves quantities and grounded native payloads;
it must not replace the former by blanket delegation. Work exhaustion refuses
new proof or reduces cache reuse, rather than weakening identity requirements.

## Runtime boundaries and maintenance

[core.mjs](../selfhost/src/runtime/js/core.mjs) owns `regionHostGuard`,
`localGuard`, `regionProofOpen` and proof cleanup. Supported post-import binding,
code, metadata and getter mutations must refuse the affected private entry.
Error observation suspends private proof so reentry cannot borrow stale coverage.
Standard captured intrinsics at module initialization remain a documented
assumption; arbitrary host callbacks installed before import are outside that
contract. No universal stack safety or all-native-family specialization is claimed.

Changes to admission should validate ordinary-root activation, complete
intermediate values, allocation/alias behavior, hostile demand traces and proof
cleanup as well as scalar results. Deep witnesses must demonstrate actual stack
fallback. Exact source and representation boundaries matter: a private global
worker is not the public `G` binding, and an identity-only comparison string is
not an executable baseline. See the
[implementation report](../implementation/phase42/README.md) for canonical evidence.

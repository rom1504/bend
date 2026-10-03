# BST stretch: exact private containers plus sequential continuation

This remains a design and cheap falsifier proposal. No native-domain patch is
applied or built. The held sequential candidate is independent and cannot
activate in the unchanged BST benchmark while its root graph refuses native
containers. Complete scalar-root proof, private type proof and native match
emission must be evaluated as a matched set before claiming any BST gain.

## Exact admitted type relation

Keep existing `j_pure_type`, `j_region_same_type` and `j_list_ground_type`
contracts intact for ordinary callers. The grounded U32 List predicate also
selects algorithms and must not become a general container predicate.

Proposed names are `j_pure_closed_sigma(book,ty)` and
`j_pure_closed_list(book,ty)`, backed by one bounded shared-fuel closed-type
visitor. They extend the existing recursive user-ADT domain only in an explicit
private owned proof mode. Every user owner still requires canonical source
identity, no parameters/templates, nonnative closed quantity-2 Data, all
constructors, and recursively admitted nonerased fields. Scalar leaves retain
their current exact native ABI proofs. String, Char, Array, functions, foreign
and unknown native types remain refused.

Native List requires the actual List owner/constructors, exact two type
arguments, quantity 2, no removed fields, admitted closed element and exact
specialized Nil/Con telescopes with the source's quantity-1 data fields. The
terminal result must equal the complete List specialization. Recursive active
entries include element identity; visiting List<A> does not close List<B>.

Native Sigma requires exactly four arguments and the original single native
Tuple constructor, arity2, no templates/removed fields, two independent closed
field types and initially no erased fields. Verify actual kind/field quantities
against the original checked Base; do not guess from owner spelling. Normalize
the second family and require a Lam whose binder is unused in its complete
body. Check independence before reducing an application at a sample first
value. Check the specialized Tuple telescope's two field types, quantities and
complete terminal Sigma result against the admitted specialization.

The new `same_type_owned` relation compares normalized admitted structures:
scalar native identity, closed user owner identity, List quantity+element, Sigma
both quantities+both independent field types. An unused Sigma family binder can
be renamed freely because it occurs nowhere in its body. No general alpha
comparison for open dependent types is necessary in this deliberately closed
domain. A function/open Var is refused before equality. Compare under one
shared bounded fuel, with exact active pairs; exhaustion is refusal. Existing
name-only Sigma comparison must not be reachable in this domain.

## Scope and request facts

The safest first scope is explicit ordinary/owned proof modes, retaining the
ordinary functions as default-mode wrappers. Thread mode to purity signatures,
expressions, match/constructor/call arguments and specialized equality. Existing
ordinary source emission and proof callers keep mode false. Only a scalar-input,
scalar-output root may request owned mode; scalar validation happens before any
ownership-sensitive lowering. Its owned graph must check every canonical source
body and all helper dependencies before opening the existing region proof.

Private component/direct/finite prefix variants may then use the stricter owned
container predicates. They emit only calls guarded by complete graph coverage.
A standalone ADT-taking public entry still follows generic dispatch; exporting a
private declaration does not grant ownership. Generic residual code can remain
inside a proved root only when every residual source operation is in the closed
domain and existing host/protocol/descriptor guards hold. No callbacks/foreign
hooks can enter that proof or supply an external container.

Do not store these results in the ordinary component/direct request facts:
normal and owned plans are different obligations. Give owned plans a dedicated
cache namespace/mode key under the same per-request metadata, or initially avoid
caching owned plans. Keep exact original ordered graph, remaining fuel and
negative plans for each mode. Cache misses may repeat proof, never widen scope.
Root-created runtime values are not a compile-time cache fact.

This explicit threading costs more than a global whitelist but makes scope
reviewable. A hidden request flag silently changing all existing logical
planner contracts would be smaller and riskier; it is not proposed. Preparation
must never derive proof authority from a graph superset or transformed terms.

## Native emission boundary

Frames owner confirms the existing runtime representations: Tuple is a native
length2 dense JS array; List is tagged {$:'Nil'|'Con',a:[head,tail]}. No runtime
change is needed. An owned native Tuple prefix must use one transparent arm and
`arg[0]`, `arg[1]`; existing generic private match emission's .$ and .a are
incorrect for Tuple. Full typed coverage plus exact sole-Tuple proof justifies
skipping runtime Array.isArray; externally supplied arrays never enter.

Native List retains current tagged matching and .a projections; only its
private admission predicate changes. Initially retain the existing generic
`ctor('Tuple',[...])` construction (which already returns the native array).
A later direct-array constructor optimization is independent. Preserve original
field evaluation/force order and generic reconstruction before trying it.
The generic runtime's Tuple build/force is not replaced by new eager work.

Existing single-self workers can handle down/up after these proofs and
match fixes. The actual original probe also finds build prefix false: its
computed sequential scalar let is outside j_linear_alias (atom-only RHS).
Build can remain generic residual under a complete owned root proof; admitting
its computed alias would be a separate small proof/phase experiment; acyclic step/pick can use direct or finite plans if their existing
term proofs pass. Wrapper self-cycle refusals remain as residual generic calls.
The separate 63-line sequential inorder proposal reuses phase2/phase3 and pops
the saved continuation before outer tail transfer. It needs no native shape.

## Estimated implementation and first falsifier

A rough source estimate, not a commitment or built diff:

| Work | Added/changed LOC estimate |
| --- | ---: |
| Bounded closed List/Sigma proof and exact owned equality | 110–180 |
| Explicit mode threading/default wrappers and owned root selection | 90–150 |
| Native Tuple match/projection and private List prefix admission | 35–70 |
| Owned fact namespace or initial uncached plan selection | 25–60 |
| Held sequential continuation | 63 |

This is roughly 320–520 LOC plus tests. It is a Phase42 stretch, not a safe tiny
late integration. Exact estimates should be revised after the original probe
reveals additional prefix/term obstacles. Probe02 already found build
computed-alias refusal; a separately bounded total primitive alias grammar
would add approximately 20–40 LOC if promoted, but is optional for first entry. No blanket persistent cache, general
IR or runtime rewrite is justified.

The cheap first falsifier is the original predicate probe: require inorder's
pure graph valid with leaf/prefix refusal, native Tuple/List-frame type refusal,
and no unexpected user helper backedges. Then an ephemeral compiler API overlay
may implement the *complete* bounded owned predicate/equality and native prefix
emission only in a diagnostic module. Compile the unchanged original BST source
at small size, retain full identities and generated JS, and instrument root
proof opens plus down/build/up/inorder private entries. A type-only overlay is
not executable evidence. Root owns execution and fresh output folders.

Before any timing, exact complete-value controls compare every tree node/tag,
ordered zipper frame/value/side, pair components, partial-fuel states, rebuilt
trees and final U32 result against original generic saved JS. Start with 0/1/7
sizes, duplicates, both skew directions and partial fuel, then retained32/64
catalog cases. Instrumentation must show actual entry; zero-entry correctness
cannot justify promotion. Separate changed descriptor and Array/prototype
protocol controls require zero entries and exact generic outcomes.

Independent compiler negatives include List<function>, List<Array<U32>>,
records containing function/vector/dependent Sigma separately, dependent Sigma
family variable under nested annotations/type arguments, mismatched Sigma and
List instantiations, quantity/constructor metadata mismatch, erased fields,
removed fields, free variables and shared-fuel exhaustion. All must refuse the
new owned predicate independently of the old predicate. A closed constructor
cycle with a forbidden sibling must not be discharged merely by an active name.

Rank this above an effectful String SCC experiment for production feasibility:
its native representations are host-free under existing ownership/protocol
checks and the helper graph needs no mutual recursion machinery. Payoff remains
unmeasured; even real worker entry does not imply removing the historical full
BST gap. The first surviving generic residual cost must be measured before
expanding scope.

## Observed original predicates (root probe02)

Root completed the original API probe against checked07 in about six seconds.
Status ok/checked true is recorded in the retained report, summarized without
mutating root raw in bst-probe02-summary.json. Inorder has valid pure graph
["inorder"], remaining fuel32748, two self refs and rejected prefix/component.
Bench's full pure graph fails. Down prefix passes but signature/capture fail.
Up signature/capture/prefix fail, with two self references across distinct
branches. Build signature/capture pass but prefix fails independently of its
failed helper closure (computed sequential scalar let). Pick prefix passes,
step and insert.fin prefixes fail; native Tuple emission is still needed.

BST/BFrame pass type proof; Sigma and ListFrame fail; Sigma's existing local
header passes while local field proof fails. All independent function/vector/
dependent Sigma nested controls refuse. Mismatched Sigma specialization
comparison currently returns true, confirming the quarantined equality hazard;
mismatched List comparison returns false. These observations constrain the
new implementation and do not validate an unimplemented predicate.

Current source has a third BookCache payload for layout facts alongside source
index and plan facts. Any owned namespace must coexist without positional
assumptions that discard/misread that payload; ordinary caches never imply owned
proof authority. Initial uncached owned planning is the simpler stretch option.

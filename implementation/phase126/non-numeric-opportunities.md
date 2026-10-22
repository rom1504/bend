# Phase126: nonnumeric composition opportunities

Offline audit of the qualified Phase125 source06 products. No compiler, generated
program, build or profile was run for this note. Phase122 samples below are
historical attribution, not refreshed Phase125 measurements. The current score
is 1.89221× upstream over 44 comparable points; 40 exceed 1.1× and 24 exceed 2×.
Inputs and exact generated-file hashes are in
`selfhost/build/phase125/broad-emission06.json` and
`implementation/phase125/results.json`.

## 1. Preserve a consumed constructor across a closed local reconstruction

**Observation.** This is a remaining concrete difference from upstream, even
after the sized Phase125 runtime helpers. In frozen `tree-bitonic.bend:45`,
`warp_zip(Node(a,b),Node(c,d))` produces
`Node(Node(a,c),Node(b,d))`. Current
`selfhost/build/phase118/p125-verified-families06/tree-bitonic.ssa:692` and `:703`
call `p125_rt_take2`; `:714`, `:724`, `:730` call `p125_rt_ctor2`. Upstream
`selfhost/build/phase93/broad01/tree-bitonic/upstream.1.c:1384` (`spin_5`)
reads both nodes, reuses their two locations, and allocates only the outer node.
Thus each successful local shuffle has two removable free/allocate pairs.
This is a work-count statement, not a predicted timing gain.

The machine consequence is real rather than just verbose QBE: the frozen
`phase125/machine/verified-p125_rt_take2.asm` performs metadata/tag/RFC dispatch,
copies fields to scratch, and changes the freelist on the unique dynamic path
(`a160`–`a18e`). `verified-p125_rt_ctor2.asm` then enters allocation again.
The report `phase125/machine/runtime-report.json` counts 91 instructions/11
conditional branches for take2 and 62/9 for ctor2 across their complete bodies;
these are **not** executed instruction counts or a claim that every branch can
be removed.

There is an even smaller seed with no mutable reuse at all. `flow(0,s,w)` returns
the unchanged tree by destructuring/rebuilding it. Current tree QBE
`:11954`–`:11963` still takes a Node and constructs the same Node in the same
field order. Replacing that closed branch with the original owning value
removes both operations, works for shared/static inputs, and needs no credit
word or runtime uniqueness check. This also avoids touching packed Leaf
representation, which is already present.

**Smallest general rule.** At the checked constructor-match boundary, recognize
an exact return of the matched constructor with its original field variables,
each once and in declaration order, with no other live uses or effects. Retain
the tag branch and its fallback, but return the original owner instead of
consuming/rebuilding it. Authenticate the constructor and full live arity;
reject permutations, changed fields, bangs/duplication, ownership transfers,
effects, unknown helpers and dependencies. Scalar copy/annotation aliases may
be normalized only with an explicit bounded equivalence proof. This is a
constructor identity law, distinct from Phase125's two primitive identities.

Only after that seed is measured, consider a **closed local constructor region**:
load all fields before any mutation; prove exact linear field accounting;
pair consumed cells with same-layout constructors inside the region; use a
raw-dynamic-unique fast path and the untouched original path otherwise. No
credit crosses a call, recursive backedge or continuation. This would address
the warp shuffle and potentially tree/map rebuilding. RFC1 support is a later
separate proof, not implied by affine source syntax.

**Why not repeat Phase118?** Generic TRMC reuse credits added a hidden value,
out slot and dynamic matching on recursive paths: about197→210ms, then196ms
with the revised ABI (`phase118/trmc-reuse-audit.md`). The proposed identity
seed has none of those costs; the larger local-region hypothesis must still
beat its own guards. Existing ownership-heavy profiles do not establish that
it will. Tree-family Phase125 positive excess is about12.6% of the corpus;
the 17.9% take and16.0% constructor historical tree samples are upper-level
attribution, not an additive realizable speedup bound.

**Falsifier.** First count actual admissions of exact identities in tree,
records and an unrelated renamed retained-alias control. Compare the same
frozen outputs and runtime with only that rule enabled. For the larger region,
one renamed two-input tree reshape with shared/static fallbacks plus the real
warp case suffices: require two fewer allocation/free pairs per successful
shuffle *and* a clean timing benefit before adding cross-call support. Preserve
the original benchmark; the diagnostic source/IR variant is a ceiling only.

## 2. Extend root-preserving observation to binary maps before inventing a cache

**Observation.** Current Map operations consume/rebuild roots to read them.
`bend2/base.bend:2701`–`:2726` (`Map.seek.go`/`Map.seek`) return the unchanged
map, searched key and optional found key; `:2755` then calls this from `Map.set`.
Current map QBE `coverage-map-churn-128.ssa:18386` is still a public scheduler
entry. Its MNode branch `:18459`–`:18481` takes the root, keeps `pos`, rebuilds
the root, and saves it while computing the routing bit. Its recursive seek
body starts `:15829`; the separate update traversal `Map.put.go` starts
`:28215`. This is not an already-selected immutable observer.

The admission boundary is explicit: native `observer-layout.bend:99`–`:108`
requires exactly two root constructors, one nullary; `:82`–`:89` requires
exactly one recursive field and scalar companions. Map has three constructors,
two recursive children, owned key payloads and an erased type parameter. Thus
relaxing one constructor-count check would **not** safely enable it. Existing
String observer success does not prove Map's shape or returned ownership.

**Hypothesis.** A typed, root-preserving observer certificate for an acyclic
binary ADT could remove path reconstruction and associated scheduler work from
lookup/seek while preserving the owning root. A returned found key requires
an owned keep, not an escaping borrowed pointer. Root aliases remain legal
because the observer is immutable and retains a dominating owner. Unknown
effects, indexing/dependent fields and unproved helper cycles stay refused.

This has better prospective transfer than a source-name optimization: record
aggregation performs `Map.get` followed by `Map.set` for every record
(`coverage-record-aggregation-256.bend:23`–`:33`), map churn uses repeated set,
and evening uses maps. Phase125 map, records and evening together account for
about18.3% of positive excess, but those entire workloads are not map lookup.
Historical map profiles also contain String routing and ownership work that
this would retain. No compiler-hot Map use was established by this audit.

**Falsifier.** Before broadening the observer domain, isolate a read-only
binary-map search returning `(originalRoot, completeObservation)` and compare
an independently checked borrowed implementation, with retained root/interior
key aliases and a missing-key case. Count eliminated root reconstructions.
If it wins, incrementally extend schema and ownership verification together.
Saving the search path across get→set could avoid another traversal, but is a
larger cursor/zipper ABI project; defer it until read-only preservation pays.
Do not substitute a benchmark-specific host map or change map ordering.

## 3. Eliminate iterations after a proven absorbing state

**Observation.** This is a cheap ceiling experiment but narrower transfer.
`coverage-bst-64.bend:36` returns the unchanged state when its tree is BLeaf;
`:50` nevertheless iterates for all fuel, and the wrapper `:136` uses size+1
fuel per insertion. The current `$product.bst.down` already flattens state and
inlines step: QBE `:1497`–`:1510` recognizes BLeaf without allocating, then
`:1649`–`:1661` still decrements/backedges. Therefore another tuple-flattening
proposal does not address this branch. Upstream C `spin_6:1426` also retains
the fueled loop, so early exit could improve both implementations rather than
merely recover upstream's layout.

For N inserted nodes the existing loop performs N(N+1) step iterations. A
semantically equivalent early exit would perform the sum of actual descent
lengths plus bounded state tests. Exact savings depend on seed/tree shape;
no traversal counts were collected. Phase122's historical 30.7% samples in
`$product.bst.down` include useful descent/allocation, not only idle steps.

**Smallest legal rule/falsifier.** A pure finite-count tail loop whose selected
constructor branch returns all state components unchanged and cannot observe
the remaining count can return immediately on that branch. Prove that all
future steps remain in the same branch; reject effects, changing hidden
accumulators, count-dependent final results and nonterminating counters.
Start with an ordinary source ceiling preserving the wrapper and full output,
plus an unrelated absorbing-state machine and deliberate negative cases.
Do not prioritize a generic fixed-point pass if only this benchmark benefits.

## Recommendation and limits

Test exact unchanged-constructor cancellation first: its proof and experiment
are small, and it removes ownership operations instead of making them a little
cheaper. The closed local reshape is the ambitious extension with concrete
upstream evidence; the binary observer is the next broader composition
capability. These are hypotheses, not demonstrated Phase126 gains.

Do not repeat the nested-Sigma rewrite (Phase123 explicit-state ceilings only
10–14%; the narrow alias-sensitive rule did not activate), map-list/tree-fold
fusion (Phase121 approximately742→741ms), or generic reusable-cell credits.
The strongest missing evidence is dynamic eligible-site count and retained
runtime share after the numeric/local-resume work, not another broad profile
or full self-hosting campaign before a local experiment establishes value.

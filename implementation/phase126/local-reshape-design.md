# Closed tree reshaping: bounded ceiling investigation

**Finding:** the category is real and local, but a suffix-only take/ctor rewrite
is not sufficient. A guarded whole-worker companion is a cleaner first test.
No target/compiler/build was run for this investigation. The runtime and source
recognizer are isolated prototypes, not installed/compiler-integrated features.

## Exact evidence and work ceiling

Frozen `tree-bitonic.bend:45` has the equation
`zip(C(a,b),C(c,d)) = C(C(a,c),C(b,d))`. Current Phase125
`p125-verified-families06/tree-bitonic.ssa:678` contains the complete private
worker. On its successful path, `:692` takes the first two fields, `:698`–`:701`
tests the second constructor, `:703` takes its fields, and `:714/:724/:730`
construct three two-field Nodes. Between these operations are only local
copies, tag comparisons, scratch stores/loads and branches. There is no helper
computation, continuation, recursive call, effect or field escape in that path.
Other branches sink original children and return Leaf0.

Crucially, the first take precedes the second constructor test. By the final
three constructors, the original shells have already been released. A local
peephole cannot simply reuse their old addresses. The success region must
start **before** the first consume, or take must gain a new ownership protocol.
The latter recreates the complexity that the earlier credit experiment tested.

Upstream C `phase93/broad01/tree-bitonic/upstream.1.c:1384` (`spin_5`) loads all
four fields, uses the two consumed locations for the inner output nodes and
allocates only the outer node. That is the exact intended work removal.

For a complete input of depth k, `warp` invokes zip `W(k)=2^k−1` times.
For `flow(d)`, `F(0)=0` and `F(d)=2W(d−1)+2F(d−1)`.
For `bsort(d)`, `S(0)=0` and
`S(d)=2S(d−1)+W(d−1)+F(d−1)`; consequently
`S(d)=2^(d−2)(d²−3d+4)−1` for d≥2. Separately the original source executes
`A(d)=2^d(d²−d+2)−2` Node constructions, including identity reboxes in flow.

| Frozen depth | zip successes per bench | Original Node constructions | Maximum eliminated Node allocations | Fraction |
|---|---:|---:|---:|---:|
|6|351|2,046|702|34.31%|
|8|2,815|14,846|5,630|37.92%|
|9|7,423|37,886|14,846|39.19%|

These are source-structure counts conditional on the existing full-tree paths,
not executed counters or speed estimates. Actual dynamic allocation savings
equal twice the number of raw-unique helper successes. Shared/static/RFC
fallbacks, packed leaves, all other compiler work and the source wrapper stay
unchanged. Later identity removal changes A(d); preserve the Phase125 baseline
when interpreting this ceiling. `ceiling.json` pins the independent recurrence
calculation and original corpus inputs.

## Smallest safe mechanism

`phase126/local-reshape/runtime-prototype.c` supplies a raw-only helper:

```
try_transpose2(state, owned_left, owned_right, authenticated_CID)
  -> nonzero owned result on success; zero and original ownership on refusal
```

It first checks the declared two-field constructor layout, then both exact tags
and CIDs, no RFC bit, dynamic locations and distinct shells. Every rejection is
read-only. Only after all checks does it snapshot all four fields; it places
each exactly once in the two reused shells and calls the ordinary constructor
for the outer node. Ordinary constructor sealing policy is retained for each
field and for the two inner nodes. There are no dangling credit cells, recursive
arguments, continuation captures, temporary out-pointer ABI or free-list
transfers for the reused shells.

Raw ownership is essential. Two checked owning raw roots cannot also have a
live external owner of the same payload; legitimate duplicated roots/tails use
the runtime's sharing representation. The helper explicitly refuses equal
locations as an additional guard. Read-only retained child/payload aliases are
legal: fields themselves are transferred without changing their reference
counts. Never infer that raw bits from arbitrary foreign/unverified terms prove
ownership. Preserve the original source/IR semantic and runtime identity gates.
No shared/RFC1 mutation or GPU/parallel qualification is part of this prototype.

The helper can be wrapped around the **complete original worker**, before any
consumption. It recognizes both root constructors itself. If zero is returned,
call the untouched original worker with the original arguments; otherwise
return the owning result. Zero is a safe refusal sentinel only because an
authenticated ordinary ADT Node result has a nonzero constructor tag.

`recognizer.bend` is a name-independent, analysis-only source certificate for
the exact successful equation. It checks two nested constructor matches,
four distinct live field binders, the exact linear output permutation, and
two matching closed ordinary tree input/result types with a two-recursive-field
constructor. Syntax/type budgets are bounded. It does not inspect or change
failure branches. Export `p126lr_inspect(request,name)` for a cheap checked
request query before integrating anything. Actual checked source shape has
not yet been queried; an eta-expanded matcher may conservatively refuse.

Missing implementation deliberately remains small and explicit: choose the
authenticated source function's original public-forwarding candidate; wrap it
using fresh private locals; add the exact helper import signature and CID/arity
verification, following the Phase125 append pattern. Preserve the independently
verified original program and complete fallback. There is **no selected hook**
or verifier relaxation in the delivered prototype. Do not call it an automatic
optimization until this integration and the source admission are demonstrated.

## Decisive experiment and rejection rules

1. Query `warp_zip` and the unrelated renamed `hedge.cross` ordinary fixture.
   Reject altered output fields, reversed/missing fields, nonrecursive/unknown
   layouts, additional effects and ambiguous source shapes before emission.
2. Compile the unchanged frozen tree and independent String/tree fixture with
   only this companion enabled. Do not modify benchmark arguments or timing.
3. Count successes/refusals and allocations in a diagnostic runtime. Require
   exactly two fewer Node allocations per success. Shared whole roots, same
   operand twice, static input and retained heap payload aliases must preserve
   complete outputs and refusal ownership.
4. Run a clean paired tree comparison only after those gates. The helper adds
   probe overhead to failures; reject if raw-unique coverage or timing gain is
   weak. No full compiler rebuild is warranted beforehand.

Phase118 generic reuse credits added a carried credit, an out slot, dynamic
matching and per-backedge work: roughly197→210ms; a sized ABI variant was about
196ms, effectively neutral (`phase118/trmc-reuse-audit.md`). This local proposal
tests a different cost model, but does not erase that negative evidence.
Its transfer class is binary tree restructuring (transposes/rotations with
exact linear field permutations), not arbitrary allocation-heavy code. Map
rotations would need their own recognized equations; no Map/compiler-hot gain
has been established. A single source-name rewrite of warp_zip would only be a
ceiling diagnostic, not the general optimization proposed here.

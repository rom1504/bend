# Phase114 architecture options: keep recursive ownership regions visible

Source-only review, 20 October 2026. No compiler, program, benchmark or diagnostic
probe was executed. This note supplements the [Phase114 design](qbe-parity-and-staged-runtime.md);
it proposes experiments, not qualified transformations or predicted speedups.

**The strongest general architecture candidate is a closed, stack-safe recursive
region with explicit continuation variants and owned block arguments.** It would
extend the successful complete-function plan across the non-tail recursion that
still excludes ordinary list, String and tree computations. The first slice
should keep existing allocation/ownership order and run descent and unwind in
one local machine loop. Flat tagged state and constructor destinations are later
uses of the same explicit layout/control boundary. Exact runtime-helper expansion
and compiler scaling repair are cheaper work to complete alongside this slice.

## What remains, and what is already implemented

The [selected source](../../implementation/phase113/selection.json) is wide31,
SHA256 `287c85558f3eb40d5576b51a4f7c0238100a9c4c93fc36ee52e3b8bc4e2ac303`.
Its checked hosted API generated the native products, but its own native image
is unqualified. The full acquisition timed out during lowering after 600 seconds.
Phase112 facts remains the qualified native checkpoint.

The final [44-point runtime table](../../implementation/phase113/broad-runtime.csv)
has a 7.087588× geometric slowdown against upstream. Important unchanged or
remaining families include list pipelines 14.265/13.860×, tree-bitonic 11.120×,
expression traversal 9.720×, map churn 9.060/9.140×, lexer 7.638× and Unicode
text 4.979/4.920×. Scalar-region is down to 2.130×. These are observed whole-program
ratios; none attributes a CPU fraction to allocation, helper calls or dispatch.

Phase113 already implements complete acyclic functions and self-tail loops,
cross-call fixed products, array-pair results, typed scalar/Nat/field facts,
bounded literal-combinator reuse, bounded bottom-up inlining, range propagation,
guarded array accesses, stable heap-base reuse and explicit machine-width
rendering. Phase112 already implements private workers, continuation fusion,
immutable images and Word-pattern reuse. Recommending those capabilities again
would miss the remaining boundary.

Three current source facts are particularly decisive:

* Selected `p113d_call` at line 44501 rejects a self call to a local destination;
  only a terminal self call becomes `P113DAgain`. `p113e_call` at line 45046 permits
  only previously admitted callees. Non-tail recursion and recursive groups cannot
  become complete direct functions by increasing the inlining limit.
* [Product layout](../../selfhost/tools/performance/phase113/products/layout.bend)
  reuses a checked, fixed single-constructor shape. It does not represent a sum of
  different constructors. Lexer `Mode = Gap | InId(U32) | InNm(U32)` consequently
  retains state shells after the outer pair disappears.
* The [current machine audit](../../selfhost/tools/performance/phase113/direct/remaining.md)
  finds no calls or spills in `mit`, but retains a large guarded array cell,
  constructor/take sites in lexer state, and generic frames in `ident`, `num`
  and `gen`. One remedy cannot be inferred to dominate all three categories.

## Ranked experiments

| Rank | Capability and purpose | First ordinary witness | Limit of the claim |
|---|---|---|---|
| Prerequisite | Reuse validated immutable originals; isolate planning/optimization cost | The same captured checked small/medium compiler request | Improves compiler throughput; does not itself improve generated runtime |
| Cheap parallel experiment | Expose one exact constructor/take or ownership helper fast path as structured operations, with unchanged fallback | Existing list traversal plus shared String/owned-field controls | Removes a common opaque boundary; static call counts do not establish the time share |
| 1: general control | Closed recursive regions with explicit typed continuations | Existing `dbl`, then `String.append`, then expression `eval` | Removes global transport/dispatch within admitted regions; initially keeps explicit continuation storage and all result allocation |
| 2: representation | Finite tagged payloads across closed calls/loops | Existing lexer `Mode` step/flush, plus an unrelated owned-field state | Removes nonescaping state shells; does not flatten arbitrary recursive heaps |
| 3: stronger specialization | Certified constructor destinations, then producer/consumer fusion | `dbl`/String append for destinations; existing list generate/filter/map/fold chain for fusion | Can remove a continuation category or intermediate containers; needs additional ordering, alias and publication contracts |

The ranking is architectural leverage, not a mandate to delay cheap measured
helper improvements. If ordinary kernels show helper cost dominates even with
the same control graph, that evidence should move specialized runtime operations
ahead of recursive-region implementation.

### Rank 1: the useful 10×-ambition slice

Extend the direct plan with **local block edges, typed continuation cases and
explicit result destinations**. QBE still constructs SSA; another general SSA
optimizer is unnecessary. A closed source recursive group becomes one worker
whose state is a block tag, full-width argument/result slots and an explicit
continuation stack. Each continuation case carries exactly the live values
needed after the call. First support a single self-recursive function, then
admit a mutually recursive group atomically. Unsupported groups retain their
existing generic entries.

This is more general than recognizing a final constructor call. It can retain
the strict post-call selector in list `keep_gt1`, the saved right child of an
expression evaluator, and post-return reconstruction. A tail-only SCC extension
would not admit these examples. A native recursive call would lose the current
stack-bounded behavior and is not an equivalent substitute.

For the first implementation, reuse the existing explicit worklist storage and
its capacity discipline, or an equally bounded private storage adapter. A
sentinel separates the region's frames from its caller's pending continuation.
Local return dispatch must consume only region frames; the public exit restores
the established caller state. Captures need not be heap constructors. The first
goal is to eliminate repeated `p111_rt_jump`/`return`, register-bank transport and
global segment dispatch, while keeping push/pop storage and constructor order.
The mature upstream already uses explicit descent/unwind frames for list and
String reconstruction, making this a parity experiment before a new allocator
or data representation is necessary.

**Cheapest falsifiable gate.** Use the unchanged `dbl` from
[list-pipeline128](../../selfhost/build/phase93/fixtures01/coverage-list-pipeline-128.bend),
with a dynamically supplied list and a complete list observer. One continuation
holds its computed head; one local unwind case constructs the result. Require
the actual called worker to contain local descent/unwind, bounded native stack,
and no per-element generic frame/jump/return transport. Merely emitting an unused
private function is not success. Allocation count need not decrease.

Then use ordinary `String.append` with empty, dynamic, static and shared suffixes,
Unicode and retained output/input aliases in both release orders. Finally use
the existing two-child [expression evaluator](../../selfhost/build/phase93/fixtures01/coverage-expression-32.bend)
to establish that the plan handles a saved owned subtree and more than one
continuation case. These checks distinguish a reusable continuation plan from a
list-specific rewrite. Use ordinary complete-output tests only.

The first source gate should print the actual normalized checked body and its
admitted plan. The earlier TMC audit did not produce such a captured-body witness;
source resemblance alone is insufficient to start claiming admission.

### Rank 2: share the tagged-payload layout with source state

Generalize fixed products to a bounded **sum of checked product layouts**.
For lexer Mode this is a tag plus one U32 payload, transported through the
existing direct result vector and local loop. The inactive payload is not an
owner. At generic/escaping boundaries, construct the exact original constructor;
at entry, consume the original box using existing shared/unique semantics.

The tag/payload schema is also what a local continuation case needs. Share its
layout and active-field rules rather than maintain separate informal layouts
for continuations, source unions and flat products. The first state witness
should exercise every Mode transition, then an unrelated sum with an owned
String field. Scalar-only Mode checks cannot establish field disposal or alias
preservation. Existing single-constructor product admission remains unchanged
until the sum adapter independently qualifies.

### Rank 3: 100×-ambition category removal

A shared owned-region plan can eventually specialize the runtime and computation
together: construct/project/take, variant transitions, continuation capture and
resume remain semantic operations until their use and lifetime are known.
Emit existing helpers or qualified structured templates from the same operations.
Do not reconstruct those decisions from C or QBE text.

Two concrete next steps are more credible than a wholesale string/heap rewrite:

1. **Constructor destinations:** for a proven final recursive field, retain a
   private result root and one hole capability, then fill with normal sealing.
   This removes per-element continuation storage. It does not remove the output
   nodes. The [TMC feasibility note](../../selfhost/tools/performance/phase113/direct/tmc-feasibility.md)
   gives the exact List/String boundary and the missing fill operation.
2. **Single-use producer/consumer fusion:** avoid materializing an intermediate
   list/tree/state when its only consumer is known and ordering is proved. The
   frozen list pipeline generates, filters, maps and folds. It offers a real
   category-removal witness rather than an allocator micro-optimization.

The second is substantially harder: existing `keep_gt1` computes the recursive
tail before its selector, so naive streaming reverses some evaluation order.
Purity alone does not establish equal termination or arithmetic-error order.
The first fusion should require total scalar prefix operations or preserve the
original evaluation schedule explicitly. Shared inputs, escaping intermediate
values and unknown consumers retain materialization. Binary tree reconstruction
also needs multiple live destinations/continuations; it is outside a one-hole
spine rule. No literal 100× runtime improvement is supported by current evidence.

## Contracts that the first representation must make explicit

* **Provenance and closure:** derive constructor layouts, function identities,
  effects and live arities from the authenticated checked book. Admit a recursive
  group all-or-none. Initially refuse bangs, parallel scheduling, foreign effects
  and unresolved/escaping calls inside the region; keep the original fallback.
* **Order and ownership:** snapshot edge arguments before parallel assignment.
  Transfer each owned argument, capture and returned field exactly once; preserve
  the existing explicit keep/drop order. A tag determines which payload slots
  are live owners. Never drop or read an inactive variant's slots.
* **Control and storage:** every resume tag names a checked case of the right
  arity; pushes initialize all captured fields before publication to the local
  stack, and pops restore the matching layout. Preserve the caller's continuation
  boundary, stack capacity checks and result vector. No unbounded native recursion.
* **Representation:** physical Terms remain U64. Nonowning does not imply U32;
  packed Bool and Nat retain their existing encodings. Preserve exact width
  legalization at QBE boundaries. Existing structural verification remains a
  required gate, not an ownership proof for arbitrary reflected IR.
* **Destinations, only if added:** holes belong to fresh unpublished output nodes;
  the cursor is a borrow, not another owner. Initialize every hole once and seal
  raw CTR children, including static suffixes. No take, sharing, effect or return
  may expose unfinished nodes. Earlier allocation changes exhaustion timing and
  requires an explicit resource-semantics qualification.

The meaningful equivalence is outputs, ordered observable effects and ownership
of retained aliases with no leaked live owners, under stated runtime premises.
It is not byte-for-byte heap or allocator-address equality.

## Stop/go and quantitative limits

First record semantic qualification, then the intended structural/counter change,
then matched uninstrumented runtime. Preserve the original inputs, full outputs
and fallback controls. A helper-call or frame count is not a CPU-time percentage.

Fixing only the two list-pipeline points to exactly upstream time would leave
the current 44-point geometric mean at **6.28515×**, computed from the frozen CSV
with the other 42 ratios unchanged. Thus even the largest visible list gap is
not a corpus-parity plan by itself. The recursive-region proposal earns its rank
only if it extends to independent String/tree cases; tagged state, arrays and
scalar instruction quality still need their own evidence.

For a single workload, a speedup of 10 requires removing at least 90% of baseline
time even if the targeted work becomes free; 100 requires 99%. These are Amdahl
limits, not measured shares, and cannot be applied to the geometric aggregate
as if it were one execution. A representative 7.09× case would need about 85.9%
less time to reach parity. The current static audits establish no such fraction.

Finally, native integration remains gated on compiler scalability. The
[source31 scaling audit](../../selfhost/tools/performance/phase113/direct/scaling.md)
identifies repeated whole-program verification, quadratic flat-product suffix
work and full-map joins. Preserve the independent final verifier while reusing
immutable internal validation, and measure existing stages before a full build.
New region analysis should use cached summaries and bounded graph passes rather
than another sequence of whole-body substitutions. Faster generated kernels
do not compensate for a compiler that cannot finish acquiring its own image.

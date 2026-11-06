# Phase173: the smallest native semantic-store interface

Source audit at `dc0440a`, with the Phase173 working pilot inspected on
2026-11-06. No target executions, production edits or performance measurements
were made for this note. The parent campaign owns those experiments.

## Main finding: native Array access is already constant-time

**An append-only store does not need a new foreign allocator to avoid a
binary-tree traversal on every access.** The source definition of `Array` is a
tree, but authenticated native `Array.get`/`set` operations use a dense block.
The distinction changes the proposed experiment: first remove owned-record
transport and repeated store reconstruction, rather than replacing an assumed
tree implementation which the native compiler does not execute.

Evidence:

* [Base Array](../../bend2/base.bend) defines tree operations around lines
  2325–2481. Its `Array.fork` documentation explicitly specifies two handles to
  the **same cells**, not persistent snapshots. `clone` copies instead.
* [Native Array lowering](../../selfhost/src/back/native/array.bend),
  `nc_array_known`/`nc_array_value`, recognizes get/set/swap/size/new/clone and
  emits native operations. Authentication uses `nc_native_def` in
  [bridge.bend](../../selfhost/src/back/native/bridge.bend), rather than arbitrary
  user function names.
* [QBE runtime](../../selfhost/src/runtime/qbe/runtime.c), `blk_at` and
  `native_array_get`/`swap`/`set` around lines 1156 and 1292, computes an index
  and accesses one cell. The uniform representation holds 64-bit `Term` cells;
  scalar packing uses 32-bit cells. Both have constant-time addressing.
* [Scalar admission](../../selfhost/src/back/native/scalar-array.bend),
  `ns_definitions`/`nc_compile_checked`, can refuse global scalar packing when
  File effects or non-scalar arrays are reachable. **That refusal does not turn
  authenticated native array operations back into tree traversal.** A U32 in a
  uniform cell is immediate: retaining, sealing or dropping it does not traverse
  another object. There remains the ordinary runtime call and tag/handle work.
* [Flat product lowering](../../selfhost/src/back/qbe/flat-products.bend),
  `p113p_pair_code`, and runtime `p113_rt_array_pair` already remove the temporary
  Tuple carrier for admitted get/swap/size/clone calls. Their ownership credits
  remain unchanged; this is not a borrowed-payload API.
* The selected [JS direct primitives](../../selfhost/src/back/js/direct/primitive.bend)
  emit ordinary JS array indexing and mutation; the checked
  [JS array-effect regions](../../selfhost/src/back/js/array-effects.bend) also
  support direct array operations. Actual admission in a particular generated
  pilot still needs inspection. The source tree representation alone predicts
  neither native nor JS execution cost.

There are genuinely linear operations. `blk_new` initializes all cells;
`blk_copy` copies all cells; constructing `ANode{left,right}` uses `blk_node` to
merge blocks. Doubling capacity therefore gives **amortized** constant-time
append, not worst-case constant-time append. Structurally matching array halves
can copy substantial blocks. The runtime itself documents O(n log n) copying
for a complete match to leaves. Store consumers should use authenticated array
operations, not recursively decompose `ANode` for ordinary access.

## Where the current pilot can still pay heavily

The experimental [store](../../selfhost/tests/phase173/store.bend) linearly
threads `Array<P173Node>` and `Array<U32>`. This is a sound first semantic
experiment: IDs are postorder, metadata is retained exactly, and no mutable
alias or unsafe foreign arena is assumed.

However, a node read returns an **owned P173Node**, whose shape includes owned
Strings and lists. The runtime's uniform `blk_keep` must retain the stored
object when it is not immediate. Destructuring and projecting it can cause
additional ownership work. A scalar edge read does not have that payload cost.

Every accessor also destructures and reconstructs the nine-field `P173Store`,
and returns another product. The existing `p113p_known` admits widths 1–8, so
one cannot assume that this nine-field root becomes a completely virtual flat
value through the currently implemented flat-product path. Other worker
optimizations may apply; only emitted code establishes which costs survive.

These are **candidate costs, not measured bottlenecks**. Inspect the selected
getter/loop's emitted QBE for native array op 72 / `p113_rt_array_pair`, root
constructor/take calls, retained payloads and continuation transfers. A count
of source-level Array operations is insufficient.

## Recommended minimum interface

Keep the current Array ABI and compiler algorithms in Bend. Use a private,
linearly threaded root. A conceptual interface is:

```text
new(capacity)                           -> Store
read_header(Store, NodeId)             -> Store & HeaderIds
read_edge(Store, EdgeIndex)            -> Store & NodeId
append(Store, HeaderIds, childIds)      -> Store & NodeId
retain_payload(Store, PayloadId)       -> Store & OwnedPayload
freeze_prefix(Store)                   -> Store & PrefixBounds
```

This is an interface sketch, not checked Bend code or a proposed public ABI.
Each operation consumes and returns the root exactly once. `HeaderIds` contains
scalar IDs, ranges and flags; owned semantic payloads are obtained explicitly
when they must escape. Bounds are checked against published counts: native
Array indexes wrap at capacity, so a bad semantic ID must never silently wrap
to a valid node.

Implement in increasing order of disruption:

1. **Unpack the root around a complete computation.** A private Bend worker
   receives the required array handles and scalar bounds as linear parameters,
   performs a sequence of operations, and reconstructs `Store` once on return.
   Keep existing get/set intrinsics and flat pair returns. This is the smallest
   way to test whether accessor transport, rather than storage addressing,
   dominates. Do not introduce closures merely to simulate a borrowing scope.
2. **Read scalar header columns without returning whole nodes.** Store child
   start/count and payload identity in `Array<U32>` columns or fixed-stride
   scalar rows. Keep exact `P173Shape` values in an owned payload table initially.
   Consumers that need only child ranges never retain a whole node. Consumers
   that require a shape still use an ordinary owned read. This preserves exact
   unknown tags and metadata without requiring a full interning system first.
3. **Only after evidence, preserve a borrowed payload through one verified
   consumer region.** The root remains live, immutable published slots cannot
   be overwritten, and no borrowed word escapes. Scalar results/IDs may escape;
   an owned result must receive the ordinary retain operation. The verifier
   must reject an escaping borrow, root destruction, mutation of its slot, or an
   intervening effect with unknown alias behavior. Unknown cases retain the
   existing owned get. The active borrowed-record experiment may supply this
   capability without any new runtime primitive.

This removes costs gradually and tells us which category mattered. There is no
justification yet for replacing native Array with a new Store runtime solely
to obtain O(1) indexing.

## Ownership, snapshots and reclamation

**Affine handles are necessary but not sufficient.** The store API must not
publish mutable aliases through `Array.fork`, unchecked foreign code or escaped
fields. File I/O can coexist with an owned store; it does not justify treating
arbitrary calls as unable to access a borrowed store. Keep the borrow region
closed and effect obligations explicit.

**A prefix is not an independently owned persistent snapshot.** For one
linearly threaded append-only root, `(epoch,nodeLimit,edgeLimit)` can identify a
read-only prefix while that root remains live and published cells are immutable.
It cannot outlive the root. A snapshot that escapes must carry a valid owner;
growth must preserve its storage. `Array.fork` alone is not persistence because
both handles observe writes. `Array.clone` is an explicit O(n) alternative.
Versioned immutable pages or per-version deltas become justified only when the
real checking algorithm requires simultaneous independent snapshots. Mutable
analysis facts need their own versions/deltas; do not overwrite facts visible
to an old prefix.

**IDs do not own nodes.** The root owns arrays and payloads. Dropping it reclaims
their storage under the existing runtime; returning a naked ID after dropping
the root is invalid. Separate per-function scratch ownership from durable
program ownership, and reclaim scratch at a real lifetime boundary. A durable
store can avoid repeated term destruction while still increasing peak memory
if it retains every discarded version. Measure retained bytes and final cleanup,
not only allocations during a scan.

**No unqualified O(1) claim.** Current get/set is O(1) in array size, but copying,
initialization, growth and final payload destruction are not. Truly bounded
worst-case append requires segmented storage and a bounded-cost page index,
which is a larger design and unnecessary for the first falsifier. A U32 ID also
needs overflow checks and an explicit absent-ID convention.

## Representation improvement available later

Upstream [comp.ts](../../bend2/comp.ts), `arr_cells`/`arr_op` around lines
1735–1780, already makes array layout a **per-element** decision. It reads
scalar lanes directly and retains boxed lanes only when needed. Our native
route currently relies on a global scalar-array permission for its narrow
packing option.

A useful later change would carry a verified element-layout certificate to
authenticated array operations, independent of unrelated File effects. Mixed
`Array<U32>` and `Array<P173Shape>` could then coexist with different layouts.
But this needs consistent handle metadata, creation, get/set, clone, structural
matching, foreign interfaces and C/QBE emission. Simply enabling the global
scalar bit for a mixed store is incorrect. Half-sized U32 cells alone do not
promise a substantial whole-compiler gain.

For the initial store experiment, uniform 64-bit immediate IDs are the safer
baseline. The all-Bend producer and consumers, existing primitives and native
ownership runtime already provide the necessary implementation boundary. No
checker, optimizer, dependency algorithm or semantic graph construction needs
to move into C.

## Smallest decisive experiment and failure conditions

Use the parent's exact `nc_compact` plus ordered-reference computation with
identical input/output requirements. Compare current tree terms, the initial
owned-node store, and at most one accessor/column variant. Charge import,
computation, export if required by the API, initialization, growth and cleanup.
Do not report only a scan over a prebuilt store as the full benefit.

Before timing another variant, inspect these few implementation facts:

1. Does its emitted read reach the native array primitive or source fallback?
2. Does the loop allocate a new Store/Tuple/node on every read?
3. Does the relevant consumer need owned shapes or only scalar child fields?
4. Does resizing account for the apparent work at this input size?

Finite controls should cover absent/invalid IDs, capacity boundaries, growth,
empty and unknown-tag nodes, exact spans and removed-name metadata, repeated
child identities, prefix reads after append, and owned payloads retained after
store disposal. Compare complete values using the independent term path.
Existing source checking and final native verification remain separate gates.

Reject a new arena as the primary intervention if existing Array operations
already index directly and whole-root/payload traffic dominates. Reject the
store as an immediate compiler migration if import/export and mandatory owned
payload traversal erase the gains. In that case, the next architectural test is
one producer and multiple consumers sharing the same IDs and lifetime—not a
faster foreign allocation function. Do not undertake a full self-build merely
because this interface is cleaner.

**Conclusion:** the native representation needed by Phase173 largely exists.
The missing experiment is whether a durable, linearly owned semantic store can
avoid repeated owned semantic-object traffic across a complete computation.
That is a stronger and more precise hypothesis than replacing a presumed
persistent native Array implementation.

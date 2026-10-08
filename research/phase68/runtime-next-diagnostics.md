# Native runtime diagnostics after workers, products and packing

Source/data proposal only. No compiler, Clang or program ran in this lane.
The pinned upstream is `0592662`. Complete the active product/packing selection
before claiming an incremental speed ratio for either proposal below.

| Rank by likely gain | General mechanism | Plausible gain in affected code | Fast discriminating experiment | Production cost |
| --- | --- | --- | --- | --- |
| 1 | Reuse uniquely consumed constructor storage | 1.1–1.5× for a narrow slice; up to 2× only if remaining allocator traffic dominates | 20–40 minutes for saved-C ablation and two independent outputs | Roughly 2–4 hours; 60–120 Bend lines for conservative worker scopes, plus branch/alias controls |
| 2 | One relaxed 64-bit RFC location read | 0–10%, potentially zero after other changes | 10–20 minutes; replace one runtime function in saved C, original and candidate paired under the existing plan | Roughly 30–60 minutes including ownership review; approximately 6–12 C lines |

These are hypotheses for affected programs, not geometric-mean predictions.
The first mechanism saves allocator work; the second saves a few loads/branches.
Neither alone justifies predicting a remaining 3× gap will disappear.

## Storage reuse has a concrete missing compiler mechanism

Upstream `comp.ts::node_fields` (1584) obtains the consumed constructor's storage
with `ctr_take`, then keeps eligible storage in a lexical spare list. Its
`ctr_build` (1020) takes a spare with the same allocation class. A zero or static
spare falls back to `heap_alloc`; unused spares flush before leaving the scope,
jumping to another segment, or forking. Branches copy the compile-time spare
list and discharge their own paths.

Our `bridge.bend::nc_destructure` immediately emits
`spare_free(... ctr_take(...))`. Every later `ne_constructor` emits a fresh
`heap_alloc`. The runtime allocator already caches freed nodes in a per-lane
LIFO list. Therefore the improvement is usually bypassing free-list stores,
loads, counters and threshold checks, not avoiding a system allocation. Do not
describe every `heap_alloc` call as an operating-system allocation.

There are concrete source witnesses in saved checked `native-flat06-rest`:

- `Map.lo` and `Map.hi` take a two-word Tuple and later construct a two-word
  Tuple in the same successful arm. An intermediate three-word node uses a
  different class. Their ordinary worker bodies contain no foreign call.
- The two-Node success arm of `tree-bitonic:warp_zip` takes two two-word Nodes
  and constructs three two-word Nodes. Two of those new nodes can reuse the
  consumed storage when ownership is unique. Packed leaf removal is separate.

These are examples of a general consume-then-build rule, not admission by
function name. They prove a syntactic opportunity, not hotness or a speedup.
Recheck the current selected C: products can remove transport Tuples entirely,
and packing can remove small leaf boxes before storage reuse is considered.

## Narrow correctness argument

After successful `ctr_take(e, value, n, fields)`, all live fields have been
copied into owned local words. A returned location at or above `HEAP_OFF` is
uniquely consumed storage; a shared take returns zero after retaining its
fields, and static storage lies below `HEAP_OFF`. Keep the existing take and
its unique-owner synchronization unchanged.

For a later constructor with `cls_fit(m) == cls_fit(n)`, reusing that location
has sufficient capacity. All field expressions must be evaluated before the
first overwrite. Retain their existing sealing/ownership operations and order.
The old constructor has no remaining owner; shared/static cases allocate as
before. Constructor identity need not match because the old tag belongs to the
consumed word, not the storage allocation.

Every spare is affine: consumed at most once, otherwise freed exactly once on
every normal exit. Initially flush at calls, scheduler/foreign boundaries,
parallel boundaries and self-tail backedges. Local joins can keep a spare only
if its C scope dominates every use and cleanup. Packed one-field matching
supplies no spare. Branches require explicit copied spare facts and separate
cleanup; a raw textual global replacement is insufficient.

## The quickest useful C-only experiment

Start from one freshly saved checked C artifact plus its pinned recipe and
oracle. In a small reviewed successful arm, change only:

```c
// Existing:
spare_free(e, cls_fit(2), ctr_take(e, old, 2, fields));
/* original field reads and subsequent operations */
u64 nd = heap_alloc(e, cls_fit(2));

// Diagnostic:
Loc spare = ctr_take(e, old, 2, fields);
/* identical field reads and subsequent operations */
u64 nd = spare >= HEAP_OFF ? spare : heap_alloc(e, cls_fit(2));
```

Audit all exits between take and allocation; either prove the allocation is
reached or insert the original `spare_free` on the exceptional path. For the
host-only worker screen, existing `err_seen` checks are false on the host and
runtime errors terminate the process. Do not carry that justification to GPU
execution. Preserve a literal patch and input/output hashes; this is an
intervention diagnostic and must never be installed as a compiler shortcut.

Use ordinary uninstrumented binaries for alternating-order timings at common
fixed work. Separately use allocation counters to confirm exactly one fewer
heap-free and one fewer heap-allocation per successful unique reuse. A shared
input must show the original allocation fallback and identical output. Test
two independent families, including one where the returned object escapes the
worker, before paying for general lowering changes. Stop if saved-C gains are
small or the active path no longer allocates.

A thread-local spare cache is a different allocator policy. It can retain
storage across unrelated calls and exits and adds a check to every allocation;
it is not a clean experiment for the proposed lexical compiler rule.

## RFC read experiment is independent

The new `runtime-reads/derive-peek-v1.py` source-only method changes host
`term_peek` alone; `rfc_view`, `ctr_take`, all count mutations and destruction
acquires remain identical. Base-world owns its next execution/implementation
lane. Its proof relies on immutable location bits above the low 24-bit count,
a retained reader and existing publication synchronization. Do not remove the
unique-owner acquire that precedes storage reuse. On x86, an acquire read is
ordinarily a load rather than a full fence; avoid overstating its cost.

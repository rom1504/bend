# Offline review of the chunk String prototype

Reviewed `selfhost/tools/performance/phase101/chunk-runtime.c`,
`chunk-append.c`, `prepare.py`, the application runner, control sources, and
selected already-generated C. This review executes no compiler or program and
claims neither a proof nor new runtime validation. Final inspected hashes:

- `chunk-runtime.c`: `ac0c2639f7e545eef03c124ee70d348cfcbeed1040f0dfbf2df955576e01fbd1`
- `chunk-append.c`: `ba808f5d8157028aac91c540d2d0567bad75d856486a250ab44a1a0cdc424544`
- `prepare.py`: `0841a181ac7273d03c59b158fb7e52d31131bb0a3dbb6f590c25f72391ad1d66`

**No concrete ownership or threading defect was found in the inspected chunk
and append algorithms under their stated ownership invariant.** The representation
is nevertheless a prototype: correctness depends on the emitted code retaining
every escaping view, canonical String admission, and the explicit CPU-only scope.
The issues below distinguish actual bookkeeping gaps from unproven boundaries.

During this review, root found and repaired an **actual append-entry adapter
defect**: `WL_OPEN` introduces a fresh register bank shadowing the incoming
`r0`/`r1` parameters. The initial replacement read those fresh locals. The corrected
adapter copies both incoming arguments into `p101_left`/`p101_right` before
`WL_OPEN`, then calls the helper with those saved values. The initial
`image-append01`/`image-append02` and debug failures remain evidence of this
adapter defect, not evidence of a chunk ownership fault or successful validation.
The review's ownership reasoning below applies to the corrected adapter; root
owns its executable controls and subsequent measurement.

## Ownership reasoning

Every independent owned cursor contributes one reference to its backing chunk.
Each chunk in turn owns exactly one suffix Term, regardless of how many cursors
refer to the chunk. Borrowed projections contribute no reference and must remain
inside the lifetime of an owning root. This is the essential invariant.

`p101_cons` only extends a unique chunk into prefix storage strictly after its
three-word header. It leaves the old visible suffix unchanged. A cursor can
reuse a previously consumed prefix: with one reference there is no remaining
independent owner of that prefix. A borrowed cursor cannot legally survive its
owner's consumption. New chunks seal their suffix before it can be shared.

`ctr_take` transfers ownership unchanged while moving to the next cell. At the
last cell, it first retains the sealed suffix, then releases the chunk and drops
the chunk's former suffix ownership if that release was final. This is balanced
for both unique and shared chunks. It also permits a simple implementation at the
cost of an extra retain/release pair on a unique boundary; no correctness reason
requires replacing it with a complicated fast path during initial validation.

`term_drop` handles packed Strings before the generic tag dispatcher, and loops
on the returned suffix without losing its enclosing destructor traversal stack.
This covers a packed String nested in a legacy constructor. `span_fade` retains
packed children directly. The special `blk_new` bulk-retain branch avoids
accidentally constructing an RFC wrapper around a packed String. Those two
otherwise easy-to-miss paths are present in the actual prototype.

The count-one test followed by the existing acquire operation uses the same
ownership premise as existing unique-node operations: another thread cannot
legally obtain an independent owner without a retain performed before publication.
The test would be insufficient if borrowed views could escape into independently
running tasks; that is a compiler ownership obligation, not a property established
by observing count one. Current ordinary affine task captures are intended to
own their captured values.

## Bounded short-prefix packing and append splicing

The revised append first borrows up to `P101_CHUNK_WORDS - 3` characters into a
local U32 array. If the complete left String fits, it consumes the left owner
and prepends the saved characters to the owned right argument in reverse order.
Otherwise it discards only the borrowed probe and enters the chunk-splicing path
with the original left/right owners still intact.

This branch has sound ownership under the same invariant:

- The original left owner remains live throughout every borrowed head/tail read.
- Every copied character fits in the exact U32 source domain. No pointer into
  the old String is retained in the buffer.
- Dropping left before construction is safe even if right is an overlapping
  slice: right owns its independent reference and therefore preserves everything
  it reaches. Subsequent cons can reuse newly unique storage without changing
  the saved character values.
- The borrowed `probe` can become dangling after dropping left, but that success
  branch never reads or drops it afterward.
- Reverse insertion restores the original left-to-right sequence. Empty left
  returns right unchanged. Exact-capacity left is admitted because the final
  projected tail is examined after the last saved character; capacity plus one
  takes the ordinary path without consuming either input.

The local array uses 244 bytes at the default class six (61 U32 characters),
and at most 4,084 bytes for the runner's largest admitted class ten. It is not
recursive per character. The long-left case pays an additional bounded read
before its existing traversal; measure that tradeoff independently from the
formatting win. Root's retained earlier splice experiment exposed poor chunk
occupancy when every tiny prefix kept a nearly empty chunk; this branch targets
that physical cost without recognizing application names.

No additional lifetime/threading defect was found in this new branch. Its useful
extra controls are exact-capacity versus capacity-plus-one, left/right overlapping
within one chunk, overlap through a later chunk, and full-U32/NUL values on both
sides of the threshold.

For a unique left chunk, `p101_append` detaches its owned suffix into the local
`left` variable, installs the chunk into the growing result, and replaces its
suffix with SNil temporarily. This moves the ownership obligation; it does not
duplicate or discard it. All result chunks remain private until return.

When the left chunk is shared, consuming one cursor through `ctr_take` copies
its characters into the forward builder while leaving other owners intact.
The builder owns its current chunks and links each next chunk exactly once.
At completion, the final suffix receives the already-owned right argument,
sealed if it is a legacy constructor.

The dangerous alias case is `append(left, right)` where right points into a
chunk reachable from left, or reaches it through a containing value. Under the
invariant, that chunk has another owned reference and cannot be spliced while
shared. Earlier unique chunks can be detached safely; the shared chunk itself
is copied. The same reasoning covers `append(s, s)` and overlapping suffixes.
This reasoning deserves direct dynamic controls because a missing retain at a
compiler boundary would invalidate it.

The implementation is bounded-prefix packing plus chunk splicing, not a general
rope concatenation proof. The fallback still walks the left chunk chain and copies shared/legacy portions. It
preserves left-to-right character content and receives already-evaluated arguments
at the saturated worker. Production intrinsic admission must establish the exact
canonical String.append definition and types; a worker-name match is acceptable
only within the pinned saved-C experiment.

## Projection and observation coverage

The preparation script rewrites both the generated borrowed observer field
reads and the shared-observer routing predicate. It also handles normal
String readback and generic datatype readback through temporary two-field views.
Consuming matches share the modified `ctr_take`. The inspected source-index C
retains no `no_loc_*` read and no unhandled direct generated String projection;
remaining `term_peek` uses are runtime helpers for words, arrays, IO requests and
the explicit legacy fallback paths. This statement is about that inspected file,
not a proof for arbitrary future emitter shapes.

The full U32 Char payload survives in the low half of each cell. Unicode scalar
validation is not added. The old IO decoder remains unchanged apart from its
builder, and output conversion still uses its old encoder. Thus invalid Unicode
Char values remain distinct from malformed UTF-8 input handling.

The constructor replacement currently receives local variables in the inspected
application output, so the C call does not reorder effectful argument computation.
For a general transformation, either assert that head/tail expressions are already
evaluated atoms or preserve original evaluation order using temporaries.

## Concrete follow-ups

1. **Standalone preparation provenance.** `prepare.py`'s own `preparation.json`
   does not currently record the append flag or pin `chunk-append.c`. The main
   application runner does record `append`, `chunkClass`, the append source pin
   and snapshots all methods, so this does not erase its existing provenance.
   Add equivalent fields to the standalone preparation report for reproducibility.
   The runner's final method revalidation should also include `appendRuntime`.
2. **Device admission.** The preprocessor guard rejects Metal device compilation,
   CUDA device compilation and CUDA host builds. It does not explicitly reject
   `BEND_METAL` host builds. Current Linux tests pass `--gpu off`; maintain that
   scope and add an explicit host Metal refusal before distributing this prototype.
   A future supported GPU mode requires disabled packing or conversion at the
   host/device boundary, not merely `#if !DEVICE` around helpers.
3. **Dynamic overlap witnesses.** Several useful value controls start from a
   static literal, whose aliases exercise legacy storage. Add one constructed
   multi-chunk String used as both append operands, and append its overlapping
   dynamically derived suffixes in both orders while observing the original
   afterward. Include alias origins in a shared record and Array<String>.
4. **Chunk-class boundaries.** Controls should use lengths immediately around
   actual capacity, `2^class - 3`, for each tested class. The existing 132-character
   String crosses the default 61-character capacity but is not a boundary witness
   for every configurable class. Also append a unique mid-chunk cursor, a shared
   mid-chunk cursor and an empty right suffix.
5. **Error scopes.** `p101_append` deliberately checks canonical String shape at
   its end. Its semantics on ill-typed forged Terms and resource fail-stops are
   not established as equivalent to the original recursive worker. Promotion
   should stay behind checked canonical types; keep raw/foreign fallback explicit.
6. **Optional diagnostic guard.** `p101_release` does not detect a zero count
   before decrement. A debug-only refusal/counter would make invalid lifetime
   controls easier to diagnose, without treating a debug check as a correctness
   proof or adding it to clean performance measurements.

The existing array-sharing and parallel controls target real risks: replicated
String elements, surviving extracted values, dropped owners, independent task
prefixes and deterministic joins. Whole source-index/image outputs exercise the
ordinary application paths. They should be combined with the dynamic overlap
and exact-capacity witnesses above before committing to compiler-source lowering.

No changes to the implementation files were made by this review.

## Separate borrowed comparison experiment

A subsequent root request added `selfhost/tools/performance/phase101/chunk-compare.c`
as a separate 36-line experimental helper, SHA256
`0d00a231821e941b374026e1cdab7544b71615e76f1291f72bc88e7bc586cf86`.
No runtime, transformation or compiler source was edited for that addition,
and no target was executed by this agent.

`p101_compare` caches each packed cursor's root/end, compares the common run of
low-32-bit characters, and advances at a chunk boundary. Mixed/legacy values use
the existing borrowed head/tail adapters. It returns only the ordering value
and moves no ownership. Consequently it may replace the existing scalar observer,
but cannot replace the owned `String.cmp` function that also returns its inputs.

The helper preserves unsigned full-U32 ordering, including values above Unicode,
rather than comparing native-endian words or the distance metadata. Equal Term
suffixes return EQ immediately. That shortcut presumes finite admitted canonical
Strings; it does not certify equivalence for arbitrary malformed Terms. Every
chunk is assumed to contain at least its current character, as established by
the runtime builder invariant. The caller must keep both roots live throughout.

Controls should compare equal and late-different multi-chunk values, prefix
relations at exact boundaries, shared suffixes, packed/legacy combinations and
characters 255/256, surrogates and `0xFFFFFFFF`. Mixed packed/literal comparisons
still traverse one character at a time; a gain there is not guaranteed. Clean
graph/source measurements and full output controls remain root-owned.

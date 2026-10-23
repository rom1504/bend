# Borrowed field transport: source-grounded feasibility

This note is a bounded inspection, not an implementation or measured speedup.
Observer reachability should be repaired and measured first: the initial nested
borrower was bypassed by a prior inlined wrapper, as recorded in
`boundary-loss.md`.

## What currently happens

`p118b_reads` emits `p118_rt_borrow_fields(state, term, scratch, cid, width)` and
then a fixed load from scratch for each field. A String comparison therefore
performs two external helper calls per character on the matching-string path.
The helper in `phase118/runtime-borrow.c` checks constructor identity/count/tag,
computes `term_peek`, copies every field into scratch and returns the count.

`term_peek` is not simply `term & LOC_MASK`. In
`selfhost/src/runtime/native/runtime.c:773`, an RFC handle requires a header read
through `rfc_view` and a 24-bit shift; an ordinary handle uses its low40 location.
`rfc_view` uses two 32-bit atomic loads and an acquire when count1. The selected
sequential CPU runtime is essential when considering a simpler equivalent read.

The upstream/mature C emitter can inline these peeks into the traversal. The
remaining helper/scratch overhead is a plausible explanation for part of the
gap, but the actual next profile must determine its dynamic importance.

## Existing ABI and verifier support

The public Phase111 runtime header has no borrowed-field-pointer or heap-base
import. All current imported-call results pass `p111v_call`, which requires
U64, not N111Ptr. Merely declaring a pointer-returning helper is insufficient.

The qualified private array emitter already loads `p113a_heap_base` from state
offset0. `P111State` begins with `P111Env`, whose first member is `uint64_t *mem`.
This is an existing pinned native ABI, rather than a new guess about state
layout. Examples are `p113ah_private`, `p117h_metadata` and the Phase113
`array-fast/README.md`.

Those array loads are certified late templates after independent validation of
the original operation. The public verifier deliberately rejects arbitrary raw
heap pointers: `p111v_memory` requires a known local capacity and
`p111v_offset` permits only a bounded literal offset. A loaded heap base has no
such capacity. Do not weaken those general checks to permit borrowed reads.

## Two bounded experiments

1. **Checked pointer-returning helper.** Preserve the exact constructor checks
   and `term_peek`, but return `&state->e.mem[location]`; generated fixed-offset
   loads read the fields directly. For a packed one-field constructor, retain
   the old scratch path or return a supplied scratch address after decoding it.
   Current NO boxed layouts have width at least2; Succ and Char are already
   separate scalar paths. This experiment removes copies and scratch reloads
   while retaining the external call. It is lower risk, but may have a modest
   ceiling if call/guard latency dominates.

2. **Certified late borrowed-read template.** Recognize the already-verified
   readonly import and its exact fixed field-load block, then emit structured
   loads using the existing pinned heap-base ABI. Preserve a tag/layout guard
   and the original helper fallback before any dereference. Decode RFC handles
   correctly; keep the held root and the exact result words. This removes the
   external helper and copying together, and therefore has the larger potential
   ceiling. It needs a dedicated source-bound proof/template admission like the
   existing array path, not a global pointer-verifier exception.

For either route, a narrowly verified late operation is cleaner than exposing
a freely writable pointer to the general IR. A generic N111Ptr currently permits
stores where capacity allows; a new borrow-pointer import would otherwise need
readonly/escape tracking or an exact-use checker. The operation's temporary
pointer should have a private fresh namespace and only the generated loads as
uses. If the old helper status is live, preserve its exact count result too.

The current matcher tests constructor auxiliary identity; it does not alone
prove TAG_CTR. Retain that distinction. A wrong tag, unsupported packed layout,
unknown descriptor or wrong width must reach the original helper/failure path.
Read-only static nodes can be valid: do not copy the array-write path's
dynamic-location restriction without justification.

## Decisive evidence and cost

First compare the exact hot borrowed reader's machine instructions and helper
counts after callsite repair. A local replacement of only field transport can
isolate the ceiling without another full compiler build. Preserve dynamic
shared/unshared/static roots, aliasing, shared suffixes, malformed constructor
controls, count/width mismatches and the original packed fallback.

A pointer-helper prototype is roughly 30–60 minutes including focused ABI
checks; a late fully inline template is roughly 60–120 minutes with independent
structural controls. These are implementation estimates, not wall-time
commitments or speedup claims. The small source-loop experiment should decide
whether either merits full native compiler qualification.

# Shared-constructor runtime boundary

Source/assembly audit at `4a47e78`; the root subsequently ran the bounded gates
reported below. No compiler, native program or C compiler was run by the
audit/preparation lane. Production runtime/source/selection are unchanged.

## Why this boundary, and its actual ceiling

Phase166's four-helper 46.73% result belongs to the small complete-record lookup
kernel. The newer retained full-source capture in
`selfhost/build/phase161/profile-full01/capture/000-sample-full-current-candidate-n2-diagnostic/analysis.json`
has 7,452 samples, zero loss and 99.43% process-CPU coverage. Its disjoint physical
leaf observations are:

| Leaf family, including cold clones | Samples | Full capture share |
|---|---:|---:|
| All `p125_rt_ctorN` |116|1.56%|
| All `p125_rt_takeN` |595|7.98%|
| `ctr_take` |205|2.75%|
| `span_fade` |526|7.06%|
| `term_drop` |778|10.44%|
| `p111_rt_sink` |271|3.64%|
| `rfc_wrap` |58|0.78%|

These are physical instruction locations, not causal savings or dynamic call
counts. The 239.98-second diagnostic CPU clock differs from the qualified
249.222-second complete build. Even deleting every `p125` constructor/take
instruction would not achieve the new 150-second target. Broad ownership work
remains significant, but most required child-reference traffic cannot disappear
merely by inlining calls.

The exact diagnostic assembly adds a useful falsifier: **260 of `span_fade`'s
526 samples occur at offset49**, the `lea` immediately following the dependent
child-RFC count load. Samples can skid; this is not a precise load-latency
measurement. It nevertheless contradicts treating the whole helper's cost as
call/return overhead. A fast path still has to access those counts.

## Concrete transformation

The current runtime marks `span_fade` `OUTLINE`, which expands on host to
`noinline,cold` (`runtime.c:110`), although the helper is a 7% full-request leaf.
Its sole source caller is `ctr_take`'s shared branch (`runtime.c:1091`).
`ctr_take` already obtains the RFC header, loads its child pointers, and copies
all fields to the output buffer. `span_fade` reloads those fields from the heap,
increments each nontrivial child's reference count, and calls `term_drop` on
the parent. `term_drop` rediscovers the parent's RFC and count even though this
path has already excluded a unique parent.

Two separately controlled changes are prepared:

1. **Warm annotation:** remove only `cold` from `span_fade`, preserving
   `noinline` and the existing `preserve_most` policy. No global annotation
   change, allocation rewrite or arithmetic change.
2. **Shared take:** after the unchanged complete field copy and unique-owner
   branch, when the already read count is greater than one and the parent is
   nontrivial, retain children from the copied output fields in the original
   order, then decrement the parent's current RFC directly. The generic
   fallback remains intact. This avoids a second payload traversal and the
   generic parent-drop entry; it does not eliminate required child increments.

Both changes are active only under `P144_SINGLE_MUTATOR_RFC && !DEVICE`. The
atomic and device routes keep their original implementation even when the new
flags are enabled. The existing serial-runtime policy already rejects BANGS,
GPU targets and unaudited multiple heap mutators.

### Ownership and error obligations

- The output buffer is the ordinary writable, heap-disjoint local buffer of
  the existing take ABI. Post-verification `p125` calls authenticate its capacity;
  ordinary native/runtime callers use local field buffers. This is not an ABI
  widening to arbitrary aliased pointers.
- All output fields are copied before any child increment, exactly as before.
  Left-to-right `rfc_bump` calls and malformed-unsealed-child errors are retained.
  Counter overflow uses the original check, mutation and fail-stop ordering.
- The parent started with count greater than one. In the single-mutator
  interval, the intervening operations only increment children; they cannot
  reduce that count. The direct decrement therefore cannot release the parent.
  It subtracts from the **current** counter, never restores the cached header;
  duplicate child aliases and even child/parent counter aliases retain their
  increment effects.
- Count-zero or otherwise trivial/malformed parent cases use the old fallback.
  Unique raw and RFC-unique cases are unchanged. Heap reclamation, publication,
  raw array ownership and the Phase148 shared-Type-wrapper refusal are untouched.
- Generic `term_drop`'s local `err_spun` poll is inert on this host-only route;
  device execution never enters the new branch.

These are source arguments under the existing runtime ABI, not a new formal
proof. Independent ownership and failure controls are required before adoption.

## Frozen preparation and cheapest falsifier

`tools/runtime-variants.py` is a data-only exact-replay producer. It authenticates
the maintained runtime, applies two unique substitutions and checks their exact
inverse. It copies the unchanged headers and writes all build commands/pins.

Prepared root: `selfhost/build/phase169/runtime-variants01/plan.json`.
Runtime source SHA256:
`7d82d3024e8ce5a712ac373b755abe845663734d61196e031c27b4f9b0e44661`.

The plan contains six compile/link pairs: baseline, warm-only, shared-only,
both, atomic-control and atomic-with-both-flags. It deliberately retains pinned
**GCC10 `-O2 -std=gnu11 -ffp-contract=off`** rather than introducing Clang as a
third independent treatment. Historical runtime compilation/link cost was about
1.9 seconds per variant; this is an estimate, not a Phase169 observation.

Relink the exact existing Phase152 N2 program object:

| Input | Bytes | SHA256 |
|---|---:|---|
| `phase152/native-n2/program.o` |24,811,328|`896a04ccd67d0159871ec3b3d46907404b5fa73c2e5ae88b6a787463558e66eb`|
| Qualified runtime object |119,096|`2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3`|
| Qualified compiler binary |18,945,224|`d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd`|

First require baseline object/binary identity and identical atomic-control versus
atomic-flags objects. Then run existing complete Phase166 kernel outputs plus
an unrelated compiler traversal, with shared duplicate-child, retained original
root, static, raw-unique, RFC-unique and invalid-child controls. Parent overflow
and child overflow behavior need direct ABI checks; do not interpret ordinary
successful programs as covering malformed ABI error paths.

Only after those gates, measure clean paired small compiler requests. Relinking
the actual compiler measures broad execution without rebuilding a compiler image
or changing its output policy. Complete stdout identity is still mandatory.
If favorable, one full-source request tests transfer. Inspect actual assembly
and code size: an inlined multi-arity retain path can increase instruction-cache
pressure, and the warmer branch may be neutral when dependent memory access
dominates. Reject a kernel-only gain with no useful complete-request transfer.

This trial cannot itself promise the required roughly40% full-build reduction;
it is the lowest-cost general ownership test supported by existing full profiles.
It complements, rather than replaces, work elimination in the compiler pipeline.

## Prepared finite semantic gate

`tools/runtime-controls.py` builds `tools/runtime-controls.c` against the frozen
runtime under all six treatments. The root runs it inside the existing guard;
the runner does not nest resource guards. It defines21 literal state controls,
including shared arities1–5, duplicate child aliases, retained-root second use,
raw/static/RFC-unique/packed paths, maximum parent count, the malformed zero-count
fallback, the final valid child increment, overflow before/after an earlier
increment, unsealed-child order, and arity/tag rejection. Total:126 finite rows.

Controls use the real runtime `_exit(1)` in a forked child and shared anonymous
memory. The parent checks exact returned fields, remaining root fields, child and
parent counters, free-list heads/lengths, and changes preceding errors. The host
runner additionally requires exact stdout, exact diagnostic stderr and status.
No error handler is replaced. A large sparse virtual mapping represents the
runtime's fixed heap offset; only a handful of pages are resident. These controls
are authored independently from source semantics. They are not a universal
ownership proof or new atomic concurrency gate.

Output-buffer audit: internal calls use local `fb[2]` in `io_cbuf` and `fs[256]`
in `io_exec` (`runtime.c:2550,2729`). Verified emitted calls require nonzero
capacity (`verify-segments.bend:204`); positive capacities originate from explicit
allocas and the state/scratch pointers (`:67–68,106`,
`verify-direct.bend:42–44,337`). Loaded heap pointers have capacity zero. The
legal output may alias runtime stack/state storage, but not constructor payload
or RFC cells. This audit does not grant arbitrary foreign callers permission to
pass aliased heap memory through the take ABI.

## Root-executed bounded result

All126 semantic rows pass in `runtime-controls01/report.json`. The
`runtime-build01/report.json` checks confirm disabled runtime object and linked
image are byte-identical to the qualified baseline, and enabling both flags in
the atomic configuration changes no object bytes.

The actual native compiler compiled the nonempty verifier source in two reversed
orders, retaining the prepared-Base policy. All eight requests emit the exact
2,895,455-byte QBE oracle with empty stderr. `runtime-verifier01/report.json`
records complete child-request observations (no subsequent QBE/assembly/link):

| Runtime | Mean of two requests | Ratio to baseline |
|---|---:|---:|
| Baseline |4.876999s|1.00000|
| Warm annotation |4.843197s|0.99307|
| Shared-take fusion |4.791713s|0.98251|
| Both |4.772153s|0.97850|

The approximately2.15% combined screening reduction is useful evidence but too
small to be the primary path to150s. Two observations are not broad validation
or a precise long-run estimate. No whole-self-build or generated-program gain
is claimed, and no runtime treatment has been promoted.

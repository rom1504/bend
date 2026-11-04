# Phase159 bounded candidate-scan ablation audit

Independent source review, 2026-11-04. No target execution or runtime/production
edit by this audit. Inspected the exact Phase157 vendor runtime and GC image
construction receipt. Root reports two admitted profiles with about77–78% of
CPU in `gc_refill`, and dominant PCs in its candidate-word search. The source
argument below does not independently remeasure those percentages.

**Recommendation: perform one bounded diagnostic build.** Capping the optional
GC candidate search is a credible causal test of this negative runtime result.
Preserve the complete allocation/ownership/GC machinery and fall through to
its existing slow path. This is an allocation-policy experiment, not a proven
general allocator improvement or a change to our qualified QBE compiler.

## Exact proposed boundary

Source:
`selfhost/build/phase157/vendor/rt/bendrt.h`, SHA256
`b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a`.

At line863, change only the loop condition in a **new research header**:

```c
/* original */
for (uintptr_t n = 0; b == NULL && n <= nw; n++) {

/* diagnostic: cap GC's private byte search, retain the RC search */
for (uintptr_t n = 0; b == NULL && n <= nw && (shared || n < 64); n++) {
```

`shared` is `gc_hot.rc` (line853). Under tracing GC, each iteration inspects
one64-bit word containing eight candidate bytes, so64 iterations inspect at
most512 block entries, not64 blocks or64 allocations. `gc_top` counts64KiB
blocks. The original loop walks the heap's complete candidate-word range and
revisits the starting word to cover candidates masked off below the cursor.
The cap intentionally does not preserve complete search when that range is
large. For ranges needing at most64 iterations, behavior is unchanged.

Keeping `(shared || ...)` leaves the shared RC candidate-bit scan untouched.
The current experiment is explicit GC, but modifying RC unnecessarily would
broaden the semantic/resource obligation, especially when tracing is disabled.
Do not change candidate contents, advance `rcur` on a miss, suppress collection,
or change the claim fraction in this first experiment.

## Why this is a plausible safe diagnostic

The scan is a **reuse preference**, not reachability, pointer validation or
marking. Its candidates are explicitly allowed to be stale (comments841–846).
The loop only obtains a block through the existing checks and ownership claim:

- `bi < gc_top` and small-block kind;
- matching size class/pool and currently unowned block;
- atomic compare/exchange from unowned to owned;
- real free-slot occupancy meeting the existing claim threshold.

Those checks and all existing writes remain unchanged (lines875–891). A miss
after the cap leaves `b == NULL`; no unseen candidate byte is cleared and no
unseen block is marked owned. A successful claim keeps `k->reuse = 1` and the
same cursor update. The pre-search old-cache flush/release (836–839), claiming
flag/fences and deferred stop handling (851–852,894–897) remain intact. The
collector's signal handler still defers stopping a claiming thread (2328–2335).

With no block found, the unchanged fallback (900–913) acquires `gc_lock`, checks
the allocation threshold and `gc_auto_trace`, runs `gc_collect_locked` when
required, claims a suitable `gc_partial[pool][class]` block, or chooses the
existing shared/new-block route. The ordinary fresh/reused cache setup,
allocation bits, young marks, holes/barriers and accounting then apply
(915–939; `gc_next_bits`/`gc_window`,686–719).

The global collector still scans all roots and sweeps the whole heap. `gc_sweep`
rebuilds partial-block lists (2353–2393) and free runs (2406–2414), independent
of whether an optional reuse candidate was searched on this refill. New-block
allocation still checks the heap bound (619) and contributes to allocation
accounting (`gc_handed`,742–747; fresh-block path930). Therefore the patch does
not turn tracing off, bypass memory ownership or manufacture free storage.

This is a source-level argument about which existing paths remain reachable.
It is not a proof of the entire foreign runtime, its signal/root machinery or
all possible schedules. Exact ordinary output controls remain required.

## Material risks and interpretation limits

The cap can miss a useful candidate beyond the search window. The existing
cursor advances only on a successful claim, so repeated misses can keep visiting
the same prefix; remote candidates may wait until a later sweep rebuilds the
global partial lists. Do not describe the cap as a fair rotating search.

Consequently it can change allocation addresses, locality, retained heap,
collection timing/counts and time under `gc_lock`. It may increase peak RSS or
reach a resource limit on a workload that the full search admits. Preserving
memory safety does not preserve all finite-memory behavior. This matters even
with unchanged GC thresholds: candidate reuse and fresh/partial-block allocation
have different accounting paths. Keep the2GiB live RSS guard and preserve any
refusal as a failed experiment rather than raising limits to obtain a win.

`BEND_NO_FREE=1` does not by itself prove that candidate bytes are always zero.
The runtime has native freeing and lifo-flush writers (`bend_free_slot`,1216–1282;
`gc_lifo_flush`,755–773). A successful cap would establish that bounding this
search policy helps this workload, not that every scanned byte was zero or all
reuse searches should be deleted. A subsequent policy design could maintain
an explicit nonempty summary or bounded rotating search, but that is beyond
this one-change test.

The77–78% physical refill share is not automatically the removable scan share.
Only mapped PCs inside the loop support that narrower attribution. Even a large
clean speedup would characterize this backend/runtime/workload bundle, not
prove GC generally superior or transfer directly to production QBE.

## Minimal qualification and causal comparison

Reuse unchanged
`selfhost/build/phase157/gc03/program-adapted.c`,1,445,181bytes, SHA256
`4dbb234a71c378c8250e70e783b912025660ca906eb5f92ca41d213ffa69a9a8`.
It includes the monolithic `bendrt.h` unless `BEND_RT_SPLIT` is defined. Place
the one-change header in a fresh include directory and use the original pinned
Clang-O3 command/flags from `gc03/report.json`, replacing only include and output
paths. Do not rerun the Bend emitter, alter the nine already-admitted effect
registrations, use a new optimization flag or rebuild the seed. Retain original
and changed header identities and assert an inverse patch recovers every byte.
Ensure no adjacent original header or split-runtime object shadows the candidate.

The original image took56.41s to construct with about350MiB peak compiler RSS;
that is an acquisition estimate, not a guarantee. One such build is justified
by a repeated dominant physical hotspot, rather than speculative code shape.

Required finite gates:

1. Candidate `oracle 1` exits0, has empty stderr and matches the complete
   independent173,582-byte output already used for Phase157. Use the correct
   `compiler-work` argv0 and identical captured book.
2. At least one short N1/N4 screen, then balanced clean old/new N16 observations
   on CPU3, one worker/GPU off, with fresh processes and complete teardown.
   Keep unchanged original GC image as the comparator. Bracket the final block
   with the exact oracle; retain CPU, wall, RSS and all failures.
3. If it wins, one separate admitted physical profile should show the candidate
   scan cost collapsing rather than merely moving to another path. A separate
   GC-statistics observation can reveal changed collection/heap behavior;
   instrumented elapsed intervals are not exclusive GC CPU. Do not count the
   diagnostic clock as a clean timing result.

The independent verifier and emitted QBE oracle remain unchanged because the
Bend computation itself is unchanged. Passing these gates explains a concrete
runtime cause of Phase157's GC negative; it does not constitute broad generated
program conformance, multiworker qualification or an upstream-ready allocator
patch. No production change or public comment is implied.

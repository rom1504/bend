# Rejected private weak-head pair memo

A private `wnf(book, term)` cache is semantically plausible but **slower in this experiment**, so it is not integrated. It is separate from the context-free Boolean stability memo and the shipped private compiler package.

On the real 312-declaration compiler-core library, counter-only instrumentation observed 339,730 weak-head calls and 133,138 repeated exact `(book identity, term identity)` pairs (39.2%), across 465 book objects. Counting only repeated terms would report 146,595 and wrongly conflate distinct books. Instrumentation changes no force/result behavior and preserves exact compiler observations/output. Its max RSS was 582,588 versus 716,672 KiB for control; this is the instrumentation footprint, not cache performance.

The prototype pins the reviewed checked H byte hash. A nested WeakMap keys both immutable book and term. It changes only the existing specialized non-tail call wrapper: a miss still executes the original `force(privateWorker(...))`, with no extra wrapper frame. Only completed six-field KTerm results are stored; exceptions and in-progress work are not cached. Tail workers, `g_wnf`, graph heaps, freshness counters and strong-normalization routines remain unchanged. Returned graphs can remain alive while their keys remain live, unlike the Boolean fact cache, so peak memory was measured.

Three serial alternating fresh-process rounds on CPU0 used separately primed verified Base caches. All 24 exact observations and emitted-byte comparisons passed:

| Input | Control request | Pair memo request | Change |
| --- | ---: | ---: | ---: |
| Tree | 2.039 s | 2.064 s | 1.2% more |
| List sort | 3.534 s | 3.641 s | 3.0% more |
| Rejected bytes operations | 1.596 s | 1.628 s | 2.0% more |
| 312-declaration compiler core | 27.752 s | 28.977 s | **4.4% more** |

All three core pairs regress. Median core process wall rises 28.900→30.126 s and peak RSS rises 580,676→597,480 KiB (2.9%). Small negative-case timings vary substantially between rounds; the table reports all three observations' medians, not a selected favorable pair. Identity reuse alone does not establish useful saved work.

Fourteen additional exact observations cover seven same-path source/import changes in reused APIs: changed source/dependencies produce new output; repeated invalid imported types preserve their diagnostic; restoring valid imports succeeds. The private contract still requires immutable compiler data behind the textual request boundary. This experiment does not justify caching arbitrary public graphs, single-key term caches across different books, `g_wnf`, or freshening-dependent operations.

[private-wnf-memo.json](private-wnf-memo.json) retains counts, exact input/tool/proof identities, all samples and resource observations. Raw reports and hash-verified consumed-tool snapshots live under `selfhost/build/phase4/private/{wnf-counts,wnf-compare,wnf-requests}`. Tools are `private-wnf-{probe,memo,compare}.mjs` under `selfhost/tools/performance/phase4`; the reused-request gate shares `private-stable-requests.mjs`. The frozen experiment proof snapshot correctly remains labeled pending even though the same H subsequently completed its fixed point.

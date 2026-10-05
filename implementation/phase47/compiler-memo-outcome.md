# Completed type-query memo: lexer screen outcome

Recorded 2026-10-04. **Useful diagnostic signal; no production cache shipped.**
The installed compiler remains Phase 45 worker23. This experiment changes only a
saved compiler API used to measure compiler requests, not generated target execution.

Five alternating, fresh-process lexer library requests per clean variant give:

| Metric | Unmodified API | Boolean memo | Interpretation |
| --- | ---: | ---: | --- |
| Median request time | 4,510.212 ms | 4,210.782 ms | **6.64% reduction**, 1.0711× baseline/memo |
| Median public emission boundary | 3,033.871 ms | 2,732.853 ms | Same public timer in both variants; not an exclusive internal-pass profile |
| Median process max RSS | 314,580 KiB | 313,764 KiB | Includes import/verification overhead; no general memory-gain claim |

Each API variant's disk Base cache was independently primed before comparison.
Fresh processes reset the memo between requests. API/driver import and startup
remain outside `requestMs`; public timer overhead is common to both variants.
The [screen receipt](evidence/compiler-memo-screen.json) retains all ten request
times, not only the favorable rounds. One memo round is slower than its paired
baseline; five rounds on one source establish a screen, not a universal gain.

All 17 supervised jobs complete with zero exit status: three primes, check
baseline/memo, library baseline/counted memo, and five alternating clean pairs.
Their [plan and raw process receipts](../../selfhost/build/phase47/compiler-memo01/jobs-plan01.json)
retain order, commands, CPU 3, Node 24.18.0, 4,096 KiB stack, 1 GiB heap,
2 GiB tree-RSS ceiling and 4 GiB available-memory floor. Their enclosing wall
durations total 79.256 seconds; that is not the sum of timed request medians.

Check observations agree exactly. All library observations and output identities
agree, including status, phase, checked/trust flags and source inventory.
The emitted library is **208,893 bytes**, SHA-256
`a288fb4c6a8dd2309c961f1632e3e9e0e51bc3d9237973507b2b3c22b8fb89c2`.
The [counted request](../../selfhost/build/phase47/compiler-memo01/memo-count-library.json)
records 21,664 calls, 11,005 hits, 10,659 misses/stores, and zero non-object keys,
non-Boolean results, exceptions or capacity saturation. About **51% query reuse
is not 51% request acceleration**; observed request reduction is 6.64%.
Counted timing is excluded from the clean medians.

The [derivation receipt](../../selfhost/build/phase47/compiler-memo01/derive.json)
binds the exact checked API/runtime/Base, source/host dependencies, byte snapshots,
variants and runner. The baseline API is byte-identical to selected worker23.
The counterfactual memo uses request-local WeakMaps keyed by exact raw book/type
objects and stores only completed outer `Nil`/512 Boolean results. It misses
structurally equal fresh objects and tests neither cross-request reuse nor
persistent dependency invalidation. It caches neither tail messages nor exceptions.

This one lexer input does not qualify a maintained Bend fact table, arbitrary
public graph mutation, inner active/fuel queries, other contextual books, or a
whole compiler corpus. Further work must first replicate the observation on an
independent request and measure source-level key/table costs, then exercise
recursive refusal, first diagnostic and changed source/import/API boundaries.
The [proposal](compiler-memo-proposal.md) and [earlier census](compiler-cost-proposal.md)
remain separate from this measured outcome. No new compiler-latency release claim
or generated-program speedup is inferred.

# Phase137 — Borrowed queries that survive inlining

**Checkpoint: small experiment validated; full native qualification in progress.**
The integrated compiler is independently source-checked and passes50 finite
controls. Lexer, closures and Map produce byte-identical QBE to the qualified
parent. The installed and qualified Phase134 selections remain unchanged.

The main finding is a pass-composition problem. The compiler already knew how to
produce useful borrowed readers, but early inlining replaced their callers with
owning record operations. Preserving this boundary makes existing optimizations
work together without repeating preparation.

In a fresh five-round native comparison, the exact compiler-query extraction is
uses31.23% less time and an unrelated nine-field record workload64.88% less time. These are
kernel results, not compilation-throughput or broad generated-program claims.
Width alone, source factoring alone and argument-order changes did not provide
this transfer. [All variants and limitations](query-notes.md).

The integrated Bend source adds177 lines (58,392→58,569), including controls;
source bytes increase8,831. Four width bounds change8→16, one inlining-profitability
entry changes, three actual queries use complete scalar predicates, and the old
width9-refusal control moves to17. Existing verifier/entry/runtime contracts and
eleven proof declarations are unchanged. These proofs do not establish a new
end-to-end compiler-correctness theorem.

[Design](../../design/phase137/README.md) ·
[Experiment](../../experiments/phase137/P137-001-borrowed-query-boundaries.md) ·
[Independent source/ownership audit](audit/README.md) ·
[Actual generated calls](audit/generated-calls.md) ·
[Native gate plan](native-plan.md) ·
[Reproduce](../../selfhost/tools/performance/phase137/README.md) ·
[Immutable small-experiment evidence](evidence01/receipt.json).

No PR comments were posted. Native N1/N2/compiler-request results will be reported
separately from the small-program gains; failed candidates remain evidence.

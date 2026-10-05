# P47-003: repeated compiler proof work census

Date: 2026-10-04. Pre-execution status: diagnostic producer only, unmeasured,
investigate. Owner: callbacks agent producer; root execution.

Instrument an exact checked worker23 API derivative to count checking, planning
and outer `j_pure_type` queries. No cache, extra force or changed return protocol.
Count exact raw book/type pairs with a bounded table and report saturation.
Separate instrumentation overhead from actual compiler latency. Start with lexer
and an independent representative input if the first result is informative.

The outer Boolean type query uses fixed empty active-set/512 fuel, unlike inner
recursive calls. Reuse would still need exact checked context, policy and lifetime
plus measured key/memory overhead. ABI2's source-only Base prefix cannot restore
live checker memo/diagnostic state; do not skip that recheck based on its name.
Prior exact-key normalization memoization regressed despite a useful hit rate.

Falsification for further cache work: low reuse, saturation, key/retention cost
comparable to proof work, or a context/diagnostic ambiguity. A census alone earns
no speed claim and does not change the installed compiler.

## Final outcome — 2026-10-05

The census recorded 21,664 outer type queries and 11,005 repeated exact book/type
identities. A bounded saved-JavaScript WeakMap counterfactual reduced the measured
lexer request median 6.64% while preserving exact output bytes. The roughly 51%
repeat rate is a query count, not a compiler speedup estimate. Context/key cost,
lifetime and diagnostic preservation still need a production proof.

No proof cache is included in installed array06. The independent final compiler
request comparison instead measures its representation changes: medians rise
1.21% for fold, 3.75% for edit distance and 0.87% for lexer over freshly paired
worker23. The cache diagnostic and these requests are not pooled. See the
[census outcome](../../implementation/phase47/compiler-memo-outcome.md),
[final request-cost report](../../implementation/phase47/compiler-cost-final.md)
and [selected candidate](../../implementation/phase47/selected-candidate.md).

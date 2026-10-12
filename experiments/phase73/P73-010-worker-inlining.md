# P73-010: test the private-worker inline boundary

Private-worker inlining currently uses4096 emitted source bytes as its cutoff.
Administrative copies, preprocessor facts and labels distort that estimate.
Use saved candidate C to force inlining of all admitted private workers, with
unchanged runtime, outputs and toolchain. Four alternating pairs on AST/tree/
Array.map/lexer. This is a diagnostic upper bound, not a production policy;
inspect Clang cost and reject regressions before designing any broader heuristic.

Also test the opposite boundary: remove forced hints from private workers and
let the pinned Clang optimizer decide. The source/runtime/oracles stay identical.

Rejected: all-forced versus candidate10 medians AST435→498ms,tree306→298.5,
Array.map475.5→473,lexer292.5→268.5. No-forced medians AST434.5→435,tree307→292.5,
Array.map529→503,lexer292→311. Neither policy wins broadly; preserve the existing
cutoff. Both complete alternating campaigns, generated diffs and build costs
are retained. The higher Array.map baseline in the second campaign demonstrates
why these separate comparisons must not be combined as one timing series.

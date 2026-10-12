# P73-010: test the private-worker inline boundary

Private-worker inlining currently uses4096 emitted source bytes as its cutoff.
Administrative copies, preprocessor facts and labels distort that estimate.
Use saved candidate C to force inlining of all admitted private workers, with
unchanged runtime, outputs and toolchain. Four alternating pairs on AST/tree/
Array.map/lexer. This is a diagnostic upper bound, not a production policy;
inspect Clang cost and reject regressions before designing any broader heuristic.

Also test the opposite boundary: remove forced hints from private workers and
let the pinned Clang optimizer decide. The source/runtime/oracles stay identical.

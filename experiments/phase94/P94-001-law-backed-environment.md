# P94-001: law-backed native environment preparation

Status: registered, unmeasured.

Design: [Phase94](../../design/phase94/laws-backed-native-optimization.md).
Baseline: `90f40c4`; native source D04 and Phase90 release.

Hypothesis: filtering an environment for liveness, appending a binding and then
partitioning with the same predicate contains removable membership tests and
list reconstruction. A safe generic helper can state and prove equivalence to
the reference sequence, and be the exact helper called by the compiler.

Correctness requires independent kernel acceptance, false-equality rejection,
mutation controls and production linkage. Unsafe predicate adapters and C/runtime
semantics remain separate obligations. Measurement requires real helper scaling
and paired compiler evidence before any end-to-end gain claim. Promotion requires
benefit sufficient to justify complexity and all applicable integration gates.

The Phase67 Lean-version failure is an inherited prerequisite, not evidence
against the transformation. Preserve new failed proof and measurement attempts.

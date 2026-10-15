# P94-001: law-backed native environment preparation

Status: completed; proof method validated; performance candidate not promoted.

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

Result: exact safe helper and full 36-definition elaboration accepted by the
unchanged upstream BendTT kernel under official Lean 4.34.0. False equality is
independently rejected; three helper mutations fail the frozen Bend law. Six
actual adapter controls pass. The helper saves17.6–39.0% time on four extracted
workloads, but24 real compiler pairs are neutral: request0.9972365× and process
wall0.9995302× baseline. All45 original benchmark C products remain byte-identical.

The first compiler screen failed final method authentication and is excluded;
the second repeated all48 samples with frozen inputs. No B2/full-self rebuild or
production edit is justified by this benefit. Candidate adds50assembled lines;
production stays unchanged. [Report](../../implementation/phase94/README.md) and
[evidence](../../selfhost/tools/performance/phase94/evidence02/summary.json).

Next hypothesis should first establish inclusive native allocation/lifetime cost
and a material saving, then reuse the law-backed helper workflow. Generic cleanup
leaf samples alone do not attribute costs to this environment transformation.

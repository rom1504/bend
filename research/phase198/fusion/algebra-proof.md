# Independent finite-word algebra check

Status: **not accepted in Lean**. The final authorized attempt reached theorem elaboration and failed. No compiler correctness claim depends on this optional check. [Machine-readable status](algebra-status.json) and all four attempt receipts preserve the exact inputs, diagnostics and resource guards.

`Affine.lean` states the intended invariant for every bit-vector width `w : Nat`, including zero, and every finite `Context w`:

```text
run context m b = m * value context + b
run context 1 0 = value context
```

The context has one distinguished child beneath each add, multiply, left subtraction, or right subtraction constructor. Siblings are already evaluated `BitVec w` values. The model does not prove the Bend recognizer, binder matching, source evaluation order, worker loop, U64-to-U32 implementation, encoding, or runtime correct.

The first two attempts exhausted 12-second deadlines without a diagnostic. Attempt 03 stopped before launching Lean because `/usr/bin/time` is unavailable. Attempt 04 replaced that dependency with Python monotonic timing and `resource.getrusage(RUSAGE_CHILDREN)` deltas, used a minimal BitVec import and one Lean worker, and completed inside its 20-second guard:

| Phase | Wall seconds | User CPU seconds | System CPU seconds | Result |
| --- | ---: | ---: | ---: | --- |
| Import-only control | 10.6623 | 0.2898 | 0.2456 | Passed |
| Affine theorem | 2.6979 | 2.5793 | 0.0760 | Failed |

Total driver wall time was 13.8843 seconds. The import-only wall cost was substantial compared with its CPU time; the earlier undiagnosed timeouts cannot be attributed solely to proof rewriting. The final trace reports 412,458 raw profiler heartbeats for elaborating `run_value` and 16,854 for `identity_entry`. These are profiler counts, not seconds. Child RSS in the receipt is the cumulative child maximum, not a per-phase difference.

The subtraction cases remain unsolved: `sub_eq_add_neg` normalizes the subtraction inside multiplication before `mul_sub` applies, leaving an undistributed `m * (x + -s)` expression. The identity-entry simplification also leaves `1 * value x + 0 = value x` unsolved. Lean reports `sorryAx` dependencies from error recovery; the driver correctly rejects the nonzero exit and does not count these declarations as accepted proofs. The exact failed source remains checked in, rather than substituting an untested repair after the last permitted run.

`algebra-argv.json` records the final actual command. It uses an 18-second whole-check deadline inside a 20-second guard, an import-only control, explicit rewrites, and heartbeat tracing. Re-execution requires a fresh output/job name and a coordinated resource slot. No additional execution was authorized or performed after this result.

The compact evidence files retain the original methods/proofs, complete diagnostics and guards. The final receipt also pins the Lean 4.32.0 executable/runtime and bit-vector library. A future proof repair must pass independently and report its exact axiom dependencies before this status can change. Finite compiler/oracle results and the prior mathematical argument remain separate evidence.

# Counting a fresh native candidate

`run-candidate.py` is a versioned addition. The original `run.py`, counter
transformation, and consumed baseline receipts stay unchanged. Root alone runs
targets, serially on CPU3 under the same guard. No installed compiler is required:
the runner reads exact saved C and its checked emission/acquisition receipts.

```sh
python3 selfhost/tools/performance/phase68/profiles/run-candidate.py \
  --acquisition selfhost/build/phase68/native-arity01 \
  --attempt selfhost/build/phase68/arity-build01 \
  --out selfhost/build/phase68/native-arity-counts01
```

The default numeric/array cases run with one and seventeen repetitions, zero
warmups, CPU execution and one worker. The independent oracle checks outputs.
The already complete `native-counts01` baseline supplies the corresponding
operation-count deltas; it is not rerun. Rough target occupancy is one minute,
dominated by two Clang builds, not a timing guarantee.

The runner binds the candidate API to its checked build and frozen source
snapshot. It verifies exact emission source/output/recipe identities, original
acquisition Clang command, baseline toolchain identity and flags/environment,
unchanged workload, unchanged selfhost runtime C, and unchanged effect files.
This is a comparison of two lowering versions using the same native runtime.
It does not compare the current installed compiler against historical receipts.

Use `--check-only` without `--out` for CPU0 source/data checks and fail-closed
instrumentation anchor validation. This path launches no targets or guard and
writes no files. Available baseline cases constrain `--cases`; requesting an
unmeasured baseline case fails rather than borrowing another workload.

Counter ratios explain changed operation frequencies. They do not establish
runtime speedups: instrumentation changes generated code and execution, counts
include IO/digest work, and requested allocation capacity is not RSS. Numeric
zero baselines produce a null ratio. Segment identifiers and decoded names are
bound independently to each emitted C because numbering changes between builds.
Clean performance remains the separate uninstrumented comparison.

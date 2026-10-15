# Phase93: runtime of the original 45 points through the native compiler

## Question and scope

Measure execution speed of native programs produced by our native Bend compiler,
against programs produced by pinned upstream TypeScript's C backend. Preserve the
45 fixed-input points from the historical JavaScript catalog (23 original Bend
programs). This measures generated-program execution, separately from compiler
requests and Clang builds. No production compiler change or PR comment is planned.

Phase92 establishes equal complete C products from source-matched native B1/B2,
but its one-shot executions and approximately 20 ms supervisor polling cannot
establish runtime ratios. The old JS runtime ratio and the differently wrapped
C12 result are not denominators for this experiment.

## Comparable workloads

Keep the original bodies, parameters, expected results and full generic-array
serializer. Derive closed, Base-only sources from the recorded Phase88 fixtures,
replacing their single-call IO entry with a documented batching entry. Read the
repetition count and workload arguments at runtime, normalizing the upstream and
own IO.args conventions by reading the final four arguments. Repeat the exact
catalog input, as the JS benchmark does; do not quietly introduce a different
16-input schedule. Every iteration compares the complete result with the frozen
expected result and contributes one success to a counter. Both warmup and measured
counts must match, and the initial complete output must match the catalog.

The batch prints the measured success count between IO.now calls, forcing its
observation. The interval includes validation, loop overhead and the final small
print; it excludes startup, initial observation, warmup, compilation and Clang.
Strings and the generic-row result are fully observed. Zero-work scalar controls
remain explicitly identified. These wrappers are new benchmark products, not the
identical C bytes validated in Phase92.

Acquire every wrapper through native B1, native B2 and pinned upstream at
059266225b77c8ca256ac6b25ee5c21449bab151. Require complete B1/B2 C identity before
using one shared executable to represent both. Compile own and upstream C with
the same pinned Clang22, C11/O3, pthread and math flags. No generated-C patch or
production change. Both native compilers remain implemented in Bend.

## Measurements and validity

Use one CPU (3), one runtime thread, GPU off, bounded RSS and the shared execution
lock. Root alone runs targets; agents prepare and review offline. Start with a
small pilot covering numeric, string and tiny workloads, preserving failures.
Calibrate each pair separately, choose a common repetition count targeting at
least 200 ms for the faster role, and require every final interval >=100 ms.
Run three paired rounds with order alternation, retaining all observations.
Read an inner high-resolution process clock separately from supervisor wall time.
If calibration cannot qualify a point within limits, retain it as unresolved;
never compute a full-45 mean from only survivors.

Inspect representative generated loops and optimized assembly for repetition
hoisting, especially scalar, fold and zero-argument inputs. Check repetition
scaling. IO.args alone does not prove anti-hoisting. If a compiler optimizes
repeated work away, label that point rather than presenting its loop cost as
general kernel throughput. The same fixed-input caveat applies to the old JS
benchmark; varying-input stress tests are a separately named future corpus.

Report individual medians/ranges and our/upstream ratios (below one is faster),
equal-point geometric mean, and a mean giving each of the 23 original programs
equal weight. Do not divide native ratios by historical JS ratios to claim a
JS-versus-C speedup: target, harness, clocks and date differ.

## Efficiency, preservation and completion

No compiler image rebuild, full self-emission or broad frontend rerun is needed.
Freeze all source, runtime, compiler, toolchain and harness inputs. Deduplicate
only byte-identical newly emitted B1 C against retained B2 C with explicit
restoration mappings. Preserve unique C, binaries, raw sample receipts, failed
attempts and calibration; archive them with full-byte readback verification.
Keep a 160 MiB disk reserve for targets. Commit design, methods and findings,
then push the report with reproducible commands and documentation links.

The experiment is complete when all points have a result or an explicit failure,
measurement limits and native-stage attribution are clear, and the report is
published to the existing bootstrap branch. Optimization is a separate decision.

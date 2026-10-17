# P105-001: current native B1/B2 versus pinned upstream

Plan frozen before target execution, 2026-10-17. User requested the measurements
defined in [the comparison protocol](../../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md).

Measure candidate04 native B1/B2 and pinned upstream TypeScript/Bun on identical
Bend sources, emitting complete C. No compiler source, release or backend change.
The question is how their compilation latency differs by workload and Base
preparation, not whether C programs run faster or a new backend improves builds.

Run the six-source screen for four fresh-process rounds in both prepared/live
modes; then closed45/23-original corpus for two rounds in each mode. Finally run
the complete candidate04 compiler source for two prepared rounds and one live
round. The full-source live observation is deliberately exploratory; do not
present it as a repeated estimate. Fixed seed10520261017; randomized case/mode
order and rotated role order. Reuse authenticated existing native executables.

Existing current native C/diagnostic records and exact-source upstream screen/self
C are oracles. Closed45 upstream C must be freshly acquired before timing; that
is a determinism reference, not independent semantic proof. Compile and execute
six varied broad-corpus product pairs against existing expected complete output.

Primary timing uses the existing Phase46 high-resolution child wrapper uniformly
inside the Phase86 resource guard. It includes fork/exec, startup, preparation,
C output and process completion, excluding authentication and supervisor setup.
Guard wall has20ms exit polling and is recorded separately. Internal request
clocks have unequal Base/input/output boundaries and are diagnostic only.

Use one CPU3, serial root-owned targets, one native worker/GPU off, same filesystem.
Ordinary requests:60s/2GiB RSS; full source:300s/6GiB with16GiB available-memory
floor. At least192MiB disk reserve (256MiB full source). Deduplicate only newly
produced exact-equal C via hard links, keeping every sample path and raw logs.
Preserve failures. Report all cases, ratios, variation, memory and both point
and original-source geometric weighting; do not combine full self with small
sources or claim held-out coverage. No Clang/image rebuild in compiler clocks.

Runner: [compare.py](../../selfhost/tools/performance/phase105/compare.py).
Results will be recorded in [the report](../../implementation/phase105/README.md).

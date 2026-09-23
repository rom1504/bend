# P6-001: residual cost in the consolidated compiler

Recorded 2026-09-23 02:50 UTC, before execution. Domain: diagnostic profile of
the Phase 5 equality-derived checked compiler, not a new speed measurement.

Hypothesis: after native string equality removes the demonstrated repeated
comparison reconstruction, checking/annotation still pay substantial generic
trampoline, allocation and substitution/index costs. Prior B1 and private-H
profiles describe different artifacts and cannot identify this residual.

Use the already bounded Phase 4 inspector launcher, unchanged: one frozen
60,909-byte compiler-core library, CPU2, Node24.18, stack4MiB, heap3GiB,
10ms sampling, at most180seconds including Base preparation. Actual emitted
bytes must equal the existing core oracle SHA016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186.
If the source/API pairing produces a different correct output, preserve the
failed oracle attempt and investigate before revising the expectation.

The current derivative is e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a,
with genuine checked parent5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667.
Use frozen final host/runtime and canonical pinned Base. Capture tool/config,
inputs, profile, spans, emitted bytes and exact commands. Verify derivation
before launch and consumed files after completion. Retain any failed or
incomplete attempt. A single profile gives priorities, not removable-cost
ceilings or statistical speedups. Broad backend correctness may overlap;
therefore process/API wall times and sample weights cannot establish a controlled
comparison with earlier profiles. Do not add nested API spans.

Decision: rank concrete code paths, then choose the cheapest ablation/counter.
Do not change production compiler source in this diagnostic. Do not reopen
rejected general normalization memoization, one-site substitution workers or
accessor-only layout rewrites without a new discriminating mechanism.

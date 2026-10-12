# P70-001: general root-preserving observers

Registered before Phase70 execution. Domain: compiler-written-in-Bend native
host lowering. Baseline: Phase69 typed10 (`674e7960…`), upstream `0592662`.

Hypothesis: a bounded branch-local identity analysis can prove one/two immutable
roots are returned unchanged and produce a read-only scalar observer, eliminating
reconstruction for unrelated programs as well as the motivating Map paths.

First falsifier: analysis-only admission/refusal on actual typed erased bodies;
no native emission changes yet. Reject altered fields, non-tail residual calls,
unknown effects/layouts, escaped borrowed values and erased demanded failures.
Then checked-only integration with raw/device fallback and explicit error/poll
and ownership controls. Measure against current Phase69, not compiler23.

Correctness: not run. Measurement: not run. Decision: investigate/implement
sequentially as authorized. The earlier saved-C 0.909× Map result is a hypothesis
target, not a Phase70 result. [Design](../../design/phase70/observers-and-compilation.md).

# P46-001: does the generated-program gap persist with C?

Frozen proposal, 2026-10-04. Correctness: not run. Measurement: not run.
Decision: investigate, with no compiler promotion.

Use the [Phase46 design](../../design/phase46/backend-comparison.md) to compare
the same six bounded Bend workloads across upstream/selfhost and JS/C. A large
native gap would falsify the simple claim that choosing JavaScript alone causes
our relative execution deficit. Separate native runtimes and lowering pipelines
prevent treating this comparison as a single-factor causal experiment.

Outcomes and exact limitations will be recorded in
`implementation/phase46/README.md`. Root owns serial supervised execution;
agents inspect workload selection, invocation and interpretation independently.

# P4-014: Full-source inspector sampling

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Rejected**.
- Evidence: Failed/incomplete; timing invalid.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Obtain full-source exclusive CPU samples to guide structural optimization.

The [detailed report](../../implementation/phase4/report.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Reached 1,800-second deadline without a usable profile. Concurrent scheduling failures occurred; causality is unproven. No speed conclusion retained.

## Next action and reopening criterion

Use bounded small-source profiling (≤180 seconds, 3 GiB, ≤128 KiB inputs) and cheap counters; expensive full builds are validation, not discovery.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

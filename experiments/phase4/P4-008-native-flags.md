# P4-008: Native PGO and compiler flags

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Deferred**.
- Evidence: Measured; exact full-source and native semantic gates passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Reduce native runtime cost with PGO, O3 or ThinLTO without source algorithm changes.

The [detailed report](../../implementation/phase4/native-opt.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

PGO full-source mean 280.227→254.775 s, 9.1% less, but roughly nine minutes setup and approximately 23-compilation repayment. O2 remains default.

## Next action and reopening criterion

Consider PGO for stable repeated validation images. Rebuild profiles for changed native C; do not reuse stale profile claims.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

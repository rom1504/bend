# P4-010: Memoize private weak-head normalization

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Rejected**.
- Evidence: Measured; exact outputs and reused-request gates passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Cache complete normalization results using both immutable book and term identity.

The [detailed report](../../implementation/phase4/private-wnf-memo.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

39.2% repeated pairs; core 27.752→28.977 s, 4.4% slower in all three pairs; peak RSS +2.9%.

## Next action and reopening criterion

Do not revive from hit counts alone. A successor needs cheaper lookup or a costly eligible subset, and a memory-retention argument.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

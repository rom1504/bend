# P4-006: Direct private tag comparisons

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Rejected**.
- Evidence: Measured; exact outputs passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Replace reviewed compiler-tag comparisons with direct strings inside the private boundary.

The [detailed report](../../implementation/phase4/tag-comparisons.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Real core 40.297→40.398 s, slightly slower; small examples improved only 1–2%.

## Next action and reopening criterion

Reopen only after a changed representation or profile makes comparison cost material.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

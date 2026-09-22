# P4-005: All/ADT weak-head shortcut

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Rejected**.
- Evidence: Measured; semantic controls passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Skip generic evaluator entry for literal All/ADT terms already in weak-head normal form.

The [detailed report](../../implementation/phase4/analysis-normalization.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

H list-sort v1 5.709→5.665 s; v2 5.337→5.261 s. Larger B1 pipeline inconsistent despite isolated annotation improvement.

## Next action and reopening criterion

Do not rerun the same shortcut. A successor must eliminate more than the cheap evaluator entry or demonstrate a different workload bottleneck.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

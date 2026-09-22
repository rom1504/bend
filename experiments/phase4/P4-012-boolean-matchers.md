# P4-012: Specialize exact private Boolean matchers

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Pending**.
- Evidence: Measured; 300 controls and 24 exact samples passed; review/broad gates pending.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Reuse the two immutable Bool.and partial handlers and specialize Bool.not while preserving first-argument demand and original fallback.

The [detailed report](../../implementation/phase4/private-booleans.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Real core 28.115→25.874 s, 8.0% less; tree/list 4.2%/4.4% less. Private image only.

## Next action and reopening criterion

Independent review, combined stability ablation, full-source output/memory gate and broad exact frontend sweep.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

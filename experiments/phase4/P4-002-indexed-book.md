# P4-002: Indexed final-definition selection

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Accepted**.
- Evidence: Measured; independently audited; final-source gates passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Replace repeated filtering with an exact name index above a measured-size threshold while preserving last-definition order and unrelated initial duplicates.

The [detailed report](../../implementation/phase4/book-final-real.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Real 3,212-event compiler book: B1 2.151→0.115 s, 18.75× for this component. Malformed UTF-16 requires the original fallback.

## Next action and reopening criterion

Retain threshold and collision/error-order controls. Do not extrapolate the component ratio to compilation.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

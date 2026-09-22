# P4-007: Share private nullary values

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Deferred**.
- Evidence: Measured; independent boundary review passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Reuse frozen Nil/Unit values to reduce internal construction without changing public identity semantics.

The [detailed report](../../implementation/phase4/nullary-values.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

List sort improved 7.6%, but real core only 1.4%; one of three core pairs was flat/slower.

## Next action and reopening criterion

Prioritize larger and more consistent gains. New evidence must include real-core and retained-memory effects.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

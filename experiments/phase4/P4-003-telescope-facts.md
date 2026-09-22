# P4-003: Reuse substitution-invariant telescope suffixes

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Accepted**.
- Evidence: Measured; independently audited; complete fixed point passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Prove that substitution leaves an immutable term structurally unchanged and reuse that fact through literal All suffixes, after checking the first argument.

The [detailed report](../../implementation/phase4/analysis-telescopes.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Real H core 53.545→42.908 s, 19.9% less. Earlier v2 changed three first errors; v3 fixes demand order. Stability is not a normalization identity.

## Next action and reopening criterion

Complete final comparative measurements. Raw host mutation is outside the typed immutable input contract.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

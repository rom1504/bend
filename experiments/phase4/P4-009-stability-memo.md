# P4-009: Memoize completed private stability facts

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Pending**.
- Evidence: Measured; direct and reused-request gates passed; broad gates pending.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Cache the pure context-free Boolean fact by immutable KTerm identity, with weak keys and no exception/in-progress caching.

The [detailed report](../../implementation/phase4/private-stable-memo.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

89.2% repeated identities yield only 6.1% less real-core time (29.000→27.226 s); do not equate cache hits with avoided runtime.

## Next action and reopening criterion

Combine with P4-012 only after independent review. Measure full-source memory/time and broad exact frontend behavior before promotion.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

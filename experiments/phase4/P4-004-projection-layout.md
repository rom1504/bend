# P4-004: Projection copies and direct child access

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Deferred**.
- Evidence: Measured; exact immutable-shape controls passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Isolate projection array copies and list traversal before considering a whole term-representation rewrite.

The [detailed report](../../implementation/phase4/representation.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Clean warm H tree 3.185→3.134 s; list 6.421→5.800 s for combined prototype. Large operation counts did not imply dominant time.

## Next action and reopening criterion

Private direct accessor calls were pursued in P4-001. A new layout needs evidence beyond operation counts and a complete ABI migration plan.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

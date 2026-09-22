# P4-011: Flatten ordinary partial-call chains

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Rejected**.
- Evidence: No eligible sites; no timing claim.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Collapse statically known ordinary function partial chains while preserving eager evaluation and overapplication order.

The [detailed report](../../implementation/phase4/private-booleans.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Zero qualifying chains in the actual combined H; preparation rejected the unchanged image before benchmarking. Seven semantic controls passed.

## Next action and reopening criterion

Reopen only for changed generated code or a separately proven matcher strategy; P4-012 is such a narrower successor.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

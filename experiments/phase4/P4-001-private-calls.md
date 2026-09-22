# P4-001: Private compiler calling convention

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Accepted**.
- Evidence: Measured; exact output and boundary gates passed.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Generic apply/force and argument copying dominate H runtime samples; specialize only compiler-owned calls behind a text-only worker boundary.

The [detailed report](../../implementation/phase4/private-image.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Tree 2.957→2.095 s; list 5.384→3.776 s; real compiler core 52.212→34.651 s in the retained clean matrix. Startup can erase small-request gains.

## Next action and reopening criterion

Full-source comparison of the final combined-source private image; keep public mutable function ABI unchanged.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

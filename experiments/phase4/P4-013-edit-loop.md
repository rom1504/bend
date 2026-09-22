# P4-013: Checked B1 rebuild and persistent focused validation

Recorded: 2026-09-22. Phase 4 migration checkpoint, 17:13 UTC.

- Decision: **Accepted**.
- Evidence: Measured genuine CLI workflow; all observations match prior candidate.
- Scope: the exact artifacts and workload in the linked report; this record does not expand that scope.

## Hypothesis and test

Use a checked development B1 and bounded reused compiler sessions so full self-reproduction is an integration gate, not each edit.

The [detailed report](../../implementation/phase4/development-final.md) supplies the implementation, controls, consumed input/tool identities, cache/resource policy, samples and retained failures. Its linked evidence is authoritative for numeric values and reproduction commands.

## Observation and decision

Final-source actual bootstrap 20.735 s plus first 21-case paired CLI 16.483 s =37.217 s of child wall. Reused validation median9.328 s. Full frontend remains a separate broad gate.

## Next action and reopening criterion

Keep exact diagnostics, fresh request graphs and pinned reference/provenance checks; measure user-visible workflow rather than compiler-only subintervals.

## Record history

This capsule was added after the experiment to index existing evidence; it is not a claim of preregistration. Original design, run reports, failed attempts and Git history remain intact. Append a new run or linked successor when evidence changes; do not overwrite a rejected run.

# P41-004 — Two-worker frontend validation gate

- Status: proposed validation workflow change; fresh two-worker main and broader runs are pending.
- Baseline: frozen Phase40 frontend gate and existing reference acquisition; candidate comparison starts from the exact Phase41 checked image if compiler changes are promoted.
- Design: [validation latency proposal](../../design/phase41/validation.md). Current evidence: [validation implementation record](../../implementation/phase41/validation.md).

**Hypothesis.** Exactly two persistent candidate workers can reduce frontend correctness elapsed time while retaining all 3,026 main and 196 broader comparisons, the established observations, exact path/layout comparisons, worker health checks, and the frozen four-worker reference.

**Cheapest disproof.** Run main and broader serially with the reviewed successor and required aggregate resource bounds. Reject the scheduling change if counts, outcomes, health, or exact comparisons differ; if the run exceeds its bound or cannot stay within memory/CPU limits, preserve the failure and return to the unchanged one-worker gate. Do not drop cases or relax the oracle.

**Observed checkpoint.** Existing Phase40 acquisition receipts are 784.390 seconds for main and 37.354 seconds for broader; they are historical context, not the denominator for a new speed claim. Phase41 has no fresh two-worker run in the ledger snapshot. Report enclosing job time, memory peak, and health from fresh receipts before deciding.

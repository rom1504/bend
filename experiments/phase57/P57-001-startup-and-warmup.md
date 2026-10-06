# P57-001: compiler startup versus repeated execution

Hypothesis: loading and early V8 tiering explain much of B2's additional cost.
Measure actual API import, first ordinary library request and three subsequent
requests with the same driver. Keep API-keyed Base disk caches separately primed.
If the repeated-request gap remains, startup is not a complete explanation.

[Design](../../design/phase57/compiler-performance-attribution.md).
Results and the executed scope belong in
[Phase57](../../implementation/phase57/README.md). No production change is proposed.

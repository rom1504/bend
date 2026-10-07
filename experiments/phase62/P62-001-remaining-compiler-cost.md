# P62-001: explain excess compilation work

Status at registration: investigate; no source optimization selected.

Hypothesis: the residual compilation gap includes avoidable repeated term and
analysis work, rather than one uniform allocation or JavaScript-backend deficit.
Contrast current B2 with pinned TS and same-source checked B1, separate stages,
and measure operation counts. A similar work count with higher time per operation
would redirect effort toward representation/generated code; repeated work would
favor sharing, dependency-scoped queries or environment-based evaluation.

[Design](../../design/phase62/compiler-parity-investigation.md).
Outcomes will be recorded in [the report](../../implementation/phase62/README.md).

Correctness: retain original images and complete emitted-byte checks.
Measurement: separate clean timing, CPU samples, allocation samples and counters.
Decision: investigation only; no release or compiler-source change in this phase.

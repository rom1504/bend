# P63-002: validate each shared node once

Status at registration: transport implementation in progress; no target executed.

Hypothesis: a schema-validated positional DAG reduces parse/allocation/validation
cost relative to frame2 while carrying more useful prepared state. Record bytes,
decode plus mandatory validation, preparation and whole-request time separately.
Malformed constructor/scalar/reference data must fail closed or discard optional
state. Old frame compatibility and the trusted-local provenance contract remain.

The rejected binary decoder is the negative control, not supporting evidence.
Stop or revise if reconstruction costs erase whole-request benefit.

[Design](../../design/phase63/ready-world-and-lowering-plan.md) ·
[Report](../../implementation/phase63/README.md).

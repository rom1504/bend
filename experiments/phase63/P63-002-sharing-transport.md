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

State05 evidence overturns the warm-only result: first-process generic decoding
regresses cache time (~153→179ms), while complete requests still improve through
world reuse. Fixed constructor validation/objects remove that regression in a
same-image host experiment. V2 passes206 accepted and1331 rejected differential
cases with exact rejection messages and real graph alias preservation.
Two alternating rounds, both byte-exact: Numeric453.61/474.89→350.59/356.27ms;
Map1491.09/1344.18→1202.35/1221.53ms. These are small diagnostic campaigns, not
TS parity or a production selection. State06 integrates the reviewed V2 decoder
for checked-image qualification. Raw: `selfhost/build/phase63/decoder-v2-controls01.json`
and `state05-host-fastv2/confirm/report.json`.

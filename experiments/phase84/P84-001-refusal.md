# Actual-refusal short circuit

This experiment index is retrospective; the [Phase84 design](../../design/phase84/replace-native-work.md) was committed before these prototypes.

Hypothesis: Skip construction after an actual private worker refusal, retaining scheduler behavior and error precedence.

[Patch](prototypes/refusal.patch) · [Notes](../../implementation/phase84/refusal-notes.md)

Checked B1 attempt: `selfhost/build/phase84/compiler01/attempt.json`.
Exact-source snapshot and checked API are bound by that receipt.

Correctness, measurement and promotion are separate decisions. Follow the
[phase report](../../implementation/phase84/README.md) for completed results and
rejected/failing predecessors. No installed change is implied by a passed screen.

[Initial screen](../../implementation/phase84/screen01.json): two rounds, fresh requests, exact C.

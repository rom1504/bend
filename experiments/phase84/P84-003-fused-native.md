# Coupled native annotation and erasure

This experiment index is retrospective; the [Phase84 design](../../design/phase84/replace-native-work.md) was committed before these prototypes.

Hypothesis: Construct existing annotated and erased body products together, removing a later recursive erasure walk. Retains Ann for existing consumers; partial fusion only.

[Patch](prototypes/fused-native.patch) · [Notes](../../implementation/phase84/fused-native-notes.md)

Checked B1 attempt: `selfhost/build/phase84/compiler04/attempt.json`.
Exact-source snapshot and checked API are bound by that receipt.

Correctness, measurement and promotion are separate decisions. Follow the
[phase report](../../implementation/phase84/README.md) for completed results and
rejected/failing predecessors. No installed change is implied by a passed screen.

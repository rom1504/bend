# P48-005: Entry checks and profitability

Status: investigation; no measurement or promotion claimed.

Hypothesis: Reduce temporary guard allocation or reject unprofitable source shapes while retaining every required host observation.

Design: [mechanism](../../design/phase48/entry-profitability.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

Outcome and receipts will be appended with their original attempt identities.

## Measured outcome

The allocation-free raw-entry diagnostic passed its independent mutation/reentry
and ordinary-value audit. Its 45-sample screen gains 1.039× at 128 steps, is
adverse at 4096 (0.993×), and nearly neutral at 8192 (1.002×). Production
integration is deferred; the unsafe admission-bypass result remains only an
upper bound. [Outcome and exact ranges](../../implementation/phase48/entry-profitability.md).
The optimized-body-only host-footprint idea was rejected: original generic
invocation/forcing can observe omitted protocols even when the private body
cannot. No safe mask derivative was released or executed.

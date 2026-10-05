# P48-002: Scalar values across private calls

Status: investigation; no measurement or promotion claimed.

Hypothesis: Eliminate executed nonescaping state tuples crossing private calls while preserving demanded fields and shared persistent consumers.

Design: [mechanism](../../design/phase48/aggregate-transport.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

Outcome and receipts will be appended with their original attempt identities.

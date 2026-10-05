# P48-001: Known target/capture transport

Status: investigation; no measurement or promotion claimed.

Hypothesis: A renamed factory/helper/callback chain becomes first-order while prefix demand and capture aliasing remain exact.

Design: [mechanism](../../design/phase48/higher-order.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

Outcome and receipts will be appended with their original attempt identities.

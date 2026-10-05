# P48-001: Known target/capture transport

Status: completed and deferred; representative acquired modules are unchanged.

Hypothesis: A renamed factory/helper/callback chain becomes first-order while prefix demand and capture aliasing remain exact.

Design: [mechanism](../../design/phase48/higher-order.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

H02 passed 26 complete oracles and 39 boundary observations. Actual Morning and
closure acquisitions emitted byte-identical array06 modules with no H entries,
so a further timing campaign was unnecessary. The 406-line prototype is preserved
outside selected source. Factory diagnostics identify matched recursion and a
partial-binding stage as the missing general admission, not an implemented win.
See the [outcome](../../implementation/phase48/higher-order.md) and
[next bounded experiment](../../implementation/phase48/remaining-opportunities.md).

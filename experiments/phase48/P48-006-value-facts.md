# P48-006: Literal and value propagation

Status: umbrella investigation completed through two concrete selected slices;
no separate general value-analysis framework was added.

Hypothesis: Use static typed value facts to remove actual repeated loop work without losing public demand or host fallback.

Design: [mechanism](../../design/phase48/composable-representations.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

The concrete continuations are [finite F32 literals](P48-007-private-f32-literals.md)
and [native String values](P48-008-native-string-values.md). Their actual-entry,
semantic and timing evidence stays separate; the common idea is not counted as
another gain. RNFA04 also carries bounded direct-count provenance for a decline-only
profitability check. Broader JW constant propagation remains future work and
cannot erase observable shared-view writes. See the
[phase report](../../implementation/phase48/README.md).

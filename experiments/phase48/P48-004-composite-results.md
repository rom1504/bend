# P48-004: Owned public result adaptation

Status: checked candidate and scoped controls/entry/screen passed; no promotion.

Hypothesis: Admit structural composite results and materialize their public representation without changing tags, sharing or mutation.

Design: [mechanism](../../design/phase48/composite-results.md);
[overall contract](../../design/phase48/composable-representations.md).
Baseline: Phase47 array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
runtime `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.

Falsifier: changed observable value/error/order/alias; no actual private entry or
removal of executed work; unfavorable runtime/compiler/size tradeoff on independent
sources. Diagnostic ablations do not qualify compiler source changes.

Outcome: original-handle private region plus one final public record shell.
No raw array escape, wrapper identity registry or shared runtime edit was needed.
Independent static review passed. Root's checked-composite01 API is
`bec513e634527dd292834811e5875e36c40b5c7873dfe4ebc326e74a4c40ec3c`,
with the unchanged baseline runtime above. composite-controls02 passes 30 independent
value oracles and 6 boundary traces plus executed fast/fallback/refusal witnesses.
Actual maintained row.probe counter passes 1 fast/0 fallback and expected four-array
Dp result; its observations.json is valid JSON with a real final newline.

The fresh three-round composite-screen01 reports generic row 0.385457→0.0306253 ms,
12.586x baseline gain and 4.353x pinned TypeScript time; local-pair is neutral
(1.44921→1.44195 ms). Short warmups, row half-drift up to -22.94%, and two points
limit this to a screen. No broad qualification or installed-release claim follows.

Exact receipts, recomputed medians and limitations:
[implementation](../../implementation/phase48/composite-results.md),
[data-only evidence](../../implementation/phase48/evidence/composite-results-screen.json),
[checked attempt](../../selfhost/build/phase48/checked-composite01/attempt.json),
[controls](../../selfhost/build/phase48/composite-controls02/report.json),
[actual entry](../../selfhost/build/phase48/composite-row-entry01/observations.json),
[screen](../../selfhost/build/phase48/composite-screen01/report.json).

Next narrow coverage candidate is canonical flat Sigma/Tuple results with only
scalar/Array fields and exact native public Tuple layout. It is unimplemented;
require its own dependent/nested refusal, alias/mutation and executed-entry
controls rather than extending raw escape or assuming another gain.

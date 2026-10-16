# P102-001: attribute the text win before changing representation

Status: mechanism supported; integrated candidate under native qualification.
Registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: iterative append on the existing linked String ABI removes most
renderer continuation cost while preserving current graph/index consumers.
Compare with Phase101 chunk-plus-append using identical complete fixtures.
Then test adaptive small strings/cursors only when profiles identify a need.

First gate: full-byte renderer and graph controls; then independent shared,
static, full-U32, Array and parallel String controls and all 50 application inputs.
Record construction/destruction ownership and fail closed on adapter mismatches.
No application-specific replacement or release promotion from intervention alone.

Result: linked-storage iterative append removes26.4% of complete one-worker
renderer time in the first four-round screen, with RSS about81→53MB. Copy/free
still removes19–22%, so continuation elimination explains most of the benefit.
Global chunks retain graph regressions and are not selected. The final compiler
uses generic constructor-loop lowering instead of an append-name intrinsic.
Its isolated single-cell reuse adds5.6–7.4% renderer improvement over the same
TRMC parent in six alternating rounds. Exact full-U32/shared/parallel controls
pass; actual Bend-produced products pass all50 application inputs.

Evidence: `phase102/linked-append01`, `linked-copy01`, `linked-controls01`,
`reuse-pair01`, `reuse-controls03`, and `reuse-bend-broad01` under `selfhost/build/`.
See [report](../../implementation/phase102/README.md) and
[TRMC mechanics](../../implementation/phase102/trmc.md) for caveats and lineage.

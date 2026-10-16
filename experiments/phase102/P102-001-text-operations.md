# P102-001: attribute the text win before changing representation

Status: registered 2026-10-16. [Campaign](../../design/phase102/ambitious-native-campaign.md).

Hypothesis: iterative append on the existing linked String ABI removes most
renderer continuation cost while preserving current graph/index consumers.
Compare with Phase101 chunk-plus-append using identical complete fixtures.
Then test adaptive small strings/cursors only when profiles identify a need.

First gate: full-byte renderer and graph controls; then independent shared,
static, full-U32, Array and parallel String controls and all 50 application inputs.
Record construction/destruction ownership and fail closed on adapter mismatches.
No application-specific replacement or release promotion from intervention alone.

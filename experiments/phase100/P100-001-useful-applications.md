# P100-001: application usefulness beyond bootstrap speed

Status: measured; no compiler change or promotion.

[Design](../../design/phase100/useful-applications.md) ·
[Report](../../implementation/phase100/README.md) ·
[Results](../../implementation/phase100/results.json).

Hypothesis: a source tool, numerical image application and irregular dependency
planner expose different practical constraints, so full self-compilation speed
alone is insufficient to choose the next engineering objective. Workloads were
selected by task/data behavior before timing them.

All three compile through installed native B1/B2 and pinned upstream. Native
stage C pairs agree; 50 distinct inputs pass 318 complete-output executions.
The larger graph workloads take 0.33–0.36× upstream C time, source indexing about
2.15× on the compiler source, and complete image rendering about 1.35× with one
worker. Four-worker rendering gives about 2× acceleration; an identical-image
single-tile control does not accelerate. Full source/ranges/clocks are in the
report; these are finite workloads, not general language-speed claims.

Our emitted C is 3.0–3.5× larger and takes 2–3.5× upstream Clang time to build.
Prepared Base makes own compiler requests shorter here, but downstream Clang
cost makes complete application builds slower. Native imports, provider scope,
whole-file input and process-error status also constrain usability.

Decision: retain the apps and independent references as a first-class loop.
Profile text/index/rendering before a general representation change; preserve
graph and parallel correctness. Treat graph indexing as an application-algorithm
opportunity. Frozen fixture replay avoids expensive Python reference regeneration
and provides a roughly 10-second repeated substantial-renderer check.

Compiler source/images/selection, existing conformance and formal-law scope are
unchanged. Preserve rejected preflight sources, Python compatibility failure,
case-selection typo, and all timing observations including outliers. Earlier
oracle identities and full expected outputs are recorded; later runs also retain
exact oracle snapshots. No new PR comment.

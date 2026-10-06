# Phase54: backend cleanup and direct compiler-image qualification

Work in progress; the installed compiler remains Phase53 ordered02. The user
authorized shared-helper separation, explicit bootstrap routing, scalable direct
analysis and controlled compiler-image migration, preserving the native backend.

[Design](../../design/phase54/backend-cleanup-and-direct-bootstrap.md) ·
[Backend boundaries](../../docs/self_hosted/backend-boundaries.md) ·
[Shared helpers](shared-helpers.md) · [Routing](routing.md) ·
[Independent review](review.md).

## Completed first stage

Thirty-four helpers moved with unchanged names and function bodies: 27 semantic
queries into three common modules, and seven JavaScript formatting/path helpers
into one shared JS utility. Direct JS no longer takes these helpers from the
legacy emitter modules. The migration adds 19 physical header/separator lines;
it does not claim a reduction in semantic code. All native source is unchanged.

The helper-only checked build completes in **61.607 seconds**, peaking at
**1,504,722,944 bytes** process-tree RSS. Its strict 36-witness frontend gate
passes, and its generated compiler API is **byte-identical to Phase53**:
`3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`.
Runtime and driver are unchanged. Eight representative direct benchmark points
were freshly acquired; all eight emitted modules match the selected Phase53
bytes (seven distinct modules including the complete-row observer, six checked
source files). The first comparator incorrectly treated archived baseline paths
as loose files; its failure and consumed method are retained, and a reviewed
successor uses the maintained archive reader.

Two maintained compiler-image commands now explicitly select `--legacy-js`.
Six grouped host-only routing checks and syntax checks pass. This fixes omitted
selectors; it does not by itself establish a self-emitted compiler fixed point.

The initial independent graph controller passes 14 cases against the unchanged
algorithm in the helper-only checked image, in 3.719 seconds including process
startup. The successor graph implementation and compiler-image probes are still
under qualification. No new performance ratio or installation is claimed here.

## Qualification and publication policy

Use exact compiler and emitted-program identity where changes are organizational.
The graph replacement requires independent fact comparisons, scale controls and
fresh semantic/native checks. A changed generated program needs its own measured
performance evidence; unchanged output can retain the baseline's dated evidence.
The direct compiler-image route requires separate API, resource and self-emission
gates before migration. Legacy compatibility remains available.

Raw evidence is under `selfhost/build/phase54/` while writers remain active.
Final publication will retain failed attempts and selected evidence in one closed
archive. The 103 inherited unrelated files are protected. No PR comment is posted.

# Phase83 compilation work investigation

Date: 2026-10-13. Production baseline: Phase82 at `8042809`; upstream pin
`059266225b77c8ca256ac6b25ee5c21449bab151`. Three agents investigated different
mechanisms, with all target execution coordinated serially by root.

| Study | Local evidence | External implementation lessons |
|---|---|---|
|[Pipeline comparison](pipeline-comparison.md)|Public stages, source/index/report work and definition-count/warmth sweep|Go demand-driven loading; LLVM analysis scopes and grouping|
|[Representation replacement](representation-replacement.md)|Existing retained products, annotation consumers and newly measured rejected workers|Zig AIR/liveness; Cranelift construction and completion boundaries|
|[B1/B2 stage gap](stage-gap.md)|Generated code census, CPU/heap attribution and refreshed allocation samples|V8 specialization; Lean runtime-oriented types; Flambda2 control continuations|

The research changes the priority: test general early refusal of doomed worker
routes before committing to a broad native representation rewrite. B1 closure
overhead is a separate opportunity. Cold frontend timing requires further
attribution; no quadratic parser diagnosis is established.

See the [integrated report and estimates](../../../implementation/phase83/README.md),
[design](../../../design/phase83/compilation-work-investigation.md), and
[methods](../../../selfhost/tools/performance/phase83/README.md). Research source
links, read dates, moving-source limitations and failed retrievals stay in each
study. No external compiler benchmark or borrowed speed multiplier is claimed.

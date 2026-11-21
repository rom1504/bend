# Local producer retention and physical register placement

Frozen before physical timing. Each candidate applies the same rule to all eligible repeating regions in private p113d workers. A full-width store to a private scalar spill starts an admitted interval only if every later occurrence of that slot is a direct load in the same repeated straight-line block, with no other stores or address materialization. Prior history cannot flow into such a first complete definition. Multiple snapshots sharing a new home must occupy disjoint intervals. Calls and unknown or implicitly clobbering operations are barriers. Existing producer retention needs no free register. The more general arm uses whole-function physical-register liveness to reject occupied RCX/RAX/R10/R11 homes, including live-through branches and implicit call/return effects.

| Program and predeclared result | Rationale |
|---|---|
| editdist, producer-only faster than baseline | Three snapshots survive in their producing GPRs in the heavily sampled row worker. Its repeated body drops six frame operands and four instructions. |
| editdist, physical at least as fast as producer-only | One more RCX interval drops two memory operands but preserves instruction count. This is a weaker prediction. |
| Mandelbrot, producer-only approximately neutral | Its numeric mit and hchunk bodies do not change. Incidental library and harness changes may move layout. |
| Mandelbrot, physical faster than baseline | Two RCX intervals remove four repeated mit frame operands and three hchunk intervals remove six. Static instruction counts remain identical. The potential gain comes from changing store-forwarded stack lifetimes to register moves. |

Two GAS layouts, independently reconstructed baseline for each, four paired rounds; input/output comparisons against unchanged current direct products and mature C. Every family, layout, role and negative observation will be reported. An arm clears the initial family gate only if median elapsed time is at least 2% shorter than its own layout baseline in both layouts and at least three of four paired observations favor it in both layouts. Results cannot establish interaction with the separate orbit portfolio, broad performance or independent replication. [Frozen identities](hot-freeze.json) · [Full static census](hot-placement.json).

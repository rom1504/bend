# H6: local copy and width facts

Prediction: bounded straight-line aliases and known-zero upper halves allow copy propagation and removal of redundant U32 publication. A recognized full-word binary operation followed by its own `& 0xffffffff` can become U32 arithmetic only for add/sub/mul/and/or/xor; shifts keep their original semantics.
The mechanism is [expression-reuse.bend](../../selfhost/src/back/x86/expression-reuse.bend), with a 512-statement admission bound and at most 32 aliases. Writes invalidate dependent aliases; control edges and calls clear facts; unknown width cannot justify deleting truncation. This transforms admitted IR, not arbitrary machine text.
[Source receipt](../../selfhost/build/phase190/local-api-source01/manifest.json) freezes SHA-256 `f8a49abb69798cfb0c49356bf875d7f2c41f368a741da4cacf6f1ba407d8d544`. [Emission](../../selfhost/build/phase190/local-emit01/report.json) enables local values over the caller-first bundle; [build](../../selfhost/build/phase190/local-build01/report.json) retains exact-output program observations.
[local-controls01](../../selfhost/build/phase190/local-controls01/report.json) passes **nine structural controls and 1,400 independent C observations on each of two machine routes**. Fixtures bypass earlier simplification and exercise invalidation, width, wraparound and shift boundaries. No complete semantics theorem follows.

Actual [runtime05](../../selfhost/build/phase190/runtime05/report.json) / [summary](../../selfhost/build/phase190/development-summary05.json): **3.868291× C**, **0.866739× baseline (13.326% lower time)**, **0.967037× caller (3.296% lower time)** geometric mean. Four roles and four rounds balance positions.

| Case | Local / caller | Local / frozen baseline |
| --- | ---: | ---: |
| local-fold | 0.924041 | 0.808693 |
| numeric-recurrence-256 | 0.968675 | 0.839789 |
| ray-active-64-2440 | 0.905032 | 0.825011 |
| map-churn-32 | 0.979926 | 0.892205 |
| expression-32 | 1.007500 | 0.889667 |
| tree-bitonic | 1.022556 | 0.953290 |

Retain the **+0.750% expression and +2.256% tree regressions versus caller**. Expression’s baseline max/min spread is **1.119617×**, above 1.10×; it stays included. No case regresses versus the frozen baseline, but all six still exceed 2× C. No significance claim.
Mean positive log slowdown versus C is **1.352813**. Fixed-equivalent sums are **6,419.230 ms local / 6,704.000 ms caller / 7,441.852 ms baseline**. Hosted preparation/selection/object intervals are **29.832659 / 19.572428 / 6.952904 s**, not native compiler-throughput measurements.
No local-only static machine recount is credited here. Six development cases only; final held-out metrics, native qualification and installation are pending or unestablished, not inferred from this screen.
Later complement/coalescing controls or checked APIs do not supply runtime results for those changes through runtime05; their final contribution remains pending.

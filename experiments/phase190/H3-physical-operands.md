# H3: select physical operands directly

Prediction: avoid scratch-register copies when alias and width facts allow direct register/memory operands. The [baseline machine audit](../../implementation/phase190/baseline-machine.md) identified nine local-copy opportunities (66→57 static-instruction target); this was a prediction, not a measured candidate result.
The mechanism is [register-binary.bend](../../selfhost/src/back/x86/register-binary.bend) with related physical selection paths. [Source receipt](../../selfhost/build/phase190/operand-api-source03/manifest.json) freezes SHA-256 `b6d97fbf9e3e763e34f3a1fd25d21f076ea4367525adce94f26dd8171582c76f`.
[Emission](../../selfhost/build/phase190/operand-emit01/report.json) enables physical operands over policy-2/liveness/branch selection; [build receipt](../../selfhost/build/phase190/operand-build01/report.json) records exact native45 oracle checks. Failed [operand-api01](../../selfhost/build/phase190/operand-api01/report.json) remains distinct from accepted [operand-api02](../../selfhost/build/phase190/operand-api02/report.json).
[operand-controls01](../../selfhost/build/phase190/operand-controls01/report.json) passes the large-offset structural row and **25,766 independent observations on each of direct-object and assembler routes**, including source/destination aliases, widths, arithmetic, shifts, comparisons and memory operations.

Actual [runtime02](../../selfhost/build/phase190/runtime02/report.json) / [summary](../../selfhost/build/phase190/development-summary02.json): **0.949344× baseline**, **4.234034× C**, and **0.980763× alpha** geometric mean. All six remain >2× C. Fixed-equivalent sums are 7,172.959 ms operands versus 7,519.858 ms baseline.
**Four roles were timed for only three rounds: role positions are unbalanced.** Treat the incremental differences as exploratory; no significance claim or balanced-ablation conclusion.

| Case | Operands / alpha | Incremental time change |
| --- | ---: | ---: |
| local-fold | 0.932283 | −6.772% |
| numeric-recurrence-256 | 1.003013 | +0.301% |
| ray-active-64-2440 | 1.012102 | +1.210% |
| map-churn-32 | 0.980664 | −1.934% |
| expression-32 | 0.940664 | −5.934% |
| tree-bitonic | 1.019417 | +1.942% |

No operand case regresses versus frozen baseline, but three regress versus alpha. Fold is only **0.996248× baseline**, with C spread **1.110000×** and baseline spread **1.122549×**; it stays included. Alpha fold remains 1.068611× baseline in this same screen.
Hosted preparation/selection/object intervals total **29.254927 / 19.571195 / 6.931040 s**; these single observations do not establish compiler-throughput gains. No operand-only static recount is credited; the later [39/2 audit](../../selfhost/build/phase190/machine-audit-joint02/report.json) belongs to the integrated bundle.
Decision: retain the finite controls and exploratory gain with all regressions/dispersion; proceed to balanced integrated development checks. No held-out, native compiler qualification or installation.
A new local-copy/width experiment is planned; its predicted further cleanup has no measured result in this record.

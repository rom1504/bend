# H4: unified nine-color allocation

Prediction: share a bounded interference plan across four saved and five caller registers, avoiding the artificial split that leaves usable homes idle. Preserve reserved state/output/scratch homes, call-crossing restrictions, incoming ABI constraints and a validated fallback.
The mechanism is [loop-liveness.bend](../../selfhost/src/back/x86/loop-liveness.bend). [Joint source receipt](../../selfhost/build/phase190/joint-api-source02/manifest.json) freezes SHA-256 `885f4cc96d444b255ddfdc2a26530c2f9c8d1660954701fc5d34e1d7bf483871`; failed [joint-api01](../../selfhost/build/phase190/joint-api01/report.json) precedes accepted [joint-api02](../../selfhost/build/phase190/joint-api02/report.json).
[Emission](../../selfhost/build/phase190/joint-emit01/report.json) combines policy 2, liveness, physical operands, branch selection, repeated-predicate reuse and unified allocation. **This is an integrated bundle, not an allocation-only ablation.**
[integrated-controls01](../../selfhost/build/phase190/integrated-controls01/report.json) passes 18 joint, 16 register, 29 branch, 14 liveness and one operand structural rows plus 12 independent machine-route executions. The width group has zero structural rows and a 280-observation machine oracle per route. [Joint fixture](../../selfhost/tests/phase190/joint-controls.bend) tests nine distinct homes, call restrictions, interference, reserved homes, checker refusals and fallback; finite checks do not prove general allocator correctness.
[Build](../../selfhost/build/phase190/joint-build01/report.json), [runtime03](../../selfhost/build/phase190/runtime03/report.json) and [summary](../../selfhost/build/phase190/development-summary03.json) bind six exact-output development programs to the observations.

Actual: bundle geometric mean **0.902469× baseline (9.753% lower time)**, **4.016364× C**; fresh baseline is 4.450419× C. Four roles and four rounds balance positions; no sample spread exceeds 1.10×. No baseline regression is observed.

| Development case | Bundle / baseline | Bundle / C |
| --- | ---: | ---: |
| local-fold | 0.881057 | 6.836880 |
| numeric-recurrence-256 | 0.864976 | 3.174002 |
| ray-active-64-2440 | 0.938023 | 3.113835 |
| map-churn-32 | 0.913018 | 4.721053 |
| expression-32 | 0.898560 | 2.715369 |
| tree-bitonic | 0.921179 | 4.845850 |

All six still exceed 1.1× and 2× C. Mean positive log slowdown versus C is **1.390377**; versus baseline it is zero. Fixed-equivalent workload sum is **6,692.985 ms** versus **7,355.193 ms** baseline (0.909967×). QBE’s same-screen geometric mean is **1.533350× C**, showing substantial remaining distance.
[Machine audit](../../selfhost/build/phase190/machine-audit-joint02/report.json): fold positive path **66→39 instructions**, **21→2 frame references**; whole function 190→147 instructions. These are static counts for the bundle, not independent allocation savings or cache-miss measurements.
Hosted source preparation/selection/object intervals are **29.400787 / 19.525693 / 7.022019 s**. Selection remains above the first baseline API’s 14.724725 s; single acquisitions across runs are not matched native compiler-cost experiments.

Decision: the bundle merits further development inspection, but **~9.7% is not an isolated causal allocation gain**. Runtime01 fold regression and runtime02 imbalance/incremental regressions remain retained in [H1](H1-registers.md) and [H3](H3-physical-operands.md); later improvement does not erase them.
No held-out cases yet, native compiler qualification, general proof, promotion or installation. A new local-copy/width experiment is planned; no further benefit is credited before its own controls and measurements.

# H1: weighted placement and bounded liveness

Prediction: loop-weighted and invariant/parameter-weighted placement should reduce repeated scalar frame traffic while preserving fixed-home legality. Bounded liveness can keep compatible loop values in registers; unsupported or rejected plans retain fallback behavior.
Source mechanisms are [regalloc.bend](../../selfhost/src/back/x86/regalloc.bend) and [loop-liveness.bend](../../selfhost/src/back/x86/loop-liveness.bend). These live files may evolve; the measured alpha identity is the [candidate API source receipt](../../selfhost/build/phase190/candidate-api-source09/manifest.json), source SHA-256 `e087364c4a2ca5a4109cec3361b98acad045148188f2221e3ce38c89128c27a5`.
[Alpha emission](../../selfhost/build/phase190/candidate-emit01/report.json) freezes policy 2, liveness and branch selection enabled, physical operands disabled. This is a combined candidate, not an isolated policy-0/1/2 runtime comparison.

[controls01](../../selfhost/build/phase190/controls01/report.json) passes 16 register, 18 branch and 14 liveness rows plus six independent machine-route executions. Register observations include reserved homes, competing values and score saturation; liveness controls cover incoming ABI, calls, interference, dead writes and narrow live sources. This finite evidence is not a general correctness proof.
[Build](../../selfhost/build/phase190/candidate-build01/report.json), [runtime01](../../selfhost/build/phase190/runtime01/report.json), and [authenticated summary](../../selfhost/build/phase190/development-summary01.json) connect the exact machine products to six development programs.

Actual: alpha is **0.968552× frozen baseline** (3.145% lower geometric-mean time), **4.360254× C**; baseline is 4.501827× C. Five cases improve; fold regresses **1.082804× (+8.280%)**. All six remain >2× C.
Positive mean log slowdown is 1.472530 against C and 0.013259 against baseline; no alpha case exceeds 1.1× baseline. Fixed-equivalent workload sums are 7,240.237 ms alpha versus 7,501.885 ms baseline.
Three rounds balance the three role positions. Tree-bitonic alpha spread is **1.151220×**, above 1.10×; it remains included. These samples do not establish significance.
[Machine audit](../../selfhost/build/phase190/machine-audit-alpha02/report.json): fold positive path **66→59 instructions**, **21→10 frame references**, yet whole-program fold slows. No cache-miss or proportional-speed inference follows.
[Hosted API costs](../../implementation/phase190/first-screen.md): six-case typed selection rises **14.724725→20.145993 s (+36.817%)**; source preparation is 29.992174→29.355918 s. These single acquisitions are separate from runtime and native compiler throughput.

Decision: retain the mechanism/control evidence and the negative fold result; investigate physical transport and allocation interference before transfer. The result does not identify the independent contribution of weighted placement or liveness.
Coverage remains 6/6 development, 0/39 held-out. No native compiler qualification or installation. Later bundled evidence belongs to [H4](H4-joint-allocation.md), not a retroactive H1 ablation.

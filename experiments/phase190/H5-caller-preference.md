# H5: prefer legal caller registers

Prediction: try caller registers first when the joint allocator’s existing interference, incoming-ABI and call-crossing checks admit them; reduce unnecessary saved-register use without weakening legality. Fallback still searches the complete legal pool.
The mechanism is `x190_j_choose` in [loop-liveness.bend](../../selfhost/src/back/x86/loop-liveness.bend). [Source receipt](../../selfhost/build/phase190/caller-api-source01/manifest.json) freezes source SHA-256 `30e2aceafc805150a3b1d8b1799e47f9beb730b6fc42dbdb70ea66f79ca20f8f`.
[Emission](../../selfhost/build/phase190/caller-emit01/report.json) adds `x190_caller_first_enabled=True` to the integrated joint bundle; [build](../../selfhost/build/phase190/caller-build01/report.json) retains independent program oracles.
[caller-controls01](../../selfhost/build/phase190/caller-controls01/report.json) passes 78 structural rows across register/branch/liveness/operand/joint groups and 12 independent machine routes, including width observers. These finite controls do not establish allocator correctness for every input.

Actual [runtime04](../../selfhost/build/phase190/runtime04/report.json) / [summary](../../selfhost/build/phase190/development-summary04.json): caller is **3.994628× C**, **0.898097× baseline**, and **0.996276× joint** geometric mean. The same-run incremental reduction is only **0.372%**; this small screen does not establish significance.
Four roles and four rounds balance positions; no >1.10× dispersion flag. Fold regresses **0.143% versus joint**; map is unchanged; numeric, ray, expression and tree decrease approximately 0.233%, 0.930%, 1.137% and 0.071%.
All six are still >2× C, with no baseline regression. Mean positive log slowdown against C is 1.384950. Fixed-equivalent sums are **6,659.990 ms caller / 6,690.499 ms joint / 7,370.105 ms baseline**.
Hosted source preparation/selection/object intervals are **30.263044 / 20.809466 / 7.280719 s**, versus joint’s earlier 29.400787 / 19.525693 / 7.022019 s. These unreplicated acquisitions are separate from runtime and do not establish a compiler cost improvement.
No caller-only static machine-count reduction is credited; [joint’s earlier audit](../../selfhost/build/phase190/machine-audit-joint02/report.json) is not a recount of this candidate.

Decision: retain the explicit ablation and small negative fold result; use as the parent for the bounded local-value experiment without overstating the 0.372% difference. Six development cases only; held-out transfer, native compiler qualification and installation remain unestablished here.

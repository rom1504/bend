# Phase186 final ray profile

Final native-N2 ray CPU is 4.478923s versus 7.114400s in the earlier sixth checked-B1 profile: 0.629557× remaining total work (37.04% less). Each campaign has one separate clean observation, so this is a descriptive cross-campaign comparison, not a paired timing or causal result. The coordinator reports native-N2 products match checked-B1 emission; this metadata audit does not independently repeat that equivalence gate.

Both profiles pass their recorded quality gates: final 899 accepted samples (556 at 8ms, 343 at 13ms), earlier 1,401 (866/535); zero dropped samples, overruns, rejected captures or unknown leaves. Both accepted final capture windows cover over 99.93% of child CPU. The 343-sample capture is below 500 individually; the recorded pooled 899 passes. Sampling/clean wall ratios are 0.99724 final and 0.97723 earlier.

| Physical leaf/group | Earlier share | Final share | Estimated CPU earlier→final | Final/earlier work |
|---|---:|---:|---:|---:|
| p111_rt_op | 21.69% | 6.35% | 1.5430→0.2846s | 0.1845× |
| nearest workers | 51.64% | 56.15% | 3.6738→2.5148s | 0.6845× |
| sphere accessors | 15.96% | 24.06% | 1.1356→1.0776s | 0.9489× |
| trace | 6.36% | 8.03% | 0.4525→0.3595s | 0.7946× |
| pixel | 4.20% | 5.00% | 0.2988→0.2238s | 0.7490× |

Shares use sample-period weights. Estimated owner work is share×that campaign’s clean CPU; dividing final work by earlier work avoids mistaking a larger residual share for a slowdown. Estimates have no confidence intervals. In particular, accessor share grows while its combined estimated absolute work is approximately retained; individual accessor changes are too sparsely sampled to diagnose regressions.

The largest remaining owners are `$product.nearest` (40.25%, 1.8027s) and `$direct.nearest.t` (15.90%, 0.7120s). The four sphere accessors together are 24.06%. Primitive helpers fall to 6.35%, so private worker instructions and accessor call/comparison/frame costs now dominate the measured residual. The profile alone does not split remaining primitive samples by opcode or prove a next optimization’s benefit.

[Final comparison](../../selfhost/build/phase186/release-ray-profile01/plan/comparison.json) · [Earlier comparison](../../selfhost/build/phase186/profile-candidate-ray01/plan/comparison.json) · [Pinned analysis and identities](final-profile.json). JSON pins both reports, summaries, owner maps, each accepted capture analysis and both actual executable images. No programs were executed for this analysis.

# Candidate physical profile and bounded probes

The sixth assembly active-ray profile passes both periods independently: 866 samples at 8ms and 535 at 13ms, zero dropped/overrun/unresolved samples, and minimum whole-child CPU coverage 99.944%. The single clean capture consumed 7.1144 CPU seconds. Sampling captures were about 2.3% shorter than that observation; this is not a sampling-overhead or speed comparison.

| Physical leaf | Period-weighted share |
|---|---:|
| `$product.nearest` | 36.88% |
| `p111_rt_op` | 21.69% |
| `$direct.nearest.t` | 14.76% |
| `$product.trace` | 6.36% |
| Sphere accessors `sr/sz/sx/sy`, combined | 15.96% |
| `$direct.pixel` | 4.20% |

Generic primitive dispatch remains a material physical cost. Its 21.69% share bounds removing that helper alone while holding other work fixed; it is not a predicted speedup. No callers, dispatch contexts or runtime event counters were captured, so the helper cannot be attributed dynamically to particular operations or source owners. Exact ELF/FID binding passes; source ownership remains lexical and conditional. The retained Phase185 profile set contains QBE/C `raytrace` at input80/0 and x86 local-fold, not the present x86 active-ray256/2240. No compatible old ray profile exists in that retained set for a direct delta. Details and pins: [profile-candidate-ray01-analysis.json](profile-candidate-ray01-analysis.json).

The caps-only base and widened probes have **zero string or H-admission differences** across 14 queried owners: 172 record rows and 13 Unicode rows are identical. Map seek/get/put/ins workers have 1037/966/946/2037 owner nodes and fit the new2048 cap, but all retain H=0 and closure8=0. Every listed continuation suffix fits the old128 cap (maximum listed15); the four large-owner inventories are truncated after32 names and are not exhaustive. Both sets of boundary controls pass. The isolated size-cap change supplies no new admission witness in these contexts. Details: [caps-probe-comparison.json](caps-probe-comparison.json).

The six-round generic-row replication gives candidate/before **0.9721525**, or **2.78475% less runtime**. Before max/min spread is1.20%, candidate0.69%, C2.83%; all18 timed outputs and six pilots revalidate. This resolves the earlier apparent46.4% result as contaminated; the original measurements remain retained. Details: [generic-recheck-analysis02.json](generic-recheck-analysis02.json).

`selfhost/tests/phase186/analyze-runtime.py` is ready for the final full45 report. It verifies frozen catalog identities and exact sample output/counts, recomputes summaries, retains all cases, and flags sample max/min spread above10% for review. It emits per-role GM, equal-family/source GM, positive log deficits, >1.1/>2 counts, fixed-catalog projections and positive excess, plus optional same-campaign and explicitly labeled historical normalized comparisons. It has been checked against the retained405-sample/433-pilot Phase185 full45, the unstable fourth screen, and the stable six-round repeat. No target jobs were executed by this analysis work.

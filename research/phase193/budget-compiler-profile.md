# Final budget compiler-request profile

The final same-input map/set request has clean wall medians 5.905192 s baseline
and 5.308902 s candidate: **0.899023×, or 10.098% less**. Clean CPU medians are
5.860488 and 5.269106 s (0.899090×). This compares Phase192 N2 with Phase193
budget N2: compiler source and generated implementation both differ. It does
not isolate the machine effect or measure full compiler self-build.

Evidence is `selfhost/build/phase193/budget-compiler-profile01/{report,comparison,
findings}.json`, with recipe and roles in `budget-compiler-profile-plan01`.
Offline verification rehashed 114 unique retained pins and all twelve complete
stdout/stderr captures. Every request reproduced its own role's validated
object, with empty stderr and successful exit. Inputs were unchanged. Baseline
and candidate objects intentionally differ (587720 and 598440 bytes).

The clean evidence is small: baseline observations are 6.243525 and 5.566859 s;
candidate observations are 5.447748 and 5.170056 s. The baseline spread is
material. Sampling/clean wall ratios are 0.9493 and 0.9808; these are diagnostic
ratios, not negative sampler overhead. Do not turn this campaign's 10.098% into
a more precise general request improvement than the separate four-request
measurement supports.

The maintained comparison accepts pooled physical profiles: 2243 baseline and
2073 candidate samples, both periods present, no rejected captures, no dropped
samples or overruns, and adequate whole-child CPU coverage. **The original run
still has `profilesUsable=false`:** each 13 ms capture has fewer than the
individual 500-sample threshold (baseline 427/426; candidate 392/393). Pooled
adequacy is the comparator's existing rule, not a changed threshold or a claim
that those individual captures passed. Unknown weighted shares are 1.900% and
0.283%; unresolved samples remain in the denominators.

Physical groups, scaled by each role's clean CPU median:

| Group | Baseline share / CPU s | Candidate share / CPU s |
| --- | ---: | ---: |
| Generated Bend symbols | 50.97% / 2.9871 | 52.65% / 2.7739 |
| Ownership/product helpers | 17.14% / 1.0043 | 18.27% / 0.9627 |
| Reclamation | 14.27% / 0.8362 | 16.25% / 0.8563 |
| Other physical helpers | 10.82% / 0.6344 | 8.89% / 0.4684 |
| Scheduler | 3.57% / 0.2093 | 2.27% / 0.1195 |
| Allocation | 1.33% / 0.0778 | 1.39% / 0.0735 |
| Unresolved | 1.90% / 0.1114 | 0.28% / 0.0149 |

The scheduler leaf `work_loop.constprop.0` falls from approximately 0.2093 to
0.1195 CPU s. `p111_rt_sink` falls 0.2180→0.1559 s; `p125_rt_take2` falls
0.3367→0.3001 s. These observations are consistent with reduced dispatch and
runtime transition work. They are physical samples, not dynamic call counts or
a causal allocation of the total timing gain. The unresolved reduction alone
is about 0.0965 estimated CPU s and cannot be assigned to an optimization.

String and index work remains prominent. Borrowed
`p113d_FID_$p118borrow.read.p88_string_eq_go` rises from approximately
0.3642 to 0.4319 CPU s (6.21%→8.20%), borrowed `String.order.go` from
0.2238 to 0.2677 s (3.82%→5.08%), and borrowed `index_hash` from
0.1921 to 0.2256 s (3.28%→4.28%). `term_drop` remains the largest physical
leaf at 0.5541→0.5470 s; `span_fade` rises 0.2821→0.3093 s. The improvement
therefore does not demonstrate faster string loops or uniformly lower helper
cost. Shares and scaled estimates may reflect changed executed plans, layout,
sampling variation and the clean-baseline spread. Generated names identify
physical symbols, not inclusive source owners; no dynamic invocation counts
were collected.

This diagnostic complements the separate final qualification/runtime/request
receipts; it does not replace them. There are no confidence intervals or causal
speedup estimates, and no research-acceleration claim follows from these data.

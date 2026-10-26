# Final03: actual serial-runtime residual profile

The full final03 N2 capture passes its clean-output replay oracle and exact
stage/FID binding: **8,681 samples, zero drops/overruns, 99.497% sampled-thread
coverage of process CPU**. This is the actual final03 program object linked to
the diagnostic **serial** runtime, not the earlier atomic-runtime image.
[Derived evidence and method](final-profile.json) pin the complete receipts.

The input remains frozen Phase142 source `15f5cada…7dac1`. Final03 emits
115,966,145 bytes (`ac29be09…abd36`), matching its clean same-image request.
It legitimately differs from the old source01 output. Diagnostic child wall is
279.524 s, process CPU279.313 s, and the disjoint stage sum279.352 s. The outer
guard's approximately287.32 s also includes observer/harness work. Clean
standalone execution is251.861 s; the diagnostic/clean ratio1.1098 is one
observation, not a precise or constant instrumentation-overhead estimate.

The optional final verifier occurs once. Its10.081-second interval is nested
in observer work and must not be added again. There are443 unresolved active
source-owner samples and393 unresolved physical-function samples; all stay in
the denominators. All389 selected-libc eligible callers are recovered, but the
other8,292 callers are unknown. This is not a logical Bend call stack.

## Three measured engines, not three isolated treatments

| Disjoint diagnostic partition | Phase143 | Source01 atomic | Final03 serial |
| --- | ---: | ---: | ---: |
| Frontend through erasure |117.000 s|94.833 s|88.448 s|
| Admission/static/raw lowering |50.806 s|44.819 s|43.436 s|
| Initial optimizer and first independent verifier |64.031 s|64.431 s|56.247 s|
| Observer work and selected final admission |28.434 s|25.150 s|23.352 s|
| Registry |18.284 s|17.400 s|17.651 s|
| Render/output/teardown |51.845 s|47.831 s|49.962 s|

These engines differ in source, generated code, runtime and diagnostic layout.
The observations locate remaining costs but cannot apportion every change to
one optimization. In particular, the clean source01 serial-runtime observation
249.679 s used a different compiler image from final03's251.861 s. That small
difference from one observation each is not an established compiler regression.

Final03's largest finer intervals are parse/load33.411 s, checking/publication
33.826 s, raw lowering37.578 s, initial optimizer37.352 s, first independent
verification18.895 s and output49.962 s. The earlier algorithmic removals persist:
`f_find` has31 active samples, compared with480 in Phase143; the old ownership
scan has zero, compared with610. Do not budget another removal of those scans.

## The important new discriminator: append preflight costs

`p125_rt_concat_typed` now has **147 physical samples** including its cold
outline, approximately4.704 diagnostic CPU-equivalent seconds at32 ms/sample.
Of those,133 occur inside rendering: **8.81% of its1,509 interior samples**.
Rendering still shows127 destination-extension,120 take2 and75 destination-fill
samples. The guarded splice has not removed the fallback reconstruction category
from this whole computation.

Only56 concat samples retain the active `String.append` owner; synchronous
private execution can keep the outer owner instead. Neither that difference nor
the physical samples reveal actual success/refusal frequencies, call counts,
or a guaranteed recoverable4.7 s. But the new helper is now the largest physical
leaf in the output interval, while output itself increased by2.13 diagnostic
seconds from source01. This supplies a concrete reason for the coordinator's
bounded append-admission ablation and eventual fragment-write experiment.
The previously measured Unicode wins do not establish that every compiler
renderer benefits from the same preflight.

## Runtime improvement exposes the remaining representation cost

| Physical family | Source01 samples/share | Final03 samples/share |
| --- | ---: | ---: |
| Drop + fade |2,246 /24.53%|1,479 /17.04%|
| Take helpers |922 /10.07%|990 /11.40%|
| Constructor helpers |424 /4.63%|467 /5.38%|
| Register helper plus its recovered libc callers |612 /6.68%|622 /7.17%|

Serial reference counts correspond to much less measured drop/fade work, but
do not eliminate product unpack/reconstruction or register transport. The
remaining source families are `p111v_*`1,222 samples (14.08%), index/map
helpers504 (5.81%), string append/equality727 (8.37%) and `nc_uses_term/list`
186 (2.14%). Physical and source families overlap; these percentages must not
be added. Private calls also prevent interpreting active names as exclusive
function-body timings.

There is no newly demonstrated single optimization capable of supplying the
remaining approximately5× compiler-only gain. The strongest interpretation is:

1. **Finish the bounded profitability ablations already under way.** The new
   concat evidence supports selective removal/refinement before adding another
   allocator mechanism. Keep the unchanged fallback and independent outputs.
2. **Preserve compact local identities through complete computations.** The
   initial optimization/verifier budget is now56.25 s, and verification helpers
   remain14.08% of samples. The earlier compact-verifier slice is evidence for
   a representation experiment, not permission to add its11.06% to whole-request
   gains. Charge producer conversion, branch state and teardown.
3. **Remove whole output materialization boundaries.** Registry plus output is
   still67.61 diagnostic seconds. Additional naming/index tweaks alone cannot
   establish a50-second build. Reuse existing ordered fragments and test a
   bounded generic byte-marshalling sink with exact output/error semantics.

No new large architectural rewrite is justified by this capture alone. The
specific new finding is an optimization's preflight becoming a visible cost
inside the full renderer, alongside persistent reconstruction and transport
after the atomic-count cost fell.

This is **final03 only**: it does not measure proposed final04 append-policy
removal, outer-range omission, or prefix-disjoint batch changes. The reported
4.74% cold result and2.6-second batch exposure from those separate experiments
cannot be combined with these stage clocks or called properties of this image.
New variants require their own identities and matched evidence.

Offline reproduction:
`python3 -B selfhost/tools/performance/phase144/profile/final-summary-v1.py`
in an isolated replay copy with a fresh `research/phase144/final-profile.json`.
The method refuses overwriting evidence. No targets were run for this analysis.

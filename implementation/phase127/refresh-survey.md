# Profile refresh after live-register-bank repair

This offline refresh joins 24 repaired-compiler sample captures and three event
captures, plus 32 samples and six event captures from ordinary Mandelbrot and
tree-bitonic programs. It adds no target executions. All inputs come from
completed, correct-output runner receipts with unchanged input identities.

The compiler reuses its original Phase126 owner map under the explicit
`live-bank-full-comparison01.json` evidence: checked full QBE differs only in
descriptor capability 1 → 5. Attribution still validates every linked FID
pointer against that map; no duplicate 40MB owner map is needed. The new ordinary
programs have their own checked owner maps.

The [compact summary](refresh-survey.json) pins source receipts, comparison
evidence, tools and detailed reports. Full attribution and method snapshots
occupy **8.5MB** under `selfhost/build/phase127/refresh-survey01/`. Raw samples,
runtime events and owner maps remain in their original locations.

## Remaining compiler work

Across **5,502 delivered samples**, the repaired compiler has **zero sampled
libc fill instructions** in the authenticated regions. All three event captures
request **zero register-clear words**. This is consistent with the repaired
capability and leaves a clearer view of the remaining costs. Clean speedup and
same-source semantic qualification are reported separately by the coordinator.

| Request | Delivered samples | Known dispatch owner | Remaining owner-family shares |
| --- | ---: | ---: | --- |
| lexer | 1,925 | 1,836 | index 22.20%; Base decoder 15.27%; verifier 14.33%; String 14.15% |
| Map churn | 3,047 | 2,910 | String 17.99%; index 9.99%; Base decoder 9.96%; `nq_uses*` 9.89% |
| closures | 530 | 496 | Base decoder 48.86%; String 6.36%; index 5.18% |

Shares weight every sample by its actual period and retain unknowns in the
denominator. Each individual capture remains short; pooling crosses the
500-sample threshold for each repaired-compiler fixture but does not create
confidence intervals or an inclusive call graph.

Physical reclamation leaves remain **28.89% of lexer**, **24.46% of Map**, and
**12.84% of closures**. Ownership/product helpers account for another 15.88%,
19.40% and 20.30%. By contrast, allocator-entry leaves account for only
1.07%, 1.54% and 1.60%. Allocation *volume* therefore should not be mistaken
for time spent inside the allocator. Eliminating intermediate values can still
remove construction, ownership, traversal and reclamation together.

The strongest next experiments remain:

1. Extract the exact authenticated Base carrier decode. It is nearly half the
   small closure request's diagnostic profile and persists after clearing is
   removed. Preserve canonical-input checks and the frozen cold-request metric.
2. Investigate borrowed verifier/index observations and repeated name/hash work
   for lexer. A useful transformation must reduce measured ownership/reclamation
   work while retaining the independent final verifier.
3. Test early saturation or reusable legal use summaries for Map's `nq_uses`
   traversal. Its roughly 10% active-context share survives the repair.
4. Investigate name comparison and temporary string construction across larger
   requests, using both emitted-text and analysis workloads as transfer tests.

`p126bp_*`/`p113pl_*` active-context shares remain small. This still cannot settle
their **inclusive** preparation costs: separately dispatched descendants acquire
their own context. A whole-pass ablation or separate phase context is needed.

The new `entrySegmentDispatches` field also prevents a misleading call count.
For example, `p88_digits` has **1,087,899 direct-entry dispatches** per request;
the larger 3,376,728 count includes all segments owned by that definition.
Neither metric counts every source invocation, inlined call or loop iteration.

## The profiler distinguishes ordinary program shapes

The uninstrumented Mandelbrot program spends **65.85%** of weighted physical
samples in generated Bend symbols; its `$direct.mit` worker alone accounts for
26.65%. Only 1.01% is in ownership/product helpers. Counter instrumentation
records **72,442 allocation calls**, **zero frame pushes**, and 11,780,608
dispatches. Active diagnostic contexts concentrate in `rcol` (41.75%), `rpix`
(35.16%) and `hchunk` (16.80%). Synchronous workers retain the outer context, so
these contextual names are complementary to the physical `mit` leaf.

Tree-bitonic has a different profile: **25.16%** of baseline samples execute
ownership/product helpers, including `p125_rt_ctor2` at 11.16% and
`p125_rt_take2` at 10.37%. It records **25,200,954 allocation calls** and
**5,037,870 frame pushes**. `warp` owns 84.997% of allocation calls; `flow` owns
11.675%. Diagnostic contexts concentrate in `warp` (54.46%), `flow` (29.39%)
and `warp_node` (6.33%). This points toward complete tree reconstruction and
continuation/ownership work, rather than the arithmetic-focused Mandelbrot
opportunities.

Both programs have just eight `term_drop` entries despite very different
allocation volumes. Their product-take and reclamation counts—tens of thousands
in Mandelbrot and tens of millions in tree-bitonic—show why `term_drop` entries
alone are an incomplete measure of destruction.
These controls demonstrate general profiler applicability; they are not a
representative benchmark-suite result or a new compiler speed claim.

## Instrumentation cost and determinism

All overhead below uses raw runner rows separated by explicit mode. It does
**not** pool context-only runs with counter-enabled runs. Baselines are the
medians of three uninstrumented process-CPU observations.

| Mode versus ordinary uninstrumented binary | Mandelbrot | tree-bitonic |
| --- | ---: | ---: |
| Leaf/CFI sampling only | +0.80% | +0.93% |
| Diagnostic dispatch context, unsampled | +5.16% | +12.18% |
| Diagnostic dispatch context plus sampling | +5.50% | +12.24% |
| Runtime event counters enabled | +25.04% | +90.34% |

Clean median CPU times are 0.777402s and 1.033182s. Mandelbrot has one slower
0.962743s baseline observation; three repetitions do not establish a tight
uncertainty interval. Sampling also can alias, and adding context instrumentation
changes code layout: Mandelbrot's weighted fill share changes from 6.81% to
13.26%, despite a much smaller total diagnostic-runtime overhead. Treat such
bucket shifts cautiously and use uninstrumented sampling for physical costs.

For each ordinary program, **all three runtime-event files are byte-identical**,
including every per-FID counter. Counts are reproducible but not free: the
tree's 90% counter overhead is a strong reason to collect event volumes
separately from clean timing. Zero loss does not remove instrumentation bias.

Every refreshed capture preserves unknown samples, short-capture quality flags,
receipt identity and exact linked-FID binding. Physical callers, active dispatch
contexts, lowered owners and entry-segment counts remain separate observations.

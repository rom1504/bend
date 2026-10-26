# Final04 generated-program quality

**The observed row32 regression is fixed, and all45 frozen timed wrappers pass
their complete output checks.** Final04 reproduces the original Phase143 program
object for44 of45 cases. The remaining RLE object retains the already measured
improvement. These object comparisons isolate code generation; the selected
serial runtime differs from the original Phase143 atomic runtime.

There is **no fresh final04 full-corpus geometric mean**. We reused exact machine
identity where justified, then measured the changed cases. The earlier2.60%
geometric improvement belongs to final03's controlled full campaign and must not
be relabeled as a fresh final04 score.

## What was checked

The actual final04 N2 compiled all45 historical repetition-wrapper sources using
the frozen source paths and prepared Base. These are the44 timed programs plus
the original zero-work control, not the separate ordinary native45 suite.
Every resulting selected-runtime executable passed a fresh complete-output and
success-count check.

Thirty-five products—including34 timed cases—match the prior selected-runtime
machine products exactly: all loaded ELF sections have the same bytes, sizes and
addresses, except GNU build ID. Their four observations each are explicitly
**inherited** from the earlier campaign. Object reuse required complete QBE byte
equality; changed QBE was built before machine comparison. The inheritance
priority was fixed before reading timings, not selected for favorable results.

Ten remaining products restore the original143 object but use the selected
serial runtime, so their earlier atomic-runtime timings cannot be inherited.
The coordinator approved eight alternating pairs for precisely these ten cases.
All160 observations pass. Counts, warmups, arguments and output oracles are
unchanged. No full720-observation campaign was repeated.

## Fresh results and the tradeoff

Row32 compares the original143 atomic product against final04 with the serial
runtime: **509→505ms**, ratio0.9921; final04 is faster in seven of eight pairs.
This removes the previously reproduced8.79% regression. It is a complete-product
comparison, not an isolated runtime or code-generation estimate.

The other nine comparisons use the same serial runtime in final03 and final04:

| Program | Final03 median | Final04 median | Change | Slower pairs /8 |
|---|---:|---:|---:|---:|
| Morning |575.5ms|590.5ms|+2.61%|7|
| Evening |1084.5ms|1078.5ms|−0.55%|2|
| Map/set operations |803ms|800ms|−0.37%|2|
| Unicode text16 |260ms|270ms|+3.85%|6|
| Unicode text64 |262ms|275ms|+4.96%|8|
| Map churn32 |567.5ms|565ms|−0.44%|1|
| Map churn128 |547ms|546.5ms|−0.09%|4|
| Record aggregation64 |490ms|489.5ms|−0.10%|1|
| Record aggregation256 |488.5ms|484ms|−0.92%|1|

Restoring the general append behavior therefore gives up some interim gains in
Morning and Unicode, while fixing the larger row32 regression. Unicode64's
slowdown appears in all eight pairs. The small differences elsewhere are
descriptive observations, not confidence intervals or guarantees of improvement.
Final04 is not uniformly faster than final03.

The separate raytrace concern did not reproduce: eight pairs gave371ms for both
candidate and fast products. Their complete objects and loaded machine sections
were already identical. More generally, omitting the outer range pass changed
QBE text but preserved the whole program object for all45 prior wrappers; its
earlier0.81% geometric timing difference is not evidence of changed computation.

## Evidence and cost

[Complete summary and identities](final04-quality.json) contains every case,
all eight paired ratios and the exact original receipt pins.
The [receipt capsule](evidence/final04-receipts.tar.gz) and
[inventory](evidence/manifest.json) retain the original metadata, methods, frozen
corpus and complete outputs for the45 fresh checks,140 inherited observations
and160 fresh measurements. Large binaries and generated code are omitted; their
identities remain pinned. The [static audit](flagged-product-audit/README.md)
documents the8→26-instruction append-wrapper regression and raytrace identity.

Final04 wrapper emission/build/check took109.39 guarded seconds. The targeted
timing took91.73s: **201.12s additional guarded work**, after compiler acquisition
and qualification. The earlier full campaign, its deadline recovery, and agent
effort are additional costs. This gate establishes evidence for these frozen
programs; it does not establish a new upstream ratio or full-language correctness.

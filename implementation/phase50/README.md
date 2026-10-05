# Phase50: checks are widespread, but do not explain every slow program

This information-only survey profiles **all 45 maintained points / 23 sources**
using unchanged RNFA04 output and complete original result oracles. Nothing was
fixed, rebuilt, bypassed or installed. No new clean speed comparison is claimed.

## Main findings

Named guard routines and their sampled descendants account for **over 50% in
11 points**, **over 25% in 17**, and **under 5% in 16**. The 11 are included in
17; these are descriptive point counts, not independent source counts or a
prediction for every possible Bend program. Guard ancestry counts each sample
once and includes native reflection reached through a guard.

| Example | Guard ancestry, sampled % | Interpretation |
| --- | ---: | --- |
| Scalar region, zero iterations | 78.9 | Fixed entry cost dominates |
| Scalar region, 8192 iterations | 2.7 | Computation amortizes entry |
| Closures64 / closures256 | 78.6 / 75.9 | Strongly optimized body leaves guards dominant |
| List pipeline128 / 512 | 72.4 / 58.8 | Same effect, even at larger size |
| Numeric recurrence256 / 1024 | 68.8 / 52.8 | Guard cost remains substantial |
| RLE | 75.1 | Reproduces the earlier diagnosis approximately |
| Morning / Evening | 0 / 0 | Generic dispatch and matching dominate instead |
| Map/Set operations | 14.0 | Mostly generic runtime, with some guarded subroots |
| Expression128 | 27.4 | Producer/evaluator and allocation also matter |
| Edit distance / raytrace | 0.2 / 0.5 | Mostly computation in private workers |

The existing Phase48 clean results already show closures256 and list512 beating
TypeScript. High guard share identifies remaining work even in fast programs;
it does not imply that every such program is slow overall. These fresh RLE sample
percentages and Phase49's are separate observations, not pooled estimates.

## Other causes found with V8

Morning and Evening contain no `exactCode` registration. Their `invokeExact`
frame takes the generic indirect-call branch, so its cost must not be labeled
entry validation. `apply`, `force` and `invokeExact` together account for about
**42.4%, 39.7% and 39.3%** of CPU self weight in Morning, Evening and MapSet.
Matcher callbacks contribute additional time; argument arrays, partial-function
descriptors, projected fields and trampoline objects carry computation between
these runtime functions.

Fresh allocation sampling estimates:

| Program | Bend bytes/call | TS bytes/call | Bend / TS |
| --- | ---: | ---: | ---: |
| Morning | 256,549 | 8,517 | 30.12× |
| Evening | 178,662 | 6,436 | 27.76× |
| Map/Set | 1,361,386 | 46,935 | 29.01× |
| Expression128 | 102,142 | 23,350 | 4.37× |

These are sampled allocated bytes including collected objects and harness work,
not retained heap, exact event counts or execution-speed ratios. Accounting
warnings remain in the raw and summarized evidence.

V8's traces identify a specific obstacle: **`apply` exceeds the bytecode-size
limit for inlining** in Evening and MapSet. It reaches TurboFan itself, and V8
successfully inlines several surrounding helpers, but callers cannot inline this
large dispatcher. All six fresh trace windows contain **zero measured bailouts**;
persistent deoptimization is not supported as the explanation here. The
[pinned-source analysis](generic-dispatch.md) identifies the exact enum, trace
lines, source operations and limits of attribution. No polymorphic-refusal claim
is inferred from this size refusal.

Expression128 has a different cost: it materializes an expression tree with
producer/control frames, then walks it in a separate evaluator. Its producer,
selector, constructors and evaluator contribute about 89% of sampled allocation.
This makes producer/consumer fusion or leaner frame transport a more relevant
hypothesis than a generic-dispatch rewrite for that point.

Larger edit-distance, lexer, symbolic-regression and ray-tracing profiles mostly
identify hot private workers. This screen locates their costs but does not yet
explain every remaining TypeScript gap. We did not collect hardware counters,
IC/map logs or optimizer graphs for every point; allocation plus opt/inlining
traces resolved the main alternative bottlenecks without another graph campaign.

## What this suggests, without implementing it

1. Prove smaller or cheaper fresh guards for already optimized paths.
2. Investigate a smaller common `apply` path and fewer generic argument/matcher
   allocations. The measured inlining refusal motivates this; it does not prove
   that splitting the function is safe or faster.
3. Investigate producer/consumer transport on expression-like programs.

These are separate experiments. Guard removal alone cannot address the roughly
49–62× historical gaps in Morning and Evening. The exact public mutation,
property-access, error and demand behavior still constrains any future change.

## Method and evidence

The [frozen plan](../../experiments/phase50/P50-001-guard-survey.md) precedes targets.
Each initial CPU process warms for at least 1000 ms and samples for 800 ms;
observed windows are 800–847 ms with 627–757 samples. Six string-result points
compare complete strings on every call before consuming their lengths. Four
TS CPU profiles and eight allocation profiles follow; allocation windows target
400 ms. Six separate opt/deopt/inlining traces use documented per-role call
counts derived from historical clean medians. Instrumented timings never become
speed ratios. This is one profile per initial point, with no confidence intervals
or universal coverage claim.

Named guard self percentages exclude native/anonymous descendants; the ancestry
column includes those actually under a guard in the raw profile tree. Both can
miss inline checks or absent frames. GC cannot be assigned to the allocation that
caused it. Generated-other frames include runtime helpers as well as useful work.

All **63 serial target jobs pass**. Target process occupancy totals **137.40 s**;
peak observed tree RSS is **200.04 MiB**. Targets run on CPU3 with a 1024 MiB heap,
2048 MiB RSS ceiling, 4096 MiB available-memory floor and 64 MiB per-output-file
limit, under pinned Node24.18.0. Agents inspect source and evidence; root owns all
executions. The first data-only summary attempt found Python3.10 lacked
`hashlib.file_digest`; its streaming-hash successor completed, with no target
rerun or altered measurement.

The [CPU summary](evidence/cpu-summary.json) independently verifies RNFA04 module,
point and full-oracle membership, raw ancestry and hashes. The
[followup summary](evidence/followup-summary.json) recomputes allocation totals,
trace counts and nonoverlapping process intervals. The
[complete raw archive](../../selfhost/tools/performance/phase50/evidence/raw/archive.json)
contains unchanged copied modules, configs, profiles, logs and consumed tools.
All 103 unrelated files and closed historical evidence are preserved. The
installed compiler is unchanged; no PR comment was posted.

## All 45 CPU observations

Guard ancestry and self are alternative views; do not add their percentages.
Dispatch includes named apply/force/call helpers, not all anonymous machinery.

| Point | Guard ancestry % | Guard self % | Dispatch self % | GC self % |
| --- | ---: | ---: | ---: | ---: |
| `local-pair` | 0.5 | 0.5 | 0.1 | 0.5 |
| `local-fold` | 10.0 | 9.7 | 1.0 | 1.4 |
| `scalar-region-0` | 78.9 | 73.0 | 4.5 | 4.8 |
| `scalar-region-8192` | 2.7 | 2.7 | 1.2 | 0.1 |
| `complete-generic-row32` | 53.2 | 51.2 | 1.4 | 4.1 |
| `mandelbrot` | 31.4 | 30.4 | 1.5 | 2.6 |
| `editdist` | 0.2 | 0.2 | 0.0 | 0.3 |
| `tree-bitonic` | 6.0 | 5.3 | 0.4 | 4.6 |
| `lexer` | 3.5 | 3.5 | 0.8 | 9.7 |
| `symreg` | 4.7 | 4.7 | 0.1 | 1.5 |
| `test-morning-program` | 0.0 | 0.0 | 47.0 | 3.6 |
| `test-evening-program` | 0.0 | 0.0 | 43.5 | 2.7 |
| `test-rle-roundtrip` | 75.1 | 74.1 | 1.8 | 4.4 |
| `test-map-set-ops` | 14.0 | 13.8 | 41.7 | 2.2 |
| `raytrace` | 0.5 | 0.5 | 0.7 | 2.2 |
| `variation-editdist-0-17` | 0.9 | 0.9 | 0.3 | 0.5 |
| `variation-editdist-3-123` | 0.3 | 0.3 | 0.0 | 2.0 |
| `variation-lexer-6-17` | 8.9 | 8.7 | 0.8 | 5.0 |
| `variation-lexer-10-123` | 1.2 | 1.2 | 0.9 | 5.8 |
| `variation-tree-bitonic-6-17` | 25.5 | 25.0 | 1.4 | 4.5 |
| `variation-tree-bitonic-9-123` | 4.4 | 4.4 | 0.1 | 6.2 |
| `variation-symreg-4-17` | 6.7 | 6.5 | 0.4 | 1.8 |
| `variation-symreg-7-123` | 2.6 | 2.6 | 0.4 | 1.4 |
| `variation-local-fold-128-0` | 67.7 | 65.4 | 1.8 | 3.9 |
| `variation-local-fold-8192-123` | 7.1 | 6.8 | 0.4 | 0.6 |
| `variation-mandelbrot-grid-4-7` | 9.8 | 8.6 | 0.6 | 4.4 |
| `variation-mandelbrot-grid-5-31` | 1.0 | 0.9 | 0.3 | 3.1 |
| `variation-ray-active-64-2440` | 12.1 | 11.6 | 0.8 | 2.4 |
| `variation-ray-active-256-2240` | 4.7 | 4.7 | 0.6 | 3.3 |
| `coverage-closures-64` | 78.6 | 76.9 | 2.8 | 3.5 |
| `coverage-closures-256` | 75.9 | 74.8 | 7.0 | 3.7 |
| `coverage-list-pipeline-128` | 72.4 | 69.8 | 2.8 | 3.7 |
| `coverage-list-pipeline-512` | 58.8 | 57.7 | 2.3 | 2.4 |
| `coverage-unicode-text-16` | 51.3 | 50.6 | 2.2 | 2.8 |
| `coverage-unicode-text-64` | 20.0 | 19.8 | 0.5 | 3.2 |
| `coverage-map-churn-32` | 21.7 | 21.0 | 3.2 | 5.5 |
| `coverage-map-churn-128` | 7.6 | 7.5 | 5.2 | 4.2 |
| `coverage-numeric-recurrence-256` | 68.8 | 67.9 | 2.4 | 3.0 |
| `coverage-numeric-recurrence-1024` | 52.8 | 52.2 | 1.3 | 2.2 |
| `coverage-bst-32` | 47.6 | 46.3 | 1.2 | 7.4 |
| `coverage-bst-64` | 32.2 | 30.7 | 1.2 | 10.5 |
| `coverage-expression-32` | 48.5 | 47.7 | 1.5 | 3.5 |
| `coverage-expression-128` | 27.4 | 27.3 | 0.6 | 5.1 |
| `coverage-record-aggregation-64` | 14.7 | 13.9 | 5.6 | 3.4 |
| `coverage-record-aggregation-256` | 2.9 | 2.8 | 5.7 | 3.5 |

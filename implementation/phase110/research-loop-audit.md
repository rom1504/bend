# Phase110 research-loop accounting audit

The saved reports establish faster **worker execution on training workloads**,
not faster discovery of validated improvements. The compiler, emitted workers,
validation harness and research process have different clocks. Phase110 has
not measured an equal-budget frozen-builder versus updating-builder experiment.
This audit reads existing receipts only; it executes no target.

## What the clocks cover

[loop-relink01](../../selfhost/build/phase110/loop-relink01/report.json) relinks
two cached QBE workers and the same cached runtime with an instrumented version
of the frozen training harness. Both pass all eleven semantic cases, once each.
The instrumentation preserves graph contents, alias lifetimes, observations and
release checks. Its original worker clock is unchanged; added boundary clocks
can perturb small operations, so this is diagnostic accounting, not a ranking
experiment. The receipts report:

| Disjoint phase | Fused QBE, ms | Share of outer run | Private runtime IR QBE, ms |
| --- | ---: | ---: | ---: |
| Independent result/alias observation | 351.454 | 52.18% | 349.591 |
| Result and alias release | 131.048 | 19.46% | 131.023 |
| Graph and alias setup | 114.013 | 16.93% | 113.556 |
| Live accounting and context close | 57.029 | 8.47% | 57.072 |
| Worker envelope | 19.723 | 2.93% | 18.971 |
| Context open | 0.207 | 0.031% | 0.211 |
| Bookkeeping/stdout plus pending check | 0.076 | 0.011% | 0.072 |
| **Outer run** | **673.551** | **100%** | **670.497** |

Sources: [fused accounting](../../selfhost/build/phase110/loop-relink01/fused-qbe-accounting.json)
and [private-IR accounting](../../selfhost/build/phase110/loop-relink01/runtime-ir-single-qbe-accounting.json).
The narrower original worker times are 19.722 and 18.969 ms. Phase sums reconcile
to independently subtracted partition marks; outer entry/exit residuals are
748 and 839 ns. Process walls are 690.214 and 672.483 ms, leaving 16.663 and
1.986 ms outside the outer run. That residual includes startup, case selection,
final formatting/flushing and teardown; it is not graph construction. One
instrumented pass does not establish a reliable process-speed difference.

## Worker wins and campaign cost

| Frozen training screen | search01 | final-training01 |
| --- | ---: | ---: |
| Policies × cases × rounds | 12 × 7 × 3 | 7 × 7 × 5 |
| Child executions / total repetitions | 252 / 2,520 | 245 / 945 |
| Campaign wall | 247.683 s | 35.912 s |
| Summed child-process wall | 241.375 s | 31.578 s |
| Summed worker clocks | 6.734 s | 1.175 s |
| Worker share of campaign | 2.72% | 3.27% |
| Campaign minus child walls | 6.308 s | 4.335 s |
| Global winner / geometric mean time ratio to fused QBE | pair-clang / 0.8827 | wrapper-spare-clang / 0.6216 |
| QBE winner / corresponding ratio | specialized-qbe / 0.9515 | stored-field-qbe / 0.7776 |

Sources: [search01](../../selfhost/build/phase110/search01/report.json) and
[final-training01](../../selfhost/build/phase110/final-training01/report.json).
Ratios are geometric means of per-case median **worker-time** ratios, with equal
case weights. They are not aggregate process-time ratios. Final training thus
reports 37.84% lower worker time for its global selection and 22.24% for its QBE
selection under that metric; neither number is a research-throughput result.

The later screen is 6.90 times shorter, but it changes the policy matrix, rounds
and repetition schedule. Its frozen per-case counts are 6, 3, 6, 1, 7, 1, 3,
calibrated from the earlier baseline toward about 5 ms of worker time. The two
expensive source-list cases drop from ten repetitions to one. This supports a
cheaper measurement schedule with unchanged fixtures and observations; it does
not isolate a causal worker-speed effect. Acquisition, compilation, proof work,
candidate authoring, failed attempts and subsequent qualification are outside
these screen timers. Training selection alone is not held-out acceptance.

For fixed nonworker work, Amdahl's bound is
`speedup = 1 / ((1 - f) + f / s)`, where `f` is the worker share and `s` its
speedup. Even eliminating all worker time gives only **1.0302×** for the fused
instrumented run, **1.02795×** for search01, and **1.03383×** for final-training01.
These are conditional ceilings for those measured partitions, not bounds on
optimizing the harness or compiler. Geometric mean training ratios cannot be
substituted directly for `s` in a differently weighted campaign.

## Smallest experiment that would test research acceleration

Freeze a two-batch candidate queue, acceptance thresholds, independent assessor,
semantic/law gates, unseen evaluation inputs and equal wall/CPU budgets. Start
two arms from identical builder B0 and cache state. Both pay for evaluating the
same first-batch builder candidate B1. The frozen arm continues using B0; the
updating arm installs B1 only after the frozen acceptance gates, then uses it to
build and validate the same next-batch queue. Charge B1 acquisition, rebuild,
proof/testing, failures, installation and rollback to the updating arm. Alternate
serial arm order on the same CPU, preserve every attempted candidate and repeat
paired runs before claiming a stable effect.

Count distinct candidates passing all frozen correctness and unseen-performance
gates by the deadline, and report accepted improvements per total hour together
with time to first acceptance and per-stage costs. A faster rejected candidate
does not count. The one-update, two-batch comparison is the smallest causal
pipeline test; repeated builder updates would be needed to establish sustained
feedback. Break-even requires measured update cost divided by measured savings
per subsequent validated evaluation, and is undefined without positive savings.

Most critically, B1 must actually accelerate a dependency used to construct or
validate the next candidates. The current reports optimize emitted reverse
workers; they do not demonstrate that these workers replace a bottleneck in the
builder's own execution. No recursive acceleration, sustained increase in
validated improvements/hour, full-compiler speedup or self-reproduction claim
follows from the present worker and screen measurements.

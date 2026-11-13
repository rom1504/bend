# Phase191 final-product physical profiles

The final candidate still spends a substantial part of numeric recurrence in
runtime operation dispatch: `p111_rt_op` owns 35.37% of its period-weighted
samples, versus 37.12% for Phase190. Map remains distributed across traversal,
insertion, ownership/product helpers, and the runtime worker. These observations
identify remaining work; they do not explain the numeric regression causally.

## Identity and quality

The [plan](../../selfhost/build/phase191/profile-plan03/plan.json) binds
Phase190 native45-02, final Phase191 native45-01, and the same mature C products
used in the final runtime report. The candidate source is unchanged. Each
case-role has its own workload identity, four warmups, one clean observation,
and separate 8,000/13,000 µs sampling captures, calibrated to about 2.9 CPU
seconds per run. There are intentionally zero cross-role pooled comparisons.

The offline [method](../../selfhost/build/phase191/profile-analysis03/derive.py)
verifies manifest, executable, raw-input, and analysis identities; recomputes
all 12 analyses from raw sample files and exact ELF inputs; and reproduces the
saved [comparison](../../selfhost/build/phase191/profile-plan03/comparison.json)
exactly. The [assessment receipt](../../selfhost/build/phase191/profile-analysis03/report.json)
records all physical functions, per-period leaders, and denominators. No target
program was executed by this analysis.

All six pools pass the maintained comparator: 578–614 samples each, both periods,
zero drops/overruns, zero rejected captures, intact lifecycle/handler checks,
and available clean-CPU attribution. Capture windows cover at least 99.908% of
whole-child CPU; sampled-thread CPU coverage is at least 99.994%. Individual
captures contain only 220–394 samples; admission is based on pooling identical
commands within each role, not on each capture separately.

| Case | Role | Repetitions | Pooled samples | Unknown samples / weighted share | Clean CPU µs / repetition |
|---|---|---:|---:|---:|---:|
| numeric-1024 | Phase190 | 302,276 | 584 | 0 / 0% | 9.572 |
| numeric-1024 | Candidate | 292,995 | 581 | 0 / 0% | 9.848 |
| numeric-1024 | C | 888,800 | 582 | 0 / 0% | 3.237 |
| Map-32 | Phase190 | 13,311 | 614 | 17 / 2.512% | 217.001 |
| Map-32 | Candidate | 13,660 | 593 | 11 / 1.843% | 210.010 |
| Map-32 | C | 62,331 | 578 | 0 / 0% | 46.120 |

The generic comparator retains unknown PCs in denominators; it does not enforce
zero unknowns. Both native Map pools therefore fail the additional stricter
Phase190 zero-unknown rule, while all numeric pools and C Map satisfy it.
Baseline Map's unresolved samples are predominantly in libc. The sampled/clean
wall ratio is 1.045 for baseline Map and 1.024 for candidate Map, versus roughly
0.998–1.005 for the other pools. Sampling disturbance and period aliasing remain
possible even with good CPU coverage.

## Numeric recurrence: runtime dispatch remains material

| Physical leaf | Phase190 share / estimated µs per repetition | Candidate share / estimated µs per repetition |
|---|---:|---:|
| `$direct.p37.numeric` | 62.88% / 6.019 | 64.49% / 6.351 |
| `p111_rt_op` | 37.12% / 3.553 | 35.37% / 3.484 |
| `$direct.p93.loop` | No sample | 0.14% / 0.014 (one sample) |

Both periods support the broad split: runtime-op shares are 37.29%/36.94% for
Phase190 and 35.00%/35.75% for candidate. C's 582 samples all resolve to its
generated `WL_FID_native_k_5236` worker. Its physical generated-worker identity
must not be described as scheduler overhead merely because it starts `WL_`.

The final candidate's [exact worker disassembly](../../selfhost/build/phase191/profile-analysis03/numeric-candidate.asm)
contains the loop call to `p111_rt_op` at `0x40858b`. Its argument setup supplies
constant opcode `0x3a` (58), a private-frame argument pointer, and arity one.
The frozen selected source maps `f32_to_u32` to opcode 58. The
[fixture](../../selfhost/tools/bench/catalogs/native45/fixtures/coverage-numeric-recurrence-1024.bend)
performs this conversion in every recurrence step. Thus a future direct lowering
of this known operation, preserving its exact conversion semantics, has a
concrete machine and hotness basis. It was not implemented or measured here.

The helper share is physical leaf time, not inclusive call cost or removable
overhead: conversion work must still happen, argument preparation lives in the
caller, and no call counts were collected. Dividing 3.484 µs by the fixture's
1,024 steps gives an amortized 3.40 ns of attributed helper CPU per step; that
is not an isolated dispatch/call latency. The single clean observation and
sampling uncertainty do not establish that helper time changed between roles,
nor that the larger generated-worker estimate caused the 2.82% final-suite
numeric-1024 regression. Use the balanced runtime campaign for performance.

## Map: selected-product attribution

| Physical leaf | Phase190 share / estimated µs per repetition | Candidate share / estimated µs per repetition |
|---|---:|---:|
| borrowed `Map.bit.go` | 11.56% / 25.086 | 10.96% / 23.012 |
| `work_loop.constprop.0` | 3.61% / 7.833 | 6.96% / 14.624 |
| `$direct.Map.ins.go` | 4.29% / 9.312 | 5.75% / 12.079 |
| `$direct.Map.seek.go` | 5.61% / 12.164 | 5.26% / 11.040 |
| `p125_rt_ctor2` | 5.29% / 11.478 | 5.00% / 10.502 |
| `p125_rt_take2` | 5.66% / 12.272 | 4.68% / 9.821 |
| `p125_rt_take3` | 2.79% / 6.064 | 4.45% / 9.355 |
| `p111_rt_op` | 4.03% / 8.735 | 2.78% / 5.843 |

Only 16–70 pooled samples support these native Map functions. Candidate
runtime-op and baseline take3 are below the comparator's 20-sample precision
marker. Candidate insertion is 5.68% at 8 ms and 5.83% at 13 ms; borrowed bit
traversal is 10.27%/11.66%. The 199 static frame-load removals previously found
in insertion do not imply a measured reduction in its physical share: this
profile actually assigns it a larger estimate. Do not interpret that estimate
as a causal regression of the transformation, or infer changed invocation
counts from leaf samples. Layout, sampling, other callers, and normalization
all remain relevant.

C's leading leaves are generated `Map.bit.go` (16.68%, 7.695 µs/repetition),
`term_drop` (13.42%, 6.188), generated `Map.seek.go` (9.19%, 4.238),
`span_fade` (7.49%, 3.457), and generated `Map.ins.go` (6.39%, 2.949).
Percentages describe different physical code organization, so compare names
and absolute normalized estimates cautiously. The existing `WL_FID_*` scheduler
bucket remains unsuitable for explaining generated C work.

Every estimate multiplies a within-role period-weighted sample fraction by
that role's independent clean CPU observation, then divides by its own
repetition count. Startup, initial output, warmups, and validation remain
included. These are descriptive CPU allocations, not paired timing ratios,
source ownership, cache-miss measurements, or a forecast of combined speedups.

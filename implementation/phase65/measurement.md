# Phase65 measurements

Phase65 begins at `49431ba` on 2026-10-08 00:49:17 UTC. Its selected baseline is
Phase64 State09 genuine B2
`b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`,
compiled from checked B1
`a2f8b021c20becc730cf91e8e7fd6db98f2bba8b743adec89154ff9c6217bd6f`.
The inherited 23-source result is 1.43894× TypeScript compilation time and
1.06173× imports plus first compilation. These are completed Phase64 numbers,
not fresh Phase65 observations.

The [measurement loop](../../selfhost/tools/performance/phase65/latency/README.md)
reuses Phase64's frozen timing and profiling method, with explicit Phase65
writable boundaries and exact selected-image lineage. Method01 derivation is
`290eac14e3606206c41773ef2ab49d0a098af2587869b9a400dbd2405712a424`;
baseline recipe is
`64950db817c974fc8039f7bb20b00fdfc63755f18f92af5f74d76bbdf89c6195`.
Historical audit dependencies map only to their exact byte-identical checked
snapshots; no live compiler source needs freezing to measure this baseline.

The first loop uses Numeric recurrence, Lexer, Map/set operations and active
raytrace. It collects 16 clean workers in two balanced rounds, eight CPU
profiles, eight allocation profiles and a separate stage observer. All target
execution belongs to root, serially guarded on CPU3; measurement preparation
and analysis use CPU0. Full raw-module comparisons remain mandatory.
No fresh Phase65 performance result is claimed until its campaign closes.

## Fresh selected-B2 baseline

All 16 clean workers passed complete emitted-module comparisons, with two
balanced rounds for the four sources. The [clean summary](evidence/baseline-state09-clean.json)
retains individual samples and image lineage.

| Source | Bend B2 compilation | TypeScript compilation | B2 / TS | Imports + compilation ratio |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 249.86 ms | 299.63 ms | 0.834× | 0.655× |
| Lexer | 621.53 ms | 347.37 ms | 1.789× | 1.252× |
| Map/set operations | 1036.19 ms | 587.77 ms | 1.763× | 1.393× |
| Active raytrace | 854.44 ms | 497.25 ms | 1.718× | 1.314× |

The equal-source geometric means are 1.45808× for compilation and 1.10695× for
imports plus compilation. This four-source diagnostic selection is not a new
23-source broad result. Clean measurement took 16.62 seconds with maximum worker
process-tree RSS 157.13 MiB. Persistent Base cache preparation is excluded.

The [eight stage observations](evidence/baseline-state09-stages.json) also pass
all output checks. Every Bend source uses exactly one ready-seed frontend,
prepared-world checker, prepared-bound context and selected JDPlan. The ordinary
book-context fallback is never called, and positional ABI conversion is zero
for this named-layout image. These observations establish that the intended
fast paths are active, rather than inferred from API availability.

| Exclusive diagnostic stage | Numeric | Lexer | Map/set | Active raytrace |
| --- | ---: | ---: | ---: | ---: |
| Source completion | 27.80 ms | 160.23 ms | 182.29 ms | 240.73 ms |
| Prepared-world check | 20.38 ms | 77.60 ms | 109.47 ms | 185.07 ms |
| Annotation | 2.92 ms | 10.67 ms | 111.71 ms | 31.29 ms |
| Selected plan construction | 40.77 ms | 148.81 ms | 319.18 ms | 139.27 ms |
| Plan library rendering | 11.45 ms | 19.01 ms | 75.94 ms | 14.89 ms |
| Layout proof | 1.83 ms | 11.48 ms | 36.03 ms | 12.62 ms |
| Prepared-bound context | 7.02 ms | 10.63 ms | 8.82 ms | 18.54 ms |
| Source graph trace | 2.56 ms | 9.59 ms | 23.11 ms | 62.32 ms |

The outer Base admission/decoding clock is 68.19/68.62/80.21/78.02 ms in the same
order. Its nested book decoding takes 44–51 ms and prepared-state decoding
17–28 ms. Those nested costs are already included in the outer clock and must
not be added again. The diagnostic compilation totals are 244.49/641.66/1035.96/
855.45 ms; instrumentation makes them distinct from clean medians. The table
lists the main stages, not every residual operation.

The [CPU census](evidence/baseline-state09-cpu.json) independently identifies
plan construction and source completion as major variable costs. All four Bend
profiles admit time weights. TypeScript Map's signed-time policy refuses
weighted times, so that profile retains sample counts only. Map's named call-analysis ancestry accounts for
100.3 ms and raw `jd_arity` ancestry for 40.8 ms, compared with 339.1 ms of disjoint
plan-selection samples. Repeated arity queries alone cannot account for the
entire backend cost. Host-wrapper samples are 79.1 ms on Map; this work occurs
inside broader API stages such as plan rendering, so its CPU figure is not an
additional disjoint budget beside the stage table. CPU windows include imports
and approximately 91 ms of API loading; they are not clean compilation shares.

The [allocation census](evidence/baseline-state09-allocation.json) estimates
21.89/69.42/152.90/101.96 MB for Numeric/Lexer/Map/raytrace, respectively, versus
57.90/68.85/129.12/109.44 MB for TypeScript. Bend already allocates less on Numeric
and raytrace despite raytrace's compilation deficit. Map's disjoint plan scope
accounts for 41.96 MB. The exact `constructor_exists` ancestor union covers
26.12 MB for Lexer, 25.73 MB for Map and 18.63 MB for raytrace. That is a promising
structural allocation lead. The [constructor ancestry audit](evidence/baseline-state09-constructor-ancestry.json)
identifies `base_prefix_ctor_disjoint` under 6.04/6.96/5.51 MB, respectively;
`base_prefix_world_admitted` overlaps most of those bytes. Identified checker
scopes contain 4.07/2.62/2.75 MB and prepared-bound context scopes
2.36/4.07/2.36 MB. Much of the allocation remainder lacks an exact non-constructor
ancestor, so the full union cannot be attributed to world admission. The exact
constructor CPU union is only 13/493, 14/800 and 14/673 samples for those sources.
This supports investigating a bounded repeated scan, not claiming a large
latency win from allocation percentages. The [depth audit](evidence/baseline-state09-constructor-depth.json)
shows that every unresolved constructor allocation stack reaches 129 captured
frames; nearly all retain `constructor_exists` as their oldest non-root frame.
CPU stacks similarly reach 255–257 frames. This is consistent with depth
truncation, not evidence that the unresolved bytes come from unrelated callers;
the identified world-admission subset is a lower bound. Inclusive unions overlap
the disjoint scopes and must not be summed with them.

The [targeted CPU/allocation follow-up](evidence/baseline-state09-target-ancestry.json)
retains exact named ancestors separately from shared SCC dispatch labels. No observed frame is not proof of no cost;
inlining and shared dispatch can hide particular members. Allocation weights
use `samples[].size`, and tree self-size discrepancies remain in every raw
analysis rather than being silently mixed into the totals.

## State01 rejected as an H1 experiment before timing

State01's strict checked build passed, but the [source/API identity check](evidence/state01-invalid-h1.json)
found that both the assembled source and actual B1 API were byte-identical to
the Phase64 baseline. Root confirmed the cause: the temporary H1 patch had been
restored before workflow execution; the factory records build inputs, while the
workflow copies the snapshot when it runs. Therefore State01 contains no H1
implementation. Its original successful compiler receipts and prepared command
recipes remain intact, but **no performance preparation or screen was run** and
no H1 correctness or speed claim follows. A fresh State02 must hold the patch
throughout actual snapshot/build execution. This is an invalid experiment,
not a compiler regression or a measured rejection of H1.

## State02 H1: valid experiment, negligible whole-request change

State02 captures different assembled source and B1 API bytes, avoiding State01's
snapshot error. Its [balanced screen](evidence/state02-b1-screen.json) passes all
eight complete raw-module comparisons: Numeric and Map, two checked-B1 roles,
two balanced rounds. Public annotation-contract compatibility remains unadmitted,
so this experiment is explicitly diagnostic and not production-qualified.

| Source | Phase64 checked B1 | State02 checked B1 | Compilation change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 299.85 ms | 300.55 ms | +0.23% |
| Map/set operations | 1312.13 ms | 1303.01 ms | −0.70% |

The equal-source ratio is **0.99767** for compilation (−0.23%) and **0.99810**
for imports plus compilation (−0.19%). Numeric sample ranges overlap. Map's two
candidate samples are below its two baseline samples, but the small difference
is below the previously observed 3.82% same-image A/A discrepancy. The screen
took 9.80 seconds, with maximum worker process-tree RSS 134.78 MiB.

Root declined to advance this H1 variant to genuine-B2
construction: it shows no substantial whole-request benefit to justify that
cost or a redesign preserving the public annotation contract. This does not
prove that all retained-type-fact approaches fail; it rejects advancing this
particular diagnostic on the evidence available. No B2 speed result is inferred
from these B1 observations.

## State03 H5: small Map direction, no broad screen benefit

The [State03 screen](evidence/state03-b1-screen.json) passes all eight raw-module
comparisons using the same balanced Numeric/Map B1 setup. Actual candidate
source and API hashes both differ from the frozen baseline. Numeric changes
298.52 → 300.73 ms (+0.74%); Map changes 1310.69 → 1295.93 ms (−1.13%). The
geometric-mean ratios are **0.99803** for compilation (−0.20%) and **0.99792**
for imports plus compilation (−0.21%). Numeric ranges overlap; Map's two samples
separate, but its point estimate remains below the observed A/A discrepancy.

This is below the planned 2% screen signal for advancement and does not justify
a standalone B2 speed claim or confirmation campaign on present evidence. The
screen took 9.74 seconds. Root rejected advancement of H5. Its separate 15
focused semantic controls passed; the actual staged-driver/frame4 host92 recipe
was prepared but explicitly left unrun after the performance rejection. No
host92 or B2 qualification is claimed. Original recipes and receipts remain
intact, including the unrun disposition; no B2 result is inferred.

## State04 H3: Map regression after a valid shallow-substitution change

State04's frozen `src/core/term.bend` matches the reviewed patch exactly
(`2726a94c265792203431610006281b97369ecb7f2371b6eefbefb4594db0aed5`).
Its assembled source and actual B1 API differ from baseline. All 265 focused
controls pass, as do all eight [balanced screen](evidence/state04-b1-screen.json)
raw-module comparisons.

Numeric changes 298.59 → 287.60 ms (−3.68%), but the candidate's two samples are
300.31 and 274.88 ms, so its apparent gain depends on one sample. Map changes
1281.21 → 1335.51 ms (**+4.24%**); both candidate samples are slower than both
baseline samples. The geometric mean is **1.00200** for compilation (+0.20%)
and **1.00369** for combined imports plus compilation (+0.37%). The campaign
took 10.14 seconds.

The measurement recommendation is to stop this variant before heldout or B2
work: it regresses the workload with the largest measured substitution cost,
without an overall screen improvement. Correctness controls establish the
implemented behavior, not that fewer allocations or shallow cases necessarily
improve execution. No genuine-B2 effect has been measured, so this is a scoped
B1 performance rejection rather than a universal claim about structural sharing.

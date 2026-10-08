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

## State05: Boolean constructor projection, four-source B1 screen

The [four-source screen](evidence/state05-b1-four.json) passes all 16 complete
raw-module comparisons using two balanced rounds. It measures the generic
Boolean constructor projection, not State03's retained world index. The actual
candidate snapshot changes only `check/kernel.bend` and `core/term.bend`.

| Source | Phase64 checked B1 | State05 checked B1 | Compilation change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 294.88 ms | 291.53 ms | −1.14% |
| Lexer | 579.09 ms | 596.47 ms | +3.00% |
| Map/set operations | 1309.68 ms | 1291.24 ms | −1.41% |
| Active raytrace | 891.69 ms | 866.08 ms | −2.87% |

The equal-source geometric mean is **0.99373** for compilation (−0.63%) and
**0.99427** for imports plus compilation (−0.57%). Numeric's candidate samples
span 280.27–302.80 ms; Lexer ranges overlap narrowly. The Map and raytrace
candidate ranges fall below their baseline ranges, but this small two-round
screen supplies no strong broad gain. It took 19.06 seconds and reached
133.97 MiB maximum worker process-tree RSS. No genuine-B2 effect is inferred.

## State06: tiny term-leaf substitution, mixed B1 evidence

The [State06 screen](evidence/state06-b1-screen.json) passes all eight raw-module
comparisons. Only the frozen `core/term.bend` differs from baseline; its hash
is `37d7febe08c496e85dfd7fffc3477406d2c5c1500dc31c797b865f043a112c8b`.
This is the small leaf candidate, not State04's larger shallow guards.

Numeric changes **275.02 → 295.04 ms (+7.28%)**, with both candidate samples
slower than both baseline samples. Map changes **1285.80 → 1252.37 ms (−2.60%)**,
with both candidate samples faster than both baseline samples. The equal-source
geometric mean is **1.02221** for compilation (+2.22%) and **1.01906** for imports
plus compilation (+1.91%). The screen took 9.70 seconds.

This is mixed evidence with a clear local Numeric regression in these samples.
The checked-B1 and genuine-B2 cost models differ; deciding to test the simple
leaf implementation in B2 would be a separate falsification experiment, not
promotion based on this screen. No B2 result has been measured here.

## Method02: optional Base annotation products are measured inputs

State08 introduces a deferred Base annotation sidecar under
`build/typed/base-products`, outside the existing mandatory cache directory.
[The method successor](../../selfhost/tools/performance/phase65/latency/make-method-v2.py)
requires the actual artifact for images exporting all four product APIs and
records explicit directory absence for the historical baseline. The consumed
method01 remains unchanged.

Preparation checks the exact singleton pathname, bounded header, API/Base/source
and ABI/span identities, keys and body digests, and both parent frame segment
digests against the actual segment bytes. The decoded cache intentionally omits
those parent digest fields, so the verifier reads the raw frame header rather
than comparing undefined decoded properties. Each worker checks exact sidecar
membership and byte hashes before and after execution, including no-hit sources.
Preflight hashing remains outside the existing clocks; this is a fresh-process,
prepared-artifact comparison, not an OS-cold I/O benchmark. The stage preparation
must produce the actual sidecar; a silent missing-file fallback cannot pass the
candidate preflight. Independent source review passed before method02 froze.

## H6 static decoder: substantial Numeric improvement, unresolved Map variance

The [whole-request helper counterfactual](evidence/host-static-tags-screen.json)
passes all eight complete raw-module comparisons. Both roles use the same actual
Phase64 genuine-B2 API, source, Base, driver, runtime and prepared frame bytes.
Fresh private projects differ only in the reviewed graph helper. This avoids a
compiler-image rebuild while testing whether the isolated decoder gain survives
inside the actual ordinary compiler request. It is diagnostic evidence, not
production or release qualification.

Numeric improves **255.68 → 205.26 ms (−19.72%)**: the candidate samples are
205.19 and 205.32 ms versus baseline 251.82 and 259.54 ms. Map changes
**1019.83 → 1021.62 ms (+0.18%)**, but its candidate samples are 1087.27 and
955.98 ms. That spread prevents a stable Map conclusion from this screen.
The equal-source geometric means are **0.89677** for compilation (−10.32%) and
**0.92241** for imports plus compilation (−7.76%). These are two-source ratios,
not the final 23-source aggregate or comparisons against TypeScript.

The campaign took 23.93 seconds; the maximum process RSS, including preflight
identity checks and output verification, was 398.35 MiB. A frozen successor
admits the four initial sources for a 16-worker, two-balanced-round confirmation.
The helper-only copier currently supports this no-product baseline. H2's optional
sidecars require method02's complete inventory for the selected production
comparison; they must not be silently omitted from a helper-only clone.


The [four-source confirmation](evidence/host-static-tags-four.json) passes all
16 raw-module comparisons and strengthens the H6 result: Numeric 263.01 → 207.94
ms (−20.94%), Lexer 611.30 → 562.93 ms (−7.91%), Map 1019.61 → 962.58 ms
(−5.59%), and raytrace 876.92 → 803.01 ms (−8.43%). Every candidate compilation
sample range falls below its baseline range. The equal-source geometric means
are **0.89069** for compilation (−10.93%) and **0.91533** for imports plus
compilation (−8.47%). This campaign took 47.83 seconds. It supports qualifying
H6 in the selected compiler snapshot and then measuring all 23 sources against
both genuine-B2 baseline and pinned TypeScript. It does not replace that final
campaign.

State08's [actual product preparation](evidence/state08-product-preparation.json)
now passes: baseline sidecar absence and candidate presence are confirmed. The
candidate file is 438,959 bytes, including a 437,464-byte product body. Explicit
Base preparation takes 2.984 s in the baseline process and 3.712 s in the
candidate process; these single observations are setup costs, not a balanced
preparation benchmark. Both are outside ordinary request timings. Total guarded
preparation wall time is 13.90 s, including identity/oracle work.

## State08 H2: Map gain with actual prepared product

The [balanced B1 screen](evidence/state08-b1-screen.json) passes all eight full
raw-module comparisons. The required sidecar exists and its bytes remain pinned
before and after every worker, including Numeric's no-hit requests.

Map improves **1316.43 → 1243.22 ms (−5.56%)**: baseline samples are 1313.48 and
1319.38 ms, versus candidate 1240.85 and 1245.60 ms. Numeric changes
**295.22 → 305.35 ms (+3.43%)**, with candidate samples 291.31 and 319.40 ms;
that split and overlapping ranges do not establish a stable no-hit direction.
The equal-source geometric means are **0.98833** for compilation (−1.17%) and
**0.98545** for imports plus compilation (−1.45%). The screen took 9.80 seconds
and reached 136.75 MiB maximum worker process-tree RSS.

The Map signal warrants finishing H2's focused semantic/transport controls and
considering a combined genuine-B2 test with H6. The small two-source aggregate
must not be read as a 23-source result, and H2's B1 ratio must not be multiplied
by H6's separately measured B2 ratio to claim a combined gain. The integrated
image needs its own direct comparison and no-hit coverage. Any failed controller
parents remain failed; a metadata-corrected successor must qualify its actual
checked/equality-derived API lineage explicitly.

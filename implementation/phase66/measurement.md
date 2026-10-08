# Phase66 performance measurement

The upstream update has five separate acceptance metrics: generated-program execution, B1 compilation, genuine B2 compilation, conformance, and source complexity. This report owns the first three. It never substitutes compiler throughput for generated-program runtime.

**Version scope:** the final measurements use frozen attempt07 and its genuine B2, after repairing the seven gaps exposed by the wider JavaScript corpus. Both full compiler campaigns and all 45 generated-program execution points are complete. Earlier attempt04 campaigns remain below as historical measurements. The [final verified join](evidence/selected-performance07.json) binds all three performance metrics to the actual selected images; it does not replace the separate conformance qualification.

## Final corrected compiler: full distributions

The [final checked B1](evidence/b1-07-broad.json) and [final genuine B2](evidence/b2-07-broad.json) each passed **207/207 complete-output checks**, covering 23 sources, three roles and three balanced rounds. B1 is the actual qualified image `bb6c6e2a…`; B2 is its actual self-emitted compiler `0067736c…`. All 23 ordinary B2 output modules and 45 observer modules match the independently executed B1 outputs. Each generation has its own simultaneous old-generation and HEAD TypeScript measurements.

| Clock | Updated / old B1 | Updated B1 / HEAD TS | Updated / old B2 | Updated B2 / HEAD TS |
| --- | ---: | ---: | ---: | ---: |
| Compilation | **1.00530×** | **1.40207×** | **0.99770×** | **1.32110×** |
| Imports + API loading + compilation | **1.00720×** | **0.98263×** | **0.99816×** | **0.99039×** |

These are equal-source geometric means of each source's median ratio. Compilation performance is essentially maintained through the upstream update and subsequent correctness fixes: +0.53% for B1 and −0.23% for B2. Both remain slower than HEAD TypeScript on compilation alone. Their lower startup cost brings the combined fresh-process clock slightly below TypeScript; that is a separate result, not compilation parity.

B1 has five lower and eighteen higher source medians than old B1, ranging from −7.06% to +2.99%. B2 has nine lower and fourteen higher medians, ranging from −9.01% to +4.31%. The matrices retain every observation. Some small changes have disjoint observed ranges: B1 is higher on Lexer, symbolic regression, active raytrace, Unicode and map churn; B2 is higher on symbolic regression, RLE, scalar-region, Mandelbrot grid and closures, and lower on BST. Range separation is descriptive, not a confidence interval. The largest apparent improvements on edit distance have overlapping ranges.

Five of 23 source compilation medians are below TypeScript for each generation. B1 ratios span 0.77399×–2.25875×, and B2 ratios span 0.65785×–1.86401×; Map/set operations remains the largest relative gap. The B1 campaign took 212.22 seconds with 159.9 MB peak worker-tree RSS; B2 took 218.40 seconds with 176.3 MB. No B1 and B2 observations are pooled into a cross-generation speed claim.

## Final generated-program execution

The [full runtime campaign](evidence/runtime-selected07-full.json) passed **669/669 samples over all 45 points from 23 source programs**. It compares old Phase65 Bend output, selected07 Bend output and newly acquired HEAD TypeScript output on the same original source bytes, arguments and expected values. The actual selected B2's emitted modules are byte-identical to the independently executed selected B1 modules, so this program-execution result applies to both generations' output.

| Weighting | Updated / old Bend output | Updated Bend output / HEAD TS output |
| --- | ---: | ---: |
| Each of 45 points equally | **1.00038×** | **1.04928×** |
| Each of 23 sources equally | **1.00371×** | **1.04699×** |

The upstream update and correctness repairs therefore retain generated-program speed: the observed overall change is +0.04% or +0.37%, depending on weighting. These are geometric means of medians, not totals or predictions for a typical application. Source weighting first averages a source's original points geometrically. Compilation, imports, first call and warmup are excluded from the timed execution ratio; their recorded measurements stay separate. Zero-work canaries remain explicit rather than being silently removed.

Nineteen point medians decrease and twenty-six increase relative to old Bend output, ranging from −3.21% to +4.03%. **No point has its entire candidate sample range above its old sample range.** One smaller active-ray point improves with disjoint observed ranges. The largest increases are closures at size64 (+4.03%), legacy raytrace (+3.78%), recurrence at size256 (+3.65%), Map/set operations (+3.39%) and the complete-row observer (+2.99%). All have overlapping ranges; several small workloads also show material within-sample drift. These are retained observations, not established regressions or grounds for another broad campaign.

The roughly 5% aggregate gap to HEAD TypeScript hides a concentrated tail. The following table shows the four largest source gaps and all three held-out source families. [The full breakdown](evidence/runtime-selected07-details.json) retains every point and source, sample ranges, drift, partitions and separate startup measurements.

| Source | Points | Updated / old runtime | Updated / HEAD TS runtime |
| --- | ---: | ---: | ---: |
| Mandelbrot grid | 2 | 1.00050× | 1.61888× |
| Historical Mandelbrot | 1 | 1.00595× | 1.52185× |
| Historical raytrace | 1 | 1.03783× | 1.50298× |
| Active raytrace | 2 | 0.99598× | 1.33723× |
| BST, held out | 2 | 0.99831× | 1.02743× |
| Expression, held out | 2 | 0.98933× | 1.00907× |
| Record aggregation, held out | 2 | 0.99750× | 0.96764× |

Every other source's ratio to TypeScript is at most 1.090×. Fifteen of 45 point medians, or nine of 23 source aggregates, are below TypeScript. Across individual points the ratio spans 0.71518×–1.66102×. The existing renderer gaps warrant targeted profiling if execution speed becomes the next priority; the update itself did not create a substantial broad regression. The finite selection still does not cover every Bend program or new upstream feature.

The three batches used the unchanged 600-second preset: five fresh-process rounds per role, 1,000 ms warmup, 50 ms calibration and 300 ms measured target, with the retained three-round historical-raytrace exception. Combined elapsed time was **1,118.99 seconds (18.65 minutes)** and peak worker-tree RSS was 128.7 MB. The preset applies to each batch, not to the entire 45-point campaign. Actual point execution and input/module identities were independently rechecked before the final join.

## Controlled pre-change baseline

The first campaign completed before production source changes. It used the sealed Phase65 State10 checked B1 (`3a7fedb7…`), actual self-emitted B2 (`239f7970…`), and old upstream TypeScript compiler `018751270e800bc222a93dad7f257083ee53a5f7`. The two Bend images used private Phase66 copies of their frozen host snapshots; no historical cache or release was modified. Explicit Base preparation, including eligible optional annotations, occurred outside timing.

[Verified evidence](evidence/baseline-four.json) records all 36 exact raw-module checks: four sources, three roles, three rotated rounds. The campaign took 39.38 seconds. The following values are within-source medians, in milliseconds.

| Source | Old TypeScript compilation | Current B1 compilation | Current B2 compilation |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 314.86 | 250.34 | 208.67 |
| Map/set operations | 617.22 | 1,181.00 | 960.83 |
| Lexer | 350.69 | 530.52 | 564.96 |
| Active raytrace | 504.44 | 833.34 | 893.46 |

The equal-source geometric mean of median compilation ratios is **1.39638× for B1** and **1.30987× for B2**, relative to old TypeScript. Adding measured host/compiler imports and API loading yields **0.99510×** and **1.00590×**, respectively. Import time and compilation time remain separately available in the evidence. This four-source screen is not the final 23-source distribution and does not replace Phase65's 1.28945× broad B2 result.

## Updated upstream reference and final comparison

HEAD is pinned separately at `059266225b77c8ca256ac6b25ee5c21449bab151`. Its Base changed from 71,530 to 75,064 bytes. Its emitted JavaScript must therefore be acquired and checked on the original 45 point observations before becoming a raw-output timing oracle. Original source bytes, arguments, expected results and the complete-row observer stay fixed; compiler target and Base identities are recorded separately.

The next comparisons retain old TypeScript, updated TypeScript, old B1/B2 and selected new B1/B2 as explicitly named images. Every timing worker checks the whole output against its own qualified module. Cache creation stays outside compilation clocks. Startup is reported separately. The final compiler distribution covers all 23 sources; generated-program performance uses the existing 45-point budgeted execution protocol with separate import, first-call, warmup and timed-call measurements. Small differences retain sample ranges and drift; held-out families remain identified. Preparation or a one-shot correctness check is not runtime speed evidence.

Raw recipes and receipts are under `selfhost/build/phase66/`; source factories are under `selfhost/tools/performance/phase66/latency/`. Only the root agent executes target programs. This lane prepares and verifies data on CPU0.

## Updated TypeScript screen

[The second controlled campaign](evidence/head-four.json) ran all four roles together: old B1, old B2, old TypeScript and HEAD TypeScript. All 64 complete emitted modules matched their qualified oracles. Four rotated rounds covered the same four sources in 68.00 seconds.

| Source | Old TS compile ms | HEAD TS compile ms | Current B1 compile ms | Current B2 compile ms |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 297.72 | 306.72 | 236.19 | 204.30 |
| Lexer | 349.11 | 354.17 | 533.34 | 564.31 |
| Map/set operations | 620.89 | 547.03 | 1,199.65 | 998.41 |
| Active raytrace | 498.03 | 463.38 | 841.75 | 861.36 |

HEAD TypeScript's geometric-mean compilation time is **3.79% lower** than old TypeScript in this screen; combined import/API/compile time is **2.67% lower**. Map and raytrace improve, while Numeric and Lexer are slightly slower. Against HEAD TypeScript, the unchanged B1/B2 compilation ratios are **1.46604× / 1.37749×**; including startup they are **1.04350× / 1.05210×**. These are same-campaign ratios, not ratios of separate campaign totals. The updated reference includes its updated Base, so these data alone do not isolate TypeScript implementation changes from standard-library changes.

The generated-program snapshots are separate from compiler timing. `program-reference-snapshot/report.json` copies exact current Bend, old TypeScript and HEAD TypeScript modules. Its runtime recipes preserve the existing 20/60/300/600-second protocols, result checks, warmup, paired rounds, first-call/import observations and drift. The full 45-point comparison uses three batches without reducing any workload. New mixed-target bundle metadata retains each compiler's actual revision and the original source-corpus identity; it never relabels HEAD TypeScript as a self-hosted compiler.

## Generated-program rejection screen

The [20-second runtime preset](evidence/runtime-head-fast.json) completed all five selected points and 45 samples in **16.17 seconds**. HEAD TypeScript versus old TypeScript was effectively unchanged at this screen depth: ratios were 1.0024× for pair, 0.9984× for fold, 1.0104× for the zero-work scalar canary, 1.0066× for the 8,192-step scalar case and 1.0006× for the complete-row observer. Current Bend-generated programs versus HEAD TypeScript were 1.1346×, 1.0634×, 0.9958×, 1.0071× and 1.0051× for those points.

These five small workloads were a rejection screen, not a representative runtime result for all 45 points. In particular, the zero-work canary mostly measures invocation and observation overhead. Raw sample ranges, first-call/import times and drift are preserved. The completed selected07 full runtime comparison is reported separately above; the screen is not pooled with it.

## Historical attempt04: checked B1 screen

The selected updated checked B1 uses the validated profile7 image from attempt04. The updated Base annotation product is admitted only after the independent owned/custom Base controls passed; preparation requires its actual presence and identity. The [first four-source campaign](evidence/b1-04-four.json) passed all 36 complete-output checks in 38.20 seconds.

| Source | Old B1 compile ms | Updated B1 compile ms | HEAD TS compile ms | Updated B1 / HEAD TS |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 235.65 | 238.56 | 306.29 | 0.779× |
| Lexer | 531.44 | 534.24 | 357.47 | 1.494× |
| Map/set operations | 1,163.11 | 1,177.04 | 519.17 | 2.267× |
| Active raytrace | 829.27 | 848.77 | 473.96 | 1.791× |

The equal-source geometric mean is **1.01325× updated/old B1** and **1.47442× updated B1/HEAD TypeScript** for compilation. Including imports and API loading gives **1.01225×** and **1.05401×**, respectively. All four updated medians are slightly higher than the old B1, ranging from 0.53% to 2.35%; this screen does not establish a performance improvement from the upstream update. Sample ranges are retained, including the large second-round Lexer/ray samples. Map has the largest absolute and relative remaining compilation excess here, but this timing campaign does not attribute that excess to individual compiler stages. Final B1 and genuine B2 distributions remain separate pending gates.

## Historical attempt04: genuine B2 screen

The updated genuine B2 is the actual self-emitted image `9ded6e94…`, with its selected checked B1 generator and 99 exports pinned separately. It freshly emitted all 23 benchmark sources through the ordinary private driver. All complete raw modules and all 45 observer modules matched the separately executed B1 output exactly. This permits transferring those finite output observations; it does not substitute B1 timing for B2 timing.

The [fresh B2 screen](evidence/b2-04-four.json) passed all 36 complete-output checks in 38.45 seconds.

| Source | Old B2 compile ms | Updated B2 compile ms | HEAD TS compile ms | Updated B2 / HEAD TS |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 202.60 | 208.93 | 304.48 | 0.686× |
| Lexer | 565.05 | 561.98 | 353.76 | 1.589× |
| Map/set operations | 956.31 | 958.89 | 522.59 | 1.835× |
| Active raytrace | 837.03 | 820.08 | 461.79 | 1.776× |

Compilation is effectively unchanged against old B2 in this screen: **1.00189×** equal-source geometric mean, with two lower and two higher medians. Against HEAD TypeScript it is **1.37284×**. Adding imports and API loading gives **0.99766× updated/old B2** and **1.04758× updated B2/HEAD TypeScript**. These are same-campaign ratios with their own TypeScript observations; the B1 and B2 screens are not pooled to manufacture a cross-generation comparison.

## Historical attempt04: full checked B1 distribution

The [23-source checked B1 campaign](evidence/b1-04-broad.json) passed all **207/207** complete-output checks: three roles and three balanced rounds per source. It took 216.22 seconds; peak worker process-tree RSS was 161.7 MB.

| Clock | Updated / old B1 | Updated B1 / HEAD TS |
| --- | ---: | ---: |
| Compilation | **1.00349×** | **1.39617×** |
| Imports + API loading + compilation | **1.00540×** | **0.98152×** |

The update is essentially neutral overall for B1 compilation. Twelve source medians decrease and eleven increase; the full range is −6.34% to +10.74%. The largest apparent increases, record aggregation (+10.74%) and Evening (+7.43%), have overlapping sample ranges and visibly split slow/fast observations. They remain recorded differences, rather than established systematic regressions. Raytrace, Map, symbolic regression and Numeric have smaller increases with disjoint observed sample ranges; BST has a decrease with disjoint ranges. Range separation is descriptive, not a statistical confidence interval.

Updated B1 beats HEAD TypeScript's compilation median on 5/23 sources and its combined startup/compilation median on 10/23. Ratios to TypeScript range from 0.77168× to 2.26466×; Map remains the largest relative gap. The full matrix preserves every source median and all three samples. No timing observations from the genuine B2 or generated programs enter this B1 average.

## Historical attempt04: full genuine B2 distribution

The [23-source genuine B2 campaign](evidence/b2-04-broad.json) also passed **207/207** complete-output checks. It took 217.69 seconds; peak worker process-tree RSS was 174.4 MB.

| Clock | Updated / old B2 | Updated B2 / HEAD TS |
| --- | ---: | ---: |
| Compilation | **0.99648×** | **1.32715×** |
| Imports + API loading + compilation | **0.99791×** | **0.99472×** |

B2 compilation is essentially neutral overall: the measured change is −0.35%. Ten source medians decrease and thirteen increase, ranging from −8.18% to +2.81%. None of the improvements has disjoint observed sample ranges; five small increases do, in symbolic regression, Morning, scalar-region, list-pipeline and record aggregation. This update should therefore be described as retaining compilation performance rather than delivering a new speedup.

Updated B2 beats HEAD TypeScript's compilation median on 4/23 sources and its combined startup/compilation median on 9/23. The compilation-ratio range is 0.68359× to 1.82359×. Active raytrace and Map remain the largest relative gaps at 1.82359× and 1.81168×. Including startup gives near parity overall, but that does not erase the approximately 33% compilation-only deficit. Generated-program execution remains a separate measurement.

## Localizing the wider-corpus timeouts

The wider JavaScript corpus exposed two depth-24 shared-sum witnesses, `const_shared_layout` and `show_shared_layout`, that exceeded the whole-probe 10-second limit. Their frozen artifacts contain no emitted JavaScript. Both had already passed frontend parse/check, and HEAD TypeScript completed each whole JavaScript probe in about 0.63 seconds.

A [focused diagnostic](evidence/shared-layout-timeouts04.json) copied the exact prepared04 B1 project and added public API entry/exit markers only to its private driver. It ran one witness with a 20-second guard. `j_compile_error` began at approximately 671 ms and never returned; the guard stopped the process at 20.02 seconds with 208.6 MB peak RSS. Frontend checking had completed in 19.34 ms inside this diagnostic. Annotation, layout validation, output emission and generated-program execution had not started.

Source inspection identifies repeated printability checking: sibling constructors receive the same path-local visited-type list, so both repeatedly validate their identical `Choice` child type. Repeating that branching through depth24 causes exponential work. The phase is directly observed for `const_shared_layout`; the same source mechanism applies to the second witness, whose phase was not separately traced. These timeouts remain failed observations. The diagnostic is not a clean performance sample, and the compiler fix belongs to the subsequent candidate.

# Phase107 measured metrics

Backend screen: **measure09** (`constant`). Ratios are time ratios; lower is faster.

**Runtime baseline: raw experimental IR → C/Clang O2, not upstream Bend.** The latest optional policy is a distinct experimental stage, not the installed native frontend policy.

| Workload | Optimized C / raw C | Optimized CL / raw C | Optimized QBE / raw C |
| --- | ---: | ---: | ---: |
| ir-closure | 1.008× | 1.718× | 1.139× |
| ir-list | 0.981× | 0.947× | 1.036× |
| ir-many | 1.008× | 1.018× | 0.996× |
| ir-shared | 0.859× | 1.761× | 1.284× |
| ir-shared_borrow | 0.965× | 1.998× | 1.423× |
| ir-tail | 1.009× | 1.201× | 0.947× |
| ir-text | 0.992× | 1.417× | 1.530× |
| ir-tree | 1.020× | 1.058× | 1.131× |
| source-arithmetic | 1.007× | 1.458× | 1.078× |
| source-branches | 1.001× | 1.514× | 1.101× |
| source-compiler_classify | 1.025× | 2.063× | 1.414× |
| source-erased | 0.996× | 1.508× | 1.207× |
| source-recurrence | 1.012× | 1.090× | 1.078× |

## Source-to-executable latency

Installed native compiler → C/Clang versus experimental native frontend → QBE; three cases, rebuilt objects, prepared Base. Compiler-process wall sums exclude setup.

| Case | Installed C/Clang, ms | Native QBE, ms | Native / installed |
| --- | ---: | ---: | ---: |
| arithmetic | 594.85 | 376.39 | 0.633× |
| recurrence | 583.75 | 381.52 | 0.654× |
| compiler_classify | 624.12 | 389.83 | 0.625× |

### Separately frozen held-out source timings

Final held-out compilation-cost comparison after source correctness, using fixed native image04 and installed native Bend/C/Clang-O2; both prepared Base, same zero-argument main, three alternating rounds, fresh objects with no object-cache reuse. Sources/answers/method frozen before this timing run. No policy adaptation or retroactive held-out policy-search claim; not a runtime-workload speedup.

| Case | Installed C/Clang, ms | Native QBE, ms | Native / installed |
| --- | ---: | ---: | ---: |
| gcd | 673.39 | 424.52 | 0.630× |
| triangular | 682.81 | 419.53 | 0.614× |
| saturating | 673.79 | 428.57 | 0.636× |

Equal-case geometric mean of these three source-to-executable ratios: **0.626903×**. This is not a program-runtime ratio or a new optimization-policy selection.

## Identical 128-helper kernel: fresh requests

Same Bend IR construction/optimization/verification/emission; byte-identical output. Includes process startup. Excludes parsing source, object generation, linking and program runtime.

| Policy | Format | JS, ms | Native, ms | Native / JS |
| --- | --- | ---: | ---: | ---: |
| memory | json | 3996.10 | 257.47 | 0.064× |
| memory | qbe | 4637.55 | 293.78 | 0.063× |
| pure | json | 2149.44 | 146.85 | 0.068× |
| pure | qbe | 2804.79 | 183.23 | 0.065× |
| raw | json | 123.74 | 14.14 | 0.114× |
| raw | qbe | 195.88 | 21.24 | 0.108× |

## Warm optimization pipeline cost

Warmed same-process optimization only, after corpus qualification. Input cloning, diagnostic verification, serialization and emission excluded. Both policies include their boundary checks; checked policy also includes standalone pass checks. These are optimizer timings, not generated-program speed gains.

| Case | Checked, ms | Fast, ms | Fast / checked |
| --- | ---: | ---: | ---: |
| many | 8626.527 | 889.649 | 0.103× |
| text | 9.288 | 1.176 | 0.127× |
| shared | 10.457 | 2.927 | 0.280× |
| native-branches | 6.896 | 0.887 | 0.129× |

## Fresh native pipeline requests

The 128-helper kernel emits JSON. Each row has three fresh processes per host. Policies within each report use the same image; separate reports use different images. Native/JS equality is checked for each same-policy pair. These are complete kernel requests, not source compilation or generated-program execution, and are not multiplied with the warm optimizer or hosting gains above.

| Report | Policy | Native, ms | JS, ms | Same-policy host pairs in report |
| --- | --- | ---: | ---: | ---: |
| kernel-measure02 | checked | 421.572 | 6832.709 | 27 |
| kernel-measure02 | fast | 96.919 | 1259.208 | 27 |
| kernel-measure02 | promote | 153.816 | 2314.036 | 27 |
| kernel-measure03 | fast | 91.336 | 1273.854 | 18 |
| kernel-measure03 | promote | 90.479 | 1268.432 | 18 |
| kernel-measure04 | constant | 147.130 | 2180.219 | 18 |
| kernel-measure04 | promote | 97.172 | 1270.522 | 18 |
| kernel-measure05 | constant | 90.161 | 1272.382 | 18 |
| kernel-measure05 | promote | 90.355 | 1280.781 | 18 |

## Paired optional strength stage

Five alternating rounds per pair. 14 changed-text pairs and 25 identical-text controls; all samples are retained in JSON. Only changed-text absolute medians are listed below. Mixed wins/regressions are not collapsed into an aggregate optimization gain. Both comparisons use the promotion stage as baseline.

| Workload | Backend | Promotion, ms | Strength, ms |
| --- | --- | ---: | ---: |
| ir-closure | cl | 33.713 | 29.432 |
| ir-closure | qbe | 21.601 | 19.879 |
| ir-list | cl | 16.443 | 17.296 |
| ir-list | qbe | 18.364 | 18.416 |
| ir-shared | cl | 26.730 | 26.551 |
| ir-shared | qbe | 13.417 | 13.326 |
| ir-shared_borrow | cl | 18.676 | 15.958 |
| ir-shared_borrow | qbe | 13.283 | 13.663 |
| ir-text | cl | 103.715 | 108.570 |
| ir-text | qbe | 115.573 | 127.166 |
| source-compiler_classify | cl | 33.527 | 31.208 |
| source-compiler_classify | qbe | 22.475 | 21.872 |
| source-recurrence | cl | 16.329 | 13.506 |
| source-recurrence | qbe | 16.719 | 13.402 |

## Paired optional constant stage

Five alternating rounds per pair. 2 changed-text pairs and 37 identical-text controls; all samples are retained in JSON. Only changed-text absolute medians are listed below. Mixed wins/regressions are not collapsed into an aggregate optimization gain. Both comparisons use the promotion stage as baseline.

| Workload | Backend | Promotion, ms | Constant, ms |
| --- | --- | ---: | ---: |
| ir-shared | cl | 27.596 | 19.105 |
| ir-shared | qbe | 13.568 | 13.534 |

## Optional kernel image acquisition

Acquisition uses the installed Bend-to-C path and Clang once. These are summed successful guard times, separate from request latency; the full receipts retain elapsed envelopes and JS API construction separately. Both receipts are explicitly retrospective, including the limitation that macro-included C was not independently hashed at Clang launch.

| Image | Bend-to-C, s | Clang, s | Sum, s | Receipt |
| --- | ---: | ---: | ---: | --- |
| kernel04 | 8.326 | 38.897 | 47.223 | [Source and tool hashes](kernel04-acquisition.json) |
| kernel05 | 8.239 | 38.617 | 46.855 | [Source and tool hashes](kernel05-acquisition.json) |

All samples, ranges, recorded input hashes, report hashes and precise scopes are in [metrics.json](metrics.json). Figures are standalone SVGs in [figures/](figures/). Reproduce offline with `python3 -B selfhost/tools/performance/phase107/summarize.py`.

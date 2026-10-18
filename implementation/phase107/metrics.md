# Phase107 measured metrics

Backend screen: **measure08** (`strength`). Ratios are time ratios; lower is faster.

**Runtime baseline: raw experimental IR → C/Clang O2, not upstream Bend.**

| Workload | Optimized C / raw C | Optimized CL / raw C | Optimized QBE / raw C |
| --- | ---: | ---: | ---: |
| ir-closure | 0.949× | 1.491× | 1.173× |
| ir-list | 0.846× | 0.813× | 0.877× |
| ir-many | 0.993× | 0.989× | 0.980× |
| ir-shared | 0.791× | 2.310× | 1.139× |
| ir-shared_borrow | 0.985× | 1.727× | 1.449× |
| ir-tail | 1.001× | 1.207× | 0.946× |
| ir-text | 0.999× | 1.511× | 1.599× |
| ir-tree | 1.006× | 1.037× | 1.120× |
| source-arithmetic | 1.005× | 1.586× | 1.084× |
| source-branches | 1.005× | 1.431× | 1.223× |
| source-compiler_classify | 1.108× | 1.930× | 1.660× |
| source-erased | 1.009× | 1.538× | 1.231× |
| source-recurrence | 1.012× | 0.912× | 1.057× |

## Source-to-executable latency

Installed native compiler → C/Clang versus experimental native frontend → QBE; three cases, rebuilt objects, prepared Base. Compiler-process wall sums exclude setup.

| Case | Installed C/Clang, ms | Native QBE, ms | Native / installed |
| --- | ---: | ---: | ---: |
| arithmetic | 594.85 | 376.39 | 0.633× |
| recurrence | 583.75 | 381.52 | 0.654× |
| compiler_classify | 624.12 | 389.83 | 0.625× |

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

The 128-helper kernel emits JSON. Each row has three fresh processes per host. Policies within each report use the same image; the two reports use different images. Native/JS equality is checked for each same-policy pair. These are complete kernel requests, not source compilation or generated-program execution, and are not multiplied with the warm optimizer or hosting gains above.

| Report | Policy | Native, ms | JS, ms | Same-policy host pairs in report |
| --- | --- | ---: | ---: | ---: |
| kernel-measure02 | checked | 421.572 | 6832.709 | 27 |
| kernel-measure02 | fast | 96.919 | 1259.208 | 27 |
| kernel-measure02 | promote | 153.816 | 2314.036 | 27 |
| kernel-measure03 | fast | 91.336 | 1273.854 | 18 |
| kernel-measure03 | promote | 90.479 | 1268.432 | 18 |

All samples, ranges, recorded input hashes, report hashes and precise scopes are in [metrics.json](metrics.json). Figures are standalone SVGs in [figures/](figures/). Reproduce offline with `python3 -B selfhost/tools/performance/phase107/summarize.py`.

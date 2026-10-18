# Phase107 measured metrics

Backend screen: **measure07** (`promote`). Ratios are time ratios; lower is faster.

**Runtime baseline: raw experimental IR → C/Clang O2, not upstream Bend.**

| Workload | Optimized C / raw C | Optimized CL / raw C | Optimized QBE / raw C |
| --- | ---: | ---: | ---: |
| ir-closure | 0.998× | 1.703× | 1.129× |
| ir-list | 0.995× | 0.936× | 1.025× |
| ir-many | 0.999× | 1.008× | 1.008× |
| ir-shared | 0.889× | 2.553× | 1.260× |
| ir-shared_borrow | 1.061× | 2.066× | 1.469× |
| ir-tail | 0.980× | 1.165× | 0.909× |
| ir-text | 1.024× | 1.448× | 1.561× |
| ir-tree | 1.000× | 1.032× | 1.121× |
| source-arithmetic | 1.007× | 1.476× | 1.087× |
| source-branches | 0.996× | 1.454× | 1.092× |
| source-compiler_classify | 1.036× | 2.050× | 1.428× |
| source-erased | 0.991× | 1.500× | 1.219× |
| source-recurrence | 1.000× | 1.099× | 1.080× |

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

All samples, ranges, recorded input hashes, report hashes and precise scopes are in [metrics.json](metrics.json). Figures are standalone SVGs in [figures/](figures/). Reproduce offline with `python3 -B selfhost/tools/performance/phase107/summarize.py`.

# Phase190 first development screen: alpha

Alpha reduced the six-case runtime geometric mean from **4.50183× C to 4.36025× C**, or **0.968552× the frozen x86 baseline** (3.145% lower time). This is a small development-screen gain, far from the ≤2× C target. The only observed regression is `local-fold`, at **1.082804× baseline (8.280% slower)**. No candidate was selected for promotion from this screen.

The evidence is [development-summary01.json](../../selfhost/build/phase190/development-summary01.json), derived from [runtime01/report.json](../../selfhost/build/phase190/runtime01/report.json) and the [frozen reference manifest](../../selfhost/build/phase190/references01/manifest.json). The summary authenticates 116 input pins and revalidates 63 pilot and 54 timed observations. All six development cases are ratio eligible. Three rounds rotate the three roles through balanced positions on CPU3; pilots calibrate per-role work and do not contribute to ratios.

Alpha uses weighted placement policy 2, liveness allocation and branch selection; physical operand changes were disabled. Its checked hosted compiler is [candidate-api08](../../selfhost/build/phase190/candidate-api08/report.json), source SHA-256 `e087364c4a2ca5a4109cec3361b98acad045148188f2221e3ce38c89128c27a5`. Native program executables were timed; the compiler producer was the checked JavaScript-hosted API. This is **not native candidate-compiler qualification**, self-reproduction, a source-language proof, or an installed release change.

## Runtime observations

Ratios below divide the role medians; smaller is better. Every reported case remains in the aggregates.

| Development case | Baseline / C | Alpha / C | Alpha / baseline | Time change |
| --- | ---: | ---: | ---: | ---: |
| `local-fold` | 7.76077 | 8.40340 | 1.082804 | +8.280% |
| `coverage-numeric-recurrence-256` | 3.67553 | 3.46379 | 0.942394 | -5.761% |
| `variation-ray-active-64-2440` | 3.40006 | 3.11631 | 0.916544 | -8.346% |
| `coverage-map-churn-32` | 5.13080 | 4.96800 | 0.968270 | -3.173% |
| `coverage-expression-32` | 3.03291 | 2.88985 | 0.952830 | -4.717% |
| `tree-bitonic` | 5.51539 | 5.27675 | 0.956732 | -4.327% |

Against C, both baseline and alpha have **6/6 cases >1.1× and 6/6 >2×**. Mean positive natural-log slowdown decreases from **1.504483 to 1.472530**. Against the frozen baseline, alpha has no case >1.1× or >2×; its mean positive log slowdown is **0.013259**. The only baseline regression is the fold result above.

Summed fixed-equivalent workload times are **1,777.661 ms C**, **7,501.885 ms baseline**, and **7,240.237 ms alpha**: alpha/baseline **0.965122×**, alpha/C **4.072902×**. These are projections from per-invocation medians using original catalog repetitions, not campaign wall times or adaptive batch weights. The catalog’s zero-work correctness-only case was not among these six and remains ineligible for future runtime ratios.

`tree-bitonic` alpha has max/min sample spread **1.151220×**, exceeding the **1.10×** review threshold; its samples are 0.829960–0.955466 ms/invocation, median 0.866397. It stays included. No other case/role exceeds the threshold. Three observations per role and this dispersion do not establish statistical significance.

## Machine change does not establish a speedup

The independently selected positive fold path in [machine-audit-alpha02](../../selfhost/build/phase190/machine-audit-alpha02/report.json) changes from **66 to 59 instructions**, **21 to 10 explicit frame-memory references**, and **49 to 42 moves**. Both paths retain three branches and zero calls. Nevertheless, whole-program fold runtime is **8.280% slower**. The audit counts a static path, while the benchmark includes the full program; these results do not identify the cause of the regression. Frame references are not cache misses, and the counts imply neither DRAM traffic nor proportional runtime improvement.

## Separate compiler API costs

The six-case [baseline emission](../../selfhost/build/phase190/baseline-emit02/report.json) and [alpha emission](../../selfhost/build/phase190/candidate-emit01/report.json) receipts record these single acquisition observations:

| Observed interval | Baseline API seconds | Alpha API seconds |
| --- | ---: | ---: |
| Base preparation | 0.652803 | 0.600477 |
| Six source preparations | 29.992174 | 29.355918 |
| Typed selection | 14.724725 | 20.145993 |
| Diagnostic assembly rendering | 0.604451 | 0.651318 |
| Direct-object emission | 7.010083 | 7.380454 |

Typed selection rises **14.724725 → 20.145993 seconds**, **1.368174× (+36.817%)**, despite the small runtime gain. Summing Base and recorded per-case intervals gives **52.984234 → 58.134159 seconds**. Render/object intervals include host serialization and file writes. These are unreplicated hosted API observations, not native compiler throughput. The baseline API emission receipt is separate from the retained baseline executables timed in runtime01; it is not pinned by that runtime report. Alpha’s emission receipt is pinned by runtime01.

The guard records the successful baseline/alpha emission jobs at [55.521 seconds](../../selfhost/build/phase190/baseline-emit02-guard/process.json) and [60.517 seconds](../../selfhost/build/phase190/candidate-emit01-guard/process.json), and the [runtime screen at 22.963 seconds](../../selfhost/build/phase190/runtime01-guard/process.json). These are individual whole-job wall costs; they exclude other acquisition attempts, control jobs and investigation time and are not a campaign-total cost.

## Decision and unmeasured follow-ups

This first screen observes **6/6 development cases and 0/39 held-out cases**. It supports further investigation, not transfer or promotion. The combined changes do not isolate which mechanism caused gains or the fold regression.

The next proposals are physical operand selection/copy removal, a certificate for repeated predicates, and unified nine-color allocation. **None has a runtime result in this first-screen evidence set.** Each needs independent legality/control checks, actual emitted-machine inspection and fresh development timing before any held-out evaluation or native compiler qualification.

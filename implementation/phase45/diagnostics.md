# Phase45 selected-output CPU, allocation and code analysis

The final worker23 diagnostics show that **generic invocation is no longer the dominant named CPU cost** on these two larger points. Sampled allocation per call falls about 10.1× for Map and 33.1× for records against Phase44, leaving approximately 1.33× and 1.39× the fresh TypeScript estimates. Remaining work concentrates in private string/Map components, allocations and public-entry checks. This supports further general representation and call/data-flow work; it does not identify a single remaining cause.

The completed diagnostic report contains 12 passing profiles: two points × three compiler roles × separate CPU/allocation runs. It also contains six parsed JavaScript inventories. Total diagnostic wall is 19.708s. Clean execution medians are in [results.md](results.md); instrumented call rates are not throughput evidence.

## Sampled allocation and GC

Allocation values below are sample estimates normalized by validated calls, **not exact allocation counts or retained heap**. CPU and allocation runs use different repetition counts; percentages belong to their own sampled windows.

| Point | Role | Estimated bytes/call | Allocation calls | CPU calls | GC self CPU |
| --- | --- | ---: | ---: | ---: | ---: |
| Map128 | TypeScript | 2,183,969 | 449 | 681 | 6.106% |
| Map128 | Phase44 | 29,469,426 | 16 | 23 | 6.006% |
| Map128 | Worker23 | 2,913,836 | 283 | 430 | 10.252% |
| Records256 | TypeScript | 2,728,873 | 310 | 429 | 4.783% |
| Records256 | Phase44 | 125,214,323 | 5 | 7 | 6.020% |
| Records256 | Worker23 | 3,786,384 | 193 | 290 | 7.300% |

The baseline allocation windows contain only 16 Map and five record calls, versus 283 and 193 for the candidate; fixed-duration sampling gives unequal call counts and limits precision. All six allocation profiles preserve a warning that sample-size totals and heap-tree estimates differ; four also preserve unattributed samples referring to absent tree nodes. The cause is not established. Frame weights use sampled sizes, with both accounting totals retained. No warnings are dropped or normalized into a clean bill of health.

Worker23's higher GC percentage does not contradict its lower allocation per call: it performs many more calls in each sampled window. Percentages alone do not determine GC seconds per uninstrumented call. Instrumentation includes repeated calls, result validation and loop control; import, first call, warmup and serialization are outside its stated loop boundary.

## Named CPU costs and live private components

The exclusive CPU share of `apply` + `invokeExact` + `force` + `callOwned` changes from 31.0% to 4.6% for Map and 42.6% to 8.3% for records. These sums cover only those four named runtime functions, not every possible dispatch cost. The guard functions `localGuard`, `scalarGuard`, `regionHostGuard` and `stringHostGuard` together account for 8.00% and 4.65% of candidate self CPU; reflection/string builtins may be attributed elsewhere.

| Candidate named function or component | Map self CPU | Records self CPU |
| --- | ---: | ---: |
| `Map.bit.go` private budget wrapper | 15.418% | 11.498% |
| `Map.bit.go.rec` acyclic helper | no named self sample | 9.311% |
| `Map.bit.go` native component | 5.633% | 1.018% |
| `Map.seek.go` native component | 6.114% | 3.888% |
| `String.cmp.fin/cmp` native component | 5.281% | 6.572% |

Names are recovered from the actual generated root's ordered source guards and private instance indices, with profile source positions identifying that root. In Map, relevant instance/component indices are 23 (`Map.bit.go`), 40 (`Map.seek.go`) and 11 (`String.cmp.fin`); records uses 19, 15 and 7 for `Map.bit.go`, its `.rec` helper and `String.cmp.fin`. These names explain observed work; they are not proposed compiler selectors. No named self sample does not mean no work; inlining and sampling can hide a separate function.

The Map.bit.go wrapper owns 27.384% of Map and 34.199% of records sampled allocation. Its source contains a native-budget check and a fallback argument vector, but **that attribution does not prove fallback or frame allocation**. Inlined native/helper allocations can be assigned to the wrapper. The narrower direct evidence is that records' named `$worker0` continuation machine has 2.669% of sampled allocation, whereas Map has no named machine allocation sample. That machine also executes constructors, so 2.669% is not a frame-only total; absence in Map is not proof that fallback never ran.

Every node in all six raw CPU profiles was scanned. None has a nonempty `deoptReason`, including the former oversized-function reason. This is absence in captured metadata, not proof that all functions optimized or that no deoptimization happened outside the sampled interval.

## Static JavaScript comparison

The parsed program section excludes the separately identified runtime/support prefix and export wrapper. Counts are syntactic sites and include unexecuted branches and required generic fallbacks; they are not dynamic call or allocation counts.

| Point | Role | Whole module bytes | Program bytes | AST nodes | Generic trampoline / argument-vector sites | Constructor helper sites | Array / object literal sites |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Map128 | TypeScript | 46,419 | 41,877 | 7,853 | 0 / 0 | 0 | 2 / 358 |
| Map128 | Phase44 | 271,679 | 209,451 | 45,434 | 449 / 449 | 761 | 2056 / 129 |
| Map128 | Worker23 | 246,492 | 183,835 | 46,407 | 405 / 405 | 387 | 1496 / 599 |
| Records256 | TypeScript | 48,905 | 44,598 | 8,350 | 0 / 0 | 0 | 6 / 366 |
| Records256 | Phase44 | 126,483 | 64,255 | 14,047 | 399 / 399 | 391 | 1299 / 49 |
| Records256 | Worker23 | 239,842 | 177,185 | 45,694 | 410 / 410 | 391 | 1496 / 613 |

Record output becomes larger despite its large measured execution improvement. The new native/continuation declarations coexist with public source paths and required fallbacks. Likewise, many static generic calls remain even when sampled hot execution uses private components. The static tool supplies normalized token comparisons and per-definition inventories in the preserved analysis directory; replacing site counts with a presumed dynamic cost would be misleading.

## Most useful next experiments

1. **Private aggregate forwarding and scalar replacement across calls.** The hot string/Map operations construct and project tuples/fields repeatedly. A reusable ownership/layout-aware IR pass could carry scalar fields across known local calls or branches when the aggregate cannot escape. Compare fresh allocation profiles and clean fast screens; preserve public object identity, sharing and mutation boundaries. The current attribution suggests an opportunity, not an estimated speedup or proof that every sampled byte is removable.
2. **Compact live continuation state.** Retain only live registers and useful return state at non-tail suspension. Records supplies named machine activity to inspect; Map's evidence is weaker. Use a separate counter derivative to distinguish actual fallback from inlined allocation before changing recursion policy. Do not raise the native budget from a sampled wrapper percentage.
3. **Amortize supported public boundaries through broader complete graphs.** Guard self CPU is visible even here, and tiny fixtures have much larger ratios. Extend typed coverage behind one entry instead of reinstating expensive acyclic public wrappers. The rejected worker20 comparison remains a direct falsifier for the latter approach.

These proposals concern generated-program execution. The separate [compiler-cost report](compiler-cost.md) finds slower request medians; speeding compilation needs compiler-stage evidence, not these generated-program profiles.

## Protocol and identities

The diagnostic protocol uses Node 24.18.0 on CPU 3, 150ms warmup, 600ms sampled loops, 1ms CPU sampling and 32KiB allocation sampling, with a 1024MiB heap and 2048MiB process-tree RSS/available-memory limits. Both points use exact existing catalog inputs. CPU and allocation profiles are separate fresh processes; profile timings are never substituted into the clean runtime summary.

Worker23 API is `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`, with runtime `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`. Each module and raw profile hash was rechecked before this data-only analysis. The role/source matrix is complete, allocation normalization independently matches recorded estimates, and all six static entries match their consumed module hashes.

Raw report: `selfhost/build/phase45/diagnostics23/report.json`, SHA-256 `61e75045a4e03e35d0de905f20e422ca3218cfde44e568b75a0bc9692fb50c71`. Static report: `selfhost/build/phase45/diagnostics23/analysis/report.json`. Consumed data-only extractor: `selfhost/build/phase45/diagnostics-facts23-v1.py`, SHA-256 `1721183c8528f622c33710e2e62a73645271f3300e337dda2fedeae7568ad2cf`. These paths will be bound by the portable evidence archive. No old raw reports were modified, and no target execution was run while writing this analysis.

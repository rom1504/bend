# Phase39 final generated-program profiles

The completed profiles support four concrete changes: fewer recursive dispatch
and temporary allocations in tree sorting, amortized guard checks in active
raytracing, less BigInt countdown allocation in numeric recurrence, and direct
producer/chooser execution in the expression workload. They also show substantial
remaining dispatch costs in lexer, list and map-based programs. **Those latter
programs were not changed by this phase**; their profile differences must not be
claimed as optimization effects.

All four diagnostic groups pass: 42 captures across seven input points, three
compiler roles and two profile kinds, in 65.469 seconds. They profile the exact
module bytes used in the completed 45-point clean comparison. A separate
read-only check rehashed all 42 raw profiles and module references and matched
every module SHA to its primary timing row. No target was rerun for this report.

## Scope and measurement boundaries

The comparison is installed Phase37 checked03 versus selected Phase39 checked05
(API `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`)
and TypeScript at `018751270e800bc222a93dad7f257083ee53a5f7`.
The [clean execution report](execution/report.md) contains 669 primary timing
samples over 45 points plus 60 separately retained canary-confirmation samples.
The profiles are additional instrumented observations and are excluded from
those timing ratios.

Each profile uses CPU3, Node v24.18.0, a 1 GiB heap, a 2 GiB process-tree ceiling
and a 2 GiB free-memory floor. The diagnostic preset uses at least one call and
150 ms warmup, then a 600 ms target profiling window. CPU sampling uses a 1,000 µs
interval; allocation uses 32,768-byte sampling for these selected IDs. All 42
captures reached their requested depth. That means the window completed, not
that every profile is statistically stable: the expensive lexer profiles contain
only three CPU-profiled calls and two allocation-profiled calls per selfhost role.

The profiler encloses repeated exports, result validation and harness loop work.
Import, first call, warmup and profile serialization are outside. Allocation
numbers sum V8 `samples[].size` estimates, including collected objects, then divide
by validated calls. They are neither retained heap nor exact object counts.
Every allocation profile warns that sample totals and the V8 call-tree estimate
differ; the cause is not established here. A few captures retain one sample with
no call-tree node as unattributed. The raw accounting and warnings remain visible.
CPU shares below use exclusive self weights. Source-owner totals aggregate
exclusive frame weights; inclusive totals are never added together.

## Allocation changes and clean timing context

Estimated bytes per exported call are rounded to whole bytes. The timing columns
come from the separate clean primary comparison, not profiled execution speed.

| Point | Phase37 allocation | Phase39 allocation | TS allocation | Allocation change | Clean Phase37 / Phase39 | Clean Phase39 / TS |
|---|---:|---:|---:|---:|---:|---:|
| tree-bitonic, depth 8 | 23,317,490 | 11,755,233 | 1,366,028 | −49.59% | 1.793× | 36.801× |
| lexer, depth 8 | 220,654,960 | 220,723,084 | 3,961,030 | +0.03% | Identical code | 89.292× |
| active ray, 256 pixels | 87,377,256 | 35,114,701 | 1,044,321 | −59.81% | 2.617× | 31.027× |
| numeric recurrence, 1,024 | 51,632 | 10,749 | 118 | −79.18% | 1.221× | 2.794× |
| list pipeline, 512 | 2,738,867 | 2,758,130 | 94,562 | +0.70% | Identical code | 55.980× |
| expression, depth 128 | 600,248 | 102,413 | 23,336 | −82.94% | 8.052× | 5.239× |
| record aggregation, 64 | 29,783,892 | 29,907,276 | 654,690 | +0.41% | Identical code | 74.927× |

The changed-code gains have disjoint primary timing ranges. Their exact medians
still have limitations: tree candidate half drift ranges from −15.6% to −12.3%,
active-ray reaches −27.5%, and expression reaches +9.6% in one candidate sample.
The timing report retains these rather than treating completed five-round runs
as proof of full JIT stabilization.

For numeric recurrence, roughly 91× TS's estimated allocation accompanies only
2.79× its execution time. This alone shows why neither an allocation ratio nor
a CPU sample share can be transferred directly into a speedup prediction. Its
TypeScript allocation estimate is also small enough that harness/inspector work
is a material part of that number.

## What changed, and what is still expensive

### Tree sorting

The four runtime helpers `apply`, `invokeExact`, `force` and `callOwned` sum to
49.38% of baseline sampled self CPU and 38.76% of candidate sampled self CPU.
Candidate `invokeExact` alone is 14.63%, `apply` 13.54%, and source-owned `warp`
13.30%. Direct structural workers removed part of the dispatch graph, not all
of it. The dominant source-owned allocation shifts from `warp` (39.68% baseline)
to `flow` (25.95% candidate); candidate `warp` still accounts for 18.52%,
`warp_leaf` 12.94%, `ctor` 8.76% and `apply` 7.22%.

TypeScript instead spends 52.95% of sampled self CPU in `warp` and 18.39% in
`flow`, with most sampled allocation attached to those algorithm functions.
The remaining selfhost work is therefore a combination of ordinary tree
construction and surviving generic dispatch. The saved-output component
ablations and actual worker/alias controls in [components.md](components.md)
provide the causal evidence; this later profile is consistent with them and
locates the next residual component. It does not identify a complete safe
replacement for `flow` from samples alone.

### Active raytracing

Baseline `regionHostGuard` and `scalarGuard` consume 24.02% and 14.20% of sampled
self CPU. Neither obtains a self CPU sample in this candidate capture. They
still exist: the guarded outer entry remains, and the separately validated scope
counters establish that full host/scalar checks collapse from 2,973 to one for
this point. Zero samples does not mean zero checks or permission to remove the
remaining check.

Descriptor/name reflection accounts for 38.38%/9.44% of baseline sampled
allocation. After proof reuse, candidate `apply` is the largest allocator
(25.78%) and largest CPU frame (29.84%); source-owned `trace` contributes 22.56%
of allocation across 52 mapped frames and 15.21% of self CPU across 50 frames.
`nearest` contributes another 8.92% of allocation. The 59.81% allocation reduction
supports the guard-amortization finding in [guard-scope.md](guard-scope.md).
The next target is the remaining trace/intersection dispatch graph, not another
round of indiscriminate guard-scope creation. The candidate still allocates about
33.6× TS's sampled bytes per call, but that is not a promised removable fraction.

### Numeric recurrence

The candidate removes most sampled allocation from `p37.numeric`: that function
was 78.99% of baseline allocation. Its CPU share remains about 40% (40.84% before,
39.67% after), which is a share of a smaller total, not evidence that the counter
change failed. Candidate `regionHostGuard` is now 32.78% of sampled CPU,
`scalarGuard` 6.67% and `localGuard` 2.40%. Descriptor creation, property-name
arrays and scalar guarding contribute 62.05%, 25.61% and 9.12% of its remaining
sampled allocation, respectively.

The [countdown controls and ablation](countdown.md) isolate the representation
change; these final profiles support its allocation effect. A remaining fixed
entry cost matters at this roughly 22 µs export. That does not authorize caching
proof across mutable public calls: the root already checks once per invocation,
and host/dependency mutation still requires detection on the next call. Any
future allocation reduction must preserve the same descriptor/accessor,
prototype, own-property and reentry obligations.

### Expression producer and chooser

Baseline `apply`, `force` and `callOwned` contribute 22.87%, 14.99% and 14.57%
of sampled self CPU. Candidate CPU shifts to `p37.expr` (22.39%), the private
chooser (17.19%), `eval` (9.93%) and one remaining host guard (18.02%). The producer
and chooser now appear as one mapped frame each, compared with several generic
frames before. Candidate `apply` is 1.10%; neither `force` nor `callOwned` receives
a self sample in this capture.

The remaining sampled allocation is concrete construction/frame work:
chooser 30.58%, producer 29.84%, `ctor` 16.37% and `eval` 11.64%. The code still
materializes tagged expressions and explicit producer/evaluator frames. This is
consistent with the strong full-component versus producer-only ablation in
[unary-producer.md](unary-producer.md). A smaller frame layout or avoiding a
provably unobserved intermediate is a plausible next experiment, but changing
when the producer and consumer run must preserve pre-child, child and post-child
error order, shared subtrees and explicit-stack behavior. These samples alone
do not establish a legal fusion.

## Unchanged programs are the noise control

**23 of the 45 primary points have byte-identical baseline and candidate
modules**, including lexer, list, map, BST and record families. Among the profiled
points, lexer/list/record have identical hashes, static inventories and runtime
code. Their +0.03%/+0.70%/+0.41% estimated allocation differences are variation between instrumented runs, not
new compiler effects. Sampling and JIT/allocation behavior can both contribute;
this comparison does not isolate their shares. The shifted CPU percentages also
cannot be attributed to new compiler code.

The clean lexer medians differ by −1.26% with disjoint sampled ranges, list by
−1.10% with overlapping ranges, and record by +6.65% with overlapping ranges.
Because the bytes are identical, none establishes a source optimization or
regression. Record candidate/baseline ranges overlap substantially and within-
sample drift reaches about −20%; attributing its +6.65% median difference to
this phase would be wrong. Even a disjoint range from a small run does not
overrule known code identity.

Their persistent hotspots are nevertheless useful:

- **Lexer:** `apply`/`invokeExact`/`force`/`callOwned` total 54.53% of candidate
  sampled CPU. Allocation is spread across dispatch plus `step.at` (11.33% across
  42 mapped frames), `lex` (9.43%) and `cls.go` (7.41%). The many mapped frames
  suggest staged matching/reconstruction, not just one expensive arithmetic
  operation.
- **List pipeline:** those four helpers total 59.14% of candidate CPU. Allocation
  is spread across `p37.list` (15.46%), `keep_gt1` (13.49%), `dbl` (12.15%) and
  dispatch. Source inspection confirms the timed pipeline is first-order local
  recursion; it does not call an unknown user callback. The rejected callback
  prototype is not evidence that a closure-specialization pass would help here.
- **Record aggregation:** four-helper CPU share is 44.53%, with another 21.47%
  mapped to `fn:argument1`. Map/string routines are visible, including
  `Map.bit.go` (13.58% of allocation) and `Map.bit.go.rec` (6.28%). Its application
  wrapper is small; much work comes from included Base routines. Map-churn and
  BST are relevant future transfer controls, but were not among these seven
  profiled points. This report makes no hotspot claim for their unprofiled runs.

## Static generated-code comparison

These counts are **syntax sites**, not executions. Source-owned bytes/calls include
private specializations inside owned registrations but omit copied runtime,
Base-only registrations and shared support declarations. The distinction matters
especially for the map-heavy record application. Function-expression and arrow
sites are not proof that closures escape or execute frequently.

| Point | Full module bytes, Phase37 → Phase39 | Source-owned bytes, Phase37 → Phase39 / TS | Source-owned calls, Phase37 → Phase39 / TS | Trampoline sites, Phase37 → Phase39 |
|---|---:|---:|---:|---:|
| tree-bitonic | 91,332 → 98,342 | 11,337 → 18,345 / 4,981 | 295 → 385 / 29 | 73 → 90 |
| lexer | 92,922 → 92,922 | 12,083 → 12,083 / 7,403 | 363 → 363 / 66 | 84 → 84 |
| active ray | 143,807 → 143,974 | 64,482 → 64,649 / 20,101 | 1,722 → 1,727 / 353 | 395 → 395 |
| numeric recurrence | 79,384 → 79,458 | 3,338 → 3,412 / 877 | 69 → 72 / 9 | 7 → 7 |
| list pipeline | 119,735 → 119,735 | 7,905 → 7,905 / 4,696 | 271 → 271 / 40 | 65 → 65 |
| expression | 82,665 → 83,702 | 4,528 → 5,565 / 1,849 | 103 → 118 / 13 | 20 → 18 |
| record aggregation | 121,959 → 121,959 | 2,341 → 2,341 / 2,008 | 81 → 81 / 16 | 30 → 30 |

Tree gains occur despite more call, array and trampoline **sites** because the
compiler retains generic fallback and adds private workers; those sites do not
measure hot-path frequency. Numeric source-owned BigInt literal sites fall
8 → 3, while its array/object sites stay 10/0 and allocation falls 79%. Expression
source-owned array/object sites increase 45/3 → 59/4 while allocation falls 83%.
These are useful counterexamples to optimizing a static site count as the target.
Use structural comparisons to locate emitted patterns, then use live admission,
semantic controls and clean ablations to establish their effects.

## Next experiments justified by these observations

These are hypotheses, not new speed estimates or completed implementations.
Do not multiply the remaining sample shares or the separate workload gains.

| Priority | Smallest useful experiment | First falsification/control | Why this is next |
|---|---|---|---|
| 1 | Direct **unfused** first-order list producer/filter/map/fold component in saved output | Preserve complete intermediate lists, alias/error order and generic public entries; compare exact size128/512 points at20s then60s | Simple pipeline source plus59% sampled dispatch CPU; separates dispatch removal from fusion |
| 2 | One complete private lexer step/continuation component | Require compiler-owned forced fields and original left/right/child demand; compare smaller existing lexer variation, then historical lexer | Large unchanged gap and220MB sampled allocation/call; avoid adding a scope at every token/character |
| 3 | Tree `flow`/remaining constructor and leaf continuations using the existing worker framework | Distinguish guard-only, one helper and complete component; reuse complete-tree/mutation/deep-stack controls at all three depths | Highest reuse of current proofs; current `flow` allocation and generic dispatch remain visible |
| 4 | Reduce allocation within the **existing** guarded numeric/expression entry | Same mutable descriptor/own-property/prototype/DataView/Error and reentry controls; compare numeric zero/small/1,024 and expression32/128 | Residual guard work is large after dispatch wins; one guard is still required per ordinary call |
| 5 | One closed Map/String kernel used by record aggregation | Inspect/ablate an exact saturated subtree first, preserve key ordering/Unicode and public mutations; check map/record/BST transfer independently | Base-heavy cost and Map.bit allocation suggest shared benefit, but polymorphism/strings broaden proof obligations |

Producer/consumer fusion can follow a successful direct-unfused experiment using
that direct version as its denominator. It should not be bundled into the first
change: interleaving traversals may change which error is observed and when work
is demanded. A global closure or IR rewrite is not justified merely by these
profiles; the [callback experiment](callbacks.md) already showed that a new proof
boundary and exact-code dispatch mode can cost more than one direct call saves.
Every proposal must also pass the separate compiler-cost gate: Phase39 already
pays a measured +3.50% tree compilation-request median for its added paths.

## Evidence paths

Raw reports and their hashes are retained under `selfhost/build/phase39/` and
in the campaign evidence capsule when published:

| Diagnostic group | Points | Captures | Wall seconds | Report SHA256 |
|---|---:|---:|---:|---|
| `final-historical-diagnostics01` | 2 | 12 | 20.974 | `b2e1bc896ed0b2d045c47557598ccac4ad4013573e430377047f9fee221d96e7` |
| `final-variation-diagnostics01` | 1 | 6 | 10.251 | `3c4666752925b67bfb82cc581f8349a443c051ff22a3336246c2d930d1c690dd` |
| `final-development-diagnostics01` | 2 | 12 | 15.540 | `85d6eb1c869a5483e22f87168d4a323e3a32b1aceae8ae0925c81c123250f11b` |
| `final-exposed-diagnostics01` | 2 | 12 | 18.704 | `991e25ba903a3706273d12dbec4cee9178ba32b4e3bd8a3adc68f0fe7bb067c8` |

Each has `report.json`, CPU/allocation samples and raw profiles, an
`analysis/report.{md,json}` static inventory, normalized token files and
`analysis/comparison.html` for aligned Bend-definition/generated-source review.
`exposed` describes the former holdout partition honestly: its expression
workload informed this optimization, so it is no longer unseen evidence.

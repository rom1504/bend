# Phase37 final generated-program profiles

The final profiles support the numeric and tree mechanisms, while exposing
substantial remaining runtime overhead. Estimated allocation per call falls
about **71% for numeric recurrence** and **31% for tree bitonic**. Lists remain
dominated by generic application/forcing, and active rays spend a large share
in guards. These diagnostic captures do not establish the cause of the smaller
list/ray timing regressions or replace the
[clean execution measurements](execution/report.md).

All **24 requested CPU/allocation captures pass**, using the frozen checked03
candidate, Phase36 and pinned TypeScript. No held-out application was profiled,
and no optimizer change followed final holdout timing.

| Completed diagnostic run | Points | Captures | Workflow seconds |
| --- | ---: | ---: | ---: |
| [Development](../../selfhost/build/phase37/development-final-profiles01/report.md) | Numeric 1024; list 512 | 12 | 15.172 |
| [Tree](../../selfhost/build/phase37/tree-final-profiles01/report.md) | Tree depth 8, seed 0 | 6 | 9.186 |
| [Active ray](../../selfhost/build/phase37/ray-final-profiles01/report.md) | Active ray 256, seed 2240 | 6 | 9.987 |
| Total | 4 | **24** | **34.345** |

## Identity and measurement limits

A read-only review rehashed **150 distinct files** named by the three reports'
direct input/output identities and their module/raw-profile references. All
matched. Each diagnostic compiler identity equals the corresponding identity
in the final 45-point aggregate, including candidate API
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
Each capture's module hash is among its run's recorded inputs, and its export,
arguments and expected output match the frozen catalog point. This supplements
the checked acquisition/owner closure; it is not a replacement for those
recursive provenance audits. Report identities are recorded below.

Each capture is a fresh serial process on CPU 3, Node 24.18.0, with a 1,024 MiB
heap, 2,048 MiB process-tree RSS limit and 2,048 MiB available-memory floor.
The requested warmup is one call and at least 150 ms; the instrumented window
targets 600 ms. All captures reach that target. CPU sampling uses a 1,000 μs
interval. Allocation sampling uses 32,768 bytes for all four selected points,
including objects collected by minor and major GC.

The window includes calls, exact-result validation and loop control. Import,
first call, warmup, profile serialization and final identity checks are outside.
There is one capture per point/role/kind, not repeated profiling rounds. CPU
shares are sample-weighted self cost and need not track changes in absolute
cost; JIT inlining may attribute work to an enclosing frame. No sampled frame
does not prove no execution. Static source counts do not establish frequency.

Allocation figures sum `samples[].size` and divide by completed calls. They are
sampling estimates of allocated bytes during the window, **not retained heap,
peak RSS or exact allocation counts**. Every allocation report warns that its
sample total and tree-head estimate differ; the absolute total differences are
at most 0.118% here, but their cause is not established. One TypeScript tree
sample, 34,136 estimated bytes, references an absent tree node and is retained
as unattributed rather than assigned an invented call path.

## Allocation comparison

The table reports estimated bytes per completed call, rounded for readability.
The percentage is the change in this allocation estimate, not a speed ratio.

| Point | TypeScript | Phase36 | Checked03 | Candidate change |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence 1024 | 125 | 176,929 | 51,441 | **−70.93%** |
| List pipeline 512 | 94,207 | 2,762,863 | 2,783,284 | +0.74% |
| Tree bitonic depth 8 | 1,372,518 | 33,659,413 | 23,075,825 | **−31.44%** |
| Active ray 256 | 1,057,393 | 86,466,245 | 86,957,957 | +0.57% |

The number of completed calls in allocation captures differs substantially:
numeric Phase36/candidate complete 3,802/15,799; list 239/273; tree 19/25;
ray five/five. Normalization is necessary, and the short tree/ray captures are
not precise estimates of small allocation differences. Their full raw samples
and accounting warnings remain available in each diagnostic report.

## Numeric: dispatch removal works; guards and loop allocation remain

In the baseline CPU profile, the private numeric loop has 31.16% self cost;
`invokeExact` has 9.53%, `apply` 7.33%, `get` 5.62%, the native wrapper 5.45%,
and `callOwned` 3.58%. The candidate concentrates 46.11% in the private loop,
25.13% in `regionHostGuard`, 5.09% in `scalarGuard`, and 7.63% in GC. Generic
dispatch no longer dominates the recurrence body. The increased guard share
does not by itself mean the guard became proportionally more expensive: it
now occupies a larger fraction after other work was removed.

The allocation estimate falls from 176.9 KB to 51.4 KB per call. The candidate
still attributes 79.26% of sampled allocation to the private loop;
`getOwnPropertyDescriptor` and `getOwnPropertyNames` account for 12.55% and
5.54%. This supports two remaining investigation targets: allocation within
the loop, and metadata allocation during entry validation.

The saved private loop still decrements a `BigInt` counter each iteration.
A proved bounded numeric countdown is therefore a concrete future hypothesis;
the profile does not identify all loop allocation as BigInt allocation, and
no countdown ablation was performed in this phase. Entry-guard improvements
must preserve the live native/Math/Number/DataView mutation semantics covered
by the new controls. Removing those checks is not an admissible shortcut.

The clean run, separately, measures a **5.165×** gain at numeric 1024 and a
remaining **3.338×** TypeScript gap. The profile is mechanism evidence for that
result, not an independent timing comparison.

## Lists: generic runtime overhead persists; regression cause unresolved

List CPU self cost is very similar between versions:

| Frame | Phase36 share | Checked03 share |
| --- | ---: | ---: |
| `apply` | 26.99% | 25.77% |
| `force` | 16.26% | 16.01% |
| `invokeExact` | 5.65% | 4.69% |
| `callOwned` | 4.95% | 4.74% |
| `project` | 4.99% | 5.12% |
| Garbage collector | 6.17% | 4.83% |

TypeScript instead spends most sampled CPU time in the actual list generator,
filter and mapping function: 26.50%, 23.97% and 23.45%. The Bend allocation
estimate remains about 2.8 MB per call, compared with TypeScript's 94 KB, and
the same application/forcing/closure/matcher machinery remains visible.
This is evidence of a broad opportunity to optimize proved recursive and
higher-order execution, not a demonstrated new optimization in this phase.

No region host/proof-entry frame is sampled. More strongly, the separate
[static comparison](optimizer/development-final-observations.md) establishes
that the two modules contain no calls to those region entries, and all six
benchmark-reachable definition bodies are unchanged. New finite branches are
in unused definitions. Thus direct new guard or selector execution does not
explain the **+4.65%** clean timing penalty.

The roughly unchanged allocation estimate and similar dispatch profile do not
isolate a cause. The candidate's lower sampled GC share also does not justify
attributing the slowdown to extra GC. Module-layout/JIT-context effects remain
possible, but untested. This profile neither erases the disjoint slower timing
ranges nor supplies a causal explanation for them.

## Trees: fewer allocations, but the generic recursive component remains

The tree candidate reduces estimated allocation from **33.66 MB to 23.08 MB**
per call. `apply` CPU self share falls from 25.65% to 22.12%; `force` from
7.48% to 6.96%. `invokeExact` remains substantial, at 12.30% and 13.44%.
The candidate still allocates far more than TypeScript's 1.37 MB per call.

TypeScript CPU time concentrates in `warp` (56.44%) and `flow` (16.96%);
those functions account for 67.35% and 17.72% of its estimated allocation.
Bend still spends much of its window in the generic call/forcing machinery
around recursive work. The finite selector removes useful work at a narrow
boundary but does not turn the whole recursive component into direct code.

The clean depth-8 improvement is **1.221×**, with improvements at both other
selected tree sizes. The allocation reduction is consistent with that
mechanism. These 19/25-call allocation captures do not establish a precise
allocation model or a speed prediction for a larger recursive rewrite.
Any future direct component must retain tail-cycle, demand-order, alias,
mutation and fallback controls; the earlier faster saved-output prototype
does not itself discharge those compiler obligations.

## Active rays: proof validation is a major remaining cost

The baseline/candidate CPU profiles give `regionHostGuard` **24.08%/27.38%**
self share and `scalarGuard` **12.82%/14.64%**. `apply` remains
14.60%/13.58%; `invokeExact` shifts from 3.98% to 11.52%. A single short
capture does not establish the reason for that shift.

The strongest allocation signal is property inspection: baseline/candidate
`getOwnPropertyDescriptor` has **37.75%/39.58%**, and
`getOwnPropertyNames` **9.66%/9.36%**, of estimated allocated bytes. Total
allocation remains about **86–87 MB per call**, versus TypeScript's 1.06 MB.
TypeScript's sampled CPU instead concentrates in intersection and tracing
work, led by `isect5` at 49.48%.

Both Bend CPU captures complete seven calls, and allocation captures only
five. The profiles identify guard/descriptor work as an important mechanism
to investigate, but cannot attribute the clean run's **+3.58%** regression
to the DataView guard or any single emitted change. Root-scope counters and
controlled guard-cost ablations would be needed for that conclusion. The
required host-mutation checks remain part of the admitted implementation.

## Static analysis and the next experiment boundary

Each diagnostic run includes parsed generated-source inventories and an HTML
side-by-side comparison. Whole-module counts illustrate why syntax alone is
insufficient:

| Point | Phase36 → candidate bytes | Static argument-array sites |
| --- | ---: | ---: |
| Numeric 1024 | 78,764 → 79,384 | 52 → 50 |
| List 512 | 116,349 → 119,735 | 357 → 373 |
| Tree depth 8 | 86,112 → 91,332 | 124 → 139 |
| Active ray 256 | 141,890 → 143,807 | 457 → 455 |

Numeric removes only two static argument-array sites but removes their repeated
dynamic dispatch. Tree adds fallback/fast-path syntax while reducing measured
allocation. List adds syntax outside the benchmark's reachable definitions.
These counts include runtime support and unused definitions; they are not
source-language concept counts or hot-loop execution counts.

For a subsequent phase, the evidence favors a small bounded-countdown ablation
for numeric, separate validation-cost experiments for rays, and a proof-driven
recursive/list component experiment. Each needs independent semantics and a
short clean paired timing loop, followed by broader regression checks and
fresh holdouts. No such follow-up was implemented or tuned from these final
profiles. The [performance admission](performance-admission.md) retains the
current gains and costs without claiming overall parity.

## Raw report identities

The evidence capsule preserves generated reports, modules, samples and profiles.
These SHA256 values identify the three reviewed report documents:

- `development-final-profiles01/report.json`:
  `5e3e553d8ac804d6c72a07c79afbb452c600bc1cacaff386b0afaf13465aaa4d`
- `tree-final-profiles01/report.json`:
  `bf3c98e159897a5458bd4813cb5cbf27b1085897881d49d0ca6e5154c570e6d5`
- `ray-final-profiles01/report.json`:
  `6d464d02481e6038074063d3e4f8bf864587777fa9070296c4c8addaf1d20486`

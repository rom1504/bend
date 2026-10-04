# Generated-program diagnostics

**The remaining evidence points to dispatch and temporary allocation, with
different costs across applications.** Phase44's local IR simplifications leave
those larger mechanisms largely intact. All **18 CPU/allocation profiles pass**:
three cases, three compiler roles and two profile kinds. The diagnostic campaign
completed in 27.47 seconds. These are instrumented observations, not execution
speed measurements.

Here baseline means Phase43 checked14, candidate means Phase44 checked04, and
TypeScript is the pinned upstream compiler. This comparison does not use the
rejected [known-call prototype](known-call-dispatch.md).

## Observed allocation and CPU profiles

| Case | TypeScript estimated bytes/call | Phase43 estimated bytes/call | Checked04 estimated bytes/call | Checked04 / TypeScript allocation estimate |
|---|---:|---:|---:|---:|
| Map128 | 2,191,457 | 29,495,282 | 29,643,950 | 13.53× |
| BST64 | 392,566 | 623,719 | 619,005 | 1.58× |
| Records256 | 2,722,934 | 124,509,800 | 126,323,027 | 46.39× |

These are sampled allocation estimates during each profiler window, not retained
heap, exact allocation counts or runtime slowdown ratios. Every allocation
profile reports a difference between sample and tree accounting; the cause is
not established. One TypeScript BST sample is unattributed. Checked04's Map and
records allocation windows contain only 16 and five application calls,
respectively, so small baseline/candidate differences warrant particular caution.

**Map128:** checked04 CPU self shares include `invokeExact` 13.2%, `apply` 10.6%,
`project` 6.5% and `force` 6.3%. Its largest allocation frame is contextual
worker `$instance.23` at 18.6%, followed by `project` at 16.2%. TypeScript's
`Map.bit.go` accounts for 31.9% CPU self weight and 43.1% allocation weight.
Private workers are executing, but generic dispatch and field projection still
consume substantial samples around them.

**BST64:** both compilers concentrate work in `p37.bst.build`. Checked04 assigns
59.6% CPU self weight and 89.7% allocation weight there; TypeScript assigns 69.8%
and 99.8%. Checked04 also attributes about 11.0% CPU self weight in total to
`regionHostGuard`, `scalarGuard` and `localGuard`. This case already executes
substantial direct worker code; it is not simply another generic-dispatch case.
Percentages describe each instrumented run's distribution, not absolute costs
across compilers.

**Records256:** checked04 CPU self shares are `apply` 16.3%, `force` 13.8%,
`invokeExact` 9.3% and `callOwned` 4.9%. Allocation self shares include `apply`
10.5%, `callOwned` 7.5%, `project` 7.1% and `force` 5.3%. TypeScript instead
concentrates samples in direct Map operations. The record application's cost
therefore includes library execution, not merely constructing its own records.

## Observed generated syntax

Source-owned statement ranges exclude copied runtime and Base-only definitions,
but include private specializations nested inside an owned registration:

| Case | Source-owned bytes, TS → checked04 | Function-expression/arrow sites, TS → checked04 | Array literal sites, TS → checked04 | Trampoline helper sites, TS → checked04 |
|---|---:|---:|---:|---:|
| Map128 | 2,928 → 148,540 | 0 → 43 | 0 → 802 | 0 → 90 |
| BST64 | 4,104 → 25,122 | 0 → 73 | 0 → 233 | 0 → 88 |
| Records256 | 2,008 → 2,886 | 0 → 31 | 0 → 35 | 0 → 31 |

These are static sites, not executed allocation counts. TypeScript's ordinary
function declarations are a different syntactic category from the function
expressions and arrows counted here. Source-owned ranges also omit shared
support, so this table is not a complete dependency-size comparison.

Map's source-owned normalized token files are identical between Phase43 and
checked04. BST and records lose two and three function-expression/arrow sites,
respectively, while their source-owned array and trampoline counts stay the
same. Across the full post-runtime text, including Base, checked04 still has
895 function-expression/arrow sites for Map and 877 for records. This supports
the narrower observation that the current passes remove some local wrappers
without changing the main allocation/dispatch structure.

## Interpretation and next evidence

The separate complete timing summary covers 45 points and 669 samples. Its
equal-point geometric slowdown is 6.1214× TypeScript for Phase43 and 6.0832× for
checked04, a 1.0063× baseline/candidate ratio. That essentially flat result comes
from timed execution, not these profiles; see the [phase report](README.md).

A reasonable next hypothesis is that general IR lowering must eliminate
argument vectors, intermediate function descriptors and projection temporaries
where legality facts allow it. Map and records supply evidence for investigating
those operations; BST requires separate attention to worker allocation and guard
cost. The profiles do not establish how much any proposed transformation would
save. In particular, the rejected known-call experiment shows that adding a
specialized invocation helper while retaining dispatch is insufficient on its
screened cases.

Raw evidence lives under `selfhost/build/phase44/diagnostics04/`: `report.json`
binds all inputs and 18 profiles; `analysis/report.json` contains syntax and
mapping details; `analysis/comparison.html` presents aligned generated source;
and `profiles/<case>/<role>-<kind>/` holds raw profiles and summaries. The separate
timing receipt is `selfhost/build/phase44/full-runtime-summary04.json`. Consult
the phase report for evidence publication and release status.

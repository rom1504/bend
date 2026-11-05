# Phase167 — cost model and independent falsifiers

Source-only review of retained Phase152/160–166 evidence; no target execution.
The question is complete **cold native compiler acquisition**, not one backend
kernel, source-to-IR alone, or unchecked bendc self-emission.

## Comparable clocks

| Observation | Boundary | Valid inference |
|---|---|---|
| Phase152 N2→N3 **249.222s**; emission+QBE overlap **242.103s** | Same 3,085,157-byte source, fixed prepared Base, emission piped to QBE, assembly/link; qualified exact self-reproduction | Current complete-build reference; not 242s emission plus another QBE duration. The residual after that overlap is7.119s. |
| Phase160 same compiler through QBE **223.237s**, bendc/C **167.602s**, same C factor1 **138.383s** | Full source-to-QBE, live Base, exact118,227,421 output bytes; machine building excluded | Execution/runtime can matter substantially, but observed full-request factors are1.33×/1.61×, not the much larger small-input factors. Different executable/runtime from the Phase152 reference. |
| Phase161 fixed request executable full **226.912s** → native-source closure **194.417s** | Input changes; live Base, source-to-QBE only | 14.32% screen, chiefly less frontend work. Output remains about118MB/73,926 functions; closure product unqualified. |
| Phase164 same1,556,351-byte private source acquisition **201.931s** → **201.271s** | Original qualified executor builds mixed N1; N1 builds mixed N2; complete machine acquisition | Effectively neutral generation screen. Comparing either number with249s would change source and be invalid. |
| Phase164 mixed N2 **179.548s** | Self-emission only, exact104.740MB predecessor stream | Not a179s complete cold build. |
| Phase166 complete lookup/consumer **0.54148s QBE /0.35772s C /0.15649s bendc** | Identical15KB workload, different backends/runtimes, repeated consumed result | A3.46× kernel execution gap; not a whole-compiler multiplier. |

Sources: [Phase152](../../implementation/phase152/README.md),
[Phase160](../../implementation/phase160/README.md),
[Phase161](../../implementation/phase161/README.md),
[Phase164 mixed measurements](../../implementation/phase164/mixed-findings.md),
[Phase166](../../implementation/phase166/README.md). These are screens with the
stated replication, not interchangeable additive timers or confidence bounds.

## Why lazy generic construction is necessary but insufficient

The full Phase161 diagnostic partition totals239.794 CPU seconds. It is the
qualified Phase152 object with prepared Base and an observer; do not subtract
these clocks directly from a clean live-Base request or the249s acquisition.

| Region | CPU seconds | What direct-first alone leaves |
|---|---:|---|
| Parse/load + check/publication + report |66.520|All, unless the generated compiler executes it faster or its representation/algorithm changes. |
| Generic body production |11.588|Retained factories, scheduler-only owners and continuations still required. |
| Private/direct candidates |26.782|Still constructed and analyzed; source preparation already shares `NativeStaticBody`. |
| Initial optimizer |23.673|Useful direct optimization remains. |
| First independent verifier |7.857|Required real bodies/schema/ownership obligations remain. |
| Observer composition + selected final admission |19.625|Includes9.26s conditional final verifier; do not add it again. |
| Registry |16.190|Only attributable discarded representation/analysis can disappear. |
| Render/output/teardown |40.208|Includes required output and destruction; emission already streams. |

Exact partition: [profile-metrics.json](../../implementation/phase161/profile-metrics.json).
The direct generic-production envelope is only4.83% of this diagnostic total.
Even granting the impossible removal of **all** generic production, both named
verifier intervals, the entire registry and all rendering/teardown would remove
85.10s, about35.5%. This deliberately overgenerous bundle is **not** a forecast
or a rigorous ceiling on secondary lifetime effects. It shows why those labels
do not themselves explain2×,5× or10×. The actual admissible fraction is smaller.

Phase164's mixed route already tested the main mechanism:10.44% fewer continuation
segments,4.68% smaller QBE, the same2,096 direct functions, effectively unchanged
complete acquisition. It did not fail correctness; it failed to establish useful
construction economics. Most private analysis, final direct optimization,
symbolic metadata, frontend and output survived. Additional adapter/import and
qualification machinery also has costs. There is no attribution proving one
specific compensating cost, so “verifier overhead exactly cancelled the saving”
would be an unsupported explanation. Its runtime wins were reproduced by a much
smaller imports-only route retaining generic construction, isolating composition
from body omission. Merely reimplementing this route is not a new hypothesis.

The qualified output has1,448 direct workers with same-name scheduled entries;
those entries **already call the direct workers**. Their808KB of wrapper text is
required interface work, not1,448 slow duplicate executed algorithms. The much
larger48,096 continuation population cannot all be assigned to admitted owners
from a symbol count. See [Phase163 census](../phase163/hybrid-direct-first.md).

## What can disappear without weakening the independent final checks

1. **Never construct an unused generic body.** Keep actual factories, entry
   headers, static/descriptors, and a truthful verified direct adapter for the
   positively admitted owner. Carry omitted-owner obligations through late
   transformations. Every final adapter/import must still resolve to the exact
   worker ABI; missing or changed workers refuse or require genuine fallback.
   Stable IDs authenticate references, not fictitious body validity.
2. **Avoid a repeated scan of unchanged verified generic/static bodies.**
   Phase164's retained-original candidate already does this: retain the successful
   opening's actual immutable original, accept only final direct functions and
   checked constructor hot flags, reconstruct emitted original fields from that
   retained value, check schema/order, and independently verify final direct
   bodies plus all omitted-owner obligations. A Boolean/hash supplied by an
   external caller is not authority. Do not count this existing experiment twice.
3. **Drop obsolete optimizer/reference carriers after their last consumer.**
   This needs an actual last-use map: raw candidates feed late ownership/product
   retries; headers feed FID resolution; original source/static schema supplies
   constructor/effect authority; generic bodies feed retained scheduler and region
   emission. A typed minimal authority record could replace larger carriers only
   after each obligation is represented and checked. Removing the independent
   verifier, original diagnostics on failure, or retained runtime fallback is
   not such a replacement.

Implemented evidence: [`hybrid-retained.bend`](../../selfhost/tests/phase164/hybrid-retained.bend),
[retained-original audit](../phase164/retained-original-audit.md),
[`checked-boundary.bend`](../../selfhost/src/back/qbe/checked-boundary.bend),
[`stream-emission.bend`](../../selfhost/src/back/qbe/stream-emission.bend).
Final IR validation proves its structural/ownership contracts; it does not by
itself prove semantic equivalence of a new source lowering. Keep independent
source/output/runtime gates and distinguish finite qualification from BendTT proof.

## Test the ambitious architecture, not its slogan

Relative to249.222s,2×/5×/10× require124.611/49.844/24.922s complete builds.
Under an **unchanged-executor** assumption, the diagnostic66.52s frontend alone
already exceeds the5× and10× budgets. This is an Amdahl warning, not a hardware
lower bound: a newly generated compiler can execute the frontend differently.
Even2× requires removing or accelerating a broad part of the backend, well beyond
generic omission. Tenfold must combine less semantic/analysis work, much cheaper
temporary representation/lifetimes, faster execution, and small machine products.
The current evidence does not supply these factors yet.

The next architecture should therefore change **what is constructed and kept**:
one canonical typed body per owner; direct-or-scheduled lowering selected from
authenticated eligibility; compact typed/numeric analysis state; fallback bodies
materialized only for real consumers; minimal retained authority; local allocation
boundaries. Existing compacted-body caching is retained. Native tuple counts must
be measured: Phase166 falsified importing millions of hosted String.cmp tuples
into native allocation estimates because the borrowed reader already removes them.

Cheapest decisive sequence for the root-owned execution lane:

* Start from one already checked real backend request with both direct and
  scheduler-only owners. For original and candidate, count prepared owners,
  generic/direct bodies actually constructed, final emitted bodies, discarded
  candidates, fact rows, retained authority and emitted bytes. Measure clean
  end-to-end backend time separately from observers. A faster tiny direct library
  or fewer function names does not pass this gate.
* Require actual work to disappear **downstream**—optimizer/fact construction,
  registry, verifier input and emission—not merely a different generation order.
  Keep malformed missing-worker, unresolved-FID, constructor-schema, callback,
  effect, shared-alias and deep-stack controls. Preserve independent final checks.
* Transfer once to an unrelated complete checker/optimizer request. If the gain
  vanishes or shifts work into late fallbacks, stop before a full image build.
  Only a clear substantial region gain justifies one bounded native acquisition,
  followed by the same-source N2 request. Record image-build cost separately.

To distinguish the hypotheses cheaply, ask first whether the **complete backend**
can improve2× while preserving all required optimizations and final checks. If it
cannot, this direct-first design cannot support a10× cold-build forecast. If it
does, the remaining bottlenecks dictate the next representation/runtime change;
frontend and machine construction must then receive their own controlled gates.
Do not relax output, stack-safety or checking contracts to make the target fit.

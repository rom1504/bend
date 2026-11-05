# Phase166 — execution overhead, complete consumers, and backend work

The same compiler-derived computation is **3.46× slower under our QBE than
bendc C**, and 2.29× slower under mature C. This is a bounded lookup/complete-result
workload, not self-compilation. Its profiles and a source-level counterfactual
separate two promising responsibilities: ownership/lifetimes around lookup results,
and QBE's out-of-line construction/destruction boundaries. Neither result supports
a 100× missing equality primitive or a five-second full-build prediction.

The production compiler and installed selection are unchanged. Phase152 remains
qualified. [Metrics and receipt index](metrics.json),
[design](../../design/phase166/README.md),
[machine inspection](../../experiments/phase166/code-shapes.md), and
[independent audit](../../experiments/phase166/independent-hypotheses.md).

## Same computation, three execution paths

The 15,408-byte source extracts the maintained lookup/hash/equality algorithms,
reuses Phase163's complete-record fixtures and consumer, varies record IDs, and
processes 18 complete results per round. Cases include duplicate names, misses,
Unicode, empty names, legacy inputs and a real hash collision. All three products
use identical source bytes and the same pinned Base. Source SHA256:
`4627d3b8c7b8291277574a1fc68bdf6afc972be1e32f8d1d8620c62eb4bdf181`.

Before publishing timings, complete actual and expected records at three inputs
each were compared with independently specified literal values: 108 KDef records,
including every field. Four small digest controls also pass. Native runs require
the independent complete stdout `3279346725\n`, empty stderr and exit zero.
Native digests are finite output controls, not injective equivalence proofs.
The expected-builder raw control was added after its native screening runs; it
passed before conclusions. There is no claim that every gate preceded every run.

| 10,000 rounds, whole process | Our QBE | Our mature C | bendc C |
|---|---:|---:|---:|
| Four balanced-order runs, median | 0.54148 s | 0.35772 s | 0.15649 s |
| Min–max | 0.53956–0.54305 | 0.35497–0.35933 | 0.15550–0.15691 |
| Separate profiler clean lane, three runs | 0.53691 s | 0.35664 s | 0.15436 s |
| Clean peak RSS median | 9,560 KiB | 9,540 KiB | 29,476 KiB |

The shorter 1,000-round point passed correctness but was rejected for comparative
timing because bendc finished in 19 ms, below the declared 30 ms floor. Scaling
changed only `1000` to `10000`. No favorable timing was selected from failed runs.

Our outputs come from the retained, checked Phase152 API, through its complete
QBE and C backends. This is not execution of the native compiler image itself.
QBE uses the pinned runtime/machine recipe; mature C uses Clang `-O3`; bendc uses
its pinned `-O2` recipe and the already qualified bounded-search runtime patch.
Default bendc unboxing stays enabled. Environment is explicitly
`BEND_RC=0 BEND_NO_FREE=1 BEND_AUTO_PAR=0 BANGS=0`, one worker, GPU off.
The runtimes differ intentionally; this is not a same-runtime instruction-selector
ablation. Their memory/lifetime tradeoff is part of the observation.

## What the actual native profiles say

Reused the general all-thread profiler, with 40 captures per binary alternating
8 ms/13 ms periods. All 120 independent output gates pass. Pooling admits every
capture: 2,144 QBE, 1,407 C and 585 bendc physical samples, zero unknown leaves,
zero rejected captures, and adequate CPU coverage/sample counts for each pool.
Individual short captures are insufficient alone. No instrumentation timings are
used as speedups. [Complete profiling summary](evidence/lookup-profile-summary02.md).

| Physical responsibility | QBE share | Interpretation |
|---|---:|---|
| `p125_rt_ctor1/ctor2/take1/take2` | **46.73%** | Actual constructor/destructor helper execution |
| Complete-record scanner body | 13.62% | Excludes helper leaves above |
| Borrowed equality reader | 5.57% | Character/header work, not heap allocation |
| `rfc_wrap` | 5.51% | Ownership machinery |
| `term_drop` | 4.04% | Reclamation |
| `heap_alloc` | 3.80% | Allocation |

The C scanner is 43.91% of its own CPU; `term_drop`, `rfc_wrap` and `span_fade`
together are 38.97%. Bendc's scanner is 61.64%; GC refill/mark/collection are
substantial but smaller. Percentages from different executables are not additive
or interchangeable absolute costs.

Machine inspection explains why function boundaries matter. QBE's scanner has
91 static constructor-helper call sites, 19 take sites and 15 scalar-mix calls,
with a 2,632-byte stack subtraction. C inlines allocation fast paths but retains
ownership slow paths; its frame subtraction is 120 bytes. Bendc inlines allocation
fast paths with GC-refill slow paths and a 72-byte subtraction. Static call sites
are not dynamic call counts, stack reservation is not traffic, and eliminating
a helper call does not eliminate its necessary memory work.

## A control prevents blaming everything on lookup

The full consumer builds traversal work lists and can itself dominate. A second
checked source supplies the independently specified expected records directly,
retaining the changing IDs, complete scanner, digest and loop count.

| Four-run median | Full lookup + consumer | Expected records + same consumer | Control / full |
|---|---:|---:|---:|
| QBE | 0.54148 s | 0.28461 s | 0.526 |
| Mature C | 0.35772 s | 0.12483 s | 0.349 |
| bendc C | 0.15649 s | 0.11678 s | 0.746 |

Two discriminating results:

1. QBE remains **2.44× bendc** with the lookup producer removed. Constructor/take
   boundaries and intermediate traversal state deserve a direct experiment.
2. Mature C becomes **1.07× bendc** in that control, versus 2.29× in the full
   workload. The lookup/index producer and the lifetimes/sharing it gives returned
   values are important; the scanner algorithm alone is not a sufficient explanation.

This replaces index/fixture construction as well as lookup. Reachability,
inlining and sharing change, so subtracting the times would not give exclusive
lookup duration. The books are tiny, names are constant and child lists are
empty; this does not qualify deep maps or arbitrary compiler ownership behavior.
The next consumer should be an actual hot compiler field/term use, with the full
record oracle retained separately, rather than this intentionally exhaustive digest.

## Backend census: useful evidence and a false lead avoided

The retained checked hosted API emits C and QBE from one unchanged checked
`NR_Request`. Observers count named entries, explicit nonempty-row visits and
literal tagged-object construction sites. No wrapper forces a deferred `$JMP`.
Exact inverse edits recover the original API bytes. All three observed replays
match both complete historical products byte-for-byte, and ordered stage gates pass.

| Source being compiled | C tagged-object events | QBE tagged-object events | QBE private candidate rows / boxed / flat calls | QBE verifier statement visits |
|---|---:|---:|---:|---:|
| Map | 29,832,738 | 37,558,377 | 72 / 54 / 20 | 14,848 original; 1,540 compact |
| Compiler verifier slice | 53,408,473 | 69,936,725 | 108 / 94 / 26 | 29,061 original; 4,779 compact |

These are hosted construction events, **not native allocation counts**, physical
JS allocations, retained objects or bytes. The verifier input compiles real verifier
code, but its existing execution control verifies an empty program. Stage clocks
include instrumentation, descendants, continuations and GC; first-entry intervals
are chronological partitions, not exclusive function timings. Existing clean
Phase165 backend screens remain the speed reference.

The Map producer follow-up attributes every one of QBE's **19.27M Tuple events**
to `Char.cmp`/`String.cmp` and its preservation helpers. This looked promising until
native inspection showed the relevant optimization already exists:

- Native borrowed `String.cmp` returns scalar ordering without per-character tuples
  or string reconstruction. Borrowed `String.eq/order` and composed consumers call it.
- The ordinary comparison wrapper makes two tuples per call; actual fallback use
  has not been counted. Hosted millions are not millions of native tuples.
- C's 14.41M Map `WCon` events mostly come from hosted `u32_to_word`, another warning
  against transferring a JS representation census directly to native allocation.
- Prepared-body reuse is working: 76 compact-definition queries in Map private
  production cause **zero recorded `nc_compact` entries**. Another generic cache
  would repeat machinery already present.
- Verifier fact getters already use indexed/hash tries. They are not whole-table
  linear scans. A few local repeated fact queries remain, with a much smaller ceiling.

The larger verifier-source producer repeat was not run: the Map result plus
native audit already falsified the large native tuple-removal inference. The
earlier 2.132B native allocation residual remains unpartitioned by this census.
[Method and exact source references](../../experiments/phase166/backend-census.md).

## Best next experiments

Ordered by evidence and information value, not promised whole-build speedups:

1. **Inline the proven unique-cell constructor/take fast path in QBE, retaining
   exact shared/error fallbacks.** First use the expected-record control and one
   unrelated compiler traversal. The measured 46.73% helper envelope is large;
   halving it would be an illustrative 23.4% reduction in this kernel, not a
   prediction—memory work remains. Inspect actual calls/spills, require complete
   output/ownership gates, and measure compilation/code-size cost before widening.
2. **Preserve a borrowed lookup result through a real compiler consumer.** Compare
   immediate field/term use with the current owned-result boundary, retaining book
   lifetime and alias controls. The expected-record counterfactual makes this more
   compelling than changing equality again. A bounded producer/consumer plan may
   remove retain/reconstruct/drop operations together; no new general IR is needed
   to test it. Measure sharing and allocation events, not just static calls.
3. **Attribute native backend work to candidate fate and retained representations.**
   Distinguish useful final bodies, necessary fallbacks and constructed/discarded
   candidates. Keep the independent verifier. Prepared-body caching and a new
   equality reader are weak priorities given the negative evidence. Reuse the
   current stage profiler; preserve call/row/native-event units separately.

A more ambitious request/phase-scoped allocation strategy could reduce ownership
work, but the bendc comparison also shows a higher memory footprint. It needs a
bounded-memory lifetime experiment and exact shared-root semantics first. Simply
turning off reclamation is not an optimization proposal.

No full-build gain estimate follows from these kernels. Existing whole-compiler
sampling puts equality at about 5.2% and all scalar borrow guards at about 1.3%.
The much larger ownership/construction/reclamation category remains the relevant
architectural target. Achieving five seconds still requires reducing total semantic
and machine-construction work as well as executing the remaining work faster.

## Cost, retention and reproducibility

Eleven guarded jobs used **235.08 seconds (3.92 minutes)** in total, including
builds, diagnostic capture/analysis and output checks. There were no full compiler
acquisitions, self-hosting campaigns, production changes or new backend. One small
checked API was acquired for fixture controls. The 156 native executions all pass
their independent outputs. Research, source preparation and agent effort are
outside the guarded-job total; token/quota cost is not measured by these receipts.

One controlled CPU3 execution lane, bounded RSS/deadlines/disk and the unchanged
5 GiB reserve were used. Disk initially blocked admission. Authenticated archival
verification reclaimed only the old, unselected Phase149 `native01/program.ssa`
(115.3 MiB), keeping its executable and other siblings. Recovery plan:
`selfhost/build-retention/phase166/reclaim01-verified/plan.json`;
use `archive-v02.py restore --plan ... --out FRESH` to restore it. All eleven new
runs are closed and archived/verified; their current products remain online.

Reproduction entry points:

- [Lookup fixture/control/build method](../../experiments/phase166/lookup-method.md),
  `lookup-plan-v2.py --rounds 10000` and `lookup-run.py` inside the disk guard.
- `lookup-plan-v3.py --role expected-records --rounds 10000` for the counterfactual;
  `check-expected.mjs` independently checks its complete record builder.
- `prepare.py` / `prepare-v2.py` produce the exact backend observation overlays and
  guarded job plans; the producer repeat is needed only for Map.
- The maintained `profiler/freeze.py`, `run.py`, `compare.py` and `render.py`, with
  `lookup-profile.py` setting the pinned runtime environment. Exact recipe,
  manifest and guard commands remain under `selfhost/build/phase166` and receipts.
- [Collector](../../experiments/phase166/collect.py) reproduces the committed
  receipt summaries from completed local runs. Full machine/profile artifacts are
  in verified local retention capsules, not duplicated into compiler source.

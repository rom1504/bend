# Phase37: broader program coverage and guarded backend improvements

Phase37 expands the generated-program benchmark from **15 to 45 points** before
changing the compiler. The added workloads expose important gaps hidden by the
old selection. The selected checked03 candidate adds finite selectors inside
proved private computations and removes generic dispatch for the exact native
F32-to-U32 conversion. It retains ordinary tagged data and generic fallback.

**Phase37 checked03 is installed and verified.** All 42 ordinary/relocated CLI
checks, all 15 post-install audit groups and 227 canonical source identities
pass. Inherited and new optimizer owners close separately on the same API.
The [release record](release-03.md) binds the installed artifacts; the
[admission decision](performance-admission.md) explicitly accepts the measured
regressions, compiler costs and source increase alongside the targeted gains.

The [phase design](../../design/phase37/README.md),
[coverage design](../../design/phase37/coverage.md) and
[reproduction guide](../../selfhost/tools/performance/phase37/README.md) record
the selection and workflow. No upstream pin changed: the TypeScript reference
is `018751270e800bc222a93dad7f257083ee53a5f7`.

## What coverage now means

| Frozen group | Points | Purpose |
| --- | ---: | --- |
| Unchanged historical catalog | 15 | Comparable previous workloads and boundary diagnostics |
| Additional algorithm/input variants | 14 | Scale, seeds, Mandelbrot grid positions and active-ray work |
| New development applications | 10 | Closures, list pipelines, Unicode, map churn and F32 recurrence |
| New held-out applications | 6 | BSTs, expression evaluation and record aggregation |
| Total | **45** | **23 distinct compiled source files** |

The 23 files comprise 13 historical sources, two additional wrappers and eight
new application families. Points, concrete source files and independent
algorithms are different counts. The original fifteen-point catalog remains
byte-identical. Holdout families were fixed before optimization; their untimed
correctness checks do not supply performance evidence for tuning.

The [coverage findings](coverage-findings.md) contain the full reference tables
and oracle limitations. Both reference compilers check all 23 sources. The
initial correctness gate passes 154 observations: 45 catalog points plus 32
small application controls, each executed by Phase36 and TypeScript. A fresh
gate repeats all **154 observations successfully for checked03 and TypeScript**.
These are selected program observations, not a full-language conformance count.

Broader coverage immediately mattered. The new active-ray points measured
74.45–85.39× Phase36/TypeScript ratios, versus roughly 23× for the historical
whole-image workload. Those are different workloads, not a before/after
regression. The new map workloads showed 92.69–100.68× gaps. Numeric recurrence
exposed generic native conversion inside an otherwise optimized loop, providing
a small testable optimization target.

Coverage remains deliberately incomplete. Most families have only two modest
points; many outputs are digests. The list generator's low four bits repeat
every sixteen elements: its two selected lengths cover complete cycles, so
changing seeds changes order but not the value distribution or final sum.
IO/FFI, native/GPU execution and large memory-resident applications are outside
this execution suite. These workloads are not a population-weighted estimate
of typical Bend program speed.

## Findings and retained changes

1. **Measure a mechanism before changing the compiler.** The
   [tree experiments](optimizer/tree-findings.md) compare controlled variants
   of one saved output. Finite tree and leaf selection together improved those
   experimental tree points by about 1.32–1.33×. A complete direct recursive
   component was faster, but requires a separate recursion/continuation proof
   and was not implemented in this compiler.
2. **Reuse the exact native semantics.** The
   [cast experiment](optimizer/native-cast-prototype.md) found an avoidable
   public call to `F32.to_u32` in every private recurrence iteration. The final
   effective public conversion and private call now share one runtime helper,
   under the existing exact signature and dependency proof. Saved-output gains
   are mechanism evidence; final checked-compiler gains belong in the execution
   report, not in the prototype table.
3. **A cheap operation can lose behind an expensive proof boundary.** The first
   checked candidate made the active-ray screen 35.6% slower. Counters found
   **1,968 extra successful tiny proof scopes**, each paying complete guards.
   The [ray attribution](optimizer/ray-regression.md) preserves that rejected
   result. Checked03 requires a finite selector touching non-scalar data before
   opening a new root; scalar selectors remain usable within an existing proof.
   The fresh short ray screen returned to overlapping baseline/candidate ranges.
4. **Numerical equality alone misses host-observable behavior.** The initial
   native-cast prototype had eighteen failing DataView mutation observations,
   including lost callbacks despite equal scalar results. The retained guard
   checks the shared view, its method slots and the captured prototype methods.
   All twenty-two adversarial observations pass on fresh checked03 output.

The finite route reuses the existing typed `Lam`/`Mat` prefix, whole-graph
`JPure` validation, materialization proof and scalar entry guards. It adds no
new optimizer IR or data representation. Only the outer scope owns forcing;
the existing trampoline and `finally` cleanup preserve deep tail cycles and
errors. Public, partial, mutated and otherwise unproved entries remain generic.
The [independent finite review](optimizer/finite-review.md) and
[final scope review](optimizer/checked03-scope-review.md) detail these obligations.

## Completed actual-output controls

The [final new-owner report](optimizer/final-scope-owner-report.md) closes three
new groups against the same selected checked03 API. Counts have different
meanings and must not be summed into a language-conformance denominator.

| Owner | Completed result |
| --- | --- |
| Exact native cast | 44 oracle rows, 57 boundaries, seven admission records; pass |
| Shared DataView guard | 22 prototype/instance observations; pass |
| Finite selectors | 154 oracle rows, nine admission records, 76 boundaries; pass |

Finite diagnostics observe all five intended selectors. Both 30,000-step
self/mutual tail cycles enter one outer proof scope and a terminal selector,
then leave no active proof. Complete tree observations preserve aliases.
Final owner closure verifies **710 file identities and 15 pinned Git blobs**.
The [closure protocol](optimizer/new-owner-closure.md) records its identity
checks and the preserved first audit failure. Fixture/parser failures, rejected
controls and earlier candidates remain in the
[attempt history](optimizer/attempts.md); they are not successful runs.

The selected API SHA256 is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
This is a checked B1 derivative, not evidence of a self-emitted fixed point.

## Final execution results

All four final groups are complete: **45 points, 669 samples and 1,056.320
seconds** of separate-run wall time (about 17.61 minutes). Their counts are
historical 15/219, variation 14/210, development 10/150 and holdout 6/90
points/samples. This is workflow time including startup, warmup and calibration,
not a program-runtime denominator or a single-preset duration promise.

The final historical run covers all fifteen unchanged points in 385.774 seconds
with 219 samples. Ordinary points have five paired rounds; the existing costly
ray policy retains three. The following subset highlights results discussed in
the [tree findings](optimizer/tree-findings.md). Times are median milliseconds
per completed program call, not compilation or acquisition times.

| Historical point | Phase36 ms | Checked03 ms | Phase36 / checked03 | Checked03 / TS |
| --- | ---: | ---: | ---: | ---: |
| Tree depth 8 / seed 0 | 19.5728 | 16.0265 | **1.221×** | 57.12× |
| Whole-image raytrace | 717.9430 | 693.1939 | 1.036× | 20.20× |
| Scalar region 8192 | 0.154784 | 0.139629 | 1.109× | 1.40× |
| Complete generic row32 | 0.402784 | 0.430625 | 0.935× | 58.11× |

The tree improvement has disjoint sample ranges and improves every paired
round. Historical ray ranges overlap slightly; scalar-region ranges overlap
substantially. Generic row32's ratio of medians is 6.91% slower, but ranges
overlap and the median paired ratio is 0.9925; this does not establish a
consistent seven-percent regression. Most other historical points are within
about 2%. The remaining TypeScript gaps are large and workload-dependent.

The [held-out application findings](holdout-findings.md) retain all six points'
ranges, paired observations and within-block drift. The selected compiler is
151.69–209.31× slower than TypeScript on BST, 41.64–42.70× on expression evaluation
and 59.87–71.69× on record aggregation. Although all baseline/candidate ranges
overlap, BST 64, expression 128 and record aggregation 64 slow in all five paired
rounds; their median paired penalties are 3.85%, 3.00% and 3.44%. Record 256's
near-unchanged median conceals two large slower rounds. These costs remain part
of the admission decision. No optimizer change followed holdout timing.

The [full execution report](execution/report.md) collects all 45 points without
pooling ratios into a claim about typical programs. It supersedes preliminary
screens while retaining their results and drift limitations. Final numeric
recurrence improves **2.674× at 256 steps and 5.165× at 1024 steps**; tree gains
across three sizes are **1.165–1.270×**, with disjoint ranges and every paired
round improving. Numeric remains 7.382×/3.338× slower than TypeScript; tree
remains 57.117–64.794× slower.

The larger list and active-ray points regress **4.65% and 3.58%**, with disjoint
ranges and every paired round slower. Historical symreg and the smaller lexer
variant also have disjoint slower ranges, by 1.63% and 1.78%. The
[admission decision](performance-admission.md) retains these costs. Static
inspection finds the six list benchmark-reachable generated globals unchanged;
it does not establish a cause for the list slowdown. The extra DataView checks
are required correctness guards, but their isolated final cost is unmeasured.

The [compiler-cost report](compiler-cost.md) separately records **+2.47% local
row, +6.40% tree and +1.06% numeric** request medians. The first two increases
have disjoint three-sample ranges. All 27 requests produce the exact expected
checked bytes. This phase does not improve compiler throughput or source size.
Reference source acquisition totals
of 113.975 seconds for Phase36 and 17.378 seconds for TypeScript include process
startup, import, checks and emission; they are not generated-program execution
times or pure compiler-throughput estimates.

## Production size and complexity

The [frozen source-size comparison](source-size-final.json) counts only ordered
compiler modules for Bend source, with generated runtime/API reported separately.

| Metric | Phase36 | Checked03 | Change |
| --- | ---: | ---: | ---: |
| Physical Bend lines | 18,174 | 18,358 | +184 (+1.01%) |
| Nonblank Bend lines | 15,545 | 15,709 | +164 |
| Compiler modules | 69 | 70 | +1 |
| Definitions | 2,024 | 2,045 | +21 |
| Types / laws | 71 / 640 | 71 / 640 | Unchanged |
| Assembled runtime bytes | 52,694 | 53,346 | +652 |
| Generated API bytes | 1,164,781 | 1,181,753 | +16,972 |

This is a small source increase, not a simplification result. The new finite
module has 166 physical lines and nineteen helpers; existing proofs and storage
are reused, but readiness checks and duplicated generic branches still carry
compiler and output costs. Line counts do not measure conceptual complexity.
The 23 benchmark sources and 45 execution points are coverage counts, distinct
from the 70 production compiler modules.

## Separate final diagnostics

All **24 CPU/allocation captures** pass on the exact numeric, list, tree and
active-ray modules from the clean final timing runs, in **34.345 seconds** total.
The [profile findings](profile-findings.md) include static generated-JavaScript
comparisons and raw V8 evidence. These diagnostic durations are excluded from
the runtime ratios. Reserved application families were not profiled for tuning.

## Integration and preservation

The [integration protocol](../../selfhost/tools/performance/phase37/final-integration-README.md)
is complete: 38 pre-installation steps, all fifteen Phase35 owner groups,
all seven Phase36 groups rebound to this actual API, canonical-source audit,
performance and compilation-cost admission, installation and CLI closure.
The three new owners supplement those gates. Fresh frontend observations agree
exactly on 3,026 main + 196 broader rows. Backend outcomes remain 69 pass / eight
not applicable / four shared failures. The [final gate table](final-conformance/gates.md)
and [inherited-audit repair](inherited-owner-audit-repair.md) preserve both the
successful closure and the original path-resolution failure. No full backend,
GPU, independent kernel or new fixed-point claim follows.

The tracked Markdown reports and compact tables are readable directly on
GitHub. Their raw links under `selfhost/build/phase37` refer to generated
receipts, modules, profiles and timing samples. Those paths are restored from
the phase evidence capsule; they are not all ordinary tracked Git files.
The [evidence guide](evidence/README.md) records capsule identity, restoration
and verification commands. Failed and
rejected attempts are retained alongside accepted evidence, with separate
producer and artifact identities.

The [resource summary](resource-summary.json) records 1,577 successful and ten
failed supervised receipts, with **zero resource stops and zero unfinished
receipts**. Nested receipts overlap; these counts are not distinct tests.
Peak measured process-tree RSS is 1,142,190,080 bytes, below the 2 GiB ceiling.
Every successful receipt stays within its RSS budget and above its free-memory
floor. Archive supervision is recorded separately. All **103 unrelated starting
files remain unchanged and unstaged**, verified by the
[protected-file check](protected-files-final.json). No PR comment was posted.

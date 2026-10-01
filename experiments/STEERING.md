# Phase38 research frontier; Phase37 compiler installed

User authorization covers compiler experiments, design/report and commit/push to
`rom1504/bend`, branch `selfhost/bootstrap`. No PR comments without an explicit
request. Older timed campaigns are historical. Preserve the 103 unrelated
starting files and closed Phase35/36 evidence.

## Research decision, 2026-10-01

The [Phase38 collection](../design/phase38/README.md) completes the requested
compiler research without implementing new optimizations. Twelve studies cover
the pinned TS backend, MLton, GHC, Flambda, Lean, Koka, Chez, JS engines, Zig,
Rust/Cranelift, fusion and validation. [Ranked ideas](../design/phase38/ideas.md)
separate observed evidence from conditional gains and correctness risks.

Prioritize a small private Number-counter probe, a ray guard-scope probe and
one direct tagged recursive component. Known callback specialization precedes
fusion. Share analysis facts only after two examples justify the abstraction;
defer a general optimizer/RC/runtime rewrite. Numeric already has one outer
guard, so scope amortization is not its established opportunity. All proposals
remain unexecuted. See the [prospective queue](../design/phase38/experiments.md)
and [research report](../implementation/phase38/README.md). Phase37 metrics below
are unchanged, and its formerly heldout families are now exposed.

## Installed result

**Phase37 checked03 is installed and verified.** All 42 ordinary/relocated CLI
checks and all 15 post-install audit groups pass; 227 canonical files match.
Fifteen inherited Phase35, seven Phase36 and three new Phase37 owner groups
close separately on API
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`. This is a checked B1
derivative, not a new self-emitted fixed point. Phase36 remains in release history.

[Report](../implementation/phase37/README.md) ·
[Release](../implementation/phase37/release-03.md) ·
[Admission](../implementation/phase37/performance-admission.md) ·
[Profiles](../implementation/phase37/profile-findings.md)

Finite selectors reuse typed matching, existing purity proofs and tagged values.
Direct F32-to-U32 conversion shares the effective public native body inside a
proved private region. DataView guards preserve callbacks, leaked instances and
host mutation. Scalar-only selectors cannot justify another proof scope; the
first broad version regressed active ray by 35.6% and is rejected.

## Measurements and costs

Coverage expands from 15 to 45 points across 23 sources, including eight new
families and three families held out while selecting this compiler. All 669
final samples pass their output expectations. Four bounded runs take 1,056.320
seconds total (17.61 minutes); this is not an inner-loop requirement.

Versus fresh same-run Phase36, numeric recurrence is **2.674×/5.165× faster** and
three tree sizes are **1.165–1.270× faster**, with disjoint ranges and every pair
improving. Remaining TS gaps are 3.338–7.382× numeric and 57.117–64.794× tree.
Four points have disjoint slower ranges: symreg +1.63%, smaller lexer +1.78%,
active ray 256 +3.58%, list 512 +4.65%. Several heldout points also slow in every
paired round despite overlapping ranges; record 256 has two large slow rounds.
No average across fixed inputs, overall gain or typical-program claim follows.

Checked-request medians rise 2.47% local row, 6.40% tree and 1.06% numeric;
local/tree ranges are disjoint. Source grows 184 physical Bend lines (+1.01%)
to 18,358 lines / 70 modules / 2,045 definitions; 71 types/640 laws stay unchanged.
This phase improves selected execution paths, not compiler throughput or simplicity.
Final allocation profiles estimate numeric -71% and tree -31%; list/ray allocation
is roughly unchanged. Profiles do not explain every small timing regression.

## Next investigations

1. Isolate unused finite branches/module layout and repeated guards before
   adding more proof boundaries. List benchmark-reachable bodies are unchanged;
   its slowdown is measured but not causally explained.
2. Ablate one saturated dispatch/matching component in map churn or lexer.
   Current gaps remain 91–106× and 81–91× TS. Use counters and complete oracles.
3. Revisit a reusable private recursive tree component only after a second
   independent shape validates the saved-output mechanism. BST gaps 152–209× TS
   expose headroom, not a forecast of achievable gain.
4. Consolidate workers/representations only when two component experiments
   establish the same missing abstraction. Measure compiler and emitted-size cost.

See [next opportunities](../implementation/phase37/next-opportunities.md).
Previously heldout BST/expression/record families are now exposed; preserve them
as regression tests and reserve new holdouts for the next optimization phase.
Add non-cycle list lengths/selectivity in a new catalog; keep old points unchanged.
No further optimization is part of the now-frozen Phase37 candidate.

## Iteration and correctness

Use the explicit [Phase37 catalog](../selfhost/tools/performance/phase37/README.md),
portable Phase36/TS reference, and 20/60/300/600-second ceilings with selected IDs.
Build/acquisition are separate; checked03 plus 36 focused probes took 42.175 seconds.
Root runs heavy jobs serially on CPU3, heap<=1 GiB, process tree<=2 GiB, with 2 GiB
available memory. Agents author and inspect; preserve failed attempts.

Frontend matches 3,026 main + 196 broader retained observations. Main verdicts remain
2,525 pass / 497 observed / 4 shared failures; backend 81 remains 69 pass / 8 N/A / 4 shared
failures. No full backend/GPU or independent proof-kernel claim. The inherited
owner audit path error and its reviewed successor both remain evidence.
The [capsule](../implementation/phase37/evidence/README.md) closes raw writers and
verifies archived bytes independently before publication.

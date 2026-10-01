# Next opportunities after Phase37

Start with one small generated-code ablation on a measured hot component. The
expanded catalog exposes large remaining gaps, but does not justify a general
rewrite before the mechanism is isolated. Keep the mandatory host correctness
checks and the new rule that tiny scalar selectors cannot purchase new scopes.

## What the evidence establishes

The [final execution report](execution/report.md) contains 45 points from 23
source files, 669 samples and four separately paired runs. The final candidate
improves tree sorting by **1.165–1.270×** and the rounded numeric recurrence by
**2.674–5.165×**. The tree result is a compiler change; the larger **2.60–3.56×**
complete-tree-component result remains a handwritten saved-output experiment.
Do not treat it as achieved production speed or a forecast for another program.

The strongest lesson is to remove repeated generic work at an existing useful
boundary. Direct native conversion worked. Replacing finite tree selection
worked. Opening thousands of scopes around tiny scalar operations failed:
1,968 extra host checks per active-ray call outweighed the saved dispatch. The
profitability restriction removes that large failure, but final active ray at
256 pixels remains **3.58% slower**, with disjoint ranges. The DataView correctness
fix is a plausible contributor; its final minimal form has not been isolated
from generated-code changes.

Preserve other costs too: list-512 is about 4.65% slower with disjoint ranges;
some heldout BST/expression/record points are consistently slower within paired
rounds despite overlapping overall ranges. The
[holdout report](holdout-findings.md) records those directions. Small aggregate
medians cannot turn these into a universal improvement claim.

## Prioritized investigations

| Target | Evidence and remaining gap | Small next experiment | Status of expected gain |
| --- | --- | --- | --- |
| Avoid useless guards/branches | Active ray retains thousands of unscoped checks; generic row has two finite branches but no possible local proof scope | Count actual scopes and guards, then separately disable only inactive selector branches in saved output; compare with unchanged baseline and correctness-preserving candidate | Possible small recovery; no demonstrated gain for the final source version |
| Map churn, then lexer | Map remains about 91–106× slower than TypeScript; lexer about 81–91×. Phase36 map profiles attribute 26.8% self CPU to a generated function wrapper and estimate 105.9 MB allocation/call versus 2.19 MB for TypeScript | Compare one hot `Map.bit.go`/caller path or one lexer step with the TypeScript output; replace only saturated dispatch/matching in saved JS, then measure complete original outputs | Large headroom, but no validated speed estimate; profile samples are allocation estimates, not retained heap |
| Reusable private tree-to-tree component | Saved tree component beats finite-only selection substantially; BST remains about 152–209× slower | Retest a small complete recursive component against the final compiler, preserving left/right demand, sharing and tail behavior; then test a separate shape before designing reusable emission | Demonstrated only for the original tree prototype; transfer to BST is unproved |
| Typed representation and worker consolidation | Generic tagged values, curried descriptors and forcing recur across tree/list/map/lexer paths | Identify a common typed carrier and call transition in two winning ablations; reuse original Lam/Mat and existing frame machinery | Architectural candidate, not an implementation commitment or parity prediction |

For maps, first determine whether the hot cost is bit/word traversal, tagged map
nodes or wrapper traffic; the current profile does not make them interchangeable.
For lexer, inspect both generated modules at the same source definition and use
actual counters before moving a boundary. For BST, preserve the fueled zipper,
skewed input and child identities; a direct balanced-tree loop is not evidence
for arbitrary insert/rebuild behavior. Purity alone does not justify moving
demand or bypassing callbacks.

Do not begin with a new optimizer IR, global cache or a collection of named
benchmark exceptions. A larger refactor earns its cost when at least two
independent component experiments demonstrate the same missing abstraction.
Include normal checked compilation time, emitted bytes and source/concept count
in that decision; faster programs can otherwise make the compiler iteration
loop slower.

## Fast iteration sequence

1. Freeze the final checked baseline, catalog, exact inputs and one falsifiable
   hypothesis. Choose one development point plus a refusal/control point. Read
   the existing CPU/allocation and syntax comparison first.
2. Derive counter-free saved-JS variants: unchanged, boundary-only and the one
   proposed mechanism. Separately instrument actual entry/guard counts and
   complete-value/alias/error controls. A zero-entry speed result is not evidence
   for the intended optimization.
3. Use a **20-second execution ceiling** to reject weak candidates on selected
   IDs. Use **60 seconds** for a second input and an unrelated canary. Preserve
   original input sizes; do not shrink work or drop failed rounds to fit.
4. Only after a clear win, implement the smallest general rule, build one checked
   compiler and acquire each relevant source once. The checked build and emission
   are outside execution ceilings; reuse the resulting modules for subsequent
   screens. Run source-derived semantic controls before timing them.
5. Use **300-second selections** for development families and five paired rounds;
   use **600-second selections** for historical/varied slow cases. Inspect
   ranges, same-round direction, first calls and half-drift. These budgets do not
   themselves guarantee steady state. Profile in a separate bounded run.
6. Freeze the candidate, evaluate a newly reserved application family, then run
   the compiler-cost and release gates. Phase37's full execution inventory took
   about **17.61 minutes across four runs**, so it is an acceptance step rather
   than the inner edit loop.

Use the maintained [Phase37 loop](../../selfhost/tools/performance/phase37/README.md)
with explicit `--catalog` and `--cases`. Retain the same-run Phase36/TypeScript
roles, exact checked receipts and fresh output directories. Resource-heavy jobs
remain serial with the recorded CPU/heap/RSS limits.

## Coverage limits for the next phase

The catalog is a purposeful mechanism sample, not a population-weighted sample
of real Bend programs. Two files are new wrappers over historical algorithms;
23 files do not mean 23 independent applications. Most new families have only
two small points, often changing size and seed together. Many outputs are
checksums; active F32 ray points use a TypeScript differential oracle. Neither
proves complete semantic equivalence.

The list generator's selected lengths contain whole 16-value cycles, so its
seeds rotate one distribution rather than vary selectivity. Add independently
selected non-cycle lengths and selectivity patterns in a new catalog version;
keep the old points unchanged. BST/expression/record performance was held out
while choosing Phase37, but using these results to choose the next optimization
exposes those families. Keep them as regression tests and reserve new holdouts.

Still missing are long-lived heap pressure, streaming and external IO/FFI,
large graphs and heterogeneous sharing, substantial partial/oversaturated-call
workloads, native/GPU/parallel performance, and the whole self-hosted compiler
application. Conformance and compiler-throughput measurements remain separate.
There is no supported date or universal multiplier for reaching TypeScript parity.

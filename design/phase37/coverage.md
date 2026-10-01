# Phase37: broaden execution coverage before optimizing

Status: prospective selection and protocol. Measurements belong in
`implementation/phase37/`; this document does not claim successful compilation
or benchmark results. The historical fifteen-point catalog stays byte-identical.

The existing catalog has thirteen source files and fifteen points, selected for
stable upstream checksums and inexpensive iteration. It is a useful development
set, but repeated tuning against it creates an overfitting risk. More seeds alone
cannot test different algorithms, long-lived state, higher-order calls or
different data shapes. This phase therefore adds both varied inputs and separate
program families before selecting the next compiler change.

## Three layers and a frozen split

1. **Historical regression layer:** the unchanged fifteen points, with their
   existing oracles, sources and 20/60/300/600-second protocols. Its existing
   portable Phase32 baseline remains available. Phase37 uses explicitly acquired
   Phase36 checked03 output when measuring incremental compiler changes.
2. **Varied-input layer:** additional sizes and seeds for edit distance, lexer,
   bitonic sorting and symbolic regression; spread-grid Mandelbrot samples and
   active ray-tracing pixels add computation distributions missing from the
   original narrow strip and mostly inactive column traversal. The new wrappers
   call the original functions; they are component workloads, not a replacement
   for the original complete algorithms.
3. **New-family layer:** higher-order closures, list pipelines, mutable maps,
   Unicode/string operations, numeric recurrence, binary search trees, expression
   interpretation and record aggregation. Each has a small and a larger or
   changed-seed point, with explicit workload accounting. These are purpose-built
   applications and existing upstream tests extended with wrappers, not a random
   sample of real production software.

Freeze source bytes, selected arguments, oracle method and split before looking
at candidate performance. Reserve complete BST, expression-interpreter and record
aggregation families as validation holdouts. Do not profile them to choose or
tune the optimization. Run them when a candidate is frozen; if a result motivates
another change, label that family as subsequently exposed. A holdout is evidence
of transfer, not proof of general performance. Seed and size variants of an
already tuned algorithm are transfer inputs, not independent program holdouts.

## Coverage dimensions

| Dimension | Existing limitation | Additional evidence |
|---|---|---|
| Scalar loops and finite branches | one long scalar canary | numeric recurrence and changed Mandelbrot distributions |
| Mutable arrays | mainly fixed 256×256 DP and one fold | seeded DP batches; mixed application state |
| Recursive algebraic data | balanced trees at one depth | changed depths/seeds; independent BST and expression families |
| Data shape | almost exclusively balanced or tiny | deterministic skewed/mixed BST inputs; varied record/list lengths |
| Higher-order values | little sustained use | dynamically selected closures and list transformations |
| Strings | generated short ASCII template | Unicode text construction, scanning and transformation |
| Maps | one to three entries in smoke tests | insertion, lookup and replacement at larger cardinalities |
| Allocation and reuse | short complete calls | larger list/tree/map/record computations and profile allocation |
| F32 computation | full ray dominated by inactive probes | active pixels at different image positions |
| Input variation | predominantly one size/seed | preselected two-point new families and algorithm variants |

Coverage remains sequential generated JavaScript. Native/parallel/GPU execution,
real network/filesystem IO, very large memory-resident services, all dependent
types and the full compiler application remain outside this suite. Conformance
gates and separate whole-compiler measurements retain their roles.

## Oracles and admission

Every timed point has an exact scalar/string expected result. Preserve existing
upstream goldens. New integer algorithms use separately written Python reference
calculations checked against the historical goldens where available. New-family
oracles record their own implementation and selected arguments. F32 ray points
use frozen checked output from the pinned TypeScript compiler as a differential
oracle, explicitly labeled weaker than an independent reference. The compiler
candidate must never define its own expected result.

Record the entire result of each application where practical, otherwise state
that the oracle is a checksum and can miss collisions. Equality of checksums is
not complete semantic conformance. Expanded-source checking failures and oracle
disagreements remain recorded; correct a fixture only with a new version and a
written reason, without silently deleting slow or failing workloads.

## Reuse the maintained loop

Use `programs/run.py` and `programs/diagnose.py` with an explicit additive
catalog. Add matching `--catalog` support to preparation and reference packaging;
default catalog behavior, source confinement and exact identity checks remain.
No second timing engine is necessary. Bind the catalog, source, emitted module,
checked compiler, Base/runtime and all preparation receipts before timing.

Keep 20/60-second selections small. The enlarged `full` catalog is an inventory,
not a promise that every point fits 600 seconds. Run named development,
variation and heldout selections in bounded chunks; report each chunk and every
unfinished point. Never reduce an input automatically to make a ceiling pass.
Build a new checked compiler once, acquire relevant modules once, screen a hot
case, then escalate to independent transfer and historical regression checks.

Profile CPU/allocation and compare generated syntax separately from clean timing.
Use whole-module and hot-component comparisons to identify repeated generic
dispatch, forcing, closures and temporary representation. A faster checksum is
insufficient for promotion: require owner/path-entry controls, public mutation
and refusal behavior, ordinary outputs, broader gates and explicit compile-time
and source-complexity accounting.

Root runs every compiler, execution, test, profile and archive job serially on
CPU3 under the shared execution guard, Node24.18, a 1GiB heap cap, a 2GiB process
tree RSS ceiling and a 2GiB free-memory floor. Agents prepare sources, controls,
analysis and documents without parallel heavy jobs. Failed and interrupted
attempts keep their original directories. Closed Phase35/36 evidence is immutable.

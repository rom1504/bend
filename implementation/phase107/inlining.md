# Phase107 bounded inlining

The new implementation under
[`inline/`](../../selfhost/tools/performance/phase107/inline/) adds a shared,
Bend-written optimization over the existing native IR. It does not edit the
production compiler or claim complete Bend-to-native lowering. The parent phase's
real source bridge can compose this pass between lowering and either backend.

The selected first boundary is small terminating pure scalar helpers, including
the lexical classifier shape seen in Phase106. Calls in a caller loop can expand;
callee loops, recursion, pointers and effects cannot. Every argument is evaluated
once into a fresh parameter local. Every callee local is reset on every invocation,
which is necessary inside caller loops. Terminal conditional returns become fresh
result assignments before the original caller continuation. Callee definitions
remain available and unsupported calls remain intact.

Code growth has a global explicit budget, bounded call graph/expansion depth and
per-callee limits. The JSON oracle counts actual AST nodes independently. It checks
that output growth stays within the requested capped budget; this measures AST
growth rather than promising a bound on emitted machine-code bytes. Refusal is
conservative: for example, early-return control flow with later statements is not
restructured speculatively.

The optional `nx_inline_deep` adds original-call-graph summaries while preserving
the common expansion engine. Shallow function facts are checked once; a gray DFS
path detects recursion and a completed-result cache reuses both positive and
negative results. Analysis is bounded to256 functions/dependency depth, separate
from four-level expansion and4096-node growth. This admits deep acyclic helper
chains without expanding them without limit. The original `nx_inline` policy is
retained as the comparison. The accepted bridge05 source snapshot predates this
extension, so the extended implementation needs its own checked acquisition.

Six finite semantic fixtures target argument snapshots, caller-name collisions,
nested conditional returns, merge-local conditionals, per-iteration local
initialization and nested calls. A seventh recursive fixture is compared
structurally and never executed. Existing
pointer-sharing workloads provide a refusal control. Expected outputs are frozen
independently; the Phase106 interpreter supplies a second execution model. Three
well-typed emitted-IR mutants test whether the oracle notices dropped local reset,
swapped parameter snapshots and discarded results.

Two small exact-result laws constrain the real safe continuation helper. They are
not a proof of inlining; freshness, traversal, termination admission and semantic
preservation remain explicit unproved boundaries. This limited contract can catch
the helper being wired to the wrong destination/result while broader finite
controls exercise the transformation.

The first integrated checked API acquisition passed in
[`bridge-check05/process.json`](../../selfhost/build/phase107/bridge-check05/process.json):
11 checked exports including `nx_inline`, 1.392s guarded wall and approximately
151MB peak tree RSS. This is source/API admission, not a whole-pass proof or a
performance measurement of optimized output. Earlier inference failures are
retained; explicit types on constructor-valued local bindings fixed them.

Root owns backend differential execution and timing. The58 frozen fixture rows,
negative controls and continuation laws are prepared; their execution status is
recorded separately in Phase107's main report as those receipts arrive.

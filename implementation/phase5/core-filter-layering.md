# P5-017 — one definition filter in the core layer

The compiler now uses `core/index.bend::index_remove` at all five former
`book_without` call sites. The duplicate law/body in `check/kernel.bend` is
removed. This repairs an actual layering problem: the standalone frontend's
definition finalizer previously depended on a helper hidden in the checker.
The two implementations are textually alpha-equivalent, including recursive
removal of every match, order, comparison demand and lazy branch selection.

The change removes 13 physical lines and introduces no public root. Neither
helper is among the maintained 54 bootstrap exports. Historical all-root
experiments remain attached to their frozen source; their old extraction scripts
are not rewritten to describe a new run.

## Validation status

The ordinary 22-module frontend component now compiles without an appended
checker helper or diagnostic modules. Its checked component API is
`bc712bc28e9ed1eaaa37d5dcd2b9eaab9e1dc22770224ec27480d2454c874c1a`.
Ordinary loading, traced loading and seeded traced loading produce exactly equal
results and completed-module order. All consumed component inputs remain
unchanged. The genuine combined normal bootstrap also completes as API
`8cfa124d7567…`.

The first component run completed functional checks but failed its final drift
check because another reviewed frontend source changed during the run. It is
retained as incomplete. A retry initially used an incorrect upstream directory
and did not compile. The successful third run reads the immutable integration-03
source snapshot. Its launcher uses file capture and checks actual spawn errors,
signals and status, avoiding the environment's ambiguous synchronous pipe error.

Static alpha-equivalence and independent review pass. The frozen checked Bend
compiler also emitted a four-module core library without a checker helper. The
unchanged Phase 4 definition-selection audit passes all 23 controls, comparing
legacy and fast results or errors for duplicate names, retained ordering,
boundary sizes, Unicode, malformed names and hash collisions. This is actual
Bend-emitted code, not a JavaScript reimplementation of the filter.

The [complete evidence archive](core-filter-evidence/manifest.json) includes the
failed attempts, exact source/tool histories, successful component and emitted
library, and raw definition-selection audit. The final combined inventory and
checked self-reproduction remain pending at this checkpoint. No performance
improvement is claimed for removing duplicate code.

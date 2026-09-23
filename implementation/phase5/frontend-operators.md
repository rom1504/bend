# P5-013 — reject unresolved operator namespaces

The promoted frontend refuses an unresolved single-dot operator reference at the
last `f_scope_ref` fallback. Quantity errors, local binders, known definitions and
ADT resolution retain their earlier decisions. Already resolved accepted terms
therefore avoid the added string checks. The error-only display helper translates
internal operator names to the source spelling; it does not reproduce upstream's
source snippet yet.

The final checked candidate is API `b8ad03e1dadc…`; the promoted
`front/families.bend` SHA-256 is
`b17a1dcf30d7ff7c7a0bc0d8e9df6d58f166ab19e3889c73b2403bb0b3b14fe4`.
Root and compact_index independently reviewed the placement. The original outer
guard and the final late guard remain separate retained variants.

## Observations

The expanded differential repairs 15 acceptance/phase observations: eight from
four pinned upstream fixtures and seven local counterexamples. The scoped final
selection has 28/28 semantic agreements, while four pinned strict check verdicts
still fail because their diagnostic text differs. The workflow's exit 1 is
retained; this is not 28 strict conformance passes.

Seven accepted programs produce exactly equal complete loader graphs before and
after the final change, including ordering and term metadata. Their validated
Base prefixes also agree. The earlier guard variant has 14 exact interpreter
and JavaScript observations. The final variant's execution claim is limited to
the recorded complete accepted-graph equivalence; that execution matrix was not
silently relabeled as another run.

The controls exposed two scope limits. First, `1n + 2n` was incorrectly accepted
by the existing Nat-prefix special case; this independent adjacency/precedence
bug is investigated in P5-018. Second, raw parsing can report a later syntax
error before the scope pass sees an earlier bare operator. Three controls retain
that diagnostic-order limitation. No exact operator diagnostic or timing gain
is claimed.

An initially presumed positive Nat shift using a U32 count also fails pinned
TypeScript. Its original fixture/selection and outcome remain; the corrected
positive uses a Nat count. Two launcher failures (relative fixture path and an
incorrect attempt directory) are recorded separately from compiler results.

## Evidence

The [complete archive](frontend-operators-evidence/manifest.json) preserves 2,939
historical file identities and 6,362,034 compressed bytes: both source overlays,
checked provenance, raw selected/execution/graph observations, review, promotion
identity and consumed fixtures/tools. A failed first archive could not recover a
superseded preparation file. Its manifest remains in
`frontend-operators-archive-attempt01`; the successful retry recovers the exact
recorded bytes by digest from immutable attempt snapshots. Recovery never changes
the historical identity or a test verdict.

# Exact static-preparation prefix checkpoints

This experimental Bend module skips work **before** `nc_compact` and
`p112s_term`. It does not rebase addresses or reuse a post-render product.
`p140sp_prepare(book,names,constructors,previous)` returns
`P140SPResult{prepared,cache,stats}`; `p140sp_empty()` starts a cold session.
The result's `prepared` field must exactly equal original `p112s_prepare`.

Candidate 15 passed checked API acquisition
(`selfhost/build/phase111/p140-native-api15/report.json`) and the 16 original
static controls (`selfhost/build/phase140/native-finite04/report.json`). The
four additional `controls-v02` cases are prepared but **not yet executed**.

Each checkpoint retains the exact after-owner `P112SDefs`: accumulated facts
and the full `P112SImage` size, nodes, interning index and error. Reuse requires
the same ordered constructor catalogue and exact effect-blocked constructor
map. It then walks names in order, checking the actual eligibility decision
and complete prepared fact. An active declaration is reusable only when its
fact is `NativeErasedBody` or `NativeStaticBody`; for those kinds,
`nc_definition` returns exactly `dv(fact)` without reading any other body.
All other cases execute the original fallback. The complete fact matters:
the producer also uses its arity/template fields and retains it as a child.

The first differing input disables all later reuse for that request, including
apparently unchanged later facts. Thus reused prefixes have the same incoming
image inductively, and the remaining suffix preserves original static identity,
interning order, capacity handling and first-error behavior. Final attachment
always calls original `p112s_attach` with the **current** book and constructors.
The original foreign and noncached-book branches remain. Errors retain the
previous cache, and the surrounding session still commits only after all gates
and output writes succeed.

Stats are `[prefixHits,freshSteps,bodyHits,bodySteps]`. A skipped inactive name
is a prefix hit but saves no compaction. Report `bodyHits` separately. The
constructor/effect catalogue, key comparison, final attachment, retention and
reclamation costs remain paid. Persistent intern-index versions share structure
but can increase memory; measure RSS rather than assuming constant space.

`owner/bridge-v04.bend` adds a distinct static cache to the raw-product state and
preserves version 3's constructor-catalogue carry. It appends the four counters
after the existing seven raw counters. No production declaration is overridden.

`controls-v02.bend` contains 20 controls comparing entire prepared books,
nodes, errors and exact counts against the original producer: cold/no-op,
first/middle/last edits, suffix interning, reverted edits, truncate/reorder,
inactive insertion and eligibility changes, constructor order/arity/hot flags,
missing facts, stale static inputs and error publication. The independent source
audit found no missing semantic input under the fixed-producer private-cache
premise. Real-request equivalence, native cost/memory measurements and the
remaining added controls must be reported separately before selecting it.

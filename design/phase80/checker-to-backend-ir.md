# Phase80: retain the checker's work

## Motivation and baseline

Phase78 is installed: checked B1 `475610ea…`, genuine B2 `cc99ac9b…`,
source `6758bf2`. Its paired fresh C-request ratios are 1.73205× and
1.38187× pinned TypeScript, respectively. This clock includes loading user
sources, checking and producing C; excludes compiler imports, explicit Bend
Base preparation, Clang and execution. Backend products are disabled. The
three measured sources are Numeric, Array.map and lexer; small and functions65
are separate held-outs. These numbers are not full-language throughput.

Phase79 rejected serialized native library workers. Saved annotation/erasure
work was substantially offset by decoding, allocation and context construction.
This experiment therefore changes the in-memory producer/consumer boundary.

The pinned upstream (`059266225b77c8ca256ac6b25ee5c21449bab151`) provides the
model: `bend.ts`'s `Infer`/`Check` retain typed terms; `def_check` publishes them;
`comp.ts`'s `fun_of` consumes them. Per-compilation object-keyed maps retain
opened terms, uses, spines and other facts. Emission still repeats when ownership
and representation facts change. Upstream is not a single-pass backend.

Our checker already rebuilds terms in `KChecking.term`, preserves a separate
semantic declaration world, and publishes completed terms in `KWorld.checked`.
The subsequent `annotate_selected` reconstructs application, constructor, match
and let types. That is a concrete boundary to improve before introducing another
IR hierarchy or replacing the complete native backend.

## Sequential implementation and decision gates

1. **Checked type retention.** Prototype type annotations on successful checking
   results. Keep the chronological semantic world unchanged. Let backend readback
   normalize retained types in the final specialized world; never treat an early
   weak-head result as valid after later law fills. Reuse existing result/term
   carriers initially. Preserve failed results, first-error ordering, specialization
   consumed counts, source locations, binder identity and field/lambda quantities.
2. **Consume the retained graph.** Replace repeated inference during annotation
   with structural readback of checked runtime nodes. Keep the old annotation
   path for ordinary unannotated terms/public callers. Explicit annotations,
   rewrites, erased arguments and partially consumed template spines need named
   controls. Reachability must not accidentally emit new dependencies solely
   because private annotations now occur earlier.
3. **Measure before widening.** Build checked B1, run the frontend36 gate, then
   fresh alternating baseline/candidate requests with complete C equality on
   Numeric, Array.map and lexer. Follow with small/functions65. Capture stage/CPU
   profiles only to explain results, not as clean timing samples. Include added
   Base preparation/cache size and all added checking/readback costs. If net
   benefit is absent or output differs, diagnose in this bounded loop. Do not run
   broad release gates merely to rescue an unpromising design.
4. **Stable identity and shared lowering, conditionally.** If the boundary wins,
   investigate dense per-definition identities and immutable request-local tables
   for genuinely repeated analyses (erased body, uses, application spines, layout).
   Binder IDs are **not** expression IDs. Rewrites mint new identities; facts are
   scoped to the particular checked/specialized graph and analysis environment.
   No JavaScript host implementation of Bend semantics and no disk cache. Add a
   table only with measured reuse exceeding its construction/lookup/allocation
   cost. Fold compatible ordinary/product/observer consumers onto those facts
   rather than creating a fourth backend. This stage is contingent on evidence,
   not a requirement to ship a large rewrite after a failed discriminator.
5. **Qualification and promotion.** A worthwhile selected change gets the
   applicable native100/raw31/new14/word10/held-out/JS/threads gates, broader
   frontend checks for checker changes, genuine B2 self-check and exact B3,
   B1/B2 emission comparisons, and installed-package verification. Exact previous
   C and JS artifacts establish unchanged generated programs; if output changes,
   require execution correctness and representative runtime comparison first.
   Publish measured B1/B2 ratios separately. Never report a B1 result as B2.

## Falsifiers and scope

The first prototype tests whether type retention is cheaper than reconstruction
after accounting for larger graphs, Base decode, reachability and normalization.
Target at least 5% end-to-end savings in the screen, with no material held-out
regression; smaller clear gains may be retained only if they also simplify the
implementation. This boundary alone does not promise parity: Phase78 profiles
show annotation occupies only part of the remaining deficit. Tables or a more
integrated lowering path must remove additional work to approach that goal.

Failures include changed acceptance/diagnostics, stale type facts, field quantity
loss, broken fresh-prefix admission, larger dependency closure, memory growth,
or savings displaced into another measured stage. Preserve every failed attempt
and exact source snapshot. Revert unsuccessful production changes while keeping
their experiment records; do not replace the installed compiler with a prototype.

One supervised CPU3 execution tree; aggregate RSS 2 GiB, available-memory floor
4 GiB; Node heap 1 GiB/stack 4 MiB. Check disk headroom. No agents, no PR comments.
Design, experiment, implementation and report commits may be pushed without
additional confirmation. Unrelated inherited Phase6/68 work stays untouched.

## Evidence-driven amendment after the first screens

Whole/live-only type retention misses the gain gate and regresses held-outs;
restore the original frontend. Counts02 instead finds repeated *different-binder*
queries over the same native bodies (271 root queries/45 bodies,49,732 recursive
calls/2,243 term identities). Test a compact per-body occurrence summary shared
by existing sharing analyses, using the existing saturated quantity algebra.
This needs neither a new frontend IR nor node IDs. The summary must equal the
old per-binder query, including branch maxima and malformed-node conventions.
Its cost belongs inside the request. This bounded revised stage-four experiment
has the same measurement, held-out and qualification gates; see P80-003.

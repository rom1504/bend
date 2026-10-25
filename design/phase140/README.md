# Three-hour incremental compiler campaign

Started 2026-10-25 18:12 UTC; initial decision point 21:12 UTC. Parent
`7e5067c`, qualified producer Phase137 N3. This campaign implements the
[Phase139 reuse proposal](../../research/phase139/reusable-checked-units.md)
under its [intermediate gates](../phase139/validation-gates.md).

The target is 10× faster complete **warm builds after substantive compiler
source edits**, with at most minor compiled-program regression. This does not
promise 10× cold builds. Keep the installed and qualified compiler unchanged
until independent qualification warrants adoption.

## Experiment and budget

Freeze real same-shape numeric/policy and body edits, plus invalidating controls.
Compare incumbent ordinary B, candidate cold B and candidate warm A→B; include
source reading, invalidation, all remaining compiler work, machine build and link.
Record acquisition/seeding and focused executable validation separately.

1. First 20 minutes: audit actual reuse boundaries and mandatory floors.
2. Next 60 minutes: implement checked small parser/checker/lowering controls in
   separate Bend modules. One coordinator owns timing and integration.
3. Next 50 minutes: compose successful boundaries; measure complete small
   requests and the cost of dependency comparison, retention and destruction.
4. Final 50 minutes: one justified real-compiler comparison, then preserve
   results, failures and the most valuable next decision. If small evidence
   cannot support escalation, spend this period fixing the decisive bottleneck
   instead of launching an uninformative self-hosting campaign.

Bounded agents own independent parser, checker, backend and artifact audits.
They do not run competing full builds or change production selections. Root
owns source assembly, rendering/output reuse, native orchestration and receipts.

## Architecture under test

- Retain actual parser state at a source boundary; exact prefix equality and
  complete parser state are mandatory. Fresh suffix parsing preserves diagnostics.
- Retain the actual checker world and seen set. Admission checks ordered actual
  post-freshening declaration projections, prefix, bound and producer/Base epoch.
- Reuse prepared/lowered owner results before executing their expensive
  producers. Dependencies include bodies, negative lookups, signatures, ownership,
  layouts, fresh identities and optimization admission.
- Reuse rendering only through complete semantic input/dependency equality.
  Existing machine artifacts are reusable only with exact current bytes and
  toolchain/runtime identity. Unknown dependencies take the ordinary path.

The previous roughly 45s parse and 65s render boundaries each threaten the
35s tenfold budget. A checker-only hit or a late object cache cannot meet it.
The first conservative supported edit class may be narrower than arbitrary
source edits; report that class and fallback cost explicitly.

## Acceptance

Use 20–60s contract loops and 60–180s selected request screens with ready
artifacts. Require actual skipped work and fresh/reused output agreement. Deliberate
stale dependencies must be detected. No-op and spelling-only edits do not establish
the headline target. Cold overhead limit 5%; program-runtime limits 2% overall,
2% per family and 5% per case, subject to focused noise confirmation.

Escalate to a full build only when composed savings plausibly support 2×. The
5× milestone requires three frozen substantive supported edits; 10× is the
ambitious objective, not an expected result written in advance. Every rebuilt
compiler must actually run independent requests. Exact unchanged generated
products may reuse authenticated runtime evidence; otherwise run affected
families and escalate broad changes at integration.

Keep one heavy CPU lane, 4GiB process-tree bound, 16GiB available-memory floor,
bounded current/pending state, and explicit storage accounting. Initial disk
headroom is approximately 11GB; do not retain unnecessary full image copies.
No new backend, runtime ABI, proof claim or benchmark definition is needed.

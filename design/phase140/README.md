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

## 19:43 UTC experiment decision

The second composed hosted screen passes exact products and error recovery, but
its ordered cold-B observations add about20–22% versus the original request.
Therefore it has **not passed the5% cold-cost criterion**, and acquiring the next
native prototype is an explicit bounded research exception, not G2 acceptance or
permission to promote it. The user's objective is warm edited builds; first-cache
acquisition must nevertheless be priced and amortized rather than hidden.

Reasons to measure one native prototype: the initial full compiler experiment
already eliminated about180s of emission work with exact independent output;
small hosted costs did not predict native costs; and the next changes remove
whole scans (indexed closure visitation, retained reverse dependencies, static
preparation prefixes, observer plans and dispatch metadata). A native request
will decide whether those savings justify the retention overhead. Preserve the
ordinary compiler and installed selection. If cold overhead remains excessive,
keep reuse opt-in and report the failed criterion; do not silently relax it.

The new static-preparation capability preserves complete actual prefix state,
including accumulated facts, image allocation cursor, intern index and error.
Exact current constructor/effect inputs and erased facts establish prefix
agreement; the first difference disables all remaining prefix reuse. It never
rebases old static addresses. Independent source audit and16 differential
controls precede the native experiment. Memory cost remains a measured risk.

## 20:16 UTC scope decision

The native three-edit batch completes at134–139s per warm emission. Its final
product-policy B matches the independent qualified reference exactly; the two
other outputs have not yet received their own independent full-build references.
This is below the5× escalation criterion. Do not spend another two full reference
builds solely to certify that missed target. Preserve those rows as exploratory,
not G4 evidence.

The next candidate is measured on the original A→product-policy B pair, with a
checkpoint before that late owner and existing independent A/B references. It
adds bounded exact static-image convergence, indexed report-name deduplication,
and retained successful verifier metadata under the original exact context gate.
All236 finite controls and the complete small request screen pass. The cold
screen still exceeds the5% criterion; qualification/promotion remain withheld.

An optional separate sampling run may identify residual warm work. Instrumented
times must remain separate from clean scores. Stop adding speculative caches;
measure the integrated candidate and preserve the remaining floor explicitly.
# Final bounded experiment checkpoint,20:35 UTC

Candidate17 passes the independently referenced full product-policy pair with
105.228s native warm time. The available-executable subtotal is124.337s; charging
all shared session/runner overhead to the edit gives128.610s, versus346.960s
fresh with the same measured machine build. The cold seed remains8.93% slower
than the initial prototype. This is progress on warm reuse, not a cold-gate pass.

One final candidate replaces private higher-order equality callbacks with exact
typed Bend comparisons. Source checking,255 finite controls, two-family complete
output/plan equality and error recovery pass before native acquisition. It is
motivated by actual generated callback/continuation machinery, not hit counts.
Its outcome will decide whether to generalize comparison specialization or
prioritize cross-stage change evidence. Do not add another independent cache
layer after this experiment in the current campaign.

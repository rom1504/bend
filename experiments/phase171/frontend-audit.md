# Phase171: remaining frontend work and the 100-second target

Read-only source/evidence audit at Phase170 source
`434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`,
starting HEAD `25dda2f`. No target, compiler build, benchmark, production edit,
or new qualification was performed. The reference is the **189.329-second
complete maintained-source native self-build**, not Phase169's smaller closure.
Reaching 100 seconds requires removing **89.329 seconds / 47.18%**.

The strongest remaining frontend architecture is **one semantic declaration
store through checking and publication, with ordered legacy views materialized
only when a consumer actually requires them**. This is broader than replacing
lookup or changing numeric IDs. It removes redundant state that must currently
be updated, traversed and reclaimed together. It remains an unimplemented
architectural opportunity, but the existing evidence does **not** support it,
or any other frontend-only proposal, supplying the entire 89-second saving.

## The cost envelope, without reusing obsolete gains

[Phase161's disjoint stage metrics](../../implementation/phase161/profile-metrics.json)
partitioned an older 239.794-second diagnostic CPU observation:

| Responsibility | Historical CPU seconds | Interpretation now |
|---|---:|---|
| Parse/load |29.519|Includes parsing, elaboration, validation and freshening; not lexer alone.|
| Checking/publication |33.684|Predates selected publication improvement; not the current residual.|
| Proof report |3.317|A separate complete-report obligation.|
| Ownership/foreign eligibility |0.221|Too small to be a primary optimization target.|
| Annotation/reach |6.488|Reconstructs emission facts; not another complete typecheck.|
| Layout |2.618|A later consumer of those facts.|
| Erasure/finalization |6.400|Another complete representation transition.|
| Other preparation before backend |0.976|Includes Base/context and remaining small boundaries.|
| **All work before backend** |**83.223**|Historical envelope, not an attainable saving or current stage measurement.|

Even deleting this entire old envelope would not explain a current 89.329-second
saving. More importantly, it contains necessary parsing/checking and work already
eliminated. A fresh current-stage profile is needed before allocating a precise
seconds budget; the old shares must not be multiplied by 189.329.

[Phase169 physical samples](../phase169/native-n2-profile-summary.md) put 10.61%
at `term_drop`, 7.73% at `span_fade`, 8.52% at the existing borrowed String equality
reader, and 4.43% at `take2`. These overlap semantic stages and include runtime
cost from many producers. They support reducing temporary products, but do not
attribute those percentages to the frontend or establish additive savings.

The Phase170 suffix repair made the complete full build 189.468→189.329 seconds
in single observations, despite a large hosted lexer improvement. Its main
demonstrated value was making the genuine JS bootstrap practical. This is an
especially relevant warning against extrapolating a frontend kernel result.
See [the completed report](../../implementation/phase170/README.md).

## What is already selected

The [Phase156 publication policy](../../selfhost/src/check/publication-reuse.bend)
is called by `p143cb_resume_state` in
[compact-schedule.bend](../../selfhost/src/check/compact-schedule.bend#L164).
It tracks whether the logged declaration view is dirty and avoids repeated
canonicalization until a consumer needs it. It is not a pending optimization.

The older [Phase162 causal observation](../../implementation/phase162/README.md#causal-ablation-repeated-publication-is-expensive)
changed canonicalizations 370→76, final-selection rows 3,005,961→636,469,
checking allocation requests 613.60M→254.70M, and diagnostic C check CPU
31.543→12.344 seconds. The clean native whole-request observation was 4.62%,
already incorporated later. None of those gains can be credited again.

Other proposals that would repeat existing work:

- Annotation already reuses application-spine types and stable constructor
  telescope tails: `ka_app_spine` and `ka_args_after_head` in
  [annotate.bend](../../selfhost/src/check/annotate.bend#L403).
- The checker already has batched substitution and bounded deferred telescopes,
  plus graph memoization with separate rigid/unfolding worlds. A generic
  instruction to add environments or memoization is not new.
- Checked bodies are already retained by `dg_event_output` and
  `kw_put_checked`; they are not simply discarded and checked from scratch.
- Prepared Base and successful-world context reuse are already selected.
  `book_context_world` does not rescan the immutable Base term trees merely to
  recover their maximum binder ID.
- The frontend already carries parser name/constructor indexes in
  `FReadyPrefixGraph`. Adding another parser lookup cache is not the large idea.

## Recommended architecture: semantic book, explicit event history

Current code still represents several different responsibilities with
`List<KDef>` plus an implementation `BookCache` sentinel. At publication:

1. `p156cp_continue` updates the separate `seen` book using `book_put`.
2. `p156cp_put` updates the semantic world, sometimes materializing the raw
   declaration list before a non-childless publication.
3. `book_put` updates both the persistent index and a declaration list;
   `index_put_rest` calls recursive `index_remove` when replacing a present name.
4. `event_error` calls `constructor_names`, whose `constructor_exists` scans
   semantic declarations and their constructor lists.
5. Final publication and context consumers produce another ordered view.

These are actual source loops, not an assumption based on a runtime leaf:
[publication-reuse.bend:4](../../selfhost/src/check/publication-reuse.bend#L4),
[index.bend:340](../../selfhost/src/core/index.bend#L340),
[kernel.bend:1156](../../selfhost/src/check/kernel.bend#L1156).
The Phase162 counted workload retained **6.533M index-remove visits and 2.010M
constructor-existence visits unchanged** after the publication improvement.
Their current dynamic totals require confirmation, but the relevant remaining
algorithms are present.

Introduce a private checker state with separate declaration lookup, constructor
ownership, event order/last-event information, checked outputs, and template
state. Each accepted event updates its semantic records once. Keep the existing
event order and diagnostic machinery. Materialize the public ordered book at
the result/API boundary; do not maintain a second raw list after every update.
Carry this state through `check_declarations`, the event walker, specialization
publication and final context construction. A wrapper that converts to `KDef`
before each old consumer would retain the cost and would not test this proposal.

The difficult invariants are concrete: all signatures visible before bodies;
only completed bodies unfold; the original first error and law/fill compatibility;
constructor collisions; template rollback and snapshots; empty names and public
malformed-cache behavior. Keep generic public APIs unchanged, with a private
entry admitted only from the actual parsed/validated source and prepared Base.
Legacy fallback remains necessary outside that invariant. Do not turn a parser
success flag into authority to skip the independent checker.

**Cheapest decisive experiment:** make the private state handle declaration/event
publication end to end, while retaining the original term checker. Use the
actual retained full-source event stream and a smaller real checker source,
including Base, datatypes, laws/fills and template events. Compare the complete
ordered checked result, complete diagnostics, and independent negative controls;
then compare complete QBE for the smaller source. Charge conversion, final
materialization and teardown. A publication replay alone is a mechanism test,
not sufficient evidence for integration.

First collect the remaining visited rows and stage allocation totals on the
current route. If book coherence is now below roughly 10 seconds of the full
request, stop the large migration as a speed priority. A **3–10-second whole-build
saving is a planning hypothesis**, not a measured range; a much larger forecast
needs current evidence that the changed consumers own that much work. Budget
roughly 1–3 hours for a complete-path prototype/falsifier and at least a day for
a careful broad migration, depending on specialization/rollback changes.

## The larger follow-on: stop rebuilding frontend terms between stages

To reach beyond that narrower book ceiling, retain producer-owned semantic facts
and term structure through the actual consumer, rather than repeatedly walking
generic children. Two specific remaining boundaries are visible:

- Pattern matrix elaboration repeatedly calls `f_pattern_sub` over a row body;
  `f_hit_row` can perform two substitutions in sequence. Each traversal rebuilds
  children and carefully adjusts source spans. A pending substitution environment
  applied once when a final branch is emitted could remove repeated traversals.
  This is distinct from the checker's existing telescope substitution.
- `f_prefix_trace_validated` invokes `f_fresh_defs` over the complete new suffix.
  `ffw_walk_existing` then walks terms and reconstructs child lists/binder nodes.
  A producer that emits the final binder order during elaboration could remove
  that full transition. Simply changing parser counters is not equivalent:
  freshening happens after pattern expansion, respects let scopes, and currently
  establishes exact global binder identities.

Source anchors: [elaborate.bend:216](../../selfhost/src/front/elaborate.bend#L216),
[prefix.bend:293](../../selfhost/src/load/prefix.bend#L293),
[fresh_work.bend:134](../../selfhost/src/front/fresh_work.bend#L134).

The ambitious version is one elaborated, binder-normalized term product consumed
by checking, annotation and erasure, carrying only facts already established by
the actual checker. This can reduce multiple representation lifetimes and their
RC work. It must still check unused source declarations and preserve the exact
diagnostic and emission contracts. It is a multi-stage redesign, not deleting
validation or claiming annotation is redundant.

For the first cut, use complete real pattern-heavy declarations and imported
module fragments. Compare full freshened terms including binders, quantities,
spans, removed names and ordering; compare exact diagnostics; then compare
complete QBE. Include nested constructor patterns, duplicate binders, parallel
lets, templates, and generated lambdas. Reject a proposal that merely moves the
same traversal into a conversion pass. Historical parse/load is a **29.519-second
upper envelope**; the listed old active-owner samples do not establish a large
inclusive share for these two loops. A 2× improvement in the whole old parse
stage would be 14.76 diagnostic seconds, not 50 seconds of current wall time.

## What bendc actually teaches us

The pinned comparison is bendc
`56edcc65b3527a75838011682c231072d5b46097`; the source audit and exact anchors are
in [Phase161 frontend architecture](../phase161/frontend-architecture.md).
Its typed `Book` separates declaration map, constructor map, order and template
state. Its `book_set` changes the semantic map without maintaining our generic
sentinel/raw-list coherence. That directly supports the first proposal.

Its typed term constructors also avoid generic child-list wrappers, but the
retained [compact-App experiment](../../implementation/phase163/README.md)
made our complete native checker slower, about 4.7%. A representation change
must cross producer and consumer boundaries and remove actual products; fewer
fields on a diagram is not a speed result. bendc itself has separate checking
and emission parsers, so it is not evidence for an already proven single-pass
frontend design.

[Phase165](../../implementation/phase165/README.md) also rules out two attractive
distractions on this workload: disabling native memo operations barely changed
full checking time, and transplanting our exact existing held String-equality
algorithm into bendc stayed near its native baseline. This does not prove equal
machine cost everywhere, but it contradicts another large forecast from simply
adding memoization or rewriting that same equality worker.

## Recommendation for the 100-second campaign

Use the current full-stage profile to decide whether the private semantic-book
prototype has enough remaining cost to justify implementation. Treat parser/
elaboration fusion as the next broader frontend experiment, with complete output
gates before acquiring a compiler image. Do not start another isolated ID,
lookup, equality or compact-node kernel campaign.

A combined **15–30-second frontend improvement is an ambitious engineering
hypothesis**, not a forecast justified by current measurements. Even that leaves
roughly 59–74 seconds to remove elsewhere. The 100-second target therefore needs
the frontend work paired with a large reduction in backend construction or the
native execution cost of the whole compiler. The audit found no credible
frontend-only 89-second shortcut that preserves the maintained semantics.

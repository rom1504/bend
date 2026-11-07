# Whole-computation critique after the indexed-store experiment

Read-only source/evidence audit at `db10595c`, with the current Phase173
experimental files. No target execution or production edits. The store and
borrow agents independently cover [store amortization](next-architecture.md)
and [retaining a private parent across recursive calls](next-borrowed-computation.md).
This note examines boundaries between complete compiler passes.

**Conclusion: no currently attributed category supports a credible greater-than
20% full-build gain from one additional narrow traversal fusion.** There is a
larger architectural opportunity in the lifetime of typed semantic information,
but it requires a consumer contract, not merely a faster tree container. The
present evidence does not justify promising that this is the missing 80 seconds.

## What remains repeated, and what is already shared

The selected request constructs several representations of a reachable body:

1. The checker returns a checked `KDef` body. During checking it computes types,
   quantities and constructor telescopes, but its returned nested term does not
   retain every node's inferred type. See `check`, `check_fits`, `check_lam_done`
   and `check_ctr_found` in [`kernel.bend`](../../selfhost/src/check/kernel.bend).
2. [`p86_plan_context`](../../selfhost/src/host/native-plan.bend) calls
   `annotate_selected`. [`annotate`/`ka_annotated`](../../selfhost/src/check/annotate.bend)
   normalize the expected type, reconstruct the node and wrap it in `Ann`.
   `ka_type` and dependent telescope operations recover type information during
   this new walk. Application-spine annotation already shares intermediate
   types; that existing optimization must not be rediscovered as a new proposal.
3. `jl_checked_error` reads the annotated bodies for layout obligations.
   [`p144o_prepare_annotated`](../../selfhost/src/back/common/constructor-facts.bend)
   merges them into the source book, computes its exact fresh-ID bound and
   constructs the request. [`p143nr_visit`](../../selfhost/src/core/query-ownership.bend)
   erases each reachable definition, then scans the erased body for ordered
   references before publishing `NativeErasedBody`.
4. [`p112s_defs`](../../selfhost/src/back/qbe/static-data.bend) compacts that body,
   then reconstructs it again while interning static terms. Its published
   `NativeStaticBody` deliberately retains the previous erased fact. Several
   semantic versions therefore coexist rather than replacing one another.

This does **not** mean every later call erases or compacts again. `nc_definition`
uses the prepared facts; `nc_compact_definition` returns a `NativeStaticBody`
directly. `P112Liveness` already analyzes let suffixes backwards and avoids the
obvious repeated shrinking-suffix traversal. The Phase171 public-emitter fusion
already removed an entire worker-list producer/consumer intermediate and was
neutral. Neither a grep count of these calls nor another memo wrapper establishes
remaining repeated work.

The Phase173 store result is a particularly useful negative control: removing
45,139 logical output-store writes and 135,417 later logical reads still leaves
the complete best reported store computation at 91.048ms versus 78.806ms,
1.155×. The terminal-record experiment likewise removes real allocations without
yet showing a broad complete-AST speedup. Removing work at the source level is
necessary evidence of the mechanism, not sufficient evidence of elapsed gain.

## Quantitative limits

The [Phase171 candidate profile](../phase171/candidate-profile.md) is the latest
complete disjoint stage attribution used here. Its diagnostic clock is not the
clean 180.677s build clock and does not independently attribute retained-object
destruction to the stage that created those objects.

| Candidate boundary | Diagnostic containing interval | What is actually established |
| --- | ---: | --- |
| Annotation, layout, erased closure and other post-check preparation |18.281s|Annotation about6.30s, layout2.53s and remaining request preparation5.83s in the earlier detailed capture; exact current erasure share unknown.|
| Compact body plus static-body preparation |about4.13s|A real adjacent chain, but too small to be the main breakthrough.|
| Raw private lowering plus demanded generic lowering |24.985+8.508=33.493s|Deleting these entire intervals would still be less than20% of a roughly180s request; most work is required.|
| Registry construction plus rendering/output/exit |12.271+30.454=42.725s|A greater-than20% scope envelope, not evidence that this much redundant work exists. Public fusion and renderer-fact sharing were already neutral.|

These are **producer-stage envelopes**, not hard whole-lifetime ceilings. A
representation retained in `NR_Request` may cause allocation or reclamation in
later intervals. The lifetime contribution is presently unknown. Conversely,
calling all later ownership/runtime samples the cost of annotations would be
unsupported. The capture's large unknown-caller fraction prevents that shortcut.

The already tested deferred-pattern and selector hypotheses should remain
closed. A new annotation experiment must not silently bundle their unproven
benefits or historical gains from publication/static-body reuse.

## The larger alternative: publish semantic obligations, not a second typed AST

The consequential architectural boundary is **checked body → full annotated
body → erased body**, rather than `KTerm` versus indexed `KTerm` alone.

A future producer could consume the checked body and its expected type once,
returning the exact erased body plus explicit facts required by layout,
ownership, sharing and representation selection. Its result would contain:

```
NativeBodyFacts {
  erased_body,
  ordered_erased_refs,
  layout_result,
  live_argument_and_field_quantities,
  type_facts_required_by_semantic_consumers,
  exact_source_identity_and_bound
}
```

This is an interface sketch, not an implemented record or a certificate. The
original checked source remains available for diagnostics and independent
checking. The final semantic verifier remains unchanged. The consumer-required
facts cannot be replaced by an unchecked Boolean saying that a body is safe.

The obstruction is concrete. [`nh_definitions`/`nh_terms`](../../selfhost/src/back/native/sharing.bend)
currently combine the compact erased body with `dv(d)` from the annotated book;
`p131u_hot` uses the typed term traversal to classify duplicated values. Several
ownership/construction observers also inspect original equations and types.
Returning an unannotated `dv(d)` changes what these consumers can prove, including
their conservative fallback decisions. This can change runtime capability flags
or generated-program quality even when ordinary value tests still pass. Full
compiler cold-constructor permission happens to be disabled by its effects, but
using that accident to drop required information would not generalize.

Consequently, the sound version must first define the exact observations needed
by those consumers. Keeping an entire annotation tree under another record name
does not test this hypothesis. Rebuilding it lazily for almost every owner also
does not remove the category of work. A durable minimal fact stream could;
whether it is actually smaller and cheaper remains unmeasured.

## Smallest decisive experiment and stop rule

The low-risk immediate slice remains the store agent's **erasure plus ordered
reference publication** on actual compiler definitions. It eliminates one
complete walk without representation conversion and has an existing independent
oracle. It cannot, by itself, establish a20% complete-build route.

For the larger alternative above, use one actual verifier/optimizer definition
and its dependency closure, with both baseline annotation and erased outputs
retained as oracles. Implement a private typed-erasure producer that emits the
same erased body, ordered references, first layout error and the exact observed
sharing/ownership facts, directly from the checked body. Initially reject
unsupported forms to the unchanged whole-definition path before publishing any
fact. Preserve dependent substitutions using original arguments, erased/dead
branches, evaluation order, names, source spans and fresh-ID bounds.

The experiment must charge checking, producer, fact construction, consumers and
teardown. Record how many full annotation nodes disappear and which consumers
still demand them; then require complete request/QBE equality and independent
runtime controls. If most relevant bodies require reconstruction of their old
typed tree, or the complete request remains neutral, reject this interface before
touching the checker. Only a material winner justifies moving fact production
earlier into the checker itself, which is the more powerful and riskier version.

Before implementing even that slice, a short diagnostic around existing
annotation/erasure/consumer boundaries must establish their inclusive cost on
the actual source. If this cannot explain a useful portion of the full request,
do not launch it as another100s campaign. No current measurement demonstrates a
greater-than36-second removable lifetime cost here.

## Recommendation

Keep the general SCC/ABI discoveries, but do not turn the unsuccessful store
pilot into a broad migration. Do not promote terminal parent reuse on setter
microbenchmarks alone. The meaningful architectural next question is whether
the compiler can **compute and publish semantic facts once, then retire the
typed tree**, preserving all actual consumer behavior. That addresses a real
boundary shared by multiple passes; it remains a research hypothesis with
unattributed ceiling, not a promised20–50% speedup.

For a near-term implementation, choose the existing erasure/reference vertical
slice only if its stage attribution is material. For a breakthrough claim,
require either measured lifetime cost spanning several stages or a substantially
faster execution model that transfers across them. The evidence does not yet
support selecting an honest single-pass20% winner.

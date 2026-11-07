# Reuse checked constructor-field quantities during native erasure

Source-only investigation at `0d12402`, canonical Phase174 source
`74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.
No compiler, API, native target, or benchmark was executed by this investigation.
The experimental implementation and finite controls are unqualified until the
coordinator acquires and runs them.

## The concrete repeated work

`check/annotate.bend:462` defines `ka_field`: each constructor field receives an
`Ann` containing its elaborated value/type, `ix=1`, and the exact quantity
obtained from that constructor telescope. `ka_args_cached_head`,
`ka_args_after_head`, and `ka_args_static` all produce this marker. Annotation
already performs dependent substitution/normalization to find those quantities.

`back/js/validate.bend:458` already consumes those quantities in `jl_fields`.
The native eraser does not: `back/native/erase.bend:67` reopens the constructor
telescope with `nc_tele_fill`; `nc_erase_args` then normalizes each telescope
tail and substitutes each already-annotated argument again just to decide
whether that argument is erased. It also allocates and drops those telescope
products. This is a distinct remaining consumer, not another proposal to add
the annotation telescope cache that is already selected.

The experimental eraser uses `qt(field)==0` from the authenticated producer
instead. It preserves all the actual erasure rules, constructor identities,
proof erasure, application behavior, lambda variants, and match-field masks.
There is no runtime/compiler backend change and no new cache.

## Authority and scope

A raw `Ann` with `ix=1` is **not** a certificate. An arbitrary caller can forge a
different quantity; the finite controls deliberately demonstrate that such a
forgery changes the private eraser's result. The optimization may only execute
on this successful checked driver's actual `annotate_selected` products.

The only override is `p86_plan_annotated` after the unchanged
`jl_checked_error`. The private preparation retains the exact annotated
first-match index used by `nc_context_defs`. Its ordinary definitions are the
same winners installed into the merged book. Native stop definitions, foreign
definitions, templates that `ka_def` did not annotate, and names absent from the
annotation index retain `nc_definition_plain` unchanged. The public `nc_erase`,
`nr_prepare`, and `nr_prepare_annotated` entry points remain unchanged.

Within an authorized body, all direct constructor arguments must have the
exact `ka_field` shape (two children, empty name/removal list, zero spans,
quantity 0/1/2). Otherwise the original telescope-based decision is used. This
shape guard is defensive; it does not establish provenance. Do not install it
globally as a marker-based fast path.

The private closure walk preserves original todo order, first visits, erased
facts, source and ownership views, binder bound, paths, and scope. Final
verification and all downstream passes remain unchanged. Its extra per-owner
authority lookup and marker scan are charged costs; their profitability is
unmeasured.

Files:

- `selfhost/tests/phase175/semantic-field-erasure.bend`: separate private
  eraser and checked request preparation.
- `semantic-field-prelude.bend`: one forward preparation interface.
- `semantic-field-entry.bend`: only `p86_plan_annotated` replacement.
- `semantic-field-controls.bend`: 18 finite controls plus complete terms for
  host serialization. The unchanged `nc_erase` supplies the independent oracle;
  an explicit expected constructor term supplements paired agreement.
- `semantic-field-dependent.bend`: erased Type field followed by a dependent
  payload, and generic Data parameters plus explicit erased value fields.
- `semantic-field-rewrite.bend`: an ordinary live constructor under a rewrite,
  carrying a dependent erased equality field. Both fixtures have literal full
  stdout files; independent source checking remains required before native use.

## Cheapest decisive experiment

1. Independently source-check a bounded hosted API with original and candidate
   entry points. Run all 18 controls, serialize the complete values, and verify
   the literal expected constructor including representation, spans and lambda
   quantity-presence metadata. Keep the deliberate forged-marker witness.
2. Compare the **complete** original `nr_prepare_annotated` and private
   `p175sf_prepare` results from the same real checked annotation product. Use
   the retained nonempty compiler verifier and an unrelated Map/data workload.
   Cover constructor parameters, quantity-zero fields, dependent telescopes,
   nested products, native stops and foreign definitions. Identical erased
   bodies alone are insufficient: compare order, paths, scope and bounds too.
3. Require byte-identical complete QBE and independent program outputs. Measure
   the complete request and the preparation interval in the existing fast loop.
   If neutral, stop before any full image acquisition. Do not select a candidate
   merely because it eliminates many substitutions.

The first attempted hosted acquisition rejected a typed definition after a
forward `law` (`p175sf_arg_head`). That syntax-only failure is retained by the
coordinator. This module now uses bare law fills for both that helper and the
externally declared `p175sf_prepare`; all other forward fills were already bare.
The report-name overlay's `p175rn_walk` is also a bare law fill. No source checker
execution or new success is claimed by the source-only repair.

## Whole-request ceiling and priorities

The latest retained same-input Phase171 diagnostic (not a fresh Phase174
profile) partitions the relevant work as follows:

| Region | Seconds | What is actually covered |
|---|---:|---|
| Checking/publication |19.0273|Actual checking plus publication; not all redundant.|
| Proof-dependency report |2.5768|Report and complete unsafe/foreign dependency result.|
| Ownership/foreign eligibility |0.1939|Already too small for a primary campaign.|
| Entry/context |0.6558|Includes repeated private prefix admission/bound checks.|
| Reach/annotation |6.3896|Preexisting spine/telescope reuse already selected.|
| Checked layout |2.5562|Independent open-Array obligation, not another typecheck.|
| Merge/bound/erasure/facts |5.9091|The proposed field reuse changes only a subset.|
| **Checking plus after-check work** |**37.3087**|Nonoverlapping diagnostic intervals.|

Evidence: `implementation/phase171/metrics.json` →
`profile.stageComparison`, candidate clocks. These are diagnostic clocks on a
fixed older input; do not subtract them directly from a fresh 188-second clean
build or treat the entire category as removable.

Ranked source-grounded opportunities:

1. **Reuse quantities at the annotation/erasure boundary (this experiment).**
   Bounded implementation and existing exact-product oracle; strongest cheap
   falsifier. Absolute ceiling is less than the entire 5.909-second finalization
   interval. A 20–40% reduction of that interval would be 1.18–2.36 diagnostic
   seconds, a scenario rather than a prediction. No generated-runtime gain is
   expected because output must remain exact.
2. **A combined producer for annotated body, layout facts and erased body.**
   If the first test proves rediscovered facts are costly, retain quantities,
   normalized constructor information and dependency facts as products of the
   existing annotation traversal. This could remove annotation wrappers and
   repeated child/telescope traversals across approximately 14.855 seconds of
   annotation/layout/finalization. It needs a durable semantic contract and a
   separate final verifier; it cannot simply skip layout checking. Estimate a
   few hours for a complete real-workload falsifier, not a promised full rewrite.
3. **Semantic declaration store through checking/publication.** Existing
   Phase171 publication history already eliminates the duplicate childless
   `seen` list; Phase156 dirty-publication reuse is selected. A larger store
   must replace the real world's simultaneous ordered/list/index products
   through event checking, specialization snapshots and final publication.
   Its total stage ceiling is19.027 seconds and only part is representation
   overhead. It is materially harder than the field experiment; do not begin
   with another generic lookup/index cache.
4. **Carry successful prefix admission into context construction.**
   `p143cb_program_book` and `base_prefix_context_world` repeat suffix-bound,
   admitted-prefix and disjointness work on the same load/world. A private
   result carrying that established fact can remove redundant checks while
   preserving raw fallback. But the entire later context interval is only
   0.656 seconds: reject it as the main architectural breakthrough.

## What not to repeat

Phase165 found native memo/equality transplants did not explain the gap.
Phase163's compact App checker regressed. Phase172 deferred pattern substitutions
preserved outputs but were neutral in the actual loader. Phase173's automatic
owned reconstruction improved selected workloads but slowed complete compiler
acquisition; its contextual materializer ceiling was neutral. Those results
rule out inferring a full-build win from fewer allocation requests or local
helper speed alone.

The present source audit found no credible way to erase all37 seconds while
preserving semantics, much less obtain a10× whole build gain from this region.
The useful next result is one measured consumer that can reuse established
semantic facts without reconstructing them, with complete exact outputs and
charged setup/lifetime costs.

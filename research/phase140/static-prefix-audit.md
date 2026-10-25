# Static preparation prefix-cache audit

Bounded independent source review of `selfhost/tools/performance/phase140/static/core-v01.bend` against the selected Phase137 `p112s_prepare`, `p112s_defs`, `nc_definition`, `nc_compact` and `p112s_attach`. No targets were executed for this review.

No missing semantic input was found under the private, fixed-producer cache contract. This boundary has a particularly small read set:

1. Current `nc_pack_foreign` and cached-book admission run freshly, as in the original.
2. Current constructor order, name, arity and hot flag are compared exactly. The effect-blocked constructor map is also compared exactly, preserving first-match/index structure as well as values.
3. At each active owner, the key requires an exact complete `NativeErasedBody` or `NativeStaticBody` fact. For precisely these kinds, `nc_definition` returns `dv(fact)` without further source/body queries. If the fact is missing or another kind, the owner is rebuilt.
4. `nc_compact` reads only that body. `p112s_term` reads only the compact body, blocked constructor map and incoming `P112SImage`; it does not consult the book.
5. Prefix reuse starts from the original empty `P112SDefs`. Each matching name/eligibility/fact reuses the exact complete after-owner state. By induction the incoming state is identical to a fresh traversal. The first mismatch permanently disables all following hits, even when a later fact matches.
6. The retained state includes the facts list and the entire image: size, nodes, intern index and error. Thus deduplication, encounter-order offsets, 65,536-word capacity behavior and first-error state are not reconstructed approximately.
7. The original `p112s_attach` is called with the **current** book and constructor list. Current constructor metadata attachment is not borrowed from the old book. Failed preparation retains the prior cache, and the complete-session publication gate remains an additional obligation.

Inactive definitions need only matching name and inactive classification: the original `p112s_defs` does not inspect their body/fact or change state. A current effect change still affects the freshly computed global blocked map. Name insertion, deletion or reorder either ends an identical prefix or forces the remaining suffix fresh.

The controls should include active/inactive transitions; direct-fact removal; constructor order/arity/hot/effect changes; first/middle/last edits; suffix deduplication after a miss; stale `NStatic` input; capacity-boundary behavior; failed request publication; and edit/revert. Version1 already includes several of these. Full fresh `P112SPrepared` equality is a stronger oracle than node counts alone.

This is not a formal proof or a speed result. Retaining every prefix also retains historical persistent intern-index versions; the live graph can be larger than the final image alone. Native peak/retained memory, cold acquisition overhead and complete warm payoff must be measured before adoption. No static addresses are rebased, and no stable-literal-ID scheme is introduced.

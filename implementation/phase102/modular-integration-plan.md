# Modular integration plan, before final candidate selection

This is an offline source audit, not a promotion or execution result. The
reference is `typed-observer-source02/compiler.bend`, SHA256
`c02663993bd6d8d8dbcf633ad3372b1335676989f26b2a12ea0ac6e7cebdcbda`.
It combines typed03's scoped local calls and host marking, the retained Phase99
selector specialization, generic TRMC v2, and early owning-observer forwarding.
It does **not** include the String.append-specific prototype or chunk runtime.
Root must choose the final tested candidate before applying this plan.

## Exact Phase102 integration boundary

Compared with the installed Phase98 source, the candidate changes eleven
existing definitions and adds 57 definitions. Four additions are renamed
original implementations (`ntr_plain_*`), so these are not 57 new concepts.
No runtime ABI, constructor representation or new public compiler API is needed.

| Existing definition | Canonical owner | Change to preserve |
| --- | --- | --- |
| `nc_let_prefix_call`, `nc_let_value` | `src/back/native/bridge.bend` | Lower admitted saturated ordinary calls through the existing ordered local-value ownership path. |
| `nc_lower_ctor_to`, `nc_lower_live_to` | `src/back/native/bridge.bend` | Recognize the private TRMC construction node before ordinary constructor sequencing; retain original fallback. |
| `nd_ref_arity` | `src/back/native/direct.bend` | Enter bounded selector specialization for saturated calls; retain all refusal paths. |
| `nf_candidate`, `nf_bodies` | `src/back/native/flat.bend` | Retry only the existing non-tail-self refusal; emit a private root/hole worker and ordinary one-Term wrapper. |
| `nf_plan_scoped` | `src/back/native/flat.bend` after the Phase98 prerequisite | Run owning-observer forwarding after ordinary/product planning and retry. |
| `nq_transfer` | `src/back/native/product.bend` | Complete the private outstanding constructor slot; ordinary transfers are unchanged. |
| `nc_finish` | `src/back/native/book.bend` | Apply existing host-only segment metadata for exact internally authorized no-bang plans. |
| `ns_compile_named_scoped` | `src/back/native/static.bend` after the Phase98 prerequisite | Permit local calls under the weaker checked observer capability without granting sharing/layout capability. |

Recommended organization uses **one new module**, `src/back/native/trmc.bend`.
Keep `ntr_*` analysis, sequencing, private construction and worker emission there.
The four tested entry wrappers stay in their existing owning modules, beside
their renamed original implementations. Do not fuse those wrappers or rename
the helpers during the first qualification: that would add a separate refactor
to the tested transformation.

Keep the fourteen `nbc_*` selector functions in `direct.bend`, next to saturated
application lowering. Keep the eleven `nf_scheduler_*` local-plan functions
together in `flat.bend`, beside `nf_host_*`; the private BookCache plan and
permission distinction are then maintained in one place. Keep the seven
`nfo_*` functions in `observer-integration.bend`, next to `no_route_*`, because
they reuse that exact owning adapter and proof/admission protocol.

Add `trmc.bend` immediately after `flat.bend` in `src/compiler.json`; mirror the
addition in `src/back/native/manifest.txt`. The JSON manifest is the actual
default assembler input. The native text manifest is currently incomplete and
has a different ordering (for example it omits `uses.bend` and `request.bend`),
so do not silently substitute it as the build manifest. The assembler groups
types, laws and definitions; module position does not authorize extra behavior.

## Phase98 is not the current canonical assembly

The actual current `src/compiler.json` lists **132 modules / 32,692 physical
lines**. These are a fresh filesystem census; some historical reports quote a
different census. The native source selected in Phase98 is a separate derivative,
SHA256 `2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
Its authoritative profile is
`selfhost/tools/native/profiles/phase98-comparison02/profile.json`.

An offline declaration comparison, ignoring comments and blank lines, finds
1,239 changed declarations, 150 additions and nine removals relative to the
current canonical manifest. Normalizing only the known `p88_string_eq`,
`p88_string_order` and `p98_tag_eq` call substitutions reduces the changed set to
**44 declarations**. That normalization is an inventory aid, not a proof that
the profile substitutions can be discarded.

The differences that matter to integration are:

- Native `NC_Code.body` is `NC_Text`, with leaf/concatenation/render helpers;
  canonical `NC_Code.body` is still String. Directly copying TRMC v2's
  `nct_leaf` construction into canonical would therefore be ill-typed. Preserve
  the native text representation and all its producer/consumer adaptations as
  one prerequisite, or deliberately adapt the new code to canonical String and
  qualify that as a separate implementation. Do not mix the two representations.
- The native source already has `nf_plan_scoped`, `ns_compile_*_scoped` and the
  checked effect/provider capability split. Canonical has only the older shared
  observer flag. Port the scoped functions and the `nr_compile_prepared` /
  `nc_compile_checked` call chain together before enabling weaker local plans.
- Preserve Phase98's lazy `noa_below` ancestry refusal. Its original eager
  conjunction can recurse through `Absent`; an equality-style rewrite is not an
  equivalent replacement for this termination repair.
- Preserve held String equality/order and fused term-tag comparisons in the
  native compiler source. They affect compiler execution, including the new
  helpers. Prototype files use `p88_string_eq` / `p98_tag_eq`; canonical-style
  spellings require the existing explicit profile rewrite, not undefined names.
- The native lineage includes rope/continuation joining, bounded fork closure,
  nonrecursive table/segment traversals and unindented C emission from earlier
  phases. The D04 source and its exact ancestry remain the baseline for these;
  replacing it with today's canonical assembly loses unrelated selected work.
- Native `p86_*` request I/O and `p88_*` prepared-Base carrier code, their types
  and `main`, are native driver support. Keep them out of the shared core module
  list unless a deliberate driver split is undertaken. The installed JS release
  is an independent selection and must not be relabeled as the new native source.

The remaining 44 changed declarations are in native `book`, `bridge`, `direct`,
`flat`, `observer-adapter`, `observer-analysis`, `observer-emitter`, `parallel`,
`pattern`, `product`, `request`, `scalar-array`, `static`, `tables` and
`word-pattern`. Most are NC_Text construction/access adaptations. The nine
removed declarations are the old `nb_*` indexed fork-closure implementation and
its laws, replaced by the native `p90_*` implementation.

## Integration and reproducibility sequence

1. Freeze the final source, every consumed helper/method and its exact reversible
   recipe. Keep the rejected append versions and consumed method snapshots.
   Replaying the Phase102 recipe onto authenticated Phase98 must reproduce the
   selected candidate byte-for-byte and reverse exactly to Phase98.
2. Preserve the native profile path as the qualification reference. Record a
   modular mirror of the selected mechanisms with the ownership boundaries above;
   do not claim the mirror is the tested image before a separate acquisition.
3. Reconcile prerequisite native modules in one explicit prerequisite change:
   NC_Text, scoped permissions, ancestry repair and earlier native lowering
   differences. Keep native driver/carrier support as an explicit profile input.
   Inventory every remaining declaration difference after assembly. A blanket
   replacement by an old generated full compiler is not modular integration.
4. Apply the eleven hooks and 53 genuinely new helpers to their owning modules.
   Keep one definition of each public entry. Preserve the existing `law
   nc_lower_live_to` alongside its wrapper; the renamed implementation requires
   the explicit signature used by the tested TRMC recipe.
5. Use the existing deterministic `tools/assemble.mjs` to produce source and a
   declaration map. Freeze the manifest and all source-file hashes. A profile
   must explicitly bind the native driver, equality/tag substitutions and any
   remaining overlay; provide forward/inverse edits or an exact declaration
   correspondence against the frozen candidate. Do not apply the old
   position-dependent profile delta blindly to a newly assembled source.
6. Qualify the modular candidate separately: fast application output and emitted
   route checks first; broad correctness/native-chain gates only after that.
   Source ordering can change generated C/FIDs, so source correspondence alone
   is not byte-identical product evidence. Root owns all executions.

Update native backend architecture documentation with the order
ordinary/product planning → TRMC retry → owning-observer forwarding → ready
closure → scoped local calls → scheduler fallback. Document all refusals and
the no-bang host-only boundary, and link the actual source profile and release
selection from the compiler README. Keep the Phase102 experiment report separate
from installed-release claims until qualification is complete.

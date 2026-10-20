# Reviewed N_WordKind consumers

The selected mature `full-source05/compiler.bend` and current Phase111–113
source modules were inspected. These are source-review findings, not execution
receipts.

- `nl_c_type` is the only exhaustive mature three-constructor match. The overlay
  adds `N_Imm64 -> Term`, preserving every original branch verbatim.
- `nf_param_type` narrows only `N_W32`; its wildcard gives Imm64 `Term`.
- `nfp_params` accepts only exact `N_W64`; its wildcard refuses Imm64. This can
  reduce that old scalar-promotion eligibility; it cannot silently narrow.
- `nk_kind`, `nk_value`, `nk_binding`, `nk_typed_bindings`, `nf_params_zip`,
  `nf_typed_params`, `nc_live_uses`, environment partitions/captures, and
  `nq_field_bindings` copy kinds or create ordinary unknown fallbacks. Aliases
  and captures retain Imm64; missing/unknown values stay W64.
- `nk_field_binding` and the original `nh_field_mask`/`ns_scalar` producers stay
  unchanged. They still distinguish only existing W32 mask bits. New Nat
  fields are introduced by the separately authenticated field helper.
- `nf_expand_kinds` keeps a nonflattened parameter's kind; flattened fields
  become W64. No Nat type argument is mistaken for a field fact.
- Phase112 `p112to_nonowning` is the explicit ownership consumer extended to
  Imm64. Its existing `p111_keep` and `p111_partition_step` consumers preserve
  order and skip only the already-trivial retain/release operation.
- Phase113 direct/product candidates carry NC_Binding kinds. Their emitter,
  verifier, self-loop snapshots, caller outslots and runtime operands use U64
  independently of kind. The inliner copies full-width words.
- Phase113 direct-fields `p113df_kind` preserves prior kind on an unset bit;
  on a set bit it introduces the existing authenticated W32 fact. The Nat
  field overlay retains the same validated-mask fallback. Virtual bundle
  refinement has no book argument and is deliberately unchanged.
- Reflected control predicates that match only W32 or Box have wildcard
  fallbacks. Imm64 is not mistaken for either. The older explicit Nat-unknown
  nonowning expectation is superseded, as documented in README.

No new scalar-array fact is introduced: `ns_scalar`/`ns_array_type` remain
unchanged, so a Nat array cannot silently become a 32-bit array through this
profile. No runtime type, word layout, overflow operation, checked telescope,
source evaluator, or native symbol ABI is changed.

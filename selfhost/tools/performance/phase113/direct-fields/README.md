# Preserve the checked match-field certificate

The mature compiler already determines scalar field ownership before erasure.
`nc_erase_mat` specializes the original checked constructor telescope with the
actual ADT arguments, computes `nh_field_mask`, and stores the result in erased
`Mat.qty`. A set bit denotes a canonical U32, F32, Char or Bool field. Erased
fields do not consume live-field positions. Thus the same generic constructor
can carry different facts for `List<U32>` and `List<String>`.

The mature `nc_match_apply_slow_to` consumes that mask through `nc_field_env`
and `nk_field_binding`. The first Phase113 direct/product consumers instead used
`p111_field_env`, discarding it. This candidate restores that existing semantic
plan. It adds no type inference and does not classify a runtime word by its bits
or infer a type from a constructor spelling.

`p113df_field_env` preserves field IDs, names and full U64 words. It changes only
ownership kinds, allowing the existing keep/sink planner to omit operations on
known nonowning fields. Its mask guard requires an erased Mat arity matching the
live field count, at most eight fields, and no out-of-range mask bits. An absent
or malformed certificate leaves the fields unknown.

For a virtual `NQBundle` match, `p113df_bundle_env` consumes the same certificate
only when constructor identity and arity match and all fields are variables.
It refines the existing bindings without changing IDs, words or preexisting
kinds on unset bits. This handles scalar fields returned inside virtual
products without inventing a separate product type analysis. Flat entry
parameters remain unchanged until a checked match supplies their facts.

All physical transport remains full-Term U64, including Bool's accepted packed
representation. A scalar ownership fact does not authorize truncation.
Canonical Nat is deliberately outside the mature scalar mask; the separate
`nat-facts` candidate may extend the shared helper with its own full-width kind.

Composition:

- Append `model.bend` and optionally `controls.bend`.
- For the enhanced scalar profile, apply `overrides-direct.bend` after the
  existing Word adapter. It replaces only `p113dm_original_match`.
- For the product profile, apply `overrides-products.bend` after its Word
  adapter. It replaces `p113pm_original_match` and `p113pl_match`.
- Export `p113_field_control_report`; its 24 reflected-data rows exercise
  masks, field positions, aliases, shadowing, unknown/dependent types, virtual
  product transfer, preservation of names/IDs/kinds, and ownership operations.

`changes.json` records the source origins and exact changed expressions.
Production source admission must bind the selected `nc_erase_mat`,
`nc_tele_fill`, `nh_field_mask`, `nh_field_mask_head`, `ns_scalar`,
`nq_layout_type`, `nc_field_env`, `nk_field_binding`, the unchanged checked
frontend/static preparation, the replacement declarations and the keep/sink
consumer. Caller-supplied raw KTerms or masks are not certificates. These
reflected controls do not establish their provenance; the public compiler
constructs them internally from the authenticated checked request.

The source-only ray09 audit found two `Hit` takes in the complete `trace`
function, whose fields are Bool, F32 and U32. Four keep sites and four sink sites
operate on those scalar fields or their local aliases. This candidate is
expected to remove those eight static helper sites. The remaining Nat ownership
sites are a separate opportunity. This count is a structural prediction, not a
runtime speed claim. Parent-owned source, semantic and matched machine gates
are still required.

At preparation, only delimiter checks and bounded source inspection were run.
No compiler, API, native program or benchmark was executed by this agent.

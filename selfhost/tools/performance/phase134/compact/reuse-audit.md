# Independent owner-reuse source audit

After deferring local-token compression, the coordinator requested this bounded
review of `reuse/owner-v02.bend` against qualified Phase131 source
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
The reuse-source03 manifest adds the probe without overriding parent functions.
No target or checked API was executed by this reviewer.

**Finding:** no missing book dependency was found in the exact recursively
admitted grammar. This is a source review, not a formal proof.

| Boundary | Reason the existing key/grammar covers the inspected dependency |
| --- | --- |
| `p111_entry` / `p111_extend` | Owner name, exact compact body, fresh counter, bang, effective/live arities, native/foreign classification, mapped name and worker kinds reproduce eta selection, entry parameters and naming. |
| `NCall` | `p112s_live_fallback` calls `p111_jump(nm(t),...)` directly. No callee query occurs. `p113n_original_value_kind` classifies it as opaque `N_W64`. Callee changes can affect later program verification, but not these cached instruction bytes. |
| `NOp` | Primitive dispatch and primitive result kind depend on the explicit name, argument count and fixed producer implementation. They do not inspect another book definition. |
| `NNatAdd` / `NNatSum` | Rewrites/constructor helpers are fixed; `Succ` selects the runtime special-constructor kind4, followed by fixed `nat_add`. There is no lookup of a user-defined constructor layout at this already-erased boundary. |
| `App` and beta | Native/callee result-kind queries require a `Ref` head. Recursive admission rejects every `Ref` and `Mat`, including beneath wrappers. `nd_beta` and `nq_layout_subst` rebuild admitted syntax and variables without reading the book or introducing arbitrary globals. |
| Let/binding ownership | `p113_binding` consults environment kinds for variables, fixed kinds for words/operations, and opaque fallback for admitted non-Ref applications. Constructor provenance and matching paths are refused. |
| Wrappers/erased nodes | Recursive admission checks all children, even children ignored by lowering. This is conservative. Exact term equality includes metadata as well as visible syntax. |

Inspected implementations: `p111_entry`, `p111_extend`, `p111_lower`,
`p112_liveness_*`, `p112s_live_fallback`, `p112s_liveness_fallback`,
`p113_binding`, `p113n_original_value_kind`, `p113_application_kind`,
`nd_native_call`, `nd_head`, `nd_beta`, `nq_layout_subst`, and
`p114p_constructor`/`p114p_original_constructor`.

Do not broaden the grammar merely because the current check passes. Admitting
`Ref` would expose `nc_ref_name` to a callee's native classification. An App with
a Ref head also exposes callee result-kind/arity queries that can change
keep/sink behavior while the caller's source body stays identical. `NStatic`
requires prepared-pool identity. Constructors/matches require exact native
provenance and layouts. These are concrete missing-key counterexamples to
future relaxed admission, not bugs in the current refused cases.

The cache is valid only when prior slots were produced by the same fixed
compiler/runtime/policy and are trusted in-process values. A forged slot pairing
a new key with stale, otherwise well-formed code is not authenticated by key
comparison. The existing stale-slot negative control is useful but does not
turn this API into a safe persistent cache. Independent final validation must
still run; symbol IDs and complete program metadata remain fresh.

Suggested additional finite controls, sent to the reuse owner:

- Keep compact body unchanged while changing owner parameter-kind facts or an
  alias that determines them; expect a key miss and fresh-equivalent output.
- Change native/foreign/mapped/typed entry facts; expect a miss.
- Change the definition behind an explicit admitted `NCall`; compare exact
  cached versus fresh lowering, then separately retain final-program validity.
- Refuse `Ref` beneath `Ann` and `Loc`, not just directly beneath a Let.

No claim is made that this saves preparation: compact-body construction,
eligibility scanning and all key queries still run before a hit. The actual
saved work starts at `p111_entry` and must be measured separately from retained
cache memory and complete-request time.

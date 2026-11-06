# One complete verification of the exact renderer view

Source-only candidate; no compiler or generated target was run by its author.
`selfhost/tests/phase169/verifier-single.bend` overrides only the experimental
`p169s_lowered`. Frozen Phase167–169 modules and all production code stay exact.

The original path independently verifies generic/static/adapter obligations,
checks that final workers are private, projects borrowed imports and verifies
every direct body. It then copies only the worker public flags for the renderer
and repeats the complete projection/direct verification. The candidate retains
the original generic/static/adapter gate and private predicate, constructs the
identical `p168v_functions` view, and runs the **unchanged complete**
`p118b_verify_functions` on that view once. Successful emission still uses
`p169s_seeded` with the same original program, nodes, view and live eligibility.

## Why successful view checking is sufficient here

This is a source argument for the private pipeline boundary, not a new formal
compiler proof or a generic public certificate:

1. `p168v_functions` preserves every name, parameter, result, body and function
   order. It changes only flags through the existing actual adapter map.
2. Borrowed projection depends on bodies and actual IDs; it copies the public
   field unchanged. Both forms therefore have identical projection errors and
   identical projected bodies.
3. `p113e_function` uses `public` only to **add** the original-header ABI condition
   at `verify-direct.bend:182`. The schema/body checks are the same. Ready
   signatures retain public metadata, but call/dependency verification reads
   only the common identity/arity/result fields, not this bit.
4. Consequently a successful complete public-view check entails the private
   body's former checks. `p167v_original` still runs on the original private
   program, because its adapter obligations explicitly inspect private flags.
   The separate `p167v_private` predicate is also retained.

Both independent source reviewers found no blocker in this implication or the
implemented sequencing. It does not authorize other body/metadata changes.

## Failure behavior and gates

Public ABI checks can change which error appears first. Therefore any view
verification failure takes a cold path through the exact old `p167ob_final` on
the original program. If that fails, return its original error/prefix; otherwise
return the same old view-error prefix. Original/static errors and preexisting
public workers are rejected before view construction. Lowering errors still
produce empty forwarders and an ended cursor. No failure emits program bytes.

Sixteen pure controls compare complete tiny emitted chunk lists and exact errors
against the original two-check route. They cover valid generic/private/adapter
programs, private/public dependency signatures, public ABI refusal, undefined
locals/calls, missing terminal edges, public input workers, header-before-body
errors, adapter arity, error-prefix priority and lowering refusal. Existing
100 controls remain enabled. These finite controls complement, rather than
replace, exact complete products and native successor qualification.

Prepared with `prepare-native-variants-v3.py --admission --lazy --publication
--single-verify` (plus `--api` for hosted controls):

| Source snapshot | Bytes | SHA256 |
| --- | ---: | --- |
| `single-verify-api-source01/compiler.bend` |1,638,620|`bb75f86c8d32d74c9ce7d44885601b0e82eacc7e57464e1adf632721423e7a2f`|
| `single-verify-native-source01/compiler.bend` |1,509,504|`2e09b0ee2fe5490d925ab78099d342061c81f5ca692706c5af09fb8cbf867632`|

Both lie under `selfhost/build/phase169`; their manifests pin inputs and source
derivations. New control export: `p169sv_controls()`, 16 named `:pass` rows.
No runtime gain is established by source inspection. Root's guarded complete
verifier/checker products and native full request determine whether eliminating
the duplicate pass matters enough to keep this candidate.

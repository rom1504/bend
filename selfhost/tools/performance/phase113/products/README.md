# Structured product ABI

This optional profile carries a proven fixed product as independent owning
U64 Terms across ordinary private functions. It reuses the mature
`product.bend` / `product-layout.bend` shape, telescope, bundle, use-count and
entry planning. It emits `P113DStmt` / `N111Stmt` directly. Neither C output nor
QBE text is parsed to recover semantics.

The checked layout admits one fixed nondependent constructor with one through
eight fields and at most 32 flattened input words. Field values retain full
Term representation. Nested arrays, strings and unknown layouts remain opaque
single Terms. Exact constructor identity matters even for a one-field product.

## Calls and ownership

Private `$product.NAME` variants use `public=False`; the original boxed public
segment remains available. A caller selects the variant only when the mature
signature catalogue and actual virtual bundles agree. Unknown, shared,
escaping or unsupported product shapes retain boxed evaluation and calls.
Candidate dependencies must close through the same direct-worker admission
pass. Non-tail self calls and unresolved cycles fall back.

A one-word result returns one owning Term. A two-through-eight-word result
receives a caller-owned output pointer after `state`, writes all owning fields,
and returns status zero. The direct emitter validates the vector width and
loads every result before another call can reuse its result area. There is no
C aggregate return ABI.

Virtual-shell binding requires both maximum and minimum use counts to be one.
The lowerer preserves pre-evaluation keeps, fresh independent field bindings,
field consumption, and ordinary boxing at representation boundaries. Local
vector assignments and self-loop arguments use simultaneous snapshots before
rebinding. These are checked-source lowering invariants; arbitrary raw KTerm
shape records or machine graphs are not ownership certificates.

The first implementation refuses specialized Word matches until the direct
Word recovery path is composed explicitly. Applied `Efq` fails before argument
evaluation, matching the existing callee-first CPU fail-stop path. The
unreachable result has the target's declared width.

## Array pair import

`p113_rt_array_pair` is runtime profile 11301, using unchanged state ABI 11101.
It admits only the existing primitive IDs 72/get, 74/swap, 75/size and 76/clone.
It validates exact input and output counts and non-null buffers before work,
snapshots inputs before output stores, and invokes the same array operations
as the boxed primitive path. It omits only the temporary Tuple carrier.

The array and returned value remain separate owning Terms. `get` retains the
element; `swap` transfers the previous element and consumes its replacement;
`size` returns an immediate; `clone` returns the independently owned block
copy. Shared array handles retain the existing mutable, aliased behavior.
This does not claim equality of allocator addresses or wrapper allocation.

The import returns zero on success. Invalid metadata follows the pinned CPU
fail-stop path; there is no partially valid vector or nonzero-success path.
The helper does not write dispatcher frames, `rn`, `next` or register banks.
The machine verifier additionally checks actual local buffer capacities and
excludes state pointers as input or output buffers.

## Composition

Append after the direct model and core helpers:

1. `model.bend`, `layout.bend`, `array.bend`, `controls.bend`
2. `lower-helpers.bend`, `lower.bend`, `plan.bend`
3. `diagnose.bend`, after `direct/diagnose.bend`

Apply `entry.bend` as the exact replacement of `p113d_lower_request` and
`p113d_inspect_request`. Do not also apply the duplicate request hook in
`direct/overrides-products.bend`. The diagnostic uses the same prepared book,
signatures and candidates as product lowering.

Compose the direct emitter normally, then its optional
`direct-emit/products.bend` override. The facts companion may additionally
replace `p113pl_bind_boxed` using `overrides-facts.bend`; it uses the existing
qualified `p113_binding` classifier.

The optional enhanced adapters preserve the scalar profile's recovered Word
patterns, guarded known selectors and cached suffix liveness. Append
`word-original.bend`, `word.bend`, `selector-original.bend`, `selectors.bend`,
and `liveness.bend`, then apply `overrides-word.bend`,
`overrides-selectors.bend`, and `overrides-liveness.bend`. With checked facts,
also apply `overrides-liveness-facts.bend`. These adapters retain the original
vector target; they do not cast it to a scalar destination. Their semantic
recognizers remain `nw_walk` / `p112m_plan_rows`, `nbc_definition` /
`p112b_guard`, and `p112_liveness_terms`.

The liveness consumer keeps cached suffix use sets for boxed bindings. A known
flat shape reconstructs normalized let syntax only to run the mature min/max
use guard and bundle substitution. The substituted suffix then receives a
fresh liveness plan. This avoids rescanning every ordinary scalar-let suffix.
Reconstruction assumes checked, erased single-child Bind syntax. It does not
preserve extra children or quantity metadata forged into raw reflected
`P112Liveness` records; those records are not source admission certificates.

Useful exports are `p113pl_lower_request`, `p113pl_inspect_request`,
`p113p_control_report`, `p113p_array_call`, `p113pl_boxed_candidate`,
`p113pl_flat_candidate`, and `p113pl_candidates`. The current product control
report has 20 named shape/import/width/refusal checks.

## Runtime preparation and qualification

`materialize-runtime.py` creates a fresh capsule containing the exact
authenticated runtime04 prefix plus the new export and header declaration.
It leaves historical runtime sources and objects untouched. Root builds it
under the serial target guard:

```sh
python3 selfhost/tools/performance/phase113/products/build-runtime.py \
  --runtime selfhost/build/phase113/runtime-products01 \
  --out selfhost/build/phase113/runtime-products-build01
```

The builder authenticates every source-capsule input/output, pins GCC and the
command, refuses existing outputs, and records the resulting object. Flags
are `-O2 -std=gnu11 -ffp-contract=off`.

Root completed `runtime-products-build01` and
`runtime-controls03/report.json`: all 18 independent array observations
passed, covering boxed/flat exact values, Unicode elements, input/output
overlap, clone and actual shared-handle release orders, and invalid-metadata
fail-stop behavior. The earlier two setup attempts did not execute a target.
This qualifies the runtime adapter boundary, not the complete product compiler.
Product source/API, machine-verifier refusals and end-to-end source controls
remain separate gates; no product performance result is claimed here.

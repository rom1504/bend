# Phase113 early scalar result facts

`value.bend` exports `p113_value_kind(book,value,env)` and
`p113_binding(book,id,value,env)`. They preserve `nk_value`'s exact `Var` lookup,
first-binding shadowing, `N_Box`, and `NWord` behavior. There is no global
`nk_value` override. The direct lowerer may use the new binding helper at its
local result destination. `overrides.bend` optionally replaces four generic
lowering declarations; their sole change is the producer of the result binding.
In particular, both continuation cuts now preserve the result fact instead of
creating an opaque `nc_binding(id)`.

The finite primitive whitelist has 60 exact names whose runtime results are
U32, F32, or Bool. It requires the mature primitive arity. Ordinary primitive
applications additionally pass `nd_native_call`: original builtin declaration,
recognized intrinsic, exact saturation, and no quantity-3 reference. Generated
`NOp` nodes are accepted only within the authenticated compiler pipeline; a
caller-created raw `KTerm` is not a certificate. Ordering comparisons, Nat
results, String/read results, tuples, every array operation, and unknown names
stay opaque. This metadata does not skip evaluation or consume fewer inputs.

Ordinary calls require a `Ref` head, an existing non-native, non-foreign `Def`,
exact direct arity, and a bounded traversal of its original checked telescope.
Every crossed binder must be absent from its codomain. Erased independent
binders do not consume runtime arguments. The fully consumed result must pass
the mature `nf_scalar_kind` test for an original canonical builtin
U32/F32/Bool/Char type. Unknown, dependent, partial, excess-argument, and
quantity-3 calls retain `N_W64`. Internal `NCall` symbols are deliberately not
reverse-mapped to original names. No theorem about an arbitrary supplied book
or forged binding record is claimed; the existing checked-source admission
remains necessary.

`N_W32` is reused here only as existing nonowning metadata. Physical arguments,
results, captures, and runtime scratch words remain U64 Terms. Packed Bool and
other metadata bits are preserved; this does not authorize narrowing, IEEE NaN
payload rewrites, or floating-point identities. Captured input ownership, keeps
before a call, call order, destination spelling, continuations, and error paths
are unchanged by the optional overrides. Existing Phase112 typed-ownership
keep/partition overrides are the consumers of this result metadata.

`controls.bend` exports `p113_fact_control_report()` with explicit expected
classifications and retained/elided ownership operations. These are finite
refusal controls, not a universal ownership proof. They cover primitive arity,
name/builtin authentication, excluded allocating/category results, callee
canonical type/dependence/saturation, unknown names, shadowing, and U64 binding
identity. Controls require the Phase112 typed-ownership keep/partition overlay.
The reflected books test helper behavior; the original compiler checker is
still the authority for well-typed program books.

Composition: append `value.bend` and (for the test API) `controls.bend`; optionally
replace the four declarations named by `overrides.json` with `overrides.bend`.
The direct lowerer owns its separate opt-in edit. Preserve all original verifier
declarations. Export `p113_fact_control_report` for the root's guarded check.
No compiler, native target, benchmark, or reflected control was run by the facts
agent. `inventory.json` records the exact source snapshot and dependencies.

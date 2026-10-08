# Reuse native let occurrence summaries locally

Use the existing exact U32-ID summary as an ordinary local value. The body index
depends only on the body term. `nc_let_atom`, `nc_let_emitted`, `nc_let_cut` and
`nf_bind` can share it between filtering outer bindings, preparing the body
environment and emitting ownership keeps. No global cache or AST annotation is
needed.

Let `U` be the body's occurrence index, `E` the incoming ordered environment,
and `L(E,U)` its existing duplicate-preserving filter. The existing code lowers
the body with `L(E,U) ++ [binder]`, then prepares that environment using another
copy of U. Pass the original U to the same partition instead. This retains the
binder's drop when its ID is absent, and every ordering/duplicate decision.

Value sharing filters the incoming environment by the value, then emits a keep
for each remaining row in U. This is the existing intersection algorithm with
the already computed body index. For cuts and flat binds, save that filtered
value environment once. Every row in it is live in the value, so entering
`nc_lower_live_to` skips only a partition whose drop string is empty; nested
lowering continues to use ordinary preparation as before.

Body collection remains demanded even for an empty incoming environment: the
original body-lowering environment always appended one binder. Value collection
still skips empty environments. The atom error fallback still performs its
original rest lowering before the fallback; this experiment does not reorder
that behavior. Raw finite malformed terms retain the current summary policy,
including ignoring children on Var nodes.

This removes immediate duplicate work, not all overlapping suffix traversal in
nested lets. Propagating suffix summaries deeper is a later hypothesis. Do not
apply the same substitution blindly to product lowering: its substituted body
and original source body can have different occurrence sets.

The isolated proposal is recorded under
`selfhost/tools/performance/phase68/compilation/occurrence-reuse/`. Selection
requires actual helper equality, exact complete C, and measured B1/B2 requests.

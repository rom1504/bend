# Independent bounded review of borrowed scalar calls

Reviewed the Stage1 direction in
[`borrowed-tags.md`](../../../../../implementation/phase99/borrowed-tags.md)
against Phase98 source
`2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051`.
This is a source review of a design, not acceptance of an implementation or a
native safety result. No targets or builds were run by this reviewer.

The bounded lane is coherent if the following requirements remain explicit:

1. **Internal admission certificate.** Publish a registry record only after
   `no_route_pair` has admitted both private worker and adapter with fresh private
   names. The record needs the owner, private worker, ordered parameter kinds,
   root slots, scalar observation type and successful schema. Neither a ready
   name, source-defined KDef marker nor a supplied raw book is authority. Keep
   the checked permission gate around the complete registry construction.
2. **Exact types within the existing lane.** `nol_param_type` stores parameters
   as `var(nm(ty), id)` and `no_root_types` stores `ref(nm(p))`; these lose type
   arguments. Their name identity is sound here only because `nol_root_specs`
   and `nol_scalar` require plain, argument-free types. Preserve those checks,
   the dependent-type refusal, one/two roots and four-argument limit. Applied or
   opaque aggregate support must not inherit this registry identity implicitly.
3. **Per-actual lifetime.** Each root actual must be a concrete `OA` runtime atom
   of the expected supported type, with origin below a still-owned caller entry
   root. The caller root need not occupy the same ordinal slot as the callee
   parameter. Two actuals may borrow one root, but this does not merge or remove
   owned handles. Keep the original root alive through all synchronous calls,
   including calls from a loop iteration. Preserve the lazy `noa_below` guard.
4. **No borrowed result escape.** Register only scalar-return schemas at this
   stage. Give each call result a fresh opaque observation origin, never the
   origin of an input or projected field. Reject child/shell/closure returns,
   ordinary consuming calls, foreign calls and parallel/bang work. `nol_scalar`
   includes Nat: retain full `Term` result storage rather than assuming every
   scalar is 32-bit. Scalar permission and observer permission are distinct.
5. **Direct borrowed-worker ABI.** Emit a call to the certified private worker,
   never its adapter or ordinary owning owner. Validate saturation, fresh result
   binding and every argument; add the private worker to `NC_Code` dependencies
   so `nf_admit` sees it. Preserve strict argument demand, success return and
   existing `seq`/error checks. Never read the result array after a failed call.
6. **Owned wrapper and fallback remain.** For `p88_string_eq`, symbolic
   expansion may inline `p98_eq_finish` and omit its drops inside a borrowed
   worker only because the outer owning adapter still performs the original
   root cleanup after the read. Keep the ordinary worker and unique-root route.
   Do not implement the optimization by redirecting the borrowed call through
   the owning adapter; that would consume borrowed inputs.
7. **Bounded acyclic admission.** Callees must already be certified. Retry only
   unresolved owners, skip successful owners to prevent repeated redirects,
   and bound retries/chain depth. Source order may affect which optimization is
   selected when the bound is exhausted; it must never reject a valid ordinary
   program or authorize a cycle. Self recursion remains governed by the existing
   structural cursor and `NO_Loop` tail-result obligations.

The cheapest decisive positive is the real public String equality wrapper with
shared roots: its new borrowed worker must call the existing equality borrow
worker directly without a keep/drop boundary, and outer adapter cleanup must
follow the last read. Complete results and both retained aliases must match for
equal, first-difference and suffix-difference inputs. Include same-root actuals,
unique-root fallback and reversed declaration order. Registry forgery, a wrong
root type, a foreign/owning call and an escaping child must refuse only the
observer route. Existing origin and alias controls remain useful; this review
adds no new abstract law suite and claims no native RC theorem.

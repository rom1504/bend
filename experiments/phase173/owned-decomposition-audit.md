# Phase173: independent audit of early owned decomposition

Status: design/semantic audit for an experimental transformation. No target
execution or production edit by this reviewer. Implementation review and native
gates remain separate. The implementation is owned by `p172_shared_lowering`;
bounded structural helper summaries are owned by `ambitious_architecture_review`.

The proposed rewrite changes an erased, compacted computation of the form
`setter(root, F(getter(root), args))` into an exhaustive ordinary match on `root`,
followed by the same child computation and reconstruction. It runs before
ownership/liveness analysis. Its purpose is to release an owned parent before
recursing through a child, allowing ordinary runtime ownership rules to avoid
unnecessary sharing. It must not assume uniqueness or invent a private runtime
mutation path.

## Source facts behind the experiment

`selfhost/src/front/elaborate.bend:f_pattern_sub` currently passes `t` both to
`ks(t)` and to `k_with_children(t, ...)`. `ks` returns a child field for KTerm and
KLambda, but a constant empty list for KLiteral. `k_with_children` reconstructs
the first two variants and returns the original KLiteral unchanged. All other
fields, including source spans and KLambda's `present` flag, are significant.

`selfhost/src/back/native/product-layout.bend:nq_layout_subst` has an additional
semantic boundary: a Var miss returns the whole original term without descending
into its children. `f_pattern_sub` descends on a Var miss. An automatic pass must
operate inside the original branch, preserving this difference; it must not
hoist a child traversal outside either function's guard.

The measured manual source variants are performance ceilings for those exact
algorithms. Their omission of empty-list work in literal branches is not a
general license to omit an arbitrary worker `F`.

## Admission and semantic obligations

| Boundary | Required invariant |
| --- | --- |
| Root expression | Initially require the same variable ID at getter and setter sites. Do not duplicate, drop or reorder evaluation of an arbitrary root-producing expression. |
| Helper summaries | Inspect the actual checked definitions. Require exhaustive, pure projection/closed-constant getter branches and exact reconstruction/identity setter branches. Names alone are not evidence. |
| Saturation | Account for erased versus live arity and exact parameter positions. Refuse partial application, unknown dynamic callees, unsupported constructors and unmatched getter/setter families. |
| Worker evaluation | Evaluate the original worker once per selected variant, at the same argument position/order. An identity setter branch must still evaluate and drop the computed replacement. |
| Outer control | Transform only the original selected region. Preserve surrounding branch guards and their lazy closure semantics. |
| Internal root uses | Conservatively refuse another occurrence of the root in the worker or its remaining argument expressions. Hidden alias values must retain ordinary shared ownership behavior. |
| Outer root uses | A root live after the region is not unique. Recompute liveness after rewriting so ordinary keeps/takes preserve that alias. No claimed unique-parent fast path applies. |
| Fields and variants | Preserve the exact constructor and every untouched field, including explicit/legacy variants, metadata, flags and unknown string payloads. |
| Fresh bindings | Avoid every existing binder/occurrence ID, preserve shadowing, reserve enough IDs without overflow, and respect subsequent native-ID allocation conventions. Refuse if freshness cannot be established. |
| Errors/effects | Do not remove a worker merely because its result is ignored. Getter/setter summaries must introduce no calls, partial matches or hidden effects when moved. |
| Ownership/publication | Use existing matched-field ownership and generic takes. Aliasing, publication, cleanup and backend ABI remain governed by the selected compiler/runtime. |
| Integration | Transform a durable shared prepared body before direct and generic liveness; do not make their semantic inputs disagree or reuse stale cached facts. |

An ignored-result branch must either retain the exact original computation or
contain an explicit strict binding of the worker call before returning the
original variant. The current design chooses the former: only reconstructing
variants are rewritten, and identity/unknown variants enter an alpha-renamed
copy of the original expression. The current direct lowering
in `flat-products.bend:p113pl_bind_boxed`, `p113pl_bind_flat` and `p113px_*`
lowers the bound expression before the body, even when liveness later drops the
result. The generic-path equivalent and the chosen erased binding constructor
must be checked during implementation review; an unused source binding is not
automatically a proof that effects are preserved.

The fallback rename must be structural and capture-avoiding. Ordinary core
`subst` is not automatically suitable: the documented `core_rebuild` behavior
can beta-reduce applications while traversing a term. Renaming must not reduce
unrelated applications or erase their eager arguments. Freshness must cover
binders and occurrences, not only free-variable use sets.

Taking a shared parent before recursion can be semantically correct but fail to
improve performance. That is a profitability outcome, not a reason to relax the
ordinary ownership behavior.

## Bounded adversarial controls

Use complete values from the unchanged compiler as oracle. At the structural
plan boundary, retain exact unchanged terms for every rejected case.

1. Both reconstructing variants and an identity variant with a default getter.
   Include arbitrary payloads, spans, removed-name lists and both Lambda flags.
2. A literal/identity variant whose worker result is ignored. Verify the worker
   remains in a strict call/binding in transformed IR. Use an ordinary effectful
   fixture when representable, rather than inferring preservation from final
   values alone.
3. Var hit and miss, each with a nonempty child list. The two real substitution
   algorithms have different miss behavior and must keep it.
4. An outer live root used after the transformed computation; an alias stored in
   another variable; a child shared with a separate value. Compare every value.
5. Different getter/setter root IDs, an effectful root producer, a root reference
   inside worker arguments, and an unknown/partial worker: reject conservatively.
6. A getter branch that calls another function, a partial getter match, a setter
   that changes another field, or a mismatched constructor family: reject.
7. Nested bindings/closures using the same source names, high numeric IDs, and
   an exhausted fresh-ID range. Prove no capture through full structural output
   and independent verification; exhaustion must keep the original term.
8. Multiple ordered worker arguments and nested calls. Preserve their sequence
   exactly; introducing a match does not authorize reordering effectful work.

The strongest small positive control is the actual compiler substitution body
with complete-value cases, followed by a structurally unrelated record/list
rebuild. The independent source/IR/runtime gates remain in place. A successful
summary checker is an executable admission condition, not a BendTT theorem or
an end-to-end correctness proof.

## First implementation review

Actual captured erased helpers use direct `Mat` chains, with field lambdas and
per-branch replacement lambdas; they do not necessarily retain explicit outer
root lambdas. The summary checker now handles that observed shape as well as
the explicit form. It proves positional reconstruction before normalizing a
branch's replacement ID. This normalization only touches direct constructor
arguments already established to be original fields or the sole replacement.
All fields exclude the normalized replacement ID. No arbitrary term rewriting
is hidden inside the summary.

The initial gate is deliberately narrow: ordinary closed, non-native Data
constructors, at most eight variants and sixteen live fields, no erased fields,
and at most 32 nodes in a closed constant getter. Constructor identity, width,
mask and branch order must agree between helpers. Ignored replacement branches
remain original fallbacks.

Review caused two concrete safeguards:

- Freshness includes helper field/root/replacement IDs as well as target-body
  IDs. Sequential substitution would otherwise collapse fields if a newly
  assigned ID overlapped an old helper ID. The integration seeds from the
  immutable checked book's bound and threads fresh IDs globally.
- New field and fallback-root lambdas use quantity 2, and summary field lambdas
  must have that quantity. A field can be observed and retained, and the fallback
  root appears in both getter and setter. Quantity 1 would misstate that usage
  even if a later liveness pass happened to recover the required copies.

The initial experiment also adds one whole-request no-foreign gate over the
existing complete reachable-name set. Existing observer-permission predicates
are not purity proofs: they explicitly admit IO and File providers. Therefore
this first scope covers pure extracted compiler workloads and defers effectful
native compiler CLI requests. A broader effect contract is a separate step.

`owned-decomposition-controls.bend` supplies 16 independent structural controls.
Its literal expected graph exercises reading a field that is also retained while
replacing another field, constant getters, untouched identity fallback, strict
result binding and fresh IDs. Its exact comparison augments `norm_exact` with
source spans, the physical KTerm/KLambda/KLiteral variant and Lambda's syntax
flag. It also checks refusal boundaries and that alpha-renaming does not reduce
an existing application. These synthetic summaries test construction; they do
not replace admission against actual checked helper definitions.

The `<4e9` fresh-ID restriction reserves substantial space from the downward
native allocator. This review does not establish separation for arbitrarily
large generic builds whose native fresh counter is cumulative. The bounded
experiment and unchanged final verification remain the qualification scope;
avoid claiming a new general allocator theorem.

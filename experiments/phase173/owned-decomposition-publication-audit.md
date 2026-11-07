# Automatic08 publication reaches private lowering

This source/machine audit tests a specific explanation for weak full-compiler
transfer: perhaps the new pass changes only generic bodies while direct/private
workers keep reading an older body cache. No compiler targets were run and no
source was changed.

**The simple stale-body hypothesis is false on the selected path.** Both
ordinary and product private candidate construction read the newly published
prepared-body index. The fact that all 2,337 `p113d` declarations stayed byte
identical is not proof that semantic facts were lost.

## Exact evidence

The subject is the same frozen source as
[`owned-decomposition-scalability.md`](owned-decomposition-scalability.md):
`selfhost/build/phase173/owned-native-source08/compiler.bend`, SHA-256
`8536e598ee618e401fafed82e9e75f0d32e13c697a13ddbd5f2de23639e6c3c6`.
Line numbers below refer to that file.

The machine comparison is
`selfhost/build/phase173/owned-generation-diff09/report.json`, comparing identical
compiler source built by the old qualified producer versus automatic08 N1.
It records 2,337 identical `p113d` functions, zero changed/added/removed in that
family, and a net 14 functions / 85,740 QBE bytes added overall. Continuation
symbol renumbering accounts for many apparent added/removed declarations; raw
symbol counts alone are not semantic work counts.

## The actual data path

1. `p168_catalogued` (67157) invokes `p112s_prepare` once, then gives its result
   to `p173op_prepared`.
2. `p173oa_definitions` (69754) rewrites selected `NativeStaticBody` values in a
   new body index. `p173oa_publish` (69786) replaces the first child of the
   existing `NativeStaticContext`, retaining its other metadata and raising the
   BookCache bound for generated IDs. The source definition index remains
   original intentionally: source/type evidence and erased optimization bodies
   are different objects.
3. `p168_prepared` (67139) binds the **published** book. This same value goes to
   `p128br_scan`, `p168_seed_verified`, `p168_selected` and the scalar/direct
   candidate pipeline. There is no re-attachment of the old body index between
   those points.
4. `p168_selected` (67104) computes `nq_signatures(book, names)` and calls
   `p113pl_candidates` with that same book.
5. Boxed private lowering reaches `p126s_original_candidate`; ordinary direct
   construction `p113d_candidate` (44351) and flat product construction
   `p113pl_flat_entry` (45732) obtain the body through
   `nc_compact_definition(book, lookup(book,name), ...)`.
6. `nc_compact_definition` (35268) calls `ns_body` and immediately returns
   `dv(fact)` when it finds `NativeStaticBody`. `ns_body` (35639) queries the
   published index. The original KDef supplied to the call does **not** force
   the original body to be used.

Some specialized recognizers intentionally inspect the original source
`dv(lookup(book,name))`, for example `p121f_plan` and `p125p_select`. They prove
particular source patterns. This is not evidence that the ordinary private
body lowerer bypasses the new facts. Moving all source recognizers to erased
terms would change their contracts and is not a harmless cache fix.

## The transformed compiler workloads have no private workers

A streaming inspection of actual N2 `program.ssa` found the following exact
identities for each of the seven source-compatible recursive-parent functions:

| Source owner | p112w wrapper | p111 source / `$direct` routes | p113d worker |
| --- | --- | --- | --- |
| `env_subst_term` | present | both present | absent |
| `f_sub` | present | both present | absent |
| `f_pattern_sub` | present | both present | absent |
| `nw_restore_children` | present | both present | absent |
| `nq_layout_subst` | present | both present | absent |
| `nc_compact_ctor` | present | both present | absent |
| `nc_compact_plain` | present | both present | absent |

Here the prefix is significant. A `p111` function whose decoded identity is
`$direct.f_pattern_sub` is still a generic backend route; its name is not
evidence that a verified `p113d` native worker was admitted.

The new optimization can remove ownership work inside these generic
computations while leaving the unrelated admitted private workers completely
unchanged. That matches the observed declaration comparison.

## Concrete existing admission barrier: recursive tree traversal

`f_pattern_sub` calls `f_pattern_subs(ks(t), id, value)` and then reconstructs the
parent. The child-list function (13409) is:

```text
Con{head, rest} => Con{f_pattern_sub(head,id,value),
                     f_pattern_subs(rest,id,value)}
```

`nq_layout_subst` / `nq_layout_subst_list` have the same structure (33490/33497).
These are cyclic traversals with **work after recursive calls**, not simply a
tail-recursive state machine. Owned decomposition improves the parent update;
it does not turn the child traversal into a bounded-stack native loop.

The ordinary direct self-call rule (`p113d_call`, 44220) explicitly rejects a
non-tail self-call. The selected boxed/product rule
`p118t_original_call_result` (50731) requires both a tail target and equal result
shape; otherwise it returns `product non-tail self call`. The TRMC retry
(`p118t_retry`, 50871) can address a subset of self-recursive construction, so
that first error alone is **not** a complete final refusal explanation.
However, it does not by itself eliminate the mutually recursive
parent/list-call dependency: the parent waits for the child result before
constructing its result, and the list worker invokes the parent on an element.
The ordinary readiness closure (`p113d_deps`, 44383) requires ready callees;
the bounded existing SCC fusion uses exact tail transfer, not arbitrary
non-tail return continuations.

In addition, `nq_layout_single` (33371) requires a single-constructor product.
KTerm and List are multi-constructor recursive values. Their ordinary return
values therefore remain opaque, rather than automatically becoming flat
product state. A constructor-result type alone is not sufficient to establish
a flat private ABI.

These are concrete source-level obstacles and agree with the absent machine
workers. No fresh candidate diagnostic was executed, so this report does not
claim a particular final raw error for every member after all retries. The
precise final error chain could be inspected if a future experiment targets
this boundary; it is unnecessary to reject the stale-cache hypothesis.

## Recommendation

**Do not move the publication hook to fix this result.** The intended earlier
publication already reaches both generic and private lowering. Changing the
request's source index or moving before static preparation would introduce
real obligations—erasure/static-body invalidation, constructor/static-data
references, dependency facts, fresh bounds and independent checking—without
addressing the observed admission limitation.

The useful architectural hypothesis is instead a stack-safe complete recursive
computation: preserve decomposed parent fields while the child traversal runs,
then resume reconstruction without repeated generic scheduling/boxing.
Prove its value on an extracted real parent/list traversal before generalizing.
That would add an optimization capability, whereas moving an already-visible
body between caches would only rearrange work.

This does not predict a full-compiler gain. The current kernel improvements,
new pass cost and native request result must remain separately reported.

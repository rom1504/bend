# Automatic early owned-record decomposition

Experimental design, before implementation. Root's new complete consuming-source
screens improve pattern traversal20.1% and layout substitution20.78%. Allocations
hardly change in the pattern case; large reductions in keep/sink/drop traffic
identify shorter ownership lifetimes as the mechanism. These are two real
consumer results, not a full-compiler prediction.

## Selected transformation

Recognize the composition of a structurally authenticated pure getter and setter:

```
setter(root, F(getter(root), other_arguments))
```

For each exact constructor variant, use the existing consuming match to bind
ordinary owned fields, execute the same `F` call on the selected field, then
construct the setter's exact result. The first candidate requires `root` to be
a variable and no other occurrence of that variable in the rewritten region.
Getters/setters are recognized from checked erased bodies, never their names.
Initially support one changed field, bounded constructors/branches and saturated
calls. Unsupported/malformed plans return the original term unchanged.

This uses normal Data ownership. Shared roots get ordinary shared `take`
behavior; unique roots transfer their fields. It needs no uniqueness promise,
retained parent, heap hole, new runtime entry, or custom calling convention.

## Existing IR boundary

Implement on erased/compacted `KTerm`, before direct or generic liveness/ownership
lowering. A single prepared-body rewrite must feed both paths. That boundary
retains function application identities, constructor matches and field binders;
the existing lowering then regenerates keeps, sinks, argument ownership and
stack-safe continuation frames. Postverification `P113DStmt` is too late for the
first experiment: it has already committed to root retention and can miss the
generic recursive path entirely.

The prototype will wrap one preparation boundary and publish only changed
`NativeStaticBody` facts, preserving source/erased facts, static tables,
constructor identities, complete independent final verification and the original
fallback. Exact placement and fresh-ID threading will be documented with the
implementation. This is a source-semantic optimizer extension; the old final
verifier does not itself prove the rewrite equivalent.

## Summaries and obligations

Getter summary: per constructor, return exactly a field or a closed pure constant.
Setter summary: per constructor, reconstruct that same constructor with preserved
fields and the replacement argument, or return the unchanged root. Require
complete field/order/layout information, exact parameter provenance, and pure
closed bounded helper bodies. The existing terminal-record `P173BPlan` demonstrates
field-origin analysis, but is not sufficient authority for source-level matching.

Do not elide eager work in variants whose setter ignores the replacement. The
new branch must still evaluate `F(default, args)` exactly once, then discard its
result before returning the original value. Keep existing outer guards and call
argument order. Do not move the match across an effect, unknown helper or source
branch. External aliases remain legal through normal ownership lowering.

Fresh IDs must be disjoint from every input binder/reference and downstream
descending `nc_id` temporaries; refuse exhaustion before publication. Copied
helper branch binders must be alpha-renamed. The transformed body must preserve
the original call graph except eliminated getter/setter edges and must introduce
no untracked function or constructor dependency.

## Gates and scope

1. Independent helper-summary audit and finite positive/refusal controls.
2. Complete transformed-tree controls, including root reuse, ignored variants,
   aliasing, field permutations, incorrect arities, foreign/effectful helpers,
   fresh-ID collisions and ordered nontrivial arguments.
3. Actual unchanged `f_pattern_sub` source plus an unrelated owned-record
   computation compiled through the new pass. Retain independent full-value
   oracles and an authenticated bounded digest. Inspect admission and generated
   ownership operations before timing.
4. Existing final verifier, native output and balanced complete-consumer timing.
   Stop for poor coverage or neutral runtime. No full image before material
   transfer evidence. Charge pass time and code growth separately.

No production compiler or installed selection changes in this experiment.

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

Implementation refinement: identity-setter variants will not be decomposed.
Their match fallthrough executes the exact original expression, with its root
alpha-renamed to the fallback lambda argument. This preserves eager `F` work and
the original no-reconstruction behavior without requiring a new constructor.
Only structurally proved replacement branches receive the early consuming take.

## Implemented prototype, awaiting execution gates

The implementation consists of the checked-Bend experimental modules
`owned-decomposition-summary.bend`, `owned-decomposition.bend` and a single
`owned-decomposition-entry.bend` override of `p112s_prepare`. The override calls
the original static-preparation algorithm unchanged, then replaces changed
`NativeStaticBody` entries in its existing index. Original checked definitions,
prior erased facts, constructor metadata and static-image entries remain intact.
All subsequent direct/generic lowering and final verification are unchanged.

The actual captured compiler bodies are important: `ks` and `k_with_children`
are top-level erased `Mat` chains. Each setter branch places its replacement
lambda after its constructor-field lambdas. The summary normalizes those
different replacement IDs to one authenticated ID, retaining positional field
provenance. It supports that actual shape rather than assuming every function
begins with a root lambda. Summaries read cached erased bodies without an extra
literal-compaction pass. Current restrictions include ordinary nonparametric
Data constructors, quantity2 field binders,8 variants and16 fields.

Fresh IDs start above the original whole-book bound, are threaded across all
rewritten bodies, and remain below the backend's existing4,000,000,000 source-ID
boundary. Each successful candidate additionally checks all original candidate
and summary IDs before sequential structural renaming. The generated matcher
uses quantity2 field/fallback lambdas and a strict quantity1 result binding.
This uses the existing bounded native temporary convention; the numeric boundary
alone is not a new proof against arbitrarily many downstream temporaries.

The initial whole-request gate refuses every reachable foreign/unknown
definition. This admits the pure extracted workloads and conservatively skips
the complete File/IO compiler executable. Existing observer permission allows
trusted IO and therefore cannot be called a purity proof. Generalizing the effect
scope is a later qualification question, not silently included here.

The independent structural module contains16 controls, including an exact full
graph, ignored variants, same-field sharing, field/helper/fresh-ID collisions,
effectful extra arguments, span preservation and absence of beta reduction.
The unrelated `owned-decomposition-workload.bend` exercises packet updates,
retained parent aliases and shared children; its separate digest main performs
10,000 updates over128 list elements. These are prepared controls, not claimed
passing results until the root's checked execution completes.

The automatic first slice remains inside the original `f_pattern_sub` branch.
It preserves its preceding predicate getter calls, whereas the manual consuming
source screen decomposes before that predicate. Therefore the manual20.1% result
is useful motivation, not an automatic-pass speed prediction.

## Observation adapter and expected coverage

`owned-decomposition-observe.mjs` authenticates the checked API, frozen source
assembly, Base carrier and exact engine before calling the16 controls. Its
inspection mode checks the three explicit frozen source files through `p86_plan`
and calls `p173oa_inspect_request`; every admission and rewrite remains in Bend.
It preserves the returned owner/row counts and complete bounded helper summaries,
including refusals. Inspection clocks are diagnostic and do not include native
machine construction or execution. The adapter was prepared without executing
any target. A local Node syntax check was unavailable because `node` is absent;
root's pinned Bun invocation remains the execution gate.

Expected, still unmeasured admission:

- `f_pattern_sub`: two changed KTerm/KLambda branches; literal variant uses the
  old expression. Predicate getter calls stay. Other compatible compositions in
  its reachable closure may appear and must be reported, not presumed.
- `nq_layout_subst`: the principal `k_rebuild` call remains refused because it
  has eight live arguments. This negative transfer is intentional in the first
  two-argument-setter slice; no claim that seven syntactic replacement arguments
  imply seven semantically changed fields.
- Packet user program: one changed packet branch and the unchanged vacant
  fallback, if its actual checked catalogue satisfies the ordinary Data gate.
- File/IO compiler executable: whole-request foreign gate refuses all rewriting.

On the selected prepared request, `p173od_pair` calls `nc_definition`, whose
`NativeErasedBody` fact lookup returns the already erased body. It does not erase
or compact helpers anew. Repeated work consists of indexed definition/fact
lookups, the bounded structural summary and constructor-telescope validation.
The main additional cost may instead be `p173oa_walk`: it visits each prepared
body, builds result records and child lists even when no descendant changes,
then returns the original term on zero hits. No elapsed attribution yet supports
calling summary recomputation the bottleneck. Do not add a summary cache or
broaden the pass before measuring admitted sites, complete lowering cost and
actual ownership traffic on these first workloads.

No production compiler or installed selection changes in this experiment.

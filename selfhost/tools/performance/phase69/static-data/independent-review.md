# Independent review of immutable native constructor images

Source/data review only: this lane ran no Bend compiler, Node, Clang or native
target. Root owns all execution evidence and promotion. Review covered the
proposed `static.bend` and integration edits, including worker/product paths,
the existing `STAT_IMG` runtime and raw BookCache lookup semantics.

## Issues found and corrected before integration

The initial proposal reused three existing native helper names (`ns_scalar`,
`ns_term`, `ns_terms`) with different arities. The owner renamed the proposed
helpers to `ns_static_scalar`, `ns_static_term`, `ns_static_terms` and checked
definition/type names against production source.

More substantially, creating a new `book_cached` wrapper around any plain list
changes public raw lookup when that list contains an interior BookCache. Given
`[main -> foo, cache(index foo = 7), trailing foo = 9]`, original lookup delegates
to the interior cache and returns 7. Reindexing every list element would select
the trailing 9. The corrected `ns_source` retains such lists unchanged and
`ns_prepare` declines unless there is a proper cache at the head. This preserves
the original lookup boundary rather than guessing which declaration list is
authoritative. `raw-review-cases.mjs` includes this exact counterexample.

The owner also changed eager predicates to lazy tag gates and indexed known
constructor arities once. These are compilation-cost improvements; this review
does not claim measured compilation gains.

## Representation and lifetime checks

The current proposal accepts only known constructor identities with exact
erased arity and already-proven constant children. NWord text must parse as a
canonical unsigned 32-bit decimal string, so a raw tagged pointer cannot be
smuggled into an image as a numeric word. Scalar Bool/Char rewrites match the
existing `nc_constructor_value` immediate representation and require the
appropriate zero/one child counts. User constructor identity is encoded before
the pass and cannot impersonate those runtime-owned scalar constructors.

Nullary constructors retain their existing packed representation. A one-field
user constructor is packed only for a canonical scalar word fitting the runtime
location mask; other nontrivial constant nodes receive image storage. User
foreign definitions disable preparation, preserving the existing ordinary
constructor foreign ABI. Arrays and effect nodes cannot enter an image, nor
can an outer constructor containing one: its child fails the constant test.

Children are interned before their parent and image words contain only scalar,
packed or static constructor words. Thus every location in an image graph is
immutable and below `HEAP_OFF`. Existing `term_triv`, `term_keep`, `term_drop`,
`ctr_take` and `spare_free` behavior covers repeated consuming traversals without
freeing static storage. Dynamic parents may still seal a static child into an
ordinary RFC wrapper; preserving this existing runtime behavior is safe even
though such wrappers may be a later optimization opportunity.

The image word cap is 65,536. When a node does not fit, it remains a dynamic
constructor whose already-lifted children are still valid. Node interning keys
contain exact constructor identity and emitted field words; hashing is only an
index accelerator, with exact-key lookup. No pointer-identity operation is
introduced into the supported language/foreign domain.

## Trust and demand checks

The request strips prior auxiliary cache payloads while preserving the source
index. Input NStatic syntax is rejected, so caller-supplied offsets cannot become
fresh image facts. The attached body cache contains transformed bodies only;
original definitions stay available to arity, layout and type queries. Intrinsic
and foreign bodies retain their old construction path and temporary-ID behavior.

This pass never evaluates arbitrary references, applications or NOp expressions
to discover constants. Therefore it cannot pre-execute effects, move a failing
call out of a branch, or discard dynamic arguments on the basis of a type. It
preserves static product fields for private multiword returns instead of
silently rejecting the existing product route. C identifiers remain subject to
the existing uniqueness/width validation before final emission.

## Required execution scope

No further concrete source-level blocker was found after the corrections, but
the following checks remain root's responsibility:

- All three prepared semantic fixtures, one and four CPU threads, with static
  image presence and product worker admission inspected.
- `raw-review-cases.mjs`: interior cache output 7n, a forged old static context
  claiming 999 still outputting 7n, and forged NStatic rejection.
- Existing malformed constructor/wrong-tag, demand/error-order and foreign
  callback controls. A nonconstant constructor and a mutable array must retain
  dynamic allocation.
- An input exceeding the image cap. The cap bounds image storage, not recursive
  syntax traversal depth; long literal Strings must not turn fallback into an
  unbounded stack or memory regression.
- Deterministic B1/B2 emission and a compilation-time screen. C-program speed,
  compiler speed and release qualification are separate claims.

CPU controls do not qualify device initialization or GPU execution. The pass
uses existing image infrastructure, but that fact alone is not a device test.

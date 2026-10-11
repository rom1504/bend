# Scoped native constructor storage reuse

This is a reviewed-design candidate, not an applied compiler transformation.
The P69-005 saved-C experiment measured root-reported medians of 570 ms for
mode-only, 459.5 ms for cold stores and 426.5 ms for cold stores plus two local
spares. That last 7.2% time reduction motivates a bounded general slice, but does
not justify weakening ownership or turning an implicit C-text rewrite into the
compiler architecture. Root's execution report is authoritative.

The present emitter has no reusable lexical-spare state. `nc_destructure`
immediately frees `ctr_take`'s result; `ne_constructor` allocates anew. The
ordinary worker target already carries destination, join, owner, parameters,
tail permission and signatures. It is the right home for two related facts:

- **available:** typed spare descriptors usable by construction in this scope;
- **cleanup:** the subset introduced since entering the current destination,
  which must be released when control transfers to that destination.

A descriptor contains exact field width and the generated C `Loc` variable.
Initially restrict admission to boxed non-Base constructors of width >=2 in
ordinary host workers. This avoids packed single-field, array and scheduler
transport cases. Exact width is a conservative first compatibility rule;
physical class compatibility can be considered separately later.

A successful consuming match declares a fresh `Loc` using unchanged
`ctr_take`, copies every field to local words, and extends both target lists.
The address can be reused only when it is at least `HEAP_OFF`. Shared take
returns zero; static storage is below the heap. Before building a compatible
constructor, select an available nonzero address and clear its variable once.
Otherwise call `heap_alloc`. Clearing is essential because nested value
lowering sees copies of the same compile-time descriptor list.

At a normal return or self tail jump, free all still-live cleanup addresses.
At an outward local join, free only the cleanup subset associated with that
join. Creating an inner value destination inherits **available** but resets
**cleanup**. Its later match-introduced spares belong to that inner destination;
outer spares may be consumed but must not be prematurely freed. A branch that
consumes a parent then returns without rebuilding must also release its spare.
The original ownership of moved fields remains separate from storage ownership.

Example: matching parents A and B creates two spare variables. The first
nested Node construction may consume A, the second consumes B, and the outer
Node allocates. Inner construction joins do not free A/B because they remain
in the enclosing lexical scope. A mixed-tag miss frees A before dropping its
fields. No field address survives an overwrite; all original fields were
copied first.

Tail-self loops release active spares before `goto nf_again`. Ordinary worker
admission excludes non-tail C recursion cycles. Therefore retained addresses
are bounded by lexical matches in existing native frames; no global cache,
recursive retained-root structure or new unbounded C recursion is introduced.
Error paths currently terminate the native computation and eventually discard
the corpus; their retained-storage behavior still needs explicit review rather
than silently asserting they all execute normal cleanup.

Expected implementation size is roughly 70–100 Bend lines plus mechanical
updates to `NC_Destination` constructor/pattern arities. That is larger than the
saved-C edit and touches `flat.bend`, `product.bend`, `bridge.bend` and constructor
emission. Implement with explicit facts and direct emission, not a regex over C.
No patch is prepared yet because the incremental value must compete with typed
scalar worker signatures and scheduler/product work.

Controls before selection: unique and shared parents, static parent, mismatched
branches, nested local joins, early generic/raw failures, field duplication,
two compatible spares, incompatible widths, a constructor-less branch, a
self-tail loop, and a long finite tree to check bounded memory. CPU/device
fallback must remain separate. Test an unrelated record transformation, not
only the original zipper. An attractive timing never substitutes for these
lifetime invariants.

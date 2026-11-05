# Explicit insertion zipper: independent source review

Reviewed `selfhost/tests/phase164/index-zipper.bend` against maintained
`selfhost/src/core/index-queries.bend:p131i_insert` and the unchanged leaf/join
and legacy helpers in `core/index.bend`. No compiler or target was executed.

No discrepancy was found in the candidate's source computation. At every
nonzero-mask typed node it uses the exact current predicate
`(hash xor stored) & (split - 1) == 0`, with wrapping U32 arithmetic, then the
exact `hash & split` child choice. Each frame retains the actual stored hash,
split and untouched sibling. Frames are pushed during descent, so tail unwind
rebuilds the innermost parent first and preserves left/right position. The
terminal leaf/join/fallback is evaluated before rebuilding those parents, as
in the current recursive definition.

An informal invariant is that inserting at the initial root equals plugging
the insertion result at the current subtree into the accumulated parent frames.
Each descent preserves that invariant by the same branch decision. At a leaf,
join point, legacy KDef or split-zero typed node, the candidate invokes exactly
the same existing terminal computation. This argument does not require masks
to be powers of two, monotone splits, consistent stored representatives or a
32-level depth bound. It is source reasoning, not a checked BendTT theorem.

Collision buckets still pass through `index_leaf`, including removal of every
same-name occurrence, front insertion of the complete replacement record and
preservation of surviving bucket order. Arbitrary KDef and split-zero fallbacks
receive the exact stopped subtree and original record/hash; ancestors are
rebuilt afterwards. No eager whole-tree normalization is introduced.

The zipper changes temporary representation and object lifetimes. It retains
only untouched siblings and metadata in explicit frames rather than scheduled
continuations, while the outer caller retains the inserted record. No mutation
or new pointer-identity assumption appears. Returning both an old root alias and
the new result is an essential execution control: structural source reasoning
does not establish the correctness or cost of generated ownership operations.
`walk` and `unwind` are tail recursive, but actual direct admission, machine
stack behavior, terminal generic work and total allocation cost need the native
screen. Extra zipper nodes can outweigh the eliminated continuation work.

## Oracle choice and finite evidence

The primary reference must be the **current** `p131i_insert`, not only
`p131i_original_set`. The older two-pass helper is equivalent on canonical
indexes but not arbitrary malformed typed trees. For example, insert hash1 into
`KIndexNode{0,4,KIndexLeaf{1,[a]},KIndexLeaf{4,[b]}}`: current insertion joins
above the root at mask1; the older helper reaches and replaces the left leaf.
The zipper correctly preserves the current behavior.

Phase131's retained
`selfhost/tools/performance/phase131/identity/README.md` documents 336 complete
canonical/legacy tree comparisons and 11,088 lookups. Its 840 malformed cases
belong to the later **read** experiment; they are not an insertion theorem.
The `law` declarations are signatures, not equational correctness proofs.

New standalone `zipper-controls.bend` freezes the current recursive expression
as `p164xc_original`, with no replacement of maintained declarations. It exports:

- `p164xc_case(seed,count,mode,legacy,new) -> KDef`: full rich-payload tree;
  accepts the old 4-seed, 6-length, 7-hash-mode matrix and legacy prefixes.
- `p164xc_edge(n,new) -> List<KDef>`: complete retained old root and updated root
  for 16 cases, including nested legacy/split-zero fallback, duplicate names,
  both join directions, highest-bit hashes, empty names, nonpower masks,
  inconsistent representative hashes, a 65-parent chain and shared siblings.
- `p164xc_controls() -> List<String>`: 17 quick rows, including independently
  written duplicate-removal output. The maintained exact physical comparator
  supports this quick gate; independent host deep comparison of the exported
  complete values is stronger than relying on these Boolean results alone.

The rich records include ordinary fields, child definitions, lambda quantity
presence, literal variant/value/text, removed names and source spans. There is
no checksum-only oracle. A delimiter check passed; source acquisition and all
execution results remain root-owned and were not performed by this reviewer.

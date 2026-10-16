# Native text representation: ABI and ownership audit

This is an offline source audit for the ambitious native text work in Phase101.
It proposes and challenges an implementation; it contains no new profile,
benchmark, compiler qualification or proof result. No compiler/runtime source
was edited and no compiler/program target was executed for this audit.

## Why this is a general opportunity

Phase100's source index traverses runtime input and returns a complete inventory;
its renderer constructs and joins complete pixel strings across parallel row
tasks. They stress both consuming and producing String programs. The graph
planner already benefits from borrowed String comparison and must retain that
win. A successful representation should improve all these ordinary source
programs without recognizing application names or replacing their algorithms.

The current native representation materializes a two-word constructor per
character, with reference-count wrappers where sharing requires them. IO decodes
bytes into that linked representation and later encodes the linked representation
back to bytes. Borrowed observers avoid some reconstruction but still chase one
node per character. The proposed change attacks allocation, ownership and layout
together. A static source audit does not establish their measured share in either
application; profile/counter evidence remains necessary.

## Actual implementation boundaries

| Boundary | Current code | Consequence for packed text |
| --- | --- | --- |
| Term ABI | `selfhost/src/runtime/native/runtime.c:185`, `:695` | Term has seven tag bits, sixteen auxiliary bits and a forty-bit corpus location; RFC occupies the high bit. There is room for a distinct String storage tag. |
| Logical constructor test | `selfhost/src/back/native/bridge.bend:426` | Ordinary SCon/SNil matches compare `term_aux` to CID. A new storage tag can retain SCon's auxiliary CID. |
| Owned constructor split | `runtime.c:905`, `bridge.bend:459` | `ctr_take` returns owned fields and a reusable allocation location; special packed text must transfer ownership and return no reusable two-word node. |
| Borrowed projection | `bridge.bend:436`, `observer-emitter.bend:102` | Both generic fields and observer loops directly read `e.mem[term_peek(...) + i]`. A new text tag needs explicit head/tail accessors in both paths. |
| Constructor creation | `selfhost/src/back/native/emit.bend:38` | `ne_constructor` emits ordinary constructor allocation. Canonical SCon creation must be redirected to the representation-aware constructor to benefit user producers. |
| Ownership | `runtime.c:739`, `:762`, `:797`, `:893` | `rfc_seal`, `term_keep`, `term_drop` and `span_fade` jointly define ownership. In particular `span_fade` only retains RFC fields and rejects other nontrivial fields today. |
| Bulk array initialization | `runtime.c:1095` | `blk_new` directly calls `rfc_wrap` for a replicated nontrivial non-RFC element. It needs an explicit packed-String bulk retain; changing `term_keep` alone misses it. |
| Shared observer admission | `selfhost/src/back/native/observer-integration.bend:111` | `no_shared_roots` recognizes only RFC count greater than one. Packed String sharing needs equivalent admission or the borrowed fast path can silently disappear. |
| File input | `runtime.c:2439`; `effs/file_read.c:25` | `io_str` decodes UTF-8 into SCon cells. A packed producer must preserve the current decoder's replacement behavior. |
| Text output | `runtime.c:2375`; `effs/print.c:9` | `io_cbuf` consumes each SCon through `ctr_take`; final output can initially share that adapter, then use chunk-aware encoding. |
| Pure-main readback | `runtime.c:2739` | `show_val` also directly projects borrowed SCon fields. Updating IO.print alone leaves ordinary String-result display unsound. |
| Static literals | `selfhost/src/back/native/static.bend:105` | Existing static SCon chains can remain legacy values in a mixed representation initially. |

Paths abbreviated as `runtime.c` above are under `selfhost/src/runtime/native/`;
the Bend backend paths are under `selfhost/src/back/native/`.

Using `TAG_BUF` unchanged is incorrect: that tag already denotes packed scalar
Array storage, its auxiliary field denotes the allocation class, and its drop
path does not release a String suffix. Returning a fake two-word view from
`term_peek` is also unattractive: temporary view allocation restores per-character
cost and scratch storage is unsafe with nested/parallel borrowed traversals.

## First prototype: immutable chunks with virtual SCon cursors

The root's concrete proposal is a good bounded prototype:

- Add a host-only String storage tag whose auxiliary field remains `CID_SCON`.
- Allocate a fixed-size corpus chunk, initially 256 words, with an atomic
  reference count, physical allocation class, end position and owned sealed
  suffix Term in its header.
- Store each character in one word: low 32 bits contain the complete Char
  payload; high 32 bits give the distance to the chunk header. A Term's location
  addresses the current character. The header is recoverable from any cursor
  without a hash table, external pointer or extra allocation.
- A borrowed split returns that character plus either the next virtual cursor
  or the header's borrowed suffix. It allocates and retains nothing, and is valid
  only while an owning ancestor/root remains live.
- An owned split within the chunk transfers the same ownership obligation to
  the next cursor. At chunk end it transfers the suffix if unique, or retains
  the suffix before dropping the shared chunk handle.
- A constructor prepends into unused prefix capacity only under a unique chunk
  reference. Otherwise it allocates a fresh chunk owning the supplied tail.
  Existing characters and every visible suffix remain immutable.
- Legacy static/heap SCon chains continue to work. Read/write/retain/drop helpers
  dispatch on physical storage while source-level matches see the same SCon.

This first layout uses eight bytes per character, not a claimed four-byte packed
U32 format. Its first benefit is removing per-character allocations, RFC wrappers
and ownership transfers. A later denser layout can be judged after this works.
Likewise, it is not yet an O(1) rope append: generic String.append still traverses
its left argument, but its reconstructed characters can share chunk allocations.
Avoid mixing a new append algorithm into the initial representation comparison.

This requires a small cross-cutting representation boundary, not a second
backend. The existing direct worker/product/observer infrastructure stays useful.
Whole-function typed cursor lowering can later remove accessor branches and
carry a pointer/end pair through loops; it need not precede the first experiment.

## Correctness challenges to settle explicitly

1. **Owned versus borrowed suffixes.** A chunk header owns exactly one suffix
   reference. Merely reading its suffix does not acquire another. Escaping a
   borrowed suffix, copying a containing parent or putting it in an independently
   owned task/array must retain it. Audit `span_fade` and every constructor/array
   duplication path, not just direct String calls.
   Specifically, `blk_new` can create an RFC-wrapped packed String unless its
   direct bulk-retain path is adapted; merely adding a case to `term_keep` does
   not cover this operation.
2. **Mixed representation.** Seal a legacy nontrivial suffix before publishing
   the chunk. Retaining the immutable header's suffix must return the same handle
   (RFC, packed String or trivial), so shared end-split does not need to mutate
   the header or race with another reader.
3. **End-of-chunk transfer.** Save all necessary metadata before free. For a
   shared chunk, retain the suffix before releasing the chunk reference. For a
   unique chunk, move its owned suffix and free only the chunk. Empty suffixes
   remain the ordinary immediate SNil.
4. **Nested destruction.** `term_drop` must identify packed Strings before its
   generic non-Ctr fallback treats the auxiliary field as a function ID. Dropping
   a legacy constructor with a packed String child must work too. Long chains
   of chunks should be released iteratively, not through native stack recursion.
5. **Unique prepend.** Count one is a lifetime condition, not an unused-space
   location. Track/check the header boundary and current cursor before writing
   a preceding slot. Never overwrite the current visible suffix. Aliases
   protected only by borrowed lifetime rules cannot escape those rules.
6. **Publication and parallelism.** Initialize metadata, character contents and
   the sealed suffix before sharing the handle. Reuse the existing atomic
   retain/release ordering; do not use the optimization to weaken it. Two owners
   retaining different offsets of the same chunk must keep the entire chunk and
   suffix alive correctly. Affine task captures must own their references.
7. **Device/foreign compatibility.** `#if !DEVICE` alone is insufficient: host IO
   can create values later sent to a GPU. Keep the prototype explicitly GPU-off;
   before broader use either disable packed creation whenever GPU execution is
   enabled or establish an explicit conversion boundary. Unknown foreign C
   consumers need rejection/fallback or an audited ABI adapter.
8. **Constructor identity.** Specialize canonical Base String/SCon, not a user
   constructor with the same spelling. Reuse existing identity provenance and
   refuse erased/foreign/unknown owners when their contract is not established.

## Character semantics: preserve all U32 values

Current `bend2/base.bend:70` defines `Char` as `Chr{code: U32}` and
`Char.from_u32` at line 1842 returns `Chr{x}` without Unicode scalar validation.
String therefore admits arbitrary U32 payloads, including surrogate values and
values above U+10FFFF. A UTF-8-only internal replacement would silently narrow
this domain unless it used a checked fallback. The proposed low-32-bit payload
preserves it directly.

UTF-8 validation/replacement belongs at the existing IO boundary. Preserve
`io_str`'s exact treatment of invalid leads, interrupted sequences, end of input,
surrogates and range limits. Preserve the existing output encoding behavior
without introducing a new normalization or validation rule. Phase43's JS
checked-Char/host-guard assumptions are not the native Char contract.

## Controls and cheap experiment sequence

First run saved generated-C variants, with every transformation recorded and no
application-name branches. Test actual canonical constructor/projection/runtime
mechanisms. A saved-C win is evidence for implementation, not a new compiler
release; successful paths must subsequently be emitted by the Bend compiler.

The focused control set should cover:

- Empty, singleton, capacity-minus-one/exact/plus-one and multi-chunk Strings;
  constructor/owned-split inverse; repeated prepend and dropping arbitrary suffixes.
- Duplicate a root, retain several overlapping suffixes, drop owners in different
  orders, store Strings in shared records/lists/arrays, return a matched tail,
  and compare equal/early-mismatch/late-mismatch mixed legacy/packed Strings.
- Full U32 character observations: NUL, ASCII, BMP, astral, surrogate, U+110000,
  `0xFFFFFFFF`; also valid and malformed runtime UTF-8 decode fixtures.
- Parallel tasks retaining the same String, independently constructing results,
  joining in deterministic order, and dropping unused captures. Run the existing
  exact full-image 1/2/4-worker application comparison.
- Complete source-index outputs, complete image outputs and the graph planner's
  exact output/win. Do not validate only lengths or hashes when full output
  comparison is already cheap.

Useful local laws are complete String observation equivalence, owned split/cons
equivalence, append content/order, and duplication/drop observational neutrality.
The chunk lifetime invariant must connect concrete handles, backing ownership and
borrowed cursors. An abstract immutable-value proof alone does not establish
atomic refcount implementation or that emitted code acquires every needed handle.

Use small native controls first, then Phase100 frozen-oracle replay (roughly ten
seconds for repeated substantial rendering). Record clean time and instrumented
allocation/ownership counts separately. Require substantial gains on both source
index and renderer, retain graph behavior, and test a small compiler request
before investing in a new complete native compiler-image chain.

## Lessons retained from earlier phases

- **Phase43:** translating only a consumer left an expensive producer in place;
  whole producer/consumer components achieved much larger JS gains. Apply that
  lesson here by connecting IO input and ordinary SCon construction to matching
  and output, without copying JS-specific semantic guards.
- **Phase68:** direct saturated workers and shared bodies removed generic closure
  and scheduler transitions, with instrumented count evidence. Those facilities
  already exist; text specialization should compose with them instead of adding
  another ad hoc execution engine.
- **Phase87:** growing-left String append dominated an actual compiler profile;
  linear chunk ordering produced large wins. Do not reintroduce quadratic copies
  through flatten-on-every-append or repeated representation conversion.
- **Phase89:** ordered text nodes and owned result composition reduced real native
  costs, while the same source representation regressed JS. Keep target-specific
  physical text storage separate from the shared logical String semantics and
  retain independent JS continuity checks at integration.

Sources: [Phase43 design](../../design/phase43/strings.md),
[Phase68 report](../phase68/README.md),
[Phase87 experiment](../../experiments/phase87/P87-003-linear-native-text.md),
[Phase89 report](../phase89/README.md),
[Phase100 report](../phase100/README.md).

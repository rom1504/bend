# Structure kernels for native45

Each C11 translation unit exports only
`uint32_t bench_u32(uint32_t a, uint32_t b)` as its public entry. The separate
driver owns repetition, clocks, output and validation. Compile the driver and
kernel separately without LTO. The kernels contain no catalog output constants,
case-ID dispatch, persistent caches or input-specific fast paths. Five kernels
serve the nine mappings; a size variant supplies different arguments to the
same implementation.

The semantic entry is each frozen fixture's `p93.value`, rather than an older
example `main` or an unrelated helper in that fixture. The
[native45 catalog](../../catalogs/native45/catalog.json) authenticates the exact
fixture bytes, fixed input points and independent output files. Source pins and
oracles remain there; this directory adds no replacement expected-output table.

| Kernel | Exact source definitions | Variants |
| --- | --- | --- |
| [closures.c](closures.c) | [coverage-closures-64.bend](../../catalogs/native45/fixtures/coverage-closures-64.bend): `compose` line16, `chain` line26, `bench` line70, `p93.value` line105 | [64](../../catalogs/native45/fixtures/coverage-closures-64.bend), [256](../../catalogs/native45/fixtures/coverage-closures-256.bend) |
| [list-pipeline.c](list-pipeline.c) | [coverage-list-pipeline-128.bend](../../catalogs/native45/fixtures/coverage-list-pipeline-128.bend): `dbl` line24, `keep_gt1.at` line41, `keep_gt1` line48, `suma` line61, `p37.list` line162, `bench` line169, `p93.value` line204 | [128](../../catalogs/native45/fixtures/coverage-list-pipeline-128.bend), [512](../../catalogs/native45/fixtures/coverage-list-pipeline-512.bend) |
| [bst.c](bst.c) | [coverage-bst-32.bend](../../catalogs/native45/fixtures/coverage-bst-32.bend): `BST` line9, `BFrame` line13, `bst.pick` line24, `bst.step` line36, `bst.down` line50, `bst.up` line62, `insert.fin` line76, `inorder` line96, `p37.bst.insert` line125, `p37.bst.build` line128, `bench` line136, `p93.value` line171 | [32](../../catalogs/native45/fixtures/coverage-bst-32.bend), [64](../../catalogs/native45/fixtures/coverage-bst-64.bend) |
| [expression.c](expression.c) | [coverage-expression-32.bend](../../catalogs/native45/fixtures/coverage-expression-32.bend): `Expr` line7, `eval` line17, `p37.expr.pick` line46, `p37.expr` line55, `bench` line62, `p93.value` line97 | [32](../../catalogs/native45/fixtures/coverage-expression-32.bend), [128](../../catalogs/native45/fixtures/coverage-expression-128.bend) |
| [local-pair.c](local-pair.c) | [local-pair.bend](../../catalogs/native45/fixtures/local-pair.bend): `Dp` line31, `prng` line42, `gen` line58, `init` line67, `cell` helpers lines76–99, `row` line103, `dp` helpers lines113–129, `dist` helpers lines132–138, `pair` line142, `p93.value` line214 | local-pair |

## Preserved work and ownership

**Closures.** Build the full recursively captured chain, then apply it once.
Each step allocates an addition closure and a composition closure; the base
allocates an identity closure. A composition calls its first closure, then
passes that result to its second. Captures are ordinary C fields plus a function
pointer. Each application consumes and frees its own closure. Thus a chain of
size `a` allocates and frees `2*a+1` closure objects; it is not a triangular-sum
formula or a direct arithmetic loop. The example `FBox`, `sqr` and `main.out`
are outside `p93.value`'s dependency path and are not timed work.

**List pipeline.** Materialize the LCG-produced linked list in source order,
filter it with `head > 1`, construct the doubled list, then consume it with the
wrapping sum. These are separate complete passes. Filter and map free consumed
input nodes and allocate their output nodes; no pass is fused and no list is
replaced by an array. `NULL` represents `Nil`, and C fields replace generic
runtime constructor slots. The unused map/any/all examples in `main.out` do not
belong to this fixture's measured `bench`.

**BST.** Insertion uses a heap-allocated linked zipper. Every visited tree node
is consumed, its sibling and value move into a frame, and the path is rebuilt
with freshly allocated tree nodes. Equal keys go right. The source's `size+1`
fuel loop remains, including steps that already reached a leaf; C optimizers
may simplify these no-op steps. An exhausted nonleaf is reconstructed without
inserting, preserving `insert.fin`'s other branch. The source guarantees enough
fuel for public `bench` inputs. C combines a `BF` and its list cell into one
frame struct and uses `NULL` for a leaf. The final left-node-right fold frees
every tree node and retains the repeated wrapping `acc*10+value` operation;
it does not sort a flat array or compute a multiset aggregate.

**Expression tree.** Build the complete nonbalanced tree before evaluation.
Each size step allocates the outer binary expression, its shallow binary arm,
and two literal nodes; the base is one literal. All `4*a+1` nodes are evaluated
and freed. The three branches preserve the exact seed-dependent Add/Mul/Sub
shapes, including the inner arithmetic node. A tagged C union replaces generic
constructor fields. No AST is collapsed into its result during construction.

**Local pair.** `p93.value(a,b)` calls `pair(a)` and intentionally ignores `b`.
It does **not** call the fixture's `bench(size,seed)` batch wrapper. Each call
creates and zero-fills four owned arrays of 256, 256, 512 and 512 U32s. It draws
both 256-symbol xorshift streams, initializes all 257 boundary entries, executes
all 256×256 DP cells, and swaps the two rows after every complete row. The state
record holds four C pointers; direct indexing replaces array-return tuples and
record reconstruction. Array sizes, initial zero filling, four cell reads, row
order, final distance load and index checksum stay intact. All four arrays are
freed before returning. No full-grid allocation, specialized input answer or
different edit-distance algorithm is used.

All words use `uint32_t` on the AMD64 C ABI, with unsigned comparison, logical
right shifts and wrapping arithmetic. Intermediate BST key arithmetic wraps
before reduction modulo257. The size argument is a U32-origin natural count;
the BST uses `uint64_t` for `size+1` so that addition does not wrap at UINT32_MAX.
Nullary constructors and erased type/quantity arguments have no heap object.
Tail-recursive scalar loops use ordinary C loops. Allocation failure aborts;
every allocation is reclaimed on normal return. No arena or global state
survives a call. Recursive construction/traversal still has finite C-stack and
memory limits; this is not a claim of arbitrary-size resource equivalence.

## Corner checks for the controlled execution lane

These are proposed checks, not execution evidence from this implementation
session. Keep the catalog's independent complete outputs as the main gate,
and use matching Bend calls for additional input comparisons:

- Closures: sizes0 and1, seeds0 and UINT32_MAX, then both catalog sizes. The
  empty chain must still apply identity; the single-step case exercises wrap.
- Lists: sizes0,1,2 and17; seeds0,1,2 and UINT32_MAX. This covers empty and
  fully rejected lists, retention boundaries, order across an LCG cycle, and
  wrapping seed generation without replacing it by periodic arithmetic.
- BST: sizes0,1,2,8 and17 with seeds0,17,128 and UINT32_MAX, plus catalog32/64.
  Seed128 makes the odd stride257 and exercises duplicate-key right branches.
  A helper-level review also checks zero/insufficient fuel preserves the
  existing subtree. Final accumulator arithmetic wraps as U32.
- Expressions: sizes0,1,2 and3 with seeds0,1,2 and UINT32_MAX, plus catalog32/128.
  Cover all three arms, the literal base, wrapped recursive seed increment,
  subtraction underflow and multiplication overflow.
- Local pair: pair indices0,1,17 and UINT32_MAX, with two different second
  arguments for each. This checks the measured entry's ignored argument,
  unsigned xorshift stream and wrapped `(index+1)` hash boundary. The
  UINT32_MAX index exercises zero seeds and matching streams; the DP must
  still visit the full grid.

Use a leak/undefined-behavior checker on bounded calls if the root execution
budget allows it. No C compilation, target execution or timing was performed by
the authoring agent; source/mapping consistency checks are separate from these
proposed semantic and memory controls.

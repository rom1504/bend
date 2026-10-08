# Flat06 remaining worker coverage

Source/data-only review of actual Flat06 C against saved upstream `0592662` C.
[Exact C identities, worker names and counts](worker-coverage06.json) accompany
this note. No new target or profile was run. These are emitted-source counts;
they do not measure dynamic hotness or assign percentages of runtime.

| Family | Selfhost / upstream workers | Selfhost / upstream scheduler segments | Main workload paths still outside workers |
| --- | --- | --- | --- |
| Closures | 10 / 10 | 416 / 65 | `chain`, `compose`, callback invocation, `bench` |
| Tree | 18 / 18 | 554 / 80 | `warp`, `flow`, `bsort`, `scan`; dependent `warp_node`, `bench` |
| Map | 24 / 23 | 946 / 169 | `Map.put.go`, `ins.go`, `seek.go`, `pop.go`, `to_list.go`, key construction and dependent workload loops |
| Lexer | 26 / 25 | 599 / 69 | `ident`, `num`, `gen`, `batch`; dependent `expand`, `gen.at`, `line`, `bench` |

The recursive/dynamic families in the last column also use scheduler paths in
the upstream C. Blanket admission of ordinary recursive C functions therefore
does not explain the observed parity gap, and would require a separate bounded
stack argument. Upstream's much smaller segment count includes more aggressive
inlining/transport choices; a source segment count alone is not scheduler time.

The closure workload builds an escaping function recursively. `compose`
captures `f` and `g`, then invokes them dynamically. Flat06 excludes escaping
lambdas, dynamic/partial calls and dependent callers. Its positive chain step
allocates an add closure, a partially applied compose closure, then a two-field
composed closure. Upstream folds the known compose prefix into the continuation:
construction captures `(k, h)` directly; application later creates the add
closure. This suggests general known-callee prefix closure construction or
local closure specialization, preserving argument order, ownership and delayed
demand. It is not permission to substitute the benchmark's mathematical result.

Tree `warp`/`flow`/`bsort`/`scan` use non-tail recursion and parallel bindings.
Map insertion/update reconstructs nodes after recursion; seeking/removing wraps
recursive results with other operations; traversal nests a recursive call as
an argument. Key/String construction adds its own non-tail rebuilding paths.
`Map.msb.u`/`.if` and `Map.diff`/`.fin` also have mutual recursion. The workload's
tail-recursive fill/update/remove loops inherit those rejected dependencies.
Lexer `ident`/`num` recurse underneath `SCon`; `gen` passes its recursive result
to `gen.at`; `batch` has non-tail/parallel work. The main lexical step itself is
already a worker. These are general language-shape boundaries, not missing
benchmark-specific recognizers.

Two allocation mechanisms deserve separate tests. First, upstream packs Tree
Leaf's single U32 field directly, while Flat06 allocates/seals a node. The same
gap appears for lexer mode constructors. This led to the general guarded
[P68-011 proposal](../../experiments/phase68/P68-011-guarded-constructor-packing.md):
exact payload representation, runtime fallback for wider/raw/pointer fields,
and explicit foreign/effect boundaries. Its source-derived diagnostic is not
yet a measured compiler change.

Second, upstream often retains storage returned by `ctr_take` and reuses a
suitable unique node for the next constructor. Flat06 immediately frees that
storage, then allocates again. General constructor storage reuse could help
recursive reconstruction, but needs branch/call/escape ownership and unused
spare cleanup rules. It should follow new dynamic allocation evidence after
products/packing selection. No speed estimate is established by this review.

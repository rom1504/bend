# Retained reverse dependency work queue (unqualified prototype)

The native integrated baseline reports334.286s for full compiler A and153.551s for warm changed compiler B. Raw lowering still costs44.820s despite3,683 of3,742 generic and private products hitting; frontend costs51.394s. These numbers motivate inspecting the work of establishing reuse, not adding another emitter optimization. They do not yet identify reverse closure as the measured dominant function.

## Existing repeated work

`p140o_fix` scans every owner on each sweep and looks up each conservative reference until a dirty dependency is found. The dirty count controls convergence, with a bound of owner-count plus one. Every lookup hashes a String. Raw processing performs a source-body closure and then another closure after comparing derived erased/static facts. The annotation/erasure path performs its own closure. All term names are intentionally retained as dependencies; removing names on an informal syntactic guess would weaken correctness.

`core-v04.bend` independently removes the duplicated full-body comparison: a single ordered walk produces both initial dirty owners and refreshed edges. The reference source/body equality remains exact. This candidate is separate from the currently checked core-v03 baseline.

## Prototype boundaries

`reverse-v01.bend` is the initial standalone queue sketch. `reverse-v02.bend` is the retained implementation (146 lines). Both are new experimental modules; neither replaces production declarations.

- `p140oq_build(edges)` builds a reverse relation from each reference name to a set of owners. Both levels use the existing collision-safe Patricia map. Owner sets deduplicate repeated graph edges.
- `p140oq_with(reverse, initial)` seeds a queue from **every** initial dirty name, including names absent from the owner catalogue. It follows only their reverse users. Each owner becomes dirty and enters the queue at most once. Cycles terminate without repeated global sweeps.
- `p140oq_fix(edges,initial)` rebuilds the index for a standalone comparison; it is not the retained warm path.
- `p140oq_analyze` keeps the exact existing source/context admission guard and uses the old reverse relation to close the one-pass initial delta.
- `p140oq_fact_analysis` also uses that old relation for additional erased/static fact changes.
- `p140oq_refresh` updates the relation for the next successful request. An admission miss rebuilds it. On an admitted edit, it visits owner rows but examines references only for dirty owners. Equal reference lists retain their index; changed lists remove old relations and add current ones.

Removal writes an inactive owner entry rather than inventing a map deletion implementation. Only active `P140Dirty` entries are traversed. Thus old dependencies do not remain active, but tombstones and empty rows can accumulate. Repeated changes reuse existing keys; a bounded session and eventual compaction/reset are needed before exposing unbounded long-lived service behavior.

Duplicate owner rows are handled exactly: an old relation is removed only if no current row still supplies it. That current-graph scan is paid only when reference lists change. Numeric policy edits normally keep reference lists identical; this must be confirmed from the actual request, not assumed as an admission condition. General dependency-changing edits can make this update more expensive; an owner-to-reference index could reduce it later.

`bridge-v02.bend` adds `reverse: KDef` after `edges` in both private `P140OFCache` and `P140ORCache`. It preserves empty-state/failure behavior and routes unchanged annotation, eligibility, static preparation, raw producers and final checks through the existing functions. The root session publishes the new cache only after successful complete compilation. No serialization or untrusted cache construction is supported.

## Observability audit

The existing dirty set is consumed by `p140o_has`, `p140o_mark`, the fixed-point count check and reported dirty count. Annotation, erasure and raw producers ask membership through `p140o_clean`. Cache records retain the source and edge graph, not the dirty index. No emitted output or ordered iteration depends on Patricia insertion order. The queue can therefore change physical node order while preserving membership and count. This is narrower than asserting arbitrary graph structures are equivalent.

## Source and small-product gates

`owner-source05` SHA256 `7fe62c424e907983755549c0be8e66920e3bfcfb041260da7b2204376e151a37` composes core04, products01, raw01, reverse02, bridge02 and controls. `reverse-modules-v01.json` lists the modules; `reverse-gates-v01.json` supplies bounded, sequential API/finite/real-product commands. Source05 was refused after6.46s because the `p140oq_users` tail needs an explicit affine sharing annotation. `reverse-v03.bend` adds only `+rest`; all failed source and guard receipts remain preserved. Active source06 is SHA256 `2bc5cb060b001cac61884ae1521508895a960e1d1016a636f1fd9c8ce9a72181`; `reverse-modules-v02.json` selects it. The API06 source check passed in13.67s/2.20GB, and all46 finite controls passed in1.62s. These are source/finite gates, not native qualification.

The46 finite rows include the original18 admission/static tests,13 complete old/new one-pass analysis comparisons,8 work-queue properties and7 reverse-update properties. The work-queue tests exhaust all512 directed three-node graphs with all8 initial dirty sets:4,096 finite closure comparisons, including self-edges and cycles. Additional cases cover duplicate edges and owner names, unknown or empty reference names, empty graphs, and the real32-bit hash collision between `costarring` and `liquid`. Update tests cover removal, addition, duplicate-owner preservation/removal, unknown names, collisions and fallback rebuild.

Finite closure equivalence is not a proof of compiler correctness. After the source check and controls, require actual fresh/cold/warm raw and final-QBE equality, then the composed real compiler edit. Only compare speed after preserving the original full warm baseline and charge index acquisition, retained memory, cleanup and output materialization. No whole-stage gain can exceed the measured time of that stage; queue complexity alone does not establish a5–10× complete rebuild speedup.


The real owner-screen02 comparison also passes both actual executable edits:
complete fresh/cold/warm/no-op raw lowerings are identical and both final warm
QBE products equal fresh B, while original A equals its frozen native oracle.
The screen costs46.80s/666MB. Ordered raw-stage observations are:

| Case | Fresh B | Warm B | Cold A acquisition | Raw hits/misses |
|---|---:|---:|---:|---:|
| Lexer |0.543s|0.519s|1.187s|33/12|
| Map |2.301s|0.427s|4.043s|69/3|

The cold index acquisition has a cost. These results are not a balanced
cross-version trial, and the entire warm compiler has not yet been measured
with the reverse cache. The current frozen evidence index is `evidence-v02.json`.
The full native baseline, exact changed B output and combined follow-up gate
remain root-owned. No default compiler or production cache format changed.

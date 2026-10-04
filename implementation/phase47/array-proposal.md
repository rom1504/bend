# Array-view probe and implementation boundary

Status: diagnostic producer prepared; no target executed and no gain established.
The [producer](../../selfhost/tools/performance/phase47/array-probe.py) accepts only
the preserved Phase46 `batch03/array-selfhost-js/program.mjs` with SHA256
`0a079e6ee0ce4f8c261943cd708c86df1d7dd2e0d67cf4d72e91b0122ad8a2a4` and its checked
emission receipt. It rewrites three identical private `fold.loop` function spans
with independently pinned hashes. This exact-output selection is an experiment
boundary, not a proposed source-name selector in the compiler.

Run the producer with the source module and a fresh output directory. It writes
four executable modules and `manifest.json`; it does not execute them:

| Variant | Change from preceding variant | Question |
| --- | --- | --- |
| original | Exact source copy | Reference behavior and time |
| shell | Expand `arrayset` into ordered local temporaries | Does removing its call boundary help? |
| view | Reuse backing view from first demanded read; retain length reads | Is repeated `arraydata` work significant? |
| length | Cache length after the first read's `Number(index)` | Does stable-length knowledge help further? |

All derived loops retain separate `Number` calls for the read and write. The
write's array/index/value expressions precede its helper body. Caches have only
empty declarations before the loop; acquisition stays at the first original
read site. The zero-iteration early return is byte-identical. Every other
generated function, guard and runtime byte remains unchanged.

These are unchecked derivatives. `Number` is mutable and can reenter or mutate
an array; retaining its call does not prove backing identity or length stability.
Array properties/getters/proxies and escaped aliases can invalidate a cached
view. Removing helper frames can affect error-stack observations. Existing
descriptor guards do not establish these additional permissions. The original
and shell variants help distinguish a JIT call-boundary effect from the proposed
new invariants; they are not universal semantic proofs either.

Root should first syntax-check all modules, compare independent base/warm/digest
oracles, then measure identical counts serially in rotated paired order. Include
zero and one fold iteration in a separately derived control, plus renamed small
array programs before considering production work. Adversarial controls should
replace `Number`, mutate backing storage/length during conversion, and observe
getters and aliases; either retain the original behavior or refuse optimization.
The Phase46 fixed batch cannot alone prove those boundaries. Any result must keep
compiler acquisition cost, warm execution and diagnostic controls separate.

## Where a surviving mechanism belongs

The current emitted read is already scalarized: `j_region_inline_output` in
[region.bend](../../selfhost/src/back/js/region.bend) emits `JInlineRead` as an
array handle plus element, and `j_region_read_definition` emits the corresponding
private helper. The write is emitted by `j_region_native_array` in
[emit.bend](../../selfhost/src/back/js/emit.bend). Existing
[fold lowering](../../selfhost/src/back/js/fold.bend) already keeps tuple fields
in loop locals. Merely adding another tuple-shell optimization would miss the
remaining repeated view/length and helper operations.

A general implementation needs explicit typed array allocation/read/write
operations, use/alias facts and movement permissions. The first sound scope is
an array allocated inside a private scalar-result root, with no escape, unknown
callback, storage replacement or resizing across the region. A view can be
acquired at its first demanded operation and reused only while those facts hold;
zero-iteration loops must not acquire it. Length stability and index-conversion
stability are separate facts. Unknown calls/public boundaries invalidate reuse.

The current [JW model](../../selfhost/src/back/js/ir/worker-model.bend) lacks
explicit array effect nodes. A successful probe should therefore motivate a
small shared array-operation plan consumed by existing region lowering and later
JW, rather than a workload-specific printer rewrite or broad purity flag. The
[existing experiment plan](../../docs/remaining_opportunities/experiment-plan.md)
already separates typed array effects, result forwarding and public adapters;
this probe tests whether one narrow consumer warrants that implementation.

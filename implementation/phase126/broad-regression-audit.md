# Source32 broad regressions: bounded static audit

The root's completed broad run reports **morning +15.29%** and **all three
tree-bitonic cases +11.2–12.1%**, despite the overall score improving
1.90357→1.75263. These are material regressions and must remain prominent.
This approximately three-minute audit ran no targets and establishes no
dynamic cause.

Inputs are the exact source/QBE pins in
`selfhost/build/phase126/final32-emission.json` and
`selfhost/build/phase125/broad-emission06.json`. Source hashes match between
roles. Source32 does **not** include the rejected tree-reshape prototype.

## Tree: core ownership workers did not change

The base tree program has 806→825 QBE functions: 19 additions and 17 changed
existing bodies. All additions are Nat/U32 conversion/formatting workers,
their four joined tail-SCC workers, and the benchmark's `p93.word` adapter.
There is no newly admitted tree worker. Of existing non-formatting bodies,
only `p111_$direct.bsort`, `p111_$direct.flow` and `p111_$direct.p93.loop`
change: their Nat predecessor helper call becomes exact inline subtraction,
scratch store and count1. Subsequent temporary/label numbers change with it.
`warp_zip`, `warp_leaf.go`, `warp_leaf`, the local-resume `warp` worker and
their tree ownership operations have byte-identical QBE bodies.

Retained base-tree executable inspection:

| Body | Phase125 / source32 instruction counts | Definite change |
|---|---:|---|
| `p111_$direct.flow` | 177 / 169 | Removes special-take call; same 0x800-byte frame |
| `p111_$direct.bsort` | 79 / 75 | Removes special-take call |
| `p114r_$direct.warp` | 270 / 270 | Normalized instructions identical |
| `p113d_$direct.warp_zip` | 125 / 127 | Alignment NOP/prefix and branch-offset differences |
| `p113d_$direct.warp_leaf.go` | 93 / 93 | Same QBE; relocated machine body |
| `p113d_$direct.warp_leaf` | 112 / 112 | Same QBE; relocated machine body |

Counts are static, include padding, and are not cycle estimates. The actual
`warp_zip` diff has new alignment NOPs versus old redundant CS prefixes; it
does not add take/ctor calls. Its entry moves 0x405a20→0x406410; the unchanged
local `warp` worker moves 0x4106c0→0x410c60. Thus code-layout effects are a
credible hypothesis, not an established explanation. Nat predecessor
projection is the only changed tree-computation lowering found here and is
the smallest independent ablation; fewer instructions do not prove faster
execution. Formatting/SCC changes can also affect harness work and layout.

## Morning: a different, wider changed call graph

Morning has 1315→1342 functions, 29 additions and 23 modified existing bodies
(two old identities disappear). Added workers include flat Map.bit/go/at,
String.eq/is_le/order/cmp.fin, Map.ins.splice, and the same formatting/SCC
family. Nat predecessor projection also changes Map.msb.u and p93.loop.
Therefore the tree's mostly unchanged hot bodies cannot explain morning by
analogy: its actual lookup/comparison call graph changes. Without a fresh
sample or matched ablation, the responsible worker is unknown. The earlier
observer-only lexer regression is a reason to check newly admitted String
helpers, not proof that they cause morning's regression.

## Smallest next discrimination

Retain source32 and its exact broad results. First compare only the already
available ordinary tree fixtures with Nat-predecessor emission disabled,
keeping all other plans and runtime fixed. Then independently ablate the
formatting tail-SCC/late-closure combination. Inspect real machine layout as
well as timings; a changed binary address alone is not evidence of a fix.
For morning, isolate the observer late-closure contribution before adding
more optimizations. Reuse complete expected outputs and paired measurements;
do not weaken correctness gates or silently exclude these cases from the
aggregate. This audit has not selected or executed any of those experiments.

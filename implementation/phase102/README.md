# Phase102: ambitious native campaign

Status: execution started 2026-10-16 20:09 UTC; planned window approximately
three hours. [Design](../../design/phase102/ambitious-native-campaign.md).

## Current candidate

The current source is `depth-inline-source01/compiler.bend`, SHA256
`535c1f8f8d19cdddebeb397e3ef461346488b92feae28fa363a110ff136286d9`,
replayed by [`phase102-lowering02`](../../selfhost/tools/native/profiles/phase102-lowering02/profile.json).
It has39,228 physical lines, **438 more than installed Phase98**. It combines
general worker composition, owning-observer forwarding, bounded selector
specialization, generic tail recursion through constructors, private cell reuse,
and bounded forced inlining. The earlier +425-line candidate below is historical:
its native B2 construction exceeded420s and it is not the retained successor.

The successor passes153 focused executions, including the original branch
controls. Its four-round application screen (`depth-bend-screen01`) checks72
complete outputs:

| Complete application | Candidate / installed B2 | Candidate / upstream |
|---|---:|---:|
| generated10000 source index |0.591|0.985|
| compiler-text source index |0.580|1.197|
| renderer, one worker |0.744|1.001|
| renderer, four workers |0.719|1.108|
| DAG800 |0.779|0.287|
| chain1000 |0.793|0.309|

These are complete-process application times, including startup and IO. They
are not compiler latency, nor an estimate for all Bend programs. Host speed
varied between screens; the paired baseline/upstream observations in each
screen matter more than small changes between separate runs.

Native B1 acquisition and self compilation pass. The actual bounded B2 Clang
build also passes:377.2s target wall time,2.58GB peak process-tree RSS, at the
unchanged O2 flags and within the420s/6GiB guard. B2 self reproduction and native
qualification are in progress. Installed Phase98 native and Phase90 JS remain
unchanged until the separate semantic and runtime gates earn promotion.

The actual compiler C has941 direct NF functions and610 forced definitions.
All941 workers shared with the unbounded product have identical bodies modulo
generated variable renaming (895 byte-identical). The estimated forced expansion
falls115.12→26.56MB. This is a lexical dependency proxy, not measured LLVM IR;
the successful native build is the practical evidence. The older installed
compiler's260.8s historical build is on a different source and is not a matched
build-speed ratio.

## Detailed evidence

See the [experiment history](experiment-history.md) for all intermediate screens,
failed candidates, witness repairs and rejected approaches. Mechanism notes cover
[typed workers](typed-notes.md), [construction](trmc.md),
[build experiments](build-notes.md), and [backend qualification](backend-qualification.md).
The [release plan](native-release-plan.md) keeps image qualification separate from
source replay; the [next opportunities](next-opportunities.md) remain hypotheses
unless backed by an actual result.

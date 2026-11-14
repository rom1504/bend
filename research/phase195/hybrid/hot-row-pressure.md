# Hot row: coverage versus actual pressure

`hotgraph-replay.py` replays only the final-placement hot edit-distance row from
allocation-capture01. It first asserts exact reproduction of all 32 selected
names, their order, and every captured home/color. Those assertions passed.
The replay uses the existing structured transfer, fixed point, dead-write
interference, call self-edges, incoming ABI constraints and affinity preference.
This is static analysis, not an emitted-code or speed result.

| Physical colors | Candidate prefix | Homed names | Newly homed hot names | Newly homed setup/guard names |
| --- | ---: | ---: | ---: | ---: |
| 9 | 32 | 30 | 0 | 0 |
| 9 | 40 | 33 | 3 | 0 |
| 9 | 64 | 50 | 3 | 17 |
| 9 | 75 (all) | 57 | 3 | 24 |
| 11 | 32 | 32 | 2 | 0 |
| 11 | 40 | 37 | 7 | 0 |
| 11 | 64 | 55 | 7 | 18 |

Hot here means the existing score>=8 class, not an independently sampled
per-name read count. The three nine-color gains are the final Boolean copy
(old frame offset2896), final store index(2912), and final selected result(2904).
Most additional hot names still cannot fit. The current32-node graph reaches
10 represented live names for nine colors; the40-node prefix reaches13.

Eleven colors means RCX plus R12. RCX is forbidden for every candidate live-out
or written at a variable shift, across a real call, or imported before incoming
ABI position3. Constant shifts need no RCX clobber. The independent physical
audit found variable-shift destinations specifically cannot be RCX: direct ALU
publishes the left operand there before loading CL. R12 is available only after
relocating canonical state to a fresh stack word. Pure state-dead-range borrowing
would be blocked by the captured cold failure branch, even though the emitted
hot loop has no actual call.

With the original32 candidate cap, the added colors recover both existing hot
graph spills: `p113a_5_hoist_base`(2392) and `p113a_3_old`(2808). At40 candidates,
five more hot values can be homed: min-input copy(2832), final Boolean(2896),
first min result copy(2864), store index(2912), final selected result(2904).
Increasing the prefix further produces setup gains only in this function.

The cheapest first experiment is the existing32-bit graph with11 physical
colors, preserving its256-row bound and validating the two new physical
contracts. It needs no U64 port. A second32-node graph with the first allocation
fixed could later recover the representational gap, but must compute cross-bank
interference from both exact live sets and dead writes, including joins,
incoming copies and parallel Again. It is not enough to color the second graph
independently. Such a second pass is a coverage mechanism, not an answer to
physical pressure. The first machine-code screen should establish whether the
two recovered hot homes actually remove executed frame accesses before that
larger implementation.

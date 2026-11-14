# Phase195 allocator architecture investigation

The successful joint path has a coverage discontinuity: it colors at most 32
names into nine physical homes and stops. The legacy path retains four saved
homes and can give many more regional names five reusable caller homes. Raising
the body gate alone substitutes the former for the latter. It does not increase
register capacity or preserve regional coverage.

Source authority: `selfhost/src/back/x86/loop-liveness.bend`, `transient.bend`,
`regalloc.bend`; final-placement captures in
`selfhost/build/phase195/allocation-capture01/*/preselection.json`. These captures
precede the experimental selected-analysis projection. No target was executed
for this investigation.

## Actual coverage

Counts below are static names, not dynamic spills. Stack includes eligible
names left uncolored; float-specific XMM placement can supersede GPR homes.

| Captured owner | Rows | Eligible names | Global candidates | Stack homes | Regional Stack locals outside candidates |
| --- | ---: | ---: | ---: | ---: | ---: |
| editdist product.row | 167 | 102 | 32 | 72 | 59 |
| editdist product.row | 99 | 75 | 32 | 45 | 2 |
| tree direct.warp | 182 | 71 | 32 | 43 | 31 |
| ray direct.isect5 | 60 | 53 | 32 | 22 | 19 |
| ray product.nearest | 189 | 119 | 32 | 92 | 66 |
| ray direct.nearest.t | 175 | 113 | 32 | 87 | 66 |
| ray direct.nearest | 207 | 125 | 32 | 100 | 64 |
| borrowed read.Map.bit.go | 74 | 32 | 32 | 0 | 0 |

The last column is an offline replay of existing first-write, same-region,
setup/parameter exclusion rules, conservatively treating every call as a real
call. It is an eligibility census before global occupancy and local-local
conflicts, not an allocation forecast. The row99 function has one additional
regional Stack name already in the global candidate set; the proposed overlay
deliberately excludes it. The profile agent resolved the hot p113d row as placement99/original108,
frame2936B/outgoing144B: it accounts for 98.02% of editdist CPU. The row167
owner is the unsampled p117v fallback, frame3288B/outgoing96B. Thus only two
new locals are regionally eligible in the dominant edit loop before occupancy.

Legacy ray trace/pixel/trace owners have 239/238/245 eligible names and
146/145/144 transient homes respectively. Legacy Map ins/put/seek/pop have
571/282/332/293 eligible names, 458/196/236/216 transient homes, and
2695/1210/1299/1180 rows. Neither a 1024 gate nor a 64/128 candidate graph admits
those Map bodies under their current structural gate. Borrowed Map.bit already
has every counted name homed; increasing the candidate count cannot help it.

## Design A: global-color-aware regional overlay

Preserve the existing 32-name fixed point, interference graph, nine-color
assignment and validator. After installing that assignment, run the existing
regional eligibility scan on remaining noncandidate Stack names. Each local
must begin with a write, remain inside one call-free straight-line region and
have no parameter/setup identity. Only the five caller colors are available;
the saved-color assignments and save policy stay unchanged.

For each actual analysis event compute existing global live-in and live-out
with `x190_l_stmt`/`x190_l_body`, plus explicit writes, including dead writes.
For each local's entire inclusive interval, OR these global-candidate masks.
A physical color is available only if its existing joint color-group mask has
empty intersection with this union and no previously admitted local overlaps.
Checking only names mentioned in a region or occupancy at the first definition
is unsound: a global may be live through the region without being mentioned,
or a later global write may destroy a live local.

The transfer interface must retain the original solved Again header and
parallel parameter mask. Again reserves header|parameters as well as its
ordinary reads. Branch arms receive their common live-out and distinct regional
positions. Inline F32 uses its shared buffer/destination effect contract;
ordinary calls retain existing regional exclusions. This needs no new virtual
register identity, spill insertion, edge copies or executable IR transformation.

The isolated `hybrid/overlay-v2.bend` prototype takes this route. It deliberately
uses repeated existing suffix analyses: quadratic work within the unchanged
256-row gate buys a small implementation and avoids duplicating global transfer
semantics. A positional-count mismatch or failed fixed point returns the
unchanged validated joint frame. It has not been built or run by this agent.

Cheap falsifier: inspect actual admitted homes and hot-loop machine instructions
in editdist, tree, text helpers and ray nearest. If occupancy prevents nearly
all useful admissions, or admissions do not remove executed loads/stores, stop
this variant before qualification. The row99 census already limits expectations
for that owner. Root's output oracles and balanced runtime screen remain needed;
static eligibility cannot establish speedup.

## Design B: a 64/128-name graph, then splitting only if needed

Represent a candidate set as two/four U32 words and widen every operation:
IDs, live/header/parameter sets, graph rows, color groups, affinities, calls,
incoming ABI constraints and final validation. Fixed-point fuel becomes at
least candidate-count+1. Raising candidate fuel alone silently shifts past the
U32 representation and is invalid.

64 names can cover isect5 but still truncate both edit rows, tree warp and all
nearest workers. 128 covers their currently eligible-name counts. It still does
not cover the ray trace family or large Map owners, and it still has only nine
physical colors. More represented names can improve reuse across branches and
loops that Design A conservatively excludes, but does not resolve genuine peak
pressure. Combining widening with a body-gate increase can again destroy legacy
regional coverage unless that coverage is explicitly retained.

Cheap falsifier: replay captured final placement with a wider graph and report
which hot Stack names newly receive homes, their peak simultaneous pressure,
and removed machine loads/stores. A wider graph whose additional hot nodes all
spill is evidence for different lifetime placement or splitting, not another
candidate-count increase. A graph with profitable admissions should first be
screened under the original body gate and measured for compiler request cost.

General live-range splitting is a separate, larger change. Current frames map
one name to one home for the whole function. Splitting requires definition/use
versioning or explicit position-sensitive homes, copies at joins and loops,
and spill/reload placement across calls. It cannot be implemented safely by
changing one frame slot partway through a traversal.

## Recommendation

Test Design A first because it repairs a demonstrated compositional gap while
retaining the existing legality certificate. Its 18 authored controls assert
both hazards and actual admission, so a no-op pass cannot pass solely through
correct outputs. Keep the 256-row gate for its first screen. The dominant edit
owner is row99; its two-local eligibility limit points toward Design B or
lifetime splitting for that case. Do not disguise that limitation with counts
from the cold row. No speedup is
promised by either design. The failed selector-view and gate-only screens
support requiring a visible machine-code mechanism before another expensive
native qualification.

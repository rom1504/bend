# Current N1 tree/BST capture: constructors and resume work, not BST inorder

One controlled18-process capture completed in56.299s, below its60s cap. All
ordinary outputs and pins passed. All six pooled case/role profiles meet the
existing quality policy. The new actionable result is that BST's main descent
worker already costs about the same as QBE, while constructor handling crosses
different inline/helper boundaries. Inorder is a small category, so it is a
poor first optimization target. Tree still has substantial resume and constructor
work. No simulator or new compiler build was needed.

| Physical CPU µs/invocation | N1 x86 | C | QBE |
| --- | ---: | ---: | ---: |
| Complete tree-bitonic | 524.806 | 166.706 | 396.609 |
| tree `p114r warp` | 111.685 | 26.051* | 59.847 |
| tree named ctor2 | 82.589 | — | 0 delivered |
| tree named take2 | 79.839 | — | 70.939 |
| Complete BST64 | 27.884 | 7.360 | 18.582 |
| BST product.down | 8.658 | — | 8.990 |
| BST direct.up | 3.363 | — | 2.550 |
| BST direct.inorder | 0.628 | 0.313* | 0.306 |
| BST named ownership/product helpers, total | 13.653 | — | 5.512 |

These are physical-leaf estimates from one clean denominator per role and two
sample periods, not fresh paired speedup measurements. The starred C leaves are
its `WL_FID` workers; C distributes/inlines work differently. Its active BST
`NF_FID_p37.bst.insert` alone accounts for6.738µs (91.56%). The profiler's generic
`scheduler` label on C `WL_FID` workers is a naming heuristic, not scheduler cost.
Blank entries/zero delivered helper samples never mean zero ownership work.

## Why the BST helper difference cannot be called removable ownership

N1 ctor3/ctor2 cost5.563/1.890µs; take3/take2 cost4.531/1.670µs. QBE has no
delivered constructor-helper samples, but its actual product.down contains inline
free-list constructor hit paths and calls the same helpers on fallback. Its hot
PCs `0x4076f4` and `0x40778b` are allocator-length loads inside those inline paths.
N1 instead directly calls ctor3 at `0x40910d`/`0x4091a0` and ctor2 at
`0x409148`/`0x4091db`. Therefore13.653 versus5.512µs is **physical attribution
across different boundaries**, not8.141µs of removable semantic ownership.
Current N1 down's shorter154-instruction body versus QBE214 partly reflects
this difference. Whole-function instruction count was misleading.

The exact source gate is
[`x185_ctor_enabled`, frozen scalar.bend:217](../../../selfhost/build/phase195/selected-source02/maintained/src/back/x86/scalar.bend):
`def x185_ctor_enabled() -> Bool: False{}`. Its caller can already consume the
shared checked `p185cc` cold-constructor expansion. QBE's sampled implementation
shows the relevant representation mechanism; x86 currently disables it.
Gate, expansion, ELF and prior-experiment pins are retained in
[pc-join.json](tree-bst-profile-results/pc-join.json).

This is not a novel proposal to inline everything. The
[Phase185 guarded constructor comparison](../../../experiments/phase185/P185-006-bound-descriptor.md)
was mixed: approximately3.77% less tree time and1.05% more Map time against its
immediate Boolean/facts parent. The preserved `ctor-qbe-runtime01` receipt labels
those roles **QBE**, not a controlled current-x86 gate test. Later descriptor
facts removed repeated guard checks; final QBE results combine refinements and
cannot be attributed to this gate alone. Phase186 blanket unique-take regressions
are a separate rejected experiment, not evidence for enabling this constructor
switch globally.

## Cheapest next falsifier

A current-source enable/disable test is mechanically small and possible with
existing tools: `prepare-api.py --set x185_ctor_enabled=true`, one freshly checked
hosted API, then existing same-process prepared emission for **tree-bitonic,
BST64 and Map128** (the prior negative transfer control). Use a false-gate sibling
from the same current source; first require its emitted bytes to match the
retained current N1 products. Preserve the shared preparation closure/asset
identity checks, independent cold-constructor oracles, complete ordinary outputs,
original cache-miss fallback and exact published field semantics. Reject if the
selected machine lacks inline hits, introduces damaging spills/code growth, or
paired runtime loses on the transfer control. No benchmark names enter admission.

This needs API acquisition/emission; it is not a ready-to-run60s toggle of an
existing native image. A comparable checked combined API cost15.145s and its
six-case machine build5.771s, excluding preparation/emission/runtime, so a small
hosted screen is plausible without full native self-build. Existing
[prepared-emission](../../../selfhost/tests/phase195/prepared-emission/README.md)
can reuse the prepared inputs. No enabled API or target pair was acquired here.
The current hot-path witness makes this bounded existing-gate falsifier more
useful than building new event instrumentation first. If it is neutral or
negative, count owner-associated constructor/cache-hit/ownership paths before
another representation proposal. No numeric whole-suite gain is forecast.

Tree's earlier SP-snapshot alternative remains independently supported by
warp's111.685µs (21.28%) share and the repeated restore-SP loads. That entire share
is not redundant transport. BST inorder is only2.25%; even deletion of its entire
named leaf would be a small single-workload effect, not a meaningful explanation
of the3.8×C gap. Neither sample set supplies dynamic calls, cache-hit frequencies,
raw/RFC/count-one/shared incidence, hardware stalls or inclusive owner costs.

## Quality, cost and receipts

Pools contain597–602 samples, both8/13ms periods, no rejected captures, no
drops/overruns and at least99.9996358% sampled-thread CPU coverage. Unknown weighted
shares: tree x861.77485%, QBE3.08156%, C0%; all BST roles0%. Those tree pools pass
the maintained generic policy but fail a stricter zero-unknown interpretation.
Individual captures remain below500, so raw `profilesUsable:false` is correct;
pooling does not rewrite that flag. Sampled/clean wall ratios0.986817–1.004631
include measurement variation, not negative sampling overhead or confidence bounds.

Targets used53.780s CPU/53.798s elapsed in total; guard wall56.299s includes
supervision/analysis. Guard sampled23.17MiB peak tree RSS and2.16MiB declared-root
allocation under64MiB, keeping5GiB disk reserve. No timeout or retry occurred.
CPU3 was released before offline attribution. Retention is sealed `completed`,
capture kept hot, no pruning. Source integration was released only after all
live input checks, maintained comparison, normalization and closure finished.

[Normalized results](tree-bst-profile-results/per-invocation.json),
[raw capture receipt](tree-bst-profile-results/capture.json),
[comparison](tree-bst-profile-results/comparison.json),
[guard](tree-bst-profile-results/guard.json),
[retention](tree-bst-profile-results/retention.json), all12 analysis snapshots,
and exact helper/C-worker disassemblies are retained together. The offline
[PC-join script](analyze-tree-bst.py) executes objdump only. The original raw
samples, map snapshots and output files remain under
`selfhost/build/phase195/profile-tree-bst01`; preparation and role-specific
denominators remain in the [frozen plan](tree-bst-profile-plan/README.md).

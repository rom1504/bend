# Phase195 independent parity decision audit

Baseline `5c67ac5`, 2026-11-14. Read-only source/evidence analysis; no builds,
target executions, profiles or subagents. Calculations below use the exact
per-case medians in [Phase194 runtime summary](../../implementation/phase194/runtime-summary.json)
and unchanged native45 family assignments. They are conditional accounting,
not speed forecasts. Ray/F32, edit-distance selection and ownership experiments
remain independently owned; this audit does not implement competing versions.

## Parity requires breadth, not just larger local wins

The baseline geometric ratio is 1.971034 across 44 timed cases. Uniform parity
would require **49.27% less runtime**. In log space the required saving is
`44 × ln(1.971034) = 29.85656`. The positive deficits sum to35.57365; therefore
83.93% of current positive log deficits must disappear if already-faster cases
keep their current performance. Existing very large closure wins already
subsidize this aggregate. Parity does not mean every program is at least as fast
as C, and losing those wins would materially change the target.

Under a deliberately optimistic but finite assumption—affected slow cases reach
C exactly, unaffected cases retain their current time—the best available case
ordering needs **at least28 cases across13 families**. For the separate equal-
family score, currently2.044576 across22 families, at least15 optimally chosen
families must reach their family geometric C parity. These are different
weightings, not interchangeable counts. Unlimited speedup on one case has no
positive geometric floor; the finite C-parity assumption is essential.

| Affected set | Cases / families | Removable positive log deficit if all reach C | Fraction of required aggregate saving | Remaining suite ratio |
| --- | ---: | ---: | ---: | ---: |
| Ray + numeric + Mandelbrot | 8 / 3 | 6.60575 | 22.1% | 1.69626× |
| Editdist + local-pair | 4 / 2 | 3.92073 | 13.1% | 1.80300× |
| Both sets above | 12 / 5 | 10.52648 | 35.3% | 1.55165× |
| Map churn + BST + tree + record aggregation | 9 / 4 | 10.86671 | 36.4% | 1.53970× |
| Broader ownership-shaped set, below | 19 / 11 | 21.38909 | 71.6% | 1.21221× |

The broader ownership set adds lexer, Unicode, morning/evening, map-set-ops,
RLE and generic-row to the preceding four families. This grouping is a research
coverage hypothesis, **not evidence that ownership explains all their deficits**.
Even the first two sets plus the narrower ownership set—all21 cases brought to
C—would leave approximately1.212× overall. The present three lanes need transfer
beyond their named exemplars, or substantially better-than-C results, to close
parity in one campaign.

An alternative calculation avoids identifying C deficits: a uniform2× speedup
must affect44 cases to reach parity;3× must affect at least28;4× at least22.
If only12 cases improve, their geometric speedup must be12.04× to reach parity
with all other cases unchanged. Modest10–25% wins in several kernels are useful
progress but cannot substantiate a whole-suite parity forecast.

Matching every QBE time would give1.348552× C, a31.58% reduction from current x86,
still requiring another25.85% reduction to reach C. QBE is a useful machine/
representation comparator, not the parity target. Replacing only slower x86
cases with their QBE times in the F32 group leaves1.79551× overall; doing so for
editdist/pair leaves1.84283×; both together leave1.67873×. These hypothetical
envelopes preserve x86 where it already wins and are not one implementable backend.

## Where the deficit actually sits

| Family | Cases | x86/C family geometric ratio | QBE/C | Positive case-log deficit |
| --- | ---: | ---: | ---: | ---: |
| tree-bitonic | 3 | 3.186 | 2.419 | 3.476 |
| Mandelbrot | 3 | 2.997 | 1.822 | 3.293 |
| editdist | 3 | 2.675 | 1.279 | 2.952 |
| lexer | 3 | 2.662 | 2.014 | 2.938 |
| BST | 2 | 3.949 | 2.618 | 2.747 |
| raytrace | 3 | 2.344 | 0.982 | 2.556 |
| map churn | 2 | 3.564 | 2.701 | 2.542 |
| local-fold | 3 | 2.243 | 2.213 | 2.423 |
| record aggregation | 2 | 2.860 | 2.287 | 2.102 |
| numeric recurrence | 2 | 1.460 | 1.507 | 0.757 |

Ray and editdist show a large specifically x86/QBE gap. Numeric already beats
QBE geometrically; further work there must outperform the retained QBE result,
and its total remaining C deficit is comparatively small. Local-fold is nearly
QBE-equivalent: a scalar selector improvement alone must exceed both backends'
current loop quality. Tree/Map/BST/records have both machine and shared lowering
deficits. Their large ratios cannot be priced as removable ownership overhead
without current dynamic evidence.

## Overlooked architectural risk: allocation admission cliffs

The highest-value independent falsifier is whether broad composition repeatedly
pushes important functions out of joint allocation:

- `x190_joint_frame` in `loop-liveness.bend` admits at most256 setup/body rows and
  64 parameters. The joint graph selects at most32 candidate names, represented
  by U32 masks. It then uses nine colors: four saved and five caller registers.
- Above the row bound, `x190_allocate_legacy` first assigns four distinct global
  saved homes. Its caller-liveness path has the same256-row bound, so remaining
  allocation falls to `x185_transient_frame`: five homes for closed regions,
  with parameters/setup definitions excluded. This is a qualitative loss of
  cross-control sharing, not merely one fewer register.
- Fresh F32 identities increase candidate-name pressure; public continuation
  fusion increases row counts. The Phase193 profitability cap limits growth,
  but does not certify that an expanded function stays within allocation bounds.
  More inlining can therefore remove calls while making unrelated hot state spill.

The retained Phase194 preselection dump contains ray `product.nearest`287 rows,
`direct.nearest.t`277, `direct.nearest`305 and `direct.pixel`545; numeric31 and
the two row-worker shapes171/108 are below256. These are **preparation-stage
counts**, not the final post-pruning/selected-placement admission counts. Six
of184 captured ray functions exceed256 there. This supports measuring the actual
admission boundary, not claiming those six necessarily fall back at final emission.

Smallest falsifier: instrument or inspect final placement for these existing
owners, recording the exact refusal reason, candidate names, hot spills and
callee/caller homes. Compare one bounded admission experiment against the same
verified graph and original fallback; do not widen the 32-bit candidate mask by
changing a constant. If final pruning already brings all hot owners inside the
bound, reject this explanation immediately. If it does not, examine hot-region
allocation or an appropriately bounded larger representation before adding more
independent peepholes. Coordinate with the current register-selection lane.

## Conservative ABI/frame costs: real source facts, unpriced benefit

`x181_frame` reserves2048 scratch bytes,64 result-buffer bytes, tail staging and
a slot for each local before register assignment. Outgoing calls reserve16 bytes
per argument. Hidden state owns R12 even in many scalar workers. Any transient
argument makes `x186_call_arguments` snapshot **all** call arguments before ABI
placement. These are plausible broad costs on call-heavy workers; the current
argument/physical representation is conservative rather than ABI-minimal.

But a large reserved frame is not equivalent to touching that memory, and one
SUB of RSP does not cost proportionally to its immediate. Saved-register masks
already avoid unnecessary saves, and direct call arguments already bypass
snapshots when safe. Phase191 removed1,071 static snapshot sites/7,036 static
stack instructions for only about0.56% geometric benefit. Repeat blanket frame
or argument cleanup only with a new dynamic caller witness. A state-independent
leaf register pool is a bounded hypothesis, already documented in Phase194;
it is not an unexplored universal speedup.

The Phase192 caution still applies: the formerly slow expression eval leaf was
already close to C while continuations/dispatch dominated its whole computation.
Its final Phase194 family ratio is now1.128, showing that old hotspot shares must
not be carried forward as current removable-time budgets. No Phase194 physical
sampling establishes how much time the current allocator, spills, flags, heap
reconstruction, instruction front end or cache behavior consumes.

## Decisions that would change this audit

For each lane, retain a three-part claim: exact selected owner changes; fresh
whole-program off/on gain; demonstrated family coverage. Estimate dynamic
removable share before promising a large factor: even infinitely accelerating
a component taking30% of runtime yields at most1.43× for that program. A 2×
whole-program gain needs at least50% removable time. Static instruction/stack
counts are neither those shares nor latency measurements.

Prioritize ray/editdist for x86-specific transfer, and ownership/region retention
for wider family coverage. Use final allocation refusal evidence as a competing
architectural explanation, especially when call elimination enlarges a worker.
Keep all three scorecards—case geometric, equal-family and positive-log deficit—
so a few duplicated families or already-superfast closures cannot hide remaining
broad deficits. A large, repeatable win on one owner earns expansion; it does not
by itself establish the required coverage for parity.

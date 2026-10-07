# State08: where the remaining compilation time goes

The current stage survey points to **loading/prepared-state transport and the
backend**, rather than a uniformly slower checker. Across 23 sources, arithmetic
mean compilation time is 964.64 ms for State08 B2 and 454.44 ms for pinned
TypeScript in these diagnostic runs. Of the 510.20 ms difference, 265.99 ms is
before the backend, 241.55 ms is in the backend and 2.65 ms is other request work.
The standalone check/completion boundary averages almost the same time on both
sides. This is a description of current work, not a compiler speed improvement.

[Compact evidence](evidence/stages-summary.json) ·
[Measurement method](stages-method.md) ·
[Raw broad report](../../selfhost/build/phase62/generations01/stages46/report.json) ·
[Disjoint reader output](../../selfhost/build/phase62/generations01/stages46-analysis/summary.json).

![Current compilation cost and per-source excess milliseconds](figures/stages-costs.svg)

## What was measured

The broad survey passed **46/46 fresh workers**: 23 inputs × State08 B2 and pinned
TS × one diagnostic run. It took **59.000708 s** supervised campaign wall time.
The preceding two-source screen passed 4/4 workers in 6.084251 s. All 50 workers
retain complete raw module byte comparison with their qualified role-specific
oracle. Every diagnostic clock partition closes with zero incomplete events.
No program-runtime benchmark or compiler-source modification occurred here.

These are the same genuine B2 image, prepared Base caches, source set and ordinary
library request used by the current generation comparison. The private host
copy adds nested clocks; TS retains its original modules with worker clocks
around `book_load`, `book_valid` and `js_lib`. Import/API startup is outside the
compilation totals below. All totals are exclusive, avoiding nested double counts.

The means below are **arithmetic equal-source milliseconds**, useful for a cost
account. They are not a replacement for the clean benchmark's geometric mean
speed ratio. One diagnostic sample per cell cannot establish significance or
attribute the effect of an optimization. GC and scheduler pauses belong to the
interval in which they occur and are not separately subtracted.

## Cost account

| Request work | B2 mean ms | TS mean ms | B2 minus TS ms |
|---|---:|---:|---:|
| Prepared Base transport and admission | 173.42 | — | 173.42 |
| Source loading/completion | 255.07 | 161.53 | 93.54 |
| Checking/completion | 171.94 | 172.91 | -0.97 |
| Full backend | 361.31 | 119.75 | 241.55 |
| Other request work | 2.90 | 0.25 | 2.65 |
| **Total compilation** | **964.64** | **454.44** | **510.20** |

**The cache row is not a claim that its entire cost is avoidable or additional
semantic work.** Bend loads previously checked Base state; TS parses and checks
Base within its load/check rows. The useful comparable aggregate is prepared
state + loading + checking: 600.43 ms for B2 versus 334.44 ms for TS. The measured
check boundary alone is lower for B2 on 13/23 inputs, but that benefit includes
using prepared Base state. This does not prove that equal individual checker
operations are equally fast.

Backend time includes roots, context, reachability, annotation, layout validation,
foreign-source handling, host export conversion and text emission. It is not
solely string generation. TS places its corresponding preparation and emission
inside `js_lib`; its inner passes are not separately timed here.

## Prepared state is a large, nearly fixed floor

The cache group ranges from 165.72 to 197.81 ms across the 23 inputs. Its mean
173.42 ms breaks down as follows; these are exclusive disjoint contributions:

| Cache work | Mean ms |
|---|---:|
| Book JSON conversion/parsing | 65.35 |
| Checked-prefix JSON conversion/parsing | 23.32 |
| Header/fresh-state JSON conversion/parsing | 0.10 |
| Book and checked-state tree validation | 52.02 |
| Book/state segment digests | 16.23 |
| API/Base identity and Base source reading | 12.63 |
| Cache file read | 1.75 |
| Remaining metadata, shape checks and admission | 2.02 |

The main costs are creating and validating object graphs, not disk reading.
Reducing file size by itself is therefore an incomplete hypothesis. The earlier
binary codec rejection remains relevant; it must not be revived solely because
this row is large. A persistent compiler process that can safely keep admitted
state is a separate iteration-loop opportunity, but its warm-request result must
remain distinct from the current fresh-process metric. TS must receive an
explicitly comparable lifecycle experiment.

This fixed floor is particularly important for small sources. It does not explain
why MapSet/Evening and ray tracing accumulate different larger costs.

## Loading remains costly after prefix improvements

| Bend loader work | Mean ms |
|---|---:|
| Prefix-aware source completion | 160.83 |
| Prefix-aware freshening/trace construction | 62.64 |
| Source headers | 18.10 |
| Source span validation | 11.70 |
| Loader residual | 1.79 |
| **Total** | **255.07** |

Source completion includes parser/resolution/completion work reached through the
existing contextual API. It is not a timing of the parser alone. Freshening still
costs roughly 63 ms despite the selected prefix state, maximum-bound hoisting and
leaf reuse. Work counters should establish what is traversed or reconstructed
before attempting another freshening optimization. The loader residual includes
unclocked generated API calls as well as JavaScript host work; its `driver.*`
label does not establish language ownership.

These observations favor measuring reconstruction and repeated traversal in
completion/freshening rather than assuming that the remaining frontend deficit
comes mostly from checking dependent types.

## Backend excess is broad, with different emphasis by input

| Bend backend work | Mean ms |
|---|---:|
| Emitted dependency reachability | 153.36 |
| Final library emission/export conversion | 104.29 |
| Annotation | 33.70 |
| Layout validation | 23.79 |
| Context construction | 13.42 |
| Source reachability | 10.96 |
| Roots/stops | 10.83 |
| Owned-layout validation | 10.12 |
| Other backend/foreign/assembly work | 0.84 |
| **Total** | **361.31** |

Emitted reachability and final library generation together take 257.65 ms on
average, about 27% of this diagnostic compilation total. That is an investigation
priority, not a prediction that all of it can disappear. Prior emission-reuse
work showed real context differences and did not prove a generally safe cache.
The next evidence must identify repeated results and the actual book/type
lookups on which they depend, not reuse text solely because corpus outputs match.

The table below shows the actual per-input difference. Loading/Base/checking are
combined to avoid falsely equating their individual inner stages. Tiny other
request differences make up the remaining total.

| Input | Total extra ms | Loading/Base/checking extra ms | Backend extra ms |
|---|---:|---:|---:|
| test-map-set-ops | 928.7 | 324.5 | 601.0 |
| raytrace-active | 778.9 | 552.7 | 223.6 |
| raytrace | 731.2 | 498.1 | 227.5 |
| test-evening-program | 722.0 | 173.0 | 546.5 |
| test-morning-program | 613.5 | 261.2 | 349.0 |
| mandelbrot-grid | 611.8 | 396.0 | 213.3 |
| map-churn | 605.9 | 215.6 | 387.7 |
| lexer | 559.4 | 293.9 | 263.0 |
| record-aggregation | 553.8 | 183.5 | 367.6 |
| unicode-text | 549.8 | 296.6 | 250.7 |
| list-pipeline | 545.1 | 231.5 | 311.0 |
| mandelbrot | 525.5 | 332.9 | 190.1 |
| symreg | 509.4 | 296.0 | 211.0 |
| local-row | 489.9 | 272.1 | 215.3 |
| tree-bitonic | 478.0 | 281.3 | 194.3 |
| editdist | 469.5 | 281.5 | 185.5 |
| bst | 411.0 | 226.4 | 182.2 |
| test-rle-roundtrip | 406.4 | 242.6 | 161.4 |
| expression | 322.5 | 203.1 | 117.1 |
| closures | 265.1 | 185.3 | 77.6 |
| local-fold | 257.0 | 133.8 | 120.9 |
| scalar-region | 239.3 | 148.6 | 88.5 |
| numeric-recurrence | 160.9 | 87.7 | 71.0 |

Backend differences account for 28.7–75.7% of the per-source compilation gap.
MapSet, Evening, MapChurn and record aggregation have especially strong backend
components. Ray tracing has a larger pre-backend component. The next change
should therefore be screened on both categories, plus a small Numeric case;
optimizing only one family would miss a substantial part of the remaining work.

## Perturbation and limits

The broad diagnostic request differs from the separate clean three-round median
as follows. These differences combine instrumentation effects and ordinary
between-run variation; they are not an isolated timer-overhead measurement.

| Input | B2 diagnostic vs clean | TS diagnostic vs clean |
|---|---:|---:|
| numeric-recurrence | +0.7% | -0.4% |
| test-map-set-ops | +0.6% | +2.8% |
| lexer | +0.8% | +0.3% |
| raytrace-active | +10.7% | +4.2% |

Raytrace-active has a material +10.7% B2 difference, so its exact stage
milliseconds need particular caution. Source order and role order were fixed in
this single diagnostic round. The clean balanced comparison remains the speed
result. Sampling profiles and work counters should support each proposed
mechanism before attributing speed to a phase.

The first plot producer wrote its valid numeric summary but failed during figure
output because a local axes variable shadowed its command-line arguments. The
original producer and partial `stages-report01` remain preserved. The recorded
one-line repair in `report-v2.derivation.json` produced `stages-report02`; its PNG
was visually inspected and both PNG/SVG plus the compact evidence were copied
without changes. This was a data-plotting failure, not a compiler or stage-worker
failure.

## What this changes about the next optimization

1. Treat the pre-backend and backend gaps as two substantial targets. Even matching
   TS backend time would leave a large frontend/transport difference in this cost
   account. A backend-only plan does not cover the current overall gap.
2. On the frontend, investigate object reconstruction and traversals during
   prepared-state admission, completion and freshening. Keep the actual source
   of Base savings explicit; never weaken cache validation by treating a content
   hash as a proof of checking.
3. On the backend, trace repeated analysis/emission results and the real semantic
   dependencies of each query. This can support a correct reusable per-definition
   result, but neither the current stage totals nor earlier matching output text
   establish that design's safety or gain.
4. Use Numeric plus MapSet and raytrace-active as a compact screen covering the
   fixed floor and the two larger cost patterns. Recheck all 23 only after a
   mechanism has shown a clean improvement with unchanged output and semantics.

No optimization or promotion is made by this survey. The result is a measured
priority shift: the standalone checker boundary is no longer where most of the
remaining request-level excess sits.

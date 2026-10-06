# Source accounting and backend boundaries

Checked graph02 adds **108 physical lines (0.413%)** and **75 code lines
(0.348%)** over installed Phase53 ordered02. It moves existing helpers into
explicit common/JS utility modules and replaces repeated call-graph closure
analysis. This is an ownership and algorithm improvement, not a whole-compiler
line reduction. Legacy JavaScript and native C remain supported source paths.

This report accounts for the frozen `checked-graph02` candidate. Its checked
build and independent graph controls pass. The [phase report](README.md) owns
whole-backend qualification and installation. Full direct compiler-image emission
and self-reproduction remain **unqualified**; graph capacity is not a bootstrap
result. The [backend boundary guide](../../docs/self_hosted/backend-boundaries.md)
describes the implemented architecture and explicitly separates future IR work.

## Method and exact totals

The unchanged [Phase47 method](../../selfhost/tools/performance/phase47/measure-size.py)
counts `splitlines()` for physical lines, nonblank lines excluding leading `#`
comments for code, and leading `def`, `law` and `type` declarations. Counts cover
only manifest-listed Bend files. Definitions are textual declarations, not a
count of independent concepts. Runtime JavaScript and compiler images are separate.

The preserved data-only producer is
`selfhost/build/phase54/architecture01/count.py`; its fresh `inventory.json`
contains each module's bytes, hashes and counts, all changed-module deltas and
the consumed identities. It imports only the counting method, never a compiler
or generated program. It verifies both frozen attempt manifests, every module
against its frozen hash, the candidate's live counterparts, and all consumed
inputs again before writing the report. All **339 identities** remained unchanged.

| Measure | Phase53 ordered02 | Phase54 graph02 | Change |
| --- | ---: | ---: | ---: |
| Manifest Bend modules | 103 | 107 | +4 |
| Physical lines | 26,151 | 26,259 | +108 |
| Code lines | 21,523 | 21,598 | +75 |
| Definitions | 3,004 | 3,015 | +11 |
| Laws | 629 | 629 | 0 |
| Types | 99 | 100 | +1 |
| Bend source bytes | 1,175,720 | 1,181,194 | +5,474 |
| Direct-backend modules | 11 | 11 | 0 |
| Direct-backend physical lines | 2,489 | 2,583 | +94 |
| Direct-backend code lines | 2,034 | 2,105 | +71 |
| Direct-backend definitions | 331 | 342 | +11 |
| Direct-backend types | 12 | 13 | +1 |

The helper move contributes **+14 physical / +4 code lines**, with no new
definitions, laws or types. The four code lines are module imports; moved
definition/law bodies remain exact. The graph/capacity change contributes
**+94 physical / +71 code lines**, +11 definitions and one type. The earlier
helper snapshot's +19 physical count preceded removal of five EOF blank lines;
it remains historical evidence in the [helper report](shared-helpers.md).

| Changed module, relative to `src/back/` | Physical before → after | Code before → after | Definitions before → after |
| --- | ---: | ---: | ---: |
| `common/literals.bend` | 0 → 53 | 0 → 39 | 0 → 6 |
| `common/native-facts.bend` | 0 → 18 | 0 → 14 | 0 → 2 |
| `common/queries.bend` | 0 → 205 | 0 → 168 | 0 → 19 |
| `js/shared-text.bend` | 0 → 75 | 0 → 63 | 0 → 7 |
| `js/emit.bend` | 956 → 715 | 787 → 586 | 88 → 66 |
| `js/foreign.bend` | 168 → 158 | 139 → 130 | 17 → 16 |
| `js/literals.bend` | 189 → 144 | 150 → 115 | 19 → 14 |
| `js/private-float.bend` | 35 → 18 | 25 → 11 | 5 → 2 |
| `js/u32.bend` | 110 → 95 | 89 → 76 | 15 → 13 |
| `js/validate.bend` | 305 → 296 | 249 → 241 | 26 → 25 |
| `js/direct/calls.bend` | 341 → 435 | 275 → 346 | 50 → 61 |
| `js/direct/reach.bend` | 102 → 102 | 82 → 82 | 12 → 12 |

All **95 other original modules are byte-identical**. All 107 live Bend modules
and the live manifest match graph02. In particular, all **17 native modules**
remain exact: 2,092 physical lines, 1,745 code lines, 286 definitions, 41 laws,
17 types and 96,752 bytes. Their erasure, uniform-word representation,
continuations, direct calls and CPU/device support were not removed or rewritten.

| Separate artifact | Phase53 | Graph02 | Change |
| --- | ---: | ---: | ---: |
| Direct runtime lines / bytes | 471 / 13,212 | 471 / 13,212 | 0 |
| Legacy runtime lines / bytes | 721 / 57,500 | 721 / 57,500 | 0 |
| Typed driver lines / bytes | 761 / 53,800 | 761 / 53,800 | 0 |
| Checked bootstrap API bytes | 1,791,533 | 1,805,276 | +13,743 |
| Derived compiler API bytes | 1,814,920 | 1,828,672 | +13,752 |

Both runtimes and the typed driver are byte-identical and match live source.
Two separate maintained host commands now explicitly request legacy compiler
images; the [routing report](routing.md) covers those changes outside the Bend
manifest. Compiler-image bytes are not emitted user-module bytes or execution time.

## Conceptual tradeoff

The helper extraction adds no new proof or transformation. It gives **27 existing
semantic queries** a common owner and **seven JS text helpers** a JS utility
owner. Direct lowering no longer reaches through legacy planning files for these
helpers. The existing names and callers remain; provenance and type checks stay
with their consumers. Native lowering is retained, not mechanically changed to
consume every extracted helper.

Graph planning removes one expensive representation: a transitive reachable set
and index for each definition. It uses forward/reverse adjacency, explicit DFS
worklists, one ordered member list per SCC and per-name leader/ID/bounce facts.
Reverse propagation from unknown-tail seeds replaces repeated reach scans.
Graph visits and retained graph data become `O(V + E)`, excluding name-index
costs and typed source normalization. The extra source implements those bounded
worklists and refusal checks; it is not another parallel optimizer.

The graph remains in the direct backend because its edges, unknown-tail seeds
and indexed metadata currently have one target-specific consumer. Existing query
interfaces and component order remain stable. A neutral graph module or universal
runtime IR would add an unused abstraction here.

The shared definition budget rises from 512 to **4,096**. The graph's independent
4,194,304-edge ceiling replaces the old 65,536-work-item limit per reachable
closure, so admission is deliberately not identical. Exact emitted reach retains
its separate 65,536 queued-name and 2,097,152-character-per-definition bounds.
Repeated exact-reach emission, selected-book overlays and duplicated per-entry
SCC output remain potential costs. No whole-compiler throughput improvement or
successful direct self-emission follows from the asymptotic graph change alone.

## Qualification and reproducibility

`build-graph02/run.json` records one checked development workflow: **59.889105 s**,
peak supervised process-tree RSS **1,529,864,192 bytes**, within its 2 GiB limit.
This is one development-loop observation, not a paired throughput measurement.
`graph02-parity01/report.json` passes 15 independent graph cases;
`graph02-boundaries01/report.json` passes ten explicit budget/refusal cases.
These scopes overlap and are not added into a unique test total. Earlier sparse
diagnostics through 3,004 rows and their limits are in [scaling.md](scaling.md).
None executes a generated compiler image or proves worst-case dense memory use.

To reproduce the source inventory, use the retained producer and its unchanged
Phase47 method against the two frozen attempts. It writes only a fresh sibling
`inventory.json`; an existing output is deliberately rejected. Copy only the
producer to a fresh same-depth Phase54 raw directory before rerunning.
Set `PYTHONDONTWRITEBYTECODE=1` for replay to avoid creating Python import caches.
The original command was:

```sh
taskset -c 0 python3 selfhost/build/phase54/architecture01/count.py
```

| Input or receipt | SHA-256 |
| --- | --- |
| Count method | `8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681` |
| Phase53 attempt | `c8e1a28b53d42a44eb7d8ebe69a17fa52967359019ea8eac7bd02671e961ba0f` |
| Graph02 attempt | `594381ea67444070290efeb516458997c528829f9cd4b65385109afc2d0d4a76` |
| Graph02 manifest | `0b47088a0e189d832f3c79ee6bc6013069508a3844290b240e2b4eb710d01867` |
| Graph02 API | `d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857` |
| Source inventory | `2403fb360d694caaa7030f0ae4a26f5ce20d2b950e4f6efab264083022e999ce` |

This audit ran only data reads/counts on CPU0. It made no source, historical
evidence, compiler-output or installation changes. Later source revisions need
a fresh accounting checkpoint rather than edits to the consumed inventory.

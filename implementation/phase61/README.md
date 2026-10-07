# Phase61: compiler architecture experiments

The first combined candidate passes its checked build and focused controls and
has produced a genuine 77-export B2. A two-source pilot and a separate three-source
confirmation show small improvements against the installed Phase58 B2. They do **not** establish a
population speedup, final compiler qualification or release admission. The
installed release remains Phase58 last01.

This is an incremental report for source checkpoint
`f17585c92399aa4dd90aa791945eaa9f4c478949` (“Prototype lazy telescopes and batched
compiler context updates”). Later text-transport and Base-checkpoint candidates
must carry their own identities and results. The
[design](../../design/phase61/architectural-compiler-speed.md) sets the broader
objective; [validation commands](../../selfhost/tools/performance/phase61/validation/README.md)
keep prototype gates separate from the single selected integration matrix.

## First candidate evidence

`checked-candidate01` is an equality-derived checked B1. Its API SHA256 is
`5ea72da4a30e3c78a3854d3b98edb0dce3760986a710a908a4159869996d9881`;
the [attempt](../../selfhost/build/phase61/checked-candidate01/attempt.json) SHA256
is `dd410f5ac59a392804983d6a3cca07979ca1b1c8ec94dca6d9870a92d3e14764`.

| Completed gate | Result and scope |
|---|---|
| [Checked build](../../selfhost/build/phase61/checked-candidate01/validation-001/report.json) | 36 selected probes per role, zero exact differences; selected coverage only |
| [Telescope controls](../../selfhost/build/phase61/telescope-controls01/report.json) | 24 fill and 20 check cases per role; complete term/world/use/error comparisons |
| [Batch-index controls](../../selfhost/build/phase61/index-controls01/report.json) | 12 rows; sequential insertion equivalence and actual caller activation |
| [Primitive controls02](../../selfhost/build/phase61/primitive-controls02/report.json) | 100 metadata rows and 630 admission rows; independent canonical oracle and checked-image probes |
| [Seed controls](../../selfhost/build/phase61/seed-controls01/report.json) | 27 primitive-string equality and 10 binding cases per role; exact name/path/text binding retained |
| [Own-source construction](../../selfhost/build/phase61/bootstrap-candidate02/full/report.json) | Actual B1 emits a 77-root B2 using inherited exact-source checking |
| [Driver join](../../selfhost/build/phase61/bootstrap-candidate02/driver-comparison.json) | Eight source/direct observations agree; tiny split/unsplit equality also passed |
| [Preservation](../../selfhost/build/phase61/preservation-start.json) | Seven installed files, 32,973 closed Phase58–60 files and protected103 unchanged |

The first B2 is 3,854,951 bytes, SHA256
`5975ebcbd472da77026f5a1b10352548aacb4f3d3b3f2afc74b9d7af54af28c9`.
Its source assembly SHA256 is
`59b7a66f4d36326ff2346b955c6dde4ab1f02d34c5a16e6772d774e58c5791bf`.
The [six-command bootstrap stage](../../selfhost/build/phase61/bootstrap-candidate02-execution/report.json)
completed successfully. Full construction took 92.975 seconds under its
supervisor; the whole stage took 153.859 seconds. These include checks and
provenance work and are not warmed compiler throughput. Fresh B2 self-check,
B3 fixed-point, broad semantics and final release gates have not been claimed.

## First B2 latency pilot

The [completed screen45 report](../../selfhost/build/phase61/candidate-b2-latency01/screen45/report.json)
contains six successful fresh workers: two sources × three roles × one round,
with zero later requests. The table reports host import + API load + first
library request, in milliseconds. Each “median” is therefore one observation.

| Compile input | Phase58 B2 | Candidate01 B2 | Pinned TypeScript | Candidate / Phase58 |
|---|---:|---:|---:|---:|
| numeric-recurrence | 1,254.915 | 1,227.884 | 611.052 | 0.9785 |
| test-map-set-ops | 2,729.360 | 2,594.458 | 892.342 | 0.9506 |

The process completed in 25.359 seconds. Fresh emitted bytes matched the retained
qualified raw-module oracles; no generated-program runtime values were executed
again. Preparation and reusable Base setup are outside these request windows.
This small pilot does not isolate the contributions of telescope, index,
primitive selection or seed comparison changes, and is not pooled with any
historical campaign. The full23 compiler population and held-out inputs remain
separate decisions.

The separate [confirm90 report](../../selfhost/build/phase61/candidate-b2-latency01/confirm90/report.json)
passed all 18 fresh workers: three sources × three roles × two rotated rounds,
again with zero later requests. It completed in 77.360 seconds. Medians of the
two combined first-request observations are:

| Compile input | Phase58 B2, ms | Candidate01 B2, ms | TypeScript, ms | Candidate / Phase58 |
|---|---:|---:|---:|---:|
| numeric-recurrence | 1,362.652 | 1,359.009 | 670.107 | 0.9973 |
| test-map-set-ops | 2,830.411 | 2,630.139 | 879.934 | 0.9292 |
| raytrace-active | 2,152.571 | 2,043.071 | 822.556 | 0.9491 |

The equal-source geometric mean of these three candidate/baseline ratios is
**0.958144**, or 4.19% less observed combined latency. This is a small confirmation
set, not all23 inputs. Neither samples nor ratios are pooled with the earlier
pilot; fresh emitted-byte checks passed in every worker.

## Preserved failures and limits

- [Primitive controls01](../../selfhost/build/phase61/primitive-controls01/report.json)
  failed a controller precondition: the requested private `jd_primitive_table`
  helper was absent from the image. The failure stays retained; controls02 uses
  the independent canonical oracle. It is not a compiler-semantic failure.
- The [B1 screen20](../../selfhost/build/phase61/candidate-b1-latency01/screen20/report.json)
  exhausted its deadline after three of four workers. The candidate MapSet cell
  is incomplete and the report has `pass:false`; no two-source B1 speed result
  is inferred from the surviving cells.
- The [first bootstrap plan](../../selfhost/build/phase61/bootstrap-plan01-failure.json)
  rejected changed `jd_selected_context` source before target execution. The
  [reviewed v2 producer](../../selfhost/tools/performance/phase61/validation/prepare-candidate-v2.py)
  admits only the exact old body or the exact `book_put_many(book, defs)` body,
  calls the actual selected helper and retains tiny split/unsplit equality.

The [Base-state probe](../../selfhost/build/phase61/prefix-base-probe01/report.json)
measured 621.896 ms for its instrumented baseline Base check. It found an empty
memo and no generated names, but fresh state advanced from 3,412 to 3,967:
**555 identifiers were consumed**. This refutes a zero-state-change shortcut;
a checkpoint needs authenticated restoration of the actual checker state and
appropriate source/cache binding. The diagnostic duration is not a clean speed
measurement or permission to skip checking.

## Text transport and subsequent state prototype

The first text build rejected a nested parameter match
([diagnostic](../../selfhost/build/phase61/checked-text01/bootstrap/stderr));
[checked-text02](../../selfhost/build/phase61/checked-text02/validation-001/report.json)
then passed 36 strict observations with zero differences. Its
[six-command bootstrap](../../selfhost/build/phase61/bootstrap-text02-execution/report.json)
passed tiny split/unsplit equality and the eight-driver join. The resulting
77-root B2 is 3,893,773 bytes, SHA256
`505e3d2beaf1392ca472c36778190c02278cf30d93a86118e68e1ae2527ca5f3`.
Full construction took 82.307 supervised seconds (82.114 internal); comparison
with the earlier 92.975-second construction is an uncontrolled observation on
different sources, not an isolated text-transport speedup.

[Small controls02](../../selfhost/build/phase61/jdtext-small02/report.json)
passed 28 text goldens, 1,065 split variants, four USE identifiers and three
skew/shared-structure checks in 13.566 supervised seconds. They compare actual
checked helpers with independent goldens and the old scanner. Splits are at
code-point boundaries, not within UTF-16 surrogate pairs.

Two incomplete cap attempts remain retained. The
[combined B1 controller](../../selfhost/build/phase61/jdtext-controls01/report.json)
recorded all 28 small goldens but no completed cap row before its 120.064-second
timeout. Its sparse progress cannot identify the exact stalled operation. The
[separate B2 cap attempt](../../selfhost/build/phase61/jdtext-caps-b2-01/report.json)
timed out after 60.094 seconds while the **baseline old scanner** was processing
2,097,151 characters; it never reached a candidate cap scan. Neither timeout is
a candidate semantic counterexample. The reviewed successor separates full-size
candidate checks with independent goldens from bounded old-scanner comparisons;
its result is not credited until completed.

The separate [text02 confirm60](../../selfhost/build/phase61/text02-b2-latency01/confirm60/report.json)
passed 12 workers: three sources × two roles × two rotated rounds, first request
only. Its baseline is the installed Phase58 B2; TypeScript was not rerun.

| Compile input | Phase58 B2, ms | Text02 B2, ms | Text02 / Phase58 |
|---|---:|---:|---:|
| numeric-recurrence | 1,242.195 | 1,226.150 | 0.9871 |
| test-map-set-ops | 2,693.732 | 2,552.186 | 0.9475 |
| raytrace-active | 2,146.782 | 1,989.983 | 0.9270 |

The equal-source geometric mean is **0.953508**, or 4.65% less combined latency
in this campaign. Whole campaign wall was 55.013 seconds. These samples are not
pooled with candidate01's confirmation, and the difference between their two
aggregate ratios does not isolate text transport's contribution.

The combined Base/loader state prototype adds four optional roots and a framed
cache. Its first [state01 build](../../selfhost/build/phase61/build-state01-supervisor/run.json)
failed after 6.641 seconds because a constructed `KWorld` binding required an
explicit type annotation; the failed snapshot remains preserved. A source
successor is being checked. The
[private framed-cache workflow](../../selfhost/tools/performance/phase61/validation/workflow-frame01.mjs)
uses the selected snapshot driver's decoder and retains all existing cache
identity/span/canonical-book checks. The bootstrap successor binds the actual
checked export list and exact driver. No state-prototype qualification or
promotion is claimed from the earlier 77-root receipts.

See [timing-account.md](timing-account.md) for completed wall-clock intervals,
resource limits and the distinction between target occupancy and total work.

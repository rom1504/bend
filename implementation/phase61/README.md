# Phase61: compiler architecture experiments

**State08's balanced compiler campaign passes all 207 workers across 23 sources.**
Equal-source median B2/TS geometric means improve **2.476542× → 1.433877×** for
host import + API load + first compilation, and **3.816429× → 2.071828×** for
compilation alone. Every source improves versus the same-campaign Phase58 B2.
All fresh raw modules match; this is compiler-request evidence, not a new
user-program runtime-speed result. **Phase61 state08 is installed and verified
as a checked B1 release; the compiler timings below use genuine B2.**

The campaign's [evidence capsule and restoration guide](../../selfhost/tools/performance/phase61/artifacts/README.md)
are closed and published, with 17,386 reopened-verified raw files including all
failed and interrupted attempts. The [timing account](timing-account.md) ends at
the recorded target-work cutoff; publication is separate.

The [final qualification index](../../selfhost/build/phase61/final-state08/qualification.json)
binds the installed release and reconciles the preserved failures.
The [selected state08 results](state08-results.md) contain the balanced three-round
[JSON](evidence/state08-broad3.json), [CSV](evidence/state08-broad3.csv),
[figure](figures-state08-broad3-v2/broad-ratios.svg) and current gate matrix.
The clocks measure genuine B2 in fresh processes using prepared persistent Base
caches; preparation and post-return oracles are excluded. They are not cold
OS-cache or installed checked-B1 CLI measurements. Combined state08/TS ranges
from 0.994869 to 1.846615; compilation alone remains slower on every source.

State08 checked-B1's logical 14-step matrix passes, as do carrier/leaf controls,
86-root B2 construction and eight driver observations. The genuine B2 freshly
accepts its exact source's types (3,192 unsafe declarations retain their expected
proof-trust refusal), reproduces identical B3 bytes, and matches selected B1 on
23 raw modules / 45 points. The original failed launch and receipt-validation
attempts are preserved. B2 semantics pass 96 source, 34 numeric, 18 composition
and two overapplication observations; installed legacy42, default24 and final
identity verification pass. The daemon-interrupted release wrapper remains
incomplete, with healthy child receipts and the successful two-command resume
recorded separately in the [results matrix](state08-results.md).

State08 retains state06 plus private childless-term reuse and maximum-bound
hoisting. State07's backend cursor was reverted after mixed B1 results; no
isolated-pass or B2 effect is inferred. Context-reuse research is deferred without
a general proof, and binary cache transport was rejected on measured cost.
The [architecture guide](../../docs/self_hosted/compiler-request-pipeline.md)
explains the actual mechanisms, ownership and fallback boundaries.

The successive evidence below remains historical and is not pooled with state08.
Its pending-gate statements describe those checkpoints; the current installed
status and [remaining practical opportunities](state08-results.md#result-and-remaining-practical-opportunities)
are recorded in the selected state08 report.
See the [design](../../design/phase61/architectural-compiler-speed.md),
[validation commands](../../selfhost/tools/performance/phase61/validation/README.md),
[final target-work timing account](timing-account.md), [source footprint](source-footprint.md) and
[lossless cleanup record](cleanup.md).

## Earlier state07 checkpoint and state08 selection

The [state06 fresh own-source check](../../selfhost/build/phase61/self-check-state06-early01/report.json)
passes in **18.897 supervised seconds** (18.784 internal; 12.448 for the actual
check request), starting with an empty private Base cache. The genuine state06 B2
accepts its exact source's types. All **3,191 explicitly unsafe declarations**
produce the expected separate proof-trust failure; kernel checking is false.
This is neither a mathematical proof nor a B2/B3 fixed point, and it does not
qualify state07's changed source.

The [context-reuse diagnostic](../../selfhost/build/phase61/reuse-probe-all01/report.json)
passes all 23 inputs: retained definition text and call/component facts agree
between captured contexts, and complete raw modules match. These finite matches
do not establish general context invariance or a safe cache key. No cross-context
emission cache was selected; that research is deferred rather than credited with
an unmeasured saving.

State07 applies immutable private substitution-leaf reuse and a 34-line backend
telescope cursor. Its checked API is
`e334010c1f02479fbb348b866aa04de56454b2efd3660138e1ef48aa135973d7`.

| Completed state07 gate | Result |
|---|---|
| [Checked build](../../selfhost/build/phase61/checked-state07/validation-001/report.json) | 36 strict paired probes, zero exact differences; 56.558 supervised seconds |
| [Leaf controls](../../selfhost/build/phase61/leaf-controls-state07/report.json) | 14 structural/input-retention cases; 9.049 seconds; intentional private leaf identity reuse |
| [Backend telescope controls](../../selfhost/build/phase61/backend-telescope-state07/report.json) | 24 differential rows + one ordinary direct-constructor bridge; 10.250 seconds |
| [B1 latency preparation](../../selfhost/build/phase61/state07-b1-latency01/preparation/report.json) | Complete PASS, 13.019 campaign seconds; preparation is not a request-speed sample |

The [canonical workflow application](../../selfhost/build/phase61/workflow-sync02-application01/report.json)
installs reviewed frame2 support in the maintained development helper, SHA256
`cdd71b72cb2efeec31fdaac322fc3267644f4c6c51fd6575ea0b37e8920be27c`.
Its [development tests](../../selfhost/build/phase61/workflow-sync02-tests01-supervisor/run.json)
pass in 6.345 seconds. Consumed pilot helpers/receipts remain unchanged; subsequent
selected images must bind the actual maintained workflow.

The separate [binary codec discriminator](../../selfhost/build/phase61/binary-codec01/report.json)
passes value/metadata comparisons but is **rejected on cost**: median decode plus
required validation is 225.676 ms versus JSON's 99.840 ms, **2.260389× slower**.
The complete supervised diagnostic took 4.222 seconds. These warmed, resident-byte
codec samples are not first-request compiler timings; binary receives no
JSON-owned-tree shortcut. The existing JSON path remains selected. The
[transport report](cache-transport.md) owns the detailed interpretation.

The [state07 B1 analysis](../../selfhost/build/phase61/state07-analysis01/report.json)
subsequently reports mixed changes: three-case confirmation combined-first
candidate/baseline geometric mean **1.010232**, and compile-only **1.010398**.
This compares two B1 images with both source changes combined, not B2 or isolated
pass effects. The backend cursor was reverted; `back/common/queries.bend` in
state08 is byte-identical to state06.

State08 retains only the two-line private leaf change and maximum-bound hoisting
on top of state06's Bend source. Its checked API is
`97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8`.
[Checked36](../../selfhost/build/phase61/checked-state08/validation-001/report.json)
passes in **58.679 seconds**; [carrier controls](../../selfhost/build/phase61/prefix-carrier-controls-state08/report.json)
pass 29 world rows, five producer cases and eight maximum-bound cases in
**44.113 seconds**. [Leaf controls](../../selfhost/build/phase61/leaf-controls-state08/report.json)
pass all 14 cases in **9.044 seconds**. These are correctness process durations,
not speed samples. Genuine state08 B2 and short-screen results now pass as
recorded with the completed broad campaign in [state08-results.md](state08-results.md);
the final qualification and installed release now pass in that report. The [source footprint](source-footprint.md)
compares the frozen Phase58 and selected state08 Bend manifests separately from runtime,
host helpers and research/test tooling.

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
memo and no generated names. The source bound was 3,412 and final fresh-next
was 3,967, a difference of **bound + 555**. The actual initial fresh-next was
3,413, so the checker advanced by **554 identifiers**, as also recorded by the
[later cold-state control](../../selfhost/build/phase61/prefix-cold-controls-state03/report.json).
The source bound is not the initial fresh-next counter. This state change
refutes a zero-state-change shortcut; a checkpoint needs authenticated
restoration of the actual checker state and appropriate source/cache binding.
The diagnostic duration is not a clean speed measurement or permission to skip
checking.

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
a candidate semantic counterexample. The [reviewed successor](../../selfhost/build/phase61/jdtext-caps-b2-02/report.json)
subsequently passed in 18.189 supervised seconds: five full-size **text02 B2**
bounds, 12 short/remaining-fuel old-versus-new scanner comparisons and one
concatenation-over-cap case. Full-size candidate results use independent goldens;
there is still no completed full-size old-scanner comparison. This remains a
text02-image result, not a fresh state04-image gate.

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

## State03 checkpoint: activated loader, refused checked-Base state

The tools/docs checkpoint is `97de4e9`; the earlier source checkpoint and its
measurements above remain distinct. The combined Base/loader prototype adds
four optional roots and a framed cache. Its first
[state01 build](../../selfhost/build/phase61/build-state01-supervisor/run.json)
failed after 6.641 seconds because a constructed `KWorld` binding required an
explicit type annotation. State02 then built, but the driver had omitted the
four export registrations. Its
[cold-control failure](../../selfhost/build/phase61/prefix-cold-controls-state02/report.json)
found no retained `base_prefix_prepare` helper; this 77-export image did not
exercise the proposed checkpoint.

The corrected [state03 checked build](../../selfhost/build/phase61/checked-state03/validation-001/report.json)
passed all 36 strict observations per role with zero exact differences, in
57.895 supervised seconds. Its actual bootstrap exports contain all **81**
functions. The checked API SHA256 is
`ff4e1500219439df7f7a3a60950e5c3bdfc2eaae6b5907fdfbd4327fe2da2554`;
the [attempt](../../selfhost/build/phase61/checked-state03/attempt.json) SHA256 is
`308c3389ccc1a6625c20c871c860e7f7735509d9351e3f4f8c22a3f719cbcb2b`.

| State03 focused gate | Actual result |
|---|---|
| [Compact index](../../selfhost/build/phase61/index-controls-state03/report.json) | PASS 15 rows, including mixed/serialized compact boundaries; 8.442 supervised seconds |
| [Fused telescope](../../selfhost/build/phase61/fused-controls-state03/report.json) | PASS 44 differential cases and 27 materialization cases; 15.881 seconds |
| [Loader prefix](../../selfhost/build/phase61/loader-controls-state03/report.json) | PASS three real sources and 12 structural cases; 28.840 seconds |
| [Checked-Base cold control](../../selfhost/build/phase61/prefix-cold-controls-state03/report.json) | REFUSED: prepared `ready:false`; controller exited before continuation comparisons, 6.935 seconds |

The loader state is `FFreshPrefixState{next:3413, ready:true}`. This is separate
from the checked-Base state: the latter returned `delta:554` and remained
ineligible. The refusal preserves the ordinary checking fallback; it is not a
passed cold-checkpoint gate and supplies **no Base-checking speedup evidence**.
Source inspection identified the use of checked bodies where the final raw
world book was required; the next source revision separates `kw_book` and
`kw_checked`. State04 is reported separately below; the state03 refusal remains unchanged.

The [private framed-cache workflow](../../selfhost/tools/performance/phase61/validation/workflow-frame01.mjs)
uses the selected snapshot driver's decoder and retains cache identity, span
and canonical-book checks. The consumed
[v4 bootstrap producer](../../selfhost/tools/performance/phase61/validation/prepare-candidate-v4.py)
binds the actual checked exports and exact driver. A fresh state04 plan can use
the same producer. Final qualification tooling will be selected only after a
useful candidate screen; no state03 B2, broad qualification or promotion result
is inferred from either the plan or earlier 77-root receipts.

## State04: checked-state restoration admitted

The [state04 checked build](../../selfhost/build/phase61/checked-state04/validation-001/report.json)
passed the same 36 strict observations in 56.752 supervised seconds. The
[cold-checkpoint controls](../../selfhost/build/phase61/prefix-cold-controls-state04/report.json)
now report `ready:true`, with the same bound 3,412 and fresh advance 554.
All 21 rows passed across two actual sources: 11 admitted continuations and
10 fallback cases, including full-world comparisons and shifted fresh floors.
The control took 32.258 supervised seconds. This verifies the repaired source's
checkpoint behavior in those cases; it does not supply a compiler-speed result.

The [six-command bootstrap stage](../../selfhost/build/phase61/bootstrap-state04-execution/report.json)
passed using the reviewed v4 producer and all actual 81 exports. The genuine
B2 is 3,952,902 bytes, SHA256
`3358e1a7d2317a6b8d40325ef9d84f7d9609b51001c5649097c0eff0ca7cc441`.
Full construction took 91.604 internal seconds and 91.756 supervised seconds.
Tiny split/unsplit output equality and the eight-driver comparison passed.
The separate [cache I/O controls04](../../selfhost/build/phase61/cache-combined-controls04/report.json)
passed in 1.006 supervised seconds, covering frame/source-span corruption and
invalidation with conditional export inventory checks. These filesystem controls
perform no compiler requests and make no cache-permission or speed claim.
The broad screen below establishes its own limited measurement scope. Fresh B2
whole-source checking, fixed point, broad semantics and release remain separate
gates.

See [timing-account.md](timing-account.md) for completed wall-clock intervals,
resource limits and the distinction between target occupancy and total work.

## State04 broad first-request screen

The [original broad240 campaign](../../selfhost/build/phase61/state04-b2-latency01/broad240/report.json)
closed **failed**, with 62 successful workers of 69: twenty complete source
triples, successful baseline/candidate Map churn cells, one TypeScript child
killed by the campaign deadline, and six unstarted numeric/record cells.
There was no output mismatch. The [fresh tail60](../../selfhost/build/phase61/state04-b2-latency01/broad-tail60/report.json)
then passed all nine workers for Map churn, numeric recurrence and record
aggregation. The original deadline receipt remains unchanged.

The [completed-triple analysis](../../selfhost/tools/performance/phase61/validation/state04-broad-analysis.json)
uses the first twenty complete triples and **all three roles from the fresh
tail** for the remaining sources. It does not combine the original Map
baseline/candidate cells with a later TypeScript cell. All 23 sources' fresh
compilations matched their complete, previously qualified raw module bytes.
This is compile-output evidence; generated runtime values were not rerun.

Each source has one first request per role, no later request and fixed role
order. Combined latency includes compiler import, ordinary API load and the
first library request. The equal-source geometric mean is **0.698615** for
state04 / installed Phase58 B2, and **1.702067** for state04 / TypeScript.
The fresh baseline/TypeScript geometric mean is **2.436343**, so this campaign
improves that ratio to **1.702067**. Compilation-only geometric means are
**3.772993** for baseline/TypeScript and **2.549266** for state04/TypeScript.
The ratios of summed combined times are separately **0.708878** and
**1.737534**. All 23 state04/Phase58 ratios are below one; all state04/TypeScript
ratios remain above one. These single observations supply no within-cell
spread, drift or balanced-position estimate.

| Compile source | Phase58 B2, ms | State04 B2, ms | TypeScript, ms | State04 / Phase58 | State04 / TS |
|---|---:|---:|---:|---:|---:|
| mandelbrot | 1775.640 | 1231.136 | 685.823 | 0.6933 | 1.7951 |
| editdist | 1602.947 | 1126.695 | 643.679 | 0.7029 | 1.7504 |
| tree-bitonic | 1554.596 | 1044.561 | 620.465 | 0.6719 | 1.6835 |
| lexer | 1628.749 | 1206.566 | 661.697 | 0.7408 | 1.8234 |
| symreg | 1595.762 | 1134.857 | 640.407 | 0.7112 | 1.7721 |
| test-morning-program | 1940.729 | 1377.664 | 833.735 | 0.7099 | 1.6524 |
| test-evening-program | 2235.093 | 1670.243 | 1063.845 | 0.7473 | 1.5700 |
| test-rle-roundtrip | 1491.399 | 1016.783 | 622.292 | 0.6818 | 1.6339 |
| test-map-set-ops | 2684.805 | 2260.079 | 873.486 | 0.8418 | 2.5874 |
| raytrace | 2071.728 | 1577.868 | 820.158 | 0.7616 | 1.9239 |
| local-row | 1642.121 | 1153.037 | 647.378 | 0.7022 | 1.7811 |
| local-fold | 1309.308 | 819.719 | 600.317 | 0.6261 | 1.3655 |
| scalar-region | 1451.460 | 885.886 | 610.933 | 0.6103 | 1.4501 |
| mandelbrot-grid | 1866.112 | 1309.027 | 687.871 | 0.7015 | 1.9030 |
| raytrace-active | 2131.796 | 1582.534 | 818.215 | 0.7423 | 1.9341 |
| closures | 1325.606 | 824.566 | 598.167 | 0.6220 | 1.3785 |
| list-pipeline | 1873.955 | 1332.284 | 760.259 | 0.7109 | 1.7524 |
| bst | 1504.765 | 1044.665 | 626.745 | 0.6942 | 1.6668 |
| unicode-text | 1641.357 | 1208.841 | 665.724 | 0.7365 | 1.8158 |
| expression | 1382.353 | 877.124 | 597.519 | 0.6345 | 1.4679 |
| map-churn | 1940.100 | 1390.460 | 797.444 | 0.7167 | 1.7436 |
| numeric-recurrence | 1255.875 | 819.993 | 628.680 | 0.6529 | 1.3043 |
| record-aggregation | 1981.419 | 1380.924 | 768.520 | 0.6969 | 1.7969 |

The broad attempt took 242.269 campaign seconds and the tail took 34.646.
This is a useful screen of a candidate image, not final whole-source checking,
fixed-point, integration qualification or installation. The framed final-gate
planner is reviewed but has not been launched for this checkpoint.

## Disk interruption and resumed state06

The [state05 supervisor](../../selfhost/build/phase61/checked-state05-supervisor/run.json)
remains incomplete after the filesystem exhausted its space. Its partial
snapshot and logs are retained; there is no completed checked attempt or
compiler rejection inferred from that resource failure. Work paused until the
user explicitly resumed it after cleanup.

The [tracked cleanup report](cleanup.md), linked to the original raw receipts, preserves
49 historical raw profiles as lossless gzip payloads, verifying decompressed
length and SHA256 before removing each raw copy. It reports **5,054,062,592
allocated bytes reclaimed** and 140,575,698 newly compressed bytes. Three
existing archives and 46 new gzip files retain the payloads; the mapping and
restore tool must remain with them. Source, reports, Phase6 and active
Phase58–61 artifacts were excluded. All seven installed compiler files still
matched their starting hashes. This cleanup executed no compiler or benchmark.

The fresh [state06 checked build](../../selfhost/build/phase61/checked-state06/validation-001/report.json)
passed all 36 strict observations per role with zero exact differences. Its
[supervisor](../../selfhost/build/phase61/checked-state06-supervisor/run.json)
records 57.669 seconds and peak tree RSS 1,628,602,368 bytes. The actual API is
`61761c0272092792bdb7c9bdb7a5abe07bddb79d5c807318cf0d2c9fb3b0b2b6`;
its attempt SHA256 is
`c803e731b067acfa7de58d5533a9261a31c12b70c975f07ecae9196ceec2d3b1`.

The [bootstrap plan](../../selfhost/build/phase61/bootstrap-state06/plan.json)
binds the actual **86 exports**, unchanged historical order, explicit
[carrier admission](../../selfhost/tools/performance/phase61/cache/carrier-admission01.json)
and exact frozen driver. Its completed bootstrap gates are recorded below; the
plan alone was never counted as their result. The independently
reviewed final package is materialized separately in
[methods-frame02](../../selfhost/build/phase61/methods-frame02/methods.json).
It retains the full selected checked-B1 and genuine-B2 qualification gates,
with source-derived declaration counts and frame2 cache decoding. Completed
same-attempt bootstrap evidence may be rebound instead of regenerated.
The completed focused, B2 and subset measurement results follow. Final
qualification and release admission remain pending.

State06's [native host-fact controls](../../selfhost/build/phase61/host-native-controls01/report.json)
passed all **18 cases**: ten proof/refusal cases and eight exact wrapper/event
comparisons, in 23.717 supervised seconds. The actual checked helper and Base
are bound to the receipt. These synthetic graphs establish the stated host
classification behavior, not a broad source-conformance or latency claim.

The [native-prefix carrier controls](../../selfhost/build/phase61/prefix-carrier-controls-state06/report.json)
passed **29 world/completion/fallback rows** across two actual sources, plus
**five producer cases**, in 43.222 supervised seconds. Fifteen continuations
were admitted and fourteen took fallback. The scope is private authenticated
state; the gate does not establish arbitrary disk-cache authenticity. The
six-command state06 bootstrap subsequently passed, as recorded below.

## State06 B2 and completed subset measurements

The [bootstrap execution](../../selfhost/build/phase61/bootstrap-state06-execution/report.json)
passed all six commands in **132.061 supervised-stage seconds**. The
[full emission](../../selfhost/build/phase61/bootstrap-state06/full/report.json)
produced a genuine 86-root B2 of **3,977,511 bytes**, SHA256
`f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`.
It binds source SHA256
`14af4de4b67de746cfa1d59458a0e27c1e03e02516583c6d2a621352b11e449e`.
Full construction took **71.729 internal seconds / 71.952 supervised seconds**.
Tiny split/unsplit equality and all
[eight ordinary-driver observations](../../selfhost/build/phase61/bootstrap-state06/driver-comparison.json)
passed. Construction uses inherited exact-source checking; it is not fresh B2
self-checking or a B2/B3 fixed-point result. Different earlier source/export
sets prevent interpreting their construction durations as a controlled speedup.

[Preparation](../../selfhost/build/phase61/state06-b2-latency01/preparation/report.json)
passed for all three roles in 13.768 campaign seconds, outside latency windows.
The [screen45 pilot](../../selfhost/build/phase61/state06-b2-latency01/screen45/report.json)
then passed six fresh workers, two sources × three roles × one round, with no
later requests. It took **10.318 campaign seconds**. Combined first-request
latency is host import + API load + ordinary checked library compilation:

| Pilot input | Phase58 B2, ms | State06 B2, ms | TypeScript, ms | State06 / Phase58 |
|---|---:|---:|---:|---:|
| numeric-recurrence | 1,273.926 | 591.089 | 588.849 | 0.4640 |
| test-map-set-ops | 2,744.962 | 1,690.756 | 905.690 | 0.6159 |

The separate [confirm90 campaign](../../selfhost/build/phase61/state06-b2-latency01/confirm90/report.json)
passed **18/18 workers** in **30.997 campaign seconds**: three sources, three
roles and two rotated rounds, first request only. Its two-observation medians
are not pooled with the one-round pilot:

| Confirmation input | Phase58 B2, ms | State06 B2, ms | TypeScript, ms | State06 / Phase58 | State06 / TS |
|---|---:|---:|---:|---:|---:|
| numeric-recurrence | 1,238.956 | 596.422 | 575.348 | 0.4814 | 1.0366 |
| test-map-set-ops | 2,765.139 | 1,688.581 | 911.956 | 0.6107 | 1.8516 |
| raytrace-active | 2,136.962 | 1,340.179 | 812.680 | 0.6271 | 1.6491 |

The equal-source geometric mean of these combined ratios is **0.569145** versus
Phase58 and **1.468267** versus TS. All three inputs improve against the fresh
Phase58 baseline, while all remain slower than TS. This does not isolate native
facts, prefix provenance or transport contributions.

Compilation-only medians exclude host import and API load:

| Confirmation input | Phase58 B2, ms | State06 B2, ms | TypeScript, ms |
|---|---:|---:|---:|
| numeric-recurrence | 1,145.060 | 486.452 | 316.097 |
| test-map-set-ops | 2,671.352 | 1,576.911 | 648.616 |
| raytrace-active | 2,043.615 | 1,230.072 | 549.737 |

Their geometric mean ratios are **0.532443** versus Phase58 and **2.030508**
versus TS. Candidate API load alone is approximately 106–107 ms, versus 89–90 ms
for Phase58; TS's approximately 259–263 ms compiler import belongs to the
combined window. Near parity on Numeric's combined clock is not compile-only
parity.

Both campaigns use frozen
[method05](../../selfhost/build/phase61/latency-method05/derivation.json), including
its reviewed stable-input verification policy and selected frame decoder.
Campaign wall includes orchestration and verification outside clean clocks;
its reduction from earlier method03 campaigns is not wholly compiler speed.
Each newly emitted module passed complete raw-byte comparison with its qualified
reference. These subset runs execute no generated workloads. The subsequent
broad screen follows; the subsequent fresh state06 type check is recorded above; reproduction, final
integration and release remain unclaimed.

## State06 broad first-request screen

The [broad180 report](../../selfhost/build/phase61/state06-b2-latency01/broad180/report.json)
passes **69/69 workers** in **108.100775 campaign seconds**: all 23 sources,
three roles, one fixed-order round and no later requests. Every fresh output
matches its complete qualified raw-module reference. This is compilation/output
identity evidence; no generated runtime workload was executed.

| Equal-source geometric mean | Phase58 B2 / TS | State06 B2 / TS | State06 / Phase58 |
|---|---:|---:|---:|
| Import + API load + first compilation | 2.468310 | 1.432999 | 0.580559 |
| First compilation only | 3.802103 | 2.098952 | 0.552050 |

Preparation and post-return byte checking remain outside clean request clocks.
The 107.670503-second measurement-stage interval includes orchestration and is
not their sum. Each source contributes one observation per role, so this screen
has no within-cell spread or balanced-position estimate. The three-source
confirmation and state04's broad measurements are not pooled with these rows.
There is no wall-time extrapolation or isolated gain credited to an individual
mechanism. All23 coverage is now measured for this candidate; final semantic,
selected-source self-check/reproduction, native/legacy, generated-program
performance and release qualification remain pending. The fresh state06 type
check above is a separate completed gate.

Canonical frame2 workflow support has now landed and passed development tests,
as recorded above. Preserve the old pilot helper bytes and receipts; the final
selected bootstrap and qualification must bind the maintained helper. Existing
checked source/API identities remain valid, but pilot B2 receipts are not
silently rebound to changed tools.

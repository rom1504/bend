# Phase61 timing account — state06 broad-screen checkpoint

The campaign [start receipt](../../selfhost/build/phase61/start.json) records
`2026-10-07T08:51:24.549669+00:00`. This is an incremental account of completed
jobs; the campaign and its writers remain open. There is no final elapsed-time
denominator or work/wait percentage yet.

Root executes targets serially on CPU3. Bounds are a 1 GiB Node heap, 2 GiB
process-tree RSS, 4 GiB available-memory floor and 4 MiB stack. Reviewer/data
work uses CPU0. Process-tree RSS sums can count shared pages more than once;
they are supervised peaks, not allocation totals.

## Completed supervised jobs

| Job | Wall seconds | Peak tree RSS, MiB | Outcome |
|---|---:|---:|---|
| [Checked B1 build + selected36](../../selfhost/build/phase61/build-candidate01-supervisor/run.json) | 62.614 | 1,539.871 | PASS |
| [Telescope controls](../../selfhost/build/phase61/telescope-controls01-supervisor/run.json) | 14.371 | 583.410 | PASS |
| [Batch-index controls](../../selfhost/build/phase61/index-controls01-supervisor/run.json) | 8.341 | 588.668 | PASS |
| [Primitive controller01](../../selfhost/build/phase61/primitive-controls01-supervisor/run.json) | 7.135 | 539.789 | Controller precondition failure retained |
| [Primitive controls02](../../selfhost/build/phase61/primitive-controls02-supervisor/run.json) | 8.241 | 582.336 | PASS |
| [Seed controls](../../selfhost/build/phase61/seed-controls01-supervisor/run.json) | 8.539 | 622.488 | PASS |
| [Base-state diagnostic](../../selfhost/build/phase61/prefix-base-probe01-supervisor/run.json) | 7.437 | 532.016 | Probe PASS; state change prevents zero-mint shortcut |
| [Whole B2 construction/driver stage](../../selfhost/build/phase61/bootstrap-candidate02-execution/report.json) | 153.859 | — | Six serial commands PASS |
| [First text-transport build](../../selfhost/build/phase61/build-text01-supervisor/run.json) | 5.937 | 569.922 | Nested parameter-match rejection retained |
| [Repaired text02 build + selected36](../../selfhost/build/phase61/build-text02-supervisor/run.json) | 62.007 | 1,502.520 | PASS; distinct candidate |
| [Text02 entire bootstrap stage](../../selfhost/build/phase61/bootstrap-text02-execution/report.json) | 141.436 | — | PASS six commands |
| [Original JDText controls](../../selfhost/build/phase61/jdtext-controls01-supervisor/run.json) | 120.064 | 588.277 | Deadline; small rows retained, caps incomplete |
| [JDText small02](../../selfhost/build/phase61/jdtext-small02-supervisor/run.json) | 13.566 | 601.547 | PASS 28 goldens / 1,065 split variants |
| [Original B2 cap attempt](../../selfhost/build/phase61/jdtext-caps-b2-01-supervisor/run.json) | 60.094 | 661.488 | Deadline in first baseline old scan; candidate untested |
| [Combined state01 build](../../selfhost/build/phase61/build-state01-supervisor/run.json) | 6.641 | 671.156 | Source annotation rejection retained |
| [State02 build](../../selfhost/build/phase61/build-state02-supervisor/run.json) | 63.357 | 1,543.285 | PASS selected36; only77 exports, checkpoint absent |
| [State03 build](../../selfhost/build/phase61/build-state03-supervisor/run.json) | 57.895 | 1,568.539 | PASS selected36, actual81 exports |
| [State03 cold checkpoint](../../selfhost/build/phase61/prefix-cold-controls-state03-job/run.json) | 6.935 | 532.355 | REFUSED ready:false; no continuation qualification |
| [State03 compact index](../../selfhost/build/phase61/index-controls-state03-job/run.json) | 8.442 | 541.531 | PASS 15 rows |
| [State03 fused telescope](../../selfhost/build/phase61/fused-controls-state03-job/run.json) | 15.881 | 595.969 | PASS 44 differential +27 materialization |
| [State03 loader prefix](../../selfhost/build/phase61/loader-controls-state03-job/run.json) | 28.840 | 778.898 | PASS 3 real +12 structural |
| [State04 build](../../selfhost/build/phase61/build-state04-supervisor/run.json) | 56.752 | 1,534.121 | PASS selected36 /81 roots |
| [State04 cold checkpoint](../../selfhost/build/phase61/prefix-cold-controls-state04-job/run.json) | 32.258 | 600.844 | PASS 21 rows:11 admitted /10 fallback |
| [State04 entire bootstrap stage](../../selfhost/build/phase61/bootstrap-state04-execution/report.json) | 152.161 | — | PASS six commands |
| [Text02 B2 cap successor](../../selfhost/build/phase61/jdtext-caps-b2-02-supervisor/run.json) | 18.189 | 695.629 | PASS 5 full candidate bounds +12 small differential +1 concat |
| [Cache I/O controls04](../../selfhost/build/phase61/cache-combined-controls04-supervisor/run.json) | 1.006 | 177.109 | PASS filesystem/metadata controls; no compiler requests |

The whole B2 stage row already contains tiny construction (29.661 s), full construction
(92.975 s), source driver (15.884 s), direct driver (14.571 s), driver join and
image-pin creation. Do **not** add these nested durations again. Full-construction
peak tree RSS was 1,085.684 MiB. The emission report's internal elapsed value is
92.814 seconds; the supervisor's 92.975 seconds includes its surrounding process
work. Neither is a clean first-request latency sample.

## Completed latency campaigns

| Report | Campaign wall seconds | Successful workers | Meaning |
|---|---:|---:|---|
| [B1 preparation](../../selfhost/build/phase61/candidate-b1-latency01/preparation/report.json) | 14.571 | Preparation only | Two role preparations passed |
| [B1 screen20](../../selfhost/build/phase61/candidate-b1-latency01/screen20/report.json) | 20.854 | 3 / 4 | Deadline; incomplete candidate MapSet cell |
| [B2 preparation](../../selfhost/build/phase61/candidate-b2-latency01/preparation/report.json) | 16.939 | Preparation only | Three role preparations passed |
| [B2 screen45](../../selfhost/build/phase61/candidate-b2-latency01/screen45/report.json) | 25.359 | 6 / 6 | Two sources, three roles, one first request each |
| [B2 confirm90](../../selfhost/build/phase61/candidate-b2-latency01/confirm90/report.json) | 77.360 | 18 / 18 | Three sources, three roles, two rotated rounds, first only |
| [Text02 confirm60](../../selfhost/build/phase61/text02-b2-latency01/confirm60/report.json) | 55.013 | 12 / 12 | Three sources, two roles, two rotated rounds, first only |

Campaign wall includes launcher preflight and process orchestration. The B2
screen's measurement-stage interval is 24.997 seconds. Its clean request clocks
in [README.md](README.md) exclude case preflight, post-request byte checking and
saved-report work. Preparation is separate; zero later requests were made.
Labels such as `20` identify budgets, not guarantees of complete coverage.
The separate confirmation's measurement-stage interval is 76.995 seconds; its
samples are not combined with the earlier screen. Text02 is another separate
campaign; its bootstrap stage includes full construction at 82.307 supervised
seconds, which must not be added to the stage total again. State04 full
construction is similarly nested: 91.604 internal seconds /91.756 supervised
seconds. Its distinct source/API and81 exports prevent treating this as a
controlled comparison with the prior77-export constructions.

## Final accounting method

At root's final cutoff, use completed process/supervisor start/end intervals.
Deduplicate identical intervals, remove enclosed child intervals when their
supervisor is retained, and union half-open intervals so partial overlaps are
not counted twice. Keep build, preparation, focused control, qualification,
clean cost and sampled-profile categories separate; label mixed overlaps and
unknown categories explicitly. Failed jobs remain included in occupancy and
peak-resource accounting.

This table is a selected checkpoint list, not the campaign interval union: it
does not include every baseline preparation, data-only audit or later candidate.
Do not subtract its sum from campaign wall and call the remainder waiting.
Unrecorded intervals can include source editing, review, planning, orchestration
and ordinary tool work. These receipts measure wall occupancy, not CPU time or
agent effort. Final publication after writer closure will be accounted for
separately; no archive-closure or final release claim is made here.

## Why the broad240 screen exhausted its campaign budget

The [saved report](../../selfhost/build/phase61/state04-b2-latency01/broad240/report.json)
records 62 successful workers and one deadline-killed worker; six further cells
were skipped. Its 241.557-second measurement stage contained 184.796 seconds
of child-process wall time and 56.761 seconds outside those children. Median
time between child completion and the next child start was 0.875 seconds.
The whole command took 242.269 seconds. The separate complete tail took 34.646
seconds; it does not turn the original campaign into a passing receipt.

For the 62 successful children, the saved clocks partition time as follows:

| Saved-clock component | Seconds |
|---|---:|
| Import + API load + first compile | 76.783 |
| Recorded worker preflight | 25.892 |
| Remaining time inside worker | 74.331 |
| Child process time outside worker clock | 6.765 |
| Total successful child process time | 183.770 |

The worker remainder includes full output checking/writing, final input
rehashing and other untimed work; it is **not** an exclusive hashing timer.
Static inspection of the consumed method identifies a likely substantial
contributor: `config.inputs` contains 124,828,524 bytes, including the
123,655,872-byte Node executable. The runner rehashes this list twice per
launched child; each successful worker checks the current and preparation
input lists before and after its clean window, four more passes. The Node
identity alone therefore causes about 742 MB of repeated reads/hashing per
successful sample. The input checks do not requalify the complete old archive.

A future method could pin immutable producer/Node identities at campaign
entry and exit while retaining per-child checks of the active source, staged
compiler, cache and raw output. That would require a reviewed successor and
explicit threat/immutability assumptions. No consumed method or sample was
changed, and no exclusive hash-cost or improved-runtime claim is made here.
The exact arithmetic and original report pins are in the
[small analysis receipt](../../selfhost/tools/performance/phase61/validation/state04-broad-analysis.json).

## Disk pause and state06 resume

The state05 supervisor has `complete:false`, zero recorded peak RSS and no
finished timestamp or elapsed duration. Disk exhaustion interrupted recording;
its start time cannot be used to invent a completed build interval. The failed
attempt stays preserved and is not a semantic counterexample.

The separate [cleanup summary](../../selfhost/build/cleanup-20261007/summary.json)
credits only 5,054,062,592 bytes of reclaimed allocation from 49 verified
lossless profile replacements. Changes in total drive free space also include
activity outside this workspace and are not attributed to cleanup. No compiler
or benchmark ran during that work. Its wall time is not a compiler-latency
sample and is not labelled waiting.

The resumed [state06 build](../../selfhost/build/phase61/checked-state06-supervisor/run.json)
completed in **57.669416 seconds**, peak tree RSS **1,628,602,368 bytes**, with
36 exact observations per role passing. The completed bootstrap and subset measurements are recorded below; final
qualification still has no completed duration here. The campaign
remains open; there is still no final occupancy/total-work percentage.

State06 [native host-fact controls](../../selfhost/build/phase61/host-native-controls01-supervisor/run.json)
passed 18 cases in **23.716830 seconds**, peak tree RSS **686,784,512 bytes**.
Its [carrier controls](../../selfhost/build/phase61/prefix-carrier-controls-state06-job/run.json)
passed 29 world rows and five producer cases in **43.221522 seconds**, peak
tree RSS **642,203,648 bytes**. These are correctness-control process durations,
not clean compiler-latency samples. The subsequent completed bootstrap is recorded below. A fresh final bootstrap
after canonical workflow maintenance will be recorded separately if required;
these pilot times remain retained.


## State06 completed bootstrap and fast loop

| Report | Wall seconds | Scope |
|---|---:|---|
| [Bootstrap execution](../../selfhost/build/phase61/bootstrap-state06-execution/report.json) | 132.061495 | Six commands PASS, including tiny/full construction and eight-driver join |
| [Three-role preparation](../../selfhost/build/phase61/state06-b2-latency01/preparation/report.json) | 13.768266 | Private staging and Base preparation; outside clean request clocks |
| [screen45](../../selfhost/build/phase61/state06-b2-latency01/screen45/report.json) | 10.317683 | 6/6 workers, two inputs × three roles × one round, no later requests |
| [confirm90](../../selfhost/build/phase61/state06-b2-latency01/confirm90/report.json) | 30.996514 | 18/18 workers, three inputs × three roles × two rounds, no later requests |

The bootstrap stage contains full construction at **71.728722 internal seconds**
and **71.952000 supervised seconds**, peak tree RSS **1,173,438,464 bytes**.
Tiny construction was 29.644958 supervised seconds, source-driver validation
15.081279 and direct-driver validation 14.172370. These are nested jobs; do not
add them to the 132.061495-second enclosing stage again. Its 86-root output is
3,977,511 bytes, `f73ef8a5596e99d45108b0d31b4e6c3f49e008db000a428e27acd27d79bd6d1a`.
The source/export set differs from state04; this is not a controlled bootstrap
speed ratio or a fresh self-check/fixed-point gate.

screen45's measurement-stage interval is 9.898902 seconds; confirm90's is
30.614519 seconds. These intervals include child orchestration, unlike the
per-worker clean request clocks reported in [README.md](README.md). The
confirmation's combined-first candidate/baseline geometric mean is 0.569145;
its candidate/TS ratio is 1.468267. Compilation-only ratios are separately
0.532443 and 2.030508. Pilot and confirmation observations are not pooled, and
neither is pooled with the subsequent all23 state06 screen below.

The consumed method is
[latency-method05](../../selfhost/build/phase61/latency-method05/derivation.json),
which retains the reviewed method04 stable-input hashing protocol and uses the
actual selected frame decoder. Consequently, complete campaign wall cannot be
compared with method03's earlier repeated-hash orchestration as a pure compiler
speedup. Same-campaign clean role comparisons retain their stated boundary:
actual imports/API load plus first request, with preparation and post-return
full-byte validation excluded. The campaign remains open; no total work/wait
percentage, final semantic qualification or installation is claimed.


## State06 completed all23 screen

The [broad180 campaign](../../selfhost/build/phase61/state06-b2-latency01/broad180/report.json)
passes **69/69 workers**, all 23 sources × three roles × one fixed-order round,
with no later requests. Campaign wall is **108.100775 seconds**; its measurement
stage is **107.670503 seconds**. Preparation is reused outside these intervals;
all fresh raw-module byte checks pass, with no generated workloads rerun.

Same-campaign equal-source geometric means are **2.468310 → 1.432999 B2/TS**
for combined import/API-load/first compilation and **3.802103 → 2.098952** for
compilation alone. Candidate/baseline ratios are separately **0.580559** and
**0.552050**. The prior three-source confirmation remains a distinct experiment.
This one-round screen does not supply per-cell variation or justify a wall-time
extrapolation. Method05's outer orchestration includes untimed work, and neither
its campaign wall nor its role ratios constitute final release qualification.

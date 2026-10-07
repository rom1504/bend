# Phase61 timing account — completed target-work cutoff

The campaign [start receipt](../../selfhost/build/phase61/start.json) records
`2026-10-07T08:51:24.549669+00:00`. The final target-work cutoff is
`2026-10-07T16:38:11.916235+00:00`: **28,007.366566 seconds** (7 h 47 min).
The [final interval account](../../selfhost/tools/performance/phase61/evidence/time-use-final01.json)
observes **3,514.638909 seconds** (58.577315 min, **12.548980%**) of supervised
process wall occupancy. Its **24,492.727657-second** uncovered remainder is not
called waiting: it includes editing, research, review, orchestration, disk
interruption/restart and work without a qualifying process receipt. These are
wall intervals, not CPU usage or agent effort. Documentation, this final analysis
and publication after the cutoff are excluded.

| Exclusive supervised category | Occupied wall seconds |
|---|---:|
| Checked builds | 488.116986 |
| Focused controls | 558.182179 |
| Bootstrap construction/driver gates | 575.807345 |
| Latency preparation | 91.164575 |
| Clean-latency jobs | 951.393766 |
| Profile jobs | 97.296184 |
| Final qualification/release | 752.677875 |
| Other / mixed-category overlap | 0 / 0 |
| **Union** | **3,514.638909** |

“Clean-latency jobs” denotes the enclosing supervised job wall, including its
setup and orchestration; it is not the sum of clean request clocks. The account
scans 730 process/run receipts and admits 729 finished unique intervals. Fourteen
finished failures occupy a diagnostic union of 219.724759 seconds, already
included in the categories above. The state05 disk-interrupted supervisor has no
end and supplies no invented duration. The daemon-interrupted release queue also
has no end; its completed child process receipts are included separately. The
account verifies stable inputs and category/union arithmetic. Earlier checkpoint
tables below retain their original narrower scope and are not additional time.

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

At the recorded final cutoff, the account uses completed process/supervisor start/end intervals.
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
agent effort. Final publication after writer closure is outside this cutoff;
archive closure is a separate evidence-preservation claim.

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


## Subsequent correctness and rejected codec checkpoint

| Completed receipt | Supervised/campaign seconds | Scope |
|---|---:|---|
| [State06 own-source check](../../selfhost/build/phase61/self-check-state06-early01-supervisor/run.json) | 18.896774 | Fresh type acceptance; expected proof-trust refusal for 3,191 unsafe declarations |
| [Canonical workflow development tests](../../selfhost/build/phase61/workflow-sync02-tests01-supervisor/run.json) | 6.344696 | Maintained frame2 helper tests PASS |
| [State07 checked build](../../selfhost/build/phase61/checked-state07-supervisor/run.json) | 56.558074 | 36 strict paired probes PASS |
| [State07 leaf controls](../../selfhost/build/phase61/leaf-controls-state07-supervisor/run.json) | 9.048651 | 14 cases PASS |
| [State07 backend cursor controls](../../selfhost/build/phase61/backend-telescope-state07-supervisor/run.json) | 10.250364 | 24 rows + one constructor bridge PASS |
| [State07 B1 preparation](../../selfhost/build/phase61/state07-b1-latency01/preparation/report.json) | 13.018674 | Preparation PASS; no request-speed result |
| [Binary codec diagnostic](../../selfhost/build/phase61/binary-codec01-supervisor/run.json) | 4.221657 | Values agree; binary rejected as 2.260389× slower with required validation |

State06 own-source checking records 18.783894 internal seconds, including the
12.448330-second check request. These nested durations are not added to its
supervised interval. Type acceptance is distinct from the expected unsafe trust
refusal; this is not kernel proof or fixed-point evidence.

The binary medians (225.676447 ms versus JSON 99.839660 ms) come from five
alternating warmed codec/validation samples per role with resident input bytes.
They measure neither whole cache-read nor first compiler request. State07's
build/control/preparation durations supply no compiler-speed claim. Its candidate
source differs from state06; no source-duration extrapolation or final campaign
occupancy percentage is introduced here.


## State08 successor after the mixed B1 screen

The [state07 B1 analysis](../../selfhost/build/phase61/state07-analysis01/report.json)
retains its one-round screen and two-round confirmation separately. Confirmation
candidate/baseline geometric mean is 1.010232 combined-first and 1.010398
compile-only; both leaf and backend-cursor changes were present. No isolated
pass effect or B2 performance result follows. The backend cursor was reverted.

| State08 completed gate | Supervised seconds | Scope |
|---|---:|---|
| [Checked build](../../selfhost/build/phase61/checked-state08-supervisor/run.json) | 58.678729 | Strict36 PASS |
| [Carrier controls](../../selfhost/build/phase61/prefix-carrier-controls-state08-job/run.json) | 44.113050 | 29 world rows + five producer + eight maximum-bound cases PASS |
| [Leaf controls](../../selfhost/build/phase61/leaf-controls-state08-supervisor/run.json) | 9.044181 | 14 cases PASS |

State08 source is state06 plus private leaf reuse and maximum-bound hoisting.
These control/build durations are not clean compiler-request measurements.
At this earlier checkpoint, state06 remained the latest broadly measured B2;
state08 bootstrap, short screens and the balanced broad campaign are recorded
below. No wall-time extrapolation is added.


## State08 maintained-workflow bootstrap and short B2 requests

| Completed receipt | Campaign/stage seconds | Scope |
|---|---:|---|
| [State08 bootstrap](../../selfhost/build/phase61/final-state08/bootstrap-execution/report.json) | 132.873596 | Six commands PASS, actual 86 roots, tiny equality and eight-driver join |
| [Method06 preparation](../../selfhost/build/phase61/state08-b2-latency01/preparation/report.json) | 13.159379 | Three role preparations PASS; outside clean clocks |
| [State08 screen45](../../selfhost/build/phase61/state08-b2-latency01/screen45/report.json) | 10.384859 | 6/6 first-only workers |
| [State08 confirm90](../../selfhost/build/phase61/state08-b2-latency01/confirm90/report.json) | 31.276166 | 18/18 workers; three sources, three roles, two rounds |

The full emission's 73.272635 internal / 73.458295 supervised seconds are nested
inside the bootstrap stage, not additional intervals. Peak full-emission tree
RSS is 1,136,381,952 bytes. The 3,978,248-byte B2 has SHA256
`23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477`.
The [state08 report](state08-results.md) separates its inherited checking lane
from the subsequently completed fresh own-source/reproduction gates below.

Confirmation B2/TS means are 2.599648 → 1.452451 combined-first and
3.828061 → 2.007350 compilation-only. Method06's historical dependency relocation
changes provenance handling, not the clean method05 clock boundary. No samples
are pooled with state06, and no small cross-campaign difference is attributed
to state08's individual passes. The subsequently completed balanced broad campaign is recorded below.

The original final checked-stage attempt stops at composition with process-health
`spawnSync EPERM`; its failed receipts remain retained. The unchanged controller's
fresh retry passes 18 and overapplication passes two. The subsequent
[13-command resume](../../selfhost/build/phase61/final-state08/checked-resume02-execution/report.json)
passes, completing the logical 14-step checked-B1 matrix with the preserved
initial acquisition. Native3 and the 45-point output smoke also pass. Failure/retry time belongs to eventual whole-campaign accounting;
no incomplete stage is relabelled as completed occupancy here.

These compiler clocks measure genuine B2 in fresh processes with prepared
persistent Base caches; neither preparation nor post-return oracle validation
is included. They do not claim cold OS/page caches, installed checked-B1 CLI
latency or a new generated-program runtime-speed measurement.


## State08 exact-image B2 correctness

| Completed receipt | Internal seconds | Supervised seconds | Scope |
|---|---:|---:|---|
| [Own-source check](../../selfhost/build/phase61/final-state08/self-check/report.json) | 17.247517 | 17.385388 | Actual check request 11.397480 s; type acceptance, expected unsafe trust refusal for 3,192 declarations |
| [Fixed point](../../selfhost/build/phase61/final-state08/fixed-point/report.json) | 34.386270 | 34.567764 | Complete B2/B3 equality, SHA256 `23bd6a48…` |

The own-source gate begins with an empty private Base cache and differs from
primed-cache compiler latency. The original enclosing B2 stage remains failed:
its semantic acquisition passed, then a validator rejected extra identity
metadata. Neither successful child changes that enclosing receipt to PASS.
The separately executed B2 program-equality gate passes all 23 raw modules;
its preserved bytes do not supply a new runtime-speed measurement.


## State08 balanced broad campaign

The [audited summary](evidence/state08-broad3.json) joins all 207 successful
first-only workers: 23 sources × three roles × three rounds. Campaign wall is
**327.660806 s**; the measurement-stage interval is **327.230365 s**,
and child process wall sums to **292.450882 s**. These nested intervals
must not be added together. Preparation is reused outside the campaign.

Combined-first B2/TS geometric means are **2.476542 → 1.433877**, and
compilation-only **3.816429 → 2.071828**. These use each source/role's median
followed by an equal-source geometric mean. Role positions are balanced within
each source; source order remains fixed. The three samples per cell do not
support a significance claim or isolated attribution among source and host
changes. Previous pilots remain separate. All raw bytes pass; this campaign
executes no new user-program workload or runtime-speed measurement.


## State08 semantic retry and release interruption

The [B2 semantic retry](../../selfhost/build/phase61/final-state08/b2-semantics-resume02-execution/report.json)
passes seven resumed commands in **105.044043 stage seconds**, covering 96 source,
34 numeric, 18 composition and two overapplication observations. Its separate
identity normalization corrects receipt comparison only. The original enclosing
B2 and semantic-stage failures remain preserved; one source and six numeric TS
oracle defects remain explicit in the completed controls.

The [checked resolution](../../selfhost/build/phase61/final-state08/checked-resolution.json)
joins the preserved successful acquisition with 13 healthy resumed commands.
This completes 14 logical steps without rewriting the failed original queue.
The [release admission](../../selfhost/build/phase61/final-state08/release-admission.json)
binds those gates, B2 correctness, exact program bytes, broad compiler cost and
pre-release preservation to the selected checked B1.

| Completed release process | Supervised seconds | Scope |
|---|---:|---|
| [Install](../../selfhost/build/phase61/final-state08/release/job-install/process.json) | 7.893706 | Checked state08 B1 installation, exit 0 |
| [Verify before](../../selfhost/build/phase61/final-state08/release/job-verify-before/process.json) | 1.227523 | Installed identity verification, exit 0 |
| [Legacy42](../../selfhost/build/phase61/final-state08/release/job-legacy42/process.json) | 33.018760 | Complete supervisor and 42-step launcher PASS |

The daemon restart interrupted the [outer release receipt](../../selfhost/build/phase61/final-state08/release-execution/report.json)
before it recorded legacy42 completion. That outer receipt stays `complete:false`
and has no finished timestamp: do not invent its full interval. Legacy42's own
completed process and oracle receipts remain usable. The
[resume plan](../../selfhost/build/phase61/final-state08/release-resume02-plan.json)
records this interruption and reuses the healthy install/verify/legacy receipts.
The restart gap is not compiler execution time, and no failed or incomplete
wrapper is relabelled PASS.


The [fresh release resume](../../selfhost/build/phase61/final-state08/release-resume02-execution/report.json)
passes both commands in **19.881522 stage seconds**: default24 passes all 24
ordinary/relocated installed CLI checks, and verify-after exits 0 in
**1.227149 supervised seconds**. The verification is nested within the resume;
do not add it to the stage duration again. These release process durations are
not compiler-request or generated-program speed samples. State08 is now installed
and verified as checked B1, while genuine B2 timings remain separately scoped.

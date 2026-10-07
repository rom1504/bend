# Phase61 timing account — first candidate checkpoint

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
seconds, which must not be added to the stage total again.

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

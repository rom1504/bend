# Phase52 measurement time and next full-corpus budget

This is a provisional planning checkpoint: direct06 is selected after07 failed
the ordered-IIFE performance screen.
It records measured job durations and a forward estimate; it does not claim the
raw campaign is closed or add nested supervisor/child durations into a total.
The lead owns source accounting separately in [accounting.md](accounting.md).

## Recorded costs

All paths below are under `selfhost/build/phase52/`. Acquisition and smoke rows
sum serialized child-wall durations; they are work estimates, not total elapsed
campaign time. Timing rows use each comparison report's elapsed duration.

| Work | Evidence | Recorded seconds |
| --- | --- | ---: |
| Checked direct02 build | `build-guard02/run.json` | 56.873 |
| Checked direct03 build | `build-guard03/run.json` | 56.891 |
| Checked direct04 build | `build-guard04/run.json` | 59.397 |
| Checked direct05 build | `build-guard05/run.json` | 59.536 |
| Checked direct06 build | `build-guard06/run.json` | 59.008 |
| Checked direct07 build | `build-guard07/run.json` | 58.892 |
| Direct05, all23 source acquisitions | `prepared-direct05-full/manifest.json` | 135.244 |
| Direct05, all45 smoke cases | `smoke-direct05-full/report.json` | 3.970 |
| Direct05 batch0,15 points/219 samples | `full-direct05-batch0/report.json` | 368.268 |
| Direct05 batch1,15 points/225 samples | `full-direct05-batch1/report.json` | 380.042 |
| Direct06 intrinsic screen,8 acquisitions | `prepared-direct06-intrinsics/manifest.json` | 45.660 |
| Direct06 intrinsic screen,8 smoke cases | `smoke-direct06-intrinsics/report.json` | 0.596 |
| Direct06 intrinsic screen,8 points/72 samples | `screen-direct06-intrinsics/report.json` | 58.172 |
| Direct07 ordered screen,8 acquisitions | `prepared-direct07-ordered/manifest.json` | 45.394 |
| Direct07 ordered screen,8 points/72 samples | `screen-direct07-ordered/report.json` | 58.523 |

The05 batch2 was not started. Its30 completed points/444 samples remain useful
historical evidence, but they are not a full45 result and cannot supply missing
rows for another compiler. The two timing batches occupied748.311 measured
seconds. Their retention is an experimental cost, not a new selected result.

A failed initial build guard is also retained at `build-guard01/run.json`
(5.032s). This table is not a complete failure inventory or an elapsed-time sum.
Direct06's build peak was1,474,224,128 process-tree RSS bytes; its acquisition
peak was580,988,928 bytes. The1GiB Node heap,2GiB tree-RSS limit and4GiB available
memory floor were not increased for these measurements.

## Remaining benchmark estimate

After one image is selected, the [full plan](../../selfhost/tools/performance/phase52/full-plan.md)
requires exactly23 source acquisitions,45 passing smoke cases and three fresh
15-point batches:219+225+225=669 samples. Measured05 costs suggest approximately
2.3 minutes for acquisition,4 seconds for smoke and18.7 minutes for the three
timing batches. Allow **21–23 minutes** for this benchmark sequence plus its
small data-only aggregation. A new checked build adds about one minute.
These are estimates, not deadlines or permission to drop slow points. The600
preset bounds each batch; it does not guarantee a complete result by that time.

Independent semantics, installation, CLI smoke, portable publication and final
archive closure are separate work. They are not hidden inside this estimate.
No compression or other hardware job may overlap timed samples. The final
full-corpus baseline remains Phase51 plus pinned TypeScript; the small07 screen
instead measures direct06/direct07/TypeScript and must be reported separately.

## Reproducible final interval accounting

The unexecuted [time-use-v1.py](../../selfhost/tools/performance/phase52/time-use-v1.py)
is a small derivative of the reviewed Phase48 interval method. It reads completed
`process.json` and `run.json` supervisors, deduplicates identical command/time
rows, excludes temporally enclosed child intervals from summed occupancy, and
unions the remaining half-open intervals. Partial overlaps have an explicit
mixed category. Both successful and failed jobs remain visible.

A future data-only invocation, after timing and with a fresh output, is:

```bash
taskset -c 0 python3 selfhost/tools/performance/phase52/time-use-v1.py \
  --root selfhost/build/phase52 \
  --out selfhost/build/phase52/time-use-checkpoint01.json
```

Without `--end` this is explicitly provisional. A final cutoff does not itself
prove writer closure. Wall occupancy is not CPU usage or agent labor. Uncovered
time includes analysis, coding, review, documentation, orchestration, unrecorded
operations and possible idle time; it must not be relabeled “waiting.” No time
accounting producer or additional generated program was run for this document.

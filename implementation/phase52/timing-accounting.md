# Phase52 measurement time and next full-corpus budget

The final data-only accounting cutoff is **2026-10-05 17:43:42 UTC**, after
all selected target checks and the portable replay completed. The recorded phase
started at14:49:48 UTC: **173.900 minutes elapsed**. The union of completed
supervised process intervals is **62.831 minutes (36.13%)**. The remaining
**111.069 minutes** combines analysis, coding, review, documentation, orchestration,
unrecorded operations and possible idle time; it is not measured waiting time.
These are wall intervals, not CPU usage or agent labor.

The final receipt is `selfhost/build/phase52/time-use-final.json`, SHA256
`dd28f397fd7d1bc0b2de570f88c3d0cab57cf457894d6bd4736b64e73d4939f9`.
It is complete, uses an explicit cutoff, and rechecks all read input identities.
It records1,991 process intervals, including each individual timing-sample
process. This is not1,991 independent experiments. No duplicate or temporally
enclosed interval was found in this snapshot; no overlap is added twice.

| Recorded process purpose | Union minutes | Process intervals |
| --- | ---: | ---: |
| Checked builds | 5.927 | 7 |
| Source acquisition | 16.335 | 231 |
| Semantic/control jobs | 1.122 | 139 |
| Timed program processes | 35.352 | 1,601 |
| Qualification jobs | 1.857 | 2 |
| Release/install/CLI jobs | 2.218 | 8 |
| Other identified small controls | 0.020 | 3 |
| **Observed union** | **62.831** | **1,991** |

The three “other” rows are the maintained primitive-guard test, the mutual-source
diagnostic and the independent NaN-host diagnostic. They remain visible under
the producer's original classification. Separate compiler-request-cost and
profiler intervals are not present in this receipt; zero classified time is not
a claim that every possible form of work was instrumented.

There are32 failed process receipts, all retained. This count includes harness,
environment, invalid-fixture and known semantic-oracle failures; it is not32
independent compiler defects. The rejected07 performance experiment also remains
recorded even though its output checks/processes passed. See the
[conformance report](conformance.md) and numbered experiment reports for meaning
and successor outcomes rather than interpreting process exit counts as conformance.

The largest recorded process-tree RSS is1,486,135,296 bytes (1,417.289MiB).
Measured targets retain the1GiB Node heap,2GiB process-tree RSS bound and4GiB
available-memory floor. The final portable replay independently passed3 points
and27 fresh samples in10.368408s. The selected full benchmark passed45/669;
release qualification subsequently passed42 legacy and18 direct CLI checks.
Those results are separate evidence, not inferred from time accounting.

This explicit cutoff does not certify writer closure. Subsequent final report
editing, evidence publication, archive capture/verification, commits and pushing
are **outside this accounting window**. After writing the accounting receipt,
this agent stopped raw writes; the lead owns the separate closure decision.
Source-size accounting remains in [accounting.md](accounting.md).

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
| Selected06 batch0,15 points/219 samples | `full-direct06-batch0/report.json` | 367.616 |
| Selected06 batch1,15 points/225 samples | `full-direct06-batch1/report.json` | 377.435 |
| Selected06 batch2,15 points/225 samples | `full-direct06-batch2/report.json` | 379.437 |

The05 batch2 was not started. Its30 completed points/444 samples remain useful
historical evidence, but they are not a full45 result and cannot supply missing
rows for another compiler. The two timing batches occupied748.311 measured
seconds. Their retention is an experimental cost, not a new selected result.

A failed initial build guard is also retained at `build-guard01/run.json`
(5.032s). This table is not a complete failure inventory or an elapsed-time sum.
Direct06's build peak was1,474,224,128 process-tree RSS bytes; its acquisition
peak was580,988,928 bytes. The1GiB Node heap,2GiB tree-RSS limit and4GiB available
memory floor were not increased for these measurements.

Selected06 subsequently completed all45 points/669 fresh samples. Its three
batches took1,124.488 measured seconds (18.741 minutes), consistent with the
pre-run estimate below. The aggregate separately checks identities and oracles;
it does not count Python report work as generated-program execution.

## Pre-run benchmark estimate (retained)

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

The reviewed and now executed [time-use-v1.py](../../selfhost/tools/performance/phase52/time-use-v1.py)
is a small derivative of the reviewed Phase48 interval method. It reads completed
`process.json` and `run.json` supervisors, deduplicates identical command/time
rows, excludes temporally enclosed child intervals from summed occupancy, and
unions the remaining half-open intervals. Partial overlaps have an explicit
mixed category. Both successful and failed jobs remain visible.

The final data-only invocation was:

```bash
taskset -c 0 python3 selfhost/tools/performance/phase52/time-use-v1.py \
  --root selfhost/build/phase52 \
  --end 2026-10-05T17:43:42Z \
  --out selfhost/build/phase52/time-use-final.json
```

Without `--end` this is explicitly provisional. A final cutoff does not itself
prove writer closure. Wall occupancy is not CPU usage or agent labor. Uncovered
time includes analysis, coding, review, documentation, orchestration, unrecorded
operations and possible idle time; it must not be relabeled “waiting.” The accounting producer ran after all target jobs. It executed no compiler or
generated program. Its output is consumed evidence; a rerun requires a fresh
output path rather than replacing this receipt.

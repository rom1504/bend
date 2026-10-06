# Phase53 time and resource accounting

At the explicit cutoff **2026-10-06T00:09:58Z**, 80.13 minutes had elapsed
since 2026-10-05T22:49:50Z. Finished recorded processes occupy **35.12 minutes**
of that wall interval; **45.01 minutes** are outside those intervals.
The remainder includes analysis, implementation, review, documentation,
orchestration, unrecorded operations and possible idle time. It is not a measure
of waiting, CPU usage, agent work or inference cost. Packaging and final
publication after this cutoff are a separate tail.

| Recorded outer-job category | Wall-union minutes |
| --- | ---: |
| build | 2.00 |
| acquisition | 9.79 |
| control | 0.74 |
| timing | 19.34 |
| qualification | 0.89 |
| release | 2.16 |
| other | 0.21 |

The unchanged producer reads finished `process.json` and `run.json` receipts,
collapses identical intervals, excludes enclosed intervals and unions overlaps.
There are 1055 unique records and 10 retained non-success records.
The category named `timing` follows timing-worker commands and includes portable
replay and one installed output probe; it is not exclusively the clean full45
campaign. The full45 supervisors separately total **1,121.170 seconds
(18.69 minutes)**. Other short semantic controllers fall in `other` according to
the retained command classifier. Missing/unrecorded intervals remain explicit.

The selected build takes 61.092 seconds and peaks at 1,512,972,288 bytes process-tree
RSS. The whole accounting inventory reports a maximum of 1,512,972,288 bytes.
Full timing itself stays below 131 MB for every role. Target commands use CPU 3,
1 GiB Node heap, 2 GiB tree RSS and a 4 GiB available-memory floor. No OOM occurred.
The final timing launch's permission-review timeout produced no benchmark
samples; its retry repeated no completed work. The first legacy release gate's
six Clang sandbox refusals remain preserved with the unchanged successful retry.

Two checked builds, quick semantic falsifiers and two eight-point screens precede
one complete full45 campaign. Eight parallel agents handled distinct source,
controls, routing, benchmarking, analysis, review and packaging tasks; only one
heavy target ran at a time. The invalid left-to-right and eager let-result ideas
were rejected before compiler builds. Reference modules were reused byte-exact;
all reported comparisons use fresh same-run measurements. Compression waited
until clean timing completed.

[Compact accounting](../../selfhost/tools/performance/phase53/evidence/time-summary.json)
binds the complete archived `time-use-final.json`. The raw report retains every
record, category decision, skipped item and failure, so the category totals can
be audited without inventing task-by-task agent time.

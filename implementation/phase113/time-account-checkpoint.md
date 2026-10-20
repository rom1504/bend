# Phase113 time and resource checkpoint

Snapshot: 2026-10-20T21:04:56.841185+00:00. Source reads only; this accounting executed no targets.
The [JSON account](time-account-checkpoint.json) pins each receipt and records
its timing/resource fields, exclusions and calculation rules.

| Measure | Recorded value |
|---|---:|
| Finalized guards | 73: 54 successful, 19 unsuccessful |
| Completed guard wall coverage, interval union | **2,820.404 s (47m 00.404s)** |
| Successful guard wall sum | 2,128.632 s (35m 28.632s) |
| Unsuccessful finalized guard wall sum | 691.772 s (11m 31.772s) |
| Nested/overlap time counted twice | 0 s |
| Ongoing guards excluded | 1: `final31-hosted45-guard` |
| Maximum sampled process-tree RSS | 3,974,184,960 bytes (3.701 GiB) |
| Minimum sampled host available memory | 23,034,712,064 bytes (21.453 GiB) |

The finalized receipt span is 18:15:45.377–20:57:57.450 UTC, or 2h 42m 12.072s.
From the design's minute-resolution 18:07 start to the last finalized guard is
2h 50m 57.450s. Neither duration is active-work time. Guard coverage includes
startup, waits and I/O; CPU-seconds, unguarded source work and model labor are
not measured. The longest uncovered interval is **19:55:00.494–20:39:42.695 UTC
(44m 42.201s)**, matching the reported interruption. Other gaps are also left
unattributed, not labeled idle or active.

## Final native31 attempt

The [guard receipt](../../selfhost/build/phase113/p113-final31-qualification-guard/process.json)
is finalized but unsuccessful: 600.764 s wall time, return code 1. The
[job receipt](../../selfhost/build/phase113/p113-final31-qualification/report.json)
records a 600-second timeout during full hosted compiler emission. This attempt
is included in consumed time; it does not establish a completed native compiler
image or self-reproduction. It also recorded the campaign's largest sampled
RSS and lowest sampled available memory shown above.

All finalized guards record CPU3 affinity, a 16 GiB available-memory floor and
2 GiB or 4 GiB RSS caps. Peaks are sampled process-tree values, not summed
across runs or claimed as integrated memory use. The ongoing
[hosted45 guard](../../selfhost/build/phase113/final31-hosted45-guard/process.json)
is excluded from time and resource totals at this snapshot.

## Reproduction and scope

`complete:false` alone does not mean running: the supervisor uses it for failed
outcomes too. A finalized receipt must contain finite `started`, `finished` and
`wallSeconds`, with nonnegative duration. The account unions finalized
`[started, finished]` intervals and never adds nested job, build or emission
stage durations. No overlapping finalized intervals were found. The monotonic
wall sums differ from the epoch-interval union by less than 0.001 s.

This read-only calculation reproduces the frozen wall coverage without reading
or executing compiler programs:

```python
import json
from pathlib import Path
account = json.loads(Path("implementation/phase113/time-account-checkpoint.json").read_text())
intervals = sorted((r["snapshot"]["started"], r["snapshot"]["finished"])
                   for r in account["finalizedReceipts"])
merged = []
for start, finish in intervals:
    if merged and start <= merged[-1][1]:
        merged[-1][1] = max(merged[-1][1], finish)
    else:
        merged.append([start, finish])
print(sum(finish - start for start, finish in merged))
```

Scope is guard receipts under `selfhost/build/phase113`. Original finalized
receipt paths, SHA256 pins and metadata are in the JSON; ongoing snapshots may
change later and must not be retroactively included. This checkpoint makes no
claim that all campaign elapsed time was target execution, or that successful
guard exit establishes every semantic/performance claim.

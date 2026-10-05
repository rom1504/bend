# Phase47 recorded wall-time audit

**Explicit cutoff; receipt completeness remains bounded by the scanned inputs.**

Window: 2026-10-04T23:00:16Z to 2026-10-05T01:32:22Z (152.10 minutes).

Observed supervised wall: **68.64 minutes (45.1%)**; uncovered: **83.46 minutes**.

| Job category | Union-attributed minutes |
| --- | ---: |
| build | 16.67 |
| correctness | 1.78 |
| performance | 41.44 |
| compiler-cost | 7.84 |
| profiles | 0.81 |
| misc | 0.12 |

2014 unique process records; parent/child and overlapping receipts count once. 21 duplicate record locations collapsed.

Half-open timestamp interval union, clipped to campaign window. Exact command/start/finish duplicates collapsed. Overlapping parent/child jobs count once; category attributed to shortest active supervisor interval. Categories describe job intent, not exclusive CPU stages.

Observed wall includes supervised host/tool setup and waiting, not CPU utilization. Uncovered time can include analysis, docs, handoff, preservation, unrecorded jobs and idle time; it is not a claim that all thinking was active. Only process.json/job*.json read; ongoing records without observed duration excluded. Finality requires an explicit cutoff and writer closure, not just this report.

Two full representative runs were needed after the first corpus exposed a missed private tree path. Future pre-corpus activation checks should instrument the actual private entry reached by the workload, rather than only the corresponding public wrapper.

Full data and input hashes: `implementation/phase47/evidence/time-use.json`.

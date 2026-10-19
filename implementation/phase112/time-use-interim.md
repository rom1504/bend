# Phase112 time use: interim through 02:00 UTC

The recorded target work occupied **35m41s of the first 79m (45.2%)**. This is
the union of guard intervals, including unsuccessful attempts. The remaining
**43m19s is unclassified wall time**, not evidence of idle time or waiting.
Source implementation, reviews, experiment preparation, disk recovery,
coordination and unrecorded host work cannot be separated using these receipts.
Agents also worked while the serial target queue ran.

Window: **2026-10-19 00:41–02:00 UTC**, within the planned 00:41–03:41 campaign.
The snapshot was taken at 02:00:55. It contains 45 guards completed by the cutoff
and one subsequently completed guard crossing it; that last interval contributes
only its first 123.22s. No recorded guard intervals overlap. These are process-tree
wall intervals, not CPU seconds, model token expenditure or agent labor hours.

| Guard workload | Wall time | Share of elapsed time |
|---|---:|---:|
| Full compiler image acquisition | 4m50s | 6.1% |
| Native self-reproduction | 9m20s | 11.8% |
| Focused source, IR and semantic loops | 4m19s | 5.5% |
| Representative benchmark acquisition | 5m28s | 6.9% |
| Mixed qualification and benchmark batches | 10m31s | 13.3% |
| Dedicated generated-program timing | 1m02s | 1.3% |
| Dedicated profiling | 12s | 0.2% |
| Outside recorded guard intervals | 43m19s | 54.8% |

The labels describe whole guard envelopes. A mixed batch is not counted again
under its constituent tasks. Some focused qualification includes compiler API
acquisition and generated-code execution. The accounting tool exposes every
command and marks its default category provisional for review in future runs.

Several nested receipts explain the costs without adding new wall time:

- The full acquisition guard's 289.86s contains 280.66s for hosted emission and
  9.03s for machine-code construction. Inside hosted emission, the checked
  frontend took 150.25s, lowering 28.62s, IR verification 39.07s and QBE emission
  59.57s. Repeated full acquisition is therefore expensive even though QBE/as/link
  is short.
- The 560.25s native self-reproduction guard contains 550.53s of native emission,
  with byte-exact agreement and subsequent executable construction. Together,
  initial acquisition and self-reproduction account for 14m10s, or 39.7% of
  recorded target occupancy.
- `first-image-jobs01` contains 61.90s of focused native qualification and 122.56s
  of representative runtime comparisons. `selector-fixtures-jobs01` contains the
  complete 113.84s matched compilation transport job. The transport report's own
  113.32s clock is nested here and is **not another 113 seconds of campaign time**.
- Twelve guard workflows returned nonzero, consuming 6m38s altogether. This is
  an outcome cross-cut, already in the table. It includes useful falsification
  and harness failures; it is not a measurement of wasted work. Three old
  Unicode acquisition/diagnostic attempts alone occupied 4m37s, making repeated
  attempts at the same blocked baseline a concrete cost to bound.

The evidence supports retaining one serial target queue, short API/IR control
loops for development, and full image/self-reproduction gates at integration
boundaries. It does **not** establish that target execution dominated elapsed
time or that more target CPUs would eliminate the unclassified 43 minutes.
Future plans should record start/finish events for source-work and review tasks
if a fuller time budget is required; no retrospective estimates are invented.

The exact snapshot is
`selfhost/build/phase112/time-accounting-interim01/report.json`. Its method is
[`time-accounting.py`](../../selfhost/tools/performance/phase112/time-accounting.py),
SHA256 `0d243935e061d7fa91a26cf8f771dcbe34ef3cb128ea85e290cfb1a4cb65cceb`.
Input receipt hashes, interval boundaries, direct child-job durations and
limitations are retained there. The final evidence capsule includes this JSON.

For a fresh final snapshot, after the intended target jobs finish:

```sh
python3 -B selfhost/tools/performance/phase112/time-accounting.py \
  --start 2026-10-19T00:41:00Z --until now \
  --out selfhost/build/phase112/time-accounting-final01/report.json
```

This command performs only bounded receipt analysis. An explicit cutoff such as
`--until 2026-10-19T03:41:00Z` is accepted once that time has passed. Open guards
without a recorded finish remain separate rather than being assumed to have run
continuously. Review newly introduced category labels before final reporting;
the interval-union total is independent of those labels. Seal evidence after
this snapshot, following [`evidence/README.md`](evidence/README.md). Its existing
scope includes both Phase112 receipts and every Phase111 `p112-*` subtree.

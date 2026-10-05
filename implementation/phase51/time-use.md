# Phase51 time use

The recorded phase clock starts at **07:00:18 UTC on 2026-10-05**. At the explicit
**08:13:45** accounting cutoff, 73m26s had elapsed. Initial repository reading
preceded this clock; final documentation, archive and Git publication follow the
cutoff and are not included. Raw writers closed at 08:18:41 UTC, 78m23s after
the recorded start; archive and Git publication occur after that closure.

The unchanged, parameterized Phase48 accounting tool reads only finished process
receipts in the Phase51 tree. It finds **1,046 distinct intervals, no overlap,
and 36m02s of observed execution occupancy**. Occupancy is elapsed process time,
not CPU usage or the sum of agents' work. The remaining 37m25s includes analysis,
implementation, reviews, documentation, orchestration and unrecorded operations;
it cannot honestly be labeled simply as waiting.

| Execution category | Observed seconds |
| --- | ---: |
| One checked build plus focused gate | 53.48 |
| 27 source acquisitions | 247.98 |
| Controls/maintained suite processes | 34.42 |
| Clean timing processes | 1,356.05 |
| Backend census and native retry | 383.01 |
| Five profile/trace processes | 31.03 |
| Installation, verification and 42 CLI checks | 54.06 |
| Other diagnostic controls | 1.70 |

Categories classify outer-job intent. The full45 runner's three complete batches
took 1,142.93s including orchestration; its target intervals are part of the timing
row, not an additional cost. The portable replay took 10.65s. The first census
included 17 Clang permission refusals, costing a 91.12s native-only retry; already
accepted JavaScript/interpreter cases were not rerun. Peak observed tree RSS was
1,470,701,568 bytes, below the 2GiB limit.

Four agents worked independently on guard experiments, dispatch experiments,
static review and qualification preparation. Root serialized targets and compiler
work. Five saved-output variants/screens preceded one integrated checked build;
the final full corpus ran once. Reusing the checked output and unchanged semantic
controllers avoided rebuilds during the semantic, performance and V8 followups.

The main cost to reduce next time is now clear: keep the early saved-output loop,
reuse these tools, and reserve the roughly 19-minute full comparison for the
release candidate. Do not infer that more concurrent timing would improve the
quality of the measurement. The published 20/60/300-second selections and frozen
outputs are ready for the next experiment without corpus compilation.

`time-use01.json` is retained; `time-use02.json` changes only the category of the
one trace embedded in the fixed-work queue from timing to profiles, at the same
cutoff. Interval totals are identical. No durations from failed processes are
discarded, and the archive/Git stages are not disguised as target execution.

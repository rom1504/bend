# Phase118 observed time accounting

Window: 2026-10-21T09:47:34+00:00 to 2026-10-21T12:48:23.207153+00:00.

Elapsed wall time: **180.82 min**. Finished-guard union: **84.41 min**.
Including open-receipt envelopes: **84.41 min**; uncovered elapsed: **96.41 min**.
102 unique receipts; statuses: `{"failed": 18, "success": 83, "timeout": 1}`.
Summing receipts would count **0.00 min** of overlap/nesting again.

| Outermost named campaign | Disjoint minutes |
| --- | ---: |
| native qualification | 35.58 |
| broad qualification and emission | 15.48 |
| focused experiments and mixed pipelines | 13.53 |
| other guarded work | 6.00 |
| hosted cost | 5.44 |
| checked API acquisition | 4.25 |
| profiling and IR inspection | 3.81 |
| runtime acquisition | 0.28 |
| finite controls | 0.05 |

Failed/stopped intervals are included above, not discarded. Their union is 17.71 min; this is not automatically wasted time.

| Failed/stopped guard | Status | Seconds |
| --- | --- | ---: |
| trmc-api01-guard | failed | 3.21 |
| borrow-api01-guard | failed | 2.75 |
| trmc-api02-guard | failed | 2.42 |
| borrow-api02-guard | failed | 3.01 |
| trmc-api03-guard | failed | 4.91 |
| borrow-api03-guard | failed | 5.32 |
| trmc-api04-guard | failed | 5.28 |
| combined-controls-emit01-guard | failed | 5.56 |
| observer-error01-guard | failed | 2.55 |
| reuse-emit01-guard | failed | 0.06 |
| compiler-inspect01-guard | failed | 33.64 |
| compiler-inspect02-guard | timeout | 120.12 |
| scalar-controls-emit01-guard | failed | 6.07 |
| reuse-sized-emit01-guard | failed | 0.04 |
| float-jobs01-guard | failed | 2.22 |
| p118-native-float01-qualification-guard | failed | 589.62 |
| safe-api-guard01 | failed | 2.89 |
| dce-guard03 | failed | 13.77 |
| p118-native-safe02-qualification-guard | failed | 259.21 |

## Limits

- Guard wall duration includes subprocess/build/validation/orchestration time, not CPU time.
- An open receipt is an unfinished envelope, not proof its process remains active; it may be stale.
- Categories label outermost named campaigns; bundled API, finite, and target work is not split without timestamps.
- Uncovered elapsed time is unclassified, not thinking time: includes unguarded source work, tools, agents, waiting and possible missing receipts.
- Source/static audits and agent/model tokens, monetary cost, quota, billing and CPU-seconds are not measured here.
- mtime prefilter assumes normal ExecutionGuard writes; backdated/copied receipts outside selfhost/build require an explicit supplemental audit.

The JSON includes pinned receipt snapshots, exact commands, all intervals and category ownership. Rerun into a fresh directory after active jobs finish; never overwrite this snapshot.

This snapshot ends after three hours of work; final documentation/commit/push
follow it. No target was left running. Guard categories are outer campaign names:
`other guarded work` includes134.997s native timing and222.526s isolated lazy-cost
work, so it is not all overhead. The unclassified interval includes source work,
review, tools, communication and waiting; no exact split is measured. Agent/token/
quota costs cannot be reconstructed from these process receipts.

# Phase118 execution-time accounting

`time-accounting-v2.py` reads existing `ExecutionGuard` receipts and writes a
fresh JSON/Markdown snapshot. It never launches a compiler, generated program,
benchmark or profiler, and does not acquire or interrupt the target lane.

```sh
python3 -B selfhost/tools/performance/phase118/time-accounting-v2.py \
  --start 2026-10-21T09:47:34Z \
  --out selfhost/build/phase118/time-accounting03
```

Choose a fresh directory for each update. `--until` accepts an ISO UTC cutoff;
otherwise the tool snapshots the host wall clock before discovery. Ongoing jobs
can finish while the tool reads files: intervals are clipped to that cutoff and
classified as open at the cutoff if their recorded finish is later.

Outputs are `report.json`, `report.md` and `receipts.json`. The last contains
exact receipt contents and hashes, including failures, timeouts and unfinished
receipts. A later update to a live guard does not silently alter the saved view.
Replay the saved inputs using the original report's exact cutoff:

```sh
python3 -B selfhost/tools/performance/phase118/time-accounting-v2.py \
  --start 2026-10-21T09:47:34Z \
  --until COPY_THE_SNAPSHOT_REPORT_WINDOW_END \
  --snapshot selfhost/build/phase118/time-accounting02/receipts.json \
  --out selfhost/build/phase118/time-accounting02-replay
```

The placeholder must be replaced by `windowEnd` from the saved report. A replay
reconstructs the captured inventory, not files that arrived after that snapshot.
ISO timestamps round to microseconds: replay of snapshot02 preserves every
receipt, status, category and interval ownership, with a maximum numerical time
difference of0.477 microseconds. Union tests also cover nested and crossing
intervals; comparisons use a one-microsecond absolute tolerance for timestamps.

## Definitions and attribution

- **Elapsed wall time** is cutoff minus the supplied phase start.
- **Finished-guard union** measures the union of completed receipt intervals,
  including unsuccessful work. Nested guards never count twice.
- **Guard-envelope union** adds unfinished receipts from their start to cutoff.
  This is explicitly an envelope: an unfinalized receipt may be stale, so it is
  not proof that a process was active for that entire duration.
- **Uncovered elapsed** is elapsed minus the envelope union. It is unclassified,
  not agent thinking time. It includes unguarded edits and analysis, tool overhead,
  waiting, possible missing receipts and other activity. Agents may also work
  while guarded jobs execute, so neither side is an agent-time total.
- **Summed receipt time** and the difference from the union expose overlap and
  nesting. A disjoint interval partition assigns each time slice once to its
  outermost campaign. Non-nested overlapping categories get an explicit mixed
  category rather than an arbitrary attribution.

Categories are reproducible name/command heuristics for checked API acquisition,
finite controls, focused/mixed pipelines, broad emission/qualification,
profiles/IR inspection, hosted cost, runtime acquisition and native qualification.
A bundled root guard may contain API building, controls and native program builds;
without separate timestamped receipts its time remains in the campaign category.
These are not accurate per-pass compiler timings. A failed guard can mean a
driver assertion or source check failed; it does not imply incorrect generated
code. Negative experiments remain in the totals and may provide useful evidence.

Discovery searches **all** `process.json` paths under `selfhost/build`, including
ignored and hidden trees, then requires the ExecutionGuard schema and overlapping
recorded timestamps. Old file mtimes are an efficiency prefilter: ordinary guard
writes happen after their start. Backdated receipts or artifacts outside that
tree require a supplemental audit. Duplicate start/command identities count once;
aliases remain in the report. The recorded start/finish wall-clock interval is
used for unions, while the original monotonic `wallSeconds` is retained per row.

No CPU-seconds, model tokens, quota percentage, billing, monetary cost, attention,
or total agent-research effort is available from these receipts. Source-only
audits and static analyses generally have no guard receipt; this accounting
cannot assign their cost or measure their overlap with target execution.

## Initial evidence and version history

`time-accounting01` covers09:47:34–12:13:53UTC:146.33min elapsed,52.28min finished
guard union,55.25min including one unfinished native-safe03 envelope, and91.08min
unclassified elapsed. It records99 guards:79 successful,18 failed,1 timeout and1
unfinished. Failed/stopped intervals total17.71min; this is not automatically
wasted time. Native-float01 and native-safe02 failures account for14.15min of it.

The first tool respects ignore rules. V2 expands discovery to ignored/hidden
paths; the original tool and snapshot remain unchanged so their pins stay valid.
Use `time-accounting02` or a later V2 snapshot for full discovery and updated
native-job status. Do not quote snapshot01 as the eventual phase total.

The initial full raw discovery also found no qualifying contemporaneous guard
outside Phase118. A global read of every historical JSON was unnecessarily slow;
the current tool avoids that by filtering old mtimes before opening the nearly
50,000 historical receipt bodies. This source audit itself is outside guard
execution and is not relabelled as target time.

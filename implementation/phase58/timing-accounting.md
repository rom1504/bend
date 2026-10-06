# Phase58 wall-time accounting procedure

This is a prepared data-only ledger, not a completed time report. Root supplies
the cutoff after the selected target jobs finish. The start receipt records
`2026-10-06T07:30:12.793654+00:00`; its scope explicitly excludes initial planning
before that timestamp. No compiler, generated program or archive runs during
the accounting command.

Reuse the frozen [Phase52 reader](../../selfhost/tools/performance/phase52/time-use-v1.py),
SHA256 `74f1435846cdd22f71dd7b8b2d5bbbbdbcc872ce3886fe583359099f16fe8520`.
It already accepts another raw root and the `startedUtc` start schema. Its pinned
Phase47 timestamp/interval helpers remain unchanged, and Python bytecode writes
are disabled. The Phase52 receipt kind denotes this historical method; the
actual Phase58 root, start and consumed receipts identify the new campaign.

```sh
taskset -c 0 python3 -B selfhost/tools/performance/phase52/time-use-v1.py \
  --root selfhost/build/phase58 \
  --categories selfhost/tools/performance/phase58/time-use-categories-v4.json \
  --end ROOT_SUPPLIED_UTC_CUTOFF \
  --out selfhost/build/phase58/time-use-final.json
```

The output must be fresh. Omit `--end` only for an explicitly provisional
snapshot in a different output path. Supplying a cutoff does not prove that
writers have closed. Publication, preservation sweeps or compression after the
cutoff are outside this ledger and must be reported separately. Do not run this
command during target timing or after raw writer closure.

## What the ledger measures

Read only `process.json` and `run.json` supervisory receipts beneath the new
raw root. Require a command, start, finish and measured wall interval; retain
unfinished or malformed entries in the skipped list. Final input rehashes detect
a consumed receipt changing during the snapshot. A newly created receipt during
the scan may be absent, so the final run follows root's target cutoff.

1. Collapse repeated locations with the same command/start/finish triple.
2. Identify intervals completely enclosed by another recorded interval. Retain
   their failures and RSS peaks, but exclude their durations from the outer-job
   sum. This is temporal containment, not an inferred operating-system process
   ancestry relation.
3. Clip the remaining intervals to the start/cutoff and union their half-open
   ranges. Partial overlaps of different categories receive an explicit mixed
   bucket. No child durations or inclusive spans are added twice.
4. Preserve failed and interrupted completed jobs. Their time was still spent;
   success is independent of accounting. A live job with no finish is omitted
   and disclosed, rather than assigned an invented duration.

The result gives elapsed wall time, observed interval-union occupancy, category
union totals, naive versus deduplicated sums, overlap diagnostics and the largest
recorded process-tree RSS. These are supervisor wall intervals, including host
startup and any setup inside the supervisor. They are not CPU usage, exclusive
compiler time, agent effort or a clean benchmark. The maximum RSS is a maximum
observed tree peak, not summed memory use or a continuous campaign measurement.

## Category assignments

The [versioned category map](../../selfhost/tools/performance/phase58/time-use-categories-v4.json)
assigns exact raw path prefixes to known outer-job purposes. The longest match
wins; unmatched rows use the frozen reader's command classifier and remain
explicitly `other` if no rule matches. Current clean compiler-latency pilots are
`cost`; these durations include all work inside their captured supervisors,
not just the clean per-request metric. Inspector diagnostics, if added later,
must use `profiles`, not a latency category.

V2 preserves all 50 v1 entries and adds the earlier shared matrix's explicit paths:
B1/B2 preparation, clean request measurements, CPU/allocation captures, the
own-source clean and instrumented supervisors, the three program timing batches,
selected self-check/fixed-point/program-equality supervisors, B2 semantic gates,
and shared supplement acquisition/control supervisors. CPU/allocation paths
must be explicit because the frozen fallback does not recognize `--mode cpu`
or `--mode allocation` alone. The original map remains byte-identical
(`4817acb4…`); preparing the successor did not run the ledger.

| Category | Meaning |
|---|---|
| build | Genuine checked-image construction and its enclosed selected probes |
| acquisition | Checked fixture/program emission and enclosed cache preparation |
| control | Focused semantics, native representatives and value smoke controls |
| qualification | Maintained suites, own-source/bootstrap checks and fixed-point work |
| timing | Generated-program execution under the unchanged timing worker |
| cost | Clean compiler-request measurement jobs, including their outer setup |
| profiles | Instrumented CPU/allocation/trace jobs |
| release | Install, verify, CLI/relocation and portable replay jobs |
| preparation / other / overlap-mixed | Recorded preparation, unclassified intent or overlapping purposes |

Before final consumption, inspect `otherRecords`, skipped entries and any mixed
overlap. If a new selected output path needs an explicit category, preserve this
map and create a reviewed successor with the narrow additions. Recompute only
the data-only ledger into a new output; never edit a consumed time receipt.

The difference between phase elapsed time and observed union is **unrecorded
wall time**. It can include design, source edits, reviews, report writing,
orchestration, unrecorded operations and idle time. It must not all be labeled
waiting or attributed to one person. Root's concurrent edits and agent work are
not recoverable from target supervisor receipts. Keep these limits next to any
work-versus-test comparison.

V3 adds the diagnostic and last01 qualification/program paths. V4 preserves all
118 v3 mappings and adds the seven actual `comparison-last01` job prefixes. The
earlier planned `latency-final-*` aliases remain harmless unused entries; actual
clean versus instrumented jobs use explicit V4 categories. No category file
changes a completed measurement.

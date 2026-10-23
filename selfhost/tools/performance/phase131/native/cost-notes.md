# Phase131 incremental cost and evidence snapshots

`cost-snapshot.py` reads only guard receipts below `selfhost/build/phase131`.
It executes no compiler/program and writes a fresh report plus a small incremental
archive. Completed receipts, bounded logs and nearby completed control reports
are archived; large source, SSA, machine products and profile payloads remain in
their original locations. Their absence is not represented as full semantic
evidence archival.

Refresh after the remaining campaign finishes:

```sh
taskset -c 1 python3 -B selfhost/tools/performance/phase131/native/cost-snapshot.py \
  --previous selfhost/build/phase131/native-cost02/report.json \
  --out selfhost/build/phase131/native-cost03
```

Choose another fresh suffix if that output already exists. Keep every predecessor
report/archive; each new report pins its predecessor and lists the cumulative
archived identities. Archives contain only new or changed small evidence files.
The cost report itself is alongside its archive rather than included recursively.

Interpretation matters:

- Guard wall sums count guarded subprocess/wrapper duration. They are neither
  CPU seconds, elapsed research time, agent tokens, quota nor billing.
- Interval unions show overlap across concurrent lanes; per-CPU unions separate
  actual lane occupancy from an aggregate sum. They do not measure unguarded
  research or prove how much useful CPU work occurred.
- CPU3 contains acquisition, clean comparison, profiling and correctness work.
  Only explicit timing runners receive the clean-timing category. CPU4 is the
  proof/law lane; CPU5/6 are separate correctness and diagnostic investigations.
- Category and negative-control labels are visible command/path rules. All raw
  commands, statuses and per-receipt pins remain available for independent review.
  A law mutation or malformed proof may correctly return nonzero. Such cases are
  labeled separately; the label itself is not a semantic proof that rejection
  was expected.
- Incomplete/unstable receipts and work after the snapshot cutoff are excluded
  with explicit reasons. Refresh rather than treating a live snapshot as final.

The first snapshot had a classification bug: the absolute path component
`selfhost` matched the word `self`, so acquisition was labeled self-emission.
`native-cost02` corrects this by inspecting only relative guard-name components.
Counts and times in the earlier report were unchanged. The original method is
preserved at `selfhost/build/phase131/native-cost-methods/999770e0c9b13a6cfcdcbc2eea5e2e9adc50eb24885379ee279e18901098d135.py`.
Use cost02 or later for purpose totals. Original failed attempts and receipts
remain intact.

At cost02's cutoff,225 completed guards account for2,174.70 summed guard seconds
and1,868.93 seconds of interval union. Forty-two have nonzero/incomplete status;
16 of those carry negative-control labels, leaving26 other failures. This is a
provisional cost snapshot, not the completed phase total.

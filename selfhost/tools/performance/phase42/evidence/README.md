# Phase42 published evidence

The [release report](../../../../../implementation/phase42/README.md) links the
results, correctness, profiles, compilation cost and time account.
[selected-release.json](selected-release.json) indexes the exact chosen reports.

## Closed raw campaign

[campaign-archive01/archive.json](campaign-archive01/archive.json) inventories
**34,982 files**, including successful and failed experiments, source snapshots,
receipts, generated programs, all samples, profiles and the complete job ledger.
[raw-campaign.tar.gz](campaign-archive01/raw-campaign.tar.gz) is91,512,582bytes,
uncompressed659,999,726bytes; SHA256:

`bc1a5ead1eee4cec316e1c21f84ad44890c7ccc457053b9c519cea0ec0cda7a7`

The archive was independently reopened and every member hash checked. Raw-file
membership and contents were verified unchanged after capture. The
[writer closure](writers-closed01.json) was declared only after all jobs and raw
writers stopped. [Publication](publication01.json) took50.03seconds outside the
closed experiment ledger. All 103 unrelated starting files are unchanged and
unstaged; `protected-final.json` retains the check.

To inspect raw evidence without writing into a historical campaign directory:

```sh
mkdir /tmp/phase42-evidence-NEW
tar -xzf selfhost/tools/performance/phase42/evidence/campaign-archive01/raw-campaign.tar.gz \
  -C /tmp/phase42-evidence-NEW
```

The report index uses paths relative to the archive's Phase42 root. Absolute
paths in old receipts describe the original execution environment. For portable
performance replay, use the separately verified [baseline](../baseline/manifest.json)
and [current](../current/manifest.json) bundles, following the [guide](../README.md);
replay does not require extracting this large raw campaign.

## Derived publication files

The final per-point table and plot come from the complete669-sample three-batch
closure. Renderer v2 preserves unavailable drift values as null/NA and records
missing counts; it never treats missing drift as stability. The 45-point SVG uses
a0.1×–512×log axis, with zero clipped or omitted points. All paired samples,
medians and ranges remain in the raw reports and published machine table.

The [accounting tool](summarize.py) records enclosing job intervals without
adding nested child intervals. The 335 jobs have no recorded overlap. Its explicit
cutoff precedes archive publication and final documentation/Git delivery.
Unclassified time is not identified as model latency or idle time.

The raw archive is closed. Do not rewrite receipts or append to its ledger.
New experiments and any re-rendering must use fresh output paths and retain the
original producer identities. Documentation written after closure lives outside
the raw archive and is versioned in Git.

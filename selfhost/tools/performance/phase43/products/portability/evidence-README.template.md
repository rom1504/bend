# Phase43 published evidence

The [release report](../../../../../implementation/phase43/README.md) explains
selected correctness, performance, profiles, compiler cost and accounting.
[selected-release.json](selected-release.json) binds exact attempt/API, report
members and hashes. Portable replay uses the separately verified
[baseline](../baseline/manifest.json) and [current](../current/manifest.json)
bundles and the [budget/profile guide](../README.md); replay does not require
extracting the complete raw campaign.

[campaign-archive01/archive.json](campaign-archive01/archive.json) inventories
`FINAL_MEMBER_COUNT` raw files, including failed experiments, source snapshots,
receipts, generated programs, all samples, profiles and the closed job ledger.
[raw-campaign.tar.gz](campaign-archive01/raw-campaign.tar.gz) is
`FINAL_COMPRESSED_BYTES` bytes, `FINAL_UNCOMPRESSED_BYTES` uncompressed; SHA256:

`FINAL_ARCHIVE_SHA256`

Every member was independently reopened and hash checked; raw membership and
contents were verified unchanged after capture. [writers-closed01.json](writers-closed01.json)
was declared only after all target, agent, ledger and accounting raw writers
stopped. [Publication receipt](run-publication01/run.json) lives outside the closed
experimental root and retains command, timing, bounds and process logs. The 103
protected starting files are unchanged and unstaged; their exact final receipt is
indexed by member+SHA in selected-release.json.

To inspect raw evidence in a new directory:

```sh
mkdir /tmp/phase43-evidence-NEW
tar -xzf selfhost/tools/performance/phase43/evidence/campaign-archive01/raw-campaign.tar.gz \
  -C /tmp/phase43-evidence-NEW
```

Report members are relative to the archived Phase43 raw root. Absolute paths
inside original receipts describe the original execution host. The raw archive
is closed: new experiments, rerendering or documentation go outside that root,
retain original producers, and never rewrite archived receipts or its ledger.
The portable 45 current manifest retains exact selected acquisition provenance;
its three-role replay compares Phase43 against Phase42 checked16 and unchanged
pinned TypeScript. Phase42 bundles, raw archive and ledgers remain intact.

The selected receipt index must include complete preinstall and postinstall
composite closures, all 34 owner closures (16 inherited plus 18 new), strict
installed audit and launch, selected full 45 timing closure and sample table,
performance/cost admission, compiler-cost report, source counts, profiles,
portable plan/fast/target replay, protected-final, writer closure and archive
manifest. Failed or prototype-only evidence cannot replace those selected-image
requirements. Profiles have separate budgets and do not establish speed ratios;
missing drift remains unavailable. Accounting uses enclosing job intervals,
without adding nested child intervals; archive publication is outside its cutoff.
Final prose created after closure is not claimed as content of the raw archive.

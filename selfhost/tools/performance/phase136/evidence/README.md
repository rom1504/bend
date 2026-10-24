# Phase136 evidence and research cost

These tools read receipts and archive source/metadata only. They do not execute
the compiler, profiler, benchmark or machine toolchain. Run them only after the
coordinator confirms all selected writers have finished. Failed attempts remain
visible and do not acquire successful validation status merely by being archived.

`costs-v01.py --out implementation/phase136/costs.json` retains successful and
failed guard clocks, resource receipts and nested tool/native observations.
It reports the sum of guard wall intervals and their observed interval union
separately. The first is resource-lane exposure; neither includes all agent work.
Nested compiler/process/stage/tool clocks are never added to guard totals.
Tokens, quota, monetary cost and unrecorded reasoning time remain unknown.

After that collector and final analysis documents are complete:

```sh
python3 -B selfhost/tools/performance/phase136/evidence/archive-v01.py \
  --writers-closed --out implementation/phase136/evidence01 \
  --root implementation/phase136
```

Default roots are all Phase136 build metadata, Phase111 `p136*` API receipts,
Phase134 `p136*` acquisition/baseline receipts, and any Phase130 `p136*` request
receipts. Exact `stages-source01` and `query-source01` sources are included, along
with their frozen modules and all Phase136 methods. Metadata from other result
locations can be added with explicit `--root` paths.

The archive includes physical samples, contexts, callers, symbolized analysis,
the 30.8 MB exact owner map, the authenticated unwind table, attribution methods
and diagnostic stderr. It requires a completed passing profiling capture and
checks each required raw evidence pin. The existing attribution implementation
also authenticates/reads the exact ELF and mapped shared libraries. Those remain
separately pinned external artifacts: this archive is sufficient raw research
evidence, not a self-contained replacement for those binaries.

Full generated QBE, assembly, objects, ELF, shared libraries and hosted `api.mjs`
are excluded. Large `stdout` products are excluded explicitly and keep their
producer hashes. Bounds are 64 MiB per member and 192 MiB total uncompressed;
streaming compression avoids retaining the archive in memory. Every archive
member is reopened and hash-verified, and original inputs are rechecked after
completion. Source and methods are copied as evidence, never transformed.

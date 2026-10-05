# Phase49 evidence and recovery

The entire closed raw campaign is retained: **327 files /
36,273,442 logical bytes**, in one **2,929,563-byte**
[compressed archive](raw/raw-campaign.tar.gz). The producer reopened every member,
verified its size/hash, then rehashed the original inventory. No target or compiler
runs during archiving.

SHA-256: `bc63eeffa2e8329c29b4181ef2a30c8d781887b696a0087b0456619d7305bfe0`.

- [Evidence index](index.json) binds reports, tools, frozen input modules and prerequisites.
- [Archive manifest](raw/archive.json) gives every member's relative name, size and hash.
- [Writer closure](writers-closed.json) records the terminal boundary at
  `2026-10-05T05:52:23.944855+00:00`.
- [Protected-file check](protected-final.json) verifies all 103 unrelated starting files.
- [Measurement summary](../../../../../implementation/phase49/evidence/measurements.json)
  independently recomputes the recorded medians/profiles and checks 131 inputs.
- [Original modules and provenance](../inputs/manifest.json) retain the exact
  TS/array06/rejected-values03 sources used by every role.

All 63 public-call jobs returned the expected result. The original incomplete
TypeScript optimizer dump remains a failed artifact inside the otherwise
successful job; its longer-run successor is separate. Three guard-removal
modules are deliberately unsafe diagnostic derivatives and remain uninstalled.

The unchanged [archive producer](../../phase42/validation/archive-campaign-v1.py)
uses its historical Phase42 schema; `rawRoot` identifies Phase49. Its attempt/API
fields identify the unchanged installed RNFA04 compiler, not a new checked build
or the separate rejected values03 diagnostic role. See the role manifest above.

## Recovering the diagnostic artifacts

Verify the compressed size and SHA-256 above before extraction, then choose a
fresh directory:

```sh
mkdir selfhost/build/phase49-recovered-NEW
tar -xzf selfhost/tools/performance/phase49/evidence/raw/raw-campaign.tar.gz \
  -C selfhost/build/phase49-recovered-NEW
```

Rehash extracted members against `raw/archive.json.files`. The archive contains
all raw configs, process receipts, profiles, traces, three completed optimizer
graphs, the incomplete first graph, guard derivatives and consumed method copies.
The original input modules and maintained producers are tracked beside it.

Historical absolute paths remain in receipts. Do not rewrite them to claim
relocatable provenance. For a new execution, follow the [guide](../README.md),
create new configurations with local module paths and the same hashes, and retain
new receipts. Summarizing historical receipts without relocation requires their
recorded paths to remain available. Node24.18.0 and its pinned V8 engine remain
part of the comparison; upgrading the engine constitutes a different experiment.

The Phase48 input/history prerequisites are preserved in its
[evidence index](../../phase48/evidence/index.json). This small capsule does not
repeat those earlier full archives or the Node executable. New work must never
append files to the closed `selfhost/build/phase49` root.

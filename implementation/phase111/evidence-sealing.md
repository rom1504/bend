# Evidence capsule format

[`seal-evidence.py`](../../selfhost/tools/performance/phase111/seal-evidence.py)
creates [capsule01](evidence/capsule01.tar.xz); its adjacent manifest records
member verification and exact source identities. The coordinator validates the
final inventory after all target runs finish.
This is an internal consistency check, not a separate user approval step. The tool never invokes
a compiler, target, shell command or network operation, and never deletes source
or compiled products.

The only recursively inventoried roots are `selfhost/build/phase111`,
`selfhost/tools/performance/phase111` and `implementation/phase111`. The evidence
output directory and Python caches are excluded. All report/manifest JSON,
guard process/method/input records, stdout/stderr/logs and failed attempts are
included. Both receipt `file` identities and shared-guard `path` identities are
recognized when collecting pinned method dependencies. Source and method files
up to 4 MiB, and generated fixture QBE/LLVM IR
up to 2 MiB, are included. ELF binaries, objects, archives, assembly and large
or unclassified products receive hash/size entries while remaining local.

The frozen `full-source05` compiler/modules/manifest, `full-api05` API/report and
`runtime-source03` C/headers/manifest are mandatory. If `runtime-source04` exists,
its C/headers/manifest are also mandatory. Their acquisition pins are
checked before sealing. Direct hash-pinned source/method dependencies referenced
by Phase111 JSON may be copied from the repository's compiler/tool/build source
trees; their hashes must match. No earlier phase is recursively scanned, and
dependency receipts are not followed transitively. External tools/platform files,
non-source dependencies, missing files and changed live versions retain their
recorded identities and explicit disposition. This is a bounded source/evidence
capsule, not a promise that every external prerequisite is embedded.

The archive is a deterministic `tar.xz` containing `index.json`, `summary.json`
and deduplicated `blobs/sha256/HASH` payloads. The index maps original relative
paths to contents and records every excluded artifact identity. Limits are
64 MiB of unique uncompressed payload and 6 MiB compressed, enforced before
compressed writes exceed the cap. The implementation requires the archive cap
plus 2 MiB free disk. It reopens and hashes every member, then regenerates the
entire plan to reject changes during sealing. Existing destinations are refused;
only a failed invocation's own unpublished `.partial` output can be removed.

The summary reports receipt kinds, direct status/scope fields, per-receipt row
counts and explicit success/refusal booleans. It preserves incomplete reports.
Guard wall times and the union of recorded guard timestamp intervals are
separate from top-level receipt seconds grouped by kind. These quantities
overlap. It deliberately does not infer distinct qualified-test totals, elapsed
research time, a compiler performance win or a self-hosting result.

Once target runs have finished, the coordinator obtains the exact read-only plan:

```sh
python3 -B selfhost/tools/performance/phase111/seal-evidence.py --plan > /tmp/phase111-seal-plan.json
```

Inspect its `plan.files`, references, limits and summary. Use the validated
`planSha256` with a fresh output path:

```sh
python3 -B selfhost/tools/performance/phase111/seal-evidence.py --seal \
  --expect-plan-sha256 VALIDATED_PLAN_SHA256 \
  --out implementation/phase111/evidence/capsule01.tar.xz
```

The script writes the capsule plus `.manifest.json` and `.summary.json`
sidecars. A changed inventory requires regenerating and validating the plan. For restoration,
read the index, verify blob hashes and copy only validated destinations into an
empty checkout or staging directory; do not overwrite live source/tools or
assume that hash-only compiled artifacts are present.

The later 128 MiB file-limit guard needs no special capsule exception. Both
`full-native01` (the recorded 64 MiB/SIGXFSZ failure) and `full-native02` are in
the existing recursive scope, including their guards, method identities,
commands and logs. The 50.7 MB compiler QBE, 64/68.8 MB assembly, full object and
executable remain local with streamed SHA-256 identities; they are not payloads.
The source guard retains the shared lock/RSS/deadline supervisor and changes
only bounded per-file admission and disk headroom. The disk check is an admission
floor, not a global quota on all files a command could create.

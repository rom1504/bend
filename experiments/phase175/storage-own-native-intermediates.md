# Phase175 completed native machine intermediates

This is an exact archival proposal, not a completed recovery. Capture and pruning must wait until the active timing pair finishes. No capture, prune or compiler execution was performed to prepare it.

The frozen proposal is `storage-own-native-intermediates.json` (SHA256 `fa6ee5f9d23ea2956670c03baf1eb2a99e4dd193ce0e350967845b592988b7bc`). It selects only `program.s` and `program.o` from the seven completed builds below. All corresponding writers finished successfully and their guard lifecycles are sealed.

| Completed build | Selected allocation (MiB) |
|---|---:|
| `baseline-native01` | 32.543 |
| `field-native01` | 32.852 |
| `publication-native01` | 32.555 |
| `report-native01` | 32.582 |
| `parse-baseline-native01` | 17.207 |
| `parse-precedence-native01` | 17.215 |
| `parse-lookahead-native02` | 17.262 |

Total: **14 files, 182.215 MiB allocated**. A previous assembly/object capsule compressed to 12.446% of source allocation, suggesting roughly **159.537 MiB net recovery** before small receipt/directory overhead. This is an estimate; actual archive allocation and free space must determine the next compiler admission. The 64 MiB archive cap is a safety bound, not a predicted archive size.

## Why these files may become cold

`selfhost/tests/phase175/native-frontend.py:32–44` authenticates reports, bindings, Base/carrier/source, and the executable/runtime/source identities. Its execution path reauthenticates the executable at line 56. It does not read assembly or objects. The active baseline/combined pair retains both executables, and the combined build root is entirely outside this selection.

Every binary, runtime, source, hosted API, retained IR, build report, guard receipt and other unlisted file remains in place. Future relinking or assembly inspection will require restoring these exact products. The proposal does not alter any qualified image, selector or resource guard.

## Capture and independent apply

After timing stops, the coordinating agent should take the maintained shared execution lock and authenticate the proposal, tool identities, successful report/guard receipts and exact current file metadata. Expected content hashes come from the original completed build reports; this metadata-only review did not reread large products during timing. Capture must independently verify their current bytes.

Use `selfhost/tools/build-retention/close.py` `capsule` with exactly each root’s two selected rows and fresh `captureOut`. Preserve the normal **5 GiB free-space floor**, **64 MiB archive cap per root**, and **128 MiB member cap**. Do not reopen or edit existing sealed lifecycle receipts. Reopen/hash each complete new archive and check source stability; then use the unchanged `archive-v02.py verify` and require exact approved paths, hashes, metadata and allocation totals. Only a separate successful `apply` may unlink the approved leaves. Keep the archive, receipt, verification plan and application journal.

The JSON includes a fresh capture destination and exact apply/restore command for every root. No whole directory deletion or broad dependency scan is needed.

## Restoration

For example, after the baseline capsule has been captured, verified and applied:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/own-intermediates-baseline-native01/verified/plan.json \
  --out selfhost/build-retention/phase175/own-intermediates-baseline-native01/restored
```

`restore` recreates the original selected paths by default. `--out` names a fresh restore journal, not a new destination for recovered products. Reserve enough disk for raw restored files first; use a new journal path for a later repeat. The other six exact commands are recorded in the proposal.

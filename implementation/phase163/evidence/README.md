# Phase163 exact evidence

`capsule.zip` contains source snapshots, preparation manifests, exact result
reports, raw paired timings, diagnostic output and original guarded commands.
`inventory.json` maps every member to its original path, byte count and SHA256.
`seal.json` authenticates the capsule and inventory. Every archive member was
read back and checked before the copied loose staging files were removed.

Useful members:

| Question | Member |
|---|---|
| Native source→QBE request speed | `native-optimized-requests01/report.json` |
| Repeated generated-program speed | `runtime-pairs01/report.json` |
| Four-policy code/constructor census | `direct-modes01/report.json` |
| Same-policy, byte-identical output comparison | `generic-matched01/report.json` |
| Unrelated admission/output transfer | `native-transfer01/report.json` |
| Compact frontend stage measurements | `frontend-native-pilot01/report.json` |
| Independent complete helper controls | `workload-controls01/report.json` |
| Compact structural controls | `compact-controls-run03/report.json` |
| Native prototype acquisition and identity | `direct-native-optimized01/report.json` |
| Original command/resource limits | the corresponding `*-guard/process.json` |

The initial snapshot's `*-guard/retention.json` members predate closing. Final
sealed authority is under `retention-final/guards/`; corresponding close,
archive, verification and cleanup receipts are under
`retention-final/closure-and-cleanup/`. The distinction is intentional: original
evidence was not silently overwritten. `phase-summary/` captures the final metric,
cost, source-check interpretation and retention summaries at sealing.

Bulk generated QBE, assembly, objects, hosted APIs and ELF files are outside this
compact Git capsule. Exact local copies remain in explicitly hot research roots
or the verified archives identified by the closure receipts. These local archives
are on the same filesystem; Git publication does not make them an off-host backup.
Restoration must preserve exact paths/identities where a recorded tool checks
them. Rebuilding from source is not guaranteed to reproduce every historical byte.

Prepared source snapshots are evidence only. The maintained production compiler
remains the source selected by the ordinary manifest; Phase163's Bend changes are
the small explicit modules in `selfhost/tests/phase163/`.

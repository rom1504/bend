# Phase164 exact evidence

`capsule.zip` contains frozen prepared Bend source, export/assembly manifests,
complete result receipts, raw timing samples, diagnostics, expected outputs,
guard commands/resource observations and final closure/cleanup authority.
`inventory.json` records every original path, size and SHA256; `seal.json`
authenticates the archive and inventory. Every member was read back and verified.

Useful members:

| Question | Member |
|---|---|
| Original ten IO output/runtime cases | `smoke-machine01/report.json`, `transfer-machine01/report.json` |
| Broader discovery and retained-original controls | `broad02/report.json`, `retained03/report.json` |
| Same-source native acquisition | `hybrid-native03/report.json`, `hybrid-n2-03/report.json` |
| Complete native requests | `native-requests03/report.json`, `n2-requests03/report.json` |
| Exact native self-emission | `n2-self-emission03/report.json` |
| Small imports-only ablation | `imports01/report.json`, `imports-machine01/report.json` |
| Complete zipper tree comparisons | `zipper-controls04/report.json`, `zipper-controls05/report.json` |
| Neutral and fused zipper runtime pairs | `zipper-native01/report.json`, `zipper-fused-native01/report.json` |
| Native alias/malformed controls | `zipper-native-controls01/report.json` |
| Source-check failures | `zipper-api01/`, `zipper-api02/`, `zipper-api03/` diagnostics |
| Exact command and limits | Each corresponding `*-guard/process.json` |

Source snapshots are experimental evidence, not additional maintained compiler
versions. Earlier transport method versions are in `method-snapshots/`, current
ones in `methods/current/`. Final retention metadata is present both beside each
guard and in `retention/`; scientific result/process files were not rewritten.

Bulk QBE, machine assembly/objects, generated hosted APIs and ELF files remain
in local hot roots or authenticated restorable archives recorded by closure
receipts. Their bytes are deliberately outside the compact Git capsule. Four
Phase164 compiler assembly/object files were selectively pruned only after exact
archive verification; binaries, source, logs and receipts remain hot. A restored
historical machine audit needs those exact archived files. Same-filesystem
archives are not independent backups, and rebuilding does not guarantee every
historical executable byte.

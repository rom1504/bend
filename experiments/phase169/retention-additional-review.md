# Additional Phase169 disk headroom

This is a metadata-only proposal. No archive, compiler job, live product hash scan, or deletion was run while the current checker target was active.

`fresh-archive-proposal03.json` selects 18 files in six old, completed native build directories: exactly `program.ssa`, `program.s`, and `program.o` per root. It excludes every ELF, source, API, runtime object, receipt, report and profile record. All Phase152, Phase168 and Phase169 artifacts remain outside scope.

| Completed old build | Allocated MiB |
|---|---:|
| Phase134 / p144-final03-n1 | 218.39 |
| Phase134 / p144-integrated-n1-01 | 218.36 |
| Phase134 / p144-final04-n1 | 218.75 |
| Phase147 / integrated-plan04/image | 222.32 |
| Phase147 / integrated-plan05/image | 223.17 |
| Phase147 / cold-baseline01 | 218.68 |
| **Total** | **1,319.68** |

All are exclusive regular files, with no symlinks or extended attributes. Their original complete build reports contain exact product hashes and sizes. The proposal pins each report and the successful exact-output writer guard. Current-file hashing is deliberately deferred to capture, after the active target finishes.

No selected root was referenced in the maintained build tool sources, current binding manifest, or Phase169 method/recipe files inspected before generating this proposal. Some images were formerly qualified; their executables remain hot, and the current qualified Phase152 products and all old N2 products are untouched. Historical Phase144/147 relinking or profile re-symbolization may need explicit restoration of the archived intermediate. That is the only intended availability change.

Existing run capsules retained these old qualified/full-build roots hot. Fresh selective archives are therefore required: a hash-only receipt is insufficient. `archive-selected-v02.py` caps scratch at 64 MiB per root, retains regular file modes, reopens all members, verifies bytes and gzip completion, rechecks current identities/metadata, then delegates to the maintained `archive-v02.py verify`. It never prunes. Expected retained archives are 150–210 MiB combined, giving approximately **1,110–1,170 MiB net recovery**; actual net recovery must be measured after capture.

Root must review this proposal and wait for an idle target lane. For bounded scratch and rapid recovery, capture and apply one named root at a time:

```sh
python3 -B experiments/phase169/fresh-retention-plan03.py capture --name p144-final03-n1
python3 -B experiments/phase169/fresh-retention-plan03.py apply --name p144-final03-n1
```

Repeat with the other exact names in the proposal. Omitting `--name` runs all six reviewed rows. `apply` first asserts that every verified plan contains exactly the reviewed names/bytes/hashes/allocation, then the maintained tool reauthenticates archives/current files before unlinking. `restore` uses those same retained verified plans. No whole-directory deletion or target-job reserve change is involved. Both new helper scripts passed AST syntax inspection; no capture/apply command has been executed for this proposal.

# Phase173 second bounded storage review

This is a new proposal; the first proposal and its applied receipts remain
unchanged. Only metadata inspection, source/receipt reading and exact-byte hashing
ran. No compiler target, archive, retention mutation or deletion ran.

[storage-proposal02.json](storage-proposal02.json) selects **16 exclusive files
in eight sealed/completed experimental roots, 46.66796875 MiB allocated**. Every
selected file is `program.s` or `program.o`. This scope cannot provide the requested
150–250 MiB headroom: the five old store comparisons contain only 46.359375 MiB;
the three small control roots add 0.30859375 MiB. Net recovery will be smaller than
these raw allocations and must be measured by the root's archive/apply receipts.

| Priority | Phase173 roots | Selected leaves | Allocated MiB |
| --- | --- | --- | ---: |
| Old store comparisons | `store-native-baseline02`, `store-native-candidate02`, `store-native-oracle02`, `store-flat7-native01`, `store-direct-native01` | Each `program.s`, `program.o` | 46.359375 |
| Optional small controls | `scc-owned-baseline01`, `scc-owned-machine01`, `scc-swap-machine01` | Each `program.s`, `program.o` | 0.30859375 |

Each original build report is complete, each writer guard succeeded, and each
retention lifecycle is sealed/completed. The proposal pins those receipts and
closures. Every selected leaf has one link, ordinary file mode, no extended
attributes, stable inode/size/timestamps, and a fresh SHA256 matching its original
build report. Failed partial `store-native-baseline01` is excluded.

All executables, retained/source QBE, sources, runtime objects, API artifacts,
reports, requests, oracle output and unlisted files remain hot. All borrow
artifacts and diagnostic runtime objects remain hot. **ABI03 and SCC store/verifier
assembly/object files remain hot for dispatch comparisons.** No qualified or
installed Phase170/171 artifacts are selected.

The operational scan covered 163 current build/native/profiler/manifest and
Phase173 test-method files, plus 138 bounded Phase173 receipt files. Exact selected
paths occur only as output identities in their own original writer reports.
The maintained Phase173 `native-pair.py` was inspected directly: it authenticates
build receipts, retained/source QBE, runtime, executable and expected output;
it does not read the selected assembly/object files. Those required pair inputs
remain hot. Historical machine-code inspection or relinking would require exact
archive restoration.

## Root-operated application

Use the unchanged `experiments/phase169/archive-selected-v02.py` with this new
proposal and fresh `p173-second-` output directories beneath
`selfhost/build-retention/phase169/`. Its compatibility checks are satisfied by
these successful completed writer roots and exact selected leaves.

Before each root, independently enforce **5 GiB reserve plus the 32 MiB per-root
archive scratch budget**, then recheck the reserve afterward. The frozen helper
internally checks only 4 GiB. Serialize with the execution lane and never run
compiler targets during archival/application.

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal02.json \
  --name p173-store-native-baseline02 \
  --out selfhost/build-retention/phase169/p173-second-store-native-baseline02
```

The helper reopens and hashes every captured member, checks unchanged originals,
and emits `verified/plan.json` without deleting. After inspecting that exact plan
and `capture.json`, root may run maintained `archive-v02.py apply` with a fresh
`applied` output directory. Keep its capsule, plan, journal and measured free-space
receipt. `archive-v02.py restore` using the same verified plan and a fresh receipt
directory recovers the exact archived leaves.

Stop on changed identities, shared links, unexpected dependencies or reserve
failure. Do not expand the scope merely because this narrow tranche cannot meet
the desired headroom.

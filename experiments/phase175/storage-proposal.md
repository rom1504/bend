# Existing-archive capacity for Phase175

[storage-proposal.json](storage-proposal.json) selects **485 exact generated
files in eight retired roots: 261.637 MiB allocated, with no recapture**.
Every selected leaf is an exclusive regular file whose current bytes match its
original complete, reopened-verified archive receipt. Eight narrow policy files
protect every other archived member. No source, API, executable, runtime,
profiling sample, result receipt or selector is selected.

| Root | Generated products selected | Files | MiB |
| --- | --- | ---: | ---: |
| Phase152 `programs45-acquire01` | Old emitted QBE, assembly and objects | 270 | 166.742 |
| Phase152 `n2-all` | Old qualification machine intermediates | 186 | 51.527 |
| Phase152 `compiler-bench01` | Complete emitted QBE stdout copies | 24 | 21.188 |
| Phase165 `lookup04` | Generated `program.c` | 1 | 4.469 |
| Phase165 `map04` | Generated `program.c` | 1 | 4.461 |
| Phase165 `ours-eq01` | Generated `program.c` | 1 | 4.422 |
| Phase165 `original02` | Generated `program.c` | 1 | 4.414 |
| Phase165 `memo01` | Generated `program.c` | 1 | 4.414 |

The original Phase42–65 archive cleanup is exhausted. A bounded inventory of
540 Phase130–173 run capsules found only 339.39 MiB of remaining exclusive
generated candidates across 97 roots before operational review. The eight-root
proposal concentrates most of the useful capacity without a large campaign of
small archives. **An existing-archive-only 1–2 GiB tranche was not found.**

The [reference audit](storage-reference-audit.json) read 5,843 maintained/current
metadata and method files, 419.32 MB, in 3.43 seconds. No selected root appeared
in maintained tooling/manifests/installed metadata or Phase170–175 operational
metadata and methods. Historical Phase152 benchmark/qualification replay and
Phase165 generated-C inspection may require exact restoration first. Their
executables, reports, sources, runtime inputs and measurements remain available.
This is a scoped audit, not a guarantee about arbitrary future dynamic paths.

Preserve the entire Phase174 installed/rollback/N1/N2/Q3/benchmark/profile chain,
Phase170 rollback, Phase171 candidate and 77-control references, Base/toolchain
inputs, active Phase175 work and the shared Phase32 lock. The selection does not
alter any build guard, asset map or compiler source.

## Verification and application

The review hashed current selected bytes and checked original archive identities;
it **did not run a new archive-stream verification or prune**. Each proposal row
contains exact maintained `verify`, `apply` and `restore` commands. Root must run
`verify` before application and require its exact path set, current hash/inode
metadata, file count and allocated bytes to match the row. Preserve refusals and
never broaden the selection to compensate for them.

First root, sufficient to release 166.74 MiB without capture:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py verify \
  --policy experiments/phase175/storage-policy-p152-programs45-acquire01.json \
  --receipt selfhost/build-retention/phase152/programs45-acquire01/root-00/receipt.json \
  --out selfhost/build-retention/phase175/p152-programs45-acquire01/verified
```

After exact-plan review:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase175/p152-programs45-acquire01/verified/plan.json \
  --out selfhost/build-retention/phase175/p152-programs45-acquire01/applied
```

Process roots serially under the maintained shared lock, separately from compiler
targets, and retain the new verification/application journals and existing
capsules. At review, free-space headroom was 113.68 MiB above the 5 GiB reserve;
successful pruning would leave about **375.32 MiB**, before small receipts and
other writers. Remeasure actual free space before admitting a target.

## Optional fresh capture ceiling

A subsequent bounded Phase173 census found **372.32 MiB** across 414 remaining
exclusive `program.ssa`, `program.s`, `program.o` and `plan.jsc.bin` files, even
before excluding profiling/validation inputs. The largest single member is the
89.64 MiB checked-plan binary. Thus a further **1 GiB fresh tranche restricted to
these Phase173 intermediates is impossible**. Capturing some cold members could
recover additional capacity, but it requires a separate exact selection and
archive verification. No speculative fresh-capture proposal or broad deletion
was added to this existing-archive tranche.

# Phase175 combined frontend machine intermediates

Prepared an exact two-file proposal in `storage-own-combined.json`. The successful
`combined-native01` writer and its sealed guard are pinned. Only `program.s` and
`program.o` are selected: **32.633 MiB allocated**, with **28.541 MiB expected net
recovery** based on the actual preceding seven-root compression. This estimate
excludes small new receipt/directory allocation; actual capture determines net.

Both leaves remain exclusive regular files. Original completed build-report
hashes are authoritative; capture must independently hash them. Preparation
read only small receipts and file metadata while the fixed-candidate timing run
was active. It did not capture, prune, hash large products or execute targets.

Keep the combined executable, source, runtime, API, retained IR and every report
available. Future assembly inspection or relinking requires restoring these two
exact products. Other roots and phases are outside the proposal.

The controller may add this proposal's frozen SHA to its explicit allowlist,
then run only after the target lane is idle under the shared execution lock.
Use the maintained capsule and independent archive verifier, preserve the normal
5 GiB floor, 64 MiB archive cap and 128 MiB member cap, and require an exact
path/hash/inode/metadata match before a separate apply. No guard or selector
changes are needed.

The proposal records separate apply and restore commands. After successful
capture/verification/apply, restore at original paths using:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/own-combined-native01/verified/plan.json \
  --out selfhost/build-retention/phase175/own-combined-native01/restored
```

`--out` is a fresh journal, not a new product destination. Reserve capacity for
raw restored files before running it.

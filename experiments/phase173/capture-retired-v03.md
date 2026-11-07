# Reviewed retired-artifact capture adapter

`capture-retired-v03.py` implements capture only for the exact SHA256-pinned
`storage-proposal03.json`. It does not execute compiler targets, delete files,
apply plans, or reopen sealed retention lifecycles. The agent has not run a
capture. Validation includes syntax/static inspection, authentication of the
pinned maintained methods and source/reader relationships, and successful
metadata-only admission of `p173-retired-store-api06` after expanding the active
prefixes: one selected file, 207 protected seed roots, 1,323 traversed dependency
files and 1,329 protected paths.

The adapter authenticates original terminal API/control receipts and sealed
closures, source snapshot completion where relevant, original inode metadata,
file hashes, and the exact approved names. It acquires the existing shared lock,
recomputes the protected Phase173 dependency closure, and adds newly created
bindings and unsealed guarded requests to that closure. Explicit active prefixes
are `dispatch-`, `plan-`, `borrow-`, `consuming-`, `pattern-`, `layout-`,
`store-wide8-`, `erased-`, `owned-decomposition` and `automatic-`. This includes
anticipated owned-decomposition and automatic experiment roots when they appear.
Every direct file in those roots and their transitive Phase173 JSON dependencies
is protected. `abi-*03` and the explicitly selected baseline/source roots also
remain seeded. A plain `binding.json` seeds its root; a source snapshot's
`base-binding.json` alone does not make every historical source snapshot active.
The original protected set remains protected as well. Any selected live
dependency causes refusal.

Each fresh output is limited to 32 MiB, with 5 GiB free space retained. The adapter
calls the maintained `close.py` capsule routine with only the exact selected
leaves. That routine preserves modes, reopens/hashes every archive member and
checks unchanged originals. The adapter repeats live dependency admission after
capture and uses unchanged `archive-v02.py` to verify an exact prune plan. It
compares the resulting full path/size/hash set with the reviewed allowlist.

Source snapshot manifests are approved archive members, preserved byte-exactly.
Their terminal API receipts remain hot. The generic capsule schema records the
archive's original bytes; the adapter's separate intent records source review
and reader/writer evidence. It does not bypass automatic protected-path refusals
or modify the maintained verifier. All unlisted files stay hot.

Root can first run metadata-only admission:

```sh
python3 -B experiments/phase173/capture-retired-v03.py \
  --name p173-retired-store-api06 --check-only
```

Then capture that one reviewed root into a fresh receipt directory:

```sh
python3 -B experiments/phase173/capture-retired-v03.py \
  --name p173-retired-store-api06 \
  --out selfhost/build-retention/phase173/retired-store-api06
```

Inspect `capture.json`, `capsule/receipt.json` and `verified/plan.json`. The output
also records `applyPreflight`, the metadata-only command to repeat immediately
before root separately runs the maintained applicator:

```sh
python3 -B experiments/phase173/capture-retired-v03.py \
  --name p173-retired-store-api06 --check-only
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase173/retired-store-api06/verified/plan.json \
  --out selfhost/build-retention/phase173/retired-store-api06/applied
```

Use `archive-v02.py restore` with that same verified plan and a fresh receipt
directory for exact recovery. A failed capture retains partial evidence and all
source files; it never prunes. Do not treat a partial receipt as a valid plan.

These operations must stay serialized under the coordinating root. The closure
checks known current dependencies and newly recorded bindings; it cannot predict
a future decision to revive a retired API. Root must not start such work between
the immediate preflight and separate apply. Restore first when reviving it.

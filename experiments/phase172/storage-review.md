# Phase172 bounded storage preflight

Metadata and exact-byte hashing only; no compiler, archive, prune, lifecycle
mutation or deletion ran. Current HEAD is `fbdf8a0`. The prior Phase17117-root
tranche is already applied. Its old recovery is not new available space.

The676 retained capsule receipts contain only five still-hot, exclusive generated
leaves larger than20MiB; most belong to protected Phase169/170 final references.
There is no preverified2GiB tranche. Much older QBE and machine bulk is already
hardlinked; removing one path would not release its allocation, and the maintained
pruner correctly declines shared files.

[storage-proposal.json](storage-proposal.json) freezes a narrower fresh-capture
proposal: **16 generated leaves in12 terminal experimental roots,671.6875MiB raw**.
Estimated net recovery is roughly0.55–0.60GiB, but that is not measured. It can
provide a useful bounded lane; it cannot honestly promise1–2GiB.

| Roots | Selected leaves | Raw MiB |
|---|---|---:|
| Phase127 live-bank same-source emission; Phase128 initial emission | Two `program.ssa` files |191.77|
| Phase144 parser original/candidate products | Two `program.s` files |36.26|
| Phase147 plan04/plan05 cold measurements | Assembly/object pairs |213.75|
| Phase163 direct recovery/optimized experiments | Assembly/object pairs |140.48|
| Phase132 compact baseline; Phase136 machine replay; Phase142 edited smoke; Phase144 fixed parent | Four `program.o` files |89.43|

Use the JSON's exact byte totals; table values are rounded. Every selected file
has one link, ordinary permissions, no extended attributes, stable before/after
metadata and a freshly computed SHA256. Each root has a successful terminal
writer and complete report. Newer lifecycle files are sealed/completed, never
qualified. Legacy runs are labeled as terminal legacy evidence rather than
inventing a modern qualification or closure.

All executables, sources, APIs, reports, original QBE except the two specifically
listed old emit-only products, profile-input object copies and every unlisted
file remain hot. Installed Phase170, rollback/current Phase152/168–171 references,
active Phase6/68 work, tools/runtime/Base/bench fixtures and the shared lock are
excluded. A bounded scan of119 current manifest/build/profiler/Phase171–172 method
files found no literal use of a selected path. Historical reproduction may need
an exact restoration; this is not a claim that no historical document references
these artifacts.

## Root-operated capture and review

The unchanged `experiments/phase169/archive-selected-v02.py` accepts the proposal
schema and only the listed `program.ssa`, `program.s`, `program.o` leaves. It
archives, reopens/hashes every member, checks original bytes/modes/stability and
asks maintained `archive-v02.py` to produce a precise prune plan. It never deletes.
Its frozen output scope requires `selfhost/build-retention/phase169/`, even for
this later proposal; use a distinct `p172-` prefix.

**Reserve caveat:** the historical capture method enforces4GiB internally. The
current policy remains5GiB. Root must enforce5GiB plus the32MiB per-root capture
bound before each root and check the reserve afterward, or use a separately
reviewed successor with that enforcement. Do not silently lower the new campaign's
reserve because the old method permits it. Serialize capture/prune with the sole
execution lane; avoid simultaneous compiler work.

Example after root review and reserve preflight:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase172/storage-proposal.json \
  --name p128-source01 \
  --out selfhost/build-retention/phase169/p172-p128-source01
```

Inspect `capture.json` and `verified/plan.json`: selection must be exactly the
proposal's listed files, all their identities must match, and the reserve must
remain intact. Only then let the maintained applicator remove them:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p172-p128-source01/verified/plan.json \
  --out selfhost/build-retention/phase169/p172-p128-source01/applied
```

Exact recovery, with a fresh receipt directory:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase169/p172-p128-source01/verified/plan.json \
  --out selfhost/build-retention/phase169/p172-p128-source01/restored-01
```

Repeat only approved rows, one at a time, and stop when adequate space exists.
Preserve all fresh capsules, evidence, plans and journals; do not overwrite the
original sealed closure. Capture refusal or a changed/shared selected file is a
safe stop, not grounds to relax the tool. Actual recovery comes from apply/free-
space receipts, not this proposal's raw-size sum.

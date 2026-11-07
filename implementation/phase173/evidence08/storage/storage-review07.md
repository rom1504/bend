# N3 assembly/object archival

[storage-proposal07.json](storage-proposal07.json) selects only
`owned-native-n3-08/program.s` and `program.o`, totaling **92.3671875 MiB
allocated**. The successful build and sealed/completed lifecycle are pinned;
fresh hashes and exclusive inode metadata agree with its receipt. No target,
capture or apply ran, and no broad dependency scan was repeated.

N3's QBE digest, assembly and object match N2's completed receipts. N3 compared
its emitted stream with N2's retained SSA and did not retain another SSA file.
**Both distinct N2/N3 executables remain hot**, together with every receipt,
source/runtime asset and N2's `program.ssa` fixed-point oracle.

The unchanged audited `request.image_binding` path needs executable plus receipt,
not the assembly/object outputs. Native qualification and context workloads can
continue using the retained image. Later relinking or assembly inspection can
restore the two archived products exactly.

Current headroom was **60.35 MiB above the 5 GiB reserve**. N2's actually captured
assembly/object bytes are identical, and its archive was **11.50 MiB**. That
predicts **80.87 MiB recovery**, giving **141.22 MiB headroom** after apply. Tar
metadata can vary slightly; remeasure actual free space before admitting the
next job. The full 32 MiB archive cap would leave only 120.71 MiB headroom, so do
not infer a larger job's admission solely from the cap.

Enforce **5 GiB + 32 MiB** before this one-root capture and recheck afterward:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal07.json \
  --name p173-owned-native-n3-08 \
  --out selfhost/build-retention/phase169/p173-owned-native-n3-08
```

Inspect the exact two-file plan, then root may apply it separately:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-owned-native-n3-08/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-owned-native-n3-08/applied
```

The existing helper internally uses a 4 GiB floor, so the external 5 GiB check
remains necessary. Preserve its capsule, plan and journal for maintained `restore`.
No original lifecycle or directory needs to change.

# N2 assembly/object archival before N3

[storage-proposal06.json](storage-proposal06.json) selects only
`owned-native-n2-08/program.s` and `program.o`: **92.3671875 MiB allocated**.
Fresh hashes and exclusive inode metadata match the complete successful build;
the guard and lifecycle are sealed/completed. No capture, apply or target ran.

**Keep `program.ssa` (100,278,749 bytes) as the N3 oracle.** Keep the N2 executable,
image binding/report, source, runtime, requests and all other files. The unchanged
`request.image_binding` consumes the executable and receipt, not their assembly
or object outputs. The recorded image is native stage N2 with `qbe-source-v1`.
A bounded 1,106-file receipt scan found the selected paths only in their writer's
output identities.

Run N3 with N2 as its image and `--expected-qbe` pointing to N2's retained SSA;
omit `--retain-ir` for N3. The maintained native builder compares the complete
emitted byte count/SHA256 even without retaining a duplicate SSA file. N2's
reference remains available for the new-optimizer fixed-point comparison.

At review, headroom above 5 GiB was **93.98 MiB**. Comparable assembly/object
captures predict **11.50 MiB archived**, **80.87 MiB recovered**, and **174.85 MiB
headroom afterward**, enough for the proposed 160 MiB guard. This is an estimate.
Subtracting the entire allowed 32 MiB archive cap would leave only **154.35 MiB**,
so **remeasure actual free space after apply**; cap admission alone does not prove
that the N3 budget fits. Concurrent writers can also change the result.

Use the existing one-root helper, after enforcing **5 GiB + 32 MiB** externally
(the frozen helper itself checks only a 4 GiB floor):

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal06.json \
  --name p173-owned-native-n2-08 \
  --out selfhost/build-retention/phase169/p173-owned-native-n2-08
```

Inspect `capture.json` and `verified/plan.json`, then apply exactly the two leaves:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-owned-native-n2-08/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-owned-native-n2-08/applied
```

Retain the exact capsule and receipts. Restore with the maintained `restore`
command and this verified plan if future N2 relinking needs the archived products.
No lifecycle reopening or directory deletion is required.

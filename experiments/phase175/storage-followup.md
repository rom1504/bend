# Phase175 completed storage follow-up

This note records one completed archive/apply and three completed hardlink operations. The running fixed-baseline build is excluded. Aggregation changed no artifact, ran no target and did not repeat large content reads.

| Completed operation | Net recovered MiB |
|---|---:|
| `combined-native01` assembly/object archive | 28.492 |
| N1/N2 assembly and object | 90.270 |
| N1 retained IR / Q3 exact output | 93.586 |
| Phase174 / Phase175 fixed-candidate assembly and object | 89.668 |
| **Follow-up total** | **302.016** |

The combined archive removed 32.633 MiB of original allocation, retained 4.086 MiB of compressed archive allocation plus its receipts, and completed in 2.166s. Hardlinks reclaimed 273.629 MiB gross; the net values subtract 0.105 MiB of verification, intent, journal and apply receipts. Cumulative recovery with the [previous report](storage-own-native-recovery.md) is **3734.188 MiB**. These are allocation totals, not a claim about currently free space.

All artifact paths remain valid for the hardlinked products. Binaries, sources, runtimes and reports stayed available. Hardlinked products must remain immutable because their inode and timestamps are shared; subsequent builds use fresh roots. The small receipt chains were authenticated, exact approved archive sets compared, and current hardlinked path/inode relationships checked. Original capture/verifier/dedup tools performed the full content checks.

## Rejected first attempt

The coordinating agent reported that `dedup-native-apply01` refused a stale verification before mutation. No corresponding apply receipt, intent or journal exists. Comparing `dedup-native-verify01` and `verify02` independently confirms that only the N2 object’s allocated size changed by **4,096 bytes**, plus the derived potential-recovery total. Content hashes, byte lengths, inode, mtime and ctime were identical. Fresh verification passed and `dedup-native-apply02` completed. The exact metadata gate was retained; it was not weakened to bypass the refusal.

## Evidence and recovery

Exact application, verification, journal, capsule and proposal pins are in [storage-followup.json](storage-followup.json). This includes the successful `dedup-native-apply02`, `dedup-q3-apply01` and `dedup-fixed-candidate-apply01` receipts and both stale/fresh verification snapshots.

The combined assembly/object archive can be restored at its original paths with:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/own-combined-native01/verified/plan.json \
  --out selfhost/build-retention/phase175/own-combined-native01/restored
```

`--out` is a fresh restore journal; reserve raw-file space first. Hardlinked products need no restore to execute or inspect: both paths already contain the original bytes. Independent writable copies would require a separately reviewed split.

Net totals include archive-root directories and dedup receipt files, but exclude shared parent directory blocks and tracked documentation. No prospective fixed-baseline deduplication is counted.

## Later closed baseline

After the above snapshot, the frozen baseline finished successfully.
`selfhost/build/phase175/dedup-fixed-baseline-apply01.json` records exact
assembly/object deduplication against Phase174 fixed-baseline, recovering
94,060,544 allocated bytes before its receipt overhead. Both original artifact
paths remain readable and immutable. This later operation is not included in
the preceding snapshot totals.

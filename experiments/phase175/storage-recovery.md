# Completed Phase175 storage recovery

Emergency recovery completed: **28 roots, 644 exact files**, independently
archived, verified and pruned. It recovered **3,012.09 MiB (2.94 GiB)** after
charging the new archives, verification/application records and directory blocks.
Current compiler, rollback, runtime, source and profiling inputs remained hot.

The [receipt aggregation](storage-recovery.json) pins every completed verifier,
application and recovery report, checks the approved path/hash/inode sets and
counts, and provides an exact restore command for every root.

| Completed tranche | Roots / files | Source allocation | New archive allocation | Net after all new retention storage |
| --- | ---: | ---: | ---: | ---: |
| Earlier existing archives | 8 / 485 | 261.64 MiB | None | **261.11 MiB** |
| Phase140 frames/payloads | 9 / 35 | 2,594.57 MiB | 354.91 MiB | **2,239.17 MiB** |
| Phase102 rendered child logs | 19 / 609 | 810.41 MiB | 36.07 MiB | **772.92 MiB** |

The first row was completed before the external disk drop; it is separate from
the emergency recovery and was not counted again. Across both operations, net
allocation recovered is **3,273.20 MiB**.

The emergency archives contain **390.90 MiB of compressed bytes**, occupying
390.98 MiB of filesystem blocks. Compression reduced Phase140 payloads to 13.68%
and Phase102 logs to 4.45% of their original logical bytes. New metadata and
directory blocks add 1.92 MiB beyond the archives. Total retained emergency
storage is **392.89 MiB**, against 3,404.98 MiB of removed source allocation.

Recorded filesystem free space rose from **2,617.41 to 5,627.93 MiB** during the
emergency campaign: **3,010.52 MiB observed increase**. This differs slightly from
file/block accounting because shared filesystem writers and receipt timing also
affect free space. The ending value is a historical receipt, not a current job
admission promise. Recorded per-root recovery wall time totals **199.73 seconds**,
excluding investigation and time between roots.

The scoped 2 GiB archival-maintenance floor did not alter the normal **5 GiB
compiler reserve**. Compiler work resumed only after recovery. No additional
capture, prune, compiler or benchmark job ran while preparing this aggregation;
it reads the completed receipts and current retained block counts.

## Exact restoration

All 36 per-root commands are in `rows[].restoreCommand` in
[storage-recovery.json](storage-recovery.json). They use the maintained verifier's
pinned plan and restore to the **original paths** by default. `--out` is a fresh
restoration journal, not the destination of the recovered files. Restoration
checks member bytes and mode and refuses changed existing content.

For example, restore only the original `a.frames` member:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/emergency-p140-full-product01/verified/plan.json \
  --member a.frames \
  --out selfhost/build-retention/phase175/emergency-p140-full-product01/restore-a-frames01
```

Restore a complete earlier generated-C selection:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/p165-lookup04/verified/plan.json \
  --out selfhost/build-retention/phase175/p165-lookup04/restore01
```

Reserve space for the restored members before running these commands, serialize
with target activity, and use a new journal path for each invocation. Keep the
archives, original receipts, verified plans and application journals intact.
Historical output comparisons and benchmark reanalysis can restore their exact
raw evidence when needed; aggregate reports and operational compiler assets
remain directly available.

## Subsequent Phase175 machine intermediates

A later, separate [seven-root recovery](storage-own-native-recovery.md) archived only completed Phase175 assembly/object files and recovered another 158.973 MiB net. Its report preserves the distinction from these original 36 plans.

# Phase175 completed native intermediate recovery

The coordinating agent captured, independently verified and applied all seven approved assembly/object plans after the timing pair. This note aggregates those completed receipts; it ran no compiler, archive capture or prune. The frozen proposal remains unchanged.

| Measure | Actual |
|---|---:|
| Completed roots / selected files | 7 / 14 |
| Removed file allocation | 182.215 MiB |
| Compressed archive bytes | 22.843 MiB |
| Archive allocation | 22.859 MiB |
| All retained capsule/journal files and directories | 23.242 MiB |
| **Net recovery, including retained metadata** | **158.973 MiB** |
| Sum of recorded recovery work | 12.842s |

The expected net recovery was 159.537 MiB; actual recovery including new journals/directories was 158.973 MiB. Archive logical bytes were 12.539% of original logical bytes. All work preserved the normal **5 GiB maintenance reserve**; no target guard or selector changed.

| Root | Removed MiB | New archive MiB (allocated) | Net MiB including metadata |
|---|---:|---:|---:|
| `baseline-native01` | 32.543 | 4.074 | 28.414 |
| `field-native01` | 32.852 | 4.117 | 28.680 |
| `publication-native01` | 32.555 | 4.078 | 28.422 |
| `report-native01` | 32.582 | 4.078 | 28.449 |
| `parse-baseline-native01` | 17.207 | 2.168 | 14.984 |
| `parse-precedence-native01` | 17.215 | 2.168 | 14.992 |
| `parse-lookahead-native02` | 17.262 | 2.176 | 15.031 |

## Evidence and preserved inputs

Each completed capsule was reopened and verified by capture, then independently verified before exact-file apply. This aggregation authenticated the small receipt chains, checked the full approved path/hash/metadata sets against each verified plan, confirmed all 14 selected paths absent, and checked that protected executables/runtime/source remained present at recorded lengths. It did not stream-rehash the compressed archives or rerun compiler tests.

Only `program.s` and `program.o` became cold. Every executable, source, runtime, hosted API, retained IR and build/guard report remains hot. The historical frozen benchmark input (`phase170/source-final/compiler.bend`, `434edd1d…`) remains distinct from the proposed full candidate (`a0e953a8…`); neither was selected or changed.

The seven recovery receipts record free space from 5375.781 to 5534.688 MiB: an observed span increase of 158.906 MiB. This differs slightly from exact block accounting because other activity and journal timing affect free-space samples. It is a historical observation, not a capacity promise for the next target.

## Relation to earlier recovery

The [earlier report](storage-recovery.md) covers 36 plans independently. Adding these seven gives **43 plans, 1,143 files and 3432.172 MiB cumulative net recovery**. This sum accounts for new retention allocations within each capsule root; it excludes tracked experiment documentation/shared ancestor directory blocks and does not imply this much disk is currently free. The earlier emergency tranche and its 2 GiB maintenance floor are not conflated with this normal-floor tranche.

## Restore

All seven exact restore commands and authenticated verification/application receipts are in [storage-own-native-recovery.json](storage-own-native-recovery.json). For example:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py restore \
  --plan selfhost/build-retention/phase175/own-intermediates-baseline-native01/verified/plan.json \
  --out selfhost/build-retention/phase175/own-intermediates-baseline-native01/restored
```

This restores the original selected paths. `--out` is a fresh restore journal, not the recovered-product destination. Reserve raw-file capacity before restoration, and choose a fresh journal for a repeated restore. Future relinking or assembly inspection requires restoration; executing the retained programs does not.

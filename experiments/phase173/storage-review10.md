# Final bounded Phase173 generated-bulk tranche

[storage-proposal10.json](storage-proposal10.json) selects **11 exact files in
seven completed native roots**, totaling **102.8984375 MiB allocated**. All are
exclusive regular files with current SHA256/inode/metadata pins, successful
writer receipts and sealed/completed lifecycle records. No executable, source,
runtime, API, report or failed-build file is selected. No target, compression,
capture or apply ran during this review.

| Capture name suffix after `p173-final-` | Selected direct leaves | Allocated MiB |
| --- | --- | ---: |
| `store-native-oracle02` | `program.ssa` | 20.5391 |
| `context-digest-native10` | `program.s`, `program.o` | 15.3359 |
| `context-digest-baseline10` | `program.s`, `program.o` | 15.3203 |
| `borrow-ast-oracle-machine01` | `program.ssa`, `program.s`, `program.o` | 14.8320 |
| `store-native-candidate02` | `program.ssa` | 12.4453 |
| `store-flat7-native01` | `program.ssa` | 12.4414 |
| `store-direct-native01` | `program.ssa` | 11.9844 |

The requested **300 MiB recovery cannot fit this scope**. The bounded Phase173
census found only 385.58 MiB across 254 SSA/assembly/object roots, including
protected current validation products and failed runs. The eight largest
completed roots total only about 116.68 MiB before compression. Reaching 300 MiB
would require many more roots or a separately authorized historical tranche.
This proposal deliberately stops at seven safe native roots.

Actual prior N2 captures compressed SSA to 13.95% and assembly/object to 12.45%
of allocated size. Applying those ratios predicts **13.80 MiB archived** and
**89.10 MiB recovered**. At review-time headroom of 79.01 MiB above the 5 GiB
reserve, this would leave approximately **168.10 MiB**. This is an estimate,
not a full-build admission guarantee. Each root has its own **16 MiB archive
cap**; the caps bound scratch use and do not guarantee positive total recovery.
Measure actual space after every root and before any later target.

The [single reference audit](storage-references10.json) read 1,385 scoped metadata
and method files (112.50 MB) in 0.28 seconds. It covered Phase173 build receipts,
guard/lifecycle/request/binding manifests, maintained native/profiler tools and
selectors, and Phase173 experiment/test methods. It did not recursively traverse
historical dependency graphs. No selected root appeared in the scanned maintained
native selectors, profiler methods or manifests. The exact selected-leaf consumers
are completed native pair/output or static-shape experiments; their reports are
pinned in the proposal and remain hot. The coordinator explicitly confirmed
campaign closure and no further target execution.

Historical pair/shape replay can authenticate these IR files as inputs. Such
replays must **restore the exact archived members first**. Normal execution of
the retained programs does not need their SSA/assembly/object files. Preserve
the binaries and every source/runtime/receipt, all qualified Phase170 chains,
profiling assets, native64 and quality-screen validation products. In particular,
`store-native-baseline02/program.ssa` remains hot because the retained
`wide-store-event-base-run01` diagnostic uses it, and the failed
`context-value-baseline09` is excluded entirely. Prior storage proposals are
historical evidence; this explicit campaign-close selection supersedes the hot
status only of the eleven listed leaves.

For each exact name in the table, root can capture using the existing adapter:

```sh
python3 -B experiments/phase169/archive-selected-v02.py \
  --proposal experiments/phase173/storage-proposal10.json \
  --name p173-final-store-native-oracle02 \
  --out selfhost/build-retention/phase169/p173-final-store-native-oracle02
```

Inspect the exact verified plan, then apply separately:

```sh
python3 -B selfhost/tools/build-retention/archive-v02.py apply \
  --plan selfhost/build-retention/phase169/p173-final-store-native-oracle02/verified/plan.json \
  --out selfhost/build-retention/phase169/p173-final-store-native-oracle02/applied
```

Process roots serially under the maintained shared lock. Enforce **5 GiB + 16 MiB
before each capture**; the frozen helper itself checks only a 4 GiB floor. Use
fresh capture paths and leave sealed closures unchanged. A capped capture failure
retains the source; do not apply incomplete plans, bypass a protection refusal or
enlarge the selection. Keep every capsule, verified plan and journal for maintained
exact restoration. No new archival framework or repeated closure scan is needed.

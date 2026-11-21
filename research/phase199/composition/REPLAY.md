# Reproduce the combined Phase199 x86 compiler

Start in the prepared `build/publish/bend` checkout with the qualified `selfhost/build/phase198/progress-portfolio01` tree, `word-api03`, `quotient-machine-api01`, and the Phase194 assets and Phase186 release QBE N2. `core.py` reads the two checked API sources and their receipts. `tail.py` uses the archived Phase198 public-tail certificate. The complete combined source has SHA-256 `a48b1532ec45ac23cb972796f0101a8bf1864ed8769c6a2daee114ee268ce313`.

The following sequence uses fresh destination names in a replay checkout with the acquisition's original absolute path. The frozen JSON argv contain that absolute workspace for the assets and source. Keep existing acquisition directories in the evidence checkout. Run checker and native stages serially on the guarded CPU 3 lane. The archived runner executes argv arrays in order and stops when a command fails.

```sh
c=research/phase199/composition
p=selfhost/build/phase198
s=research/phase199/scan-lowering

python3 -B "$c/core.py" --out "$p/p199-core02"
python3 -B "$c/replay/run.py" "$c/replay/p199-core-check02-argv.json"

# Prepare and acquire the checked scan API if this prepared checkout lacks it.
python3 -B "$c/replay/run.py" "$s/prepare-argv02.json" "$s/acquire-argv02.json"

python3 -B "$c/integrated.py" \
  --parent "$p/p199-core02" --check "$p/p199-core-check02/report.json" \
  --api selfhost/build/phase199/scan-api01 --out "$p/p199-integrated01"
python3 -B "$c/replay/run.py" \
  "$c/replay/p199-integrated-check01-argv.json" \
  "$c/replay/p199-integrated-native-image01-argv.json"
```

`core.py` replaces four machine-selection hooks and adds 27 declarations. Its output has SHA-256 `3b1c136a2822f3f0824edca400f40b62490be9757af233a4e9694c527961fcf4`. `integrated.py` admits the three checked scan modules into `x185_array_version`, adding 24 declarations and replacing that existing hook. Both assembly steps check exact declaration-body changes and protected declarations. The upstream whole-source checks recorded 6,259 and 6,283 declaration events respectively, both with zero unresolved holes. Kernel checking is a separate stage. The original core source ordering was refused at `X198WOp`; the checked `core02` source puts the type and its prerequisites ahead of use.

The resulting 19,068,032-byte N1 executable is `selfhost/build/phase198/p199-integrated-native-image01/program`, SHA-256 `4c5ef960f02e803826801dcc47f12b1cbed2261708440a02d6707d1739cab0de`. The build took 188.68 seconds under its guard, with peak process-tree RSS of 1,121,226,752 bytes. Its assembler emitted the two `72618344968093696 shortened to 0` diagnostics also present in the progress and core N1 builds. Its `report.json` binds the QBE N2 producer, source, compiler executable and advertised x86 object protocol. The core-only N1 argv are retained for independent fallback reproduction. The [source and build receipts](replay/evidence/) include the failed first ordering, successful core source, combined source, whole-source checks, process guards and retention records. The [ordinary-program procedure](../native-use/README.md) selects a scan runtime, and the [native45 procedure](../broad/INTEGRATED.md) specifies the catalog acquisition.

# Phase181 replay

Use the repository root and fresh paths. The evidence archive preserves exact
source snapshots, API images, receipts, outputs, selected machine inspections
and failed attempts. Its index names excluded bulk machine products; rebuilding
them requires the pinned assets and native reference images. Restore an archive
only in a separate empty directory. No PR comment or installed update is needed.

Assemble the current experimental entry from maintained source, independently
check it, and acquire its QBE-built native seed:

```sh
python3 -B selfhost/tests/phase181/assemble.py \
  --out selfhost/build/phase181/replay-source01
python3 -B selfhost/tests/phase181/job.py replay-check01 45 16 \
  selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs \
  --source selfhost/build/phase181/replay-source01/compiler.bend \
  --out selfhost/build/phase181/replay-check01
python3 -B selfhost/tests/phase181/job.py replay-seed01 180 300 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase175/full-native-n2/program \
  --image-receipt selfhost/build/phase175/full-native-n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source selfhost/build/phase181/replay-source01/compiler.bend \
  --seconds 165 --out selfhost/build/phase181/replay-seed01
```

The seed actually executes the Bend x86 emitter. Build its source through the
new target, then repeat using that first assembly-built image:

```sh
python3 -B selfhost/tests/phase181/job.py replay-x1 210 384 \
  python3 -B selfhost/tests/phase181/native-build.py \
  --image-receipt selfhost/build/phase181/replay-seed01/report.json \
  --binding selfhost/build/phase181/replay-source01/base-binding.json \
  --source selfhost/build/phase181/replay-source01/compiler.bend \
  --seconds 195 --out selfhost/build/phase181/replay-x1
python3 -B selfhost/tests/phase181/job.py replay-x2 360 384 \
  python3 -B selfhost/tests/phase181/native-build.py \
  --image-receipt selfhost/build/phase181/replay-x1/report.json \
  --binding selfhost/build/phase181/replay-source01/base-binding.json \
  --source selfhost/build/phase181/replay-source01/compiler.bend \
  --seconds 345 --out selfhost/build/phase181/replay-x2
python3 -B selfhost/tests/phase181/reproduction.py \
  --first selfhost/build/phase181/replay-x1/report.json \
  --second selfhost/build/phase181/replay-x2/report.json \
  --out selfhost/build/phase181/replay-reproduction01
python3 -B selfhost/tests/phase181/job.py replay-smoke01 150 128 \
  python3 -B selfhost/tests/phase181/native-smoke.py \
  --image-receipt selfhost/build/phase181/replay-x2/report.json \
  --binding selfhost/build/phase181/replay-source01/base-binding.json \
  --out selfhost/build/phase181/replay-smoke01
```

For cheaper iteration, assemble hosted exports with repeated `--export`, acquire
them using the maintained `hosted.mjs acquire`, then use `source-controls.py`.
It reuses authenticated Phase171 semantic preparation and a small current emitter
API. That separation reduces acquisition memory; it does not establish current
native-stage qualification. Exact executed commands are in each guard/receipt.

For the ABI corpus, add both `abi-controls.bend` and `hygiene-controls.bend` with
`--module`, and export `x181_direct`, `p181c_functions`, `p181c_validate`,
`p181h_validate`, `p181h_controls`, `missing`. The checked API feeds `abi.mjs`.
Source checking, actual IR admission, machine execution, native reproduction
and timing remain distinct gates. Keep the existing verifier and literal
oracles unchanged when evaluating a new instruction-selection policy.

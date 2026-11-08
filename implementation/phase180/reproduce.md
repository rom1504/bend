# Replay Phase180

Run at the repository root. Do not overwrite historical paths. The archive
contains exact source snapshots, API exports, receipts, diagnostics, failed
attempts and selected generated bodies. Restore only into a separate empty
directory. Machine products excluded from the archive have pinned identities
and build commands in their receipts; local originals remain retained.

`tests/phase180/snapshot.py FRESH_DIR` freezes maintained Phase178 source and
applies the small Bend deltas. It rejects a different baseline hash. Current
successful experiment is `snapshot06`; do not substitute an earlier failed one.
`prepare.py --parent-source SNAPSHOT` wraps the existing lexical extractor.
It performs no compiler semantics in the host language.

For hosted values, reproduce the exact exports/modules listed in
`base-api-source01/manifest.json`, `compact-api-source06/manifest.json` and their
`exports.json`. Acquire using the shared checked `tools/build/hosted.mjs`, pinned
Bun and `selfhost/.bootstrap/upstream-phase66`. The baseline uses the Phase175
digest; the candidate uses the representation-neutral Phase180 digest. Then run:

```sh
python3 -B selfhost/tests/phase180/job.py NEW_VALUES 90 40 \
  selfhost/.assets/bin/bun selfhost/tests/phase180/application-values.mjs \
  --baseline BASE_API/report.json --candidate CANDIDATE_API/report.json \
  --out selfhost/build/phase180/NEW_VALUES

python3 -B selfhost/tests/phase180/job.py NEW_FRONT_VALUES 120 40 \
  selfhost/.assets/bin/bun selfhost/tests/phase180/frontend-values.mjs \
  --baseline BASE_API/report.json --candidate CANDIDATE_API/report.json \
  --binding BASE_SOURCE/base-binding.json \
  --out selfhost/build/phase180/NEW_FRONT_VALUES
```

Extract each native frontend using `--native-main`, the Phase175
`frontend-plan.bend`, role-appropriate `frontend-digest.bend`, and unchanged
`frontend-native.bend`. Independently accept both sources using the maintained
`check-source.mjs` before building. For each source:

```sh
python3 -B selfhost/tests/phase180/job.py NEW_NATIVE 100 160 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase175/full-native-n2/program \
  --image-receipt selfhost/build/phase175/full-native-n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source NATIVE_SOURCE/compiler.bend --retain-ir --seconds 85 \
  --out selfhost/build/phase180/NEW_NATIVE
```

Run the balanced complete-request gate with the fixed656,302-byte input:

```sh
python3 -B selfhost/tests/phase180/job.py NEW_PAIR 125 20 \
  python3 -B selfhost/tests/phase175/native-frontend.py \
  --baseline BASE_NATIVE/report.json --candidate CANDIDATE_NATIVE/report.json \
  --binding BASE_SOURCE/base-binding.json \
  --source selfhost/build/phase175/baseline-source03/compiler.bend \
  --mode request --rounds 2 --seconds 30 \
  --out selfhost/build/phase180/NEW_PAIR
```

`inspect.py --baseline BASE_NATIVE --candidate CANDIDATE_NATIVE --out FRESH_OUT`
authenticates retained products and extracts six named functions' SSA, assembly
and objdump bodies. It executes neither compiler. Run through `job.py` with a
35s/20MiB budget. Static sites must not be interpreted as dynamic frequencies.

All new target jobs need one outer guard; never nest guards. The Phase180 wrapper
uses CPU3,2GiB aggregate RSS,16GiB available-memory floor and5GiB disk reserve,
then records a retention closure. The frozen receipts contain exact commands
and hashes for this run. No broad qualification is required to reproduce the
negative decision, and this recipe does not authorize image promotion.

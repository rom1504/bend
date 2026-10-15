# Native compiler host

These methods run an explicitly qualified native compiler release. Preparation
of the host code does not select or qualify an image: `selection.json` must be
created from an actual completed admission after the separate compiler gates.
The installed JavaScript release and historical native07 selection stay separate.

After selection, from the repository root:

```sh
python3 -B selfhost/native.py input.bend -o output.c
python3 -B selfhost/native.py input.bend -o output-b1.c --stage b1
python3 -B selfhost/native.py input.bend -o output-live.c --live
python3 -B selfhost/native.py input.bend -o output-repeat.c --calls 5 --seconds 300
```

`--selection PATH` chooses an explicit selection pointer. The pointer names the
immutable qualification manifest and default stage; `--stage` can choose the
other qualified image. B1 is the Bend compiler built by the pinned upstream C
backend. B2 is the same Bend source compiled by native B1. Neither request runs
JavaScript. Python authenticates the selected assets, bounds execution and
transports files; it implements no compiler algorithms.

The entry accepts one Base-importing source and the admitted nine effect files.
Execution uses one CPU worker with GPU off. The default deadline is60seconds;
`--seconds` supports1–600seconds. `--calls 5` repeats the request in one process
and requires all five full C identities to match before publishing the first.
Existing output files are refused. Success/failure receipts and logs stay under
`selfhost/build/native/requests/`. Requests verify selected inputs before and
after execution and publish output atomically.

`launch.load(pointer, stage=None, live=False)` returns `(release,binding)`;
`binding['stage']` is the resolved stage. `launch.native_args(release,source,prefix,
calls=1,live=False,stage='b2')` constructs the exact corresponding argv. A harness
must call `load` before and after a batch and pass the resolved stage explicitly.
Normal loading authenticates only the selected source, image and request assets.
The offline admission collector validates complete provenance and gates once;
the launcher does not replay historical experiments on every request.

The historical native07 command remains available with its original manifest:

```sh
python3 -B selfhost/tools/performance/phase90/runtime-migration01/native.py input.bend -o historical.c
```

No automatic fallback changes the selected stage or historical release after a
failure. Full conformance, GPU behavior, parallel scaling and mathematical
compiler correctness require evidence beyond these native entry gates.

## Package and restore

After actual admission and public CLI validation, a maintainer can seal the
selected request assets without running targets:

```sh
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase98-assets01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets01/receipt.json --verify-only
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets01/receipt.json
```

The capsule contains both qualified images, source, selection/manifest,
Base/carrier/runtime parts/providers and minimal host methods, plus explicitly
listed profile-reproduction assets. Large generated C and historical evidence
remain in the phase capsules. Member paths, complete bytes, modes and hashes are
verified. Restoration requires the recorded checkout root because the prepared
Base carrier includes source-location identities. It only creates missing files,
refuses changed existing files or modes and preserves160MiB disk headroom.

The original archive methods are preserved under Phase90. The new derivation
record is `selfhost/tools/performance/phase98/comparison/public-host-preparation01.json`.
Python syntax parsing during preparation is not a runtime, admission, public CLI
or archive-restoration test. Those actual results must be recorded separately.

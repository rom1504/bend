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
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase98-assets02
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json --verify-only
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase98-assets02/receipt.json
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

## Reproduce the native source profile

The Phase98 profile is a compressed exact edit recipe against D04, preserved in
the committed Phase90 public capsule. It does not require committing the large
assembled compiler or experimental parent sources as text:

```sh
python3 -B selfhost/tools/native/profile.py --profile selfhost/tools/native/profiles/phase98-comparison02/profile.json --out-source /tmp/compiler-native-phase98.bend --receipt /tmp/compiler-native-phase98-replay.json
```

This data-only command checks the baseline capsule and member, applies all exact
edits, checks the final source hash and reverses the edits to the original bytes.
Existing outputs are refused. The resulting source is the explicit native build
profile; it does not update canonical Bend modules or the JavaScript release.
Source replay is separate from source proof, checked acquisition and native gates.
The default replay profile is comparison02, exact source `2a72bbdc…e051`, which
adds lazy observer-ancestry refusal to the permission/held-equality/tag profile.
Comparison01 remains explicitly available as historical `59b36a1c…2714`; its
eager ancestry recursion can diverge and it is not the release candidate.

`cli-controls.py SELECTION COMPLETED_CONTROLS OUT` is the maintainer's serial
public-interface gate after actual admission. It checks both stage argv policies,
cached/live/repeated full products, exact invalid-source rejection, unchanged
assets and refusals before publication. The final preparation and command order
are recorded in `../performance/phase98/comparison/promotion-plan.md`.

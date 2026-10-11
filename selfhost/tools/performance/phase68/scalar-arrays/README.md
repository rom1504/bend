# P68-016 scalar array discriminator

Prospective registration: [P68-016](../../../../../experiments/phase68/P68-016-scalar-arrays.md).
Source findings: [array audit](../../../../../research/phase68/array-after-products15.md).
No targets ran in the preparation lane.

`derive-v1.py` admits only exact checked products15 array C
`19087b31006dd02e8fb51fd38e3b6df29b19885abb55700eaef06b0f3caf3826`.
It produces packed-U32, direct-unshared-location and combined interventions.
Each literal edit is confined to a selected host worker. The original runtime,
compiler images and scheduler fallback remain unchanged; this diagnostic does
not establish public/raw API equivalence.

`prepare-v1.py` uses frozen saved-native-v2 admission to verify the selected
checked API, snapshot manifest, runtime/toolchain recipe, original acquisition
and emitted C. It recreates the intervention C inside a fresh Phase68 build
directory and freezes the independent oracle, source pins and three rotated
rounds of four arms at common plan03 counts. It executes no compiler or target.

The root-only `run-v1.py` verifies all inputs, replays the literal edits,
builds three binaries, checks16 smoke observations, and measures12 intervals
under one serial CPU3 resource guard. Every timed interval must reach100ms
for timing qualification. All arms have the same61440 repetitions and7680
warmups. Three rotations are the requested screen, not complete four-position
balance. Its stdout/output checks and retained child receipts use the existing
saved-native protocol.

Frozen execution plan:
`selfhost/build/phase68/scalar-array-diagnostic01/plan.json`,
SHA`0a6bb48e3133f5403a24b2e7a10f1e51c51a0f8ff0d9a14262911634f65b2292`.
Root execution command from the repository root:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase68/scalar-arrays/run-v1.py \
  --plan selfhost/build/phase68/scalar-array-diagnostic01/plan.json
```

Initial source-only copies under `diagnostic-v1` are preserved but their large
C files are ignored by Git. Small derivations, manifests and literal patches
are retained. Recreate them in a fresh destination with `derive-v1.py` and the
pinned products15 C; never overwrite the existing attempt. The actual timing
plan uses its own copies under `selfhost/build/phase68`.

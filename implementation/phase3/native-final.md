# Final native compiler workflow

The final frozen Phase 3 compiler modules passed full checking and ownership,
compiled with Clang 16 at `-O1`, and emitted the complete compiler's JavaScript
library successfully. The native output is **1,131,553 bytes**, SHA-256
`360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de`,
exactly equal to `build/phase3/final-fixedpoint/stage2.mjs`.
This closes this selected native execution workflow gate; it does not establish
whole-language conformance or a native executable fixed point.

[Archived evidence](evidence/native-final.json) retains the original preparation,
checked-emission, C-cache, worker-exposure, validation and full-source reports,
their exact hashes, command/environment ledgers, selected fixture sources, and
attempt-local supervision source snapshots. Raw binaries and logs remain under
`selfhost/build/phase3/native-final/`.

## Inputs and results

All 59 compiler modules match the frozen native-integrated source and current
production bytes. The native entry adds the two existing graph/bundle IO modules.
Pinned upstream revision `6018e28ecc67cf1fffc0c20c64b11023474c2df8` checks and
emits that source before Clang runs. The target compiler source is
`936266643e95973709bac4b567289c5792decadbb3297f90018ed5052582d772`;
the graph compiler including its IO entry has a different, recorded source hash.
The target uses the same canonical pinned Base path and runtime bytes as the
completed [final fixed-point proof](evidence/final-fixedpoint.json), rather than a copied Base module identity.

| Observation | Time |
| --- | ---: |
| Complete checking and JS/C emission, outer process | 40.655 s |
| Initial Clang/cache command, outer process | 71.932 s |
| C compilation within that command | 68.463 s |
| Reused native build, including preprocessing, outer process | 1.846 s |
| Native full compiler-source pipeline and output consumption | 287.315 s |
| Same operation including wrapper publication/provenance | 287.457 s |
| Same operation, outer Node process | 287.540 s |

These are single observations pinned to CPU 0 on a shared host, with other work
on other CPUs. They are not an isolated speedup comparison. Native compilation
includes source IO and all required compiler gates; writing output follows the
inner timer. Node children used a 4 MiB stack and 4 GiB old-space setting. Those
Node flags do not bound the native executable's heap.

The content-addressed cache hit reused an identical binary, SHA-256
`0d493da1c51e0440282478809047594dec0f43e7c69b68e5ad2e074136fc6368`.
The cache identifies C bytes, preprocessing, compiler executable/version and
build tools; it assumes stable host linker/libraries. Checking and emission are
separate required artifacts, never inferred from a successful C build.

The same checked Bend implementation passed **11/11 selected native/JS cases**:
seven positive import, Unicode, library and foreign-asset cases had exact emitted
bytes and matching execution; four negative cases matched the expected rejection
phase/checking state. This compares native execution with unchanged generated JS
workers, not the handwritten TypeScript compiler. A separate production-validator
smoke passed with the real cache-hit binary.

## Tool compatibility and reproduction

The production [graph workflow](../../selfhost/tools/performance/rapid/native-graph.md)
now uses the C cache directly. Both graph validation and measurement accept the
version-2 cache report and retain support for legacy C-only reports. Their shared
identity verifier checks actual source/JS/C/binary bytes, the exposed worker
chain, the cache record key, and consistent report/record metadata. Both tools
include the verifier in their consumed-tool hashes.

Cache-hit reports have no original C compilation duration. Measurement therefore
records `cCompileMs: null` and `phaseWorkMs: null`, while retaining observed
preprocessing separately. Cache-miss phase sums exclude compiler discovery,
post-build revalidation and publication; they are not process wall time.

Run the bounded regression tests from the repository root:

```sh
node --test --test-isolation=none selfhost/tests/native-build-evidence.test.mjs
```

All **21 tests passed**, including changed C/binary bytes, incomplete builds,
wrong cache keys, changed identity records, mismatched exposure and timing scope.
The shared verifier also accepted both actual final-build reports. The updated
production validator passed `nested-parent` end to end with the cached binary.

The recorded 11-case matrix and full-source attempt used frozen local copies of
the graph launcher/validator with asynchronous file capture for bounded process
supervision. Their exact sources and adaptations are archived; they are not
silently represented as the subsequently updated production tools. The production
change is limited to report compatibility and timing attribution. The native
compiler pipeline and compiler source did not change during this integration.

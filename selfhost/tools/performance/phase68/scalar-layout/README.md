# Checked scalar-array fast loop

Use an actual checked attempt and freeze a fresh Phase67-method recipe into
`selfhost/build/phase68/`. Historical raw paths are immutable. The benchmark
compiler is still implemented in Bend; `nc_compile_checked` owns admission.

1. Build once with `development/workflow.mjs run` using the Phase68 bounded
   CPU3/jobs1 configuration. For this result the attempt is `scalar-build20`.
2. Freeze/acquire using `phase67/benchmark/freeze.py` and `run.py acquire` with
   the exact candidate API. Emission, Clang and independent runtime oracles
   must all pass. `--cases array --roles selfhost` is the narrow first screen.
3. Reuse the acquired binaries with `run.py measure` for the seconds-scale
   iteration loop. Use qualified intervals of at least100ms, independent
   checksums and balanced repeated runs; do not time a compiler rebuild each time.
4. For integration, `compare-native.py --candidate ACQUISITION_DIR... --out
   FRESH_DIR` reruns installed, candidate and pinned upstream saved binaries
   in three balanced rotations. It verifies recipes, sources, C and binary
   receipts. This six-family comparison costs about a minute because the old
   installed array executable is slow; reserve it for a selected candidate.
5. Run `selection-v1.json` (14 paired native fixtures),
   `selection-roundtrip.json` (Char/F32), `admission-controls.mjs FRESH_DIR`, and
   the existing 37-case integration/raw/one-four-thread gates under one guard.
   Admission controls require explicit `BEND_TYPED_API`, `BEND_BASE` and
   `BEND_UPSTREAM` pointing to the candidate and pinned reference.
6. Generate a genuine B2 once, then use the frozen selected B1/B2 C-request
   method in `../compilation/`. These clocks measure compilation, not program
   execution. `verify-js-routes.py --baseline ATTEMPT --candidate ATTEMPT --out
   FRESH_DIR` proves exact JS/frontend generated dependencies and host routes;
   its scanner derivative explicitly admits just the new native export.

`diagnose-user-seals.py` retains P68-018's saved-C diagnostic (mixed outcome,
not selected). It has a fixed fresh raw destination; do not rerun into an existing
path. Its failed predecessor is retained in `user-seal-diagnostic01`.
`inspect-annotations.mjs` observes the actual driver-adapted typed compiler API.

One CPU3 target tree at a time, RSS2GiB/available-memory floor4GiB,
Node heap1GiB/stack4MiB. No outer guard around controllers that own a guard.
Source-only preparation and analysis run on CPU0. See the
[report](../../../../../implementation/phase68/checked-scalar-arrays.md) for
measured scope, identities and remaining gaps.

For the new checked native entry, `profile-checked-entry.py --plan PLAN --out
FRESH_DIR` derives the old request worker with only its observed/required native
stage changed. It reuses the exact prepared cache and plan, runs the four profile
jobs only, and retains a literal derivation receipt. `summarize-compilation.py
--plan PLAN --profiles PROFILE_DIR --out NEW_JSON` joins those with all27 completed
clean measurements without relabeling the old failed profiling plan complete.

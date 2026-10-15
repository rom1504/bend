# Noindent qualification with regular-file preprocessing input

This fresh derivative preserves the exact source, producer and eight native
controls from `../noindent-methods01/`. The only admission change is the pinned
`whitespace-check-v3.mjs` method: each Clang preprocessing child receives a
new read-only regular-file descriptor at offset zero. The failed v2 pipe-input
attempt remains an input and must still record its empty-output timeout.

Actual `selfhost/build/phase90/whitespace02/report.json` passed all four CPU
preprocessed-output comparisons. Offline admission of that completed report
passed with 701 bound inputs; see
`implementation/phase90/noindent-v3-admission.json`. This did not execute a
compiler or qualify any native binary.

After an actual successful guarded C build:

```sh
python3 -B selfhost/tools/performance/phase90/noindent-methods02/bind-own-native.py \
  EMISSION_REPORT CLANG_GUARD_DIRECTORY IMAGE
python3 -B selfhost/tools/performance/phase90/noindent-methods02/own-native-gates.py \
  IMAGE FRESH_OUTPUT --oracles selfhost/build/phase90/whitespace02/report.json
```

`--check-only` validates bindings without targets. Optional `--self-source`
follows all eight live/cache controls. Every new raw C result must match its
qualified new oracle exactly; CPU preprocessing does not qualify GPU branches,
arbitrary raw segment bodies, native self-hosting, or performance.

`derivation.json` records exact reversible edits. Previous methods and evidence
are unchanged. The build binder preserves actual compiler flags and requires a
successful guard; it does not require an optimization level.

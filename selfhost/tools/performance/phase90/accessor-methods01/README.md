# Function-table accessor: diagnostic image qualification

These fresh derivatives reuse `../noindent-methods02/`. They admit only the
frozen two-edit host-C table lookup experiment recorded in
`selfhost/build/phase90/table-accessor01/derivation.json`.

The original checked Bend emission remains `c=81ca2837…` (38,614,586 bytes).
The actual compiler-build input is separate: `compiledC=a4cd3990…`
(38,614,663 bytes). Admission verifies the exact receipt, recipe and both files,
replays both unique edits, and reverses them to the original bytes. The Bend
source is still `d04ad79c…`; runtime assets used for compiling user programs
remain unchanged. Image, gate and self-emission reports explicitly identify
this C-patched diagnostic. No native-B2 or public/cache admission is granted.

Root, after a successful actual guarded Clang build:

```sh
python3 -B selfhost/tools/performance/phase90/accessor-methods01/bind-own-native.py \
  selfhost/build/phase90/js-self11/report.json BUILD_GUARD IMAGE
python3 -B selfhost/tools/performance/phase90/accessor-methods01/own-native-gates.py \
  IMAGE FRESH_GATES_DIRECTORY --oracles selfhost/build/phase90/whitespace02/report.json
python3 -B selfhost/tools/performance/phase90/accessor-methods01/emit-qualified.py \
  IMAGE FRESH_GATES_DIRECTORY/gates.json FRESH_SELF_DIRECTORY --seconds 240
```

The eight real live/cache checks remain exact full-C comparisons to the four
CPU-qualified new oracles. The last command reuses completed gates and compares
self-emitted C to original `81ca2837…`, **not** the patched `a4cd3990…` compiler
build input. It preserves the same guards and every failure. Both gate/emitter
commands accept `--check-only`; that option executes no compiler targets.

Offline source/oracle preflight passed: exact forward/inverse C replay, checked
parent and all four CPU oracles, 732 unchanged input bindings. Evidence:
`implementation/phase90/accessor-binding-preflight.json`. No native build,
binary admission or actual target was performed by this preparation lane.
`derivation.json` records reversible method edits; all earlier methods remain
unchanged.

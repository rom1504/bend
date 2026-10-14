# Exact Phase90 native-image comparison

These are fresh derivatives of Phase89 `broad-exact-v2.py` and
`measure-qualified.py`. Historical files, Phase88 C digests and public native
image/cache admission remain unchanged. The candidate is the upstream-built B1
for frozen source `74b390d3…`; the paired baseline is the separately admitted
Phase89 native B1. This is not a native B2 comparison.

Both tools require immutable `native-gates01/gates.json`, not the report that
continues changing during self-emission. They authenticate the exact candidate
image, checked source/C/build chain, ten source replacements and their inverse,
ancestor nine-effect proof, all nine unchanged effect providers, the trusted Base
carrier, and the actual eight live/cache guard commands/processes/C outputs.
The candidate receives that carrier only inside this private experiment.

Actual-input offline preflights completed on Python3.9:

* `selfhost/build/phase90/broad-preflight01/preflight.json`: all45 points and45
  distinct sources admitted; zero target jobs.
* `selfhost/build/phase90/pair-preflight01/preflight.json`: all six sources and both
  image roles admitted; zero target jobs.

These establish executable method/input compatibility, not candidate broad C
equality or speed. The exact method changes are replayable from
`native-comparison.derivation.json` using `replay-native-methods.py`; replay writes
fresh copies and does not execute them.

Start with the small/Map pair:

```sh
python3 -B selfhost/tools/performance/phase90/measure-qualified.py \
  selfhost/build/phase90/compiler-native01 \
  selfhost/build/phase90/pair-small-map01 \
  --gates selfhost/build/phase90/native-gates01/gates.json \
  --cases small,map_closed --calls 1 --rounds 2
```

Then, if useful, run all six cases in two rotated rounds:

```sh
python3 -B selfhost/tools/performance/phase90/measure-qualified.py \
  selfhost/build/phase90/compiler-native01 \
  selfhost/build/phase90/paired-cold01 \
  --gates selfhost/build/phase90/native-gates01/gates.json \
  --calls 1 --rounds 2
python3 -B selfhost/tools/performance/phase90/measure-qualified.py \
  selfhost/build/phase90/compiler-native01 \
  selfhost/build/phase90/paired-five01 \
  --gates selfhost/build/phase90/native-gates01/gates.json \
  --calls 5 --rounds 2
```

The six sources are small, Numeric, Lexer, Map, Functions65 and Unicode. Each
process uses one thread on CPU3 and the same prepared-Base boundary. Five-call
mode preserves every request clock and requires all five C outputs to match the
retained ordinary B2 oracle. Report the first and fifth request separately;
process wall time includes startup, preparation and the complete call sequence.
Do not add process/preparation/request clocks or describe a fifth request as a
fresh invocation. No TypeScript runs are added.

The broad gate emits all45 independent retained catalog sources once each:

```sh
python3 -B selfhost/tools/performance/phase90/broad-exact.py \
  selfhost/build/phase90/compiler-native01 \
  selfhost/build/phase90/broad-exact01 \
  --gates selfhost/build/phase90/native-gates01/gates.json
```

It checks full C SHA256 and byte length against the already executed Phase88
oracles, retaining all45 point mappings and process/resource receipts. Exact C
reuses those prior functional execution results; it is not a fresh generated-code
speed measurement. There is no Clang/program execution in this gate.

Both methods stop at the first failed process or C mismatch, retain failed
evidence and verify all frozen inputs after the run. The paired method also
requires one request clock per emitted output. Each target has a
90-second default guard,2GiB RSS limit,4GiB available-memory floor and64MiB file
limit. Use fresh output directories; append `--check-only` for offline admission.
Root runs targets serially. No target was launched while preparing these methods.

# Native session comparison

`native-run-v04.py` is a host supervisor, not a compiler or optimization cache.
Its `--prepare` arm creates a frozen input manifest and two tiny refusal fixtures.
The `--run` arm requires the completed experimental native image and runs only
the commands recorded by this procedure, under the coordinator's resource guard.

The frozen execution plan is
`selfhost/build/phase134/session-native-plan04/plan.json`. It binds timed
`session-source04`, its checked API, 109 finite controls and raw-plan bridge.
The image is built through the supervised compiler→QBE pipe. The supervisor
checks the complete receipt, source, qualified producer, runtime, successful
compiler/QBE and assembly/link results, bounded transport and binary identity.
There is no requirement to materialize a whole compiler QBE file.

```sh
python3 selfhost/tools/performance/phase134/session/native-run-v04.py \
  --prepare \
  --plan selfhost/build/phase134/session-native-plan04/plan.json \
  --acquisition selfhost/build/phase134/session-native-pipe01/report.json \
  --build selfhost/build/phase134/session-native-finish01/report.json \
  --out selfhost/build/phase134/session-native-measured04

# Run only after the coordinator confirms the native lane is available.
python3 selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase134/session-native-guard01 \
  --seconds 120 --rss-mib 3072 --available-mib 16384 --cpu 3 -- \
  python3 selfhost/tools/performance/phase134/session/native-run-v04.py \
  --run --plan selfhost/build/phase134/session-native-plan04/plan.json
```

The real edits are the existing Lexer shift-amount edit and Map multiplier edit.
Each edit changes checked source and the complete emitted QBE. Native B uses its
actual distinct file path; it does not reuse the hosted experiment's original
semantic path. Therefore the qualified core N2 independently compiles all four
actual source paths through its ordinary, uncached entry. Every session file
must match those fresh oracles exactly, without whitespace normalization. A's
oracle also has to match the prior independently qualified frozen output.

Five native refusals cover a relative output, duplicate output, output/input
collision, invalid A and invalid B. The input-collision probe uses a fresh
sacrificial source copy and verifies that it remains unchanged. Invalid B must
leave complete, independently correct output A and must not create output B.
The supervisor itself requires fresh, real, distinct output parents and rejects
aliases; the Bend guard checks literal paths, not filesystem identity.

For each family, two pairs alternate warm/cold order. The second round also
reverses family order. Each session starts a fresh process. Both modes prepare
Base once and compile A before B; only retention of A's returned typed cache
differs. A and cold B must report zero prior hits. Warm B's reuse counts are
recorded; a valid zero-hit result falsifies the reuse hypothesis rather than
failing semantic correctness. Every output must match the independent oracle.
The supervisor records complete
child wall time, user/system CPU and peak RSS with `wait4`, plus the source's
preparation/A/B millisecond intervals where available. Millisecond resolution
and two pairs warrant modest conclusions, not a precise universal speed claim.

Acquisition and native build costs remain separate. Warm versus cold reset
isolates reuse of already acquired state; both modes still pay cache construction
for A, and cold B builds new cache state. This is not by itself a measurement of
cache construction overhead against a one-process uncached compiler. Likewise,
a speedup on these two edits is not full-compiler incremental compilation,
persistent caching, bootstrap qualification or recursive acceleration.

The host-only checks exercise the timing-output parser with both v03
and v04 formats and reject mixed timing records. They execute no Bend targets.
The native receipt is authoritative for whether the experiment actually passed.
V01 and plan01 are retained, unexecuted preparation history. V02 additionally
checks the raw bridge's source/API binding and accepts the old v03 stat printer's
trailing separator. No-cache adoption overhead remains deliberately unmeasured;
the campaign does not include another baseline or full bootstrap acquisition.

V03 preserves the initial pipe wrapper refusal and requires the separate reviewed
machine-finish receipt. The compiler and QBE succeeded; assembler exit zero
produced the same split-immediate warning pattern as the qualified core. The
review checks every low/high word store, and finishing reassembles the preserved
assembly to an exactly identical object before linking. The original receipt
remains incomplete. Relative-path refusal executes in a fresh scratch directory
so even a broken guard cannot overwrite an existing repository output.

V04 fixes a host fixture mistake: the tiny ordinary reference must import Base.
It reuses the exact source-checked raw-bridge revision-A fixture; invalid input
also imports Base before its intentional syntax error. Run03 is retained: its
four real-program oracles passed, then the tiny oracle correctly refused the
missing import. No compiler source or native image changed for this correction.

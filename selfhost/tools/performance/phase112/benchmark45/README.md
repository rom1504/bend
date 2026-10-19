# Phase112 original45 compiled-program runtime follow-up

This freezes the exact existing Phase93 batch wrappers, workload arguments and
complete-output oracles for all 45 historical input points. Every upstream
binary and its C source matches the original acquisition receipt. These are
compiled-program runtime measurements, separate from Phase111's 45 one-shot
conformance checks and from compiler request/build time.

`manifest01.json` preserves the corpus order and records the 39 points outside
the initial Phase112 six-case runtime screen. These are held out only from that
screen; earlier projects and conformance runs already saw the programs. The
historical `scalar-region-0` control has an undefined runtime ratio. It still
receives complete-output/count checks in all three rounds. Aggregates therefore
cover 44 fixed input points, or 38 in the 39-case held-out partition. The 45
points span 23 historical families; this is equal-point weighting, not 44
independent source programs or equal-family weighting.

The new `upstream-50ms-profile01.json` chooses each measurable count solely from
the three prior Phase93 upstream times:
`max(1, ceil(old_repetitions * 50 / median_upstream_ms))`, with four warmups.
No Phase112 product timing influences those counts. The exact same counts and
arguments apply to all current roles. The profile has a 20-ms qualification
floor and three alternating rounds. The zero-work control uses one repetition
and four warmups, permits a zero clock, and contributes no ratio. This new
profile must not be merged with the old counts or the initial six-case profile.

Prior upstream timing predicts 2.21 seconds per round for all 44 measurable
points. At a hypothetical uniform 14.2x candidate/upstream ratio, three matched
rounds would take about 101 seconds of program time, or 87 seconds for the 38
held-out measurable points. These are planning estimates; unseen ratio tails,
process startup and acquisition can increase them. Native acquisition should
be budgeted separately, initially 480 seconds plus a 180-second runtime guard.
Root owns all target execution under the serial CPU3 process-tree guard.

Acquire using the actual final native image and runtime object. The producer
receipt must be a completed build/qualification receipt containing the exact
image pin. Replace uppercase placeholders with concrete absolute paths before
running. Product directories must remain below Phase111 because the unchanged
native emitter enforces that boundary.

```sh
python3 -B selfhost/tools/performance/phase112/benchmark45/acquire-native.py \
  --image ABS_IMAGE --runtime ABS_RUNTIME_O --producer-receipt ABS_IMAGE_RECEIPT \
  --prefix selfhost/build/phase111/p112-broad-native01 \
  --out selfhost/build/phase112/broad-native01 --budget-seconds 480

python3 -B selfhost/tools/performance/phase112/benchmark45/run.py bind \
  --label finalcandidate \
  --reports selfhost/build/phase112/broad-native01/products-map.json \
  --out selfhost/build/phase112/broad-binding01.json

python3 -B selfhost/tools/performance/phase112/benchmark45/run.py measure \
  --bindings selfhost/build/phase112/broad-binding01.json \
  --profile selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json \
  --out selfhost/build/phase112/broad-runtime01 --budget-seconds 180
```

For a 39-case follow-up, add
`--names-file selfhost/tools/performance/phase112/benchmark45/heldout39.txt` to
all three commands and use fresh paths. A full45 measurement additionally
reports the named Phase112 held-out 38-point aggregate. It does not pretend the
six previously screened points are held out.

The native supervisor calls unchanged `phase111/native-emit.py` with explicit
image/runtime and its standard QBE build. It records actual native receipt
paths, complete build receipts and binary hashes. Binding independently checks
the same source/Base/carrier, QBE/as/link flags and outputs. Timed products use
`PROGRAM --threads 1 --gpu off -- REPS WARMUPS ARG0 ARG1`. The clock remains
Phase93 `IO.now` milliseconds, including each workload, full-result comparison,
loop and final success-count print. Compiler/build clocks and process startup
are excluded. Raw stdout, stderr, exits, binary hashes and process wall time
remain in every observation.

`requestedCorpusNames` includes the zero-work control, while `ratioCaseNames`
and `coverage` describe measurable points. `fullCorpusOutputQualified` requires
every requested role/corpus output in every round; `fullMeasuredCorpus` requires
all 44 measurable points. A failure preserves observations, suppresses incomplete
aggregates, and never changes membership/counts automatically. The runner is a
standalone copy of the frozen six-case method with corpus labels, held-out
accounting, names-file input and explicit zero-work handling adapted. The active
six-case runner and manifest were not changed. Source-only preparation and
synthetic accounting/parser checks ran; no target was launched by the author.

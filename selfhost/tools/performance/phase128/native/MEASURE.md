# Native measurement reuse

All commands that execute targets belong to the root's serial CPU3 guard lane.
`qualify.py`, `timing-plan.py` and `aggregate.py` only inspect artifacts or write
plans. They never execute compilers or generated programs.

## Early N1 throughput

After checked acquisition admission, actual hosted emission, an aligned N1
build and the original focused19 suite, prepare a research-only timing block:

```sh
python3 selfhost/tools/performance/phase128/native/timing-plan.py \
  --research-admission selfhost/build/phase128/native-admission01.json \
  --hosted HOSTED_EMISSION/report.json --n1-build N1_BUILD/report.json \
  --n1-focused N1_FOCUSED/report.json \
  --out selfhost/build/phase128/research-timing01 --tag p128-research01
```

The generated `jobs.json` uses unchanged Phase125 `timing-run.py`, through the
existing guard and Phase113 `run-jobs.py`. It is explicitly
`unqualified=true,researchOnly=true`; N1 self-reproduction is not required.
The historical repair image contains **Phase126 source32**, compiled by the
Phase127 repaired emitter. It is not an image of Phase127 source or a same-source
N1/N2 comparison. Both freshly emitted products link the same additive Phase128
runtime; the historical compiler retains its original linked runtime.

Request time and request plus machine-build time remain separate. Native uses
prepared Base/cached runtime; upstream loads source Base and builds its C/runtime
output. Generated-program execution here checks correctness, not runtime speed.

## Full qualification and N1/N2 timing

```sh
python3 selfhost/tools/performance/phase128/native/qualify.py \
  --admission selfhost/build/phase128/native-admission01.json \
  --hosted HOSTED_EMISSION/report.json --n1-build N1_BUILD/report.json \
  --self-emission N1_SELF_EMISSION/report.json --n2-build N2_BUILD/report.json \
  --n1-focused N1_FOCUSED/report.json --n2-focused N2_FOCUSED/report.json \
  --n2-full45 N2_FULL45/report.json \
  --out selfhost/build/phase128/native-qualification01.json

python3 selfhost/tools/performance/phase128/native/timing-plan.py \
  --qualification selfhost/build/phase128/native-qualification01.json \
  --out selfhost/build/phase128/qualified-timing01 --tag p128-qualified01
```

Qualification binds actual receipts directly, without relabeling an older
plan. It verifies raw hosted/N1-self QBE equality, separate N1/N2 builds, exact
tool/runtime/alignment identity and focused19/focused19/full45 semantics. It
makes no ELF equality or N2→N3 claim. Timing emits two separate blocks:
N1/N2/upstream and repaired historical image/N1/upstream. Compare within each
block and disclose drift between blocks.

## Historical generated-program runtime

Ordinary `full45.py` products are one-shot correctness programs. The historical
44-point runtime metric instead uses frozen Phase93 in-process repetition
wrappers plus one zero-work control. One-shot process times cannot substitute
for that metric, and passing repetition arguments does not change their source.

Prepare native emission-only jobs for the exact historical wrappers:

```sh
python3 selfhost/tools/performance/phase128/native/aggregate.py prepare \
  --image NATIVE_IMAGE/program --producer-receipt PRODUCER_RECEIPT.json \
  --runtime selfhost/build/phase128/runtime-borrow01/runtime.o \
  --prefix selfhost/build/phase111/p128-batch01 \
  --out selfhost/build/phase128/native-wrappers01
```

The producer may be the actual N1 build receipt for early research, or full
qualification; it must bind the image and runtime. Root executes the resulting
`jobs.json` through guard/run-jobs. `report.json` remains incomplete until every
requested emission is authenticated. `--names` selects a bounded subset.
`--reuse-map` accepts a JSON map of names to existing receipts only for identical
image, source, Base/cache and emitter. No hosted reacquisition is needed.

Build and measure the resulting native QBE once, under the root guard:

```sh
python3 selfhost/tools/performance/phase128/native/screen.py \
  --emission selfhost/build/phase128/native-wrappers01/report.json \
  --baseline selfhost/build/phase126/final32-screen/report.json \
  --out selfhost/build/phase128/native-runtime01 --label native-runtime01 \
  --rounds 3 --scale 4
```

The explicit baseline is the complete selected Phase126 source32 original45
report. `screen-derivation.json` records every change from the Phase126 screen
and verifies the exact inverse. The original independent output/count/elapsed
oracle, count profile, aligned builder and execution arguments stay unchanged.
The existing `phase126/summarize.py` accepts this screen. Partial coverage stays
a subset result; ordinary N2 full45 qualification is still separate.

The original Phase112 `benchmark45/run.py bind` assumes unaligned assembler
arguments and rejects these aligned products. This screen reuses its observation
oracle with the already established aligned build policy instead.

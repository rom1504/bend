# Phase112 matched compiled-program screen

The initial runtime comparison uses six exact existing Phase93 batch sources:
lexer, active ray geometry (256/2240), closures (256), Unicode text (64), map
churn (128), and numeric recurrence (1024). Sources, workload arguments, full
expected values and the old 45-case catalogue stay unchanged. This is a six-case
screen, not a replacement for Phase93's 44 measured points. The original Phase111
Unicode product could not be acquired; the explicit five-case baseline and
six-case candidate accounting below preserve that missing denominator.

All six upstream C/Clang binaries remain available and match their acquisition
pins under `selfhost/build/phase93/broad01/NAME/upstream.program`. Their actual
build commands used pinned Clang22, `-std=c11 -O3`, `-lpthread -lm`. Existing
Phase111 six-case products used different one-shot Phase88 sources, so they
cannot provide a matched runtime denominator here. Acquire six Phase111 products
from the unchanged `selfhost/build/phase93/fixtures01/NAME.bend` files, using the
qualified Phase111 successor and its exact runtime object.

The frozen [manifest](../../selfhost/tools/performance/phase112/benchmark/manifest01.json)
pins the available binaries, generated upstream C, source/oracle provenance,
Base/carrier, Phase111 compiler/runtime and direct QBE/assembler/linker tools.
The observed prior output is independent of Phase112, but is reused regression
evidence rather than a new handwritten oracle. Upstream and direct backends have
different code generators; their respective flags are held fixed and reported.
Direct candidates use the same QBE target, assembler, linker flags and worker
settings as Phase111. Runtime-object identity is recorded separately.

Root runs acquisition under its serial CPU3 process-tree guard:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark/acquire.py \
  --out selfhost/build/phase112/baseline-acquisition01
```

The exact six commands are in
`selfhost/tools/performance/phase112/benchmark/acquire-phase11101.json`.
They invoke unchanged Phase111 `native-emit.py`, with `--runtime` for build-only
qualification. Individual requests allow 120 seconds and each build command
allows 30 seconds; root should apply a 300-second overall acquisition guard
initially. New artifacts are QBE/assembly/objects/binaries only, roughly several
MiB for six small programs. Existing upstream artifacts and the runtime object
are reused. No per-program C or full compiler rebuild is needed for this screen.

After acquisition, binding is source-only:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark/run.py bind \
  --label phase111 \
  --reports selfhost/tools/performance/phase112/benchmark/phase111-reports01.json \
  --out selfhost/build/phase112/phase111-products01.json
```

A candidate map may give native emission receipt paths, or entries of the form
`{"emission":"API_EMIT/report.json","build":"BUILD/report.json"}` for a
checked API producer followed by unchanged `build.py`. The binder authenticates
the same fixture/Base/carrier, the exact emitted QBE input and complete build,
then records the producer kind. Product execution remains a valid code-generation
comparison when a checked hosted API produced the candidate, but it does not
establish native candidate compiler speed or self-host qualification.

Root then runs repeated products under the same guard, without compiler work:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark/run.py measure \
  --bindings selfhost/build/phase112/phase111-products01.json \
  --out selfhost/build/phase112/runtime-baseline01 --budget-seconds 300
```

Add candidate binding files to `--bindings` for a matched comparison. Every
sample invokes `PROGRAM --threads 1 --gpu off -- REPS WARMUPS ARG0 ARG1`.
All roles use these frozen counts:

| Program | Repetitions | Warmups | Workload arguments |
|---|---:|---:|---|
| lexer | 685 | 32 | 8, 0 |
| active ray geometry | 1,883 | 32 | 256, 2240 |
| closures | 81,920 | 32 | 256, 123 |
| Unicode text | 3,679 | 32 | 64, 123 |
| map churn | 1,050 | 32 | 128, 123 |
| numeric recurrence | 76,800 | 32 | 1,024, 123 |

Three rounds are the minimum. Roles rotate order by case and round; a two-role
run alternates order. Initial timing intervals were at least 248 ms in the old
Phase93 data. A new sample must last at least 100 ms; otherwise the run remains
unqualified with no aggregate. There is no automatic repetition retuning based
on candidate results. A future count change needs a separately identified plan
and fresh matched samples for every role.

The primary clock is **milliseconds**, from the existing batch's `IO.now` calls.
It includes workload evaluation, comparison of every complete result, the loop,
and final success-count printing. Startup, the initial complete output, and 32
warmups are outside it. Stdout must exactly contain the full frozen expected
value, warmup count, measured count and one decimal millisecond line, each
newline-terminated. The count alone is insufficient: initial full output and
every repeated equality check must pass. The supervisor records raw stdout,
stderr, exit status, binary hash and process wall time separately.

`--budget-seconds 20`, `60`, or `300` bounds the execution campaign after input
authentication. `--names NAME ...` permits a small explicitly labeled subset
within the shorter budgets. `--seconds` caps each child (default 30). Expiry
preserves partial observations and fails qualification; it does not reduce
rounds or silently publish a partial six-case aggregate. Root's outer guard
also bounds memory, disk and total process-tree lifetime. The first 300-second
screen will establish whether the generic Phase111 product is practical at
these old counts.

Per-program ratios divide each role's median milliseconds by the upstream or
Phase111 median, so below one means faster. The geometric mean equally weights
the six distinct programs and is published only when every selected sample
passes correctness and minimum-duration checks. Three alternating rounds show
a range, not a statistical confidence interval. Compiler acquisition and
request clocks never enter this ratio.

`scalar-region-0` remains an explicit historical zero-work exclusion: both old
optimized backends reduced it to zero-millisecond batches even at 200 million
repetitions. Its ratio stays undefined. It is outside this initial six; other
short or timed-out results are not automatically classified as zero work. The
full45 runtime gate can follow if this screen is useful, preserving the existing
Phase93 sources, old catalogue and that named exclusion.

Preparation authenticated available inputs and exercised only the output parser
against saved observations. No compiler or generated program was launched by
the benchmark tooling author.

## Checked API acquisition and separate short profile

The first native acquisition produced lexer, ray and closure products, then
the Unicode compiler request exceeded its 120-second limit without QBE output.
That failed receipt is retained. The timeout is not a program execution result
and is not increased automatically. The same qualified Phase111 compiler source
is also available as checked `full-api05`. Its Unicode request also failed, as
recorded below. Use that producer for the remaining map and numeric baseline
products, and checked candidate APIs for subsequent products:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark/acquire-api.py \
  --api selfhost/build/phase111/full-api05/api.mjs \
  --prefix selfhost/build/phase111/p112-baseline-api02 \
  --out selfhost/build/phase112/baseline-api02 \
  --names coverage-map-churn-128 coverage-numeric-recurrence-1024 \
  --merge-reports selfhost/tools/performance/phase112/benchmark/phase111-reports01.json
```

This defaults to 60 seconds per API emission and 30 seconds per build command.
Without `--names`, it acquires all six. `--prefix` selects fresh Phase111 output
paths, as required by unchanged `emit.mjs` and `build.py`; `--out` records the
campaign in Phase112. It writes `products-map.json`, suitable for `run.py bind`.
With `--merge-reports`, successful selected acquisitions replace only those
entries, preserving the first three native products. Each API, its checked
receipt, compiler source, actual fixture, runtime and output is pinned.

The binder permits a mixed Phase111 baseline only when the API receipt identifies
the exact qualified Phase111 compiler-source hash and the runtime matches the
frozen Phase111 object. Bindings and runtime reports retain producer kinds, so
hosted production is explicit. Neither mixed production nor API acquisition
clocks become a native-compiler speed claim. The pre-change benchmark method is
retained in `benchmark/method-history/` for replay of the failed acquisition.

`fast-profile01.json` is a **new short-batch screen**, frozen before new program
timing. It uses `ceil(original repetitions / 8)` and four warmups, identically
for every compared role: 86 lexer, 236 ray, 10,240 closure, 460 Unicode, 132 map,
and 9,600 numeric repetitions. Wrapper bytes, workload arguments and expected
outputs remain exact. Pass it explicitly:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark/run.py measure \
  --bindings selfhost/build/phase112/phase111-products01.json \
  --profile selfhost/tools/performance/phase112/benchmark/fast-profile01.json \
  --out selfhost/build/phase112/runtime-fast01 --budget-seconds 60
```

This profile has a 20-ms minimum interval and retains at least three alternating
rounds. The shorter intervals have coarser relative precision at 1-ms clock
resolution; small percentage differences are inconclusive. Its observations and
geometric mean must stay separate from the original 100-ms-minimum profile.
The explicit 20/60/300-second campaign budgets still fail on exhaustion rather
than silently changing counts, rounds, membership or the denominator.

## Missing baseline and explicit comparison membership

Five baseline batch products are acquired: native lexer, ray and closures, plus
checked-API map and numeric in `baseline-api02/report.json`. Acquisition and
binding establish the product provenance; the separate runtime report must
establish complete-output correctness and timing qualification.

Unicode compilation timed out in the native request at 120 seconds and in the
original checked API at 60 seconds. The separately supervised original
`full-api05` staged request then failed naturally with
`RangeError: Maximum call stack size exceeded.` during lowering after 56.48
seconds in that stage, about 60 seconds total. Its actual failed receipt is
`selfhost/build/phase111/p112-baseline-unicode-staged01/report.json`, SHA256
`ec1b4149f563f02d72d03b92cd13e382549ea5e1dcc78e7a9657bf4314c1f2c6`.
It produced no QBE. These are compiler failures, not program runtime results;
the baseline Unicode request is not retried or replaced with a candidate.

`benchmark/baseline-completion-plan02.json` supersedes plan01 and uses
`phase111-five-template02.json`: the three actual native receipts and two actual
API/build paths, with Unicode explicitly unavailable. The binder's default
still requires all six. Pass `bind --names` with those five names to create an
explicit subset binding. The older mixed staged template remains a historical
plan and cannot qualify the missing product. Successful candidate Unicode
emission and other equivalence controls do not fill the missing denominator.

Measurement can combine a five-case Phase111 binding and a six-case candidate
binding, or compare the candidate six directly with upstream six. Version2
reports retain each role's requested, qualified and missing names. In a union
run, `complete` means all available scheduled work finished and inputs stayed
pinned; `fullRequestedQualification` additionally requires every requested
role/case. `fullInitialSix` requires all six for every role. A six-case ratio
against Phase111 is null when Unicode is missing. A five-case geometric mean
appears only as `matchedSubsetGeomeanRatio`, with its explicit qualified names
and count, after all five available pairs qualify. It is not a six-case result.
Original and short timing profiles retain separate reports.

## Combined acquisition receipt boundary

`selfhost/build/phase112/combined-batch01/report.json` remains `complete: false`:
the benchmark helper `run.py` changed during that acquisition, and its final
input check correctly reported `Changed input`. All six individual emission
and build receipts completed before that outer check. The contemporaneous
method change invalidates the campaign envelope; its status is not rewritten.

Root independently authenticated those six actual receipts and their source,
QBE, runtime and binary pins in `combined-binding01.json`, SHA256
`1c4df52cb88d868432e68097498984461f8786fbb19ef16954ca79ef831fe64a`.
That binding qualifies all six products for subsequent execution without
repeating acquisition. `combined-runtime01/report.json` separately records
their completed three-round short-profile execution against upstream. These
product observations do not turn the failed acquisition envelope into a
completed campaign or supply the missing Phase111 Unicode baseline.

The benchmark runner is now frozen at SHA256
`b7983f0aae731043c235573b48831efb35e562471f1f83a82cfedeff24280118`;
earlier helper snapshots remain in `benchmark/method-history/`.

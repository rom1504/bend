# Handwritten C and maintained Bend runtime comparison

The [Phase184 measured report](../../../../implementation/phase184/README.md)
contains the complete45-case result, per-case CSV, chart and retained evidence.

This workflow compares prepared executables on the same45 input points and
complete output oracles from the [native45 catalog](../catalogs/native45/catalog.json).
It measures program execution only. Compiler acquisition and machine construction
are prerequisites and do not contribute build-time results to this comparison.

The three roles are `handwritten-c`, `bend-qbe` and `bend-c`. The latter two use
our maintained Bend compiler: selected native N2 emitting QBE, and the selected
native public C compiler emitting C. `bend-c` is not upstream TypeScript's C
backend. Both Bend roles remain visible because the fastest build workflow and
fastest generated program need not use the same backend. The report also gives
a separate, post hoc per-case best-Bend envelope; no single backend is claimed
to achieve that entire envelope.

There are44 timing-eligible points and one zero-work correctness control.
Variants retain their original arguments and share the catalog's23 source
groups. A selected subset is explicitly a subset; it cannot stand in for all45.
This page describes the method and commands, not a claim that a campaign has
passed or a statement of measured speed.

## C implementation and validation boundary

The [shared driver](driver-README.md) calls each kernel through a separately
compiled translation unit. Acquisition uses the pinned Clang with
`-std=c11 -O3 -ffp-contract=off -fno-lto`, then links without LTO. This keeps the
kernel body unavailable to the driver's optimizer, preventing repeated calls
with identical inputs from being hoisted out of the timing loop. Kernels contain
no expected-result constants or input-specific result shortcuts.

U32 arithmetic retains32-bit wrapping semantics, and F32 operations retain
single-precision rounding without contraction or fast-math reassociation.
The C driver reads the full expected output from a pinned file. Each invocation
computes and compares its result; text results are owned strings freed after
comparison. Warmups and initial output precede the timer. The measured interval
includes repeated evaluation, validation, result disposal and success-count
printing, matching native45's interval. Stdout uses ordinary buffering.

These are handwritten algorithm counterparts, with explicit representation
choices, rather than a claim that C and Bend allocate identical objects. Read
the family notes before interpreting a ratio:

- [Algorithms](algorithms/NOTES.md): edit distance, complete row state, tree sorting and lexer.
- [Numeric kernels](numeric/NOTES.md): word arithmetic, arrays and F32 recurrence.
- [Rendering and symbolic work](render-symbolic/NOTES.md).
- [Structures](structures/NOTES.md): closures, lists, trees, expressions and local pairs.
- [Maps and aggregation](text-map/NOTES.md), and [text kernels](text-map/NOTES-text.md).

The acquisition adapter requires the original complete-output check for every
selected Bend product and checks the corresponding C result. It also runs its
declared additional argument pairs against both Bend roles. These finite checks
do not establish equivalence for arbitrary inputs. Sanitizer and structural
reviews are separate evidence; their instrumented products are not timing inputs.

## Acquire explicit products

Run from the repository root. Each command below has its own single outer
[disk/process guard](../../../../docs/self_hosted/build-retention.md), through
the Phase184 job wrapper. Do not nest guards. Use fresh job/output names; the
examples reserve CPU3, a960-second outer deadline and the stated disk budget.
The inner acquisition deadline is900 seconds, leaving finalization headroom.
These are ceilings, not promises that every machine finishes within them.

First save an acquisition recipe, replacing `/absolute/repository` with the
canonical checkout path. The installed package receipt authenticates the C
image and its sibling Base/runtime assets; it does not need a new image key.

```json
{
  "kind": "bend-benchmark-acquisition-v1",
  "catalog": "/absolute/repository/selfhost/tools/bench/catalogs/native45/catalog.json",
  "reference": "bend-qbe",
  "roles": {
    "bend-qbe": {
      "provider": "build",
      "assets": "/absolute/repository/selfhost/manifests/assets-native.json",
      "imageKey": "qbe-n2",
      "host": "native", "stage": "N2", "target": "qbe",
      "mode": "cache", "policy": "ordinary-serial", "status": "qualified-installed"
    },
    "bend-c": {
      "provider": "build",
      "assets": "/absolute/repository/selfhost/manifests/assets-native.json",
      "image": "/absolute/repository/selfhost/dist/native/bend",
      "imageReceipt": "/absolute/repository/selfhost/dist/native/BUILD.json",
      "host": "native", "stage": "N1", "target": "c",
      "mode": "cache", "policy": "ordinary-serial", "status": "qualified-installed"
    }
  }
}
```

Acquire the exact Bend wrappers with the maintained build adapters. QBE uses
its declared machine toolchain/runtime; C uses the declared C toolchain.
The `status` labels above refer to the installed selection and do not replace
the per-product output checks or their receipts.

```sh
python3 -B selfhost/tests/phase184/job.py bend-products-example 960 1024 \
  python3 -B selfhost/tools/bench/acquire.py \
  --recipe /absolute/path/to/acquire-bend.json --set full \
  --seconds 900 --guarded --cpu 3 \
  --out selfhost/build/phase184/bend-products-example
```

Next, the [Phase184 acquisition adapter](../../../tests/phase184/acquire-c.py)
authenticates that complete Bend acquisition, builds the handwritten C kernels
and freezes the three-role product manifest. Omitting `--cases` requires all45.

```sh
python3 -B selfhost/tests/phase184/job.py direct-products-example 960 512 \
  python3 -B selfhost/tests/phase184/acquire-c.py \
  --assets selfhost/manifests/assets-native.json \
  --bend-products selfhost/build/phase184/bend-products-example/programs.manifest.json \
  --seconds 900 --guarded --cpu 3 \
  --out selfhost/build/phase184/direct-products-example
```

For a bounded pilot, give both acquisition commands the same explicit
`--cases ID,ID` selection instead of requesting the full set. Do not describe
that receipt as full45 qualification. Reuse existing complete, unchanged
products when available; the timing runner never acquires missing products.

## Run the normalized runtime comparison

```sh
python3 -B selfhost/tests/phase184/job.py runtime-example 960 512 \
  python3 -B selfhost/tools/bench/handwritten-c/run.py \
  --manifest selfhost/build/phase184/direct-products-example/products.json \
  --rounds 3 --seconds 900 --target-ms 250 --guarded --cpu 3 \
  --out selfhost/build/phase184/runtime-example
```

The runner verifies the frozen binaries, expected files, methods, catalog
points, families and source groups. Changed inputs invalidate the campaign.
Each role starts calibration at the original count. A short batch scales up
using `ceil(count * target / elapsed)`; a zero-millisecond batch grows10×.
A batch longer than twice the target scales down and verifies the new count.
A single invocation longer than the target is unavoidable and accepted.
Counts stop at `2^31-1`, calibration at eight attempts, each child at30 seconds,
and the campaign deadline at no more than900 seconds. Every pilot is retained.

After calibration, each case receives three serial rounds with rotating role
order. Original inputs, expected outputs and warmup counts stay fixed; measured
repetitions may differ between roles. Every accepted timed batch must last at
least100ms and pass the entire output/success-count contract. The zero-work
point still executes and validates, but contributes no ratio.

This is a **new normalized milliseconds-per-invocation metric**, not the
historical fixed-repetition native45 score. It avoids forcing the slower role
to perform the much larger batch needed to resolve a very fast C kernel.
Different batch lengths can expose different allocator/cache behavior, so
the report retains counts, elapsed intervals and process clocks alongside the
normalized samples. `--cases`, `--rounds` and `--target-ms` make subset and depth
choices explicit; rounds divisible by three balance the three role positions.

The report shows per-role medians, ratios/log-ratios against handwritten C,
equal-point geometric means, and equal-family/equal-source weighted geometric
means. Group weighting averages log-ratios within each group before giving
groups equal weight. The per-case best-Bend envelope is reported separately.
If any selected case fails, is incomplete, or has a short timed sample, there
is no admitted aggregate. Deadline exhaustion retains a partial report; it
never drops the failed cases to produce a favorable geometric mean. Fully
admitted individual cases may still be inspected with their limited scope.

Offline metadata tests use mocked children and execute no benchmark products:

```sh
python3 -B selfhost/tools/bench/handwritten-c/test_run.py
```

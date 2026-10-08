# Fresh native baseline

The Phase66 compiler used as the baseline emitted structurally expensive native code.
On three diagnostic families, its executable is **3.13×–122.59× slower** than
current upstream-generated C. Its C also takes **16.56–16.75 seconds** to compile,
versus **0.88–0.95 seconds** for upstream. These are fresh Phase67 measurements,
not reuse of Phase46's historical ratios.

Both roles use upstream `059266225b77c8ca256ac6b25ee5c21449bab151` language/Base
and the same Clang22 toolchain and flags. Our producer is the installed checked
B1 `bb6c6e2ad6f18bf54d2b5c7e4e7a8d0fe3f0f80658a260ad52256fa4351d81a6`.
This measures the native pipeline and generated executables; it does **not**
remeasure Phase66's B1/B2 JavaScript compilation-parity score. Each product uses
its compiler's own native runtime; this compares complete backend products.

| Workload | Upstream C µs/workload | Bend C µs/workload | Bend / upstream | Clang build, upstream / Bend |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence | 3.27 | 50.77 | 15.55× | 0.946 / 16.561 s |
| Array fold | 2.91 | 356.15 | 122.59× | 0.905 / 16.754 s |
| Captured closures | 3.84 | 12.01 | 3.13× | 0.883 / 16.753 s |

Six acquired products pass smoke checks and all twelve final timing observations
pass independent output digests and clock qualification. Two rotated rounds use
the identical 16-input schedule, measured repetitions and warmups in each pair.
The shortest measured interval is 118 ms. The two-sample relative range reaches
11.8% for upstream arrays and 10.4% for our numeric case: use these as screening
estimates, not precise small-percentage results. Their equal-family geometric
mean is 18.13×, but three deliberately diagnostic families do not establish a
representative whole-language score. Tree, Map and Lexer remain held out here.

The supervised CPU is 3, native threads 1/GPU off, Node heap 1 GiB/stack 4 MiB,
process-tree RSS ceiling 2 GiB, available-memory floor 4 GiB. Every target uses
the existing exclusive guard. Native compilation uses `-std=c11 -O3 -lpthread
-lm`, without fast-math. Runtime excludes emission, C build and startup; it
includes the shared Bend digest and its final formatting/printing. Warmups are
one eighth of measured repetitions, with no claim of steady-state stationarity.

## Why native lowering is the first target

Our emitted files are 1.96–2.01 MB, versus 118–125 KB upstream. The following are
**syntactic occurrences in the whole C translation unit**, excluding preprocessor
lines. They include runtime code and are not dynamic allocation/dispatch counts.
Exact patterns and C hashes are in the [shape receipt](evidence/native-baseline02-shape.json).

| Workload | `WL_CASE` segments, Bend / TS | Continuation assignments | Generic closure transfers |
| --- | ---: | ---: | ---: |
| Numeric | 2,340 / 51 | 1,981 / 16 | 223 / 3 |
| Array | 2,378 / 51 | 2,011 / 16 | 233 / 3 |
| Closures | 2,307 / 65 | 1,963 / 23 | 225 / 6 |

This supports first testing general removal of trivial argument continuations
and saturated scalar-call transport. It does not prove which fraction of runtime
those operations consume, nor that every static segment executes. The planned
ablations must improve actual independent-output executions before promotion.

Checked Bend-to-C request clocks are 2.03–2.14 s for B1; upstream load/check plus
emission takes 0.68–0.71 s. B1 prepares its checked Base before that request while
TS loads Base inside its request. Import/setup and preparation are separate in
the [summary](evidence/native-baseline02-summary.json). These are acquisition
observations with one sample per product, not a controlled JS compilation score.

## Reproduce and extend

[Reusable loop and commands](../../selfhost/tools/performance/phase67/benchmark/README.md).
The initial recipe omitted core Clang shared-library pins; it was superseded
before target execution. Baseline02 pins the driver, core shared libraries,
linkers and headers, records selected C environment variables, and checks inputs
before and after execution. The OS/system libraries remain host dependencies.

The first array calibration returned an unresolved coarse 1 ms upstream clock.
The separately derived `native-plan-screen03.json` increases measured array work
to 61,440 iterations and reduces warmups to 7,680, retaining all calibration
observations. It predicts a roughly 25-second largest process within the
45-second deadline. Final observed array intervals are 168–189 ms upstream and
21.609–22.155 s for Bend; all qualify. Candidate screens reuse this exact plan;
a substantially faster candidate requiring more repetitions must get a new plan
and paired remeasurement, not an extrapolated gain.

Closed raw inputs in `selfhost/build/phase67/`:

- `native-baseline02-recipe.json`: `43c21dc7…65103e`.
- `native-baseline02/report.json`: six C emission/build/smoke products.
- `native-calibration02/report.json`: six retained calibration observations.
- `native-plan-screen03.json`: `7c9e6460…a74d44`, with derivation sidecar.
- `native-timing03/report.json`: twelve final qualified observations.
- [Summary](evidence/native-baseline02-summary.json): `9449a717…983d3a`.
- [Static shape](evidence/native-baseline02-shape.json): `b13d7d25…ae0388`.

Raw preservation and final candidate decisions belong to the Phase67 closure;
these baseline receipts are never overwritten when a candidate is selected.

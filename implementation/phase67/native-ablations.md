# Native lowering ablations

The final six-family campaign selects atoms plus saturated scalar lowering:
**33.3% less native execution time, 18.4% less Clang build time and 20.0% smaller
generated C**, using equal-family geometric means. All six families improve.
Native execution remains **10.41× upstream C** on this diagnostic set, down from
15.61× on the same reference anchors. See the final table below; these are not
JavaScript-runtime or B1/B2 compiler-throughput scores.

The first candidate removes continuation construction when a native call
argument is already a variable or machine-word literal. This is a general
lowering rule, applied across programs; it does not match benchmark names.
The [fresh baseline](native-baseline.md) establishes the initial backend gap.

## Atoms only

All three candidate products pass smoke output checks and six measured
observations pass independent digests with intervals above 100 ms. The exact
same wrappers, compiler environment, Clang flags, runtime plan and warmup counts
are verified by the [comparison receipt](evidence/native-atoms01-comparison.json).
Baseline and candidate campaigns ran sequentially, not interleaved, so these
are screening gains pending broader confirmation.

| Workload | Baseline µs/workload | Atoms µs/workload | Execution-time reduction | Clang build, baseline → atoms |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 50.77 | 37.21 | 26.7% | 16.56 → 14.01 s |
| Array | 356.15 | 244.13 | 31.5% | 16.75 → 14.25 s |
| Closures | 12.01 | 9.72 | 19.1% | 16.75 → 13.99 s |

Equal-family geometric means: **25.9% less execution time, 15.6% less Clang build
time and 15.0% less generated C**. C build is one acquisition per product;
execution uses two rounds. This covers three diagnostic families, not universal
native conformance or generated-JavaScript/compiler-throughput performance.

Static counts support the intended mechanism: numeric segments fall from 2,340
to 1,885, array from 2,378 to 1,904, and closures from 2,307 to 1,859. The same
455/474/448 reductions appear in continuation assignments and task-node syntax.
Closure-construction and generic closure-transfer counts stay unchanged. These
are textual counts, not dynamic allocations or executed dispatch counts.

Against the **earlier** upstream timing, remaining gaps are about 11.40× numeric,
84.03× array and 2.53× closures. These contextual projections are not a fresh
paired TypeScript campaign. The sizeable remaining array gap warrants the next
scalar-call ablation and held-out programs.

Evidence: [summary](evidence/native-atoms01-summary.json),
[static shape](evidence/native-atoms01-shape.json),
[verified comparison](evidence/native-atoms01-comparison.json).
`compare.py` refuses changed shared method inputs, different plans, wrapper
identities or output expectations, and clocks below 100 ms. It keeps native
acquisition/build/runtime clocks distinct from Phase66's B1/B2 JS compilation
metrics. No release promotion follows from this screen alone.

## Atoms plus saturated scalar calls

The second candidate also removes the call protocol for exactly saturated known
scalar primitive calls, preserving the primitive's operation/evaluation behavior
and retaining fallback for other expressions. Three fresh candidate products and
all six measured observations pass the same output and clock gates.

| Workload | Baseline µs/workload | Atoms + scalars | Reduction from baseline | Increment beyond atoms |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 50.77 | 22.46 | 55.8% | 39.6% |
| Array | 356.15 | 232.38 | 34.8% | 4.8% |
| Closures | 12.01 | 9.47 | 21.1% | 2.5% |

The combined screen gives **38.9% less execution time (1.64× speedup)**,
**15.6% less Clang build time**, and **16.6% less C source**, using equal-family
geometric means. Scalar lowering's clearest incremental benefit is numeric;
the smaller array/closure increments need broader evidence and should not be
oversold as precise independent gains. Native gaps against the earlier upstream
measurements remain 6.88×, 79.99× and 2.47× respectively.

Additional segment reductions beyond atoms are 50 numeric, 40 array and 37
closure segments. Closure construction/dispatch syntax remains unchanged, so
the remaining transport and aggregate costs warrant later architectural work.
This checkpoint advanced to the tree/Map/Lexer held-out gate and refreshed
upstream runtime observations below; the three-family screen alone did not
qualify a release.

Evidence: [combined summary](evidence/native-scalars01-summary.json),
[shape](evidence/native-scalars01-shape.json),
[baseline comparison](evidence/native-scalars01-comparison.json),
[increment versus atoms](evidence/native-scalars-versus-atoms01.json).

The first held-out baseline launch correctly refused installed-release
verification after production compiler source had changed for the candidate.
That failed launch remains `native-heldout-baseline01`. The replacement recipe
uses the frozen Phase66 checked API, whose bytes exactly equal the original
installed baseline; all shared host/runtime/Base/method/toolchain identities
match. The [continuation receipt](evidence/native-baseline03-continuation.json)
does not claim that the mixed live checkout still verifies as the installed
release. Held-out products use a fresh `native-heldout-baseline02` directory.

## Final six-family result

The held-out tree, Map and Lexer sources all improve. Across the complete six
families, baseline and selected Bend images produce 12 correct acquired
products and 24 qualified runtime samples. The reference contributes six acquired programs and
12 full-plan observations, with six additional refreshed observations for the
first three families. Atoms-only and calibration observations remain separate.
These are workload/product counts, not language conformance-test counts.

| Family | Before µs/workload | Selected µs/workload | Less execution time | Selected / upstream C |
| --- | ---: | ---: | ---: | ---: |
| Numeric | 50.77 | 22.46 | 55.8% | 7.20× |
| Array | 356.15 | 232.38 | 34.8% | 84.99× |
| Closures | 12.01 | 9.47 | 21.1% | 2.46× |
| Tree | 1,865.81 | 1,469.67 | 21.2% | 9.78× |
| Map | 2,795.36 | 2,004.03 | 28.3% | 5.90× |
| Lexer | 9,957.88 | 6,816.58 | 31.5% | 14.71× |

[Combined evidence](evidence/native-final06-summary.json) binds the disjoint
screen/held-out comparisons and the baseline-image continuation. The first
three TS denominators use the [later replay](evidence/native-upstream-refresh01-comparison.json)
of the same frozen binaries; their clocks shifted −4.5%, −5.9% and +0.4%.
Held-out denominators use their newly acquired upstream products. Campaigns are
sequential epochs, not interleaved baseline/candidate/TS triples. All actual
full-plan intervals exceed 100 ms; each runtime cell has two observations.

Clang compilation falls from 16.56–38.98 s to 13.75–28.19 s across these cases,
with an 18.4% geometric-mean reduction. This is a separate single-build-per-product
clock. C source is 20.0% smaller on the same weighting. The lower runtime cost
is useful and general across these families, but array aggregates, closure
transport and continuation-heavy lowering still leave a substantial native gap.
A future large gain should target those structures, not micro-optimize Clang
flags or assume that C emission alone gives native parity.

The recommendation is to select the combined general lowering after the root's
native/B2/JS correctness and release gates. Six diagnostic families establish
breadth beyond the initial three; they do not cover every Bend program, GPU
behavior, effects, or all native APIs. The fast loop below improves the next
investigation's efficiency without inflating this scope.

## Validated fast iteration loop

The new six-family Bend-only loop executes already compiled programs and passes
all twelve independent-output/clock checks in **7.00 s of recorded campaign wall
time**, excluding initial Python setup/input hashing. The native child processes
total 2.83 s; guarded workers account for 3.41 s. Measured intervals total 2.47 s
and individually range from 182 to 230 ms. Peak tree RSS is 25.7 MiB.
[Exact validation and boundaries](evidence/native-fast06-validation01.json).

The [plan](evidence/native-fast06-plan01.json) is bound to immutable selected B1
`c76f1113…0c1fb3` and its six compiled executables. New candidates use the same
plan and independent digests, so routine relative runtime screens avoid spending
30 seconds on the slower array binary merely to time TS above the clock floor.
Bend/C compilation costs remain separate and are not hidden by this improvement.
Occasional TS-resolved runs retain the external performance anchor. No repeated
C build is needed between runtime observations, and an improvement that makes
intervals too short triggers paired baseline/candidate recalibration.

The fast-loop baseline is ready for subsequent optimization. Its observations
are distinct from the full-plan six-family score above because repetition and
warmup counts differ. [Commands and artifact prerequisites](../../selfhost/tools/performance/phase67/benchmark/README.md).

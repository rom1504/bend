# Native lowering ablations

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
This candidate goes to the tree/Map/Lexer held-out gate and a refreshed upstream
runtime observation before selection; these screen results alone do not qualify
a release.

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

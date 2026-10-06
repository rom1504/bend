# Which B1 transformations matter?

The ordered-stage experiment passed **24 fresh worker processes and 96 checked
library requests**. On these two compiler inputs, native string equality accounts
for the largest observed step, expanding literal choices adds another substantial
gain, and the final tail-choice rewrite adds a smaller gain. These are changes
to the upstream-emitted Bend compiler image; they are not measured improvements
to the direct B2 image.

The [structured summary](evidence/transformation-latency-summary.json) recomputes
the actual medians, individual request sequences, ratios and artifact bindings.
The run took **325.622 s**, with **303.642 s** summed worker wall time. Its separate
preparation took **63.905 s** and is not included in that timing-run total.

## Exact sequence

These are restored intermediate stages of the existing derived B1, not new
checked builds or compiler-source changes. All retain the same original runtime
and public exports. The original derivation scope is compiler-host data with
standard unmodified JavaScript builtins; it is not arbitrary reflective-host
equivalence.

| Stage | Change from preceding stage | Image bytes | SHA256 prefix |
| --- | --- | ---: | --- |
| Raw | Genuine checked upstream-emitted image | 1,807,265 | `1498f6758c1ce713` |
| Equality | One guarded primitive-string equality fast path in `String.eq` | 1,807,347 | `0d4a58b3b2e4133d` |
| Literal choices | 3,315 exact saturated choice sites with two literal closure arguments become direct selection of the chosen arrow, retaining `run_tail` | 1,824,731 | `769818565235c7a39` |
| Tail choices / B1 | 329 eligible returned choices become statements; terminal generated calls retain tail messages | 1,830,723 | `128619779fb5e291` |

The equality fast path returns JavaScript `===` when both operands are primitive
strings; other values retain the old function body. The first choice pass does
not remove every closure or trampoline. The tail pass has its own narrower
one-return branch conditions. Site counts describe rewritten source sites, not
dynamic calls, allocations or measured CPU shares.

Preparation compiled Evening and lexer through all four images and executed
their complete catalog oracles. Every image emitted byte-identical JavaScript
for each input; every one of the 96 measured requests matched its prepared
output. The images have separate, primed, API-keyed Base caches. The same source,
ordinary driver, backend and first-plus-three-repeat protocol are used as in
the [four-image comparison](latency.md). Three cyclically rotated rounds are
not a fully counterbalanced four-position schedule.

## Measured latency

All times are medians in milliseconds. “Later request” is the median of each
process’s three subsequent requests, then the median across the three processes.

| Input | Image | Load | First request | Load + first | Later request |
| --- | --- | ---: | ---: | ---: | ---: |
| Evening | Raw checked image | 60.270 | 6,117.318 | 6,179.621 | 4,903.808 |
| Evening | Equality only | 60.323 | 3,758.420 | 3,818.743 | 2,639.401 |
| Evening | + literal choices | 70.254 | 3,042.786 | 3,113.040 | 2,013.534 |
| Evening | + tail choices (B1) | 61.454 | 2,905.922 | 2,968.364 | 1,941.993 |
| Lexer | Raw checked image | 60.257 | 3,400.119 | 3,460.747 | 2,421.374 |
| Lexer | Equality only | 60.021 | 2,276.325 | 2,336.531 | 1,350.877 |
| Lexer | + literal choices | 61.534 | 1,854.689 | 1,916.223 | 1,115.700 |
| Lexer | + tail choices (B1) | 62.008 | 1,761.562 | 1,822.705 | 1,060.369 |

Each row below compares only the next stage against its immediate predecessor.
The percentage is the reduction in time; the ratio is before/after.

| Input | Added transformation | Initial gain | Initial time reduction | Later gain | Later time reduction |
| --- | --- | ---: | ---: | ---: | ---: |
| Evening | Equality | 1.618× | 38.20% | 1.858× | 46.18% |
| Evening | Literal choices | 1.227× | 18.48% | 1.311× | 23.71% |
| Evening | Tail choices | 1.049× | 4.65% | 1.037× | 3.55% |
| Lexer | Equality | 1.481× | 32.48% | 1.792× | 44.21% |
| Lexer | Literal choices | 1.219× | 17.99% | 1.211× | 17.41% |
| Lexer | Tail choices | 1.051× | 4.88% | 1.052× | 4.96% |

The full raw-to-B1 ratios are **2.082× / 1.899×** for initial latency and
**2.525× / 2.284×** for later requests (Evening / lexer). The intermediate
ratios multiply along this sequence; their percentages must not be added. The
individual steps are conditional on the transformations that precede them.
JIT and allocation interactions can contribute to each observed difference;
this experiment is not a factorial separation of independent effects.

## Individual later-request sequences

Values are milliseconds, in execution order within each process. These retain
the warming trends and nonmonotonic observations rather than reporting only the
fastest request.

| Input | Image | Round 1 | Round 2 | Round 3 |
| --- | --- | --- | --- | --- |
| Evening | Raw checked image | 5,591.2 → 4,491.4 → 4,974.1 | 5,088.5 → 4,501.5 → 4,834.1 | 5,182.3 → 4,903.8 → 4,862.0 |
| Evening | Equality only | 2,998.7 → 2,444.9 → 2,639.4 | 3,005.3 → 2,512.9 → 2,844.5 | 3,022.7 → 2,442.4 → 2,599.3 |
| Evening | + literal choices | 2,419.2 → 2,013.5 → 1,799.1 | 2,446.8 → 2,012.1 → 1,875.7 | 2,418.0 → 2,143.0 → 1,938.6 |
| Evening | + tail choices (B1) | 2,466.1 → 2,068.6 → 1,849.8 | 2,314.5 → 1,933.6 → 1,725.3 | 2,296.6 → 1,942.0 → 1,727.0 |
| Lexer | Raw checked image | 2,576.1 → 2,143.7 → 2,443.6 | 2,614.4 → 2,187.9 → 2,421.4 | 2,535.3 → 2,225.8 → 2,047.8 |
| Lexer | Equality only | 1,629.6 → 1,344.3 → 1,159.3 | 1,630.0 → 1,361.8 → 1,162.5 | 1,633.1 → 1,350.9 → 1,169.6 |
| Lexer | + literal choices | 1,323.2 → 1,059.2 → 906.6 | 1,261.4 → 1,164.4 → 921.4 | 1,287.6 → 1,115.7 → 967.3 |
| Lexer | + tail choices (B1) | 1,081.2 → 1,060.4 → 868.2 | 1,103.5 → 1,057.3 → 866.0 | 1,079.0 → 1,086.0 → 866.3 |

## What this establishes—and what it does not

The additional B1 image transformations are a substantial part of its advantage
on these compiler requests. This strengthens the reason to compare B2 against
both raw and derived B1: the derived image is not simply unmodified output from
the upstream compiler.

It does **not** make equality a fresh B2 opportunity: selected Phase56 B2 already
has definition-only native `String.eq`. Nor does it show that copying the two
choice passes into B2 will reproduce these gains. B2 has different emitted
structure, control flow and runtime decisions. Its remaining hot choice/call
sites need their own exact-source analysis and controlled experiment.

There is no TypeScript or B2 timing role in this stage matrix. Their separately
measured values from the earlier four-image run are not pooled here or used as
same-run denominators. This is two library compiler workloads, not a whole-corpus
generated-program speed claim or compilation of the entire compiler. Three
subsequent requests still show material changes, so no stationary throughput or
statistical-significance claim is made.

Raw evidence is `selfhost/build/phase57/stages-latency01/report.json`, SHA256
`92b84eaf0d84762dbf1e4b9fe6f0e0f5586ebdc1bd3614533ab7c693361fdf3a`.
Its preparation and exact intermediate derivations are retained at
`stages-preparation01/report.json` and `transform-stages01/report.json`.
The summary rehashes all 24 worker receipts, validates serial rotation and the
reported exact-output matches, and independently recomputes all displayed
timing values. No compiler or benchmark target was run during this analysis.

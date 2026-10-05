# RNFA04 compiler request cost

RNFA04 increases the median checked-library request time by **3.27% for Evening**
and **4.41% for lexer** against array06 in this two-source screen. Both sources
produce byte-identical JavaScript with the two Bend compilers. All **18 requests**
pass independent expected-output checks. These are compiler costs, separate from
the execution speed of the emitted programs; this result supplies no compiler
latency improvement or full-corpus/self-compilation claim.

## Request boundary and protocol

The unchanged Phase30 worker runs three rotated fresh-process rounds per source
and compiler: TypeScript/baseline/candidate, baseline/candidate/TypeScript, then
candidate/TypeScript/baseline. Each request checks source loading, validation and
library generation. Bend lazy API loading and ordinary Base-cache handling remain
inside `inspect`; disk-cache priming is excluded. Host import is measured separately.
The TypeScript import loads the upstream modules, whereas Bend imports the typed
driver and loads its API lazily during the request. Comparing host-import columns
alone would therefore be misleading.

The runner uses Node 24.18.0, CPU 3, a 4,096 KiB stack, 1,024 MiB heap, a 2,048 MiB
polled process-tree RSS ceiling and a 4,096 MiB available-memory floor. Requests
run serially with a 60-second child limit and 240-second campaign limit. Each
output equals the independently checked acquisition from its exact compiler tuple.
Before/after artifact verification and output writing are outside request timing
but inside process wall time. The latter is deliberately not labeled compilation.

## Measured request and startup times

Each cell is the median **[minimum, maximum]**, in milliseconds, across three
observations. All raw observations remain in the derivation receipt.

| Source / compiler | Checked request ms | Host import ms | Import + request ms | Process wall ms |
| --- | ---: | ---: | ---: | ---: |
| Evening / TypeScript | 578.638 [578.326, 580.906] | 214.933 [213.031, 217.324] | 793.572 [791.357, 798.229] | 5405.740 [5386.116, 5408.735] |
| Evening / Array06 | 3895.067 [3761.718, 3928.089] | 3.918 [3.816, 3.943] | 3898.985 [3765.661, 3931.905] | 8663.367 [8537.943, 8690.196] |
| Evening / RNFA04 | 4022.600 [4014.988, 4029.197] | 3.805 [3.798, 4.039] | 4026.398 [4018.793, 4033.236] | 8827.204 [8819.333, 8844.898] |
| Lexer / TypeScript | 332.953 [332.364, 335.243] | 212.593 [211.478, 212.708] | 545.661 [544.958, 546.721] | 5164.428 [5142.133, 5225.925] |
| Lexer / Array06 | 4455.951 [4436.055, 4476.249] | 3.831 [3.822, 3.874] | 4459.825 [4439.885, 4480.070] | 9231.357 [9210.287, 9273.383] |
| Lexer / RNFA04 | 4652.499 [4488.040, 4770.704] | 3.843 [3.831, 3.933] | 4656.431 [4491.883, 4774.535] | 9600.119 [9308.294, 9717.982] |

RNFA04 remains **6.952× TypeScript request time on Evening** and **13.973× on
lexer**, versus array06’s 6.731× and 13.383×. With only three fresh observations
per cell, the ranges are descriptive, not confidence intervals. The comparison
measures the combined compiler changes; it does not isolate a planner, pass or
new source line as the cause of the extra time.

## Memory and output size

RSS cells are median **[minimum, maximum]** in MiB. Process RSS comes from Node’s
`resourceUsage().maxRSS`; tree RSS is the supervisor’s sampled process-tree peak.
They are different observations and need not have identical peaks. Output sizes
are identical in all three repetitions of each cell.

| Source / compiler | Process RSS MiB | Sampled tree RSS MiB | Output bytes |
| --- | ---: | ---: | ---: |
| Evening / TypeScript | 532.500 [531.207, 533.457] | 532.242 [531.207, 533.152] | 62,658 |
| Evening / Array06 | 530.781 [529.348, 531.238] | 530.266 [528.574, 531.238] | 177,066 |
| Evening / RNFA04 | 536.555 [535.199, 539.500] | 536.527 [534.426, 538.984] | 177,066 |
| Lexer / TypeScript | 531.332 [530.188, 532.824] | 531.074 [530.188, 532.566] | 14,110 |
| Lexer / Array06 | 534.637 [534.012, 536.289] | 534.379 [533.754, 536.031] | 209,949 |
| Lexer / RNFA04 | 537.984 [537.379, 539.168] | 537.121 [536.910, 537.727] | 209,949 |

Evening output is 177,066 bytes for both Bend compilers, SHA-256
`b21b0bbd4e40873907038838d89c559ef73d6c7e599f87e63e94b9f5be77f8b7`.
Lexer is also byte-identical at 209,949 bytes. The different TypeScript output
sizes do not imply a runtime-speed ratio.

## Preparation and campaign cost

The timed campaign wall is **161.249 s**, of which the 18 child process walls sum
**140.457 s**. The checked request intervals alone sum **53.670 s**. The remaining
20.792 s outside those children includes runner verification and orchestration;
it is not compiler execution. Child wall also includes its own substantial
verification and startup work, so these three totals must not be added together.

Preparation stays separate. The retained preparation receipt records baseline
binding verification at **2.817 s** and candidate binding verification at
**2.797 s**, summing **5.613 s**. This is the two measured binding processes, not
a complete planner wall timer and not the earlier full-corpus acquisition or
cache-priming cost. The receipt’s inherited `executed:false` means it did not run
the cost requests; its explicitly recorded binding subprocesses did execute.

## Artifact and source binding

| Artifact | Identity / count |
| --- | --- |
| Array06 API | `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f` |
| RNFA04 API | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` |
| Shared runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |
| Pinned upstream | `018751270e800bc222a93dad7f257083ee53a5f7` |
| Evening source | `b254a68ad0208b8a5f388d72095633cd8fc119adf40d45f5621e93f37e7b4f71` |
| Lexer source | `6014af6bf7e97c8feaafa918e79f28a22d2c9c92bea836203fcd89b6d70a4fbb` |
| Physical compiler lines | 23,254 → 23,660 (+406, +1.75%) |
| Nonblank/non-comment lines | 19,175 → 19,489 (+314, +1.64%) |
| Definitions / modules | 2,622 → 2,673 / 86 → 92 |

The [static accounting](accounting.md) binds those source totals to the same API.
It is a cost/complexity inventory, not an explanation for the timing difference.
Historical phase labels retained inside the copied planner describe its lineage;
the exact attempt/API/runtime/source joins above identify this measurement.

[Checked derivation](evidence/compiler-cost-final.json) recomputes every median
and range, verifies the exact 18-row rotation, checks all raw result/process
leaves, output hashes and serial intervals, and rehashes 852 consumed inputs.
Its SHA-256 is `1ece9cbf372998de408ce4ac2927801b354a7828ee5876652f9f40a71f99151b`.
The raw report is `selfhost/build/phase48/compiler-cost-rnfa04/report.json`;
its hash and the frozen data-only derivation helper are included in that receipt.
The [method plan](compiler-cost-plan.md) preserves the runner and preparation
procedure. No compiler or generated program was executed to produce this report.

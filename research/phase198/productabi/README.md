# Private product return transport

The current direct backend writes each multiple result to a caller-owned buffer. A caller reloads all fields into their assigned homes. The fixed 64-byte stack reservation by itself costs no additional instruction at each call. The potential savings come from eliminating address formation, argument staging, stores and reloads.

## Where the boundary executes

The census joins instructions to the program-counter samples from the same linked executable, verifies its SHA-256 digest and weights each observation by its sampling period. The payload includes the source load, pointer evaluation, field store, zero status and the three-instruction caller reload per field. The broader interval adds the call setup and call, the target's straight-line prologue and return epilogue. Some argument and return instructions would still execute with a register convention. These are historical sample shares. Each individual session fell below the profiler's 500-sample minimum. Paired sessions supply 548–678 raw observations per row. Scheduled execution, instruction overlap, code layout and sampling error limit extrapolation.

| Historical product | Transfer payload | Broader interval | Immediate unchanged forwarding |
| --- | ---: | ---: | ---: |
| Lexer, Phase194 | 3.29% | 9.44% | 0.13% |
| Lexer, Phase192 | 4.89% | 10.96% | 0.00% |
| BST64, Phase195 | 2.79% | 3.06% | 0.00% |
| Map churn32, Phase191 native | 2.51% | 3.87% | 1.30% |
| Map/set operations, Phase194 | 1.74% | 3.86% | 0.70% |
| Active ray64, Phase194 | 1.62% | 2.16% | 0.00% |
| Edit distance, Phase194 | 0.26% | 0.61% | 0.00% |
| Local pair, Phase191 development | 0.46% | 0.69% | 0.00% |
| Local fold, Phase190 development | 0.00% | 0.00% | 0.00% |

All 45 current Phase197 N1 outputs have at least one pair-return call site. Fifteen contain exactly one product call. Fifteen have a call followed immediately by returning its results unchanged. The general private result ABI has a measurable target on lexer and BST. Forwarding a caller's result buffer to the callee covers fewer sampled instructions. A function's total sample count can give a misleading estimate here. Edit distance spends most of its time computing inside its row worker between return boundaries.

The complete current static census and historical sample joins include paths, digests and individual sessions. [Current products](current.json) · [Matched profiles](census.json) · [Census implementation](census.py)

## Machine experiment

The frozen experiment compares ordinary lexer and BST64 with a two-word private convention in R10 and R11. The callee can load both output words without clobbering their source homes. The caller can publish them independently to its normal stack or register homes. Both registers are scratch throughout the existing allocation scheme. All original exported bodies remain callable with their normal hidden pointer and return status. Direct pairs that need version fallback, have another use of the hidden pointer or return through a different instruction sequence retain their original call operation. The caller keeps the old positions of all remaining arguments, including stack arguments. A separately instrumented copy counts pair calls. Each timing arm executes the original uninstrumented benchmark and validates its original result counts.

The screen uses fresh assembly from the current native compiler, both project and ordinary assembler layouts, four paired rounds and three additional argument sets checked against the independent C executable. The predeclared admission threshold is a median ratio of at most 0.98 with three favorable pairs under each layout for the same workload. [Machine transformation](project.py) · [Frozen criterion and initial source projections](frozen.json) · [Guarded timing and oracles](screen.py)

## Two-lane screen outcome

A count-instrumented copy records 15,659 additional pair calls per complete lexer invocation. One call site in the lexing loop accounts for 15,147. BST64 executes 64, and its other two pair call sites execute zero additional times. The uninstrumented lexer used 3.49% less time under the project layout (3 of 4 pairs faster) and 4.95% less time under the assembler default (4 of 4). BST64 used 1.34% and 7.14% more time, respectively (1 of 4 and 0 of 4 faster). All four baseline/candidate layout products matched C on the ordinary input and three further inputs in each case. [Report and per-site counts](evidence/productabi-screen01-report.json)

## Unchecked source prototype

The timing and correctness evidence above covers the two assembly projections. The experimental Bend source was staged for checking. Its checked API, emitted products, conformance, and self-hosted transport remain unverified. The associated product API, control and emission recipes are prospective. No production compiler path was changed.

The isolated Bend prototype requires at least two syntactic pair call sites to the same defined target and declines array-versionable bodies and raw scalar returns. The retained public function uses its existing result buffer. A new local symbol accepts compact arguments and returns in R10/R11. Name collisions in the function-ID marker disable specialized calls for that context. This structural admission excludes all three BST64 targets in this experiment and selects the lexer's recurrent step worker. The observed number of calls motivates the policy. Input-specific runtime profitability remains empirical. [Bend rules](pair.bend) · [Integration edits](prepare.py)

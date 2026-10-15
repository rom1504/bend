# Phase92: same-source native compiler screen

The own-C native B2 takes **1.203× the request time and 1.444× the process
time** of the upstream-C native B1 across six workloads. This is a matched
compiler-program comparison: identical frozen Bend source, request inputs,
prepared Base, output runtime/effects, Clang executable and O2 flags. All
36 emitted C files match their independent retained oracles.

The [actual report](../../selfhost/build/phase92/screen01/report.json)
(`2bf06b30bf99fe4e6913210b02f75e82578d244da4c362a758afbea4ade753dd`,
661,862 bytes) records two balanced fresh-process rounds, one request per
process and CPU3 affinity. The campaign took 33.003 seconds. Offline review
rehashed all 159 recorded inputs and all 36 outputs, checked actual guards and
clock logs, and independently reproduced every reported median and ratio.
No compiler or benchmark was executed by that audit.

| Workload | B1 request ms | B2 request ms | TS/Bun request ms | B2/B1 request | B2/B1 process |
|---|---:|---:|---:|---:|---:|
| Small | 64.5 | 75.0 | 439.4 | 1.163× | 1.579× |
| Numeric | 110.5 | 127.5 | 536.6 | 1.154× | 1.445× |
| Lexer | 375.0 | 465.0 | 792.1 | 1.240× | 1.366× |
| Map | 1,403.0 | 1,701.0 | 1,153.1 | 1.212× | 1.258× |
| Functions65 | 228.5 | 285.5 | 616.6 | 1.249× | 1.462× |
| Unicode | 60.0 | 72.0 | 417.6 | 1.200× | 1.585× |

Values are medians of two observations per role/workload. Aggregate ratios
weight all six workloads equally using their geometric mean:

| Comparison | Request time | Process time |
|---|---:|---:|
| Native B2 / native B1 | 1.202550× | 1.444469× |
| Native B1 / TS-Bun | 0.312266× | 0.465379× |
| Native B2 / TS-Bun | 0.375515× | 0.672225× |

B2 requests are 15–25% slower than B1 on every selected workload. Both native
stages beat TS/Bun in five cases; Map remains slower: B1 is 1.217× request /
1.230× process, and B2 is 1.475× request /1.547× process. The matched B1/B2 gap
therefore survives holding the Bend compiler algorithm and input fixed. This
screen does not identify which generated-C mechanism causes it.

## Base preparation and clock boundaries

| Native stage | Base decode/preparation, pooled median | Range across 12 processes | Runtime transport |
|---|---:|---:|---:|
| B1 | 59 ms | 57–66 ms | 0–2 ms |
| B2 | 139 ms | 134–158 ms | 1–2 ms |

The roughly 80 ms pooled-median Base difference helps explain why the process
gap is larger than the request gap. These are separately measured regions,
not an additive decomposition of geometric means. Both stages decode the same
authenticated carrier before the request clock. Full C/error/verdict character
consumption is inside the request; consumed-character counts agree between
native stages. Output writes and process teardown are outside the request and
inside process time. Python authentication is outside both clocks.

The TS/Bun reference has a different preparation boundary: it loads/checks
source Base inside its request, while native stages reuse prepared Base. Its
imports are separately recorded; output hashing/writing follows its request
clock. Consequently the TS ratios are useful end-to-end context under the
declared modes, not proof that the Bend compiler algorithm is three times
faster. No warm-process or production CLI ratio is implied.

## Identity, coverage and program-speed limits

Both native compilers run source `d04ad79c…` (1,759,353 bytes). B1 executable
`6bb07e94…` was emitted by upstream `0592662…`; B2 is native07 `d7c7a479…`.
Their compiler-runtime lowering deliberately differs. The request runtime,
Base, five runtime parts, nine effect providers and cache carrier are identical.
The only CLI normalization removes the explicit sentinel for B1, whose upstream
IO.args already supplies its executable head. The same Bend entry receives the
same remaining arguments. See the [method](../../selfhost/tools/performance/phase92/comparison/README.md)
and [checked build receipt](../../selfhost/build/phase92/upstream-b1/build.json).

This screen measures **compiler execution**, not the speed of programs it emits.
Its complete-C identity proves unchanged products on these six sources. The
prepared expanded lane covers 45 closed catalog points from 23 originals and
will additionally execute their outputs; it is a separate qualification until
its report completes.

Even if all 45 products agree, that does **not** transfer the historical C12
runtime ratio (1.067× upstream) to this experiment. Original C12 uses different
batch wrappers and imported modules, which the frozen native entry cannot load.
The closed45 sources and their old execution checks are correctness controls,
not that timed corpus. Exact C under identical runtime/toolchain conditions
supports product continuity between native stages; it supplies no fresh numeric
program-speed ratio or general runtime-parity claim. The original Phase91
JS23/C12 continuity remains separately valid for its explicitly bound products.

Two rounds and millisecond native clocks provide a screening result, without
confidence intervals or a universal speed claim. The six-source selection,
single-Base host, nine effects and one-thread CPU mode remain finite limits.

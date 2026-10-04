# P45-005: private call graphs and explicit continuations

Status: checked worker02 passes the selected controls and six-point execution
screen. It removes generic private calls, but the emitted machine is too large for
V8 to optimize. Tail-frame reuse and component partitioning are the next ablations;
neither is credited with results below. Phase44 remains the installed reference.

The worker model separates values, register assignments, direct private calls,
typed cases and returns. Its lowerer consumes the existing complete contextual
instance graph and retains admission, literal provenance and host guards. Its
printer initially emits one PC dispatcher for the graph: tail calls transfer to
another PC; non-tail calls save the current register vector and return PC. This
handles non-tail mutually recursive helpers without unbounded native recursion.
Native residual calls retain their guarded public implementation. There is no
recognition of benchmark source or export names.

`checked-worker01` passed its selected build checks, but review identified a missing
local native-literal owner check. Worker02 adds
`j_literal_owner(book, wnf(book, ty))` before lowering a compact literal. This is
provenance hardening, not a claim that build01 failed compilation or a measured
performance change. Both snapshots and receipts remain intact. Derived API hashes:

| Attempt | SHA-256 |
| --- | --- |
| `checked-worker01` | `6b5b7b956a48a191cb4b091c8a1fdb1540f561edc742f0fd38e103d3d14c98bf` |
| `checked-worker02` | `e4e25984a43bb15706af190e9d18b13c5f21a2e6521b8c4173f244b1023e95ec` |

Worker02's selected paired validation has 36 passing probes and zero exact
differences. `qualify-worker02/report.json` passes all eight maintained suites:
IR, backend, global initializers, choice, arm, primitive guards, provenance and
foreign values. The report includes 37 IR checks, 72 arm observations, 1,129 guard
checks plus 25 observations, and ten checked provenance constructors. These are
selected controls, not full-language qualification or installation.

The six-source acquisition emits one new machine each for Map and record
aggregation. Lexer uses the projection improvement; BST, list pipeline and closure
output remain byte-identical to the Phase44 control. Machine presence is static
evidence; the separate CPU profiles below also observe execution of both machines.

`runtime-worker02/report.json` completed all 54 samples in 44.74 seconds. The
60-second preset uses three fresh rounds per role, rotated role order, at least
350 ms warmup and a 150 ms target. Node 24.18.0, CPU 3, a 1,024 MiB heap and
2,048 MiB process-tree/free-memory limits match the campaign protocol. TypeScript
is pinned at `018751270e800bc222a93dad7f257083ee53a5f7`; baseline is Phase44 checked04.

| Point | TS ms | Phase44 ms | Worker02 ms | Phase44 / worker02 | Worker02 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Lexer | 1.695542 | 13.105716 | 7.923490 | 1.6540× | 4.6731× |
| Map churn 128 | 0.782691 | 22.700096 | 12.730704 | 1.7831× | 16.2653× |
| Record aggregation 256 | 1.284932 | 101.000133 | 48.718614 | 2.0731× | 37.9153× |
| BST 64 | 0.052464 | 0.128984 | 0.127904 | 1.0084× | 2.4379× |
| List pipeline 512 | 0.031167 | 0.015256 | 0.015750 | 0.9686× | 0.5054× |
| Closures 256 | 0.022530 | 0.010161 | 0.010362 | 0.9806× | 0.4599× |

Record candidate samples are 48.9120, 18.6337 and 48.7186 ms: two distinct timing
states, despite modest within-sample drift. Its median is not evidence of a stable
regression against the separate String-only experiment's 29.8226 ms. Different
runs cannot isolate that comparison. Map's baseline still has roughly −30% to −33%
within-sample drift. These screens guide the next ablation; they do not settle a
full-corpus gain or attribute every change to the worker.

`diagnose-worker02b/report.json` completes 12 independent CPU/allocation profiles
in 19.44 seconds: two points, three roles and two profile kinds. Instrumented
execution is diagnostic only. The first diagnostic invocation omitted the Phase37
catalog and rejected selection before executing a target; its preserved
`job-diagnose-worker02` receipt is not a semantic or performance failure.

The decisive finding is in each raw candidate CPU profile's `$worker` node:
`deoptReason` is **`Function is too big to be optimized`**. Map node 16 and record
node 15 carry this reason. Thus oversized emission is an observed optimization
failure, not merely a guess based on source length. Worker plus entry-wrapper
self samples account for about 87% of both candidate profiles; attribution between
those two frames does not identify individual Bend helper costs. Generic
apply/invoke machinery is no longer the leading sampled cost.

| Static worker surface | Map | Records |
| --- | ---: | ---: |
| Functions in machine | 52 | 52 |
| Dispatcher bytes | 71,046 | 71,939 |
| PC cases | 727 | 732 |
| Private transfers allocating a register vector | 168 | 166 |
| Non-tail continuation pushes | 99 | 98 |
| Tail transfers | 69 | 68 |
| Literal-true tuple/Char case tests | 64 | 65 |
| Residual native call sites | 14 | 18 |

These are static sites, not execution frequencies. All private calls inside the
machines are PC transfers; residual native sites are String.append, U32.cmp and
Nat arithmetic/comparison. They retain semantic checks and should not be replaced
by unchecked JavaScript arithmetic.

Allocation sampling estimates about 21.11 MB per Map invocation and 25.94 MB per
record invocation, versus TypeScript's 2.18 MB and 2.67 MB respectively. Normalize
by each profile's own repetition count; these estimates include the profiled
validation loop and are not exact allocation counts. Approximately 92% of
candidate allocated bytes are attributed to `$worker`; constructor support is
3.14% for Map and 4.17% for records. This combines register vectors, field arrays
and any inlined allocations; it does not prove that every byte is a call frame.
GC self time is only about 3%, so eliminating collections alone is insufficient.

The next general transformations are:

1. Reuse the current register vector for tail transfers. Evaluate every argument
   before writing any slot, preserving permutations and parallel argument values.
   Register vectors never escape into Bend values or native calls.
2. Partition the exact private-call graph by strongly connected components. Keep
   explicit continuation machines within recursive components and use direct
   calls between components. The component graph is acyclic, bounding additional
   native call depth by admitted component count. Static analysis finds 48 Map
   components and 47 record components; the largest is about 16.6 KB, over four
   times smaller than the whole machine. This is a size prediction, not a speed
   result.
3. Remove proven literal-true branches and simplify local constructor/projection
   pairs. Follow with frame reuse or liveness only if the next profiles justify it.

The new graph pass uses three U32 bitsets per row, admits at most 96 functions,
validates every direct target in both branches, and computes exact transitive
closure with one pivot per function. It returns failure for an oversized or
invalid graph, never treats unfinished reachability as proof of acyclicity.
Execution and adversarial controls must qualify partitioned output separately.

All raw paths above are under `selfhost/build/phase45/`. They are campaign receipts,
not public artifact links; no earlier phase's raw evidence was modified.

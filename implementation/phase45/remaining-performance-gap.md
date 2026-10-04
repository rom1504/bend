# Remaining execution gap after the full worker23 comparison

The completed 45-point comparison makes overall execution **1.977× faster** than fresh Phase44 output, but still **3.079× slower than pinned TypeScript** with equal-point weighting. Equal-source weighting is 4.147× TypeScript; family weighting is 4.734×. All 669 samples pass. Full semantic qualification and installation remain separate; this is execution evidence, not a release claim. See [all 45 medians and the diagram](results.md).

## Larger private graphs are much closer

| Point | Phase44 / worker23 improvement | Worker23 / TypeScript |
| --- | ---: | ---: |
| Records64 | 42.929× | 1.619× |
| Records256 | 41.473× | 1.605× |
| Map churn128 | 15.040× | 1.538× |
| Active ray256 | 13.886× | 1.843× |
| Original raytrace | 10.586× | 1.741× |
| Unicode64 | 8.395× | 2.679× |
| Lexer | 4.847× | 1.472× |

Complete private graphs amortize guarded entry across substantial computation. Explicit calls/matches replace generic descriptor dispatch; SCC partitioning avoids giant generated functions; bounded native recursion and tail loops reduce continuation vectors; Number-Nat removes internal BigInt work; direct constructors remove helper calls and temporary field arrays. These mechanisms have independent intermediate evidence, but the final table measures their combined effect.

Profiles from earlier candidates suggest remaining internal allocation, live-register/frame size and ordinary acyclic calls as useful targets. Fresh worker23 profiles would be needed to rank their current contributions. Existing producer/fold/fusion implementations retained by typed ranking should migrate into reusable worker passes so the general backend inherits their compact execution without displacing proven faster plans.

## Generic paths and small public boundaries dominate the remaining ratios

| Point | Worker23 median µs | TypeScript median µs | Ratio |
| --- | ---: | ---: | ---: |
| Morning | 198.779 | 3.279 | 60.614× |
| Scalar region, zero work | 4.043 | 0.067 | 60.117× |
| Complete generic row32 | 394.599 | 6.782 | 58.181× |
| Map/Set operations | 1,166.426 | 20.515 | 56.857× |
| RLE roundtrip | 31.776 | 0.563 | 56.415× |
| Evening | 130.006 | 2.636 | 49.328× |

These are warmed repeated-execution windows, not module-import timings. A tiny TypeScript denominator can magnify fixed public-call cost, as in the zero-work scalar case. Other gaps include substantial real computation: generic row and Map/Set still take hundreds of microseconds or more. Source inspection shows unsupported function-valued arguments, Array operations, Map payload/result shapes and public object boundaries keep parts of these graphs generic. The measured ratios alone do not isolate exclusive causes.

The nullary implementation helps RLE and Map/Set, but the longer final windows show smaller combined gains than short screens: 1.143× and 1.275× against fresh Phase44. Morning/evening remain effectively flat. Canonical Unit coverage is independently demonstrated; it did not change those previously acquired corpus modules, so it earns no isolated speedup claim there.

## Preserve useful boundaries instead of adding a worker to every helper

Worker17b's long comparison exposed a major regression from wrapping a two-function acyclic scalar helper called twice per row cell. Worker18 restored its old output through a general profitability gate requiring recursive work for new alias-only public roots; acyclic callees inside an admitted graph remain optimized. Worker20 reopened acyclic admission with smaller primitive fences and still slowed the row 5.15×. Full host/String validation and exact public-call bookkeeping remain plausible fixed costs; that ablation did not independently profile each contribution.

The useful next direction is broader complete-graph coverage behind one guarded entry: local-function applications, Array/native operations and owned result reconstruction, each with refusal, mutation, demand and aliasing controls. Public reconstruction must preserve identity/sharing and externally mutable layouts. Admission alone is insufficient: use the maintained fast-five canaries first, then representative screens, then a complete comparison.

Worker23 preserves the profitability repair and fixes six supported post-import host-hook observations found on22. That correctness repair retains public `.code`, `.call` and `.env` observations while making `invokeExact` preflight use private captured intrinsics. It does not remove the source/native/host guards that authorize private execution.

Thirty-two final medians improve and 13 regress; the largest increases are generic row 4.93%, one Mandelbrot-grid point 4.12% and bitonic 3.15%. No statistical-significance claim is made. Two points—closures256 and list-pipeline512—already beat TypeScript at 0.477× and 0.572×, but that does not establish overall parity. These maintained fixtures informed development, half-window drift remains, and their distribution is not every Bend program.

Evidence: [complete execution report](results.md), [typed selection](../../experiments/phase45/P45-016-root-plan-ranking.md), [acyclic policy](../../experiments/phase45/P45-018-acyclic-root-profitability.md), [rejected readmission](../../experiments/phase45/P45-020-acyclic-reentry-ablation.md), [nullary ABI](../../experiments/phase45/P45-021-nullary-abi.md), [Unit coverage](../../experiments/phase45/P45-022-canonical-unit.md), [exact-entry repair](../../experiments/phase45/P45-023-exact-entry-preflight.md).

## Existing wrapper-registration boundary: static finding only

`exactCode` still calls live `exactCodes.add(code)` in
[runtime core](../../selfhost/src/runtime/js/core.mjs). That statement is unchanged
in frozen workers19,22 and23 and already appears in commit `6cbd0a1`.
[The inherited worker emitter](../../selfhost/src/back/js/worker.bend)
creates some exact wrappers after import: `j_nat_loop_wrapper` does so inside a
delayed `Succ` arm (line135), and `j_nat_branch_public_prefix` does so when
returning a final Bool function (line334). An ordinary `fn` allocation is a plain
descriptor object and does not itself register with a WeakSet.

The actual worker23 `numeric-recurrence.mjs` has this delayed wrapper for
`p37.numeric`. A minimal next probe is a legal staged call
`call(G['p37.numeric'], [1n])` after replacing `WeakSet.prototype.add` with a
recording native delegate, restoring the property in `finally`; compare the
partial descriptor and events with Phase44 output, then separately try a
throwing sentinel. Static inspection predicts a registration hook before the
new wrapper's body guard in both versions. This probe has **not run**: no runtime
failure, new worker23 regression or release blocker is claimed. The six executed
worker23 preflight controls establish their stated scope, not universal
equivalence under every host mutation.

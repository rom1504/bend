# Phase42 selected16 profile findings

**General parity was not reached.** The final 45-point geometric mean runtime
ratio to pinned TypeScript falls from 12.569× (Phase41) to 8.862× (selected16).
Tree gains roughly 6–8×, BST24–27×, and list2.7–6.6× against Phase41; Map and
lexer still sit near 90× TypeScript. These runtime conclusions come from the
ordinary throughput [batch1](../../selfhost/build/phase42/integration03/runtime-batch1/report.json),
[batch2](../../selfhost/build/phase42/integration03/runtime-batch2/report.json) and
[batch3](../../selfhost/build/phase42/integration03/runtime-batch3/report.json),
not from profiler wall times.

All 36 captures passed: six programs × three roles × CPU/allocation. Reports:
[tree](../../selfhost/build/phase42/integration03/profiles-tree/report.json),
[list/BST/Map](../../selfhost/build/phase42/integration03/profiles-list-bst-map/report.json),
[lexer/raytrace](../../selfhost/build/phase42/integration03/profiles-lexer-ray/report.json).
Every profile module hash was checked against its same-role final 45 batch module;
these diagnostics use the actual selected16 image. CPU sampling is1ms. Allocation
sampling is32KiB, or256KiB for raytrace, and includes collected objects.

## Allocations normalized by completed calls

Each number below is the report's integer `summary.totalWeight` divided by its
`repetitions`, displayed to two decimal places. These are V8 **estimated allocated
bytes/call**, not exact object counts, retained memory or RSS. Ratios normalize
call counts; raw sampled totals alone cannot compare roles.

| Point | TypeScript B/call | Phase41 B/call | Selected16 B/call | Selected/TS | Phase41/selected reduction |
|---|---:|---:|---:|---:|---:|
| Tree [8,0] | 1,362,031.15 | 4,816,836.94 | 1,489,610.58 | 1.09× | 3.23× |
| List [512,123] | 93,953.93 | 503,010.36 | 14,009.13 | 0.15× | 35.91× |
| BST [64,17] | 391,966.84 | 15,946,340.84 | 1,085,337.49 | 2.77× | 14.69× |
| Map [128,123] | 2,202,457.21 | 107,626,337.60 | 107,008,409.60 | 48.59× | 1.01× |
| Lexer [8,0] | 3,938,343.84 | 224,980,920.00 | 222,592,354.67 | 56.52× | 1.01× |
| Raytrace [80,0] | 9,241,040.50 | 662,884,808.00 | 687,038,312.00 | 74.35× | 0.96× |

Allocation repetitions (TS/Phase41/selected) were tree 1222/162/851,
list 5821/2870/26059, BST 6510/38/974, Map 385/5/5, lexer 244/3/3 and ray 16/1/1.
The expensive points have few calls: especially ray's single-call estimates
cannot establish a small allocation regression. Profiling encloses invocation,
validation and loop control; import and warmup are outside. Estimates include
harness/runtime allocation, and report warnings retain unattributed samples.

## Remaining hot paths and generated code

- **Tree:** candidate self CPU samples concentrate in `warp$tree$hybrid`41.35%
  and `flow$tree$hybrid`17.39%; warp accounts for70.74% of estimated allocation.
  GC contributes10.68% of CPU. Allocation now approaches TS (1.09×), while the
  ordinary tree8 runtime remains1.223× TS. Flat owned fields and bounded hybrid
  recursion removed much generic dispatch; remaining work is chiefly the actual
  warp/flow traversal and its fresh result allocation. Static source-owned calls
  increase503→602 and bytes29,624→53,423, while trampoline sites decrease105→76:
  the larger specialized graph is faster, not syntactically smaller.
- **List512:** actual fusion reduces estimated allocation roughly35.90× versus
  Phase41 and runs0.605× TS at this point. `regionHostGuard` is40.75% self CPU,
  `scalarGuard`15.31%, and the root body22.81%. Descriptor queries account for
  about79.5% of allocation, with scalarGuard another12.38%. Fused arithmetic
  leaves boundary validation as the prominent fixed cost. Source-owned calls
  fall653→566, trampoline sites112→88, conversions32→16. This is an opportunity
  for cheaper equivalent guards, not authority to cache mutable facts across calls.
- **BST64:** selected runtime is6.651× TS despite26.96× improvement. `bst.down`
  is26.24% self CPU and72.27% of allocation; `apply` is19.65% self CPU, with
  `invokeExact`4.69% and `force`3.91%. The residual `p37.bst.build` path is still
  generic. Native product/List construction helped, but temporary product/path
  allocation and generic build/insertion dispatch remain. Static source-owned
  bytes grow4,534→20,144 and trampoline sites52→77; scalar root proof opens useful
  inner workers while leaving an expensive generic prefix.
- **Map128:** selected runtime91.39× TS and allocation48.59× TS; neither moves
  materially from Phase41. Post-runtime/source-owned syntax inventories are
  identical between Phase41 and checked16. Self CPU remains `invokeExact`21.28%,
  `apply`20.36%, generic matcher closures22.88% combined, and `force`8.02%.
  Allocation is spread through application, projection, continuations and forcing.
  Existing Phase42 specializations have not reached this source graph.
- **Lexer:** runtime90.81× TS and allocation56.52× TS. `apply`26.95%, `force`
  11.63%, `invokeExact`9.53% and `callOwned`7.73% self CPU dominate. Some private
  code was added (source-owned bytes12,083→26,535), but it did not remove the
  central generic string/matcher/continuation path. More emitted functions alone
  do not establish useful admission.
- **Raytrace:** runtime19.76× TS, with allocation around74.35× TS. `apply`28.53%
  and `enterExact`11.36% self CPU lead; residual `nearest`, matcher and callOwned
  paths remain. Generated source grows53,172→91,648 bytes and trampoline sites
  344→369. The one-call allocation sample suggests generic dispatch/data shells
  remain costly; it does not isolate a causal cost of the added specialization.

## Next priorities

First target Map/lexer's actual generic hot closure: obtain a tiny source-valid
activation discriminator, full value/alias/observer controls and one precise
saved-JS experiment before extending proof domains. For BST, isolate generic
build/insertion dispatch from down-step product/path allocation; retain exact
Nat bounds, duplicate ordering and deep iterative fallback. For tree, investigate
fresh warp allocation/liveness only with a measured discriminator: earlier lazy
stack/pruning and helper hoisting experiments did not justify source promotion.
List's equivalent descriptor/host guard cost is a smaller, clearly identified
opportunity, with mutable dependencies revalidated at each entry.

Self/inclusive samples locate work; inclusive shares overlap and must not be
added as independent savings. These profiles support prioritization, not causal
claims about any single patch. Static sites do not reveal executed allocation or
admission frequency. Actual source/guard/domain controls and balanced unprofiled
throughput remain the promotion gates.

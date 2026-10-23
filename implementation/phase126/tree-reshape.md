# Tree reshape: real work removal, no runtime win

**Reject both timed variants from the final compiler.** The checked transformation eliminated the intended allocator traffic, but three matched tree cases regressed. The important distinction is that fewer allocator calls did not establish fewer fresh heap cells, better locality or faster execution.

The source certificate recognizes the general owning equation `(C(a,b), C(c,d)) -> C(C(a,c), C(b,d))`, independent of source function/constructor names. It authenticates the closed recursive constructor and exact ordered field uses. The whole worker first attempts raw, dynamic, distinct-shell reuse; zero preserves both operands and executes the complete original body. Four fields are snapshotted before mutation. No benchmark source or oracle changed.

## Measured results

Both actual-source admissions (`warp_zip`, independently renamed `hedge.cross`) passed equation/type checks. Source24 passed 18 finite structural/import/hygiene controls and the ordinary owning-tree/String fixture, including retained roots, same-argument aliases, retained payloads, static inputs and wrong tags. These are focused checks; source24 received **no broad 45 or native N1/N2 qualification**.

Clean screens used three rounds, the frozen wrappers, aligned QBE builds, one CPU and complete output/count checks. Each table cell is candidate/baseline median milliseconds; the screen baseline is qualified Phase125, not upstream. These are tree-family results, not whole-corpus ratios.

| Case | Raw reuse + generic outer constructor | Raw reuse + fixed2 outer constructor |
|---|---:|---:|
| tree-bitonic |1072/1028 =1.043×|1058/1024 =1.033×|
| depth6, seed17 |1097/1013 =1.083×|1189/1113 =1.068×|
| depth9, seed123 |907/873 =1.039×|886/886 =1.000×|
| Geometric mean |**1.05470×**|**1.03345×**|

Fixed2 remained 4.90153× upstream on these three cases. The two screens occurred separately; their difference is not a paired estimate of generic-versus-fixed2 helper cost. Neither demonstrated a gain against its own matched baseline.

Evidence: `selfhost/build/phase126/reshape-screen24/report.json` and `reshape-fixed2-screen01/report.json`. The fixed2 variant changes exactly one helper return expression to the existing `p125_rt_ctor2`; compiler24, QBE, ownership guards and sealing remain identical.

## Counts falsified the refusal hypothesis

The separate instrumented pair linked parent combined17 and source24 against **the same diagnostic runtime object**, with unchanged arguments `--threads 1 --gpu off -- 1 0 8 0`. It checked complete stdout through the original Phase112 oracle after removing exactly one diagnostic stderr record. Counts cover the entire process, including wrapper validation/readback; they are not timing evidence.

| Whole-process counter | Parent17 | Source24 | Removed |
|---|---:|---:|---:|
| Heap allocation requests |30808|19548|11260|
| Constructor materializations |30759|19499|11260|
| Consuming constructor takes |30758|19498|11260|
| Fields handled by takes |63553|41033|22520|
| Wrapped takes |14|14|0|

All 5630 reshape attempts succeeded; all refusal counts were zero. Exactly 11260 shells were reused. Per-CID comparison attributed every constructor/take delta to the authenticated Node constructor; other constructors were unchanged. Node constructor requests fell 29692→18432, **37.92%**, while total constructor requests fell 36.61%.

Evidence: `reshape-count-pair01/report.json`, including raw stdout/stderr, pins, exact source reversibility and per-CID invariants. This disproves low raw-guard hit rate as the explanation. The RFC1-capable variant was independently reviewed and built as `reshape-runtime02`, but **not timed**; it was deferred once counts showed no refusals to recover.

## What the static machine evidence explains—and does not

1. **The baseline already recycles these shells.** `runtime-verified01/runtime.c:776–805` implements allocation as a per-class LIFO pop and free as a LIFO push. The original successful `warp_zip` takes/free two raw nodes, then calls the fixed2 constructor three times. On the ordinary local-freelist path, the first two allocations immediately recover those two freed cells. Both algorithms therefore have the same net live-node change, +1. The counters prove removal of allocator bookkeeping and calls, not removal of 11260 fresh backing allocations or a smaller output representation. Bank/handoff misses were not counted separately.

2. **The new guard is substantial machine code.** The QBE caller still reserves its 2048-byte scratch frame and saved registers before calling the helper (`program.s:802`). The helper saves six registers, reserves 88 additional bytes, checks constructor metadata/tags/raw flags/dynamic distinct addresses, and dispatches sealing before another constructor call. Fixed2 removes the generic outer-constructor route but retains those checks and call boundary. This is observed overhead, not proof that it accounts for the entire slowdown. The original path also has runtime calls and checks, so counting new instructions alone would be misleading.

3. **Physical tree placement changes.** When no freelist handoff intervenes, freeing first input A then B means original construction allocates its first inner node at B and second at A. The reuse helper places them at A and B respectively. Logical output is identical, but subsequent traversal follows a different address arrangement. Cache/locality effects are a plausible competing explanation; no cache-miss or cycle attribution was collected here. Code layout effects likewise remain unmeasured.

Pinned static extracts and linked disassembly: `selfhost/build/phase126/reshape-static-audit01/manifest.json`. Those artifacts were produced by read-only host disassembly, not by running target programs.

The useful result is a rejected, fully activated allocation optimization with exact work accounting. Stop adding guards or RFC cases to this experiment. If this category is revisited, first distinguish allocator fast-path cost from fresh allocation/cache cost and compare a representation or call-boundary change with a cheap decisive test; the present evidence does not justify retaining the extra optimizer complexity.

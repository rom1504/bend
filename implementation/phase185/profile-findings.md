# Phase185 baseline generated-program CPU profiles

All six pooled profiles pass the maintained sample-quality gate. The
[campaign](../../selfhost/build/phase185/baseline-profile01/report.json) completed
in55.77s using unchanged Phase184 products, one CPU3 lane and two sample periods
(8ms/13ms). All12 captures match their complete result/warmup/repetition/elapsed
output contracts; no inputs changed. No compiler or generated program was run
while preparing this analysis.

| Fixed workload | QBE samples | C samples | Leading QBE physical costs | Leading C physical costs |
|---|---:|---:|---|---|
| map-churn-128 | 826 | 876 | Borrowed `Map.bit.go`12.0%; constructor helpers9.2%; take helpers11.4%; dispatch/transport17.3% | `Map.bit.go`21.8%; `Map.seek.go`11.6%; `term_drop`9.2%; `span_fade`6.1%; `Map.ins.go`6.1% |
| tree-bitonic | 789 | 811 | Constructor helpers18.1%; take helpers16.0%; dispatch/transport16.6%; private `warp`9.0%; `p111_rt_op`6.1% | `warp_zip`24.2%; `warp`15.8%; `warp_leaf`14.7%; `flow`10.0%; two anonymous continuations17.9% |
| raytrace | 868 | 876 | Private `colf`51.1%; two nearest-hit functions23.7%; frame helper7.0%; keep helper4.8%; `colf.px` variants9.2% | Two anonymous continuations50.4%; nearest-hit functions26.9%; `colf`15.8%; `colf.px`4.0% |

Shares use the comparator's period-weighted denominator and retain unknown
samples. Constructor helpers mean `p125_rt_ctor*`, take helpers mean
`p125_rt_take*`; dispatch/transport is `work_loop.constprop.0`, `p111_rt_jump`,
`p111_rt_return`, `p111_rt_frame` and `p111_set_regs`. These groups do not overlap.
Physical leaf costs differ from inclusive function costs: an inlined operation
appears in its generated caller, and a helper's callees appear separately.

Every pool exceeds500 accepted samples; all captures have zero drops/overruns,
plausible delivery, complete thread lifecycle and at least99.926% capture-window
coverage of child CPU. Several individual captures have fewer than500 samples;
their compatible pools meet the gate. QBE uses the main-thread collector; C uses
the maintained pthread collector. Unknown period-weighted shares are7.88% for
QBE map and6.69% for QBE tree, predominantly unresolved libc leaves; ray and all
C profiles have none. Do not assign those libc samples to a guessed helper.

This was sample-only: **there are no new clean runtime ratios, independent clean
CPU denominators, allocation counts or dispatch event counts**. The profiler
correctly suppresses absolute clean-CPU estimates. Relative shares locate work;
they cannot establish the exact QBE/C gap or an optimization's speed effect.

## Constructor-cache inlining budget

If an ideal change removed **all physical time inside the verified constructor
helpers** and changed nothing else, Amdahl's calculation gives:

| Workload | `p125_rt_ctor*` share | Ideal time reduction | Ideal speed factor |
|---|---:|---:|---:|
| map-churn-128 | 9.21% | 9.21% | 1.101× |
| tree-bitonic | 18.11% | 18.11% | 1.221× |
| raytrace | No observed samples | No observed constructor budget | Not established |

This is a conditional deletion-only budget, **not a rigorous upper bound on
general inlining or a predicted gain**. Constructor-cache inlining retains field
writes, allocation/refill and any required sealing; it removes only part of that
work. Conversely, caller optimization, layout effects and unassigned callees can
change time outside these helpers. Zero observed ray samples does not prove a
zero true cost. Across the two periods, aggregate constructor-helper fractions
were7.7–10.7% for map and15.0–21.3% for tree, so the pooled percentages are not
precise confidence bounds.

The results make tree the strongest constructor-cache candidate and map a
plausible transfer check. Constructor inlining alone cannot be assumed to close
the larger map/tree QBE/C gaps from Phase184. Their takes and dispatcher/register
transport remain substantial separate targets. C tree execution is concentrated
inside generated kernels, consistent with more of those operations being
integrated there; this profile does not prove which lowering change caused the
difference. C map still spends15.3% in drop/fade, so ownership work remains even
in that faster baseline.

Ray is a separate problem: QBE spends most time in `colf` and traversal work,
with visible continuation/keep overhead. The retained QBE for `colf` contains
repeated scratch/register/continuation transport around its recursive tree.
Nearest-hit arithmetic accounts for23.7% of QBE physical time; these samples do
not support treating the entire ray gap as constructor allocation or float math.
The C anonymous continuations remain explicitly unnamed rather than being
assigned source owners from their numeric names.

## Attribution and evidence

All six QBE attribution reports authenticate the actual ELF segment pointers.
The owner maps are conditional lexical groupings; producer provenance is
explicitly unverified, with no current emitter-source pins and no source map.
No dispatch context or physical caller was collected, so a runtime leaf cannot
be charged to a particular active Bend definition. This does not claim that
today's edited compiler produced the retained baseline.

- [QBE comparison](../../selfhost/build/phase185/baseline-profile01/bend-qbe/comparison.json), SHA256 `7434a146649ae556121bdb74ec93fb45714a9378708aa56daaa1e56801f6d01e`.
- [C comparison](../../selfhost/build/phase185/baseline-profile01/bend-c/comparison.json), SHA256 `eeb5d8a60ea0473ebf1c8f6791f429eb8afae9211fd93298ae155b3ddf655918`.
- [QBE capture receipts](../../selfhost/build/phase185/baseline-profile01/bend-qbe/capture/report.json) and [C capture receipts](../../selfhost/build/phase185/baseline-profile01/bend-c/capture/report.json) pin every observation, executable, independent oracle and analysis.
- [Representative QBE owner binding](../../selfhost/build/phase185/baseline-profile01/bend-qbe/attribution-0/report.json) records the exact provenance limits.

## Assembly array-path follow-up

The [array-x86 local-fold profile](../../selfhost/build/phase185/array-profile02/plan/comparison.json)
uses the original `(4096,17)` input,16000 repetitions and4 warmups. The
[controller](../../selfhost/build/phase185/array-profile02/controller/report.json)
completed in10.75s with exact output and no changed inputs. Both captures pass
loss/delivery/coverage checks; the8ms/13ms pool has520+321=841 samples,
zero unknowns/drops/overruns and at least99.930% capture-window CPU coverage.

**840 samples,99.844% of period-weighted CPU, land in
`p113d_FID_$product.fold.loop`.** The remaining sample is
`blk_new.constprop.0` (0.156%). There are no observed
`p117v_FID_$product.fold.loop` fallback samples. The measured computation is
overwhelmingly in the fast-body symbol; fallback execution is not a supported
explanation for this kernel's remaining runtime. Investigate the fast body's
machine code next. Zero sampled fallback time is not proof of zero fallback
invocations, and no dynamic entry counters or clean timing denominator exist.

Both attribution reports authenticate116 linked FIDs and178 function symbols.
The candidate's machine-only `native.py --ir` receipt has no compiler request,
so the owner map deliberately omits producer-receipt/source-map claims and
retains conditional lexical grouping. Exact physical symbol placement is
established; no logical call stack or active-dispatch cost attribution is implied.

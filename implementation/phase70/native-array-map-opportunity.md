# Array-map: restoring representation permission helps; loop products remain

## Measured compiler02 checkpoint

The checked Bool admission is now implemented in compiler02. Root's balanced
saved-binary comparison measured **1.385× faster execution than Phase69 B1** on
this Array-map case, with **2.468× upstream execution time** still remaining.
This is one workload, not the original six-family or broader coverage geomean.

| Role | Three measured intervals | Median |
| --- | --- | --- |
| Phase69 B1 | 1022, 1028, 1010ms | 1022ms |
| compiler02 B1 | 738, 732, 751ms | 738ms |
| Pinned upstream | 299, 299, 327ms | 299ms |

Each interval uses 15,360 measured repetitions and 15,360 warmups with identical
source and Clang settings. Roles rotate over three rounds. All nine intervals
passed the independent base/warm/measured digest and 100ms timing floor. The
comparison excludes emission and C compilation. The exact measurement is
`selfhost/build/phase70/compiler02-array-map-comparison/report.json`, SHA-256
`9080ffa4849ede8388cd9953703f9cdfe8856142d3d9a8e04280230a1372c89a`.
This whole-version comparison includes the observer/compiler02 changes; it is
not a controlled isolated attribution of every saved millisecond to Bool alone.

The new [C inventory](../../selfhost/tools/performance/phase70/coverage/array-map-shape-v2.json)
shows the intended structural effect: typed scalar parameters, scalar arrays,
unshared arrays and cold user constructors all change from permission 0 to 1.
The runtime's later `#ifndef` zero defaults are inactive. As a result,
`native_array_get/set` select direct locations and packed 32-bit accesses,
without generic element retain/sink/seal paths; private NF_SCALAR parameters
become u32. Narrowing Bool did not authorize shared arrays: the independent
shared-alias control still requires unshared permission 0.

Both specialized map-loop bodies are **byte-identical before and after this
change**, including their signatures before preprocessing. Each retains one
`heap_alloc`, one `ctr_take` and two `rfc_seal` sites around the two-field Tuple
transporting the input array and current element. Upstream's corresponding
loops retain no such sites and pass those components as separate parameters.
The remaining general opportunity is therefore product transport across loop
parameters and call/return boundaries, with ownership preserved. The already
admitted scalar path gives a cleaner fast loop for evaluating it.

These are lexical sites, not an executed allocation profile: Clang may inline
or simplify code, and remaining list conversion/folding also costs time. A
product prototype should first prove that these recurring Tuple sites disappear
from emitted hot loops, then use the same frozen workload and independent
digest. It should not promise that removing them alone closes 2.468× to parity.
Candidate C is 1,072,812 bytes / 35,674 lines, slightly larger than the Phase69
file despite faster execution; source length is not the hot-path cost metric.

The historical source diagnosis below explains why this experiment was chosen.

## Initial diagnosis before Bool admission

The strongest source-level lead for the new Array-map gap is **a whole-program
fallback triggered by an intermediate `Array<Bool>`**. The compiler already has
packed array and typed scalar machinery, but this program loses both. A second
visible cost is boxed loop state. This is inspection of immutable emitted C,
not a profile or a demonstrated decomposition of the preliminary **3.44×**
[calibration ratio](native-coverage-baseline.md).

## Concrete differences

Both outputs implement the same repository `Array.map` pipeline, with two
1024-element maps and a final array-to-list fold. The mappings are specialized;
this is not principally an unknown-lambda dispatch problem.

| Mechanism | Phase69 B1 output | Pinned upstream output |
| --- | --- | --- |
| Element layout | `NATIVE_SCALAR_ARRAYS=0`; 64-bit Term slots throughout | Both U32 and Bool arrays use packed 32-bit slots |
| Array access | `term_peek`, element `blk_keep`, overwritten-value sink and `rfc_seal` | `BLK_SHR=0`, direct location and scalar `blk_read/write` |
| Private scalar parameters | `NATIVE_TYPED_SCALARS=0`, so `NF_SCALAR` becomes Term | Index and current element are explicit `u32` |
| Map loop state | Input array/current element transported as a heap Tuple | Array and element travel as separate loop parameters |

The [source inventory](../../selfhost/tools/performance/phase70/coverage/array-map-shape-v1.json)
pins both C files and the exact selected function bodies. Selfhost
`Array.map.go~0` and `~1` start at lines 14357 and 15092, with one `heap_alloc`, one
`ctr_take` and two `rfc_seal` sites in each loop body. The corresponding upstream
`spin_6` and `spin_7` start at lines 1368 and 1406 and contain no such sites: they
pass the array and element independently into the next iteration. The source
therefore predicts per-element Tuple traffic in both selfhost maps; counters or
machine-code inspection are still needed to establish its executed cost.

The total C files are 1,068,151 versus 130,945 bytes. This is emitted source size,
including runtime, scheduler fallback and helpers—not an executable hot-code
size measurement or an explanation of the elapsed-time ratio.

## Why the earlier optimization declined

In [scalar-array.bend](../../selfhost/src/back/native/scalar-array.bend),
the earlier `ns_scalar` accepted trusted Base U32/F32/Char, but excluded Bool. The reachable
specialized maps require `Array.new/set/get` with Bool elements, so the
whole-program packed certificate necessarily fails. There could also be other
refusal reasons; no analysis query has been executed here.

`nc_compile_checked` uses that same `packed` flag for `NATIVE_TYPED_SCALARS` and
`NATIVE_SCALAR_ARRAYS`; its `unshared` flag additionally depends on `packed`.
Thus one unsupported element type also removes typed private parameters and
direct array locations elsewhere in the program. The emitted first five macros
confirm this fallback. By contrast, upstream's `lay_arr` and `arr_op` derive
storage and owned fields from each element layout. The prior
[Phase68 array investigation](../../research/phase68/array-after-products15.md)
already isolated packed storage and sharing as meaningful costs on a different
workload. Those old speedups must not be transplanted to this case.

## Original experiment proposal, now completed above

First investigate **checked Bool admission to the existing packed certificate**.
This is a general type rule: current constructor lowering already emits trusted
False/True as 0/1, and private scalar classification already treats Bool as W32.
The experiment must verify all checked producers/consumers, leaf/node patterns,
cloning and sharing, while preserving raw/foreign/unknown fallback. Width alone
must not authorize unshared access. It should also report whether other
certificate refusals remain instead of assuming the allowlist is the only one.

Then compare the resulting emitted shape and the unchanged saved-binary fast
loop. A separate product-parameter experiment can remove the array/value Tuple
from the two map recurrences; upstream demonstrates the intended general form.
Changing both mechanisms at once would make attribution weaker. Longer-term,
separate independent certificates so a boxed or unknown array does not disable
unrelated scalar optimizations across the whole program.

No gain estimate is justified by these source counts. Neither the dominant
runtime fraction nor residual list-conversion cost has been measured. This
inspection identifies a concrete, reusable opportunity; it does not implement
it, run targets, or change the observer integration critical path. List
pipeline's separate 2.14× calibration gap remains unexplained by this array rule.

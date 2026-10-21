# Phase119 numeric machine-code refresh

Offline audit at HEAD `6315f14182d887d4a7365b3977817cb995807505`. No compiler,
generated target, benchmark or profiling process was run by this audit. Root's
new measurements are distinguished from static inspection below.

**The central numeric kernels have mostly not changed since Phase116.** Their
old structural explanations remain relevant; old sample percentages must still
be replaced with the new profiles. The strongest unresolved opportunity is
preserving numeric representations and identities across a complete private
region, rather than another runtime-helper spelling change.

## Authenticated scope

[Supporting JSON](numeric-audit.json) verifies the selected Phase118 safe03
source/API/runtime against `implementation/phase118/selection.json`, verifies
the exact QBE bridge to the timed float01 producer for the four inspected cases,
and hashes retained assembly, objects, executables and reference C. Build inputs
including QBE1.3, assembler and GCC10 are checked against their receipts.

Safe03 source is `a1aac003bbcac3731cc47b3c00dcc7e27f9323842fd26cb60417c2115e85ff10`;
runtime-extend01 is `1b740d48e0db4504b214e0c909d0b5f28cd49064850e9be69fdb20a53a6c55fe`.
The timed products remain hosted-generated native programs. The exact safe03
QBE bridge does not turn them into a timed N2-produced benchmark.

Reference artifacts are the existing Phase93 pinned upstream C/Clang products
and Phase102 mature selfhost C products, with identical fixture hashes. They
are useful product comparisons but different compiler vintages and pipelines;
they are not a controlled experiment changing only QBE versus Clang.

Root's completed `selfhost/build/phase119/clean01/report.json` gives:

| Exact fixture | QBE median | Mature selfhost C | Upstream C | QBE/upstream |
| --- | ---: | ---: | ---: | ---: |
| scalar-region-8192 | 429ms | 207ms | 201ms | 2.134× |
| active-ray256/2240 | 1,703ms | 688ms | 201ms | 8.473× |

These are three-round results at the same long workload/count contracts used
in Phase116. Other Phase118 broad-screen times use one quarter as many
repetitions and fewer warmups; do not mix their absolute milliseconds.

## What actually changed

The JSON extracts each emitted assembly function and renumbers only `.Lbb`
local labels. All instructions, registers, constants and constant-label
references otherwise remain exact. This is stronger than comparing counts,
but does not assert identical binary placement or dynamic call frequency.

| Current function | Assembly instructions | GPR/XMM moves | Static frame references | Change |
| --- | ---: | ---: | ---: | --- |
| active-ray `$direct.isect5` | 200 | 49 | 47 | Identical Phase114→117→118 |
| active-ray `$product.nearest` | 421 | 4 | 113 | Identical Phase114→117→118 |
| active-ray `$direct.nearest.t` | 366 | 4 | 93 | Identical Phase114→117→118 |
| scalar-region `$direct.mit` | 121 | 0 | 2 | Identical Phase114→117→118 |
| Mandelbrot `$direct.mit` | 121 | 0 | 2 | Identical Phase117→118 |
| numeric-recurrence `$direct.p37.numeric` | 60, formerly65 | 9, formerly8 | 9, formerly10 | Runtime op58 removed |

Counts cover entire functions including cold paths, not dynamic instructions.
They count assembly instructions and exclude assembler-inserted alignment, so
they need not equal older objdump totals. Mandelbrot's overall Phase118 speedup
is not a faster `mit` worker. The recurrence now has no call in its worker and
loses four callee-register saves, but retains a2KiB scratch frame and repeated
integer/float conversions. Its retained broad-screen median is104ms versus
123ms Phase117 and50ms upstream; this is earlier evidence, not a new run here.

## Ray: the remaining difference is larger than its calling convention

Current `p118-broad01-variation-ray-active-256-2240-build/program.s:1369` still
receives ten float values as integer `l` arguments, repeatedly stores operands,
moves bits into XMM registers, performs single-precision arithmetic and moves
the result back to an integer word. Its frame reservation is2072bytes.
`nearest` at line1996 and `nearest.t` at2467 retain2280/2232byte frames, selectors,
Boolean decoding and calls across that representation boundary. `Hit` results
are already flattened here; another generic pair-unboxing pass would miss this
specific cost.

Retained mature C inlines intersection work into its nearest functions. Its
generated C still includes scalar rewrapping, temporary joins and error polls
(`b1/output.1.c:8991`), so its source is not already an ideal typed IR. Clang can
remove much of that local scaffolding and keep floats in XMM registers. Yet
this C route remains3.423× upstream on the fresh active-ray measurement: merely
matching its existing machine code would still leave a substantial gap.

The upstream hot `spin_22` contains a much larger optimized numeric region. In
addition to scalar arithmetic, its retained machine body contains15 `addps`,
5 `subps`,42 `mulps` and6 `divps` sites. The inspected mature-C nearest and QBE
functions have none of these packed arithmetic instructions. A concrete example
at addresses`0xa917..0xa942` performs `sqrtss`, one scalar division, a broadcast,
packed division and packed multiplication for ray components. This establishes
an additional optimization capability exposed by the larger region; whole
function SIMD counts do not quantify its runtime contribution or prove that
vectorization alone would reach parity.

The selected runtime already uses `sqrtss` on its ordinary path. The previous
audit's sqrt-specific29/906 samples are historical, not a new dominant-cost
claim. Similarly, old local float-lane experiments improved active ray12.77%
and raytrace4.17%; restoring them is not evidence for a2× gain. Preserve exact
F32 rounding, signed zero and NaN behavior when evaluating larger regions.

## Scalar: signed-shift recognition is missing, not QBE support

The ordinary fixture expresses arithmetic shift-right-by8 as
`(v >> 8) | select((v >> 31) == 0, 0, 0xff000000)`. Both upstream and mature C
machine loops recover `sar 31; and 0xff000000` for the sign fill. Current QBE
instead retains comparison/normalization/select chains around logical shifts.
The earlier inspected hot iteration has97 instructions versus upstream38,
including7 `setcc` versus2 and3 conditional jumps versus1. Neither loop calls
helpers or accesses stack memory inside that iteration.

QBE already supports `sar` (`qbe-1.3/doc/il.txt:698`); our structured verifier
`p111v_operator` at safe03 line40212 and renderer `p111q_binop` at40657 already
accept it. The lost opportunity is recognizing the unsigned-source identity:

1. `p112_scalar_dispatch:41246` maps each `U32.shrn` independently through
   `p112_scalar_shift`, masking the operand and checking the full Nat count
   before a logical shift. Those guards correctly preserve counts>=32 and must
   not be globally removed.
2. Inlining exposes the helper's comparisons and selection as separate mutable
   machine locals/branches. Existing Boolean recognition only handles exact
   single-Set0/1 arms; this sign-fill selection returns0 or`0xff000000`.
3. `p113w_ring:48419` accepts only add/sub/mul/and/or/xor followed by a mask.
   It deliberately excludes shifts. Therefore the existing width peephole
   cannot reconstruct the signed-word operation from this graph.

A future general recognizer would need the same reaching low32 producer on
both shifts, exact count/mask constants, correct selection polarity, unchanged
values through copies and branch joins, and no removed effects. It must emit
**word-width** arithmetic shift and then zero-extend the U32 result to the
64-bit Term convention. A64-bit `sar` on a zero-extended U32 has the wrong sign.
For a variable-count generalization, QBE's modulo-width shift semantics require
retaining the source count guard. `N_W32` ownership kind alone is not a proof
of the needed bit pattern or Boolean encoding.

This can be investigated near structured range/copy facts before final
emission, retaining verifier and fallback. No workload or helper name should
select it. Do not repeat Phase118's rejected dead-scalar cleanup: it reduced IR
but grew the hot loop97→99 instructions and regressed8.05%.

## Highest-value unresolved questions

1. Do refreshed physical samples still concentrate in intersection plus nearest,
   and which surviving instructions account for the changed distribution after
   runtime improvements? Use the current ELF for current PCs.
2. How much comes from local numeric representation versus call boundaries and
   missed cross-call simplification/vectorization? The later experiment should
   separate typed ABI alone from a bounded preserved numeric region.
3. For the integer region, does recovering exact signed-word and canonical
   Boolean identities remove actual hot instructions? This is a more specific
   hypothesis than generic branch removal or “QBE lacks optimization.”

The smallest later falsification steps are distinct:

* **Signed-word identity:** first export the existing verified `mit` body and
  establish that one general reaching-definition pattern covers its sign-fill
  sites without helper names. If it cannot recover the same low32 producer and
  exact selection polarity, reject that bounded recognizer. If it can, check
  ordinary U32 boundary values0,`0x7fffffff`,`0x80000000`,`0xffffffff` against
  the independent source expression, preserve width/shift-count semantics,
  and inspect whether the resulting machine loop actually loses the chain.
  Unchanged or worse hot machine code falsifies the proposed mechanism before
  any broad compiler rebuild. A positive result still needs the scalar fixture
  and an unrelated numeric transfer case, with ordinary output checks.
* **Typed numeric region:** use the existing source/outputs and compare three
  otherwise matched small products: current lowering; typed private ABI alone;
  and a bounded region retaining float locals across intersection and nearest.
  Count conversions, live spills and residual control in the same computations
  and run existing exact numeric controls. If conversion removal merely moves
  to the boundary, or the fused region adds spills without reducing measured
  time, reject that proposal. ABI-only improvement would not establish the
  benefit of region fusion; neither static SIMD availability nor fewer source
  lines predicts the size of a gain.

No transformation is implemented or selected by this audit. The new native
profiles are root-owned; their conclusions should supplement these authenticated
static differences rather than inherit Phase116 sample shares.

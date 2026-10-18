# Promoted shared loops: remaining code shape

P107-010 is closed as an optional arithmetic pass. Its finite correctness controls
pass; paired runtime effects are mixed, so it is not the default pipeline. The
original promotion audit below motivated the experiment; final results follow.

Read-only CPU0 source/disassembly audit of artifacts06 and measure07. No compiler,
program, profile or benchmark ran in this lane. Existing root measurements are
reported here; causal explanations below are static inferences.

Scalar promotion removed the shared loop's heap load/store chain. In Cranelift
`bend_ir_main`, the loop at 0x104–0x125 contains no heap access or call, but it loads
the accumulator from `[rsp]` at 0x104 and stores it at 0x121 every iteration. The
header at 0xa6 rematerializes the masked bound. The promoted reference counters
remain live registers through the loop and are tested after it, despite cancelling
increments/decrements. Their extra live ranges plausibly contribute to the spill;
this is not measured allocator attribution.

QBE's fused public `phase106_entry`, loop 0x170–0x187, keeps the accumulator in a
register and contains no memory access or call. The emitted Nx JSON/SSA still has
scalar counter add/sub and many local copies; the machine code has already removed
the loop's counter arithmetic. Thus deleting textual copies alone is not evidence
of a runtime opportunity. Both allocations and frees remain outside the loop.

The borrowed variant has no loop memory access in either backend. Its Cranelift
loop is 0xe1–0x102 in `bend_ir_main`; QBE is 0x140–0x154 in fused
`phase106_entry`. Both retain a multiply by33 on the loop-carried accumulator.
Raw Clang C uses shift/add instead, with two-way shared and four-way borrowed
unrolling. The same serial multiply appears in promoted shared: CL 0x10f, QBE
0x175. The wrapper calls `bend_ir_main` in CL; QBE fuses the entry, so these are
matched executed kernels, not comparisons to unused private QBE copies.

| Existing measure07 result | CL / raw Clang | QBE / raw Clang | Raw QBE / promoted QBE |
| --- | ---: | ---: | ---: |
| shared | 2.553× | 1.260× | 2.651× |
| borrowed | 2.066× | 1.469× | 1.413× |

The shared promoted times are27.025ms CL and13.336ms QBE versus10.586ms raw Clang.
Borrowed is18.865ms/13.413ms versus9.131ms. These figures inherit the matrix's
workload/round boundaries. They do not measure a general program-speed average.
The current CL objects use `speed_and_size`; a separate `speed` policy is a cheap
future backend ablation, but source inspection has not established that it changes
this spill or multiply.

## Small next experiment

Try type-aware constant multiply reduction for scalar atoms multiplied by a power
of two or one greater than a power of two. For known unsigned widthW,
`x * (2^k + 1)` equals `(x << k) + x` modulo2^W for k<W. This is a generic arithmetic
identity, with no names, reference-count patterns or coefficient33 special case.
Restrict duplicated operands to typed constants or variables; refuse unknown or
pointer types and larger expressions. Preserve every effect/control-flow position.
The initial IR literal holds only a U32 value, so literal-derived k is at most31,
even when the operand width is64. Retain verifier, function/node and growth caps.

This may shorten the accumulator dependency chain on both backends; the emitted
objects must confirm the intended shift/add remains after backend optimization.
It cannot by itself eliminate CL's spill or unroll either loop. A predicted large
speedup would be unsupported. Reject it if unchanged objects, compile cost or
held-out execution outweigh the result. Full modular boundary oracles must cover
both widths, both coefficient positions, high bits/wraparound, nonmatching
coefficients and refusals. Then run the existing complete runtime corpus.

A later scalar copy/constant propagation pass could recognize loop-carried
identity values and remove constant counter live ranges. It needs joins,
loop-written-variable invalidation and safe liveness; this is a larger change than
the arithmetic experiment. Do not infer that arbitrary copy deletion or heap-store
elimination is safe from this particular source.

## Method and pins

Used `objdump -dr -Mintel` and `readelf -Ws` on immutable objects, following the
[existing code-shape methodology](code-shapes.md). Offsets are object section
addresses, bounded by ELF function symbols. Static instructions are not dynamic
counts; frame reservations are not RSS. JSON and QBE SSA were inspected to connect
the executed arithmetic to its producer. No extra object was built.

- `selfhost/build/phase107/artifacts06/report.json`: `4791b282c4a7e2f577a93175d16480afb30b3de708e190ca3309b80669fc1a46`.
- `selfhost/build/phase107/measure07/report.json`: `96ff5c5ec480a019f6f76762a864d9dd866129f426ec8052532658cb0838e837`.
- `selfhost/build/phase107/measure07/ir-shared-4096-cl.o`: `8d512063a505724b36652d64ddde0d1bb62441011ec39f9a48feaf0f648f4cb4`.
- `selfhost/build/phase107/measure07/ir-shared-4096-qbe.o`: `5e12721337ad557a1fd97b681d19a471ecc645f5dbc0908e74d0dba46d591343`.
- `selfhost/build/phase107/measure07/ir-shared-0-c.o`: `a0ff1d97813326ac66d2b99c8f3daeb9162f9dcf4748639aefd649fc619a5488`.
- `selfhost/build/phase107/measure07/ir-shared_borrow-4096-cl.o`: `0bfc6d7f8c86d05ce7d338cb854891432e80b4cdddbe31309150e6f5d1ec6416`.
- `selfhost/build/phase107/measure07/ir-shared_borrow-4096-qbe.o`: `abab667d963dafdffa59d621501c9b3bf026aa2de1341014449599d6170e3a0d`.
- `selfhost/build/phase107/measure07/ir-shared_borrow-0-c.o`: `7010c3451378a2f8e9ff47ee1d9c41267ac3894ed72badff2f4ab2769c4b3b7f`.

## Optional P107-010 implementation

The [hypothesis](../../experiments/phase107/P107-010-constant-multiply.md) was written
before the candidate. `inline/strength.bend` adds109 lines with
`nx_strength_reduce(program)`; the40-line fixture module provides
`nx_sr_fixture(width,factor,left)` and `nx_sr_fixture_extra(name)`. There is no new
IR or memory analysis and no production/default pipeline change. Zero/one,
powers-of-two and powers-plus-one identities apply to known typed atoms only.
The U32 coefficient representation bounds the search to32 steps; U64 products
keep U64 operands and shift constants. Recursive structural traversal preserves
call/argument, allocation, memory and control positions. Original body4096,
program65536 and function256 bounds limit work; output growth over4096 or failed
final verification returns the original whole program.

The successor [controls](../../selfhost/tools/performance/phase107/inline/strength-controls-v3.json)
contain70 coefficients, two widths, both coefficient positions and2800 complete
modular product expectations generated independently with Python integers. U64
values are decimal strings to avoid JS Number rounding. The U64 fixture's product
helper returns the full64-bit value; its U32 public entry compares that value to
a supplied full64-bit expectation. Repeating with a wrong high-half expectation
checks that low32-bit agreement cannot mask an error. Extra witnesses cover a
non-atom refusal, nested eligible arithmetic and invalid widths.

Bridge17's first checker attempt failed in the fixture helper: `width` was used
twice without a borrowing annotation. Its raw diagnostic remains in
`selfhost/build/phase107/bridge-check17/stderr.log`. Commit `cb1c3c0` adds only the
fixture's `+width`; the transformation core is unchanged. The original controls
remain preserved and v2 changes only the fixture identity/version/derivation,
with all2800 arithmetic expectations unchanged. Bridge18 then rejected a plain
helper declared after its caller; `e69baa4` reorders it without an unsafe bypass.
The v3 controls preserve the earlier identities. Bridge19 checks successfully;
the transformation core remains the original109-line implementation.

The supplemental [control builder](../../selfhost/tools/performance/phase107/strength-extra-controls.mjs)
constructs11 host-side IR graphs without requiring another Bend-source rebuild.
Two executable witnesses observe a called function's write and a loaded snapshot
across a subsequent store; three malformed call/load/allocation operands require
unchanged-input refusal. Six structural-only cases cover257functions,4096/4097
original body nodes,4096 accepted versus4098 refused total growth, and65537
original program nodes. Malformed and capacity graphs were not executed. These
controls now pass through `strength-extra01`, as detailed below.

Source/data checks cover definition-name uniqueness, source pins, pinned Base
unary `U32.shr` signature and independent arithmetic expectations. Root performed
the checker, generated-program and runtime targets; this lane performed source,
disassembly and receipt analysis only.

## P107-010 closed results: optional, not default

[`strength-audit01`](../../selfhost/build/phase107/strength-audit01/report.json)
passes282 valid graphs:280 width/coefficient/side combinations and two additional
valid fixtures. The two malformed fixture graphs are refused unchanged. Its8440
independent-interpreter observations compare original and transformed results,
including U64 high-half checks;1500 generated native outputs pass across GCC,
QBE and Cranelift. These native executions cover the selected boundary subset,
not every possible scalar input.

The [supplemental structural audit](../../selfhost/build/phase107/strength-extra01/audit-report.json)
passes11 controls: eight valid and three invalid. It checks exact ordered effect
statements, their complete operands and control-flow positions. The three nested
call/load/allocation operands are refused unchanged. All six limit controls pass:
257functions refused,4096-body accepted/4097-body unchanged,4096 whole-program
growth accepted/4098 growth refused, and65537 original nodes refused. The accepted
body4096 case grows2046 nodes. The two executable call/load snapshot witnesses add
[32 model observations and48 native outputs](../../selfhost/build/phase107/strength-extra01/report.json).
Capacity fixtures remain structural only; none is counted as a semantic execution.

The measure08 screen completed312 model observations,78 builds and234 timed runtime
records. It is retained as a screen, rather than used to estimate the incremental
effect from independently run measure07/08 ratios. The predeclared
[paired comparison](../../selfhost/build/phase107/strength-pair01/report.json)
then ran all39 existing optimized binary pairs:13 programs × three backends,
five rounds,390 observations. No binary was rebuilt or policy retuned for it.

Each round alternates promotion/strength order by case and round, reverses case
order after the round, and uses the same inputs, repetition count and complete
expected result for both roles. The reported clock is elapsed child-process time,
including launch and the repeated workload, not optimizer time. Medians use five
samples per role. Twenty-five pairs have identical ELF `.text`; their observed
ratios range0.953–1.093 and are not credited as optimization gains. This finite
campaign provides no confidence interval or general speed guarantee.

All14 changed-text pairs are shown below. Values are strength time divided by
promotion time; below1 is faster.

| Program | Cranelift | QBE |
| --- | ---: | ---: |
| list | 1.052 | 1.003 |
| source classifier | 0.931 | 0.973 |
| borrowed | 0.854 | 1.029 |
| shared | 0.993 | 0.993 |
| text | 1.047 | 1.100 |
| source recurrence | 0.827 | 0.802 |
| closure | 0.873 | 0.920 |

Recurrence improves17.3% CL/19.8% QBE; closure improves12.7%/8.0%, and borrowed CL
improves14.6%. Text regresses4.7% CL/10.0% QBE, and list CL regresses5.2% in this
paired estimate. Shared is effectively unchanged. These are generated-program
results; they say nothing about compiling the full Bend compiler faster.

The initial shared screen illustrates why the paired protocol matters. QBE's
ratio to raw Clang changed1.260→1.139, appearing roughly10% better. But raw Clang's
denominator moved10.586→11.607ms, while the optimized QBE measurements were
13.336→13.223ms. The direct paired strength/promotion result is0.993, not a10%
incremental gain. Preserve both observations rather than selecting the favorable
ratio or treating smaller instruction count as proof of faster execution.

Decision: retain the pass as **optional**. The mathematical identity is useful and
the implementation remains small, but mixed backend results—especially QBE
text—do not justify applying it globally. No program-specific selector, production
default or installed compiler changed. Further tuning requires another bounded
hypothesis and held-out validation; this phase does not add a larger propagation
or unrolling pass.

Final receipt SHA-256 identities:

- Bridge19 API: `10958e538198098ab7fff529ea02b7cccecd5ac07f04069829f86911f7d4b6e4`.
- Main qualification: `6008f4889c89979152ff1c23f372d61d2aad0ae3f4b7ab5815c7ced26907f7a8`.
- Supplemental structural audit: `72d39ddefaddd91dce8b455f48dcf20a82ab93dc3a7ec030dd70f832dad2972c`.
- Supplemental executions: `261ee74791f65ef2e9322c586beb96c5f7cc87ad51a56c5051908da75d85be41`.
- Measure08 screen: `e3766443e875cdf5fcbb4d34b262f436c2cecf10f8f4e9acaaacac667742e2da`.
- Five-round paired campaign: `b11f61d5adf45ed8a0addda73bbd33da507b1840c6bdf63a5ef2c33326128766`.

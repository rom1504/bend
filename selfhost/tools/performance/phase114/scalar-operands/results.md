# P114-008: scratch stores removed, floating representation boundary remains

The prototype did exactly the intended mechanical work, but its measured benefit is small. In the unchanged ray worker `$direct.isect5`, **34 unconditional machine scratch stores disappear**, while **all 49 GPR/XMM moves remain**. Keep this optional experiment; the evidence does not justify another default integration cycle.

Root's ordinary-source structural controls passed: arithmetic stores **8→0**, conversion **1→0**, and mixed unsupported square-root use **3→3** with exact original fallback. The ordinary executable also passed its complete independent stdout. The subsequent matched two-program screen had 24 correct, qualified observations: four compiler roles × two programs × three rounds. Six observations belong to this candidate; 24 is not its independent sample count.

| Same-screen median runtime | Selected parent | Candidate | Candidate change |
| --- | ---: | ---: | ---: |
| Active ray 256/2240 | 425 ms | 411 ms | −3.29% |
| Local pair | 389 ms | 391 ms | +0.51% |

The geometric mean candidate/parent ratio is **0.985916**, or **1.41% less runtime on these two programs**. This is a small screen, without a confidence interval or broad candidate qualification. The measurement receipt reports 11.572 s of measurement wall time; acquisition and the surrounding campaign are separate. Root deferred promotion.

## Exact static comparison

Both inspected ray binaries are the products used in that same screen. The source hash is identical, `7099448e301e2cab7cb5ab47e2a4892dbf44ac246676b4f950282c7a57007669`. [results.json](results.json) contains source/API, QBE, assembly, binary and measurement pins, complete extracted worker text, line numbers and counting definitions.

| `$direct.isect5` | Selected parent | Operand prototype |
| --- | ---: | ---: |
| QBE `storel`, whole function | 51 | 14 |
| QBE `loadl`, whole function | 50 | 13 |
| QBE stores before first conditional | 37 | 0 |
| Machine qword frame stores before first conditional | 34 | 0 |
| Machine qword frame stores, whole function | 41 | 7 |
| Machine instructions | 200 | 166 |
| Explicit stack reservation | 2,072 B | 24 B |
| GPR↔XMM `movq`/`movd` | 49 | 49 |
| Scalar FP arithmetic | 19 | 19 |
| Scalar FP comparisons | 2 | 2 |

The call list remains `p111_rt_fail`, `p111_rt_op`, `p111_rt_fail`; the ordinary square-root runtime path remains. The remaining stores belong to unchanged nested/fallback rendering. The stack numbers describe the explicit `subq` reservation, excluding saved registers and incoming arguments. These counts are static observations, not execution frequencies or time fractions.

Parent assembly begins at line 1185 of `selfhost/build/phase111/p114-final-screen01-variation-ray-active-256-2240-build/program.s`; candidate begins at line 1161 of `p114-scalar-operands-screen01-variation-ray-active-256-2240-build/program.s`. The parent starts each scalar operation with scratch writes. The candidate removes those writes, but still repeats this pattern:

```asm
movq %r8, %xmm0
movq %rsi, %xmm1
subss %xmm1, %xmm0
movq %xmm0, %rsi
movl %esi, %esi
```

The next arithmetic operation reconstructs its floating operands from integer words again. The QBE source still declares ten F32 source parameters and the result as `l`. This experiment deliberately retained those representation boundaries, so deleting operand stores cannot remove them.

The primary assembly hashes are parent `cbf5170cd7cbf35238ca8ac269ee72d3614883a3b846fcee22f632e3ceb6433e` and candidate `109c54601a153a6a55818e66b889a54bff20bf6fea9b971654e07ded85bd07ff`. QBE hashes are parent `c971b03be7481773ee0e22cc65240af95b1538f38d4fa7516075b084708fc6c2` and candidate `c5759422b44ba9c01cf3506571c3d3b85e97f6c81ecdada1d573b70743a575ad`.

Reproduce the source/receipt/static comparison without executing any compiler or generated program:

```sh
python3 -B selfhost/tools/performance/phase114/scalar-operands/compare-static.py \
  --out /tmp/p114-scalar-operands-static-review.json
```

## What upstream illustrates

The existing pinned upstream C ray product expresses arithmetic directly with `f32_unbox`/`f32_rewrap`; see `spin_9` at line 1407 and `spin_22` at line 2050 of `selfhost/build/phase93/broad01/variation-ray-active-256-2240/upstream.1.c` (SHA-256 `18faa3fc10c9e388a5ee819481a4ea397f446358277f4c152e2391a69e99deec`). Its source still contains bit conversions, so the presence of casts alone does not force the machine moves we see in QBE output.

Read-only disassembly of that screen's existing upstream binary, SHA-256 `673a5086e23e7381d967d946b14d456012ba2140d6e6a2dee09aba2f47c821ee`, shows `spin_22` keeping intermediate values in XMM registers. At addresses `0xa8e9–0xa923`, two argument moves feed `mulss`, `addss`, `sqrtss`, `divss` and `divps` without an integer round trip after every arithmetic operation. At `0xa92e–0xa955`, the inlined intersection arithmetic likewise remains in the FP register domain. This is evidence of optimized floating value flow and packed arithmetic in the final Clang product. It is not a matched whole-function size comparison: Clang has combined/inlined operations across our worker boundaries.

```sh
objdump -d --start-address=0xa8d0 --stop-address=0xa980 \
  selfhost/build/phase93/broad01/variation-ray-active-256-2240/upstream.program
```

The strongest next hypothesis is therefore a checked, typed private F32 region: preserve F32 values through local operations and admitted calls, and convert once at generic Term boundaries. [The architecture follow-up](../../../../../implementation/phase114/next-category-removal.md) describes the required signature/value-flow proof and ordinary-source experiment. This result supports that experiment; it does not establish how much of the remaining ray or broad runtime gap it will recover.

No compiler hooks or runtime sources changed during this analysis. Only existing artifacts were read; no new target execution occurred.

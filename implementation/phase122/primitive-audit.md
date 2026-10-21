# Phase122 primitive-arm audit

Offline inspection only: no compiler, target, profiler or rebuild executed. Uses the current Phase121 products and Phase118 `runtime-extend01/runtime.o`; source/selection identity is documented in `numeric-audit.md`. Two captures per case, sampled leaf PCs rather than call-stack or primitive counters. Counts below are sampled PCs, **not primitive invocation counts**.

## What can be attributed

`objdump -dr --disassemble=p111_rt_op selfhost/build/phase118/runtime-extend01/runtime.o` identifies the retained runtime function at object `.text` offset `0x50b0`. Symbol-relative offsets remain valid after linking. Runtime source `runtime.c:4012` and `primitives.h` identify the matching semantics.

| Workload | All samples | p111_rt_op samples | Arm/block attribution |
|---|---:|---:|---|
| lexer | 1098 | 6 (0.55%) | Dispatch/prologue: 6 |
| test-evening-program | 1113 | 66 (5.93%) | U32.cmp: 5, Nat.add: 15, Nat.sub: 4, Nat.mul: 5, Nat.cmp: 1, Dispatch/prologue: 16, Nat.divmod: 9, Shared return: 5, Other/shared: 3, Bool.or: 2, Nat.is_lt: 1 |
| coverage-map-churn-128 | 1115 | 76 (6.82%) | Nat.sub: 12, Shared return: 8, Nat.divmod: 34, Nat.is_lt: 7, U32.cmp: 2, Nat.add: 1, Dispatch/prologue: 11, Other/shared: 1 |

The strongest resolved site is **Nat.divmod in map**: 34/76 op samples, 34/1115 (3.05%) of all samples. Offset693 (`+0x2b5`) alone has25 samples; this is the `mov %rdx,%rcx` immediately following the64-bit `div %r8` at+690. It is consistent with division latency/retirement attribution, not proof that the following move itself is slow. This arm ends by tail-jumping to `p111_tuple`, which allocates and seals a two-field owned result. Allocation samples elsewhere cannot be charged to this call without caller attribution.

Evening's identifiable arithmetic is broader: checked Nat.add (15), Nat.divmod (9), checked Nat.mul (5), saturated Nat.sub (4). Lexer has only6 op samples, all in the common entry/dispatch, so **no particular primitive can be identified and op is not a major lexer cost in these captures**.

Useful exact machine regions:

- +664..727: Nat.divmod, zero guard, one unsigned64-bit division computing quotient/remainder, tuple-return tail call.
- +1096..1161: Nat.mul, zero case and48-bit overflow guard (includes division by multiplier).
- +1168..1207: Nat.sub, unsigned subtraction plus conditional zero saturation.
- +1216..1253: Nat.add, addition plus48-bit result limit guard.
- +2368..2412: U32.cmp, two comparisons followed by Ordering constructor selection.
- +2944..2972: Nat.is_lt, unsigned64-bit comparison.
- +0..51 and+228..245: common entry/return. These cannot identify a primitive from the PC alone. Do not distribute these samples proportionally to the resolved arms.

## Actual QBE evidence and smallest useful test

Current files are `selfhost/build/phase118/p121-broad-emit04/{lexer,test-evening-program,coverage-map-churn-128}.ssa`. Generic calls retain literal opcode70 (`Nat.divmod`), opcode62/63 (`Nat.add/sub`), opcode67 (`Nat.is_lt`) and other IDs even in specialized private regions. Map and evening each contain seven static Nat.divmod calls, including original generic/native wrappers plus literal-divisor10 and33 call sites. These are **static inventory, not hot-site counts**; the samples cannot distinguish which caller/divisor dominates. The opcode70 call returns a tagged tuple, which is passed into normal continuation/constructor machinery.

Highest-information primitive experiment: exact owned-result projection for Nat.divmod, retaining quotient/remainder as two scalar results through a checked private consumer instead of materializing/taking a tuple. Start with a known literal nonzero divisor and compare an arithmetic-only projection against arithmetic+tuple-elimination. Preserve zero-divisor semantics `(0,a)`, Nat range, result order, and escaping tuple fallback. This can eliminate dispatch, hide neither overflow nor arity obligations, and potentially remove allocation/transport beyond the3% leaf arithmetic share; the latter is a hypothesis requiring measurement. A pure opcode-specialized helper alone cannot credibly explain or close a multi-fold gap.

Second cheap experiment: checked direct Nat.add/sub/is_lt projections in existing structured regions, retaining overflow rejection and saturation exactly. Nat.mul guard removal requires an independent range proof; replacing it with machine wrapping multiply is incorrect. Before a broad primitive pass, add lightweight independent caller/primitive counters or use a bounded single-arm ablation to resolve how much tuple/control machinery is actually attributable. No such experiment was run here.

The dominant remaining lexer work is control/ownership/generated workers, not arithmetic dispatch. Treat map/evening primitive specialization as one small enabling part of a larger tuple/control representation change.

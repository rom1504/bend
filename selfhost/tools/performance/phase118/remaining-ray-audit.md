# Remaining ray cost: preserve a numeric region, measure before changing the ABI

Offline audit of existing artifacts only; no compiler or generated target was run.
The strongest remaining hypothesis is loss of numeric and Boolean provenance
through the **intersection plus nearest-hit loop**, not a slow square-root
instruction or stack reservation alone. A typed private ABI could help, but the
evidence does not establish that changing the ABI is the dominant opportunity.

## What is actually measured

Current `selfhost/build/phase118/broad-screen01/report.json` gives these matched
three-round medians, with complete-output checks passing:

| Case | Phase117 baseline | Phase118 candidate | Upstream C |
| --- | ---: | ---: | ---: |
| active ray256/2240 | 478 ms | 479 ms | 57 ms |
| raytrace | 608 ms | 470 ms | 57 ms |

Thus active ray is unchanged and remains **8.40×** upstream in this screen;
raytrace improves but remains **8.25×**. These are different workloads. Do not
attribute raytrace's improvement to a transformation that leaves active ray
unchanged, or mix these budgets with Phase116's longer diagnostic timings.

The available physical profiles are the **older qualified Phase114 product**,
collected by Phase116, not a new profile of the Phase118 candidate:

`selfhost/build/phase116/native01/variation-ray-active-256-2240-qbe-{8000,13000}.analysis.json`.

The first has 562 samples and meets the 500-sample threshold; the second has 344
and is corroborating evidence below that threshold. Both have zero loss. Pooled
906 instruction leaves locate the following regions:

| Physical instruction region | Samples | Share |
| --- | ---: | ---: |
| `$direct.isect5` | 365 | 40.29% |
| `$product.nearest` | 212 | 23.40% |
| `$direct.nearest.t` | 93 | 10.26% |
| `p111_rt_op` | 93 | 10.26% |
| `$product.trace` | 87 | 9.60% |

These are physical leaves, not inclusive call stacks. Missing ELF symbol sizes
are resolved using the next text symbol. Short periodic profiles do not identify
the exact cycle cost of individual instructions. In particular, the hottest
`isect5` PC, `0x4057f3` (26 leaves), is a GPR/XMM move immediately after `mulss`;
`0x40578b` (11) similarly follows `addss`. Sampling at dependent moves is not
proof that the move itself, rather than its dependency, causes the stall.

Disassembling **that exact profiled binary** subdivides `p111_rt_op`:

| Region / original addresses | Samples | Whole-program share |
| --- | ---: | ---: |
| shared dispatch/prologue `0x42bd30..0x42bd5f` and epilogue `0x42be13..0x42be1b` | 44 | 4.86% |
| U32 narrowing `0x42be20..0x42be2c` | 9 | 0.99% |
| U32 division/remainder `0x42c790..0x42c80f` | 10 | 1.10% |
| sqrt case `0x42c998..0x42c9b6` | 29 | 3.20% |
| shared float-result return `0x42c1f7` | 1 | 0.11% |

The 44 shared samples cannot be assigned to sqrt without call-chain or other
evidence. The 29 sqrt-case leaves include arity checking, load, sign test and
result branch, not just arithmetic. Removing **all** runtime-op leaves would
only imply an illustrative 1.114× Amdahl ceiling on this old profile; removing
the sqrt-specific leaves alone gives 1.033×. Caller setup is additional and useful
arithmetic cannot actually be removed, so neither is a speed prediction.
Even deleting all 40.3% of `isect5` would give only 1.675×. Parity needs improvements
across several regions, not one clever sqrt or calling-convention edit.

## Three source-to-machine boundaries

### 1. Local floating arithmetic repeatedly becomes an integer word

Ordinary source `phase88/broad-fixtures03/variation-ray-active-256-2240.bend:91`
computes three coordinate differences, a dot product and a discriminant in
`isect5`; all ten inputs and the result are F32. Current broad QBE lines 1865–2416
still declare ten `l` parameters after state and an `l` result. Each operation
stores integer operands, reloads/casts them to `s`, performs arithmetic, casts
the result to `w` and extends back to `l`. The next operation reverses this.

Current assembly `p118-broad01-variation-ray-active-256-2240-build/program.s:1369`
contains 49 GPR/XMM moves, 19 floating arithmetic operations and a 2072-byte explicit
frame reservation in this function. A representative sequence around 1384 is:

```asm
movq %r8, -2064(%rbp)
movq %rsi, -2056(%rbp)
movq %r8, %xmm0
movq %rsi, %xmm1
subss %xmm1, %xmm0
movq %xmm0, %rsi
movl %esi, %r9d
```

This is static evidence of local representation churn. It is **not** primarily
incoming-argument ABI work. Changing the function signature alone leaves most
of this pattern intact.

Phase114 already tested two slices; do not repeat them as new discoveries:

* `phase114/scalar-operands/results.md`: 34 unconditional scratch stores removed,
  frame 2072→24 bytes, but 49 register-domain moves unchanged; active ray 425→411ms,
  only 3.29% less time.
* `phase114/float-lanes/results.md`: local reuse reduced 49→25 moves and 166→131
  instructions; active ray 411→369ms versus the operand parent (10.22%), or 12.77%
  versus that screen's selected parent. The family follow-up improved raytrace
  only 4.17%; its two other cases had byte-identical products.

Those experiments preserve integer parameters/results. Neither is integrated
into the current `float-source01` source; its name refers to Phase118's different
float conversion work. Their gains support preserving local lanes, but cannot
justify a 2× prediction from static instruction counts.

### 2. Known Boolean and sqrt become generic runtime values

Source `isect.go` tests `F32.is_lt(disc,0)`, then computes `F32.sqrt(disc)` on
the false branch. Current assembly around 1495 materializes a 0/1 comparison,
then tests both integer 1 and a tagged True constructor using shifts/masks before
branching. Canonical-Boolean provenance was lost even though the producer is
known. This work is inside the arithmetic worker, independent of its entry ABI.

The sqrt branch writes a one-word argument buffer and calls `p111_rt_op` with
opcode 36. Runtime source `runtime-extend01/runtime.c:4158` spells
`f32_rewrap((f32)sqrt(f32_unbox(args[0])))`. **Both old and current machine code
already use `sqrtss`**, with a negative-input `sqrtf` fallback. In the current
binary this is `0x42d2f0..0x42d30e`, fallback `0x42d8b8`; old addresses appear
above. It is incorrect to infer a slow double-precision sqrt from C spelling.

A direct legal projection can eliminate dispatch and buffer transport, but it
must establish the exact language-level result contract. The source branch is
not a proof of finite nonnegative input: NaN makes `<0` false, and signed zero
and infinity remain possible. Preserve NaN/zero/comparison behavior, exception
policy where observable, and existing operation ordering. A tiny typed helper
with exact current semantics is a valid transport ablation; a bare `sqrtss`
replacement justified only by this benchmark is not. There is no evidence that
sqrt dominates the remaining 8× gap.

### 3. Nearest-hit retains generic control and transport around the scalar worker

Source lines 163–178 carries ray direction/origin and best hit through a sphere
loop, selects sphere coordinates/radius, calls `isect5`, narrows the index and
compares the new distance. Current `$product.nearest` QBE lines 4465–6545 and
assembly 1996–2463 retain all parameters as `l`, a 2280-byte frame and two static
isect call sites in alternate branches. Around 2367 the chosen site allocates 48
argument bytes, writes five stack arguments, calls `isect5`, spills its word
result, calls runtime opcode 25 (`U32.from_nat`), and reconstructs F32 for compare.
Runtime opcode 25 is simple low 32-bit narrowing, **not** an overflow check.

The typed F32 ABI could put eight float arguments in XMM registers and leave
two on the stack instead of five integer stack arguments. But a caller with many
live invariants must still preserve them across caller-clobbered registers.
This is a hypothesis, not evidence that all stack traffic disappears.

The nearest workers also contain repeated selector branches (`sx/sy/sz/sr`),
loop-state updates and Boolean decoding. `nearest.t` has another 2232-byte frame.
Their combined 33.7% leaves cannot all be charged to ABI setup. `Hit` is already
flattened into result-output fields on this route; another generic constructor
elimination does not address this hot path.

Pinned upstream C disassembly shows the contrasting capability: `spin_22`
at `0xa8e9..0xa955` keeps arithmetic in XMM registers, includes packed `divps`,
and fuses intersection arithmetic with surrounding work. This is evidence for
cross-boundary optimization, not a matched function-size comparison or proof
that SIMD alone accounts for the speed difference.

## Best next experiment: falsify the whole-region hypothesis cheaply

Do not undertake a general ABI rewrite on this evidence alone. Use a bounded,
closed numerical region whose signatures are recovered from checked source:
exact F32 values, canonical Booleans and integer-width conversions stay distinct
through arithmetic, branches and **one private call boundary**. Public Term
interfaces remain unchanged. Keep the original verified graph and separately
check the derived signature/value-flow projection; do not infer F32 from the
existing `N_W32` width.

The smallest useful experiment is a source-driven paired projection:

1. Keep a surviving private call with typed F32 parameters/results and canonical
   Boolean flow. This measures the actual ABI hypothesis beyond Phase114's
   local-lane experiment.
2. Fuse that same admitted callee into its caller with a strict size bound,
   retaining exactly the same numerical operations. This removes the whole
   call boundary and exposes selector/loop invariants. Compare against 1, not
   against a parent that still has unrelated scratch-buffer costs.

Use a renamed ordinary two-function numeric control with ten float arguments,
branches and sqrt, then unchanged active ray and raytrace. Confirm the intended
call survives in 1 and is absent in 2. Retain complete outputs and the established
F32 semantic controls; no reassociation, contraction or workload-name rules.
Reuse the Phase114 artifacts as historical controls rather than rerunning their
unchanged campaigns. Time only this narrow pair after structural success, with
an updated physical profile if it helps. If register traffic disappears without
a material runtime gain, stop expanding this path and examine actual loop work.

This separates three explanations: local representation churn, parameter ABI,
and cross-call optimization visibility. The potential broad compiler capability
is a semantic numeric region; the performance gain remains unmeasured. The
current evidence ranks it above another scratch-frame reduction or sqrt-only
campaign, but does not justify a predicted multiplier or full compiler rebuild.

## Artifact identity

All paths below are repository-relative; ordinary source and older products
are evidence, not changes to selected artifacts.

| Artifact | SHA-256 |
| --- | --- |
| `selfhost/build/phase118/float-source01/compiler.bend` | `b16a71925e94585b5d66a010a8377a1f6500376de217d90fee7eb2e8fcb26c08` |
| `selfhost/build/phase118/broad-emit01/variation-ray-active-256-2240.ssa` | `1e0f9c024c12a1e7a9a52c976083e3c7a0468dd07d6c941fa84c2c1ad9fb6bb2` |
| `selfhost/build/phase111/p118-broad01-variation-ray-active-256-2240-build/program.s` | `7a45b7c3ae52f4f657876808eb6afd88fbe6a5c2769c8690795f4faafa81bd59` |
| same directory, `program` | `e615a8b73f7ef69cdbcfdcf303999fba6b8e8a70839bcf5e14930f475cd92727` |
| Phase116 8000µs analysis named above | `0bc0ad47bd80d272462313a4c556c92b32d5d6e3b426d6a660cbc01c7841ce93` |
| Phase116 13000µs analysis named above | `33c1574f3d6297d52200254b53d26f03828ddb005209656f5f0afe68e5be6142` |
| `selfhost/build/phase111/p114-final-screen01-variation-ray-active-256-2240-build/program` | `24c4ac3dc59543d22eb9717567aaaad8210c8b7a056bd92c9d349d3080c1ae81` |

The old profiled binary must be used for its PCs; current addresses differ.
Existing emission/build receipts bind source, QBE, runtime and tool identity.
No target execution, production edits, qualification or promotion occurred in
this audit.

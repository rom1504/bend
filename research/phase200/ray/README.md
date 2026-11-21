# Sqrt-preserving F32 regions: staged candidate, no speed claim

The **runtime helper passed differential and register-preservation tests**.
The compiler overlay is extracted but **not yet source-checked or emitted**.
No candidate ray program has run, no candidate timing exists, and nothing is
installed. `checkpoint.json` records these separate states and exact pins.

## Category being changed

The current Phase199 ray `$product.nearest` owner has 760 decoded instructions,
162 RBP-relative memory operands and two `SQRTSS` sites. Its sqrt is physically
inline, yet remains an unknown call to F32 home allocation and private-buffer
analysis. This splits otherwise closed floating regions, materializes argument
buffers and sends live values through general registers or stack homes.
`candidate.json` and `current-nearest.asm` pin the actual inspected object.
The 38.2969% owner weight is explicitly a historical Phase194 proxy, not a
current profile or a measured weight for these two sites.

The candidate gives sqrt a precise machine-effect contract. Normal execution
retains the same inline ordered comparison and `SQRTSS`; only negative values
call `p200_rt_f32_sqrt_keep`. That helper preserves every allocated GPR and
XMM home around the existing `sqrtf` fallback. The final emission plan can
therefore treat an exactly admitted sqrt as a canonical F32 value node, retain
XMM homes across it, forward its scratch input, and prune dead private stores.
It introduces no FP reassociation, reciprocal approximation, AVX requirement,
benchmark name, scene constant or input-specific rule.

This is distinct from the rejected Phase197 local VEX, compare, copy and
constant-conversion experiments, whose whole-program gains remained below 2%.
It targets allocation and buffer boundaries across an operation, rather than
rescheduling one arithmetic block. Whether that saves enough work is unmeasured.

## Runtime contract and actual checks

The custom x86-64 ABI takes and returns the raw low F32 lane in XMM0. Only
XMM0/XMM1, reserved R10/R11 and flags may change; all other GPRs and all 128 bits
of XMM2–XMM15 survive. Stack alignment is maintained for libc. The compiler's
allocated floating homes use XMM registers, not upper YMM lanes. The helper
does not access Bend state, allocate, change ownership or invoke user callbacks.
Negative inputs retain the existing `sqrtf` errno and floating-environment
behavior; zero, positive values and NaNs retain the ordered-compare/SQRTSS path.

Root-coordinated `p200-ray-runtime01` passed in **0.181 seconds of work**
(0.251 seconds guarded process time), using the pinned GCC10 and unchanged
baseline runtime. It checked:

* **65,888** exact result-bit, errno and MXCSR comparisons against actual
  `p111_rt_op(36)`, including signed zeros, subnormals, infinities, signaling and
  quiet NaNs, arbitrary input upper bits and random patterns.
* All four rounding modes crossed with DAZ/FTZ settings: **16 MXCSR modes**,
  with masked exceptions and initial sticky flags.
* **1,024** preservation checks covering 13 allocated/callee-saved GPRs and
  all four lanes of XMM2–XMM15, across both fast and negative-libc paths.

These are finite executable checks plus source/ABI reasoning, not a formal
proof or an unmasked-exception qualification. Exact source, tools, commands,
result, process and sealed retention receipts are retained in `evidence/`.
The 1,256-byte helper object is identified by SHA256
`3ebd7e3ea0b76f577e9d7b5e3db4f033de4dce4c0cd9b4c64e1cb35ae5d25ee3`;
no binary is committed. The first scheduled run was held before launch because
disk space was below the unchanged 5 GiB reserve. It ran once after explicitly
authorized archival restored space, within a 1 MiB disk budget.

## Exact staged compiler and remaining gates

`sqrt-regions.bend` overlays nine declarations on the Phase199 integrated
source `a48b1532ec45ac23cb972796f0101a8bf1864ed8769c6a2daee114ee268ce313`.
It retains exact primitive/state/arity admission, one-word unary read footprints,
ordinary unresolved-buffer handling, canonical publication and label-overflow
fallback. The extracted source is
`selfhost/build/phase200/ray-source01/compiler.bend`, SHA256
`382d39d69ceca0f8fac7c62297e53994b948d2f78db7470deb2788916eaf2d04`.
Its extraction receipt is retained; extraction is not source checking.

The next bounded action, only with the parent's shared-lane handoff, is the
20-second API acquisition in `acquire-argv01.json`. The genuinely staged
follow-on is `prepare-screen.py` plus `screen.py`:

1. Check 712 admission combinations and eight malformed shapes.
2. Emit direct objects from three unchanged ordinary ray sources and the
   independently authored typed `sqrt-hold.bend`.
3. Run 16,384 typed-worker result/errno/status comparisons, including negative
   sqrt with other FP values live across it, before any timing.
4. Match the complete ray outputs against mature C on ordinary and alternate
   inputs; link old and new objects against the same helper/runtime.
5. Run six rotated timing rounds, inspect the actual changed hot owner and
   independently repeat promising results across link layouts before promotion.

Those scripts have only been staged and Python syntax-checked. Their execution
and results must not be inferred from the passing standalone helper. A retained
compiler would additionally require ordinary native reproduction, broad gates,
and an authenticated runtime bundle containing its new external symbol.

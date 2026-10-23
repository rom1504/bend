# Phase127 libc audit: newly executed fill work and a lost capability

This is an offline audit of the completed `paired01` clean timings and physical
PC captures. No compiler, benchmark or diagnostic executable was run by this
audit. The original captures and compiler images are unchanged.

## Main observation

Phase126 adds substantial samples in libc's **memory-fill implementation**.
Phase125 has zero observed fill samples across all three requests. Both 8ms and
13ms sampling periods independently show the new Phase126 fill activity.
Copy-region CPU estimates stay approximately flat. The previously unresolved
libc increase is therefore not simply increased `memcpy` execution.

The exact libc is `/usr/lib/x86_64-linux-gnu/libc-2.31.so`, SHA256
`d13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159`.
Fresh offline disassembly equals the retained Phase119 disassembly byte for byte.
The [range manifest](libc-regions.json) binds the reviewed ranges to that object:

- `[0xa3930,0xa3c29)`: copying, including overlap branches and `rep movs`.
- `[0xa3c30,0xa3de3)`: filling, including byte broadcast, vector stores and `rep stos`.

These are instruction-region classifications, not reliable exported-symbol
boundaries. The fill implementation has several entry points. Its sampled PCs
alone establish neither fill byte nor allocation/array size. In particular,
calling this "zeroing" requires caller evidence.

| Request | Phase125 / Phase126 samples | Fill samples old / new | Estimated new fill CPU | Total clean CPU increase |
| --- | ---: | ---: | ---: | ---: |
| lexer | 898 / 1,017 | 0 / 125 | 0.304s | 0.274s |
| map churn | 1,234 / 1,602 | 0 / 174 | 0.424s | 0.965s |
| closures | 241 / 287 | 0 / 37 | 0.093s | 0.111s |

Estimates pool each PC observation weighted by its sampling period, then
multiply by independently measured clean median process CPU. They are not
causal savings or confidence intervals. Closures has fewer than500 pooled
samples and is exploratory. Zero observed Phase125 samples does not prove zero
execution. Lexer’s estimated fill delta exceeds the total observed CPU delta;
sampling variation and changes elsewhere prevent subtracting these estimates
as exact accounting. Raw per-period counts and all capture identities are in
[libc-profile-comparison.json](libc-profile-comparison.json).

## A concrete compiler/runtime explanation to test

The exact full-compiler QBE descriptors differ in **capabilities**:

| Native image source | Capabilities | Live register bank bit4 |
| --- | ---: | --- |
| Phase125 `p125-native06-full-emit/program.ssa` | 5 | enabled |
| Phase126 `p126-native32-full-emit/program.ssa` | 1 | disabled |

The ABI header defines this field at byte88 (the twelfth 64-bit descriptor
field). Exact descriptors and QBE hashes are retained in the comparison JSON.

The selected runtime has these relevant branches:

- `WL_BANK` uses a local register bank when capability bit4 is absent.
- `WL_INIT_BANK` clears that bank with `memset` in that case.
- `WL_READ_STATE` and `WL_WRITE_STATE` restore full-bank copying in that case.
- `p111_set_regs`, at runtime source line3944, clears the unused register suffix
  with `memset` after transfers whenever capability bit4 is absent.

This establishes a specific, independently inspectable difference consistent
with the new fill samples. It does **not** establish which of those call sites
accounts for each sample, why the verifier no longer admits bit4, or the speed
that repairing admission would recover. Do not flip the capability bit as an
optimization: its safety conditions must be re-established by the existing
verifier. The next high-value investigation is why live-bank admission was lost
and whether it is a genuine newly exposed obligation or missing fact propagation.

## Physical caller recovery is unusually cheap here

The exact libc FDE `0x0000c9e8` covers `[0xa3d00,0xa3de3)`. Its CIE declares:

```text
CFA = rsp + 8
return address = memory[CFA - 8] = memory[rsp]
```

That FDE has only `DW_CFA_nop` entries, so the rule holds throughout it. The copy
FDE `[0xa3930,0xa3c29)` has the same rule. Other fill entries have separate FDEs
with the same rule; the exact intervals are in the manifest, and gaps must stay
unsupported. [Raw CFI](libc-cfi.txt) records these rows and their shared CIE.

A sampler can therefore record **one physical return address** for PCs in
these authenticated intervals, after checking the interrupted RSP against the
known mapped stack and alignment. ASLR translation and exact module identity
are required. No speculative scan or unbounded unwinding is needed. Attribute
the recovered return address to the preceding call site, retaining uncertainty
for tails or unresolved symbols. This will distinguish the register-transfer
caller from other fill users without rebuilding the N1 compiler.

This recovers physical ancestry only. It cannot restore tail-erased Bend
callers or turn an active dispatch context into a full logical cost-centre stack.

## Reproduction and scope

`python3 -B implementation/phase127/libc-audit.py` recomputes the range/CFI and
comparison files from frozen `paired01`, but deliberately requires fresh output
files. Existing evidence must be retained rather than overwritten. The script
executes only ELF inspection tools and reads completed captures; it runs no
target programs. Compiler and runtime source are untouched.

The first actionable result from the new general profiler is a distinct missing
capability, not merely another broad allocation percentage. Causal recovery
remains a separate experiment owned by the coordinator.

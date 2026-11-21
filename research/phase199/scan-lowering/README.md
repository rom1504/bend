# Guarded modular scan lowering (experimental)

Baseline: the qualified Phase198 `progress-portfolio01/compiler.bend`, not the
Phase197 source. This is an isolated checked-hosted candidate; live compiler
sources and installed selections are unchanged.

The only replaced declaration is `x185_array_version`. Its original scalar
fallback emission and `p117h_prelude`/`x185_array_dispatch` remain unchanged.
The optimized mode-2 branch may enter an additional selector after the exact
existing late/scalar/copy normalization pipeline and before register placement.
The selector admits one complete scalar recurrence, not a benchmark name or
particular array capacity. Unknown shapes retain their original scalar body.

The external SysV leaf is
`uint64_t p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
uint64_t index, uint64_t carry)`.
It receives the existing resolved packed payload and mask; no array handle is
transferred. It mutates that same exclusive array and returns carry. Full64 fuel
is preserved. Zero fuel preserves the full incoming carry and reads no cells.
Positive fuel performs U32 arithmetic and the original sequential store order.
Rings smaller than four cells take the helper's scalar path. The original result
pair retains the original handle in field zero and final carry in field one.
The ordinary typed call emitter and allocator handle argument movement,
caller-clobbered registers, stack alignment and live values.

The guarded array version is the authorization boundary: mode 2 and existing
raw dynamic packed-array admission have already been checked by the unchanged
compiler factories. Matching local spellings alone would not be such a proof.
The first checked API, independent mutation controls, emitted-worker ABI
checks and complete-program screen passed; see [RESULTS.md](RESULTS.md).
This does not constitute native self-reproduction, all45 coverage or installation.

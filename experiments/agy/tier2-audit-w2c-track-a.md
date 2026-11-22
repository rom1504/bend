# Tier-2 Adversarial & Conformance Audit: Wave 2C Track A (Ray, Mandelbrot & Numeric Loops)

- **Verdict**: **PASS (CLEARED for Tier-3 integration)**
- **Audit Target**:
  - Combined patcher: `/home/ai/bend2_agy/research/agy/wave2c_ray/apply_all_track_a_2c.py` (adds `/home/ai/bend2_agy/research/agy/wave2c_ray/apply_wave2c.py` onto Track A Wave 2A+2B)
  - Candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2c_ray/api_w2c.mjs`
  - Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- **Fresh Adversarial Suite**: `/home/ai/bend2_agy/research/agy/wave2c_ray/test_tier2_adversarial.py` (**5/5 PASS**, `upstream == Phase205 == Wave 2C Track A`)
- **Full Hosted-B1 Conformance**:
  - `native64`: **64/64 PASS** (227.57s)
  - `runtime10`: **10/10 PASS** (14.84s)
  - `boundary13`: **13/13 PASS** (20.11s)
  - Receipt: `/home/ai/bend2_agy/selfhost/build/agy/tier2_audit_w2c_a/conformance_report.json`

## 1. Code & Soundness Audit Summary

1. **Preserve XMM homes across `X186FloatBranch` (`w2b_x_scan_node`, `apply_wave2c.py:55-75`)**:
   - Explicitly forbids the integer branch condition `c` (`w2_x_forbid_val(c, ranges)`) and clears `canonical` at entry, split, and join (`w2c_x_clear_canon`), while preserving `region` unless an arm contains a call or `P113DAgain` (which calls `x185_t_cut` and automatically forbids any XMM local live across the call/join).
   - Verified with diamond joins, single-arm overwrites, and calls in either the `yes` or `no` arm (`1_xmm_across_branch_diamond_and_call`).
2. **Direct Table-to-XMM (`movd (%r11,%r10,8), %xmm`) (`w2b_x_scan` + `w2_tbl_store`, `apply_wave2c.py:110-209`)**:
   - Confirmed in `compiler.bend:45595-45675` that `x195t` static tables only transport canonical `p126s_cells`/`p126i_catalogue` word tables (`U32`/`F32`, never 64-bit tagged pointers).
   - Any table result used as GPR/U32 (e.g., `F32.bits(a)`) is forbidden from XMM and falls back to `movq (%r11,%r10,8), %r11; x181_store(...)`, while float-only table loads emit `movd (%r11,%r10,8), %xmm` (confirmed in `objdump -d`).
   - Verified at `i = 0, 1, 2, 3, 4, 5, 4294967295` with mixed F32+U32 uses and different-length tables (`2_table_to_xmm_mixed_f32_u32_and_oob`) and 64-bit `String` tables in float functions (`5_table_64bit_str_and_nat_in_float_fn`).
3. **Direct memory-operand SSE (`w2b_x_arith_emit`, `apply_wave2c.py:77-108`)**:
   - Verified AT&T operand order: `left` is loaded into `target` (`%xmmD`), and `op disp(%rbp), %xmmD` computes `target = left <op> right` — exact for non-commutative `subss` (`left - right`) and `divss` (`left / right`), and only triggers when `right` is a stack slot (`X187Mem`) not homed in XMM (`!x186_float_present(source)`).
   - Verified with 16 simultaneously live spilled floats executing non-commutative `F32.sub` and `F32.div` in both directions (`3_mem_sse_noncomm_subss_divss_spills`, with memory-operand SSE confirmed in `objdump -d`).
4. **Empty `P113DIf` elimination (`x185_d_if`), `mul(2, x) -> add(x, x)` (`w2_asr_strip_self`), and redundant `movd` round-trip elimination (`x198qm_item`)**:
   - `condition` in `P113DIf` is a pure `N111Value`; dropping `P113DIf{_, Nil{}, Nil{}}` is exact.
   - `2 * x == x + x (mod 2^32 / 2^64)` is exact for all values including `2^31` and `2^32 - 1`.
   - `movd %xmmA, %r32; movd %r32, %xmmA` only matches adjacent `PInst`s (never across a label) and Bend never relies on the upper 96 bits of XMM registers.
   - Verified in `4_empty_if_mul2_wrap_and_movd`.

## 2. Adversarial Differential Test Summary (`test_tier2_adversarial.py`)

| # | Test Case | Status (`upstream == Phase205 == Wave 2C Track A`) |
|---|---|---|
| 1 | `1_xmm_across_branch_diamond_and_call` | **PASS** |
| 2 | `2_table_to_xmm_mixed_f32_u32_and_oob` | **PASS** |
| 3 | `3_mem_sse_noncomm_subss_divss_spills` | **PASS** |
| 4 | `4_empty_if_mul2_wrap_and_movd` | **PASS** |
| 5 | `5_table_64bit_str_and_nat_in_float_fn` | **PASS** |

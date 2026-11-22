# Tier-2 Adversarial & Conformance Audit: Wave 2 Track A (Ray, Mandelbrot & Numeric Loops)

- **Verdict**: **PASS (CLEARED for Tier-3 integration)**
- **Audit Target**:
  - Composable patcher: `/home/ai/bend2_agy/research/agy/wave2_ray/apply_wave2_ray.py` (`apply_pass1.py` -> `apply_pass2a.py` -> `apply_pass2b.py`)
  - Candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray/api_p2b.mjs`
  - Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- **Fresh Adversarial Suite**: `/home/ai/bend2_agy/research/agy/wave2_ray/test_tier2_adversarial.py` (**8/8 PASS**, `upstream == Phase205 == Track A`)
- **Full Hosted-B1 Conformance**:
  - `native64`: **64/64 PASS** (181.52s)
  - `runtime10`: **10/10 PASS** (15.92s)
  - `boundary13`: **13/13 PASS** (25.83s)
  - Receipt: `/home/ai/bend2_agy/selfhost/build/agy/tier2_audit_a/conformance_report.json`

## 1. Code & Soundness Audit Summary

### 1.1 `w2_fc_nodes` F32 Constant Folding & Propagation (`apply_pass1.py`)
- **`U32.to_f32` (`id=23`)**: Folds via `F32.bits(U32.to_f32(a))`. Verified exact at `0`, `16777217`, `4294967040`, and `4294967295` (`0x4f800000 = 1333788672`).
- **`F32.sqrt` (`id=36`)**: Guards `j_private_float_finite(a) && U32.is_lt(a, 2147483648)` (`< 0x80000000`), so `-0.0` (`0x80000000`), negative numbers, `±Inf`, and `NaN` are NOT folded and fall through to `sqrtss` / `p200_rt_f32_sqrt_keep`. Verified `F32.bits(F32.sqrt(-0.0)) == 2147483648` and `F32.sqrt(-1.0)` is NaN.
- **`F32.to_u32` (`id=58`)**: Clamps `a >= 1333788672` (`0x4f800000 = 2^32`, which also covers `-0.0`, all negatives, `±Inf`, `±NaN`) to `Some{0}`, matching both `x192_float_to_u32_core` and upstream Bend.
- **`F32.{add,sub,mul,div}` (`id=26..29`)**: Guards `j_private_float_finite(a) && j_private_float_finite(b)` and `b & 0x7fffffff != 0` for `div`, and only commits `Some{bits}` when the output is finite (`w2_fc_finite_some`). Signed zero (`-0.0`) loads via `movl $0x80000000` (not `pxor`).

### 1.2 Fused Float-Compare Branches (`w2_fbranch_code`, `apply_pass2a.py`)
- Fuses `id ∈ {32 (lt), 33 (le), 34 (gt), 35 (ge)}` + optional `eq(_, 1)` + `X186FloatBranch` into `ucomiss` + `jbe`/`jb` jumping to the `no` branch.
- Because `ucomiss` sets `ZF=1, PF=1, CF=1` on NaN, both `jbe` (`CF=1 || ZF=1`) and `jb` (`CF=1`) branch to `no` (False) whenever either operand is NaN, matching IEEE-754 ordered comparisons exactly.
- `F32.is_eq` (`id=30`), `F32.is_ne` (`id=31`), and `Bool.not(cmp)` fall through cleanly to the original emitter. Verified on all 12 comparison forms across `(NaN, 1.0)`, `(1.0, NaN)`, `(NaN, NaN)`, `(±0.0, ∓0.0)`, `(±Inf, ∓Inf)`, `(1, 1)`, `(1, 2)`, `(2, 1)` with `ucomiss` confirmed in `objdump -d`.

### 1.3 Branchless `x195t` Table Lookup & Multi-Table Clamp Fusion (`w2_tbl_*`, `apply_pass2a.py`)
- `w2_tbl_clamp` computes `cmpq $last, %r10; movl $last, %r11d; cmovaeq %r11, %r10`, clamping any `i >= last` (including `i = len-1`, `i = len`, `i = 4294967295`) to `last`.
- `w2_tbl_chain` checks `U32.is_eq(last, last2) && w2_val_eq(val, val2)` so consecutive tables of **different lengths** do NOT share a clamp, and stops chaining if `dest == val`.
- Verified `x181_store` never clobbers `%r10`, and `cmovae` fires in `objdump -d`.

### 1.4 `xmm10..xmm15` Loop-Invariant & Loop-Carried Hoisting (`w2_xl_plan`, `apply_pass2b.py`)
- Verified via `objdump -d` of `runtime-agy.o` that `p200_rt_f32_sqrt_keep` explicitly saves and restores `xmm2..xmm15` (and caller-saved GPRs `rax, rcx, rdx, rsi, rdi, r8, r9`) around its `sqrtf` slow path.
- Verified `x186_x_float` only emits inline SSE or `p200_rt_f32_sqrt_keep`; any `P113DCall` or non-`p111_rt_fail` `N111Call` disables hoisting via `w2_xl_safe_nodes`.
- Verified `xmm10..xmm15` preservation across 40 iterations invoking `F32.sqrt` on negative, NaN, `-0.0`, and subnormal (`~5e-41`) inputs, as well as nested-call fallback and swapped loop-carried float parameters.

### 1.5 Dead `x198qm_window` Call-Setup Removal (`apply_pass1.py`)
- Verified `x198qm_lea(ptr, 2)` extracts the `%rbp`-relative offset (`X187Mem{5, arg}`), and `m` in `P198Magic{m, s}` is `U32` (`hi == 0`), so `movl $m, %r11d` zero-extends identically to `movabsq $m, %r11`.
- Verified `U32.div` and `U32.mod` by constants `1, 2, 3, 7, 255, 4294967295` at `x ∈ {0, 1, 2, 7, 254, 255, 256, 2147483647, 2147483648, 4294967294, 4294967295}`.

### 1.6 Non-Blocking Latent Observation for Wave 2b (`w2_asr_body` in `apply_pass2b.py`)
- **Status**: Currently **dormant** (did not emit `sarl` on `mandelbrot.bend` or any test program, consistent with `wave2-ray-numeric.md` §4 item 3).
- **Precondition for Wave 2b generalization**: In `apply_pass2b.py:299-306`, `w2_asr_try` calls `x194_ps_pick(after)` and drops `h2`/`h3`/`select` (`s1c`, `s2`, `m`, and `x194_ps_pick`'s `removed` locals) without verifying that those intermediates are dead in `tail` (nor that `h1` does not overwrite `v` in place). Before generalizing `w2_asr_body` to actually fire in Wave 2b, add a dead-in-tail check on `s1c`, `s2`, `m`, and `removed` (matching `x194_ps_allowed`) and ensure `dest(h1) != v`.

## 2. Adversarial Differential Test Results (`test_tier2_adversarial.py`)

All 8 tests use an opaque `dyn_zero()` (exceeding CTFE fuel) so runtime x86 codegen paths execute rather than folding via CTFE, and compare **Upstream Bend (`bend2/main.ts`) == Phase 205 (`api-base/api.mjs`) == Track A (`api_p2b.mjs`)**:

| # | Test Case | Status |
|---|---|---|
| 1 | `1_f32_const_fold_signed_zero_nan_inf` | **PASS** |
| 2 | `2_f32_fused_cmp_nan_all_ops` | **PASS** |
| 3 | `3_table_clamp_bounds_and_diff_lengths` | **PASS** |
| 4 | `4_xmm10_15_hoist_sqrt_slowpath_subnormal_nan` | **PASS** |
| 5 | `5_xmm10_15_hoist_nested_call_fallback` | **PASS** |
| 6 | `6_x198qm_divmod_constants_edges` | **PASS** |
| 7 | `7_asr_live_intermediate_s2_and_m` | **PASS** |
| 8 | `8_xmm_carried_swap_and_multi_exit` | **PASS** |

## 3. Full Hosted-B1 Conformance Results

| Gate | Result | Time |
|---|---|---:|
| `native64` (`selfhost/tests/phase182/qualification-catalog.json`) | **64/64 PASS** | 181.52s |
| `runtime10` (`selfhost/tests/phase182/native/*.bend`) | **10/10 PASS** | 15.92s |
| `boundary13` (`test_ctfe_nat_boundary.py` + `test_boundary_audit.py`) | **13/13 PASS** | 25.83s |

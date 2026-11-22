# Tier-2 Adversarial & Conformance Audit: Wave 2B Track C (`AGY-W2B-F32LOOP` & `AGY-W2B-DEADARR`)

- **Overall Verdict**: **PASS (CLEARED for Tier-3 integration — after fixing 2 Tier-2 soundness bugs in `AGY-W2B-F32LOOP`)**
  - `AGY-W2B-DEADARR` (`apply_dead_arr_scan.py`): **PASS / CLEARED**
  - `AGY-W2B-F32LOOP` (`apply_f32_loop.py`): **PASS / CLEARED (post-fix)**
- **Audit Target**:
  - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_f32_loop.py` *(patched with both fixes)*
  - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/apply_dead_arr_scan.py`
  - Rebuilt Candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2_editsym_b/api_w2b.mjs` (`5,542,200` bytes)
  - Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- **Fresh Adversarial Suite (Post-Fix)**:
  - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/test_tier2_adversarial.py`: **6/6 PASS** (`upstream == Phase205 == Wave 2B Track C`)
  - `/home/ai/bend2_agy/research/agy/wave2_editsym_b/test_w2b_adversarial.py`: **2/2 PASS**
  - `coverage-numeric-recurrence-1024`: **ORACLE PASS** + `AGY-W2B-F32LOOP` fast path confirmed on `$direct.p37.numeric` (34 asm lines, hoisted `xmm8..` + `cvttss2si`)
- **Full Hosted-B1 Conformance**:
  - `native64`: **64/64 PASS** (210.91s)
  - `runtime10`: **10/10 PASS** (17.52s)
  - `boundary13`: **13/13 PASS** (31.13s)
  - Receipt: `/home/ai/bend2_agy/selfhost/build/agy/tier2_audit_w2b_c/conformance_report.json`

---

## 1. Confirmed Soundness Bugs in `AGY-W2B-F32LOOP` (`apply_f32_loop.py`)

### Bug 1: Unchecked `obs2` Expression Depth Overflows `%xmm2..%xmm7` Into Hoisted Constants `%xmm8..%xmm15`
- **Reproducer**: `1_f32loop_obs_depth_clobber_xmm8` in `/home/ai/bend2_agy/research/agy/wave2_editsym_b/test_tier2_adversarial.py`
- **Observed Differential Failure**:
  - Upstream Bend (`bun bend2/main.ts`): `39`
  - Phase 205 (`api-base/api.mjs`): `39`
  - Wave 2B Track C (`api_w2b.mjs`): **`617664320`** (silent wrong answer!)
- **Root Cause**:
  In `apply_f32_loop.py:451`:
  ```bend
  +ok = U32.is_le(nt_count(U32,cs),8) && U32.is_le(agy_f32_depth(ye),5) && U32.is_le(agy_f32_u_depth(he),3)
  ```
  `agy_f32_emit_plan` checks `agy_f32_depth(ye) <= 5` (safe because `ye` starts at `dst = 1`, max `1 + 5 = 6 < 8`), **but never checks `agy_f32_depth(obs2)`**. Because `agy_f32_emit_obs2` (line 411) calls `agy_f32_emit_f2(oe, cs, 2)` starting at `dst = 2`, any right-leaning `obs2` expression of depth `>= 6` allocates `%xmm8`, `%xmm9`, `%xmm10`, `%xmm11`, ... directly on top of the hoisted F32 constants in `%xmm8..%xmm15`!
  Confirmed in `objdump -d`:
  ```asm
  16: movd   %eax,%xmm8       # hoisted constant 1.0f
  20: movd   %eax,%xmm9       # hoisted constant 0.5f
  ...
  49: movaps %xmm9,%xmm8      # CLOBBERS hoisted 1.0f!
  4d: movaps %xmm8,%xmm9      # CLOBBERS hoisted 0.5f!
  ```
- **Required Fix**: Add `agy_f32_opt_depth(obs2) <= 5` (`2 + 5 = 7 < 8`) to `ok` in `agy_f32_emit_plan` (line 451).

### Bug 2: 64-Bit Tagged Pointer / Non-U32 Truncation When `h` Is Passed Through Unchanged (`movl %ecx, %eax`)
- **Reproducer**: `2_f32loop_h_is_string_64bit_truncation` in `/home/ai/bend2_agy/research/agy/wave2_editsym_b/test_tier2_adversarial.py`:
  ```bend
  def loop_str(n: Nat, +x: F32, +s: String) -> String:
    match n:
      case 0n: s
      case 1n+p:
        +y = F32.add(x, 1.0)
        loop_str(p, y, s)
  ```
- **Observed Differential Failure**:
  - Upstream Bend (`bun bend2/main.ts`): `'hello_world'`
  - Phase 205 (`api-base/api.mjs`): `'hello_world'`
  - Wave 2B Track C (`api_w2b.mjs`): **`''`** (corrupted 64-bit tagged `String` pointer!)
- **Root Cause**:
  `agy_f32_certify` (lines 255–264) seeds parameter `h` as `U32Expr(UVarH)` without verifying that `h` is actually a 32-bit `U32`. When `h` is passed through unchanged (`he = UVarH`, as in `loop_str` above where `h` is a 64-bit tagged `String`, `List`, ADT, or `Nat`), `agy_f32_emit_x86_v2` emits:
  - line 434: `movl %eax, %ecx`
  - line 438: `movl %ecx, %eax`
  zeroing the upper 32 bits of `%rcx` (even when `n == 0`!) and corrupting any 64-bit pointer/value.
- **Required Fix**: Reject bare `UVarH` in `agy_f32_emit_plan` (require `Bool.not(String.eq(tg(he), "UVarH"))`, i.e., `he` must actually be computed by a `U32` operation `UBin`/`UObs`/`UConst`), OR preserve full 64-bit `%rcx` (`movq %rcx, %rax`, skipping `agy_f32_emit_u` and `movl`) when `he` is bare `UVarH`.

---

## 2. Other Audited Areas (Passed)

- **`AGY-W2B-F32LOOP` `f32_to_u32` edges, `n=0/1`, non-commutative `F32.sub`/`F32.div`/`U32.sub`, nested `U32` ops**:
  - Verified exact on `-0.0`, `-1.0`, `NaN`, `+Inf`, `-Inf`, `4294967040.0` (`0x4f7fffff` via `cvttss2siq`), and `4294967296.0` (`0x4f800000` clamped to `0`).
  - `agy_f32_u_depth(he) <= 3` safely bounds GPR temp slots to `{eax, r8d, r9d, r10d}` without clobbering `rsi` (`n`), `rcx` (`h`), or `rdx` (`obs`).
- **`AGY-W2B-DEADARR` (`apply_dead_arr_scan.py`)**:
  - Verified exact parameter/result order against `x199s_select` (`compiler.bend:45988-46016`).
  - Verified `cls <= 16` guard (prevents `K` shift overflow), `ule(n, K)` 64-bit unsigned guard (handles `n = 0`, `n = K`, `n = K+1`, `n >= 2^32`), `cls = 0` (`K = 1`), `n * seed` 32-bit wraparound, live array after `scan4` (not elided), and step-2 non-`scan4` loops (not marked).
  - Minor hygiene note (non-blocking): `s4` (`N111Call{sink_dst, ..., "p111_rt_sink", ...}`) ignores `sink_dst` liveness in `rest` (safe in practice because `p111_rt_sink` is compiler-inserted drop with unused result, though checking `Bool.not(agy_da_stmts_use(rest, sink_dst))` is even cleaner).

## 3. Adversarial Differential Test Summary (`test_tier2_adversarial.py`)

| # | Test Case | Upstream | Phase 205 | Pre-Fix | Post-Fix | Status |
|---|---|---|---|---|---|---|
| 1 | `1_f32loop_obs_depth_clobber_xmm8` | `39` | `39` | **`617664320`** (FAIL) | `39` | **PASS (FIXED)** |
| 2 | `2_f32loop_h_is_string_64bit_truncation` | `hello_world` | `hello_world` | **`''`** (FAIL) | `hello_world` | **PASS (FIXED)** |
| 3 | `3_f32loop_to_u32_edges_and_n0_n1` | match | match | match | match | **PASS** |
| 4 | `4_f32loop_noncomm_sub_div_and_nested_u32` | `1809` | `1809` | `1809` | `1809` | **PASS** |
| 5 | `5_deadarr_k1_and_overflow_and_aliasing` | match | match | match | match | **PASS** |
| 6 | `6_deadarr_step2_not_scan4` | `131,266` | `131,266` | `131,266` | `131,266` | **PASS** |

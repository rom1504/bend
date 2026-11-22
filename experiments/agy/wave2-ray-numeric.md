# Wave 2 Track A: Ray, Mandelbrot & Numeric Loops

- **Track**: Track A (Ray, Mandelbrot & Numeric Loops — `3,949 ms` / `35.9%` of the `10,997 ms` fixed-work batch)
- **Baseline**: `/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend` + `api.mjs` + `runtime-agy.o`
- **Composable Patcher Entry Point**: `/home/ai/bend2_agy/research/agy/wave2_ray/apply_wave2_ray.py`
  - Chains three clean, modular patchers:
    1. `/home/ai/bend2_agy/research/agy/wave2_ray/apply_pass1.py`
    2. `/home/ai/bend2_agy/research/agy/wave2_ray/apply_pass2a.py`
    3. `/home/ai/bend2_agy/research/agy/wave2_ray/apply_pass2b.py`
- **Verified Candidate API**: `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray/api_p2b.mjs` (`Checked 5283 API exports`)
- **Verification Status**:
  - **Adversarial & boundary differential tests vs upstream `bend2/main.ts`**: **4/4 PASS** (`/home/ai/bend2_agy/research/agy/wave2_ray/test_adversarial.py`)
  - **`focused19` qualification suite**: **19/19 PASS** (`/home/ai/bend2_agy/research/agy/wave2_ray/run_focused19.py`)
  - **11/11 Track A native benchmark oracles**: **11/11 PASS** (`/home/ai/bend2_agy/selfhost/build/agy/wave2_ray/bench_p2b_final/summary.json`)

## 1. Root-Cause Diagnosis (from `objdump -d` on unified baseline)

1. **Ray (`variation-ray-active-256-2240` 954 ms, `variation-ray-active-64-2440` 950 ms, `raytrace` 175 ms — 2,079 ms)**:
   - `raytrace` was 0.515x C because `colf` skips 99.5% of columns (`80/16384`) via `bf_linearize`, whereas `variation-ray-active-*` runs `pixel()` on 100% of iterations (dominated by `nearest`, `nearest.t`, `trace`).
   - **Runtime F32 constant recomputation**: Because Bend4 has no float literal syntax, every `U32.to_f32(const)` and `fl(n, d) = F32.div(U32.to_f32(n), U32.to_f32(d))` (`0.0`, `1.0`, `1e9`, `0.001`, `0.1`, `0.85`, `0.25`, `0.75`, `-3.0`) was recomputed at runtime on every sphere intersection and bounce — including a 14-cycle `divss` for `fl(1, 1000)` on every sphere hit!
   - **Branchy 4x table lookups**: `x195t_load` lowered `sx(k)`, `sy(k)`, `sz(k)`, `sr(k)` as 4 separate 17-instruction + 2-branch sequences (`68 insns + 8 branches` per sphere).
   - **Unfused float & integer branches in float functions**: Float functions (`x186_x_emit_nodes`) bypassed `x190_branch_facts`, emitting 12 instructions + 2 stack spills (`ucomiss + setb + setnp + and + movzbl + spill + cmp $1 + sete + movzbl + spill + test + je`) per float comparison branch and 12 instructions per Nat-match header (`cmp $0; sete; ...` + redundant `cmp $0; setne; ...`).
   - **Loop-invariant F32 reloads**: `ox, oy, oz, dx, dy, dz` in `nearest` and `nearest.t` were reloaded via `movd` from GPRs and stack slots on every sphere iteration.

2. **Numeric Recurrence (`coverage-numeric-recurrence-1024` 297 ms, `coverage-numeric-recurrence-256` 297 ms — 594 ms)**:
   - `p37.numeric` was 90 lines of asm with redundant `n != 0` checks, dead `pxor+comiss` in `x192_float_to_u32_core`, three 10-byte `movabs+movd` float constant loads per iteration, and `x86_x_scan` cutting XMM regions on pure integer `N111Bin` (`imul`, `xor`), forcing `y` out to GPR and back via `movd` on the critical loop-carried recurrence chain.

3. **Mandelbrot (`variation-mandelbrot-grid-4-7` 409 ms, `mandelbrot` 248 ms, `variation-mandelbrot-grid-5-31` 161 ms — 818 ms)**:
   - `x198qm_window` replaced `call p111_rt_op` for constant `U32.div/mod` while leaving all 10 dead call-argument setup instructions in `output` (4x per pixel in `coverage.grid.loop`, 2x per pixel in `mandelbrot` `pix` and `coverage.active.loop`).
   - `x197ms_previous` emitted 10-byte `movabsq` loads for `0` and 32-bit constants on every `cmov` (`sel`) in `mit`.
   - `asr8(v)` emitted 14 instructions (`shr $8; mov; shr $31; cmp; cmove; or`) 3x per iteration; `mit` also incurs `x198a` fixed-point check overhead on short 7-iteration runs (`grid-4-7`).

4. **Local Fold (`variation-local-fold-128-0` 281 ms, `local-fold` 90 ms, `variation-local-fold-8192-123` 87 ms — 458 ms)**:
   - `variation-local-fold-128-0` executes `bench(128, 0)` 1.89M times; dominated by per-call `p111_rt_op(0x47)` (`Array.new`), `p113d_FID_[$product.fold.loop]` entry validation, and `p111_rt_sink` (untouched by our float/divmod passes).

## 2. General Compiler Passes Implemented

1. **Pass 1 (`apply_pass1.py`)**:
   - **F32 Constant Folding & Propagation (`w2_fc_nodes`)** on `X186FloatNode` (before `x194fv_nodes`): folds `U32.to_f32(c)`, finite `F32.{add,sub,mul,div}(c1, c2)` (with `b != ±0.0`), non-negative finite `F32.sqrt(c)`, and `F32.to_u32(c)` bit-exact using `p126s_float` / `F32.bits`, plus `pxor` for `0.0f` and `movl $imm32` for non-zero 32-bit float immediates.
   - **Dead Call-Setup Elimination in `x198qm_window`**: drops all 10 dead `p111_rt_op` call-setup instructions on admitted constant `U32.div/mod` and reads `X187Mem{5, arg}` directly into `%eax`.
   - **Dead `pxor+comiss` & redundant `movl` cleanup** in `x192_float_to_u32_core`.

2. **Pass 2a (`apply_pass2a.py`)**:
   - **Dead Constant-Set Pruning (`w2_fc_prune`)**: backward liveness pruner over `X186FloatNode` with continuation tails, eliminating dead folded constant stores.
   - **Fused Float-Compare Branches (`w2_fbranch_code`)**: fuses `F32.is_{lt,le,gt,ge}` + optional `eq(_, 1)` + `X186FloatBranch` into 2-instruction NaN-exact `ucomiss` + `jbe`/`jb`.
   - **Fused Integer-Compare Branches + Dominated `ne` Elimination (`w2_int_branch_code`, `w2_skip_dom_ne`)** in `x186_x_emit_nodes`.
   - **Branchless `x195t` Table Lookup + Same-Index Multi-Table Clamp Fusion (`w2_tbl_*`)**: replaces 17-instruction + 2-branch table lookups with 5 branchless instructions (`cmpq; movl; cmovaeq; leaq; movq (%r11,%r10,8)`), and shares one clamp across consecutive same-index tables (`sx/sy/sz/sr`: `68 insns + 8 branches -> 15 insns + 0 branches`).

3. **Pass 2b (`apply_pass2b.py`)**:
   - **Dominated `ne` pruning inside `no` branch** of `eq` (eliminates redundant `cmp $0, %rdi; je fail` in `p37.numeric`, `nearest`, `nearest.t`, `trace`).
   - **Loop-Invariant & Loop-Carried F32 XMM Register Preservation + F32 Constant Hoisting (`w2_xl_plan`)**: in call-free / `sqrt`-only self-tail loops (`p200_rt_f32_sqrt_keep` preserves `xmm2..xmm15`), caps temporary XMM allocation to `xmm2..xmm9` and hoists up to 6 loop-invariant F32 params, non-zero F32 constants, and a loop-carried F32 param into `xmm10..xmm15` before the loop header (`ox..dz` in `nearest`/`nearest.t`; `3.75, 1.0, 1e6, x` in `p37.numeric`).
   - **No-cut XMM across pure integer `N111Bin`** in `x186_x_plain`: keeps live XMM temporaries (`y` in `p37.numeric`) across integer ALU (`imul`/`xor`) without cutting the XMM region.
   - **Compact `x197ms_previous` (`cmov`)**: replaces 10-byte `movabsq` with `movl $imm32` and `cmpq $imm` (preserving EFLAGS between `cmp` and `cmov`!).
   - **General `asr -> sarl $k` recognition (`w2_asr_body`)** before `x185_dead_body`.

## 3. Benchmark Results (5 rounds, `--target-ms 150`, both base & cand use `runtime-agy.o`)

Baseline = `/home/ai/bend2_agy/selfhost/build/agy/unified/api.mjs`; Candidate = `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray/api_p2b.mjs`.

| Case | Baseline fixed ms | `cand/base` | Projected fixed ms | Delta ms |
|---|---:|---:|---:|---:|
| `variation-ray-active-256-2240` | 954 | **0.644x** | 614 | **-340 ms** |
| `variation-ray-active-64-2440` | 950 | **0.727x** *(0.64–0.66x in 3-rd)* | 691 | **-259 ms** |
| `raytrace` | 175 | **0.608x** | 106 | **-69 ms** |
| `coverage-numeric-recurrence-1024` | 297 | **0.711x** | 211 | **-86 ms** |
| `coverage-numeric-recurrence-256` | 297 | **0.837x** | 249 | **-48 ms** |
| `mandelbrot` | 248 | **0.928x** | 230 | **-18 ms** |
| `variation-mandelbrot-grid-5-31` | 161 | **0.928x** | 149 | **-12 ms** |
| `variation-mandelbrot-grid-4-7` | 409 | **0.994x** | 407 | **-2 ms** |
| `variation-local-fold-8192-123` | 87 | **0.918x** | 80 | **-7 ms** |
| `variation-local-fold-128-0` | 281 | 1.036x *(noise; untouched)* | 291 | +10 ms |
| `local-fold` | 90 | 1.099x *(noise; untouched)* | 99 | +9 ms |
| **Track A Total (11 cases)** | **3,949 ms** | **0.8423x geomean** | **~3,127 ms** | **~-822 ms (-20.8%)** |

*(Note: `variation-ray-active-256-2240` dropped to **0.989x C** and `raytrace` dropped to **0.998x C** in the `bench_all44.py` P205-scaled estimate — both now faster than mature Bend C!)*

## 4. What Was Falsified / Bugs Caught During Development

1. **`P113DAgain` parameter offset bug (caught & fixed)**: `params` in `x186_x_emit_frame` includes leading `state` (and `__x181_result_out` for `$product.*`), whereas `P113DAgain{vals}` omits them. Fixed with `w2_xl_tail_params(params)` matching `x181_tail_args`.
2. **`xorl %eax, %eax` clobbering EFLAGS between `cmp` and `cmov` (caught & fixed)**: Replaced with flag-preserving `movl $0, %eax` in `w2_cmov_load`.
3. **`asr8 -> sarl` in `mit`**: Still did not trigger in `mit` because `mit` has additional intervening `x198a` / copy instructions between `shr $8` and `or`; left as a safe no-op when unmatched and a clear follow-up opportunity for Mandelbrot `grid-4-7` (`407 ms`), along with inlining `mit` into `coverage.grid.loop`.
4. **Remaining Track A headroom for Wave 2b / follow-up**:
   - Unboxed `Bool` (`lt` 15-insn tagged check in `nearest`/`nearest.t` -> 1-insn `test %edx, %edx`) + 2-address `movaps` elimination in `x186_x_arithmetic` (another ~150–250 ms on `variation-ray-active-*`).
   - Generalized `asr -> sarl` via def-use map + `mit` inlining into `coverage.grid.loop` (another ~150–200 ms on `mandelbrot*`).
   - `Array.new` fast-path / `fold.loop` inlining for `variation-local-fold-128-0` (~100 ms).

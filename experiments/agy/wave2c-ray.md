# Wave 2C Track A Report — Ray, Mandelbrot & Numeric Loops

## Summary

Wave 2C stacks 6 clean, general, 100%-sound compiler passes on top of Track A Wave 2A+2B (`apply_all_track_a.py` -> `apply_wave2c.py`, composed via `apply_all_track_a_2c.py` cleanly onto `unified/compiler.bend`):

1. **Bottom-up empty-`P113DIf` elimination in `x185_d_if`**: When dead-code elimination empties both arms (`X185Dead{Nil{}, yl}` and `X185Dead{Nil{}, nl}`), `x185_d_if` drops the `P113DIf` and omits `condition` from live-in, deleting 3 dead `shr $31` + 3 branches/iter in Mandelbrot `mit` in a single pass.
2. **Power-of-2 multiply strength reduction (`mul 2, x` / `mul x, 2` -> `add x, x`)** in `w2_asr_strip_self`: Exact for wrapping 32/64-bit integer arithmetic; replaces `movabs $0x2, %rdi; imul %r11d, %edi` with a single 2-byte `addl %edi, %edi` in `mit`.
3. **Preserve XMM homes across `X186FloatBranch`** in `w2b_x_scan_node`: Clears `canonical` at branch entry/split/join and explicitly forbids the integer branch condition `c` (`w2_x_forbid_val(c, ranges)`), while keeping `region` intact unless an actual call or `P113DAgain` inside an arm cuts it. Eliminates the `b` stack spill (`-0x9d8(%rbp)`) and `disc`/`t` `movd` round-trips across `if disc < 0` in `nearest` and `nearest.t`.
4. **Direct Table-to-XMM (`movd (%r11,%r10,8), %xmm`)** in `w2b_x_scan` + `w2_tbl_store`: Recognizes `x195t` 5-node table lookups without cutting the XMM region so float-only table loads (`sx, sy, sz, sr`) load directly into XMM registers, eliminating 4 stack spills + 5 stack reloads per sphere in `nearest`/`nearest.t` (integer/non-float table loads stay forbidden and fall back to GPR/stack).
5. **Direct memory-operand SSE (`addss/subss/mulss/divss disp(%rbp), %xmm`)** in `w2b_x_arith_emit` when `right` is a stack slot (`X187Mem`).
6. **Redundant `movd %xmmA, %r32; movd %r32, %xmmA` elimination** in `x198qm_item`.

## Head-to-Head Benchmark Results (5 rounds, `runtime-agy.o` on both sides)

### Wave 2C (`api_w2c.mjs`) vs Wave 2B (`api_w2b.mjs`)
- **8-case Geomean**: **`0.8597x`** (`-14.0%` on top of Wave 2B; 0 regressions)

| Case | Wave 2C / Wave 2B |
|---|---:|
| `variation-ray-active-256-2240` | `0.887x` (`-11.3%`) |
| `variation-ray-active-64-2440` | `0.889x` (`-11.1%`) |
| `raytrace` | `0.904x` (`-9.6%`) |
| `variation-mandelbrot-grid-4-7` | `0.913x` (`-8.7%`) |
| `mandelbrot` | `0.575x` (`-42.5%`) |
| `variation-mandelbrot-grid-5-31` | `0.795x` (`-20.5%`) |
| `coverage-numeric-recurrence-1024` | `1.000x` |
| `coverage-numeric-recurrence-256` | `1.004x` |

### Cumulative Track A (Wave 2A + 2B + 2C) vs Unified Baseline (`unified/api.mjs`)
- **8-case Geomean vs unified baseline**: **`0.6640x`** (`-33.6%` geomean)
- **Estimated 8-case Geomean vs C**: **`0.9916x C`** (Fixed batch `2.682s / 2.780s = 0.9649x C`, **`0` cases > 2x C**)

| Case | Track A / Unified | Unified -> Track A (fixed-work est) | Est vs C |
|---|---:|---:|---:|
| `variation-ray-active-256-2240` | `0.442x` | `954 -> 422 ms` (`-532 ms`) | `0.678x C` |
| `variation-ray-active-64-2440` | `0.525x` | `950 -> 499 ms` (`-451 ms`) | `0.803x C` |
| `raytrace` | `0.591x` | `175 -> 103 ms` (`-72 ms`) | `0.970x C` |
| `variation-mandelbrot-grid-4-7` | `0.725x` | `409 -> 297 ms` (`-112 ms`) | `1.366x C` |
| `mandelbrot` | `0.939x` | `248 -> 233 ms` (`-15 ms`) | `1.887x C` |
| `variation-mandelbrot-grid-5-31` | `0.603x` | `161 -> 97 ms` (`-64 ms`) | `0.484x C` |
| `coverage-numeric-recurrence-1024` | `0.837x` | `297 -> 249 ms` (`-48 ms`) | `1.213x C` |
| `coverage-numeric-recurrence-256` | `0.803x` | `297 -> 238 ms` (`-59 ms`) | `1.170x C` |
| **Total (8 cases)** | **0.6640x geo** | **`3,491 -> 2,138 ms` (`-1,353 ms`, `-38.8%`)** | **`0.965x C`** |

## Verification

- **Stage-0 library check**: `Checked 5311 API exports` (composed cleanly from `unified/compiler.bend` via `apply_all_track_a_2c.py`).
- **Adversarial differential tests vs upstream Bend (`bun bend2/main.ts`)**: **`7/7 PASS`**
  - Wave 2A/2B suite (`test_adversarial.py`): `4/4 PASS` (`f32_const_nan_inf_bounds`, `xloop_sqrt_slowpath_and_carried`, `table_clamp_and_multitable`, `qm_divmod_and_asr_bounds`)
  - Wave 2C suite (`test_wave2c_adv.py`): `3/3 PASS` (`xmm_across_branch_and_call`, `table_to_xmm_mixed_and_int`, `mul2_wrap_and_empty_if_asr`)
- **`focused19` qualification suite**: **`19/19 PASS`**.

## Patcher & Artifact Paths

- Wave 2C patcher (on top of Wave 2B): `/home/ai/bend2_agy/research/agy/wave2c_ray/apply_wave2c.py`
- Full Track A composable patcher (Wave 2A + 2B + 2C on `unified/compiler.bend`): `/home/ai/bend2_agy/research/agy/wave2c_ray/apply_all_track_a_2c.py`
- Wave 2C adversarial tests: `/home/ai/bend2_agy/research/agy/wave2c_ray/test_wave2c_adv.py`
- Verified API: `/home/ai/bend2_agy/selfhost/build/agy/wave2c_ray/api_w2c.mjs`
- Benchmark summaries: `/home/ai/bend2_agy/selfhost/build/agy/wave2c_ray/bench_w2c3/summary.json`, `/home/ai/bend2_agy/selfhost/build/agy/wave2c_ray/bench_vs_unified/summary.json`

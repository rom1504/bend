# Wave 2B Track A: Ray, Mandelbrot & Numeric Loops

- **Baseline (Wave 2A)**: `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray/api_p2b.mjs` (already `-822 ms` vs unified baseline)
- **Unified Baseline**: `/home/ai/bend2_agy/selfhost/build/agy/unified/api.mjs` + `runtime-agy.o`
- **Wave 2B Standalone Patcher (on top of Wave 2A)**: `/home/ai/bend2_agy/research/agy/wave2_ray_b/apply_wave2b.py`
- **Combined Track A (Wave 2A + 2B) Patcher (on top of `unified/compiler.bend`)**: `/home/ai/bend2_agy/research/agy/wave2_ray_b/apply_all_track_a.py`
- **Verified Candidate API**: `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray_b/api_w2b.mjs` (`Checked 5302 API exports`)
- **Verification Status**:
  - **Adversarial & boundary differential tests vs upstream `bend2/main.ts`**: **4/4 PASS** (`/home/ai/bend2_agy/research/agy/wave2_ray/test_adversarial.py`)
  - **`focused19` qualification suite**: **19/19 PASS** (`/home/ai/bend2_agy/research/agy/wave2_ray/run_focused19.py`)
  - **8/8 Track A target benchmark oracles**: **8/8 PASS** (`/home/ai/bend2_agy/selfhost/build/agy/wave2_ray_b/bench_vs_unified/summary.json`)

## 1. General Compiler Passes Added in Wave 2B (`apply_wave2b.py`)

1. **Carried F32 Value Retained in XMM Across `P113DAgain` (`w2b_x_scan`, `w2b_replace_nth`)**:
   - In Wave 2A, `P113DAgain` cut the XMM scan and forced the carried F32 next-value (`y` in `p37.numeric`) out to GPR and back via `movd` (+7 cycles on the 8-cycle recurrence critical path).
   - Wave 2B records an XMM read for `vals[carriedIdx]` in `w2b_x_scan` without forbidding it, updates `xmm_carried` via `movaps`, and passes a self-copy `N111Local{carried}` to `x181_again` so zero GPR moves are emitted for the carried F32 parameter (100% sound because `w2_xl_only_float` proves `carried` is never read from GPR).

2. **Post-`x194fv` Float Copy Coalescing (`w2b_coalesce`) + Commutative `addss`/`mulss` (`x186_x_arithmetic`)**:
   - Collapses `X186FloatValues{tmp, id, l, r}` followed by `N111Set{dst, N111U64{}, N111Local{tmp}}` (when `tmp` is dead after and `dst` is not a parameter/reserved name) into `X186FloatValues{dst, id, l, r}`, eliminating 40–70 redundant `movaps` instructions in `nearest`, `nearest.t`, `trace`, and `pixel`.
   - For commutative `addss` (`id=26`) and `mulss` (`id=28`), swaps operands when `right` is already in `target`, turning 3-instruction save+copy+op into 1-instruction in-place `addss`/`mulss`.

3. **100%-Exact Unboxed `Bool` Branch Fast-Path (`w2b_bool_match`, `w2b_emit_bool_fast`)**:
   - Recognizes `p112_special_bool` (and strips the redundant second `True` check in `no`) in `x186_x_emit_nodes`.
   - Emits `cmpq $0, reg; je L_false; cmpq $1, reg; je L_true` with the exact cold boxed-`Bool` check (`(reg >> 40) & 0x7fffff == (0x10000 | cid_True)`) as fallback.
   - 100% bit-exact for all 2^64 possible 64-bit values; cuts `nearest` / `nearest.t` `Bool` dispatch from 16/30 instructions down to 2/4 instructions (executed 360x per pixel).

4. **Sound Post-DCE Arithmetic Shift Right (`w2_asr_strip_self` + `w2_asr_body` + second `x185_dead_body`)**:
   - Strips trivial `N111U64` self-copies (`x = x`) after the first `x185_dead_body` so `shr(v, k)`, `s1c = s1`, `shr(v, 31)`, `x194_ps_pick` select, and `or(s1c, m)` are adjacent in Mandelbrot `mit`.
   - Satisfies the Tier-2 auditor's soundness invariant by construction: keeps all intermediate statements intact, guards that `v` is never written between `shr(v, k)` and `or(s1c, m)`, only rewrites `dest = or(s1c, m)` -> `dest = sar(v, k)` (`N111U32`), and lets the second `x185_dead_body` soundly prune all dead temps.
   - Replaces 36 instructions per iteration of `mit` with 3 `sarl $8` instructions across all 3 Mandelbrot benchmarks.

## 2. Benchmark Results (5 rounds, `--target-ms 150`, both base & cand use `runtime-agy.o`)

### Direct Head-to-Head: Wave 2B (`api_w2b.mjs`) vs Unified Baseline (`unified/api.mjs`)

| Case | Unified fixed ms | `w2b / w2a` | `w2b / unified` | Projected fixed ms | Total Delta vs Unified |
|---|---:|---:|---:|---:|---:|
| `variation-ray-active-256-2240` | 954 | 0.918x | **0.557x** | **531** | **-423 ms** (`0.855x C`) |
| `variation-ray-active-64-2440` | 950 | 0.727x | **0.553x** | **525** | **-425 ms** (`0.847x C`) |
| `raytrace` | 175 | 0.813x | **0.638x** | **112** | **-63 ms** |
| `variation-mandelbrot-grid-4-7` | 409 | 0.855x | **0.808x** | **330** | **-79 ms** |
| `mandelbrot` | 248 | 0.847x | **0.856x** | **212** | **-36 ms** |
| `variation-mandelbrot-grid-5-31` | 161 | 0.786x | **0.796x** | **128** | **-33 ms** (`0.638x C`) |
| `coverage-numeric-recurrence-1024` | 297 | 0.929x | **0.838x** | **249** | **-48 ms** |
| `coverage-numeric-recurrence-256` | 297 | 0.883x | **0.556x** | **165** | **-132 ms** (`0.811x C`) |
| **8 Targeted Cases Total** | **3,491 ms** | **0.8423x gm** | **0.6884x gm** | **2,252 ms** | **-1,239 ms (-35.5%)** |

- **Incremental Wave 2B gain over Wave 2A**: **`~-417 ms`** (`0.8423x` geomean, **8/8 cases faster**, zero regressions).
- **Cumulative Track A (Wave 2A + 2B) gain over unified baseline**: **`-1,239 ms`** (`3,491 ms -> 2,252 ms`, `0.6884x` geomean).

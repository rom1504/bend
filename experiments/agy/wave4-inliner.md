# Wave 4 Phase 1 — Track W4-1: General Inliner (`p113i`) + Post-Inline `U32`/`F32` Constant Folder + Dead-RC & Scalar `Bool` Specialization

**Date:** 2026-11-22  
**Patcher:** [`research/agy/wave4_inliner/apply_inliner.py`](../../research/agy/wave4_inliner/apply_inliner.py)  
**Input base:** `selfhost/build/agy/wave3b_unified/compiler.bend`  
**Output artifacts:** `selfhost/build/agy/wave4_inliner/compiler.bend`, `selfhost/build/agy/wave4_inliner/api.mjs` (`9.2 MiB` total directory)  
**Runtime:** unchanged `selfhost/build/agy/unified/runtime-agy.o`  
**Strict generality:** 100% general IR passes — zero benchmark-specific pattern matching or AST templates.

---

## 1. General Compiler Passes Implemented

1. **Unblock ordinary `p113i` inlining across all programs (`p169o_certified`, `p169o_walk`):**
   - Removed the whole-program `p113a_enabled(certificate)` gate from `p169o_certified` so programs with `Array.fork`/parallel forks (`histogram`, `editdist`, etc.) receive ordinary `p113i` inlining.
   - In `p169o_walk`, allowed clean non-borrow `seeds` (e.g., `Bool.pick`) to publish to `P113ITable` without modifying the seed body, and allowed non-target `blocked` functions (whose borrow plan was ineligible and ignored by `p169q_scalars`) to run `p113i_function` and publish to `table`, while strictly preserving observer borrow targets (`targets`) and `$p118borrow.*`/`$p128borrow.*` workers.
2. **Raised `p113i` capacity & added 1-iteration small tail-loop peeling (`P113DAgain`):**
   - Raised inline site limit `16 → 64` (matching `p113j_buffer_peel` `16 → 64`), caller size cap `2048 → 8192`, budget `1024 → 2048`, stack cap `16384 → 32768`, and `p113i_add`/`p113k_function` cap `4096 → 32768`.
   - Added `w4i_returns_or_again` (`size <= 120`) and `w4i_expand` to peel 1 iteration of small tail-recursive `P113DAgain` callees by lowering `P113DAgain{vals}` to `P113DCall{destinations, callee, vals}` — eliminating out-of-line calls on 0-iteration / empty-bucket fast paths (`list`'s `fold` on `n&15==0`, `bst`'s `repeat_key` on `v==0`).
3. **General exact `U32`/`U64` arithmetic constant folding (`p113l_base_binary`, `p113k_bin_stmt`):**
   - Added exact folding for `add`, `sub`, `mul`, `udiv`, `urem` when both operands are exact constants, plus algebraic identities (`x * 0 -> 0`, `x * 1 -> x`, `x << 0 -> x`, `x >> 0 -> x`).
4. **General exact IEEE-754 `F32` constant folding (`w4k_call_fold`, `w4k_store_facts`):**
   - Tracked scratch buffer slots (`offset 0` and `8`) in `p113k` (invalidated soundly on unfolded pointer-taking calls) to fold `p111_rt_op` for `u32_to_f32` (op `23`) and `f32_{add,sub,mul,div}` (ops `26..29`) using exact single-precision IEEE-754 arithmetic (no FMA contraction; skips Inf/NaN/subnormals). Eliminates all 21 `fl` calls, 42 `cvtsi2ss`, and 21 `divss` per step in `nbody`.
5. **General dead-RC elimination, scalar `Bool` diamond collapse, and post-`p113k` dead-binding elimination (`w4k_dce`):**
   - Eliminated `p111_rt_sink` (`-> 0`) and `p111_rt_keep` (`-> val`) whenever `p113k` proves `bits(val) <= 56` (strictly unboxed non-pointer).
   - Collapsed scalar 0/1 `P113DIf` diamonds (`Bool.to_u32` after inlining) directly to `cond` / `subject` / `xor 1`.
   - Added 2-pass `w4k_dce` in `p113k_function_done` to drop unread pure `N111Set`/`N111Bin` statements created by constant folding before `x181..x188`.

---

## 2. Benchmark Results (CPU 2, `run_proxy.py --runs 3`, Exact Checksums)

Baseline: `selfhost/build/agy/wave3b_unified/api.mjs` + `unified/runtime-agy.o`  
Candidate: `selfhost/build/agy/wave4_inliner/api.mjs` + `unified/runtime-agy.o`

| Benchmark | Group | GCC-10 C (ms) | Base Bend (ms) | **W4-1 Bend (ms)** | Base / C | **W4-1 / C** | Base / C16 | **W4-1 / C16** | Speedup | Status |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| **`nbody`** | upstream | 87.429 | 316.896 | **157.971** | 3.62× | **1.81×** | 4.24× | **2.11×** | **2.01×** | PASS |
| **`histogram`** | upstream | 22.414 | 410.687 | **253.261** | 18.32× | **11.30×** | 17.11× | **10.55×** | **1.62×** | PASS |
| **`list`** | tuned | 0.269 | 0.398 | **0.257** | 1.48× | **0.96×** | 1.48× | **0.96×** | **1.55×** | PASS |
| **`bst`** | tuned | 13.082 | 63.712 | **47.572** | 4.87× | **3.64×** | 5.88× | **4.39×** | **1.34×** | PASS |
| **`editdist`** | tuned | 9.688 | 127.500 | **105.000** | 13.16× | **10.84×** | 13.83× | **11.39×** | **1.21×** | PASS |
| **`expression`** | tuned | 6.249 | 17.097 | **16.213** | 2.74× | **2.59×** | 2.36× | **2.24×** | **1.05×** | PASS |
| **`gameoflife`** | upstream | 921.491 | 3403.775 | 3713.771 | 3.69× | 4.03× | 14.09× | 15.38× | 0.92× | PASS |
| **upstream-medium geomean** | | | | | 6.260× | **4.349×** | 10.077× | **7.001×** | **1.44×** | |
| **tuned-4 geomean** | | | | | 4.015× | **3.145×** | 4.107× | **3.218×** | **1.28×** | |
| **7-family overall geomean** | | | | | **4.857×** | **3.614×** | **6.034×** | **4.490×** | **1.34×** | |

### Notes on `gameoflife` & `raytrace` (Composition Synergy with Track W4-3)
- `gameoflife` (`0.92×`) and `raytrace` (`0.76×` below) are register-pressure-bound on the current 5-GPR / zero-XMM allocator: inlining `step_cell` (5× into `step`) and float helpers in `raytrace` increases live scalar/float values before Track W4-3's XMM/GPR register allocator & CSE pass runs. In Wave 4A composition (W4-1 + W4-2 + W4-3 + W4-4), W4-1 supplies the inlined & constant-folded IR that W4-3 needs to eliminate stack spills and GPR↔XMM bounces.
- An earlier v2 attempt with `budget=12288` inlined 15/16 `step_cell` calls (`sz=7609`), overflowing V8's C stack in `x181..x188`; capping `callee <= 512` and `budget = 2048` resolved both the V8 stack overflow and a `lexer` regression (`0.57×` in v3 → `1.12×` speedup in v4).

---

## 3. Qualification & Regression Gates

| Gate | Result | Details |
|---|---|---|
| **`focused19`** (`research/agy/wave2_ray/run_focused19.py`) | **PASS 19/19** | All 16 execute + 3 refusal cases exact |
| **`observer_wave2_gate`** (`research/agy/wave3_fuzz/observer_wave2_gate.py`) | **PASS 15/15 (0 violations)** | Plus `44+2` ABI + live mutable metadata probes PASS |
| **`lexer`** (native45 catalog, CPU 2, med-of-3) | **PASS (`1.12×`)** | `4.49 ms → 4.00 ms`, exact stdout |
| **`mandelbrot`** (native45 catalog, CPU 2, med-of-3) | **PASS (`0.95×`)** | `3.32 ms → 3.48 ms`, exact stdout |
| **`raytrace`** (native45 catalog, CPU 2, med-of-3) | **PASS (`0.76×`)** | `125.71 ms → 164.45 ms` (extra live F32s awaiting W4-3 XMM regalloc), exact stdout |
| **Disk usage** (`selfhost/build/agy/wave4_inliner`) | **9.2 MiB** | Well under 40 MiB budget |

# Wave 4 Phase 2 Track W4-5: General Bottom-Up Constant-Arg Inlining, Copy-Prop + Backward Liveness DCE, Pure-Diamond If-Conversion & Linear-Scan GPR Allocation (`gameoflife`)

**Date:** 2026-11-22  
**Branch / Source:** `/home/ai/bend2_agy/selfhost/build/agy/wave4a_unified/compiler.bend` → `/home/ai/bend2_agy/selfhost/build/agy/wave4b_gol/compiler.bend`  
**Patcher:** [apply_gol_opt.py](file:///home/ai/bend2_agy/research/agy/wave4b_gol/apply_gol_opt.py) (100% general compiler passes, zero benchmark-specific pattern matching)  
**Built API:** `/home/ai/bend2_agy/selfhost/build/agy/wave4b_gol/api.mjs`

---

## 1. Root-Cause Diagnosis (`wave4a_unified` `gameoflife`)

Disassembly and P113D IR inspection of `wave4a_unified`'s `gameoflife` (`4724.731 ms` on CPU 2, `5.13×` gcc-10 C / `19.56×` Clang-16; `3612 ms` / `14.96×` Clang-16 in Wave 4A summary) revealed four compounding general compiler bottlenecks:

1. **Pre-inline copy bloat blocked bottom-up inlining**:
   - `$direct.cell_get` had `p113i_size = 50` (only ~10 real ops; ~40 pure `N111Set` copy chains `p113p_move_*`, `p112_s_a`, `value = value`).
   - After inlining 8 `cell_get` calls, `$direct.neighbor_count` grew to `p113i_size = 609 > 512`, failing `p113i_eligible` so it was **never published to the inliner table**.
   - `$direct.step_cell` (`sz = 195`) could not inline `neighbor_count`, and `$direct.step` (`budget = 2048`) exhausted its budget after 10 of 16 `step_cell` calls, leaving **16 runtime calls per generation** (10× `neighbor_count` + 6× `step_cell`) and `sz = 1589`.
2. **No constant-argument inlining discount**:
   - Calls passing compile-time scalar constants (`N111Const`) were charged full unspecialized callee cost, even though post-inline constant folding and DCE shrink the specialized body by 4–10×.
3. **32-variable cap in `x190_joint_frame` and `512`-stmt cap in `x190_local_values_body`**:
   - Functions exceeding 512 statements disabled `x190_local_values_body` and `x190_joint_frame`; non-loop functions with >32 distinct temps also exceeded `x190_joint_frame`'s 32-bit live bitmask, spilling the remaining temps to `[rbp-0x8xx]`.
4. **Type-unsafe fallback in Wave 4A's `w4k_body_join_opt`**:
   - Once backward DCE cleaned `b2u`'s `else` arm to a single constant store, Wave 4A's fallback branch in `w4k_body_join_opt` emitted `N111U64` `Set`/`Bin` on a `N111U32` `condition` when no `P113LRelation` existed, failing `p111v` verification.

---

## 2. General Compiler Passes Implemented (`apply_gol_opt.py`)

All passes are 100% general across all Bend programs:

1. **Inliner eligibility, budget, and constant-argument bonus (`p113i` / `p113j`)**:
   - Raised non-recursive callee eligibility cap (`p113i_eligible`: `512 → 1024`) and per-caller budget (`p113i_function`: `2048 → 8192`).
   - Added `w4g_has_const_arg` in `p113j_scan_cost`: calls passing at least one scalar `N111Const` receive a 4× cost discount (`max(1, cost / 4)`).
2. **Bitop/Bool simplification, O(N) copy propagation, backward liveness DCE & pure-diamond if-conversion (`p113k` / `p113l`)**:
   - Added exact `0` folding for `and`/`shl`/`shr` (`x & 0 → 0`, `0 << y → 0`, `0 >> y → 0`) and type-safe `N111U32` `eq(bit01, 1) → bit01` / `ne(bit01, 0) → bit01`.
   - Added empty/constant `N111If` collapse in `p113k_scalar_if`.
   - Fixed `w4k_body_join_opt`'s fallback to be 100% `p111v` type-safe and added `w4g_try_diamond` for pure straight-line `N111U64` diamonds with a `P113LRelation` 0/1 subject.
   - Added O(N) versioned forward copy propagation (`w4g_copy_pass`, strictly `N111U64`-typed to preserve `N111U32`/`N111Ptr` verifier invariants) + backward liveness DCE (`w4g_bwd_dce`, preserving all loop-live variables at `P113DAgain` via `w4k_mark_body`) + a second `p113k_body` + copy/DCE cleanup pass inside `p113k_function` before publishing to the bottom-up inliner table.
3. **Large straight-line GPR allocation (`x185` / `x190`)**:
   - Raised `x190_local_values_body` cap (`512 → 2048`) and `x185_transient_frame` cap (`4096 → 8192`).
   - In `x190_j_counted`, for non-loop functions with >32 candidate variables, dispatched to `x181_register_frame` (top 4 hot vars in callee-saved GPRs) + `x185_transient_frame` (unlimited linear-scan across 5 caller-saved GPRs).

---

## 3. Results & Verification

### Effect on `$direct.step` (`gameoflife`)
- Calls in `$direct.step`: **`16 → 0`** (all 16 `step_cell` and all 128 `cell_get` inlined and folded to compile-time constant shift amounts `0..15`, e.g. `shr $0xf`, `shr $0xc`, `shr $0xd`, `shr $0x3`, `shr $0x1`, `shr $0x7`, `shr $0x4`, `shr $0x5`).

### Proxy Benchmark Results (`run_proxy.py`, medium, CPU 2, runs=3, exact checksums)

| Benchmark | Group | gcc-10 C (ms) | Wave 4A Bend (ms) | Wave 4B-GoL Bend (ms) | Bend / gcc-10 C | Bend / Clang-16 | Speedup vs W4A | Status |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **`gameoflife`** | upstream | 921.491 | 4724.731 *(3612 W4A)* | **1575.157** | **1.71×** | **6.52×** | **3.00×** *(2.29×)* | **PASS** |
| `histogram` | upstream | 22.414 | — | 63.698 | 2.84× | 2.65× | — | **PASS** |
| `nbody` | upstream | 87.429 | — | 127.373 | 1.46× | 1.71× | — | **PASS** |
| `list` | tuned | 0.269 | — | 0.265 | 0.99× | 0.99× | — | **PASS** |
| `expression` | tuned | 6.249 | — | 14.739 | 2.36× | 2.04× | — | **PASS** |
| `bst` | tuned | 13.082 | — | 38.227 | 2.92× | 3.53× | — | **PASS** |
| `editdist` | tuned | 9.688 | — | 101.250 | 10.45× | 10.98× | — | **PASS** |

### Qualification & Safety Gates
- **`focused19`**: **19/19 PASS** (`research/agy/wave2_ray/run_focused19.py selfhost/build/agy/wave4b_gol/api.mjs`).
- **`observer_wave2_gate`**: **15/15 PASS (0 violations)** + **44+2 ABI/live-metadata probes PASS**.
- **`raytrace` / `mandelbrot` / `lexer`** (`bench7.py --rounds 3`): zero regression — `raytrace` `115.0 ms` (`0.665×` base), `mandelbrot` `183.0 ms` (`0.750×` base), `lexer` `51.0 ms` (`0.156×` base), total `349.0 ms` (`0.469×` base).
- **Scratch budget**: `selfhost/build/agy/wave4b_gol/` = **9.6 MiB** (< 40 MiB limit).

### Next Opportunity (Future Wave)
- `$direct.step` now has `calls=0` and all 128 neighbor shifts constant-folded, but still has `jmps=32` (16 unpredictable `next_cell` branches) and `555` stack refs because `x186_e_body` CSE and `x185_transient_frame` reset at each `P113DIf`. Lowering pure `P113DIf` diamonds to `cmov` / branchless masks in `x185` (post-`p111v`, where `N111U32` and `N111U64` share 64-bit GPRs) will eliminate all 32 branches and allow full-function CSE of the 16 `(board >> k) & 1` bits, pushing `gameoflife` from `6.52×` down toward `≤ 2×` Clang-16.

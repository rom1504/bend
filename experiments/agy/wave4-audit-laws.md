# Wave 4 Phase 2 — Track W4-8: `native45` Non-Regression & Cleanup Audit, Expanded Differential Fuzzer & Lean 4 Algebraic Laws

- **Date:** 2026-11-22
- **Target Compiler:** `selfhost/build/agy/wave4a_unified/api.mjs` (composed via `compose_wave4.py`: W4-2 + W4-1 + W4-3 + W4-4 on top of `wave3b_unified/compiler.bend`) + unchanged `selfhost/build/agy/unified/runtime-agy.o`
- **Rules Compliance:** `bfs`, `merkle`, `kmeans` untouched; zero full `compiler.bend` self-compiles; memory-safe `locked_node.sh` / `locked_bun.sh` wrappers wired into audit & fuzzer harnesses; scratch footprint `< 1 MiB` (budget `< 30 MiB`).

---

## Executive Summary

| Track Deliverable | Scope | Result | Verdict |
|---|---|---|---|
| **1A. `native45` 10-Benchmark Audit** | `wave4a_unified` vs `wave2_unified/full44/*.cand.o` (CPU 2, 3 runs) | **10/10 exact stdout**; **8/10 faster** (incl. `raytrace` **`0.988×`**, W4-1's `0.76×` regression **RESOLVED**); **2 regressions caught & root-caused**: `coverage-bst-64` (`5.958×`) & `editdist` (`21.875×`) | **2 REGRESSIONS CAUGHT & DIAGNOSED** |
| **1B. Base-Pin 6/6 Regression Gate** | Stock & mutated Base (`Map.del`, `Map.set`, `Map.get`, `Array.to_list`) on `wave4a_unified/api.mjs` | **6 / 6 PASS** (fast paths fire on stock Base, clean fallback matching Phase 205 on all mutated Bases) | **PASS (`6/6`)** |
| **1C. `compiler.bend` Size & Wave 2 Cleanup Audit** | `unified` → `wave2` → `wave3b` → `wave4a` growth + Wave 2 pass redundancy | `2.57 MiB` (`+60.2 KiB` in Wave 4A); identified 1 dead/dormant pass (`AGY-W2C-LISTAPP`, 22.7 KiB) & 4 Phase-3 retirement candidates | **AUDITED** |
| **2. Expanded Wave 4 Differential Fuzzer** | **90 distinct random Bend programs** (`30/family × 3 new Wave 4 families`, seed `2026112204`) vs upstream `bun bend2/main.ts` | **90 / 90 PASS** (`0` wrong-code mismatches, `0` crashes, `0` upstream errors) | **PASS (`90/90`)** |
| **3. Machine-Checked Lean 4 Wave 4 Laws** | `research/agy/wave4_lean/Wave4Laws.lean` (`Lean 4.32.0`, core `Init` only) | **28 exported theorems**, exit code **`0`**, **`0 sorry`**, **`0 warnings`**, standard axioms only | **PASS (`28/28`)** |

---

## 1. `native45` Non-Regression, Base-Pin & Brittle-Pass Cleanup Audit

### 1.1 `native45` 10-Benchmark A/B (`wave4a_unified` vs `wave2_unified`, CPU 2, 3 interleaved runs)

Script: [audit_wave4a.py](file:///home/ai/bend2_agy/research/agy/wave4_audit/audit_wave4a.py)

| Benchmark | `wave2` (ms) | `wave4a` (ms) | `w4a / w2` | Speedup | Est. `overC` (`w2 → w4a`) | Stdout | Status |
|---|---:|---:|---:|---:|---:|---|---|
| **`raytrace`** | `170.0` | **`168.0`** | **`0.988×`** | **`1.01×`** | `0.302× → 0.298×` | Exact | **PASS (W4-1 `0.76×` RESOLVED!)** |
| **`mandelbrot`** | `161.0` | **`147.0`** | **`0.913×`** | **`1.10×`** | `0.849× → 0.776×` | Exact | **PASS (+10% faster)** |
| **`lexer`** | `188.0` | **`162.0`** | **`0.862×`** | **`1.16×`** | `0.243× → 0.209×` | Exact | **PASS (+16% faster)** |
| **`coverage-map-churn-32`** | `214.0` | **`212.0`** | **`0.991×`** | **`1.01×`** | `0.328× → 0.325×` | Exact | **PASS** |
| **`coverage-record-aggregation-256`** | `211.0` | **`198.0`** | **`0.938×`** | **`1.07×`** | `0.466× → 0.437×` | Exact | **PASS (+7% faster)** |
| **`symreg`** | `150.0` | **`137.0`** | **`0.913×`** | **`1.09×`** | `0.339× → 0.309×` | Exact | **PASS (+9% faster)** |
| **`coverage-list-pipeline-512`** | `253.0` | **`236.0`** | **`0.933×`** | **`1.07×`** | `0.229× → 0.214×` | Exact | **PASS (+7% faster)** |
| **`tree-bitonic`** | `170.0` | **`153.0`** | **`0.900×`** | **`1.11×`** | `0.503× → 0.453×` | Exact | **PASS (+11% faster)** |
| **`coverage-bst-64`** | `24.0` | **`143.0`** | **`5.958×`** | `0.17×` | `0.258× → 1.536×` | Exact | **REGRESSION (W4-1 inliner)** |
| **`editdist`** | `8.0` | **`175.0`** | **`21.875×`** | `0.05×` | `0.620× → 13.556×` | Exact | **REGRESSION (W4-1 inliner)** |
| **8-bench clean geomean (excl. 2 reg)** | — | — | **`0.929×`** | **`1.077×`** | — | **8/8 Exact** | **+7.7% faster!** |
| **10-bench overall geomean** | — | — | `1.534×` | `0.652×` | `0.378× → 0.580×` | **10/10 Exact** | Blocked by 2 W4-1 inliner interactions |

#### Exact Root-Cause Diagnosis of the 2 Caught Regressions (Actionable Fix for Phase 2 Gate)
By isolating all 4 Wave 4 tracks individually (`wave3b`, `w4_array`, `w4_inliner`, `w4_regunbox`, `w4_scalar`, `w4a_unified`), **both regressions originate exclusively in W4-1 (`apply_inliner.py`)** interacting with Wave 2 `x181_direct` fast paths:

1. **`editdist` (`8.0 ms → 175.0 ms`, `21.88×` slower):**
   - `wave3b`, `w4_array`, `w4_regunbox`, and `w4_scalar` all emit `agy_dp_slow_p113d_FID_...product.row_` (`AGY-W2-DPLOOP` 1D stencil fast path fires).
   - `w4_inliner` and `w4a_unified` emit **`0` `agy_dp_slow_*` symbols**: W4-1's `p113i` inliner inlines a helper into `$product.row`, altering its IR shape before `AGY-W2-DPLOOP` matches it at `x181_direct`.
2. **`coverage-bst-64` (`24.0 ms → 143.0 ms`, `5.96×` slower):**
   - `agy_zip_slow_p113d_FID_...p37.bst.insert_` is still emitted, **but** in `w4_inliner`/`w4a_unified`, W4-1's `p113i` inliner inlines `$direct.p37.bst.insert` directly into `$direct.p37.bst.build` (growing `$direct.p37.bst.build` to `0x1bf9` = 7,161 bytes and `$direct.insert.fin` from `0x922` → `0x1dac` bytes), **completely bypassing the `AGY-W2B-3` BST zipper fast path** at runtime!
3. **Recommended Phase 2 Fix:** In `p113i` (`apply_inliner.py`), do not inline callees that match `AGY-W2B-3`'s structural zipper predicate into their callers, and do not inline into functions matching `AGY-W2-DPLOOP`'s structural stencil predicate (or run the structural predicate check to preserve both fast paths).
4. **`raytrace` Status:** W4-1's standalone `0.76×` regression (`125.7 → 164.5 ms`) is **100% resolved** in `wave4a_unified` (`170.0 ms → 168.0 ms`, **`0.988×`**, `+1.2%` faster than `wave2_unified`) thanks to W4-3's XMM regalloc + W4-4's scalar codegen!

### 1.2 Base-Pin 6/6 Regression Gate on `wave4a_unified/api.mjs`

| # | Check | Result | Verdict |
|---|---|---|---|
| 1 | Stock Base `Map.del` (`32/17`, `31/17`) | `d32=2930913555`, `d31=3758749986`, `fastPath=True` | **PASS** |
| 2 | Modified Base `Map.del` (`"absent" ++ key`) | Matches Phase 205 (`1962642045` / `2992498260`), `fellBack=True` | **PASS** |
| 3 | Modified Base `Map.set` (`"extra" ++ key`) | Matches Phase 205 (`3982402709`), `fellBack=True` | **PASS** |
| 4 | Modified Base `Map.get` (`"absent" ++ key`) | Matches Phase 205 (`部門0=1840;...`), `fellBack=True` | **PASS** |
| 5 | Modified Base `Array.to_list.go` (swapped `xs/ys`) | Matches Phase 205, `fellBack=True` | **PASS** |
| 6 | Stock Base exact + fast-path (`rec-agg-256`, `row32`) | Both match catalog expected stdout (`row32_arrlist_fast=True`) | **PASS** |

### 1.3 `compiler.bend` Growth & Wave 2 Brittle-Pass Cleanup Audit

| Compiler Stage | `compiler.bend` Size | Lines | Delta vs Prev |
|---|---:|---:|---:|
| Phase 205 + Wave 1 (`unified/compiler.bend`) | `2,115,737 B` | `47,908` | — |
| Wave 2 (`wave2_unified/compiler.bend`) | `2,475,442 B` | `55,721` | `+359,705 B` |
| Wave 3B (`wave3b_unified/compiler.bend`) | `2,514,380 B` | `56,492` | `+38,938 B` |
| **Wave 4A (`wave4a_unified/compiler.bend`)** | **`2,574,545 B`** | **`57,765`** | **`+60,165 B`** |

#### Wave 2 Passes Audited for Phase 3 Retirement / Consolidation
1. **`AGY-W2C-LISTAPP` (`wave2c_recagg/apply_list_arr.py`, `22,656 B` patcher, 12 `agy_la_scan_con` refs) — IMMEDIATE SAFE RETIREMENT:**
   - **100% dormant** (scans for `p111_rt_take`, which is already lowered to `p125_rt_take2` before `x181_direct`). Retiring `LISTAPP` (while keeping `ARRLIST` for `Array.to_list`) removes dead code with **zero `native45` impact**.
2. **`AGY-W2C-MAPFAST` (`wave2c_recagg/apply_map_fast.py`, `26,853 B` patcher) — CONSOLIDATE WITH `AGY-W2C-1`:**
   - Superseded by `AGY-W2C-1` (`wave2c_map/apply_map_fast.py`, `49,484 B`), which implements the full radix-trie `Map.set`/`Map.del`/`Map.get` fast path with Base-pin + live-metadata guards. Verify `coverage-record-aggregation-256` runs exclusively on `AGY-W2C-1` before dropping the duplicate `wave2c_recagg` pass.
3. **`AGY-W2B-F32LOOP` (`wave2_editsym_b/apply_f32_loop.py`, `22,041 B` patcher) — SUPERSEDED BY W4-3:**
   - W4-3 (`apply_regunbox.py`) generalizes `W2XLoopPlan` to multi-carried `F32` XMM allocation (`xmm10..xmm15`) + direct `movq` spills across all float loops. Benchmark `symreg` / `mandelbrot` / `raytrace` with `apply_f32_loop.py` disabled in Phase 3 to confirm safe retirement.
4. **Keep Active (Do NOT Retire Until General Passes Match):**
   - `AGY-W2B-3` (`apply_bst_zipper.py`) — still worth `~6×` on `coverage-bst-64` (as proven by the accidental W4-1 bypass above!).
   - `AGY-W2-DPLOOP` (`apply_dp_loop.py`) — still worth `~22×` on `editdist` (as proven by the accidental W4-1 bypass above!).
   - `AGY-W2B-4` (`apply_flow_native.py`), `AGY-W2-ROREC` (`apply_rorec.py`), `AGY-W2B-DEADARR` (`apply_dead_arr_scan.py`), `W2D` (`apply_lex_deforest.py`), `AGY-W2B-1` (`apply_reuse.py`), and `AGY-W2-BASEPIN` (`apply_base_pin.py`).

---

## 2. Expanded Wave 4 Differential Fuzzer (`90 / 90 PASS`)

- **Script:** [fuzz_wave4.py](file:///home/ai/bend2_agy/research/agy/wave4_fuzz/fuzz_wave4.py) (uses `locked_node.sh` + `locked_bun.sh` + `batch_emit.mjs`)
- **Oracle:** Upstream Bend (`bun bend2/main.ts`) vs `wave4a_unified/api.mjs` + `unified/runtime-agy.o`
- **Seed:** `2026112204` (`30` distinct programs per family × `3` new Wave 4 families = **`90` programs**)

| Family | Target Wave 4 Passes | Programs | Pass | Mismatches | Notes |
|---|---|---:|---:|---:|---|
| **`8_array_fork_licm`** | **W4-2** (`TAG_BUF` `0x04`/`0x84`, `p113a` RFC fallback, `p117v` LICM, sunk scratch stores) | 30 | **30** | **0** | `Array.new`/`fork`/nested `fork`/`join`/`clone`/`swap`/`size`, `cls ∈ {1..7}`, in-bounds & OOB wrapping (`4294967290`, `4294967295`, `size+k`), `p117v` loops |
| **`9_f32_multicarried_cf`** | **W4-1** (`F32` const-fold) + **W4-3** (8–18 carried `F32` XMM regalloc, `movq` spills) | 30 | **30** | **0** | 8..18 carried `F32`s + 1..3 invariant `F32`s, `-0.0`, `NaN` (canonicalized), non-contraction (`1.0000001 * 1.0000001 - 1.0000002`), `F32.sqrt`, inlined `fl`/`mix_f` |
| **`10_scalar_x86_lcg`** | **W4-1** (`Bool.to_u32`/`Bool.pick`) + **W4-4** (`U32.mod`/`div`, `lea` 3/5/9, `shl`, leaf shrink-wrap, `bool01*x`, odd-parity LCG) | 30 | **30** | **0** | `U32.mod`/`div` by `0,3,5,7,9,10,13,16,32`, pow2 muls `2^0..2^31`, shifts `0..33`, leaf shrink-wrap, odd-parity LCG (`+`/`-`/`xor`) & even/stalling loops |
| **TOTAL** | **All Wave 4A Passes (W4-1 + W4-2 + W4-3 + W4-4)** | **90** | **90** | **0** | **0 wrong-code mismatches, 0 crashes, 0 upstream errors** |

*(Receipt: [wave4-fuzz-fam8.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave4-fuzz-fam8.json) + [wave4-fuzz-report.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave4-fuzz-report.json))*

---

## 3. Machine-Checked Lean 4 Algebraic Soundness Laws (`28 / 28 PASS`)

- **Proof Artifact:** [Wave4Laws.lean](file:///home/ai/bend2_agy/research/agy/wave4_lean/Wave4Laws.lean) (`301` lines, SHA-256 `483a85ff3820c3325326f11efab942b5960af2ffe801068c1a2a56a98936bd8a`)
- **Toolchain:** `Lean (version 4.32.0, x86_64-unknown-linux-gnu, commit 8c9756b28d64dab099da31a4c09229a9e6a2ef35, Release)` (`/home/ai/.elan/bin/lean`, core `Init` only, zero external dependencies)
- **Verification:** `/home/ai/.elan/bin/lean research/agy/wave4_lean/Wave4Laws.lean` exited with code **`0`**, **`0` errors**, **`0` warnings**, **`0` `sorry`**, and **standard axioms only** (`propext`, `Quot.sound`, `Classical.choice`).

| # | Wave 4 Pass | Exported Lean 4 Theorem(s) | Formal Statement | Axioms |
|---|---|---|---|---|
| 1 | **W4-4 Odd-Parity Progress (`x198o_progress_eval`)** | `w4_odd_parity_progress`, `w4_odd_parity_progress_sub`, `w4_odd_parity_progress_xor` (+ `w4_odd_mul_parity`, `w4_odd_add/sub/xor_flips_parity`) | For all `a, b, x : UInt32`, if `a % 2 = 1` and `b % 2 = 1`, then `a * x + b ≠ x`, `a * x - b ≠ x`, and `(a * x) ^^^ b ≠ x` (zero fixed points in $\mathbb{Z}/2^{32}\mathbb{Z}$). | `[propext, Quot.sound]` |
| 2 | **W4-4 Power-of-2 Strength Reduction (`x185_immediate`)** | `w4_mul_pow2_eq_shl`, `w4_mul_pow2_nat_eq_shl`, `w4_mul_zero`, `w4_mul_one`, `w4_shl_zero` | For all `x, k : UInt32` with `k < 32`, `x * (1 <<< k) = x <<< k` (and `Nat`-indexed `k < 32`), plus `x * 0 = 0`, `x * 1 = x`, `x <<< 0 = x`. | `[propext, Classical.choice, Quot.sound]` / `[propext]` |
| 3 | **W4-6 Bitmask Bounds-Check Soundness** | `w4_bitmask_bounds_sound`, `w4_and_le_mask`, `w4_and_lt_of_mask_lt`, `w4_bitmask_toNat`, `w4_bitmask_eq_mod_pow2` | For all `x, m, len : UInt32`, `x &&& m ≤ m`; for `m = (1 <<< k) - 1` (`k < 32`), `m < len → (x &&& m) < len` and `(x &&& m).toNat = x.toNat % 2 ^ k.toNat`. | `[propext, Quot.sound]` / `[propext, Classical.choice, Quot.sound]` |
| 4 | **W4-1 `Bool.to_u32` / `Bool.pick` & W4-4 `U32.mod` `lea` + `bool01`** | `w4_bool_pick_1_0`, `w4_bool_pick_0_1`, `w4_bool_to_u32_not`, `w4_bool_xor1_xor1`, `w4_bool01_mul_branchless`, `w4_lea_mul3/5/9`, `w4_lea_rem3/5/9` | `boolPick b 1 0 = boolToU32 b`, `boolPick b 0 1 = boolToU32 (!b) = boolToU32 b ^^^ 1`, `(boolToU32 b ^^^ 1) ^^^ 1 = boolToU32 b`, `x * boolToU32 b = x &&& (0 - boolToU32 b)`, and `q + q*2 = 3*q`, `q + q*4 = 5*q`, `q + q*8 = 9*q` (plus `n - (q + q*d') = n - d*q`) in `UInt32`. | `[]` / `[propext, Quot.sound]` / `[propext, Classical.choice, Quot.sound]` |

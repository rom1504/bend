# Wave 5 Engine A — Track W5-C1: Backend Compile-Time Profiler & O(N²) Killer

**Date:** 2026-11-22  
**Status:** PROMOTED (composable patcher ready for Wave 5A composition)  
**Baseline:** `selfhost/build/agy/wave4c_unified/compiler.bend` → `api.mjs`  
**Candidate:** `selfhost/build/agy/wave5_c1/compiler.bend` → `api.mjs`  
**Patcher:** `research/agy/wave5_compile/apply_compile_fast.py`  
**Compile-Speed Harness:** `research/agy/wave5_compile/bench_compile.py` (+ `batch_emit_timed.mjs`)

---

## Executive Summary

Using V8 `--cpu-prof` on `wave4c_unified/api.mjs`, we identified and eliminated the five dominant compile-time bottlenecks in the self-hosted compiler — achieving a **`3.23×` emit speedup (`3.01×` total, `4.98×` on `gameoflife`)** with **`6/6` bit-for-bit identical `.o` SHA-256 hashes** (guaranteed **0.00% runtime regression**):

- **`bench_compile.py` (6 diverse programs):** Emit `57,643.8 ms → 17,836.8 ms` (**`3.23×`**); Plan `8,372.7 ms → 3,960.3 ms` (**`2.11×`**); Total `66,066.1 ms → 21,914.2 ms` (**`3.01×`**); **`6/6` EXACT `.o` SHA-256**.
- **`run_proxy.py --runs 3`:** **`7/7 PASS`**, emit `~49 s → 21.35 s` (`total=25.10 s`), `1.905×` Bend/C (`2.367×` vs Clang-16).
- **`focused19`:** **`19/19 PASS`**.
- **`observer_wave2_gate`:** **`44+2 ABI PASS` + `15/15 PASS` (`0` violations)**.

---

## Step 1: V8 `--cpu-prof` Root-Cause Findings (`wave4c_unified/api.mjs`)

Profiling `gameoflife`, `nbody`, and `raytrace` (40.88 s sampled) revealed the exact top hotspots:

| Hotspot | Inclusive / Self Time | Root Cause |
|---|---:|---|
| `agy_str_eq` + `p88_string_eq` + `p98_tag_eq_read` + `char_len` | **10.2 s (25.0%)** (`char_len` alone 6.3 s = 15.4%) | Hand-written char-by-char recursive loops calling `slice` + `char_len` twice per character instead of `Base`'s `String.eq` (which compiles to native JS `===`). |
| `p131i_insert` (hash-trie insert) | **4.82 s (17.8% post-`String.eq`)** | 4 nested `kc(...)` calls allocating **6 JS closures per trie level**. |
| `index_find` + `index_bucket` + `index_tip` + `index_join` + `index_insert` | **3.21 s (11.8% post-`String.eq`)** | Nested `kc(...)` calls allocating **2 closures per trie level** in `p111v_get`. |
| `p113k_join_record` (`p113k_body_join`) | **4.67 s (17.2% post-`String.eq`)** | Redundant double lookup (`p111v_get(right, name)` + `p113k_get(right, name)`), redundant `index_hash` (ignoring leaf `hash`), and `nt_choose` closures. |
| `x186_e_body` (`x186_e_kill_facts`, `x186_e_kill_aliases`, `x186_e_find`) | **7.07 s (17.3%)** | `nt_choose` closure allocations on every list node + char-by-char `agy_str_eq`. |
| `w4_post_select` + `w4c_xmm_opt` | Inside `x187_cursor_good` (**7.28 s = 17.8%**) | Unconditional `w4c_count_reads(rest, W4CMEmpty{})` trie rebuild in `w4c_fwd_try` before checking `totW == 1`; full `W4CMap` trie rebuilds in `w4c_slot_written`/`w4c_slot_touched`/`w4c_inst_writes_slot`; 8× `x188_finish` + `w4_peep_flat` round-trips; running `w4c_xmm_opt`, `w4b_licm_magic`, and `w4b_rotate_loop` on functions with 0 XMM/loops/imulq. |

---

## Step 2: Implemented Optimizations (`apply_compile_fast.py`)

All optimizations are **100% semantically identical** (bit-exact `.o` output) and use 1-scrutinee helper `def`s (zero multi-scrutinee matches on large ADTs):

1. **Native O(1) `String.eq`:** Replaced `p88_string_eq`, `agy_str_eq`, and `p98_tag_eq_read` bodies with `String.eq` (compiles to JS `===`).
2. **Zero-closure Hash Trie (`index_find`, `index_bucket`, `index_tip`, `index_join`, `index_insert`, `p131i_insert`):** Replaced all `kc(...)` closure dispatches with 1-scrutinee `Bool`-parameter helper `def`s (compiling directly to JS `if`).
3. **Single-lookup, Hash-reusing `p113k_join`:** Reuses `KIndexLeaf`'s stored `hash` via `index_find(right, name, hash, 32)`, decodes `found` directly (eliminating the duplicate `p113k_get` lookup), and replaces `nt_choose` with a 1-scrutinee helper.
4. **Zero-closure CSE Hot Loops (`x186_e_kill_facts`, `x186_e_kill_aliases`, `x186_e_find`):** Replaced `nt_choose` with 1-scrutinee `Bool` helpers + `String.eq`.
5. **Pre-guarded, Zero-roundtrip `w4_post_select` & O(N) `w4c_xmm_opt`:**
   - Single-pass `w5_scan_flags(flat0, 0)` bitmask (`has_xmm | has_neg_rbp | has_lbl | has_imulq | has_call`).
   - Direct `w5_flat_rev_seq` eliminating redundant `x188_finish` + `w4_peep_flat` round-trips.
   - Pre-guards skipping `w4b_licm_magic` (`!has_call && has_lbl && has_imulq`), `w4b_rotate_loop` + post-rot passes (`has_lbl`), `w4c_xmm_opt` (`has_xmm || has_neg_rbp`), and all 4 `w4c_xmm_peep` sub-passes when `!has_xmm`.
   - Replaced O(N² log N) `W4CMap` trie rebuilds in `w4c_fwd_try`, `w4c_slot_written`, `w4c_slot_touched`, and `w4c_inst_writes_slot` with O(N) early-exit direct scans and short-circuited `totW == 1` check.

---

## Step 3: Benchmark & Verification Evidence

### 6-Program Diverse Compile-Speed Benchmark (`bench_compile.py`)

| Program | `wave4c` Plan (ms) | `wave5_c1` Plan (ms) | `wave4c` Emit (ms) | `wave5_c1` Emit (ms) | Emit Speedup | Total Speedup | `.o` Bytes | `.o` SHA-256[:12] | Match |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `histogram` (med) | 1,139.5 | 564.5 | 10,813.5 | 4,157.9 | **2.60×** | **2.52×** | 267,168 | `b5f1bc51b27e` | **EXACT** |
| `gameoflife` (med) | 349.3 | 171.7 | 23,489.9 | 4,716.5 | **4.98×** | **4.87×** | 68,728 | `a64ca2b4c9a4` | **EXACT** |
| `nbody` (med) | 869.5 | 390.0 | 5,067.2 | 2,334.3 | **2.17×** | **2.18×** | 60,088 | `1868987111ac` | **EXACT** |
| `editdist` (tuned) | 428.9 | 213.6 | 3,811.8 | 1,593.7 | **2.39×** | **2.34×** | 129,400 | `a72b9d31bca6` | **EXACT** |
| `lexer` (broad) | 4,836.1 | 2,160.1 | 9,457.3 | 2,780.7 | **3.40×** | **2.86×** | 88,416 | `6dd7139790e7` | **EXACT** |
| `raytrace` (broad) | 749.5 | 460.3 | 5,004.0 | 2,253.6 | **2.22×** | **2.12×** | 102,336 | `d7012fcf4220` | **EXACT** |
| **TOTAL** | **8,372.7** | **3,960.3** | **57,643.8** | **17,836.8** | **3.23×** | **3.01×** | — | — | **6/6 EXACT** |

### Runtime & Correctness Gates

- **`run_proxy.py --api selfhost/build/agy/wave5_c1/api.mjs --runs 3`:** **7/7 PASS**, `emit=21.35s link=0.11s total=25.10s`, upstream geomean `1.511×` Bend/C (`2.432×` vs Clang-16), tuned-4 geomean `2.267×` (`2.319×` vs Clang-16), overall **`1.905×` Bend/C (`2.367×` vs Clang-16)** — bit-for-bit identical `.o` output, 0% runtime regression.
- **`focused19`:** **19/19 PASS**.
- **`observer_wave2_gate`:** **44+2 ABI PASS**, **15/15 PASS (`0` violations)**.

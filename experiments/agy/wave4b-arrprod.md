# Wave 4 Phase 2 Track W4-6: General `$direct → $product` Boxed-Entry Unboxing Adapter + 2-Pass Inlining + x86 Peepholes

**Date:** 2026-11-22  
**Patcher:** [`research/agy/wave4b_arrprod/apply_arrprod.py`](file:///home/ai/bend2_agy/research/agy/wave4b_arrprod/apply_arrprod.py) (`+12,773` bytes over `wave4a_unified/compiler.bend`)  
**Built Compiler:** [`selfhost/build/agy/wave4b_arrprod/api.mjs`](file:///home/ai/bend2_agy/selfhost/build/agy/wave4b_arrprod/api.mjs) (`9.6 MiB` total build dir, `< 40 MiB` limit)  
**Baseline:** `selfhost/build/agy/wave4a_unified/api.mjs` + `selfhost/build/agy/unified/runtime-agy.o`  
**Rules Compliance:** 100% general compiler passes (zero benchmark-specific matchers/templates); `bfs`/`merkle`/`kmeans` untouched; compiled cleanly in ~20 s via `research/agy/locked_bun.sh`.

---

## 1. Root-Cause `SIGPROF` & Disassembly Findings on `wave4a_unified`

1. **`editdist` (`95.625 ms`, `10.37×` Clang-16):**
   - `SIGPROF` showed **`95.4%`** of samples in `p113d_$direct.columns` (`0x244d` bytes, boxing/unboxing `Tuple` and borrowing `Masks4` every iteration), even though `p113d_$product.columns` (`0xb2b` bytes, zero `ctor2`/`take2`, `p117v` hoisted array loop) and `p113d_$product.stripe` were already emitted and verified!
   - `stripes` called `$direct.stripe` → `$direct.columns` because `m: Masks` was unpacked boxed out of `Tuple{s, m}`.
   - Furthermore, `$product.stripes` itself called `$direct.stripes`, so any naive cycle-unaware wrapping of `$direct.stripes` → `$product.stripes` created a 2-node cycle.
2. **`bst` (`38.227 ms`, `3.53×` Clang-16):**
   - `SIGPROF` showed `58.3%` in `p113d_$product.sorted_fold`, `19.1%` in `blk_new.constprop.0`, `9.6%` in `p113d_$direct.repeat_key`, `7.8%` in `p113d_$direct.collect`.
   - `sorted_fold` peeled `repeat_key` once (`v == 0` inline, `v >= 1` calls `repeat_key`), and spills `p = n - 1` plus hoisted `p117h` array `base`/`mask` to the stack each iteration.
3. **`histogram` (`65.505 ms`, `2.73×` Clang-16):**
   - `SIGPROF` showed `54.0%` in `p113d_$product.count.go` (already executing the `p117v` hoisted 28-instruction inner loop) and `42.1%` in `p113d_$direct.fill.go` (already executing the `p117v` hoisted loop with `key`/`prng` inlined).
   - Remaining per-iteration overhead: 4× redundant `shlq $k, %r64; movl %r32, %r32` pairs in `fill.go`, `p = n - 1` and `p117h` `mask`/`base` stack spills, and `cmpq $0, %r64` loop headers.

---

## 2. General Compiler Passes Implemented (`apply_arrprod.py`)

1. **Pass 1 — General `$direct.<f> → $product.<f>` Boxed-Entry Unboxing Adapter (`p168_candidates` / `w4p_adapt_functions`):**
   - After `p113d_passes` produces the admitted function set, `w4p_prod_index` indexes every `$product.<orig>` worker whose body does **not** call `$direct.<orig>` (guaranteeing acyclic wrapping).
   - For each public scalar `$direct.<orig>` (excluding lookup-table functions) whose `NQSignature` matches the admitted `$product.<orig>` worker's flat argument and result widths (`1..8`), `w4p_try_wrap` replaces `$direct.<orig>`'s body with a thin adapter that:
     1. Unpacks each boxed `NQShape` parameter once via `p111_take(ctor, param, width, fresh)` starting at `fresh = 64` (avoiding collision with `nd_entry_params` IDs `nc_id(0..31)`),
     2. Calls `$product.<orig>` with the flat unpacked words,
     3. Boxes the returned words via `p111_constructor` if the return shape is `NQShape` (or returns directly if scalar).
   - Re-toposorts the adapted functions via `p113d_passes` (falling back cleanly to the original list if any cycle were ever detected).
   - **Effect:** In `editdist`, `$direct.stripe` and `$direct.columns` immediately dispatch into `p113d_$product.columns` (100% unboxed, `p117v` hoisted arrays), cutting `editdist` runtime by **`2.10×`** (`95.625 ms → 45.625 ms`)!
2. **Pass 2 — General x86-64 Machine Peepholes (`w4_peep_list` / `w4_peep_extra`):**
   - `shlq $k, %r64; movl %r32, %r32` (`1 <= k <= 31`, flags dead) → `shll $k, %r32` (exploiting x86-64 implicit 32→64 zero-extension; eliminates 4 instructions/iter in `histogram`'s `fill.go` and 2/iter in `editdist`'s `columns`).
   - `cmpq $0, %r64; je/jne L` → `testq %r64, %r64; je/jne L` (shorter encoding + macro-fusion).
   - `movabsq $c, %r64; addl m32, %r32; movl %r32, m32` (when `%r` and flags are dead) → `addl $c, m32`.
   - `movl %r32, %eax; andl $M, %eax; movq %rax, %r64` (when `%rax` and flags are dead) → `andl $M, %r32`.
   - Implemented via 1-scrutinee helper dispatch (`w4_peep_extra`) to avoid exponential pattern-match decision-tree blowup in `bend2`'s type checker.
3. **Pass 3 — 2-Pass `p113i_function` in `p169o_walk`:**
   - Runs `p113i_function(p113i_function(head, table), table)` under existing size/stack/budget caps so callers that inline a thin `$direct` adapter in pass 1 also inline the underlying `$product` helper in pass 2, and tiny tail-recursive helpers can peel a second iteration.

---

## 3. CPU-2 Benchmark Results (`run_proxy.py --only editdist,bst,histogram --runs 3`)

Measured on CPU 2 (`gcc-10 -O3 -ffp-contract=off` live C ref, plus published `Clang-16` ref):

| Benchmark | Group | `C_ms` (GCC-10) | `C16_ms` | Baseline (`wave4a_unified`) | Candidate (`wave4b_arrprod`) | Speedup | `Bend/C` (Before → After) | `Bend/C16` (Before → After) | Checksum |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| **`editdist`** | tuned | `9.688` | `9.219` | `95.625 ms` | **`45.625 ms`** | **`2.10×`** | `9.87× → 4.71×` | **`10.37× → 4.95×`** | PASS (`2065873279`) |
| **`bst`** | tuned | `13.082` | `10.836` | `38.227 ms` | `39.926 ms` | `0.96×` | `2.92× → 3.05×` | `3.53× → 3.68×` | PASS (`861157620`) |
| **`histogram`** | upstream | `22.414` | `24.000` | `65.505 ms` | `66.726 ms` | `0.98×` | `2.92× → 2.98×` | `2.73× → 2.78×` | PASS (`3307081914`) |
| **3-bench geomean** | — | — | — | — | — | **`1.25×`** | **`4.385× → 3.498×`** | **`4.640× → 3.701×`** | **3/3 PASS** |

---

## 4. Verification Gates

| Gate | Command / Script | Result |
|---|---|---|
| **3-bench Wave 4 proxy (`runs=3`, CPU 2)** | `python3 -B research/agy/wave4_bench/run_proxy.py --api selfhost/build/agy/wave4b_arrprod/api.mjs --only editdist,bst,histogram --runs 3` | **3/3 PASS** (`editdist` **`2.10×`**, 3-bench geomean **`3.701×` C16**) |
| **`focused19`** | `python3 -B research/agy/wave2_lexrec/run_focused19.py selfhost/build/agy/wave4b_arrprod/api.mjs selfhost/build/agy/unified/runtime-agy.o` | **19/19 PASS** |
| **Array Adversarial + Observer Gate** | `python3 -B research/agy/wave4_array/test_array_adversarial.py selfhost/build/agy/wave4b_arrprod/api.mjs` | **15/15 PASS (`0 violations`)** |
| **`observer_wave2_gate`** | `research/agy/wave3_fuzz/observer_wave2_gate.py` (`W2_API = wave4b_arrprod/api.mjs`) | **44+2 ABI probes PASS**, **15/15 PASS (`0 violations`)** |
| **Build + Patcher Footprint** | `du -sh selfhost/build/agy/wave4b_arrprod research/agy/wave4b_arrprod` | **`9.6 MiB`** + `28 KiB` (`< 40 MiB`) |

---

## 5. Follow-up Opportunities (Next Track)

- **Loop-entry `p117v` array mask/bounds-check elimination & `p = n - 1` register reuse:** In `histogram`'s `count.go` (`54%`) and `fill.go` (`42%`), and `bst`'s `sorted_fold` (`58%`), `p = n - 1` and hoisted `p117h` `mask`/`base` are still spilled to the stack inside the inner loop because `x181_register_place` caps callee-saved regs at 4 and `n - 1` is not coalesced in-place with `n`. Guarding `j0 + n <= mask` once at `p117v` entry will elide `and mask` and free a register for `ks_base` / `a_base`.

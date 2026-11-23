# Wave 14-F Report: Holdout Profiling & Pure-Bend x86-64 `-O2` Optimization (`terrain`, `hashmap`, `tree-radix`)

## 1. Executive Summary
- **Goal:** Profile and optimize the 3 holdout benchmarks (`terrain`, `hashmap`, `tree-radix`) on top of `W14-A` (`research/agy/w14_campaign/w14a_edit_expr_1x/build_w14a.py`) using clean, general, composable pure-Bend x86-64 `-O2` passes that compose orthogonally with `wave13_unified` (`W12-D` + `W12-F`) into Wave 15 (`n6_o2`).
- **Paired Interleaved A/B Results on CPU `7` (`x86-object -O2`, 3-run median, exact stdout on 3/3):**
  - **`terrain`:** **`21.8120 s → 17.8056 s`** (**`1.2250×` faster**, **`-4.006 s`**, `2.6452× C → 2.1594× C`, `-624 B` object code).
    - Hot loop `p113d_FID_$product.erode`: **`533 → 392` instructions (`-26.5%`)**, **`110 → 66` `(%rbp)` stack ops (`-40.0%`)**, **`4 → 1` `imull`** (`0` `imull` inside the 4×-unrolled loop body).
    - *Wave 15 composition projection:* 100% orthogonal to `W12-D`'s `-5.46 s` dual-array `hist` scalarization in `wave13_unified` → projected **`~12.3 s` (`~1.49× C`)** when composed.
  - **`hashmap`:** **`7.1387 s → 7.0055 s`** (**`1.0190×` faster**, `5.7265× C → 5.6197× C`).
    - Eliminated **`83,693,562` C runtime calls** to `p125_rt_ctor2` (**`83,695,627 → 2,065`**, **`99.9975%`** eliminated) via general inline hot `p125_rt_ctor2` with inline `rfc_seal`!
    - *Wave 15 composition note:* strictly generalizes `W12-F`'s sealed-only `p125_rt_ctor2` to also inline unsealed `TAG_CTR` children via class-0 freelist `rfc_seal`, while `W12-F` handles boxed `Array.get`/`Array.set` orthogonally.
  - **`tree-radix`:** **`11.7090 s → 11.5720 s`** (clean solo 3-run median **`10.3258 s` = `1.4594× C`** vs `11.2080 s` solo baseline = **`1.085×` faster**).
    - Eliminated **`23,693,814` C runtime calls** (`p111_rt_take` **`13,752,493 → 0` (`100.0%`)**, `p111_rt_ctor` **`13,752,493 → 3,811,172` (`72.3%`)**) via general class-3 (`5..8`-field) inline `p111_rt_ctor` and `p111_rt_take`, with **zero code bloat** on `merge` (`1,136` insns) and `radix` (`118` insns).
  - **3-Holdout Paired Geomean vs `gcc-10 -O2`:** **`2.9267× C → 2.7075× C`** (**`1.0810×` geomean speedup** on top of W14-A).
- **7-Family Regression Check (CPU `7`, 3-run median):** **`1.0357× C`** geomean — **zero regressions** (`expression` `0.943×`, `gameoflife` `0.445×`, `list` `1.006×`, `nbody` `1.068×`, `bst` `1.282×`, `editdist` `1.621×`, `histogram` `1.362×`).
- **Zero-Tolerance Correctness Gate (100% PASS):**
  - `--check-only`: **PASS** (`50.2 s`, `0` type/linearity errors).
  - **`64/64 native64 -O2`:** **`64/64 PASS`** (`55.08 s`, `0` failures, CPU `5`).
  - **Live-Metadata Observer Gate (`normal`, `cap-no8`, `all-hot`):** **`15/15 PASS`** (`16.68 s`, `0` violations, CPU `6`).

## 2. Pure-Bend Compiler Passes (`apply_w14f.py` / `w14f_holdouts.patch`)
All changes are pure Bend applied cleanly on top of `W14-A` (zero edits to `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, or read-only build artifacts):

1. **Straight-Line Loop Optimizer Extension (`w14f_sl_ext`):**
   - Raised `w14a_sl_take_body` fuel (`220 → 560`) and `w14a_sl_rounds` fuel (`8 → 40`), admitting 4×-unrolled straight-line loops like `terrain`'s `p113d_FID_$product.erode` (`419` insns).
   - Added `%r12` to `w14a_pick_free_reg`'s temp-promotion candidate list.
   - Added `w14f_drop_self_movl` to eliminate redundant zero-extending `movl %r32, %r32` after 32-bit ALU/`movzbl` writes.
   - Added `w14f_sl_extra`:
     - `w14f_try_xorshift`: folds 5-insn `movq rA, rB; shll/shrl $c, rA32; movq rA, rC; movq rB, rA; xorq rC, rA` (with `rB, rC` dead) into 3-insn `movq rA, rB; shll/shrl $c, rB32; xorq rB, rA`.
     - `w14f_try_and_idx`: folds `movq rA, rB; andq rX, rB; movl (base, rB, sc), rDst` (with `rA, rB` dead) into `andq rX, rA; movl (base, rA, sc), rDst`.
   - Added `w14f_find_imul_cand` / `w14f_sl_hoist_apply`: hoists loop-invariant `movq %rInv, %rT; imull $imm, %rT32` out of straight-line loops into `pre` when `%rInv` is saved in prologue, only read by that exact pair (`>= 2` times), and never read in `post` before epilogue restore.
2. **General Inline Hot `p125_rt_ctor2` with Inline `rfc_seal` (`w14f_rt_ctor2_hot_text`):**
   - Preserves compact `agy_rt_ctor_text` for non-hot (`p185cc_known`) constructors (zero bloat on `tree-radix` `merge`/`radix`).
   - For hot 2-field constructors (`!p185cc_known && w14f_ctor_known`), inlines class-1 freelist allocation (`alc->free[1]`) plus inline class-0 freelist `rfc_seal` (`alc->free[0]`) for any unsealed `TAG_CTR` field (`(f >> 56) == 2`), with strict pre-mutation checks so cold fallback has zero side effects across all Observer Gate modes.
3. **General Inline Class-3 (`5..8`-field) `p111_rt_ctor` & `p111_rt_take` (`w14f_rt_ctor_big_text`, `w14f_rt_take_big_text`):**
   - Extends `agy_rt_inline_try` to inline 5..8-field constructor allocation (`cls = 3, words = 8, atOff = 24, lenOff = 280`) for unsealed cold ctors and unique-owner `p111_rt_take`, restoring `%ecx = count` before any cold fallback call.

## 3. Paired Interleaved Holdout Scorecard (CPU `7`, 3-Run Median)

| Holdout | C (`gcc-10 -O2`) | W14-A (s) | **W14-F (s)** | W14-A (`× C`) | **W14-F (`× C`)** | Speedup vs W14-A | Obj Bytes (W14-A → W14-F) | Stdout |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| `terrain` | `8.2458 s` | `21.8120 s` | **`17.8056 s`** | `2.6452×` | **`2.1594×`** | **`1.2250×`** | `742,144 → 741,520` | `2572468224` |
| `hashmap` | `1.2466 s` | `7.1387 s` | **`7.0055 s`** | `5.7265×` | **`5.6197×`** | **`1.0190×`** | `73,416 → 83,696` | `1307803744` |
| `tree-radix` | `7.0754 s` | `11.7090 s` | **`11.5720 s`** *(solo `10.3258 s`)* | `1.6549×` | **`1.6355×`** *(solo `1.4594×`)* | **`1.0118×`** *(solo `1.085×`)* | `57,040 → 59,064` | `1998173798` |
| **Geomean (3)** | — | — | — | `2.9267×` | **`2.7075×`** | **`1.0810×`** | — | **3/3 exact** |

## 4. Remaining Holdout Bottlenecks (for Future Waves)
- **`tree-radix` (`~10.3 s` vs `7.08 s` C):** `gen` and `chk` remain on the `p111` CPS/frame machine (`14.14M` `p111_rt_return` calls, `3.81M` remaining `p111_rt_ctor` calls in `p111_FID_$direct.chk`), plus `9.95M` `p125_rt_take2` calls. Admitting `gen`/`chk` to `p113d` direct recursion is the next clean multiplier (`~1.3×` further cut).
- **`hashmap`:** `75.5M` boxed `Array.get` + `33.4M` boxed `Array.set` calls are already handled by `W12-F` in `wave13_unified` (`-0.85 s`); remaining time is L2/L3 cache-miss latency across the 4096-bucket array and RFC indirection cells.
- **`terrain`:** `hist` (`~5.5 s`) is already handled by `W12-D` in `wave13_unified`; `fill` (`69` `(%rbp)` ops) still has memory-operand ALU spills (`xor -0xa20(%rbp), %r8`) and loop-invariant `ox`/`oz` reloads.

## 5. Artifacts & Hygiene
- Patch: [w14f_holdouts.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/w14f_holdouts.patch)
- Builder: [apply_w14f.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/apply_w14f.py)
- Results JSON: [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/results.json)
- `/tmp/agy_w14f/` removed; `/dev/md2` free `>= 5.0 GiB`.

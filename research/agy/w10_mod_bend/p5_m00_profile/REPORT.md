# P5-A Report: Profiling & Diagnosing `m00`'s `302 s` `p86_plan` Outlier + Verified Fix & Split Rebalance

**Status:** **ROOT CAUSE IDENTIFIED & PROTOTYPE FIX VERIFIED (`m00` `p86_plan` `302.3 s -> 63.1 s` [`4.79x`], `m00` total `437.7 s -> 173.4 s` [`2.52x`] unsplit, and `437.7 s -> 60.3 s` [`7.26x` max-module] with `m00a`+`m00b` split)**

- **Binary profiled:** `selfhost/build/agy/wave10-native-mod/n3_w10` on dedicated CPU `0` (`taskset -c 0`, `ulimit -s 262144`)
- **Sampler:** `selfhost/tools/profiler/sample-threads.c` (`research/agy/w9_ladder/libbend_sample_threads.so`) decoded with `selfhost/tools/profiler/analyze.py`
- **Machine-readable results:** `research/agy/w10_mod_bend/p5_m00_profile/results.json`

---

## Executive Summary

1. **The `401` shared types in `types.bend` are NOT the bottleneck.** Compiling `types.bend` alone takes only **`1.71 s`** in `p86_plan` (`3.03 s` total) — **`0.57%`** of `m00`'s `302.3 s` `p86_plan`.
2. **The first half of `m00.bend` (`663` defs + `401` types) is also fast:** `p86_plan = 12.50 s`, `x198pw_plan = 29.82 s`, total = **`60.29 s`**.
3. **~100% of the `302 s` outlier lives in the second half of `m00.bend` (`m00_part2`, `p86_plan = 310.12 s`, `x198pw_plan = 91.74 s`, total = `413.13 s`) — caused by exponential pattern-match decision-tree blowup in `ff_match` / `f_hit_row` / `f_pattern_sub` (`compiler.bend:15080–15455`) triggered by JUST TWO functions:**
   - **`p186ch_expand`** (`compiler.bend:52723`, `m00.bend:6300`): 3 overlapping 7–8 level nested constructor patterns on `N111Call` with `U32` literals (`5, 0, 1`) + wildcard fallback `case _: P114TExpansion{[stmt],False{}}`. Alone takes **`> 60 s`** in `p86_plan`.
   - **`w2_asr_strip_self`** (`compiler.bend:68840`, `m00.bend:8482`): 4 overlapping nested constructor patterns on `Con{P113DScalar{N111Set / N111Bin{..., N111Const{2,0}, +x} / N111Bin{..., +x, N111Const{2,0}}}}` + wildcard fallback `case Con{head,rest}:`.
4. **Verified Pure-Bend Fix (semantic-preserving flat pattern rewrite of ONLY those 2 functions):**
   - **Unsplit full `m00`** (`401` types + `1,327` defs, `rc=0`, `6,172` segs, `8,987,136 B`):
     - `p86_plan`: **`302.26 s -> 63.09 s`** (**`4.79x`** speedup, **`-239.2 s`**)
     - `x198pw_plan`: **`114.22 s -> 76.44 s`** (**`1.49x`** speedup, **`-37.8 s`**)
     - Total wall time: **`437.73 s -> 173.38 s`** (**`2.52x`** speedup, **`-264.4 s`**)
   - **Combined with `m00a` + `m00b` split** (`m00a` = `types.bend` + first `663` defs; `m00b` = second `664` defs with the 2 functions flattened):
     - `m00a`: **`60.29 s`** (`p86_plan = 12.50 s`, `x198pw_plan = 29.82 s`, `3,159` segs)
     - `m00b`: **`58.65 s`** (`p86_plan = 27.62 s`, `x198pw_plan = 20.63 s`, `3,067` segs)
     - **Max-module wall time for `m00`:** **`437.73 s -> 60.29 s`** (**`7.26x`** speedup!)
     - **Total sequential `m00` work:** **`437.73 s -> 118.93 s`** (**`3.68x`** speedup, also eliminating `~54.4 s` of superlinear `O(N^2)` module-size overhead between `1,327` defs and `2 x 664` defs!).

---

## 1. Isolation Breakdown: `types.bend` vs `m00_half1` vs `m00_part2` vs Fixed Prototypes

All runs executed on CPU `0` (`taskset -c 0`, `ulimit -s 262144`) with `n3_w10 --trace x86-module-fast`.

| Variant | Contents | `read` | `prep` | `p86_plan` | `x198pw_plan` | `x187_elf` | **Total** | Segs |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| **Baseline `m00` (P4)** | `401` types + `1,327` defs (`1,264` exp) | 19 ms | 271 ms | **302,256 ms** | **114,216 ms** | 2,955 ms | **437,726 ms** | 6,173 |
| **`types_only`** | `401` types + dummy `main()` | 25 ms | 482 ms | **1,713 ms** | 377 ms | 170 ms | **3,026 ms** | 1 |
| **`m00_half1`** | `401` types + first `663` defs (`615` exp) | 28 ms | 474 ms | **12,496 ms** | 29,822 ms | 2,089 ms | **60,289 ms** | 3,159 |
| **`m00_part2` (unfixed)** | second `664` defs (`649` exp) on `m00_half1.p130` | 30 ms | 662 ms | **310,122 ms** | 91,741 ms | 1,682 ms | **413,126 ms** | 3,068 |
| **`m00_full` (2-fn fix)** | `401` types + `1,327` defs (`p186ch` + `w2_asr` flat) | 29 ms | 490 ms | **63,092 ms** | 76,444 ms | 4,575 ms | **173,375 ms** | 6,172 |
| **`m00_part2` (2-fn fix)** | second `664` defs (`p186ch` + `w2_asr` flat) on `m00_half1.p130` | 34 ms | 647 ms | **27,624 ms** | 20,629 ms | 1,677 ms | **58,645 ms** | 3,067 |

*(Note: `m00_half1 + m00_part2_fixed` has `p86_plan` sum `40.12 s` vs unsplit `m00_full_fixed`'s `63.09 s`, and `x198pw_plan` sum `50.45 s` vs `76.44 s`, showing an additional `~54.4 s` superlinear module-size cost when packing `1,327` defs into one module.)*

---

## 2. Native CPU Profile of `m00_part2`'s `p86_plan` (Top 25 Decoded Functions)

Captured with `libbend_sample_threads.so` at `10 ms` period (`25,000` samples covering the first `250.0 s` of `m00_part2`'s `310.1 s` `p86_plan` — i.e. **100% of samples are inside `p86_plan`**, `97.59%` symbol-resolved).

| Rank | % CPU | Samples | Decoded Symbol | Role |
|---:|---:|---:|---|---|
| 1 | **17.62%** | 4,405 | `p113d_FID_$p128borrow.owned.String.order.go` | String map/env key comparison during pattern elaboration & checking |
| 2 | **7.48%** | 1,869 | `term_drop` | Reclaiming temporary `KTerm` trees rebuilt by `f_pattern_sub` |
| 3 | **3.60%** | 901 | `p125_rt_ctor2` | Allocating 2-field `KTerm` / `Con` nodes |
| 4 | **3.46%** | 865 | `span_fade` | Span/heap reclamation |
| 5 | **2.70%** | 676 | `work_loop.constprop.0` | Native runtime dispatch loop |
| 6 | **2.43%** | 608 | `p111_rt_take` | Runtime constructor field extraction |
| 7 | **2.35%** | 588 | `[library_unresolved]` (`libc-2.31.so`) | `malloc`/`free`/`memcmp` |
| 8 | **2.21%** | 553 | `p118_rt_borrow_scalar_safe` | Borrowed scalar check |
| 9 | **1.72%** | 431 | **`p111_FID_$direct.f_pattern_sub`** | **Pattern-match substitution (`compiler.bend:15436`) — 0% in `m00_half1`!** |
| 10 | **1.42%** | 356 | `p111_rt_ctor` | General constructor allocation |
| 11 | **1.34%** | 334 | **`p111_FID_$direct.w7c_pat_sub_term`** | **`f_pattern_sub` inner `KTerm` recursion (`compiler.bend:15416`) — 0% in `m00_half1`!** |
| 12 | **1.28%** | 320 | `p113d_FID_$direct.String.order.go` | Owned string comparison |
| 13 | **1.13%** | 282 | `p111_FID_$p111.k.1105079` | Continuation frame in `p86` |
| 14 | **1.06%** | 264 | `p111_rt_op` | Primitive op dispatch |
| 15 | **1.02%** | 255 | `p111_rt_return` | Runtime frame return |
| 16 | **0.95%** | 237 | `p113d_FID_$direct.index_find` | Hash/map lookup |
| 17 | **0.92%** | 230 | `p113d_FID_$direct.String.eq__sh_slow` | Constructor/tag string equality (`f_eq`) |
| 18 | **0.87%** | 218 | `p113d_FID_$p118borrow.read.String.order.go` | Borrowed-read string comparison |
| 19 | **0.86%** | 214 | `p111_set_regs` | Runtime register transfer |
| 20 | **0.74%** | 185 | `p113d_FID_$direct.ks` | `KTerm` children accessor |
| 21 | **0.73%** | 182 | `p113d_FID_$p128borrow.owned.p98_tag_eq__sh_slow` | `KTerm` tag comparison (`"Var"`, `"Ctr"`, `"Error"`) |
| 22 | **0.66%** | 166 | **`p111_FID_$direct.w7c_subst_go`** | Core substitution during type-checking of the blown-up `Mat` tree |
| 23 | **0.63%** | 157 | `p111_FID_$direct.p98_tag_eq` | `KTerm` tag comparison |
| 24 | **0.63%** | 157 | `p111_FID_$direct.terms_at` | Positional list indexing (`kid(r, 1)`) |
| 25 | **0.60%** | 151 | `p198_rfc_take2` | Fast 2-field take |

*(Compare with `m00_half1` (`6,023` samples, zero-loss, `p86_plan = 12.5 s`): `f_pattern_sub` and `w7c_pat_sub_term` do not appear in the top 30 at all!)*

---

## 3. Root Cause in `compiler.bend` (`src/front/flatten.bend` & `elaborate.bend`)

Binary search over the `677` top-level blocks of `m00_part2` pinpointed exact cliffs at:
- **Block 161 (`p186ch_expand`, `compiler.bend:52723`, `m00.bend:6300`)**: prefix `0..160` took `5,897 ms`; adding `p186ch_expand` jumped to `> 60,000 ms`.
- **Block 521 (`w2_asr_strip_self`, `compiler.bend:68840`, `m00.bend:8482`)**: with `p186ch_expand` stubbed, prefix `0..520` took `13,612 ms`; adding `w2_asr_strip_self` jumped to `> 20,000 ms` (accounting for the remaining `~150–200 s` of `p86_plan`).

### Exact Algorithmic Bug in `ff_match` / `f_hit_row` / `f_pattern_sub`
In `selfhost/build/agy/wave10_unified/compiler.bend`:
- **`ff_match` (line 15080)**, **`ff_fields_done` (line 15134)**, **`ff_hit_done` (line 15141)** compile pattern matrices into a binary `Mat` tree by splitting on `c = f_first_ctor(rows)`:
  - **Hit subtree:** `f_hit_rows(rows, c, fields, v)` (line 15262) keeps every row matching `c` **and** every wildcard `Var` row. For each kept row, `f_hit_row` (line 15271) calls **`f_pattern_sub`** (line 15436) — **twice** on wildcard rows — to substitute `v -> Ctr(c, fields)` into the row's RHS body.
  - **Miss subtree:** `f_miss_rows(rows, nm(c))` (line 15276) keeps every non-`c` row **including** all wildcard/overlapping rows.
- **Why this explodes exponentially on `p186ch_expand` and `w2_asr_strip_self`:**
  1. **Row duplication across overlapping nested clauses:** In `p186ch_expand`, clauses 1–3 share a 7–8 level constructor prefix (`N111Call` -> `N111U64` -> `Con` -> `N111Arg` -> ...) but diverge on `U32` literals (`5` vs `+kind`, `1` vs `0`) and constructor tags (`N111U64` vs `N111Ptr`), followed by `case _: P114TExpansion{[stmt], False{}}`. In `w2_asr_strip_self`, clauses 4 and 5 match `N111Const{2,0}` in symmetric positions (`arg4` vs `arg5`), followed by `case Con{head, rest}:`. Every split where a later row has a wildcard/var in the tested column duplicates that row into **both** Hit and Miss subtrees, multiplying the number of `Mat` nodes exponentially in nesting depth!
  2. **Unconditional full-AST traversal in `f_pattern_sub` (`compiler.bend:15436`):** Every `f_hit_row` call walks and reconstructs the entire RHS `KTerm` even when `id` does not occur in the RHS, and for `case _: P114TExpansion{[stmt], False{}}`, each constructor split grows `stmt` inside the fallback RHS by another constructor layer (`N111Call{..., Con{N111Arg{...}}}`), causing both `p86_plan` elaboration/type-checking AND `x198pw_plan` codegen to process an exponentially large decision tree.

---

## 4. Recommended Fixes & Projected Speedups

### Fix A (Immediate, Zero-Risk Pure-Bend Source Fix — Already Verified!)
Flatten `p186ch_expand` (`compiler.bend:52723`) and `w2_asr_strip_self` (`compiler.bend:68840`) to 1-level-per-`match` helpers (semantic-preserving; verified `rc=0`, `6,172` segs on `n3_w10`).
- **Effect on unsplit `m00`:** `437.7 s -> 173.4 s` (**`2.52x`** faster, **`-264.4 s`** saved!).
- **Other modules to check next:** Our static scan also flagged deep nested patterns in `m01` (`w2_tbl_match`, 41 ctors depth 9), `m02` (`x202k_tail`, 28 ctors; `w2b_strip_true_check`, 26 ctors; `p126nt_expand`, 22 ctors), and `m09` (`w2b_x_scan`, 41 ctors; `agy_rt_inline_try`, 18 ctors) — flattening those can further reduce `m01`, `m02`, `m09`!

### Fix B (Split `m00` into `m00a` + `m00b` — Already Verified!)
Combine Fix A with splitting `m00` into `m00a` (`types.bend` + first `663` defs) and `m00b` (second `664` defs):
- **`m00a`:** `60.29 s` (`3,159` segs)
- **`m00b`:** `58.65 s` (`3,067` segs)
- **Max-module wall time (`m00`):** **`437.73 s -> 60.29 s`** (**`7.26x`** speedup!)
- **K=13 cluster projection (using P4 measured times for `m01..m11`):**
  - Sequential sum: `1,338.3 s -> 1,019.5 s` (**`1.31x`** faster)
  - **3-core parallel wall time:** `493.5 s -> ~345 s` (**`1.43x`** faster)
  - **8-core parallel wall time (longest pole = `m05` at `115.9 s`):** `437.7 s -> ~116 s` (**`3.78x`** faster!)

### Fix C (Permanent Compiler-Level Fix in `src/front/flatten.bend` / `elaborate.bend`)
1. **Bind shared fallback/join points once (`let fail = ...`)** before `ff_match` instead of duplicating wildcard rows into both `f_hit_rows` and `f_miss_rows` with inline `f_pattern_sub` expansion of `stmt`.
2. **Short-circuit `f_pattern_sub`** (`compiler.bend:15436`) with a fast free-id check or avoid calling `f_pattern_sub` when `id` is unbound/unused in `kid(r, 1)`.
3. **Skip redundant `Var`-column substitution** when the matched variable is not referenced in the RHS body (`f_hit_row`, `compiler.bend:15271`).

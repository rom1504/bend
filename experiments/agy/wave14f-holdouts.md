# Experiment Wave 14-F: Holdout Optimization Passes (`terrain`, `hashmap`, `tree-radix`)

- **Date:** 2026-11-23
- **Base:** `W14-A` (`wave11_unified + W12-G + W13-E + W14-A`), isolated on CPU `7` (`x86-object -O2`).
- **Status:** **PROMOTED (PASS)** — ready for Wave 15 (`n6_o2`) composition alongside `wave13_unified` (`W12-D` + `W12-F`).

## Hypothesis
Three general pure-Bend x86-64 `-O2` passes orthogonal to `W12-D`/`W12-F` target the primary remaining holdout bottlenecks:
1. **Straight-Line Loop Optimizer Extension (`w14f_sl_ext`):** Raise `w14a_sl_take_body` fuel (`220 → 560`) and `w14a_sl_rounds` (`8 → 40`), add `%r12` to temp-promotion candidates, drop redundant `movl %r32, %r32`, fold 5-insn copy-shift-restore-xor (`xorshift`) and `movq+andq+movl` indexed loads, and hoist loop-invariant `imull $imm` out of straight-line loops (`terrain` `erode` & `fill`).
2. **General Inline Hot `p125_rt_ctor2` with Inline `rfc_seal` (`w14f_rt_ctor2_hot_text`):** Keep compact `agy_rt_ctor_text` for non-hot ctors and inline class-1 alloc + class-0 freelist `rfc_seal` for hot 2-field ctors (`hashmap` `CCons`/`Tuple`).
3. **General Inline Class-3 (`5..8`-field) `p111_rt_ctor` & `p111_rt_take`:** Inline 5..8-field constructor alloc and unique-owner take (`cls = 3, words = 8`), eliminating `Cval` runtime calls in `tree-radix` `chk_join`.

## Evidence
- **Paired Interleaved A/B (`taskset -c 7`, 3-run median, exact stdout on 3/3):**
  - **`terrain`:** `21.8120 s → 17.8056 s` (**`1.2250×` faster**, `-4.006 s`, `2.6452× C → 2.1594× C`); `p113d_FID_$product.erode` shrunk `533 → 392` insns (`-26.5%`), `110 → 66` `(%rbp)` ops (`-40.0%`), `4 → 1` `imull` (`0` in loop). Composed with `W12-D`'s `-5.46 s` `hist` win in `wave13_unified`, projected `terrain ≈ 12.3 s` (`~1.49× C`).
  - **`hashmap`:** `7.1387 s → 7.0055 s` (**`1.0190×` faster**); `p125_rt_ctor2` calls cut `83,695,627 → 2,065` (**`99.9975%`** eliminated).
  - **`tree-radix`:** `11.7090 s → 11.5720 s` interleaved (solo 3-run median `10.3258 s` = **`1.4594× C`** vs `11.2080 s` solo baseline = **`1.085×` faster**); `p111_rt_take` cut `13,752,493 → 0` (**`100.0%`**) and `p111_rt_ctor` cut `13,752,493 → 3,811,172` (**`72.3%`**), with `0` bloat on `merge`/`radix`.
  - **3-Holdout Geomean vs `gcc-10 -O2`:** **`2.9267× → 2.7075×`** (**`1.0810×` speedup** over W14-A).
- **7-Family Regression Check (CPU `7`, 3-run median):** **`1.0357× C`** geomean — zero regressions across all 7 families.
- **Zero-Tolerance Correctness Gate:** `--check-only` PASS (`0` errors, `50.2 s`), **`64/64 native64 -O2` PASS** (`55.08 s`), **`15/15` Observer Gate PASS** (`16.68 s`, `0` violations).

## Artifacts
- [REPORT.md](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/REPORT.md)
- [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/results.json)
- [w14f_holdouts.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/w14f_holdouts.patch)
- [apply_w14f.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14f_holdouts/apply_w14f.py)

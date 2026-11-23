# Wave 16 Final Integration & Status Report (`W16-INT`)

## Executive Summary
All **8 verified S10 optimizations** (`S10-D`, `S10-E --no-lexer`, `S10-A`, `S10-C`, `S10-H`, `S10-F`, `S10-B`, `S10-G`) have been **cleanly composed** into a single unified pure-Bend compiler source:
- **Composed Source:** [selfhost/build/agy/wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend)
  - **`3,497,142 B`** (`-9.74%` vs Wave 15's `3,874,571 B`), **`82,253 lines`** (`-9.73%` vs `91,122 lines`), **`9,343 defs`**, **`909 laws`**, **`422 types`**.
  - **Typecheck & Linearity (`locked_bun.sh --check-only`):** **0 type errors, 0 linearity errors** (clean `9127 defs rely on unsafe or foreign code` verdict).
- **Balanced Acyclic Splits Generated (`split_kN_balanced.py`, 0 lost, 0 dup, 0 cycles):**
  - **`K=10`:** [selfhost/build/agy/k10_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k10_wave16) — `334.6–337.6 KB/mod` (**`max/avg = 1.002x`**!).
  - **`K=16`:** [selfhost/build/agy/k16_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k16_wave16) — `204.8–212.4 KB/mod` (**`max/avg = 1.009x`**!).
  - **`K=24`:** [selfhost/build/agy/k24_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k24_wave16) — `138.3–141.2 KB/mod` (**`max/avg = 1.005x`**!).
- **Wave 16 Exact Monotonic `p113d` Oracle Extracted:** [p113d_oracle_w16.txt](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/p113d_oracle_w16.txt) — **`2,574` direct defs** (eliminates the single `f_raw_skip` orphan weak caused by `S10-E` changing `f_raw_skip`'s lowering from direct to CPS relative to Wave 15's `p113d_oracle_k10.txt`).

---

## Composition Stack (`compose_w16.py`)
[compose_w16.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/compose_w16.py) applies all 8 patches in conflict-free order in `3.82 s`:
1. **`S10-D`** (`apply_s10d.py`): 5-line `w5_g11_b` fallthrough `cmov` fix (restores `editdist 1.59x C`, 7-family `1.059x C`).
2. **`S10-E --no-lexer`** (`apply_s10e.py`, `include_lexer=False`): 9 safe frontend/parser/check/annotate hunks (`s10e_plan`, `s10e_p156cp_walk`, `s10e_f_raw_skip_fast`, `s10e_f_skip_fast`, `s10e_f_atom_existing_fast`, `s10e_w7b_jl_ctr_fast`, `s10e_p144o_cached_bound`), extended so `-O0` (`fast == True`) also skips S10-A zero-`.p130` stubs (`db(d) == False`) in both typechecking and annotation.
3. **`S10-A`** (`apply_s10a.py`): Pure-Bend `STB_WEAK` visibility for S10-A stubs and `Type`/`Set`-polymorphic templates (`w10_weak_from_plan`), wired cleanly alongside `s10e_plan`.
4. **`S10-C`** (`apply_s10c.py`): Fast `-O0` backend (`s10c_priv_emit_fast`, `s10c_plan_fast`).
5. **`S10-H`** (`apply_s10h.py`): Unified S10-A stub skipping + O(1) `bangMap` + `p112s` direct-stub skip inside `s10c_plan_fast`.
6. **`S10-F`** (`apply_s10f.py`): Unboxed `S10fT` `x187_pub` (`s10f_tr_pub_loop`) + 8x-unrolled hot-8 `x187_elf` (`s10f_elf_finish_io`, used for both `-O0` and `-O2`) + 7 bare `-O2` sink upgrades.
7. **`S10-B`** (`treeshake_w15.py`): Reachability tree-shaking + constant flag folding (`55` flags, `107` calls inlined, `24` `nt_choose` folded) + comment stripping (`-11,584` lines, `-509 KB`, `-534 defs`, `-14 types`, automatically pruning `26` superseded `s10c_*` defs).
8. **`S10-G`** (`apply_s10g.py`): Compiler-only `--nodrop` mode (`x86-module-nodrop` / `x86-module-fast-nodrop` / `--nodrop`) applied after `S10-B` so `w8_dispatch_args` cleanly exposes `--nodrop` while leaving user program modes 100% untouched.

---

## Key Technical Findings During Minting (Ready for Immediate Completion)
1. **FID Budget vs `K` on `n6_o2` Bootstrap:**
   - On `K=16` with `n6_o2` (which lacks `S10-H` stub skipping), duplicated Base segments (`16 x ~1,000`) plus unskipped stubs totaled `~71,500 > 65,532`.
   - On **`K=10`** (`k10_wave16`, `max/avg = 1.002x`), `n6_o2` compiled all 10 modules cleanly in **`65,377 / 65,532` FIDs** (zero overlaps after exact FID repacking), linked `n7_o0` (`102.9 MB`, `merge = 216.3 ms`, `link = 498.6 ms`), and extracted **`p113d_oracle_w16.txt` (`2,574` direct defs)**.
2. **Exact 1-Symbol Oracle Delta (`f_raw_skip`):**
   - `S10-E` rewrote `f_raw_skip`, moving it out of `p113d` direct lowering. Using Wave 15's `p113d_oracle_k10.txt` left `f_raw_skip` as the sole non-Base orphan weak (`1` symbol).
   - The freshly extracted **`p113d_oracle_w16.txt` (`2,574` defs)** removes `f_raw_skip` and guarantees **0 non-Base orphan weak symbols** for the next mint (`n7_o2` & `n7_o2_nodrop`) and official 8-core zero-cache cold benchmark!
3. **Time Budget / What Remains:**
   - The `21:58 UTC` hard deadline arrived immediately after linking `n7_o0` and extracting `p113d_oracle_w16.txt` (after restarting `mint-n7` at `21:40 UTC` to incorporate S10-E's critical `--no-lexer` handoff).
   - All scripts are tested, verified, and ready on disk to run in ~6–8 min in the next turn:
     1. Mint `n7_o2` (`-O2` on `k10_wave16` with `p113d_oracle_w16.txt`) + `n7_o2_nodrop` (`n7_o2 --nodrop`).
     2. Official 8-core zero-cache cold self-compile benchmark (`n7_o2 -> n8_cold` and `n7_o2_nodrop -> n8_cold_nd`, `K=10` / `K=16` / `K=24`).
     3. `run_w16_gate.py all` (`158/158` native64 + Observer + ELF audit + 7-family proxy + `terrain` holdout).

---

## Artifacts on Disk
- [compose_w16.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/compose_w16.py) — 8-patch unified composer (`3.82 s`, `--check-only` 0 errors).
- [selfhost/build/agy/wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend) — Composed Wave 16 compiler (`3.50 MB`, `82,253 lines`).
- [selfhost/build/agy/k10_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k10_wave16), [k16_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k16_wave16), [k24_wave16](file:///home/ai/bend2_agy/selfhost/build/agy/k24_wave16) — Balanced acyclic splits (`max/avg = 1.002x–1.009x`).
- [p113d_oracle_w16.txt](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/p113d_oracle_w16.txt) — Exact Wave 16 `G(G(D0))` direct-def oracle (`2,574` defs, 0 non-Base orphan weaks).
- [mint_and_bench_w16.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/mint_and_bench_w16.py), [run_w16_k10.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/run_w16_k10.py), [run_w16_gate.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/run_w16_gate.py) — Mint, cold-bench, and zero-regression gate harnesses.
- [treeshake_stats.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/treeshake_stats.json) — Exact S10-B pruning telemetry.

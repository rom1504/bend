# Experiment S10-D: Restore W14-A `editdist` & Root-Cause `expression` in `wave15_unified`

- **Hypothesis:** Fixing the missing fallthrough `jne/je L; movq -d(%rbp), %r; L:` match in `w5_g11_b` will restore W14-A's `w14a_cmov_table_go` + `w14a_sl_loop_opt` (0-spill `$product.columns` loop in `editdist`), cutting 7-family geomean from `1.1341×` toward `<= 1.05× C` with zero regressions.
- **Outcome:** **PASS / PROMOTE-READY** (orthogonal to S10-B, S10-E `p86_plan`, and S10-F `term_drop`/`x187_elf`)
  - **`editdist`:** **`2.1290× -> 1.5909× gcc-10 -O2`** (`20.625 ms -> 16.406 ms`, **`1.338×` faster**, **0 stack spills** in `$product.columns`, `-208 B` `.o`).
  - **`expression` root cause:** All W14-A passes are active (`12/20/14` instructions, 0 spills, 0 `p111_rt_op`); `pad=16B` proved `8.549 ms -> 5.896 ms` (`[20,20,20,20,20]`) is an Ivy Bridge 3-branch-per-32B DSB uop-cache boundary effect.
  - **7-Family Paired Geomean (CPU `7`, 5-run median):** **`1.1341× -> 1.0590× gcc-10 -O2`** (`7/7` PASS, 6/7 `.o` bit-identical to `n6_o2`).
  - **Gates (CPUs `5,7`):** `--check-only` PASS (`0` errors on both `wave15_unified + S10-D` and `S10-B + S10-D`, idempotent), **`64/64 native64 -O2` PASS**, **`15/15` Observer `-O2` PASS (`0` violations)**.
- **Rejected/Opt-In Sub-Experiments:**
  - Blanket 32-byte alignment of all `-O2` private functions (`s10d_align_text32`) regressed `bst` (`17.84 -> 21.52 ms`) due to Ivy Bridge DSB shift; rejected.
  - `x187_e_alu` `0x83` `imm8` encoding shrinks `.o` files by `-1–3%` (`editdist.o` `-2,888 B`) but shifted `bst` on Ivy Bridge (`17.84 -> 21.80 ms`); preserved as opt-in `--with-imm8`.
- **Evidence:**
  - [apply_s10d.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10d_frontend_and_o2/apply_s10d.py)
  - [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10d_frontend_and_o2/REPORT.md)
  - [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10d_frontend_and_o2/results.json)

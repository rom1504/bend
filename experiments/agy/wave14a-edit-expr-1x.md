# Wave 14-A: 7-Family Geomean `1.1856× -> 1.0239× gcc-10 -O2` (`expression` `0.943×`, `bst` `1.299×`, `editdist` `1.621×`)

- **Workspace & Artifacts:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/results.json), [w14a_edit_expr_1x.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/w14a_edit_expr_1x.patch), [build_w14a.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14a_edit_expr_1x/build_w14a.py)
- **Gates (CPU 7):** `--check-only` **PASS (`0` type errors, `28.4 s`)**, **`64/64 native64` PASS** (`65.8 s`), **`15/15` Observer Gate PASS (`44+2 ABI`, `0` violations)**.
- **7-Family Paired Geomean vs `gcc-10 -O2` (CPU 7, 5-run median, exact checksums on 7/7):**
  - **`1.1856× -> 1.0239×`** (**`1.158×` over W13-E**, **`1.307×` over Wave 11's `1.3383×`** — achieving the `<= 1.05×` milestone!):
    - `gameoflife`: `0.469×` (`435.85 ms` vs `929.67 ms` C)
    - `expression`: **`0.943×`** (`9.433 ms -> 5.896 ms` vs `6.249 ms` C, **`1.60×` faster**, beats `gcc-10 -O2`!)
    - `list`: `1.006×` (`0.265 ms` vs `0.264 ms` C)
    - `nbody`: `1.074×` (`95.21 ms` vs `88.69 ms` C)
    - `histogram`: `1.174×` (`31.14 ms` vs `26.53 ms` C)
    - `bst`: **`1.299×`** (`22.937 ms -> 16.990 ms` vs `13.082 ms` C, **`1.35×` faster**)
    - `editdist`: **`1.621×`** (`19.286 ms -> 15.703 ms` vs `9.688 ms` C, **`1.23×` faster**, 0 stack spills in `$product.columns`)

## Summary of General Pure-Bend Upgrades
1. **Liveness & `negq` Encoder:** Added `notl`/`negq` to `w5c_is_alu_c`, taught `w4b_reg_dead` (`w14a_rd_xor`) that self-xor (`xorl`/`xorq %r,%r`) kills `%r` without reading it, and added 64-bit `negq` (`0xF7 /3`) to `w13e_es_f19` + `x202o_dispatch`.
2. **Non-Loop `p111_rt_op` Magic-Multiply (`x191_frame_forward`):** Enabled `x191_frame_forward_when` on non-loop functions `> 96` items containing `p111_rt_op`, eliminating `callq p111_rt_op` for constant `div`/`mod` (e.g., `expression` `$direct.bench`).
3. **4-Slot Contiguous `cmoveq` -> `negq` + Indexed `movq` (`w14a_cmov_table_go`):** Collapses descending 4-slot stack `cmoveq` chains keyed by `andq $3, %rIdx` into `andq $3, %rIdx; negq %rIdx; movq d0(%rbp, %rIdx, 8), %rDst`.
4. **Straight-Line Call-Free Loop Register & Copy Optimizer (`w14a_sl_loop_opt`):** Promotes loop-carried slots to unused `%r12` and loop-local temp slots to free/source registers with copy-forward, 2-imm in-place folding, indexed-load forwarding, and deferred writeback folding — achieving **0 stack spills** in `editdist` `$product.columns`.
5. **Multi-Branch Call-Free Loop Induction Cleanup (`w14a_mb_loop_opt`):** Eliminates redundant counter/induction copies and dead `movl`+`subq $1` -> `cmpl $1`, trimming `expression` `$direct.unwind` to `12 / 20 / 12` instructions (fewer than `gcc-10 -O2`'s `14 / 20 / 16`).

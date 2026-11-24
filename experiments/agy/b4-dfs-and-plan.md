# Experiment B4: DFS Dependency-Order Balanced Splitter + `x198pw_plan`/`p86_plan` Hotspot Killer

- **Status:** Verified (Splitter + `k16_wave17_dfs` / `k24_wave17_dfs` generated & benchmarked; `apply_b4.py` verified 0 errors under `locked_bun.sh --check-only` and 100% disjoint from B2/B3).
- **Artifacts:**
  - `research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py` (`--order {bfs,dfs,source}`)
  - `selfhost/build/agy/wave17_unified/k16_wave17_dfs/` & `k24_wave17_dfs/`
  - `research/agy/boot_200s/b4_dfs_and_plan/apply_b4.py`
  - `research/agy/boot_200s/b4_dfs_and_plan/REPORT.md`
  - `research/agy/boot_200s/b4_dfs_and_plan/results.json`

## Key Results
1. **DFS Post-Order Balanced Split (`--order dfs`):**
   - `K=16`: stubs `8,793 → 2,041` (**`-76.8%`**), stub bytes `978.1 KB → 210.5 KB` (**`-78.5%`**), `.exp` exports `5,593 → 1,061` (**`-81.0%`**), balance `1.0035×`, `0` forward edges.
   - `K=24`: stubs `10,085 → 2,459` (**`-75.6%`**), stub bytes `1,127.9 KB → 251.2 KB` (**`-77.7%`**), `.exp` exports `6,051 → 1,160` (**`-80.8%`**), balance `1.0168×`, `0` forward edges.
   - Native `n8_o2 --trace x86-module` on `m08` (CPU 6): `p86_plan` **`1.88×` faster** (`14,581 → 7,766 ms`), `x198pw_plan` `1.07×`, `x187_priv` `1.29×`, `.o` `-17.8%`.
2. **`gdb` Sampling + `apply_b4.py` (`x198pw_plan` + `p86_plan`):**
   - 46 `gdb bt 10` samples on `n8_o2` (`16` in `p86_plan`, `30` in `x198pw_plan`) identified `nc_uses_term` (3/30), `nq_layout_subst` (2/30), `term_drop`/`span_fade` churn (8/30), and `p86_plan` ADT/law/stub re-checking.
   - `apply_b4.py` implements 4 semantics-preserving optimizations (`b4_nc_uses_term`, `b4_nq_layout_subst`, `b4_pre_bang_index`, `b4_o2_mod_check`), verified with `0` errors under `locked_bun.sh --check-only` and `0%` `-O2` runtime regression.

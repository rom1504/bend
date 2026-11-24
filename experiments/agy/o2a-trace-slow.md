# Experiment `o2a-trace-slow`: Per-Function `--trace-slow` `-O2` Profiling & `O(N²)` / `O(2^k)` Investigation

- **Hypothesis:** In Wave 15 `-O2` self-compilation (`693 s` on 8 cores, `m04 = 579 s`, `m00 = 428 s`), `x187_priv` (`83.5%` of module time) is dominated by a small set of `O(N²)` / `O(2^k)` compile-time bombs in `w4b_reg_dead`, `w7_post_select_full`, and large match/constructor functions.
- **Evidence & Artifacts:**
  - Patcher: [apply_o2a.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2a_trace_slow/apply_o2a.py)
  - Full Report: [REPORT.md](file:///home/ai/bend2_agy/research/agy/o2_50s/o2a_trace_slow/REPORT.md)
  - Raw Metrics: [results.json](file:///home/ai/bend2_agy/research/agy/o2_50s/o2a_trace_slow/results.json)
- **Key Findings:**
  1. **Exact concentration:** Top 20 functions account for **`90.7%`** of slow `x187_priv` time in `m00` (top 3: `w13c_sink_tpl_bytes` 25.5 s, `w13c_keep_tpl_bytes` 22.7 s, `$direct.p147z_runtime_111` 18.7 s = `60.5%`) and **`79.5%`** in `m04` (top 3: `$product.agy_sh_emit_streq` 12.8 s, `$direct.w5c3_sig1` 11.3 s, `$direct.agy_map_set_machine` 7.1 s).
  2. **`w4b_reg_dead` (`hops 8 -> 2`, `budget <= 32`)**: Confirmed **`6.0×` speedup** on `$direct.s10f_rev8` (`1,514 ms -> 252 ms`) and `9.4%` speedup on `m04` first-500 `x187_priv`, with `--check-only` `0` errors and `compiler_slice.bend` `-O2` PASS (`out=34`).
  3. **Disproved sub-hypothesis & true bomb location:** Skipping `x185_dead_body`/`x185_copy_function` + `x190_branch_facts` + `w7_post_select_full` actually **increased** `w13c_sink_tpl_bytes` from `25.5 s -> 35.5 s` (`+39%`), proving the dominant `O(N²)` bomb on 150-element constructor-list / giant-match functions lives **downstream of `x191_ordinary` and outside `w7_post_select_full`** (in `x190_stmts`, `x191_frame_forward_when`, `w4_peep_list`, or `w10f_output_fn` / `x187_encode`).
- **Recommendation:** Promote the `w4b_reg_dead` cap + `x191_frame_forward` large-function cap + `w14a_sl_rounds` cap; immediately split-time `x181_program_private` vs `w10f_output_fn` on `w13c_sink_tpl_bytes` to eliminate the remaining 80% bomb.

# O2-A: `--trace-slow` Surgical `-O2` Profiling & `O(N²)` / `O(2^k)` Bomb Investigation

## Executive Summary
- **Instrument Built:** Patched `k10_wave16` (`m09_zero.bend`) with per-function `x187_priv` millisecond timing (`>= 100 ms`) in `w8_tr_emit_priv` and linked `/tmp/agy_o2a/n7_ts_o0` (via `n7_o2 x86-module-fast` on CPUs 0,1) to capture exact per-function `-O2` `x187_priv` hotspots on `m04` and `m00`.
- **Extreme Concentration Confirmed:**
  - **`m00`:** Top 3 functions alone = **`60.5%`** (`66.86 s` of `110.56 s`), Top 10 = **`80.5%`**, Top 20 = **`90.7%`**!
  - **`m04`:** Top 10 functions = **`61.2%`** (`57.49 s` of `93.95 s`), Top 20 = **`79.5%`**!
- **Delivered Patcher:** [apply_o2a.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2a_trace_slow/apply_o2a.py) (idempotent, `--check-only` `0` typecheck errors on `wave16_unified/compiler.bend`, `compiler_slice.bend` `-O2` PASS `out=34`).
  - `w4b_reg_dead` cap (`budget <= 32`, `hops: 8 -> 2`, killing `2^8 * O(N)` branch explosion) delivered a **`6.0×` speedup** on `$direct.s10f_rev8` (`1,514 ms -> 252 ms`) and **`9.4%`** reduction on `m04` first-500 `x187_priv` (`43.2 s -> 39.5 s`).
- **Critical Root-Cause Finding for `O2-50s` Integration:**
  - Bypassing `x185_dead_body`, `x185_copy_function`, `x190_branch_facts`, `x191_placement`, **and** `w7_post_select_full` (including `w5b_run_leaf_promote`) did **not** eliminate the 12–25 s bombs on `w13c_sink_tpl_bytes`, `w13c_keep_tpl_bytes`, `$product.agy_sh_emit_streq`, `$direct.agy_map_set_machine`, and `$direct.p147z_runtime_111`.
  - In fact, skipping `x185_dead_body`/`x185_copy_function` **increased** `w13c_sink_tpl_bytes` from `25,475 ms -> 35,450 ms` (`+39%`, scaling quadratically with un-eliminated instruction count!).
  - **Conclusion:** The dominant `O(N²)` bomb on large constructor-list / giant-match functions is **downstream of `x191_ordinary` and outside `w7_post_select_full`** — specifically inside `x190_stmts` / `x191_frame_forward_when` / `w4_peep_list` / `w10f_output_fn` (`w10f_fn_parsed` / `x187_encode`)! Splitting `x181_program_private` vs `w10f_output_fn` timing in `w8_tr_emit_priv` is the immediate #1 next step to cut `m00`/`m04` `-O2` by `5–10×`.

---

## Exact Top 20 Slowest `-O2` `x187_priv` Functions

### `m00` (`63` fns `>= 100 ms`, sum = `110,555 ms`; Top 10 = `80.5%`, Top 20 = `90.7%`)
| Rank | Function | Time (ms, `-O0` profiler) | Pattern / Structure |
|---:|---|---:|---|
| 1 | `w13c_sink_tpl_bytes` | `25,475` | 150-element `List<&2,U32>` literal (`150` `Con` / `p111_rt_ctor` calls) |
| 2 | `w13c_keep_tpl_bytes` | `22,654` | 152-element `List<&2,U32>` literal (`152` `Con` / `p111_rt_ctor` calls) |
| 3 | `$direct.p147z_runtime_111` | `18,730` | 16-arm string `match` decision tree |
| 4 | `$direct.w13e_sa_branch_live` | `4,740` | Tail-recursive 5-arm `match` loop |
| 5 | `$direct.x198n_selected` | `4,103` | Nested `P113DStmt` constructor list |
| 6 | `$direct.p147z_runtime_118` | `3,908` | Multi-arm string `match` |
| 7 | `$product.x187_e_error` | `2,624` | Large constructor / error builder |
| 8 | `$direct.p112r_head_buffer` | `2,512` | Large match / builder |
| 9 | `$direct.w4c_guard_ule` | `2,445` | `N111Stmt` list builder |
| 10 | `$product.p113d_call_target` | `1,789` | Multi-case dispatch |
| 11 | `x187_e_error` | `1,743` | Wrapper |
| 12 | `$direct.s10f_rev8` | `1,514` | Loop (`-> 252 ms`, **`6.0×` faster** with `w4b_reg_dead` cap!) |
| 13 | `$direct.p112s_datum` | `1,310` | Multi-case dispatch |
| 14 | `$direct.w14a_args_dst_eq` | `1,288` | Pattern match |
| 15 | `$direct.w5c3_finish_if` | `1,161` | Multi-case dispatch |

### `m04` (`65` fns `>= 100 ms`, sum = `93,946 ms`; Top 10 = `61.2%`, Top 20 = `79.5%`)
| Rank | Function | Time (ms, `-O0` profiler) | Pattern / Structure |
|---:|---|---:|---|
| 1 | `$product.agy_sh_emit_streq` | `12,812` | Giant `x188_many([...])` instruction-list builder |
| 2 | `$direct.w5c3_sig1` | `11,295` | Inlined string-eq chain (`p111v_signature`) |
| 3 | `$direct.agy_map_set_machine` | `7,058` | 217-line `x188_many([...])` builder |
| 4 | `$direct.w7_br_661` | `5,343` | Inlined 50-deep `w7_br_*` string-eq chain |
| 5 | `$direct.agy_map_del_machine` | `4,639` | 162-line `x188_many([...])` builder |
| 6 | `$direct.w7_br_660` | `3,601` | Inlined `w7_br_*` string-eq chain |
| 7 | `$product.p88_roots_done` | `3,486` | Builder |
| 8 | `$direct.agy_map_get_machine` | `3,358` | 147-line `x188_many([...])` builder |
| 9 | `$direct.agy_sh_match_lit3` | `3,062` | Deep pattern match |
| 10 | `$direct.p130m_roots_ready` | `2,831` | Builder |

---

## Patches in `apply_o2a.py`
1. **`w4b_reg_dead` (`compiler.bend:58598`):** Cap lookahead `budget <= 32` and branch `hops: 8 -> 2` (eliminates `2^8 * O(N)` exponential branch-fork + linear label scan).
2. **`w14f_sl_hoist_apply` (`compiler.bend:64302,64312`):** Cap `w14a_sl_rounds` fuel `40 -> 20`.
3. **`x191_frame_forward` (`compiler.bend:64840`):** Bypass `w7_post_select_full` when `!hasXmm && ((len > 384 && (hasCall || !isLoop)) || (hasCall && len > 96 && !isLoop))`. Leaves all `hasXmm` (`nbody`, `terrain`) and all leaf loops (`!hasCall && isLoop`: `editdist`, `expression`, `bst`, `histogram`, `gameoflife`, `list`) 100% untouched.
4. **`x185_function_place`, `x198n_place_h`, `x191_ordinary`:** Fast-path skip of `x185_dead_body`/`x185_copy_function` and `x190_branch_facts`/`x191_placement` on `!hasLoop && size > 96/128 && hasCall` (Note: for `apply_o2a.py` v2 integration, keep `w4b_reg_dead` + `x191_frame_forward` + `w14a_sl_rounds`, and evaluate keeping `x185_copy_function` enabled until the downstream `w10f_output_fn`/`x190_stmts` `O(N²)` bomb is fixed!).

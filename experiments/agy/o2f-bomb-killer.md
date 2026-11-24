# O2-F: Killing the `80%` `x187_priv` Quadratic Bomb (`w4b_find_loop`)

## Hypothesis
The `80%` `-O2` `x187_priv` compile-time explosion discovered by O2-A (`w13c_sink_tpl_bytes` = `25.5 s`, `w13c_keep_tpl_bytes` = `22.7 s`, `$direct.p147z_runtime_111` = `18.7 s`, `$product.agy_sh_emit_streq` = `12.8 s`, etc.) is caused by a single `O(N²)` pass downstream of `x191_ordinary` and outside `w7_post_select_full`.

## Root Cause Found (100% Confirmed by Live `gdb` Stack Sampling)
- Standalone 14-line reproducer (`w13c_sink_tpl_bytes`, 150-element `List<&2,U32>` literal) took **`5,809 ms`** in `x187_priv` on `-O2` `n7_o2` (`5,895 ms` total).
- 20-sample `gdb` stack profile on `n7_o2` hit **`$direct.w4b_has_jmp_to` (`56` frames)** + **`$direct.w4b_has_any_branch_to` (`13` frames)** + **`$direct.String.eq`** (`~100%` of `x187_priv` time).
- **Bug:** `x191_frame_forward` (`compiler.bend:64840`) calls `w4b_find_loop(flat0, [])` **before** checking the `w7_post_select_full` bypass. Inside `w4b_find_loop` (`compiler.bend:59022–59046`), `w7_collect_jmps` records every `jmp` target without instruction indices, so every forward merge `jmp` (from `if/else`, `match`, or inline `p111_rt_ctor` slow paths) triggers `O(N)` linear `w4b_has_jmp_to(lbl, rest)` + `w4b_has_any_branch_to(lbl, before)` scans on every `PLabel` → **`O(L × N) = O(N²)`**.

## Fix & Evidence
- **Patcher:** [apply_o2f.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2f_bomb_killer/apply_o2f.py) (idempotent, 1 hunk `w4b_find_loop_linear`, disjoint from `apply_o2a.py`/`apply_o2c.py`/`apply_o2e.py`).
- **Algorithm:** Single `O(N)` pass (`o2f_collect_before` + `o2f_collect_branches`) recording `(da=lastJmpIdx, dx=firstAnyBrIdx)` per label in one `KDef` map, replacing per-label linear scans with `U32.is_gt(da(info), idx) && U32.is_gt(dx(info), idx)` (**100% mathematically equivalent**, bit-identical `-O2` output, zero runtime regression).
- **Checks:**
  - `bun bend2/main.ts --check-only` on patched `wave16_unified/compiler.bend`: **`0` type / linearity errors**.
  - Patched `k10_wave16/m06.bend` compiled cleanly via `n7_o2 x86-module-fast` (`rc=0`, `22.8 s`).
- **Full Report:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/o2_50s/o2f_bomb_killer/REPORT.md) | [results.json](file:///home/ai/bend2_agy/research/agy/o2_50s/o2f_bomb_killer/results.json).

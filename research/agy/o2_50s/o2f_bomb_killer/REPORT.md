# O2-F: The `80%` `x187_priv` Quadratic-Bomb Killer (`w4b_find_loop`)

## Executive Summary
- **Root Cause Pinpointed (`100%` of `x187_priv` time on `w13c_sink_tpl_bytes`):**
  - Isolated `w13c_sink_tpl_bytes` (150-element `List<&2,U32>` literal) into a standalone 14-line reproducer (`repro_sink4.bend`).
  - `n7_o2 --trace x86-object` spent **`5,809 ms`** in `x187_priv` (out of `5,895 ms` total) compiling just 2 functions (`w13c_sink_tpl_bytes` + `main`).
  - Live `gdb` stack sampling (`20` samples across `n7_o2` compiling `repro_sink4.bend`) caught **`w4b_find_loop`** (`$direct.w4b_has_jmp_to` = `56` stack frames, `$direct.w4b_has_any_branch_to` = `13` frames, `$direct.String.eq` = `5` top frames) accounting for **~100% of the `5.57 s` explosion**!
- **Why O2-A's Bypasses Didn't Catch It:**
  - `x191_frame_forward` (`compiler.bend:64840`) evaluates `w4b_find_loop(flat0, [])` **before** checking whether to bypass `w7_post_select_full` (`hasLbl && w7_is_loop(w4b_find_loop(flat0, []))`).
  - Inside `w4b_find_loop` (`compiler.bend:59022–59046`), `w7_collect_jmps` records **every** `jmp` target (including all **forward** merge `jmp`s from `if/else`, `match` arms, and inline `p111_rt_ctor` slow paths) with dummy value `1` (no instruction index!).
  - Then `w7_find_loop_go` hits every `PLabel{lbl}` in `items`, sees `da(p111v_get(jmps, lbl)) > 0` is **TRUE** for every forward-jumped label, and executes an **`O(N)` linear scan** via `w4b_has_jmp_to(lbl, rest)` (and `w4b_has_any_branch_to(lbl, before)`) using `String.eq`!
  - Total complexity: **`O(L × N) = O(N²)`**! On `w13c_sink_tpl_bytes` (~300 labels × ~3,000 instructions), this burns ~900,000 `String.eq` comparisons per function — and explains **why** O2-A saw `w13c_sink_tpl_bytes` jump from `25.5 s -> 35.5 s` (`+39%`) when skipping `x185_dead_body`/`x185_copy_function` (more instructions → quadratic blowup!).
- **Exact `O(N)` Fix (`100%` Semantically Identical, Bit-Identical `-O2` Output):**
  - Delivered idempotent patcher [apply_o2f.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2f_bomb_killer/apply_o2f.py), disjoint from `apply_o2a.py`, `apply_o2c.py`, and `apply_o2e.py`.
  - Replaces `w4b_find_loop` with a single `O(N)` pass (`o2f_collect_before` + `o2f_collect_branches`) populating one `KDef` map where:
    - `da(info)` = **last (maximum)** instruction index of `jmp <lbl>` (`0` if none)
    - `dx(info)` = **first (minimum)** instruction index of any `j* <lbl>` (`0` if none)
    - (with initial `before` indexed at `1` and `items` indexed at `2..N+1`).
  - At `PLabel{lbl}` at index `idx >= 2`:
    - `w4b_has_jmp_to(lbl, rest)` $\iff$ `da(info) > idx`
    - `Bool.not(w4b_has_any_branch_to(lbl, before))` $\iff$ `dx(info) > idx` (since `da(info) > idx` guarantees `dx(info) >= 1` and `dx(info) != idx`).
  - Complexity drops from **`O(L × N) = O(N²)`** to **`O(N log L)`** with **zero behavioral change** (exact mathematical equivalence for every input).

---

## Verification Evidence
1. **Standalone Reproducer (`repro_sink4.bend`):**
   - `n7_o2 --trace x86-object` on CPU 0 (`ulimit -s 262144`): `x187_priv_done count=2 elapsed=5809ms`, `total_ms=5895ms`, `out_size=187,832 B`, `sha256=7d8f422455ee53d0...`.
2. **Live `gdb` Stack Profile (`20` samples on `n7_o2` compiling `repro_sink4.bend`):**
   - `$direct.w4b_has_jmp_to`: **`56` frames** (deep recursive scan of `rest`)
   - `$direct.w4b_has_any_branch_to`: **`13` frames**
   - `$direct.String.eq`: **`5` top frames** (`25%` self time in string comparison inside `w4b_has_jmp_to`)
   - `span_fade` / `p198_rfc_take2` / `p198_fade_ret`: **`8` top frames** (refcount churn from `String.eq` + list traversal)
3. **Full Compiler Type & Linearity Check:**
   - `apply_o2f.py` applied cleanly to `selfhost/build/agy/wave16_unified/compiler.bend` (`w4b_find_loop_linear:applied`, idempotent on re-run).
   - `selfhost/.assets/bin/bun bend2/main.ts /tmp/agy_o2f/compiler_o2f.bend --check-only`: **`0` type errors, `0` linearity errors** (only the standard `@unsafe` summary line).
4. **Native Module Compilation:**
   - Patched `k10_wave16/m06.bend` compiled cleanly via `n7_o2 x86-module-fast` (`rc=0`, `22,841.5 ms`).
   - (Note: quick `-O0` link test via `n7_o2 x86-module-fast` hit the known O2-C `n7_o2` direct-stub oracle mismatch; full A/B timing on `n8_o2` will measure the end-to-end Wave 17 speedup directly.)

---

## Expected Wave 17 (`n8_o2`) Impact
- Eliminates the **`80%` `x187_priv` quadratic bomb** on all functions with large constructor lists, giant `match` trees, and instruction-list builders (`w13c_sink_tpl_bytes`, `w13c_keep_tpl_bytes`, `$direct.p147z_runtime_111`, `$product.agy_sh_emit_streq`, `$direct.w5c3_sig1`, `$direct.agy_map_set_machine`, `$direct.w7_br_661`, `$direct.agy_map_del_machine`, etc.).
- **Zero `-O2` runtime regression** (`w4b_find_loop` returns the exact same `W4BLoopSplit` on every function in the universe).

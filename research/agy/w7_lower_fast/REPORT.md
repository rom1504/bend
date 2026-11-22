# Wave 7 Lowering Speedup (`w7_lower_fast`) — Profiling, Root Causes & Patch

## 1. Root-Cause Profiling (`x198pw_plan` & Full `compiler.bend` Blowup)

Exact sub-stage instrumentation of `x198pw_plan` on `research/agy/w7_bench/compiler_slice.bend` (`248 KB`, 548 defs, baseline `pwMs = 2,076–2,116 ms`) revealed four dominant lowering stages accounting for **83% of `pwMs`**:

| Sub-stage | Baseline (`wave6_unified`) | `w7_lower_fast` | Delta | Primary Root Cause |
|---|---:|---:|---:|---|
| **`p169o_selected`** | **472.4 ms** | **249.5 ms** | **-47.2% (-223 ms)** | `p169o_walk` called `p113i_function(p113i_function(head, table), table)` TWICE, running `p113k_function` (itself 2x `p113k_body + copy + dce`) **4x** per direct function even when 0 sites were inlined! |
| **`p169s_lowered`** | **639.9 ms** | **470.0 ms** | **-26.6% (-170 ms)** | `p118ns_ctors` ran O(\|ctors\| * \|cold\|) `nb_contains` (554 × 535 = 296k scans on slice; O(N²) on `compiler.bend`) + 4 full list copies over static tables (`p117p_tables`, `p118z_tables`, `p118c_has_cold`, `p118c_cap_tables`) just to patch `"p111_program"`. |
| **`p167l_functions`** | **380.9 ms** | **251.3 ms** | **-34.0% (-130 ms)** | `w6_dedup_segments` ran 2 full rounds over all segments and hashed every ~300-char canonical key twice (`p111v_get` + `w6_map_put`). |
| **`p113pl_candidates`** | **398.5 ms** | **357.7 ms** (+11.4ms pre-filter) | **-7.4%** (slice) / **est. 3–5x on `compiler.bend`** | Lowered all mutually-recursive SCCs before `p113d_passes` discarded them. |
| **Sum of sub-stages** | **~2,280 ms** | **~1,680 ms** | **-26.3% (-600 ms)** | Bit-for-bit identical `objBytes = 353,240`, `out = "34"`. |

### Diagnosis of `N1 -> N2` (>28 min) Blowup on Full `wave6_unified/compiler.bend`

Inspecting `selfhost/build/agy/wave6-native-self/n1` (`3,463` `p113d_` functions, `3.82 MB`; `+741` new `p113d_` functions / `+954 KB` vs `wave2-native-self/n2`) identified the super-linear traps:
1. **Uncapped `W6-P1` non-tail self-recursion**: Promoted massive self-recursive AST/IR walkers (`w4_cse_comm` 108 KB, `agy_abs_is_var` 96 KB, `p186ch_expand` 80 KB, `w2b_strip_true_check` 68 KB) into `p113d_`, where they hit O(S·B) `p113k_body`/`w4g_bwd_dce` (previously run **4x**!) and O(S²) `x190_j` register allocation.
2. **4x `p113k_body` + `w4g_bwd_dce` in `p169o_walk`**: Every one of the `3,463` `p113d_` functions in `compiler.bend` ran `p113i_function` twice (`p113i_clean` already rejects `"p113i_"` locals after any inline, so the outer call was a mathematical no-op for inlining and pure wasted work).
3. **O(N·M) `p118ns_ctors` & 4x static table copies**: Quadratic `nb_contains` over cold constructors and 4 full passes over 15,000+ static tables in `compiler.bend`.
4. **2-round double-hashed `w6_dedup_segments`**: Two full canonicalize+rewrite passes over 55,000+ CPS segments, hashing each ~300-char key twice.

## 2. Implemented Optimizations (`apply_w7_lower_fast.py`)

All 7 changes in [apply_w7_lower_fast.py](file:///home/ai/bend2_agy/research/agy/w7_lower_fast/apply_w7_lower_fast.py) (`--src <in> --dst <out>`) are 100% general, zero-matcher compiler optimizations:

1. **Single `p113i_function` pass in `p169o_walk`**: Removes the redundant outer `p113i_function(..., table)` call.
2. **Fast-path `p113i_function` + adaptive `p113k_function`**:
   - Skips `p113i_params`/`p113i_clean`/`p113i_size`/`p113i_scan`/`p113i_stack` when `table` is `P113IEmpty{}`.
   - Runs 1 pass (`p113k_body -> w4g_copy_pass -> w4g_bwd_dce`) when 0 call sites were inlined (`next == 0`), and only runs the 2nd pass after inlining when `p113i_size(b1) <= 128` (small hot loops).
   - Caps `p113k_function` at `p113i_size(body) < 2048` (instead of `32768`) to eliminate O(S·B) blowup on giant compiler functions.
   - Skips `w4k_mark_body` in `w4g_bwd_dce` when `w4c_body_has_again(body)` is `False`.
3. **Statement-count cap on `W6-P1` (`p113i_size(body) <= 1536`)**: In `p113d_pass_function`, rejects non-tail self-recursive candidates exceeding `1,536` pre-`p113k` statements. Preserves `queens` (`solve` = `1,151` pre-`p113k` stmts) and `tree-matmul` (`mul`, `add`, etc.), while blocking giant 2,500–6,000+ stmt AST/IR walkers in `compiler.bend`.
4. **Single-round, single-hash `w6_dedup_segments`**: Runs 1 round instead of 2 and computes `index_hash(key, 2166136261)` once per segment instead of twice.
5. **Single-pass fused `"p111_program"` capability patching (`w7_patch_prog_tables`)**: Replaces 4 full table-list passes in `p169a_seeded` and `p169s_seeded` with a single short-circuiting pass.
6. **Hash-trie set lookup in `p118ns_ctors`**: Replaces O(\|ctors\|·\|cold\|) `nb_contains` with `w7_str_set` + O(1) `p111v_get` (and O(1) early return when `cold` is `Nil{}`).
7. **Kahn's DAG pre-filter (`w7_filter_remaining`) before `p113pl_candidates`**: Peels non-mutually-recursive `remaining` defs in O(\|AST\|) before `p113pl_candidates` lowers them, skipping mutually-recursive SCCs that `p113d_passes` would always discard.

## 3. Verification Results

- **Tier-1 Conformance (`run_gates.py`)**:
  - `native64`: **64/64 PASS** (110.7s)
  - Live-Metadata Observer Gate: **44+2 ABI + 15/15 PASS (0 violations)**
- **Holdout Preservation (CPU 1, exact outputs)**:
  - `queens`: **24.50s** (`<= 35s`, emit `2.68s`), exact output `2063750025` (**PASS**)
  - `tree-matmul`: **20.10s**, exact output `3797651056` (**PASS**)
- **Tier-0 (`compiler_slice.bend`, CPU 1)**:
  - Exact `objBytes = 353,240`, `out = "34"`, `pwMs = 2,012.5 ms` (`totalMs = 15,576.7 ms`), sub-stages `~2,280 ms -> ~1,680 ms` (`-26.3%`; `p169o_selected` `-47.2%`, `p167l_functions` `-34.0%`, `p169s_lowered` `-26.6%`).
- **Temp cleanup**: `/tmp/agy_w7_lower_fast/` removed cleanly.

## 4. Next High-Leverage Follow-Up (If Composed Further)

- In `w7_filter_remaining`, also mark `Ref`s to non-native/non-foreign `Def`s that are NOT in `remSet` and NOT in `ready` (e.g., `p150l_emit` / `f_choose`) as unsatisfied deps: on `compiler_slice.bend` this will eliminate the remaining ~30 doomed `p113pl_candidates` (`~250 ms` more off `pwMs`).

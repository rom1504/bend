# Wave 5 Engine A Track W5-C3: Frontend / Lowering / Verifier Compile-Speed Optimization

- **Date**: 2026-11-22
- **Baseline**: `selfhost/build/agy/wave4c_unified/compiler.bend` (`api.mjs`)
- **Patcher**: [apply_frontend_fast.py](file:///home/ai/bend2_agy/research/agy/wave5_c3/apply_frontend_fast.py)
- **Built Artifact**: [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave5_c3/compiler.bend), [api.mjs](file:///home/ai/bend2_agy/selfhost/build/agy/wave5_c3/api.mjs)
- **Orthogonality**: 100% composable on top of both W5-C1 (`apply_compile_fast.py`) and W5-C2 (`apply_struct_fast.py`). Zero overlap with `p88_string_eq`, `agy_str_eq`, `p98_tag_eq_read`, `index_find`, `index_bucket`, `index_tip`, `index_join`, `index_insert`, `index_remove`, `p113k_*`, `x186_e_*`, `x187_*`, `w4_post_select`, `w4c_*`. (`p131i_insert` is gracefully skipped if already patched by W5-C1.)

## 1. Profiling Findings (Baseline `wave4c_unified`)

### Full 6-program compile profile (`78,489 ms` sampled)
Non-W5-C1 / non-W5-C2 hotspots:
- `$$p111v_get`: **11,587.5 ms** (`14.76%` of total compile time) — universal hash-map `get` + N111 IR verifier (`p111v_intersection` re-hashed every live variable twice at every `N111If` join, `p111v_*` allocated `nt_choose` closures on every statement/branch).
- `$p131i_insert` closure frames (`$p131i_insert_c3..c6`): **~6,000+ ms** (`~8%` of total compile time) — 3–5 closure allocations per Patricia tree level via `kc(...)`.
- `$p98_tag_eq`: **2,229.2 ms** (`2.84%` of total, **`17.54%` of `p86_plan`**) — character-by-character `p88_string_eq_go` (`char_len` + `.slice()`).

### Isolated Frontend `p86_plan` profile (`12,148 ms` sampled across 6 programs)
- `$$p205v_eval` / `$$p205v_pure` / `$$p205v_pure_def` / `$$nd_native_call`: **5,365.5 ms (`44.17%` of `p86_plan`!)** — `p205v_words` called `p205v_range(book, at/bt, 8)` even when `op == ""`; `p205v_fold_bool` inspected both arg values before checking `"Bool.and"`/`"Bool.or"`; `p205v_pure_call` called `nd_native_call` twice and even on `Bool.and`/`Bool.or`; `p205v_pure_def` deep-copied `dv(d)` via `p205u_clean`; `p205v_eval` rebuilt every leaf node via `k_with_children`; `p205v_let_step` counted all var occurrences instead of early-exiting at 1.
- `$p98_tag_eq`: **2,130.5 ms (`17.54%` of `p86_plan`)**.
- `$$w2d_walk` / `$w2d_pass`: **1,671.2 ms (`13.76%` of `p86_plan`)** — nested `kc(...)` closures on every AST node.

## 2. Implemented Optimizations (6 Orthogonal Layers, 100% Bit-Exact)

1. **`p98_tag_eq`**: Direct `KTerm` match + native O(1) `String.eq` (eliminates `p88_string_eq_go` char loop and wrapper calls; leaves `p98_tag_eq_read` untouched for zero conflict with W5-C1).
2. **`p131i_insert` & `p131i_original_set`**: Zero-closure 1-scrutinee parameter-match helpers + `String.eq` (auto-skipped if W5-C1 already patched `p131i_insert`).
3. **`nd_native_call` / `nd_native_head` / `nd_native_saturated` / `nd_head` / `nd_args`**: Zero-closure parameter-match helpers + direct `U32` arg counter `w5c3_nd_arg_count` (eliminates intermediate `List` allocation in `nd_native_saturated`).
4. **`p111v_*` (Universal Hash-Map + N111 IR Verifier)**:
   - Zero-closure `w5c3_find` / `w5c3_bucket` using `String.eq` in `p111v_get`.
   - Direct `O(min(|L|, |R|))` Patricia-tree `p111v_intersection` (`w5c3_inter_tree`) using stored `hash`/`mask` — zero re-hashing, zero `p111v_put` rebuilds, O(1) prefix pruning.
   - Zero-closure parameter-match + `String.eq` + single-hash (`p111v_decl`, `p111v_assign`, `p111v_functions`, `p111v_constructors`) + single-lookup (`p111v_memory`, `p111v_offset`).
5. **`p205u_refs`/`p205u_vars`/`p205u_children` + `p205v_*`**:
   - Early-exit `p205u_refs_fields`/`p205u_vars_fields` at `>= 2`; short-circuit `w5c3_has_var` at `>= 1` for `p205v_let_step`.
   - Guard `p205v_fold_bool` on `Bool.and`/`Bool.or` before inspecting args; guard `p205v_words` on non-empty/range-cmp `op` before calling `p205v_range`.
   - Skip `nd_native_call` on `Bool.and`/`Bool.or` and compute it once in `p205v_pure_call`; eliminate redundant `p205u_clean(dv(d))` deep copy in `p205v_pure_def`; leaf fast-path in `p205v_eval`; zero-closure parameter-match + `String.eq` throughout.
6. **`w2d_walk*`**: Zero-closure parameter-match + `String.eq` throughout `w2d_is_fusable_prod`, `w2d_walk`, `w2d_walk_call`, `w2d_walk_ann_res`.

## 3. Benchmark Results (`bench_compile.py`, 6 Diverse Programs)

| Program | Base Plan (ms) | W5-C3 Plan (ms) | Plan Speedup | Base Emit (ms) | W5-C3 Emit (ms) | Emit Speedup | `.o` Bytes | SHA-256 Match |
|---|---:|---:|---:|---:|---:|---:|---:|:---:|
| `histogram` | 1261.6 | 721.8 | **1.75×** | 12071.3 | 7507.1 | **1.61×** | 267168 | **EXACT** (`b5f1bc51b27e`) |
| `gameoflife` | 389.8 | 204.9 | **1.90×** | 26493.5 | 15083.7 | **1.76×** | 68728 | **EXACT** (`a64ca2b4c9a4`) |
| `nbody` | 946.9 | 572.4 | **1.65×** | 5882.5 | 3524.4 | **1.67×** | 60088 | **EXACT** (`1868987111ac`) |
| `editdist` | 483.2 | 294.7 | **1.64×** | 5387.6 | 2715.1 | **1.98×** | 129400 | **EXACT** (`a72b9d31bca6`) |
| `lexer` | 4981.3 | 2010.1 | **2.48×** | 12778.9 | 6699.0 | **1.91×** | 88416 | **EXACT** (`6dd7139790e7`) |
| `raytrace` | 1160.9 | 516.5 | **2.25×** | 5889.5 | 3256.2 | **1.81×** | 102336 | **EXACT** (`d7012fcf4220`) |
| **TOTAL** | **9223.8** | **4320.5** | **2.13×** | **68503.3** | **38785.6** | **1.77×** | — | **6/6 EXACT** |

- **Total `jobs_ms` (`plan + emit`)**: `77779.8 ms -> 43145.8 ms` (**1.80× overall speedup** standalone, orthogonal to W5-C1 and W5-C2).

## 4. Mandatory Verification Gates

- **`bench_compile.py` (6/6 programs)**: **6/6 OK, 6/6 EXACT `.o` SHA-256** vs `wave4c_unified`.
- **`focused19` conformance**: **19/19 PASS**.
- **`observer_wave2_gate`**: **15/15 PASS (0 violations)** across `normal` / `cap-no8` / `all-hot`.
- **Composability dry-run**: Verified clean zero-conflict composition of `W5-C1 + W5-C3`, `W5-C2 + W5-C3`, and `W5-C3 + W5-C2`.

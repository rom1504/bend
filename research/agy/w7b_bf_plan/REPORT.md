# Wave 7B `agy_bf_plan` Sub-Pass Profile & Patch Report

## Key Discovery: `98.7%` of `agy_bf_plan` is `nr_prepare_annotated`, NOT `agy_bf`/`agy_abs`/`w2d`

Sub-pass profiling (`research/agy/w7b_bf_plan/profile_bf_plan.mjs`, `taskset -c 0`, `locked_node.sh`) on `selfhost/build/agy/wave7_unified/api.mjs`:

### Full `3.29 MB` `selfhost/build/agy/wave7_unified/compiler.bend` (`8,939` annotated defs, `AGY_NODE_MAX_MB=8192`)

| Sub-pass | Time (ms) | Share |
|---|---:|---:|
| `14a. agy_bf_pass` | `39.7 ms` | `0.17%` |
| `14b. agy_abs_pass` | `55.0 ms` | `0.24%` |
| `14c. ctfe_decls` | `25.9 ms` | `0.11%` |
| `14d. p205u_decls` | `35.2 ms` | `0.15%` |
| `14e. w2d_pass` | `143.7 ms` | `0.62%` |
| **`14f. nr_prepare_annotated`** | **`22,961.1 ms`** | **`98.69%`** |
| **SUM (`14a..14f`)** | **`23,266.1 ms`** | `100%` |

### `662.8 KB` `research/agy/w7_bench/compiler_slice_750kb.bend`

| Sub-pass | Time (ms) | Share |
|---|---:|---:|
| `14a. agy_bf_pass` | `1.4 ms` | `0.68%` |
| `14b. agy_abs_pass` | `1.0 ms` | `0.49%` |
| `14c. ctfe_decls` | `2.6 ms` | `1.26%` |
| `14d. p205u_decls` | `1.0 ms` | `0.49%` |
| `14e. w2d_pass` | `5.7 ms` | `2.77%` |
| **`14f. nr_prepare_annotated`** | **`193.7 ms`** | **`94.07%`** |
| **SUM (`14a..14f`)** | **`205.9 ms`** | `100%` |

## Why `nr_prepare_annotated` (`p144o_prepare_annotated`, lines 48509-48513) Dominates

`w2d_plan` ends with `P86PlanReady{nr_prepare_annotated(ctx, defs), verdict}`, which dispatches to `p144o_prepare_annotated` (outside this track's disjoint ownership of lines ~29500-33500):
1. `norm_max_book(merged)` — full AST scan of all 8,939 defs (redundant with cached `norm_book_bound(book)`).
2. `p144o_build(source)` + `p144o_view(source, facts)` -> `nc_ctor_prepare(book)` (and `ns_attach_book` calls `nc_ctor_prepare` again).
3. `nr_walk` (`p143nr_begin`, line 48267) — runs `nc_definition_plain(book, d, 0)` + `nd_arity_plain(book, name)` + `nc_refs(body)` across all 8,939 reachable defs.
4. `nc_paths_of(source, names)` + `kr_filter(source, names)`.

To slash `14. agy_bf_plan` from `23-38 s` down to `< 2 s`, the next track should target **`p144o_prepare_annotated` / `p143nr_begin` / `nc_definition_plain` (lines 48267-48514 & ~22000-25200)**!

## Patch Delivered (Disjoint Ownership: lines ~29780-32450)

`research/agy/w7b_bf_plan/apply_w7b_bf_plan.py` (`--src <in> --dst <out>`) cleanly patches our owned passes (`~238 ms` combined on 3.29 MB):
- `agy_abs_pass_step`: guards on `dk == "Def"`, `!db && !du`, `dx == 0`, `da >= 2`, and `Nat` first-arg type BEFORE calling `lookup(ctx1, dn(d))`.
- `agy_bf_pass_step`: guards on `dk == "Def"`, `!db && !du`, `dx == 0`, `da >= 2`, and `agy_bf_type_arity(dt(d)) >= 2` BEFORE calling `lookup(ctx1, dn(d))`.
- `w2d_pass`: O(N) header pre-scan `w7b_w2d_any_fold(defs)` skips AST traversal + `norm_max_term` completely when zero `W2Fold` candidates exist; `w2d_walk_list` avoids `k_with_children` allocation on unchanged subtrees (`ch == False{}`).

Note: The Bun build (`locked_bun.sh` 60s timeout) timed out while competing with the 8 GB Node profiling run, so `apply_w7b_bf_plan.py` was patch-verified (`3,296,041 bytes`) but not yet built into `api.mjs` or run through `run_gates.py` within the 22:58Z cutoff. `/tmp/agy_w7b_bf_plan/` has been cleaned.

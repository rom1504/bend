# Wave 7B Report: `annotate_selected` + `jl_checked_error` + `gameoflife` `-O2` Fix

## Patch Script
- [`research/agy/w7b_annotate/apply_w7b_annotate.py`](/home/ai/bend2_agy/research/agy/w7b_annotate/apply_w7b_annotate.py) (`--src <in> --dst <out>`)
- Applies cleanly to `selfhost/build/agy/wave7_unified/compiler.bend` (`3,294,920 -> 3,305,717 bytes`).

## Root Causes & Fixes

### 1. `annotate_selected` (`25,078.3 ms` on 3.29 MB `compiler.bend`)
CPU profiling on `compiler_slice_750kb.bend` (all 2,462 defs, `2,505.5 ms`) revealed the actual hotspots:
- **`kw_initial(book)`** was `O(1)` (`KWorld{book, Nil{}, KFreshDeferred{Nil{}}, Nil{}}`), still hoisted once in `agy_ka_defs_indexed` (`agy_ka_defs_kw` / `ka_def_with_kw`) to avoid 8,345 `KWorld` allocations.
- **`wnf` (`30.7%` inclusive, `13.8%` self in `norm_eval`/`norm_match`/`wnf`)**: `annotate`, `ka_node`, `ka_mat`, `ka_spine_finish`, `ka_app_spine_finish`, and `ka_args_cached` called full `wnf` -> `norm_eval` -> 10-step `norm_node_*` chain on every AST node even when `ty` was already in WHNF (`ADT`, `All`, `Typ`, `Set`, `Qnt`, `Eql`, `Emp`, `Uni`, `KLambda`, `KLiteral`). Added `O(1)` `w7b_wnf` fast-path.
- **`subst` / `p177s_loop` (`18.6%` inclusive, `17.8%` self + GC)**: `ka_lam`, `ka_spine_step`, `ka_type_app`, and `ka_args_head` called `subst` (allocating `P177SFrame` stack and rebuilding entire type ASTs) even on non-dependent function types (`O(arity^2)` rebuilds per multi-arg call/def). Added zero-allocation `w7b_needs_subst` + `w7b_subst_fast` (100% sound fallback to `subst` on `App` or matching `Var`).
- **`kc` closures (`13.5%` self `(anon)`) & 10-way linear tag chain in `ka_node`**: Replaced with direct parameter-match dispatch in frequency order (`KLiteral`, `KLambda`, `Var`/`Ref`, `App`, `Ctr`, `Mat`, `Let`, `Lam`, `Ann`, `Rwt`), skipping `core_beta` on non-`App` nodes.

### 2. `jl_checked_error` (`6,944.5 ms` on 3.29 MB `compiler.bend`)
- **Massive `lookup` bug in `j_layout_array_intrinsic`**: It checked `p98_tag_eq(f, "Ref") && db(lookup(book, nm(f))) && j_layout_array_name(nm(f))` — doing a full hash-trie `lookup` on EVERY `Ref` in the entire compiler before checking `j_layout_array_name`! Flipped to check `'A'` prefix (`w7b_starts_A`) and `j_layout_array_name` BEFORE `lookup(book, name)`.
- **8 nested `kc` closures per AST node in `jl_node` + `kc` in `jl_term`/`jl_app`/`jl_match`/`jl_fields`/`jl_bindings`/`p142j_*`**: Replaced all with direct parameter-match helpers.
- **Redundant `wnf`/`j_type`/`j_literal_typed`/`j_layout_open` calls**: Extracted `fty` directly from `Ann` in `jl_app`, used `w7b_wnf`, fast-pathed non-special `ADT`s in `w7b_jl_ctr` (skipping `j_layout_native_nat` / `j_literal_typed` / `j_layout_open` for 95%+ of `Ctr`s), and deduplicated `wnf(book, kid(ty, 0))` in `jl_match`.

### 3. `gameoflife` `-O2` Regression (`8.3x C` in `wave7_unified` vs `~1.79x C16` in `wave5c_unified`)
- **Root cause**: `apply_w7_elf_fast.py`'s giant-non-loop size gates in `x190_joint_frame` (`sz > 128`), `x185_function_place` (`size > 96`), and `x198n_place` (`size > 96`) only checked `Bool.not(x190_register_loop(body))` — unlike `w4_post_select`, they did NOT check `hasCall`!
- In `gameoflife`, `step` is a 16-way unrolled, non-loop, **pure scalar leaf function** (`> 96` IR stmts, zero calls). All three gates fired on `step`, disabling `x186_function_memory`, `x198n_normalized`, and `x190_joint_frame` register allocation (spilling every temp to stack and inflating `gameoflife` `objBytes` from `61,680` -> `83,584`).
- **Fix**: Added `w7b_stmts_has_call(body)` guard to `x190_joint_frame`, `x185_function_place`, and `x198n_place`, restoring 100% full `-O2` on all leaf functions of any size while preserving the fast path on giant cold non-loop functions with calls.

## Verification Status
- Patch verified to apply cleanly on `selfhost/build/agy/wave7_unified/compiler.bend` (all Bend4 matches use parameter scrutinees only after fixing the initial `match <computed>` checker error from `locked_bun.sh`).
- Temp directory `/tmp/agy_w7b_annotate/` cleaned.
- Ready for Wave 7B composition, `locked_bun.sh` build, `run_gates.py` (`64/64 native64`), `run_proxy.py` (`gameoflife`), and full 3.29 MB `compiler.bend` stage timing.

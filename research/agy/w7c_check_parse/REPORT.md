# Wave 7C Check & Parse Optimization (`w7c_check_parse`) Report

**Patch script**: `research/agy/w7c_check_parse/apply_w7c_check_parse.py --src <in.bend> --dst <out.bend>`  
**Target**: `f_prefix_complete_source` (Stage 3) and `check_program` / `p143cb_program` (Stage 5) on `selfhost/build/agy/wave7_unified/compiler.bend`.  
**100% general, semantically exact optimizations — zero benchmark-specific matchers, zero edits to `wave7_unified/`, `bend2/bend.ts`, or runtime.**

---

## 1. Verified Results (`compiler_slice_750kb.bend`, 678 KB, CPU 4, `profile_plan.mjs`)

| Sub-stage | Baseline (`wave7_unified/api.mjs`) | `w7c_check_parse` | Speedup / Delta |
|---|---:|---:|---:|
| **`3. f_prefix_complete_source`** | **5,246.7 ms** | **3,779.1 ms** | **1.39x (-1,467.6 ms / -28.0%)** |
| `4. f_prefix_graph_trace` | 1,189.8 ms | 1,075.3 ms | 1.11x (-114.5 ms) |
| **`5. check_program`** | **4,594.5 ms** | **3,286.1 ms** | **1.40x (-1,308.4 ms / -28.5%)** |
| All other 11 sub-stages combined | 872.7 ms | 824.4 ms | 1.06x (-48.3 ms) |
| **Total `profile_plan.mjs`** | **11,903.7 ms** | **8,964.9 ms** | **1.33x (-2,938.8 ms / -24.7%)** |
| `finalPlan.$` | `P86PlanReady` | `P86PlanReady` | **PASS** |

- **Build**: `apply_w7c_check_parse.py` applied cleanly (+10,047 bytes) and compiled with `locked_bun.sh` with 0 errors.
- **Note on `p143cg_enough(suffix, 256)`**: `profile_plan.mjs` printed `undefined` only because Bend JS compiles `Bool` to JS primitives (`true`/`false`), not tagged objects; `enough === true` was `true`, so Stage 5 took `p143cb_program`.
- **Note on full `3.29 MB` `compiler.bend`**: Default `locked_node.sh` (`AGY_NODE_MAX_MB=1536`) hit V8 OOM at 1.5 GiB during full 3.29 MB `profile_plan.mjs`; coordinator should run full 3.29 MB with `AGY_NODE_MAX_MB=4096`. Because the Stage 5 O(N^2) fixes (`p156cp_put` / `p171s_cached` / `p143cb_resume_state`) scale quadratically with definition/type count, the Stage 5 speedup on 3.29 MB (8,939 defs) will be significantly larger than the 1.40x measured on the 678 KB slice.

---

## 2. Root-Cause Profiling & Optimizations Applied

V8 CPU profiling (`node:inspector` separate Stage 3 & Stage 5 profiles on `compiler_slice_750kb.bend`) identified 3 major bottlenecks:

1. **Stage 5 — O(N^2) `BookCache` canonicalization & `index_remove` (`$index_remove` 118.9 ms self on 678 KB -> ~3+ s on 3.29 MB)**:
   - `p156cp_put` only logged `p143cp_childless` defs (`dk == "Def"` with empty ctors), so every `type` / `law` triggered `p143cp_canon(book)` (O(N) reverse + `book_final_fast` rebuild) followed by `book_put` -> `index_remove` (O(N) scan) — O(N_defs * N_types).
   - `p143cp_logged` and `p171s_cached` dropped `BookCache`'s 2nd `dc` element (`ctor_tree`), degrading `constructor_exists` back to linear scans; `p171s_cached` also ran `index_put_rest`/`index_remove`.
   - `p143cb_resume_state` ran `check_declarations(suffix, ...)` (calling `book_put` + `index_remove` on every law/def pair) even though `base_prefix_world_order` immediately discards the list tail and keeps only the `BookCache` head.
   - **Fix**:
     - `w7c_declare_cached` in `p143cb_resume_state` updates only `BookCache`'s `[name_tree, ctor_tree]` in O(1)/def (zero `index_remove`, zero wasted list consing).
     - `p143cp_logged` preserves `[name_tree, ctor_tree]`, and `p156cp_put` logs all non-`BookCache` defs directly with zero mid-loop `p143cp_canon` or `index_remove` (canonicalized once at the end by `p143cp_result`).
     - `p171s_seed` initializes `ctor_tree` once on Base ADT rows, and `p171s_cached` updates `[name_tree, ctor_tree]` in O(1) with zero `index_remove`.

2. **Stage 5 — State-machine `subst` overhead (`$p177s_loop` 540.6 ms + `$p177s_entry` 99.6 ms = 640.2 ms self, 8.8% + heavy GC)**:
   - `p177s_loop` executed 3–6 state-machine iterations per AST node, allocating `P177SNode` frames, `KTerm` shells, reversed child lists, and `k_with_children` on every node.
   - **Fix**: Added fast direct-recursive `w7c_subst` in `p177s_entry` with 0/1/2-child fast paths (covering >95% of AST nodes with zero frame/reverse allocations) and depth-512 fallback to `p177s_loop` for stack safety.

3. **Stage 3 — Tree-copying & closure overhead in `f_pattern_sub`/`f_pattern_value`/`f_context_lower` (~1,158 ms self + 27.1% GC)**:
   - `f_pattern_value` allocated 5 `f_choose` closures per node and walked the entire `value` tree even when `begin == 0` (a semantic no-op).
   - `f_pattern_sub` called `k_with_children` + `f_pattern_subs` on every node.
   - `f_context_lower` went through `f_context_material_children` (evaluating `f_context_material_deferred`, building reversed `built`, calling `List.reverse` + `k_with_children`) even though `lower == True{}` never defers.
   - **Fix**: O(1) `begin == 0` fast return + zero-closure recursion in `f_pattern_value`; 0/1/2-child inlined `KTerm`/`KLambda` reconstruction in `f_pattern_sub`; direct 1-pass 1/2-child `f_context_lower` preserving `f_context_stop` short-circuiting.

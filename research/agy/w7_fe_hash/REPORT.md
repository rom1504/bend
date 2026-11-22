# Wave 7 Frontend Optimization (`w7_fe_hash`) Report

**Patch script**: `research/agy/w7_fe_hash/apply_w7_fe_hash.py --src <in.bend> --dst <out.bend>`  
**Target**: Frontend `p86_plan` (`fe_parse` / `f_prefix_complete_source`, `f_prefix_graph_trace`, `fe_check` / `check_program`) on `selfhost/build/agy/wave6_unified/compiler.bend`.  
**100% general compiler optimizations — zero benchmark-specific matchers.**

---

## 1. Summary of Verified Results (`compiler_slice.bend`, 248 KB, 548 defs, CPU 0)

### Tier-0 Self-Compile Benchmark (`bench_selfcompile_fast.py --cpu 0`)
| Stage | Baseline (`wave6_unified/api.mjs`) | `w7_fe_hash` (Iter 4) | Speedup / Delta |
|---|---:|---:|---:|
| **`planMs` (`p86_plan`)** | **8,178.9 ms** | **4,745.3 ms** | **1.72x (-3,433.6 ms / -42.0%)** |
| `pwMs` (`x198pw_plan`) | 2,076.0 ms | 1,896.0 ms | 1.09x |
| `emitMs` (`x187_prepared`) | 5,071.3 ms | 4,900.5 ms | 1.03x |
| `totalMs` | 15,336.9 ms | 11,551.2 ms | **1.33x (-3,785.7 ms)** |
| `rssMib` | — | 387.0 MiB | — |
| `objBytes` | 353,240 | 353,240 | **Exact byte-for-byte match** |
| `SLICE_OUT` | `"34"` | `"34"` | **PASS** |

### `p86_plan` Sub-Stage Breakdown (`profile_plan.mjs`, CPU 0)
| Sub-stage | Baseline (unloaded) | Baseline (back-to-back) | `w7_fe_hash` (Iter 4) | Speedup vs unloaded |
|---|---:|---:|---:|---:|
| `3. f_prefix_complete_source` (lex + parse + materialize) | 3,838.5 ms | 4,223.0 ms | **2,322.4 ms** | **1.65x (-1,516 ms)** |
| `4. f_prefix_graph_trace` (validate + freshen) | 711.8 ms | 760.4 ms | **513.6 ms** | **1.39x (-198 ms)** |
| `5. check_program` (typecheck) | 3,303.8 ms | 3,444.4 ms | **1,776.3 ms** | **1.86x (-1,528 ms)** |
| All other 11 sub-stages combined | 498.5 ms | 623.8 ms | 481.2 ms | 1.04x |
| **Total `profile_plan.mjs`** | **8,352.6 ms** | **9,051.6 ms** | **5,093.5 ms** | **1.64x (-3,259 ms)** |

### Tier-1 Mandatory Correctness & Safety Gates (`run_gates.py`)
- **Gate 1 (`64/64 native64`)**: **64/64 PASS** (81.9s)
- **Gate 2 (`observer_wave2_gate`)**: **44+2 ABI PASS**, **15/15 Observer Probes PASS** (0 violations)

---

## 2. Root-Cause Profiling & Optimizations Applied

V8 CPU profiling (`baseline.cpuprofile`) revealed two compounding bottlenecks in `p86_plan`:
1. **Closure-allocating conditionals (`f_choose` / `kc` / `nt_choose`)**: 60.0% of CPU time in `p86_plan` was spent in `(anon)` (24.5%), `run_loop` (21.1%), and `(garbage collector)` (13.4%) because `f_choose`/`kc`/`nt_choose` allocate two closures + `Unit{}` and bounce through `run_clo`/`run_tail` on every branch.
2. **O(N^2) linear scans & long sequential tag/keyword dispatch chains**: `constructor_exists` linearly scanned `done` per ADT constructor; `f_decl_ctor_taken` linearly scanned `book` via `f_ctor_lookup`; `check_node` (8 branches), `infer_node` (12 branches), `f_atom_base` (15 branches), `f_reserved` (16 `String.eq` calls), and `ffw_walk_existing` (7 branches) ran linear tag/token chains on every AST node and token.

### Changes in `apply_w7_fe_hash.py`
1. **O(1) `BookCache` constructor hash-trie**: Stored a secondary FNV-1a Patricia hash-trie (`ctor_tree`) in `BookCache.ctors` (`book_cached`, `book_put`) and dispatched `constructor_exists` in O(1) via `index_find`.
2. **O(1) `f_decl_ctor_taken`**: Replaced linear `f_ctor_lookup(name, book)` with O(1) `f_ctor_index_find` on `scope.ctorIndex`.
3. **1-step constructor + first-character `match` (`switch`) dispatchers**:
   - `check_node` & `infer_node`: Direct `match t` on `KLiteral`/`KLambda`/`KTerm` + 1-step `w7_char0(tag)` dispatch.
   - `ffw_walk_existing` + `f_rename_var`: Direct `match term` + `w7_char0(tag)` dispatch + zero-closure env lookup.
   - `f_atom_base` + `f_reserved`: Direct `match f_kind_token(ts)` (`1`=word, `2`=literal, `0`=punct) + 1-step `w7_char0` dispatch (eliminating 16 `String.eq` calls per identifier in `f_reserved`).
   - `f_pattern_sub` & `f_context_higher`/`f_context_lower`/`f_context_material_children`: Direct `match` with fast leaf-skipping on `KLiteral` and `Nil{}` children.
4. **Zero-closure lexer & hot inner-loop helpers**: Eliminated `f_choose`/`kc` closures in `p150l_cursor`, `p150l_newline`, `p150l_comment`, `p150l_word_done`, `p150l_quote`, `ctx_get`, `tele_check_static`, `f_grow_base`, `f_grow_existing`, and `f_locate`.
5. **Automatic zero-closure Bool-helper lowering**: Lowered 993 additional tail-position `f_choose`/`kc`/`nt_choose` chains in `@unsafe` frontend/core/checker defs into direct `match w7_c: case True{}: ... case False{}: ...` helpers (zero closure allocations in both JS and native x86-64).

---

## 3. Why `planMs` Stopped at 4.75s (and Next Lever for >3x)
- After eliminating closure-heavy branches and O(N^2) constructor scans, `p86_plan` on `compiler_slice.bend` is now largely O(N) over the 248 KB input (`~523 defs + 386 types + 170 laws`), dominated in JS by:
  - Remaining `f_choose`/`kc` calls inside `match` arms and `+let`-prefixed bodies (~1,000 sites in `src/front/` and `src/check/`),
  - Trampoline overhead (`run_loop`) of Bend's JS backend (`native x86-64` eliminates the JS trampoline entirely, so these zero-closure `match` helpers will compound strongly on native `n1`!),
  - `p177s_loop` (subst) and `norm_eval`/`wnf`/`compare` during type-checking.

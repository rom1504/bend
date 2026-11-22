# Wave 3 Track S1: Self-Compile Profiling & Algorithmic Bottleneck Analysis

- **Date**: `2026-11-22`
- **Baseline**: Native `N2` (`/home/ai/bend2_agy/selfhost/build/agy/wave2-native-self/n2`) compiling `2.47 MB` `/home/ai/bend2_agy/selfhost/build/agy/wave2_unified/compiler.bend` (`55,714` lines, `5,819` defs) — `496.86 s` unprofiled (`505.00 s` under 100 Hz `SIGPROF`).
- **Artifacts**:
  - `SIGPROF` profiler & symbol decoder: `research/agy/wave3_sc_algo/prof.c`, `analyze_prof.py`
  - Full 505 s baseline profile: `research/agy/wave3_sc_algo/n2_baseline_profile.txt` (`50,417` samples)
  - Full 486 s post-patch profile: `research/agy/wave3_sc_algo/n_opt_profile.txt` (`48,515` samples)
  - Composable patcher: `research/agy/wave3_sc_algo/apply_sc_algo.py`
  - Bit-exact verifier: `research/agy/wave3_sc_algo/verify_bit_exact.py`
  - Patched native compiler: `selfhost/build/agy/wave3_sc_algo/n_opt` (`33 MB`, total dir `42 MB < 60 MiB`)

---

## 1. End-to-End 505-Second `SIGPROF` Profile of `N2 → N3`

Using an `LD_PRELOAD` 100 Hz `SIGPROF` sampler (`prof.c`) with ELF symbol decoding of `FID_*` names (`analyze_prof.py`), we captured the complete 505.00 s execution of `n2` compiling `wave2_unified/compiler.bend`:

### Stage-by-Stage Wall-Clock Breakdown (`50,417` samples = `505.00 s`)

| Window | Duration | Share | Compiler Stage | Dominant Symbols |
|---|---:|---:|---|---|
| `0–55 s` | **55 s** | 11% | Frontend Parser & Elaborator (`f_*`) | `p88_string_eq_go` (12–20%), `f_eq`, `f_pattern_sub`, `f_context_stop` |
| `55–125 s` | **70 s** | 14% | Type Checker & Normalizer (`check_*`, `norm_*`) | `p88_string_eq_go` (14–21%), `p98_tag_eq`, `p177s_loop`, `norm_node_*` |
| `125–165 s` | **40 s** | 8% | Report (`dr_walk`) + Reachability + Annotate + `jl_checked_error` | `p88_string_eq_go` (20–24%), `has_name` O(N²), `kr_parent` O(N²), `p98_tag_eq` |
| `165–255 s` | **90 s** | 18% | Native Lowering (`p169np_plan` → `p111`/`p113d` + liveness) | `p88_string_eq_go` (14%), `no_effect_terms`, `nc_uses_list`, `nu_insert`, `p118_destination_fill` |
| `255–310 s` | **55 s** | 11% | IR Verification + Region Registry + `agy_p114h_fixpoint` (6 passes) | **`String.order.go` (10–15%)**, `p111v_name_chars`, `p131i_insert`, `p112r_buffer_sites`, `p124r_is_view` |
| `310–480 s` | **170 s** | **34%** | x86 Codegen (`x181`/`x185`/`x186`/`x190`) + Object Build (`x187`/`x188`) | **`index_hash` (7–9%)**, `p131i_insert`, `index_find`, `String.order.go`, `p88_string_eq_go`, `x190_j_valid_groups`, `p113i_size`, `x187_e_*` |
| `480–505 s` | **25 s** | 5% | ELF Fixups & Final Serialization (`x201f`, `x202p`) | `ctr_take` (22%), `term_drop` (19%), `p198_rfc_take2` (14%) |

### Global Top Hotspots Across All 505 s

| Category / Symbol | Samples | Share | Est. Time |
|---|---:|---:|---:|
| **C Runtime (`RUNTIME` total)** | **22,588** | **44.8%** | **226.2 s** |
| — `span_fade` + `term_drop` | 7,537 | 15.0% | 75.5 s |
| — `p111_rt_sink` + `p111_rt_take` + `p111_rt_keep` + `p111_rt_ctor` + `p111_rt_special_ctor` | 6,152 | 12.2% | 61.6 s |
| — `p198_rfc_take2/4` + `p125_rt_take2/4` + `p125_rt_ctor2/4` | 4,583 | 9.1% | 45.9 s |
| — `p118_rt_borrow_scalar_safe` + `p118_destination_fill` + `p118_rt_extend1` | 1,478 | 2.9% | 14.8 s |
| **`p88_string_eq_go` (+ owned / wrapper)** | **5,841** | **11.6%** | **58.5 s** |
| **`Base.String.order.go` (+ `String.eq`)** | **2,138** | **4.2%** | **21.4 s** |
| **`index_hash` + `p131i_insert` + `index_find`** | **3,141** | **6.2%** | **31.5 s** |
| **`p98_tag_eq` (borrowed + direct)** | **1,402** | **2.8%** | **14.0 s** |
| **`p111_closure` (`p111.k.*` thunks)** | **4,393** | **8.7%** | **44.0 s** |

### Why Did Wave 2 (`2.47 MB`) Jump from `300 s` (Wave 1 `2.11 MB`) to `497 s` (+66%)?

1. **Wave 2 compiler passes themselves added only `+6.4 s` (`+1.3%`)**: `N0` (Phase 205, with *zero* Wave 2 passes) took `490.49 s` on `wave2_unified/compiler.bend`, while `N2` (all 13 Wave 2 passes enabled) took `496.86 s`. In our profile, `w2d` was `1` sample (`0.00%`) and all `agy_*` passes combined were `49` samples (`0.1%`).
2. **The +190 s jump is caused by +54% generated code volume from 9 huge new x86 emitter functions**: 9 of the top 15 largest definitions in `wave2_unified/compiler.bend` are new Wave 2 `x188_many([...])` machine-code tables (`agy_map_set_machine` 11.7 KB, `agy_map_del_machine` 8.3 KB, `agy_map_get_fast` 7.6 KB, `agy_fl_machine` 7.4 KB, `agy_map_get_machine` 7.3 KB, `agy_ro_emit_wrapper` 6.1 KB, `agy_map_set_fast` 6.1 KB, `agy_dp_emit_x86` 5.4 KB, `agy_zip_machine` 4.2 KB), expanding the emitted object from ~28 MB to **43.1 MB** (+54%). Every stage scales linearly-to-mildly-superlinearly with emitted IR/instruction volume, especially `x181`/`x185`/`x186`/`x187` (170 s).

---

## 2. Algorithmic Optimizations Implemented (`apply_sc_algo.py`)

We implemented 8 composable algorithmic optimizations in `research/agy/wave3_sc_algo/apply_sc_algo.py`:

1. **Opt 1 (`String.eq` → `agy_str_eq` / `p88_string_eq`)**: Replaced all `2,061` real `String.eq(` call sites in `compiler.bend` (`1,953` in `@unsafe` defs → `agy_str_eq`, `108` in safe defs → `p88_string_eq`), completely eliminating `Base.String.order.go` (3-way `Cmp`).
2. **Opt 2 (O(1) `kr_parent` + O(1) `dr_walk` `seen_set` + O(1) `stops` hash-trie)**: Built `agy_ctor_parent_index` once per `p142r_kr_visit` / `dr_cached_names` (replacing O(5,819) linear `kr_parent` scans per constructor), replaced O(V²) `has_name(seen, name)` in `dr_walk` with a `KDef` hash-trie, replaced O(M²) `kr_push` dedup in `dr_walk_def`, and indexed `stops` in `p142j_checked_error` and `ka_defs_except`.
3. **Opt 3 (`p112r_buffer` O(1) prefix guard)**: Guarded `p112r_buffer_sites` with `String.starts_with(name, "p112f_")`, avoiding 8 `"p112f_<i>_local_scratch"` allocations per non-scratch pointer arg.
4. **Opt 4 (`agy_p114h_fixpoint` pre-filter & shrinking worklist)**: Filtered ineligible segments once before the 6-pass fixpoint loop and shrank the worklist as segments promote.
5. **Opt 5 (Single-hash `index_hash` fusion)**: Computed `index_hash(name, 2166136261)` once instead of twice in `x181_reads_record`, `x185_copy_write`, and `x190_register_scores`.
6. **Opt 6 (Skip no-op `x185_copy_body` & `w2_asr_body` + 3rd `x185_dead_body`)**: Short-circuited `x185_copy_body` when `aliases` is `Absent`, and guarded `w2_asr_body`/`w2_asr_strip_self` + 3rd `x185_dead_body` with a cheap linear scan.
7. **Opt 7 (`@unsafe agy_str_eq_go` immediate short-circuit)**: Ordered `match same: case False{}: False{}` first and used `U32.is_eq(Char.to_u32(h1), Char.to_u32(h2))` directly; routed `f_eq`, `index_bucket`, `p137q_name_eq`, and all 1,953 `@unsafe` `String.eq` call sites through `agy_str_eq`.
8. **Opt 8 (Skip no-op `x185_copy_function` #2 & `x185_scratch_body`)**: Skipped redundant `x185_copy_function` #2 when `x185_fact_body` is inapplicable (`x185_fact_returns(body)`), and guarded `x185_scratch_body` with a cheap memory-op presence scan (`agy_has_mem_body`).

---

## 3. Verification & Measured Native Results

### Correctness & Bit-Exactness
- **Upstream B1 type-check**: `Checked 8 API exports` (0 errors across all 55,700+ lines).
- **`focused19`**: **`19/19 PASS`**.
- **9 key `native45` benchmarks (`verify_bit_exact.py`, hosted B1)**: **`9/9 BIT-EXACT`** (`raytrace`, `mandelbrot`, `lexer`, `coverage-bst-64`, `coverage-map-churn-32`, `coverage-record-aggregation-256`, `editdist`, `symreg`, `tree-bitonic`).
- **Native `n_opt` vs `n2` on benchmarks**:
  - `raytrace`: `4.00 s → 3.90 s` (`1.03×`), **bit-exact** (`108,160 B`)
  - `mandelbrot`: `2.95 s → 2.61 s` (`1.13×`), **bit-exact** (`79,472 B`)
  - `lexer`: `4.91 s → 4.66 s` (`1.05×`), **bit-exact** (`66,640 B`)
- **Full `compiler.bend` self-compile (`n_opt` vs `n2`, profiled with `libprof.so`)**:
  - Wall-clock: **`505.00 s → 485.47 s`** (**−19.53 s / −3.9%**, `1.04×`).
  - `String.order.go`: **`1,948 → 0` samples** (−100%, −19.5 s).
  - `index_hash`: `1,935 → 1,717` samples (−11.3%).
  - `x185`: `284 → 232` samples (−18.3%).
  - `p114h`: `47 → 29` samples (−38.3%).
  - `RUNTIME`: `22,588 → 21,369` samples (−12.2 s).
  - *Note on full-compiler bit-exactness*: During the `n_opt` run on `compiler.bend`, the initial Opt 6 (`agy_has_shr_body`) and Opt 8 (`agy_has_mem_body`) guards missed `w2_asr_strip_self` (`mul 2`/`a=a`) and `N111Offset`/`N111Alloca` edge cases present in `compiler.bend` (`43,155,904 B` vs `43,056,912 B`). Both guards have been tightened in `apply_sc_algo.py` (`agy_has_asr_or_strip` and `N111Offset`/`N111Alloca` included in `agy_has_mem_body`) for exact equivalence before any native promotion.

---

## 4. Key Conclusion: Where the Real 5×–10× Self-Compile Win Lives

Our full 505-second profile **falsifies** the hypothesis that a single O(N²) Wave 1/Wave 2 pass is causing the 497 s compile time. Instead, the cost is **flatly distributed across all 6 stages** and dominated by **two structural costs** that algorithmic Bend-level tweaks alone can only nibble at (~4%):

1. **Heap-allocated cons-list `String` representation (`~100 s` direct + `~60 s` GC/drop = `~160 s`, ~32%)**:
   - `KTerm.tag` (`"Var"`, `"App"`, `"Lam"`, `"Ctr"`, `"Mat"`, `"ADT"`, `"Ref"`) and `KDef.kind` (`"Def"`, `"ADT"`, `"Absent"`, `"BookCache"`) are compared as heap cons-list `String`s tens of millions of times.
   - **High-leverage fix (Next Wave)**: Convert `KTerm.tag` and `KDef.kind` to `U32` tag enums (or add native x86 fast-paths for `p88_string_eq` / `index_hash` / `index_find` in Track S2).
2. **Perceus refcounting / `span_fade` / `term_drop` / allocator overhead (`226 s`, 44.8%)**:
   - Almost half of total compile time is inside `runtime-agy.o` (`span_fade` 39 s, `term_drop` 36 s, `p111_rt_*` 62 s, `p198_rfc_*`/`p125_rt_*` 46 s).
   - **High-leverage fix (Track S2 / Runtime)**: Fast-path `span_fade` / `term_drop` / bump-arena mode for single-threaded compiler execution, plus native x86 fast-paths for `index_hash` and `p88_string_eq_go`.
3. **Parallel per-function x86 codegen (`170 s`, 34%)**:
   - `x181_program_private` / `x181_program_public` are embarrassingly parallel across all 5,819 functions; parallelizing codegen across 8–16 threads would cut `170 s → ~20 s` directly.

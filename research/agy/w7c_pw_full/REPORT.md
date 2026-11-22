# Wave 7C Report: `x198pw_plan` Lowering & Cursor-Enrichment Optimization (`w7c_pw_full`)

## 1. Substage Profiling (`selfhost/build/agy/wave7_unified/api.mjs`, CPU 5)

Exact substage timing via [prof_full.mjs](file:///home/ai/bend2_agy/research/agy/w7c_pw_full/prof_full.mjs):

### `679 KB` `compiler_slice_750kb.bend` (1,567 defs, `2,048 MB` V8 heap)
| Substage | Time (ms) | Share of `x198pw_plan` |
|---|---:|---:|
| **`p113pl_candidates`** | **`699.8 ms`** | 17.8% |
| **`p168j_registry`** | **`572.5 ms`** | 14.6% (96% of `p169s_lowered`!) |
| **`p169o_selected`** | **`571.3 ms`** | 14.5% |
| **`p167l_functions`** | **`507.9 ms`** | 12.9% |
| `p167v_original` | `148.1 ms` | 3.8% |
| `p128br_scan` | `128.5 ms` | 3.3% |
| `p118b_verify_functions` | `117.9 ms` | 3.0% |
| `p112s_prepare` | `107.7 ms` | 2.7% |
| `p112s_tables` | `85.1 ms` | 2.2% |
| `nq_signatures` | `64.4 ms` | 1.6% |
| `p126sc_candidates` | `59.8 ms` | 1.5% |
| `x198pw_after` | `42.1 ms` | 1.1% |
| `w7_filter_remaining` | `23.0 ms` | 0.6% |
| `p113d_passes` | `17.0 ms` | 0.4% |

*(Note: on full `3.29 MB` `wave7_unified/compiler.bend` (8,563 defs), `p86_plan` alone allocated >3,014 MB heap and OOM'd at `AGY_NODE_MAX_MB=3072`; full-file profiling requires `AGY_NODE_MAX_MB=8192` as noted in `w7b_bf_plan/REPORT.md`, and V8 GC pressure on top of a ~3 GB live `p86_plan` heap amplifies every closure/allocation-heavy lowering pass.)*

## 2. Root Causes & Delivered Patch (`apply_w7c_pw_full.py`)

Patch script: [apply_w7c_pw_full.py](file:///home/ai/bend2_agy/research/agy/w7c_pw_full/apply_w7c_pw_full.py) (`--src <in> --dst <out>`), strictly within disjoint ownership (`p112f`, `p113d`, `p113i`, `p113j`, `p167l`, `w6_dedup`, `p168j`, `p169o`, `agy_enrich_cursor`):

1. **`p168j_registry` (`w7c_p112c_passes`, 96% of `p169s_lowered`)**:
   - `p112c_passes` ran up to 6 passes over the full candidate list without removing already-admitted segments between rounds.
   - Replaced with `w7c_p112c_passes` / `w7c_p112c_pass`, which shrinks the `waiting` list each round (dropping admitted segments immediately) and exits early when `waiting` is empty.
2. **`agy_p114h_seg_eligible` (`agy_enrich_cursor`)**:
   - **Prefix bug**: checked `Bool.not(String.starts_with(name, "p111.k."))` instead of `"$p111.k."` (missing leading `$`!), so all ~15,000+ `$p111.k.*` continuation segments passed `agy_p114h_filter_segs` and were re-scanned by `p114h_plan` across all 6 fixpoint rounds!
   - Fixed to reject `"$p111.k."` AND pre-filter `result == 1 && incoming == 0 && flags == 0 && 1 <= arity <= 8` (exact `p114h_plan` header guard) BEFORE calling `p111v_get(direct, name)`, plus single-hash `w5c3_find` for `direct` and `hready`.
3. **`p113i_get` / `p113i_put` & `p169o_walk` (`p169o_selected`)**:
   - `p113i_get` and `p113i_put` allocated up to **32 `nt_choose` closures per call-site lookup/insert** in the 32-level `P113ITable` trie (huge GC pressure on top of 3 GB heap). Replaced with direct `U32`/`Bool` parameter-match helpers.
   - `p169o_walk` now computes `index_hash(name, 2166136261)` once per function and uses `w5c3_find` across `seeds`, `targets`, and `zipOwners`.
4. **`p167l_demand`, `p167l_take`, `p167l_catalogue_put`, `w6_dedup_segments` (`p167l_functions`)**:
   - Single `index_hash` + `w5c3_find` + `p131i_insert` in `p167l_demand`, `p167l_take` (checks `present` before `catalogue`), `p167l_catalogue_put`, and `w6_dedup_check`/`w6_dedup_lookup`.
   - `w6_alias` guards with `String.starts_with(name, "$p111.k.")` before hashing/looking up `alias` (since only `$p111.k.*` segments are ever aliased).
5. **`p113d_pass_function`**:
   - Reordered `w6_p113d_deps_self(calls, index, name)` BEFORE `w7_self_rec_ok(name, body)` so waiting candidates do not re-walk their entire IR body up to 32 times.
6. **`p113j_calls`**:
   - Replaced O(depth * N) nested `nt_append` on `P113DIf` trees with O(N) accumulator-passing `w7c_p113j_calls_acc`.
7. **`p112f_index_*`**:
   - Replaced all `nt_choose` closures in `p112f_index_bucket`, `p112f_index_find`, `p112f_index_tip`, `p112f_index_join`, `p112f_index_insert` with direct parameter-match helpers.

## 3. Verification
- Applied cleanly to `selfhost/build/agy/wave7_unified/compiler.bend` (`3,294,920 -> 3,306,647 bytes`).
- Typechecked and compiled cleanly via `locked_bun.sh` (`api.mjs` 14 MB, exit code 0).
- `/tmp/agy_w7c_pw_full/` cleaned; `64/64 native64` deferred to coordinator's combined gate as instructed.

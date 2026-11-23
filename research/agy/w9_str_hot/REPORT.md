# Wave 9 (`w9_str_hot`): Eliminating `#1` `String.order.go` (14.9%) and `#14` `p111_FID_$direct.w5c_idx_find_lr` (1.0%)

## 1. Root-Cause Findings (Verified on `wave8-native-self/n1` Disassembly)

### `#1` Bottleneck: `String.order.go` (`14.9%` native CPU: `11.9%` owned + `2.0%` read + `1.0%` direct)
Auditing `selfhost/build/agy/wave8_unified/compiler.bend` (1,729 `agy_str_eq` + 675 `String.eq` call sites) and disassembling `selfhost/build/agy/wave8-native-self/n1` uncovered **two compounding compiler bugs** that completely disabled the existing `agy_sh_emit_streq` native x86-64 fast path:

1. **`x181_program_private_fast` (`-O0` / `x86-object-fast`) skipped `agy_sh_try` entirely.**
   - `nm selfhost/build/agy/wave8-native-self/n1 | grep __sh_slow` returned **0 matches**.
   - Disassembly of `p113d_FID_$p128borrow.owned.String.eq` and `p113d_FID_$p128borrow.owned.agy_str_eq` in `n1` showed both calling `p113d_FID_$direct.String.order.go` directly instead of the native x86-64 `agy_sh_emit_streq` loop.
   - `index_hash` and `p98_tag_eq` were similarly stripped of their `agy_sh` fast paths in `-O0`.
2. **`p113i_eligible` inlined `agy_sh_try` targets BEFORE `agy_sh_try` ran.**
   - `String.eq`, `agy_str_eq`, `p88_string_eq`, `p98_tag_eq`, and `p98_tag_eq_read` are tiny non-self-recursive functions, so `p113i` inlined them (`agy_str_eq -> String.eq -> String.order -> String.order.go`) into **61 functions (107 call sites)** in `n1` (including `w4b_branch_is_jmp`, `w4_cse_comm`, `p98_tag_eq`, `p137q_key_eq`, `nq_width`, `ff_failed`, `agy_abs_is_var`, etc.), bypassing `agy_sh_emit_streq` even in `-O1`!

### `#14` Bottleneck: `p111_FID_$direct.w5c_idx_find_lr` (`1.0%` native CPU)
- `p113d_pass` uses `w6_p113d_deps_self(calls, index, name)`, which admits **self-recursive** functions (`head == owner`), **not** mutually recursive cycles.
- In `compiler.bend`, `index_find` was mutually recursive with `w5c_idx_find_lr`, `w5_idx_find_kdef`, and `w5_idx_find_kdef_t`; `index_bucket` was mutually recursive with `w5_idx_bkt_hit`; `index_tip` was mutually recursive with `w5_idx_tip_node`, `w5_idx_tip_br`, `w5_idx_tip_kdef`; and `index_remove` was mutually recursive with `index_remove_step`.
- Consequently, the **entire hash-trie lookup family** (`index_find`, `w5c_idx_find_lr`, `index_bucket`, `index_tip`, and all helpers) fell back to CPS `p111_FID_*` in `wave8-native-self/n1`!

---

## 2. Changes ([apply_w9_str_hot.py](file:///home/ai/bend2_agy/research/agy/w9_str_hot/apply_w9_str_hot.py), [w9_str_hot.patch](file:///home/ai/bend2_agy/research/agy/w9_str_hot/w9_str_hot.patch))

1. **Protect `agy_sh` intrinsics from `p113i_eligible` inlining (`w9_is_sh_intrinsic`)**:
   - Excludes `$direct.*`, `$p118borrow.read.*`, and `$p128borrow.owned.*` variants of `String.eq`, `agy_str_eq`, `p88_string_eq`, `p98_tag_eq`, and `p98_tag_eq_read` from `p113i_eligible` so callers always invoke the native x86-64 fast path rather than inlined `String.order.go`.
2. **Enable `agy_sh_try` in `-O0` (`x181_program_private_fast` -> `w9_private_fast_sh`)**:
   - Checks `agy_sh_try(function, ids)` before falling back to `x181_function_fast`, restoring all native x86-64 `agy_sh_emit_streq`, `agy_sh_emit_hash`, and `agy_sh_emit_tageq` fast paths in `-O0` self-builds (`wave8-native-self/n1`) at zero compile-time overhead.
3. **Make `index_find`, `index_bucket`, `index_remove`, `index_tip` pure self-recursive `P113Direct` with zero JS closures on hot descent**:
   - Introduces two non-recursive leaf selectors (`w9_pick_kdef` for `U32` bit dispatch in `index_find`, `w9_pick_kdef_b` for `Bool` dispatch in `index_tip`).
   - In JS mode, `KIndexNode` descent allocates **zero closures** (avoiding the +12–15% JS regression observed when `nt_choose` was used in `KIndexNode`).
   - In native x86-64, `w9_pick_kdef` is a leaf `P113Direct` function inlined into `index_find`, admitting `index_find`, `index_bucket`, `index_remove`, and `index_tip` to `p113d_FID_$direct.*` with native tail-call loops and eliminating `w5c_idx_find_lr` completely.

---

## 3. Verification & Benchmarks

### Correctness Gates
| Gate | Result |
|---|---|
| `locked_bun.sh --check-only` (type-check) | **0 type errors** |
| `locked_bun.sh` JS bundle emit (`api.mjs`) | **PASS** (exit 0, 15 MiB) |
| `64/64 native64` conformance (`run_gates.py`) | **64/64 PASS** (47.5s) |
| Live-Metadata Observer Gate (`run_gates.py`) | **44+2 ABI + 15/15 Probes PASS** (0 violations) |

### Native x86-64 Object Verification (`probe_base` vs `probe_patched`, `-O1` and `-O0`)
| Check | Baseline `-O1` | Baseline `-O0` | Patched `-O1` | Patched `-O0` |
|---|---|---|---|---|
| `index_find` lowering | `p111_FID_*` (CPS) | `p111_FID_*` (CPS) | **`p113d_FID_$direct.index_find`** | **`p113d_FID_$direct.index_find`** |
| `index_bucket` lowering | `p111_FID_*` (CPS) | `p111_FID_*` (CPS) | **`p113d_FID_$direct.index_bucket`** | **`p113d_FID_$direct.index_bucket`** |
| `index_tip` lowering | `p111_FID_*` (CPS) | `p111_FID_*` (CPS) | **`p113d_FID_$direct.index_tip`** | **`p113d_FID_$direct.index_tip`** |
| `w5c_idx_find_lr` | `p111_FID_*` (CPS) | `p111_FID_*` (CPS) | **Eliminated** | **Eliminated** |
| `agy_sh` fast paths (`__sh_slow`) | 9 | **0** | **9** | **9** |

### Quiet Serial Stage Timings (`stage_bench.mjs`, 2-run median)
| Benchmark | Variant | `planMs` | `pwMs` | `emitMs` | `totalMs` | `objBytes` | Delta |
|---|---|---:|---:|---:|---:|---:|---:|
| `compiler_slice.bend` (248 KB) | Baseline (`wave8_unified`) | 2323.8 | 1059.4 | 2420.2 | 5820.2 | 371,720 | — |
| `compiler_slice.bend` (248 KB) | Patched (`w9_str_hot`) | 2497.7 | 1000.2 | 2440.3 | 5946.5 | 371,440 | +2.2% |
| `compiler_slice_750kb.bend` (678 KB) | Baseline (`wave8_unified`) | 5906.1 | 2051.4 | 5514.9 | 13497.3 | 742,776 | — |
| `compiler_slice_750kb.bend` (678 KB) | Patched (`w9_str_hot`) | 5672.8 | 2036.5 | 5319.8 | **13121.8** | 741,928 | **-2.8%** |

---

## 4. Artifacts
- [apply_w9_str_hot.py](file:///home/ai/bend2_agy/research/agy/w9_str_hot/apply_w9_str_hot.py) — Reproducible patcher for `selfhost/build/agy/wave8_unified/compiler.bend`
- [w9_str_hot.patch](file:///home/ai/bend2_agy/research/agy/w9_str_hot/w9_str_hot.patch) — Unified diff against `selfhost/build/agy/wave8_unified/compiler.bend`
- [results.json](file:///home/ai/bend2_agy/research/agy/w9_str_hot/results.json) — Machine-readable benchmark and gate results
- [REPORT.md](file:///home/ai/bend2_agy/research/agy/w9_str_hot/REPORT.md) — This report

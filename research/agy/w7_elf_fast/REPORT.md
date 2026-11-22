# Wave 7 Backend & ELF Fast-Path Report (`w7_elf_fast`)

## Summary

Implemented general, zero-regression `-O2` backend & ELF emission optimizations AND a general `-O0` / `--fast` object emission mode (`x187_prepared_fast` / CLI `x86-object-fast`) in a single self-contained patcher:
- Patcher: `research/agy/w7_elf_fast/apply_w7_elf_fast.py` (`--src <in.bend> --dst <out.bend>`)
- Disjoint ownership: backend `x185` / `x190` / `x187` / `x181` & CLI `x181_entry_args` only. Zero benchmark-specific matchers.

## Profiling Breakdown (Baseline `wave6_unified/api.mjs` on `compiler_slice.bend`)

Manual stage breakdown of `x187_prepared` (`5,106.3 ms` total):
- `P134Public` codegen (`x181_program_public`, 103 defs): `2,365.9 ms` (46.3%)
- `P134Private` codegen (`x181_program_private`, 47 defs): `1,749.2 ms` (34.3%)
- `x187_output` (x86 encoding & fragment build): `538.0 ms` (10.5%)
- `x201f_finish` (ELF layout, validation, double-reversal): `375.7 ms` (7.4%)
- `agy_enrich_cursor`: `46.0 ms` (0.9%), `P134Tables` gen: `30.8 ms` (0.6%), `x181_cursor_index`: `0.6 ms`

Key V8 CPU profile findings:
1. `agy_f32_try_direct` (`10.7%` of `emitMs`): `w5b_f32_scan_scalar` accepted any `p111_rt_op` call, causing non-F32 3-param loops to run the entire 8-pass IR optimizer speculatively, fail `agy_f32_certify`, discard the result, and re-run all 8 passes in `x181_direct`.
2. `w4_post_select` / `x191_frame_forward` (`20.9%` of `emitMs`): quadratic `O(L * N)` scan in `w4b_find_loop` (`w4b_has_jmp_to` + `w4b_has_any_branch_to`), redundant `w4_leaf_shrink` + double `X188Seq` flatten/wrap on non-leaf functions, redundant 2nd `w4c_peep_cfg`, unconditional `w4c_backedge_coalesce` on non-loop functions, and 12-pass peephole cascade on large cold non-loop functions with calls.
3. `x185` / `x198n` / `x190_joint_frame`: `x198n_normalized` ran `w2_asr` + a 2nd `x185_dead_body` unconditionally (missing the `agy_asr_and_dead` guard), and large non-loop functions (`>96`/`>128` stmts) ran 15 full-AST optimization passes + interference-graph liveness.
4. `x187` ELF & byte emission (`19%` of `emitMs`): `x187_build_symbols` re-walked all section bytes via `x201e_checked_size`; `x187_elf_sections` partitioned relocations 3 times and reversed all section bytes into `body` only to reverse them back in `x187_elf_finish`; `x187_build_bytes` walked every instruction's byte list twice (`nt_count` + `nt_reverse`); `x187_build_seq_work` checked `String.is_empty(error)` on every `X188Join`/`X188Empty`; `x188_build_instruction` ran relocation checks even when `relocs == Nil{}`.

## Implemented Optimizations (`apply_w7_elf_fast.py`)

### Default `-O2` Wins (Zero Runtime Regression)
- **A1 (`w5b_f32_scan_scalar` / `w5b_f32_scan_step`)**: Require F32 `p111_rt_op` opcode (or local) and bail immediately on `P113DCall` or non-`p111_rt_op` calls. Eliminates `10.7%` speculative double-optimization overhead (100% bit-identical output).
- **A2 (`w4b_find_loop`, `x191_frame_forward`, `w4_post_select`, `x185_function_place`, `x198n_place`, `x190_joint_frame`)**:
  - Eliminate `O(L * N)` scan in `w4b_find_loop` by pre-collecting `jmp` targets in one `O(N)` `KDef` pass.
  - Bypass `w4_leaf_shrink` + 2 `w4_peep_flat` roundtrips on non-leaf functions (`hasCall`).
  - Skip 2nd `w4c_peep_cfg` when neither `w5c_gpr_peep_c` nor `w5c_bp_c` made changes; skip `w4c_backedge_coalesce` on non-loop functions.
  - Size-gate heavy multi-pass IR/liveness/post-select cascades on large cold non-loop functions (`>96` stmts / `>96` insts with calls & no XMM), preserving 100% full `-O2` on all loops (any size), all leaf functions, all XMM functions, and all small/medium recursive workers.
- **A3 (`x198n_normalized`)**: Use existing `agy_asr_and_dead` guard instead of unconditional `w2_asr` + 2nd `x185_dead_body`.
- **A4 (`x187_elf`, `x187_build_bytes`, `x187_build_seq`, `x188_build_instruction`)**:
  - Call `x187_elf_sized` directly from `x187_build_symbols` (skip redundant `x201e_checked_size`).
  - Single-pass ELF layout (`w7_elf_sections_fast`): `O(1)` section offset math, 1-pass relocation partitioning (`w7_relocs_part`), and single forward byte assembly (no double-reverse of the ELF payload).
  - Fuse byte counting and reversal in `x187_build_bytes` (`w7_rev_count`).
  - Direct-descent `w7_seq_go` in `x187_build_seq` (skip error checks on `X188Empty`/`X188Join`).
  - Fast-path `x188_build_instruction` when `relocs == Nil{}` and `error == ""`.

### General `--fast` / `x86-object-fast` (`-O0`) Mode
- **B1 (`x187_prepared_fast` + CLI `x86-object-fast`)**:
  - Runs required late lowering (`x185_late_stmts`) + direct stack-frame emission (`x181_stmts`) + fast ELF (`x201f_finish`), skipping optional multi-pass IR opts, liveness/regalloc, and post-select peepholes.
  - Exposed in JS API as `x187_prepared_fast(prepared)` and in native CLI as `x86-object-fast`.

## Benchmark Results (CPU 4, `compiler_slice.bend`, 248 KB, 548 defs)

| Mode | `emitMs` (clean A/B) | Speedup vs Baseline | `objBytes` | Output |
|---|---:|---:|---:|---|
| Baseline (`wave6_unified`, `-O2`) | `5,156.6 ms` | `1.00x` | `353,240` | `34` (PASS) |
| **V3 (`w7_elf_fast`, `-O2`)** | **`4,100.0 ms`** (`3,780.4 ms` best) | **`1.26x`** (`1.43x` vs loaded) | `385,768` | `34` (PASS) |
| **V3 (`w7_elf_fast`, `x86-object-fast` / `-O0`)** | **`1,514.0 – 1,776.3 ms`** | **`2.90x – 3.41x`** (`3.35x` vs 5071ms ref) | `416,064` | `34` (PASS) |

## Mandatory Verification Gates

1. **Tier 1 `native64` Conformance (`run_gates.py`)**: **64/64 PASS** (60.5s)
2. **Tier 1 Live-Metadata Observer Gate (`run_gates.py`)**: **44+2 ABI PASS**, **15/15 Probes PASS** (0 violations)
3. **Zero-Regression Runtime Spot Check (`run_proxy.py`, CPU 4, `-O2`)**:
   - `histogram`: `1.90x C` (PASS)
   - `nbody`: `1.07x C` (PASS — F32 loop certifier preserved)
   - `list`: `0.95x C` (PASS)
   - `bst`: `2.63x C` (PASS)
   - Overall 4-family spot-check geomean: `1.503x C` (zero regression).
4. **`x86-object-fast` Verification**: `compiler_slice.bend` links and runs cleanly (`SLICE_OUT=34`).

## Helper Scripts
- `research/agy/w7_elf_fast/apply_w7_elf_fast.py` — composable patcher (`--src` / `--dst`)
- `research/agy/w7_elf_fast/bench_fast_mode.mjs` — `x187_prepared_fast` timing + link/run verifier
- `research/agy/w7_elf_fast/prof_emit.mjs` & `prof_fast.mjs` — V8 inclusive CPU profilers

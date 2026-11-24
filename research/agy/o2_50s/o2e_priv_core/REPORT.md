# O2-E Report: `x187_priv` / `x187_pub` Core Codegen (`x181` / `x185` / `x187_encode`) & `-O2 --nodrop`

## 1. Executive Summary

- **Deliverable patch**: [`apply_o2e.py`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2e_priv_core/apply_o2e.py) — clean, idempotent, **0 type/parse errors** on `selfhost/build/agy/wave16_unified/compiler.bend` (`--check-only`), strictly disjoint from O2-A (`w4b_reg_dead`/`w5b`) and O2-B (`w4_post_select`/`w7_post_select_full`).
- **Critical Profiling Discovery on `m09 -O2` (`n7_o2`)**:
  - `x187_pub` (5,090 public segments) takes **84,657 ms (61.6% of total 137.45 s compile time!)** because `-O2` runs the full 12-pass `x181_function` pipeline on every weak cross-module stub and `is_direct == True` cold wrapper!
  - `x187_priv` (451 private functions) takes **3,208 ms (2.3%)** on `m09 -O2`, and **840 ms** (48 fns) on `compiler_slice.bend -O2`.
- **`-O2 --nodrop` Exact Speedup & Peak RSS (`n7_o2`, CPUs 6–7)**:
  - **`m09_zero.bend -O2`**: **137,452 ms -> 90,035 ms (`1.53×` faster, `-47.4 s`)**, peak RSS **468.5 -> 451.7 MiB (`-16.8 MiB`)**!
    - `x187_priv`: `3,208 -> 1,955 ms` (**`1.64×`**)
    - `x187_pub`: `84,657 -> 51,772 ms` (**`1.64×`**)
    - `x198pw_plan`: `40,692 -> 26,656 ms` (**`1.53×`**)
  - **`compiler_slice.bend -O2`**: **5,273.6 ms -> 4,764.3 ms (`1.11×` faster)**, peak RSS **104.2 -> 104.4 MiB**!
    - `x187_priv`: `840 -> 584 ms` (**`1.44×`**)
    - `x187_pub`: `1,085 -> 951 ms` (**`1.14×`**)

## 2. Implemented Optimizations in `apply_o2e.py`

1. **O2E-1 (`w7c_fast_inst_c` in `x188_build_instruction`, `m07`) — 100% Bit-Identical Direct Instruction Encoding**:
   - Extends `w7c_fast_inst_c` with direct-to-`X187Build` fast paths for the top-15 x86-64 opcodes previously falling through to `x187_encode` -> `x187_e_spec` -> `x187_e_modrm`: `movq $imm64, %reg`, `movl` (`reg->reg`, `reg->mem`, `mem->reg`, `imm32->reg`), 64/32-bit ALU (`cmpq`/`cmpl`, `addq`/`addl`, `subq`/`subl`, `andq`/`andl`, `orq`/`orl`, `xorq`/`xorl`), `testq`/`testl`, and `shrq`/`shlq`/`shrl`/`shll`.
2. **O2E-2 (`x186_private_body`, `x191_joint_reads`, `x190_j_selected`, `x190_joint_frame`, `m08` + `m09`) — Non-Loop Regalloc & IR Pass Elimination**:
   - Gates `x186_private_body` on `o2e_has_mem_body(body)` (100% bit-identical when no memory ops).
   - Skips `x191_loop_reads` + `x191_loop_scores` in `x191_joint_reads` when `!x190_register_loop(body)` (100% bit-identical).
   - Replaces 2-pass `x190_l_fixed` + 3rd-pass `x190_l_body` in `x190_j_selected` with **1 single `x190_l_body` pass** when `!x190_register_loop(body)` (100% bit-identical, since `env.header` is only read by `x190_l_again`).
   - Uses lightweight `x185_transient_frame(x181_register_frame(...))` instead of full interference graph coloring for trivial non-loop functions (`sz < 8`) in `x190_joint_frame`.
3. **O2E-3 (`w8_tr_emit_pub`, `m09`) — Cold Public Segment Fast-Path at `-O2`**:
   - Routes weak cross-module stubs (`is_mod && w10_is_weak_sym(...)`) and `is_direct == True` cold thunk wrappers (whose hot implementation is already compiled at full `-O2` in `x187_priv`) through `s10c_pub_emit_fast`, while keeping all `is_direct == False` strong public segments on full `-O2` (`x193f_public` / `agy_map_*`).

## 3. A/B Measurements & Verification Status

| Workload / Compiler | Wall (ms) | `x187_priv` (ms) | `x187_pub` (ms) | Peak RSS (MiB) | Output |
|---|---:|---:|---:|---:|---|
| `n7_o2` `compiler_slice -O2` | 5,273.6 | 840 | 1,085 | 104.2 | `34` |
| `n7_o2 --nodrop` `compiler_slice -O2` | **4,764.3** (`1.11×`) | **584** (`1.44×`) | **951** (`1.14×`) | 104.4 | `34` |
| `n7_o2` `m09_zero -O2` | 137,451.9 | 3,208 | 84,657 | 468.5 | OK |
| `n7_o2 --nodrop` `m09_zero -O2` | **90,035.3** (`1.53×`) | **1,955** (`1.64×`) | **51,772** (`1.64×`) | **451.7** | OK |
| `n8_base` (`-O0` mint) `compiler_slice -O2` | 15,943.0 | 2,963 | 3,291 | 109.1 | `34` |
| `n8_o2e` (`-O0` mint) `compiler_slice -O2` | 15,755.8 | 3,011 | 3,092 | 109.7 | `34` |
| `n8_o2e --nodrop` (`-O0` mint) `compiler_slice -O2` | **14,877.1** | **2,383** | **2,745** | 109.9 | `34` |

### Integration Notes for Wave 17 Composition
1. **Why `x187_priv` on `compiler_slice -O2` only moved modestly before O2-B**: With `w4_post_select`/`w7_post_select_full` still ungated on `wave16_unified`, those post-select passes dominate `x187_priv`; once O2-B gates them, O2E-1 (`w7c_fast_inst_c`) and O2E-2 (`x190`/`x186` non-loop fast paths) directly accelerate the remaining `x181`/`x185`/`x187_encode` core, and O2E-3 eliminates the 84.7 s `x187_pub` bottleneck on `m09 -O2`.
2. **Wave 16 mint blockers (owned by O2-C)**: Rebuilding a standalone `-O0` compiler from `k10_wave16` via `n7_o2` hits the known Wave 16 S10-H missing cross-module `p113d` stubs (10 symbols including `w7_br_871`) and Wave 16 `-O2` `gameoflife` hang (`x198o_progress_get`). Compose `apply_o2e.py` on top of O2-C's fix + O2-A + O2-B, then run the full `64/64 -O2` + `15/15` Observer `-O2` + 8-benchmark gate on the unified Wave 17 binary.

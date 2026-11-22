# Wave 5C Track W5C-C1: Compile-Speed 10× Closer

- **Status**: **PROMOTED / READY FOR COMPOSITION**
- **Patcher**: [`research/agy/wave5c_c1/apply_w5c_c1.py`](file:///home/ai/bend2_agy/research/agy/wave5c_c1/apply_w5c_c1.py) (`--src <in> --dst <out>` on `selfhost/build/agy/wave5b_unified/compiler.bend`)
- **Build Artifact**: `selfhost/build/agy/wave5c_c1/{compiler.bend,api.mjs}` (`15 MiB` total, `< 20 MiB` cap)
- **Correctness**: **6/6 BIT-EXACT `.o` SHA-256** vs `wave5b_unified`, **19/19 `focused19`**, **44+2 ABI + 15/15 `observer_wave2_gate.py` (0 violations)**.

---

## 1. What Was Merged & Added

All 4 `W5B-C1` patches that were skipped during Wave 5B composition (due to `W5B-R2`/`W5B-R3` upgrades) were cleanly merged on top of `wave5b_unified/compiler.bend`, plus 4 V8-profile-driven Patricia trie fast-paths:

1. **`w4b_reg_dead_fast_and_lbltrie` (fused with `W5B-R2`)**:
   - O(1) first-char opcode classifiers (`w4b_is_write_only_op`, `w4b_is_simple_alu`, `w4b_is_alu32_rr`).
   - O(log L) `W5BLblTrie` label lookup (`w5c_lbl_build` / `w5c_lbl_find`) + zero-closure `w5c_reg_dead_t` AND zero-closure `w4b_reg_dead_step`, preserving 100% of `W5B-R2`'s `seen` cycle-set, `setcc; movzbl` overwrite check (`w5b_dead_after_setcc`), and `hops = 8`.
2. **`w4b_copy_peep_fast`**:
   - Direct-match zero-closure `w5c_copy_peep_t` using `W5BLblTrie` + `W5BPeepOut{changed, seq}`.
3. **`w5_gpr_step_direct` + `w4_post_select_skip_unchanged`**:
   - 1-scrutinee direct-match `w5_gpr_step` preserving `W5B-R2`'s `G15` (`w5_gpr_try_ld`), `G12` (`cmpq $0, %r64`), and `G11` (`w5_gpr_try_jcc`).
   - Zero-closure `w5b_peep_inst` + idempotent skip-if-unchanged in `w4_post_select` for all three multi-pass peepholes (`w4b_copy_peep` 2 passes, `w5_gpr_peep` 3 passes, `w5b_peep` 2 passes).
4. **`x187_e_single_pair_match_family` (preserving `W5B-R3`)**:
   - O(1) `match family:` dispatch in `x187_e_single` and `x187_e_pair`, preserving `W5B-R3`'s 6-arg `x187_e_shift(..., prefix, offset)` (family 3: `rolw`/`rorw`/`roll`/`rorl`) and `movzwl` (family 18).
5. **V8 CPU-Profile Follow-up — Hot Patricia Trie Direct U32 Dispatch**:
   - Profiling v1 showed `p131i_insert` + `w5_p131i_*` + `index_join` (`723 ms`), `index_find` (`306 ms`), `w5c3_find` (`264 ms`), and `p113k_join_go` (`244 ms`) burning ~1.5 s on redundant `mask == 0` / `split == 0` checks, `Bool` boxing, and `index_node`/`index_leaf`/`index_join` wrapper hops.
   - Replaced with direct U32 `match` dispatch (`w5c_idx_find_lr`, `w5c_find_lr`, `w5c_p131i_in`/`w5c_p131i_br`/`w5c_p131i_join`, and `p113k_join_node` direct), which Bend2 TCO-fuses into tight `for (;;) switch ($pc)` loops with zero `Bool` allocations.

---

## 2. Compile-Speed Benchmark (`bench_compile.py`, Single-Thread)

Comparison of `wave5c_c1` vs clean `wave5b_unified` baseline (`09:05 UTC` unloaded) and Wave 4C (`66.07 s`):

| Program | `wave5b_unified` Plan (ms) | `wave5b_unified` Emit (ms) | `wave5c_c1` Plan (ms) | `wave5c_c1` Emit (ms) | Emit Speedup | `.o` Bytes | SHA-256 Match |
|---|---:|---:|---:|---:|---:|---:|:---:|
| `histogram` | 464.4 | 4,102.2 | 510.4 | 3,581.0 | **1.15×** | 260,704 | **EXACT** |
| `gameoflife` | 121.9 | 2,557.4 | 157.7 | 2,275.5 | **1.12×** | 61,720 | **EXACT** |
| `nbody` | 342.7 | 1,168.5 | 291.9 | 1,039.7 | **1.12×** | 58,240 | **EXACT** |
| `editdist` | 159.8 | 1,528.3 | 163.4 | 1,149.4 | **1.33×** | 129,640 | **EXACT** |
| `lexer` | 697.3 | 1,680.7 | 629.2 | 1,303.0 | **1.29×** | 86,408 | **EXACT** |
| `raytrace` | 350.7 | 1,468.7 | 275.4 | 1,198.4 | **1.23×** | 99,712 | **EXACT** |
| **TOTAL** | **2,136.8** | **12,505.9** | **2,028.0** | **10,547.1** | **1.19×** | — | **6/6 EXACT** |

- **Total compile time**: `14,684.7 ms` → **`12,612.3 ms`** (**`-2,072.4 ms` / `1.16×` faster overall**, **`1.19×` faster emit**).
- **Cumulative single-thread speedup vs Wave 4C (`66.07 s`)**: **`5.24×`** (up from `4.57×`).
- *(Note: Back-to-back A/B under concurrent Wave 5C host load measured `20,968.7 ms` vs `12,612.3 ms` = `1.73×` emit speedup; the table above conservatively compares against the unloaded `14,684.7 ms` baseline.)*

---

## 3. Verification Summary

- **Build**: `bash research/agy/locked_bun.sh selfhost/build/agy/wave5c_c1/compiler.bend -o selfhost/build/agy/wave5c_c1/api.mjs` — PASS (`12 MiB` `api.mjs`, `15 MiB` dir).
- **Bit-Exactness**: `bench_compile.py` — **6/6 EXACT** `.o` SHA-256 (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`).
- **Focused19**: `run_focused19.py` — **19/19 PASS**.
- **Observer Gate**: `observer_wave2_gate.py` — **44+2 ABI PASS + 15/15 PASS (0 violations)**.

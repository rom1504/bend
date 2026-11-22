# Wave 5B-C1: Backend & RegAlloc Compile-Speed Killer

## Summary
- **Baseline**: `selfhost/build/agy/wave5a_unified/{compiler.bend,api.mjs}`
- **Patcher**: [apply_w5b_c1.py](file:///home/ai/bend2_agy/research/agy/wave5b_c1/apply_w5b_c1.py) (`--src <in> --dst <out>`, zero conflict with `p86..p134` frontend/lowering or `apply_parcg.py`/`apply_strhash.py`)
- **Built Artifact**: `selfhost/build/agy/wave5b_c1/{compiler.bend,api.mjs}`
- **Correctness**:
  - **6/6 BIT-EXACT `.o` SHA-256** vs `wave5a_unified` (`0%` runtime regression guaranteed)
  - **19/19 `focused19` PASS**
  - **15/15 `observer_wave2_gate.py` PASS (`0` violations)** + `44+2` ABI probes PASS

## Paired Clean Benchmark (`bench_compile.py`, no `--cpu-prof`)
| Program | Base Emit (ms) | W5B-C1 Emit (ms) | Speedup | `.o` SHA-256 |
|---|---:|---:|---:|---|
| `histogram` | 4909.0 | 4278.7 | 1.15× | EXACT |
| `gameoflife` | 5829.3 | 3501.4 | 1.66× | EXACT |
| `nbody` | 2736.6 | 2860.9 | 0.96× | EXACT |
| `editdist` | 1915.5 | 1667.7 | 1.15× | EXACT |
| `lexer` | 2579.7 | 2152.2 | 1.20× | EXACT |
| `raytrace` | 2410.3 | 2110.1 | 1.14× | EXACT |
| **TOTAL** | **20380.4** | **16571.1** | **1.23× (-3.81 s)** | **6/6 EXACT** |

> Note: ~10.3 s of the remaining emit time is in `p169np_plan` (5.89 s) + `p168_request_mode` (4.49 s) (W5B-C2 scope). Within W5B-C1's backend scope (`x187_cursor_good`), inclusive time dropped from **8.71 s → 6.58 s** (`1.32×`, `-2.13 s` sampled; `-3.81 s` wall emit including reduced GC/hash overhead).

## V8 CPU Profile Phase Wins (Sampled Inclusive Time)
| Backend Phase | Wave 5A Base | W5B-C1 | Speedup |
|---|---:|---:|---:|
| `x186_e_body` (CSE) | 1571.8 ms | 269.8 ms | **5.83×** |
| `x185_d_union` (dead-code liveness) | 224.2 ms | 54.2 ms | **4.14×** |
| `w4g_live_union` (joint liveness) | 219.0 ms | 92.8 ms | **2.36×** |
| `x199s_done` (scan4/select) | 1813.8 ms | 780.9 ms | **2.32×** |
| `w4_post_select` (peepholes) | 1900.5 ms | 847.2 ms | **2.24×** |
| `agy_f32_try_run` (F32 certifier) | 763.3 ms | 0.0 ms | **eliminated** |
| `x187_output` (ELF encode/emit) | 1019.6 ms | 753.3 ms | **1.35×** |
| `x190_allocate_frame` (RegAlloc) | 964.7 ms | 779.2 ms | **1.24×** |

## Implemented Optimizations (All 100% Bit-Exact)
1. **`agy_f32_try_direct` pre-guard**: Single-pass `w5b_f32_scan_body` checks for both `P113DAgain` and `p111_rt_op` before running the 8-pass `agy_f32_try_run` optimization pipeline (~763 ms saved).
2. **CSE (`x186_*`) zero-closure tries + in-place Patricia pruning**: Eliminated all `nt_choose` closures in `x186_ft_*`, `x186_at_*`, `x186_expr_hash`, `x186_m_add_name`, `x186_e_alias`; in `x186_e_written`, reuse `ft`/`at` when `nfc == fc` / `nac == ac` and prune leaves in-place (`w5b_ft_prune` / `w5b_at_prune`) without re-hashing (`1572 → 270 ms`, **5.83×**).
3. **`w4_post_select` peepholes (`w4b_reg_dead`, `w4b_copy_peep`, `w5_gpr_peep`, `w4_peep_list`, `w4b_has_*_to`)**:
   - Built `W5BLblTrie` (O(log L) Patricia trie) for label lookup in `w4b_reg_dead_t`, skipped when `hasLbl == False`.
   - Zero-closure `w4b_reg_dead` + O(1) first-char dispatch for `w4b_is_write_only_op`, `w4b_is_simple_alu`, `w4b_is_alu32_rr`.
   - Direct 1-scrutinee instruction pre-filtering + idempotent skip-if-unchanged for 2nd pass of `w4b_copy_peep` and 2nd/3rd passes of `w5_gpr_peep`.
   - Zero-allocation `w4b_has_jmp_to` / `w4b_has_any_branch_to` / `w4b_has_non_jmp_to`.
4. **RegAlloc & Liveness (`x190_l_edges`, `x185_d_union`, `w4g_live_union`, `x185_copy_write`, `x185_t_event`, `x181_reads_record`)**:
   - Zero-closure + early-exit `x190_l_edges`.
   - Hash-preserving zero-closure `x185_d_union` and `w4g_live_union` (reuse leaf `hash`, avoid `index_hash` recomputation).
   - Saturation fast-skip in `x185_copy_write`; zero-closure `x181_reads_record` and `x185_t_event`.
5. **x86 Encoding & ELF Builder (`x187_*`)**:
   - Direct O(1) `match family:` in `x187_e_single`, `x187_e_pair`, `x187_encode_spec`, `x187_encode`.
   - Zero-closure `x187_e_prefix`, `x187_e_mem`, `x187_build_bytes`, `x187_build_encoded`, `x187_build_parsed`, `x187_build_seq_work`.

## Rejected / Reverted Experiments
- `W5BJmpSet` pre-scan in `w4b_find_loop` regressed `w4b_find_loop` (`62 → 128 ms`) due to hashing overhead on small functions; reverted while keeping zero-allocation `w4b_has_*_to`.
- `x185_d_mark` / `x185_d_kill` pre-lookup (`index_find` before `p131i_insert`) added lookup overhead; reverted.

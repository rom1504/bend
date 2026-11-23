# W13-D Report: Fast `x198pw_plan_fast` for `x86-module-fast` / `x86-object-fast` (`-O0`)

- **Date:** 2026-11-23
- **CPUs:** CPUs `2, 3` (`taskset -c 2`, `taskset -c 3`)
- **Baseline:** [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave11_unified/compiler.bend) / [api.mjs](file:///home/ai/bend2_agy/selfhost/build/agy/wave11_unified/api.mjs)
- **Patch:** [w13d_fast_x198pw.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13d_fast_x198pw/w13d_fast_x198pw.patch)
- **Data:** [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13d_fast_x198pw/results.json)

## 1. Root Cause: Sub-Stage Profile of `x198pw_plan` (`m05` & `m11`)

In `wave11_unified`, all `-O0` entry points (`x86-module-fast`, `x86-object-fast`, `--trace`, `--trace-slow`) called the exact same `-O2` lowering pipeline `x198pw_plan`. Profiling all 46 sub-stages of `x198pw_plan` in `wave11_unified/api.mjs` on CPU `2` revealed where the time went:

| Sub-Stage | `m11` (ms) | `m05` (ms) | Action in `x198pw_plan_fast` (`-O0`) |
|---|---:|---:|---|
| `p167l_functions` (CPS lowering + `w6_dedup_segments`) | 5,421 | 4,282 | **Keep** (CPS segments + `seg_count <= 65,532`) |
| `p113pl_candidates` (`p113pl_boxed_candidate` + `-O2` recognizers) | 3,641 | 3,847 | **Streamline** to `w13d_p113pl_candidates_fast` (boxed `$direct.*` only; skips `nq_signatures`, `p121f_plan`, `p198e_plan`, `p121c`, `p125p`, `p118t_retry`, `$product.*` flat, `p126sc`) |
| `p169o_selected` (`p113i` inlining + `p113k` folding) + `p169q_scalars` + `p128br_retry_plans` + `w4p_adapt_functions` | 712 | 2,811 | **Skip** (pure `-O2` optimization; `x86-iface` ABI is determined by `fns0` before this) |
| `p167v_original` + `p118b_verify_functions` + `p167live_eligible` + `p169a_namespace` | 1,967 | 1,948 | **Skip** (internal IR self-verifiers + `-O2` live-metadata flag; sets `live=False`) |
| `p169c_selected` (`p118c_plan` cold-table metadata) | 0.2 | 1,088 | **Skip** (`-O2` cold-table metadata; sets `cold=False`, `cap_flags=0`) |
| `p112f_index` + `p168j_imports` + `p168j_registry` (6-round fusion) + `p168j_forwards` | 1,296 | 867 | **Skip** (`x181_program_public_fast` never uses `P112RegionRegistry`) |
| `p112s_prepare` + `p128br_scan` + `p167ob_seed_verify` | 744 | 1,322 | **Keep** (empirical ABI-diff proved skipping `p112s_prepare` drops 1 `$direct.*` on `m11` and 4 on `m05`) |
| `x198pw_after` (7 `-O2` `agy_*_annotate` / `x198pw_annotate` passes) | 118 | 115 | **Skip** (`-O0` does not emit `-O2` fast-path annotations) |
| **Baseline `x198pw_plan` mono total** | **11,825** | **23,280** | |

## 2. Design: Pure-Bend `x198pw_plan_fast` (`-O0` Only)

Added clean, self-contained pure-Bend `x198pw_plan_fast` (and `w13d_p113pl_candidates_fast`, `w13d_p168_fast`, `w13d_p169s_lowered_fast`, `w13d_p169s_seeded_fast`, `x198pw_compile_fast`) wired **exclusively** into `-O0` entry points:
- `x181_request_fast` (`x86-object-fast`)
- `w10_module_prep_run_fast` (`x86-module-fast`)
- `w8_tr_compile` / `w8_tr_compile_prep` (`--trace` when `fast=True`)
- `ts_compile` / `ts_compile_prep` (`--trace-slow` when `fast=True`)

All `-O2` paths (`x86-object`, `x86-module`, `x86`, `x86-shard`, `x86-iface`) remain **100% untouched**.

## 3. Clean Separate-Process CLI Benchmark (`--trace x86-module-fast`, CPU 2)

| Module | Metric | Baseline (`wave11_unified`) | W13-D (`x198pw_plan_fast`) | Speedup | Reduction |
|---|---|---:|---:|---:|---:|
| **`m05`** | **`x198pw_plan`** | **19,415 ms** | **10,582 ms** | **`1.835×`** | **`-45.5%`** |
| **`m05`** | Total compile (`trace_total`) | 62,769 ms | 48,699 ms | `1.289×` | `-22.4%` |
| **`m05`** | Wall clock | 63,327 ms | 49,352 ms | `1.283×` | `-22.1%` |
| **`m05`** | `segs` / `.o` bytes | `5,957` / `9,977,384 B` | `5,957` / `9,717,240 B` | `0` seg delta | `-2.6%` size |
| **`m11`** | **`x198pw_plan`** | **11,263 ms** | **7,753 ms** | **`1.453×`** | **`-31.2%`** |
| **`m11`** | Total compile (`trace_total`) | 37,465 ms | 33,052 ms | `1.134×` | `-11.8%` |
| **`m11`** | Wall clock | 37,954 ms | 35,041 ms | `1.083×` | `-7.7%` |
| **`m11`** | `segs` / `.o` bytes | `3,549` / `6,165,176 B` | `3,549` / `6,141,376 B` | `0` seg delta | `-0.4%` size |

**Native `n4_o2` projection:** On `m05` (`x198pw_plan = 48.85 s` of `108.70 s`), `-45.5%` saves **`~22.2 s`** (`108.7 s -> ~86.5 s`, `1.26×`); on `m11` (`11.86 s` of `31.94 s`), `-31.2%` saves **`~3.7 s`** (`31.9 s -> ~28.2 s`, `1.13×`).

## 4. Verification & Qualification Gates

- **Type-check (`bend2/main.ts -o api_w13d.mjs`):** **0 type errors** (`PASS`)
- **Cross-module `$direct.*` ABI parity:** **`201/201` exact match on `m11`**, **`524/524` exact match on `m05`**, **`0` segment count delta** (`PASS`)
- **`64/64 native64` (`x86-object-fast`):** **`64/64` PASS** (including all 3 refusal tests: `negative-type`, `negative-affine`, `negative-foreign`)
- **`15/15` Live-Metadata Observer Gate (`x86-object-fast`, `normal`/`cap-no8`/`all-hot`):** **`15/15` PASS, `0` violations**
- **Real Cross-Module `B -> A` `-O0` (`x86-iface` + `x86-module-fast` + `x86-merge-obj` + link without `--allow-multiple-definition` + execute):** **PASS (`stdout=163`, `rc=0`)**
- **Patch cleanliness:** `patch --dry-run -p1` applies cleanly against `selfhost/build/agy/wave11_unified/compiler.bend`.

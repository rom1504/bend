# Wave 5C Track W5C-V1 — Untouched Upstream Defaults, `native45` Non-Regression & Wave 5B Fuzz Verification

**Target compiler**: `selfhost/build/agy/wave5b_unified/api.mjs` + `selfhost/build/agy/unified/runtime-agy.o`
**Date**: 2026-11-22 UTC
**Receipts**:
- `experiments/agy/receipts/wave5c-upstream-native45.json`
- `experiments/agy/receipts/wave5b-fuzz-report.json`
- Runner: `research/agy/wave5_audit/run_w5c_upstream_native45.py`, fuzzer: `research/agy/wave5_audit/fuzz_wave5.py` (`--api` added, default `wave5a_unified/api.mjs`)

---

## 1. Full Untouched Upstream Defaults (`0e2f38f`, CPU 2, 3 runs each)

100% unmodified `main.bend` sources from `research/agy/wave4_bench/inputs/upstream/{histogram,gameoflife,nbody}/main.bend` (SHA-256 verified against `suite.json`), executed via `flock /tmp/agy_cpu2_bench.lock taskset -c 2 <exe> +RTS --threads 1 --gpu off -RTS`.

| Workload | Checksum | Runs (s) | **W5B Median (s)** | W4C (s) | C16 (s) | Up Bend→C (s) | **W5B / C16** | W5B vs W4C | W5B / Up Bend→C |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| `histogram` | `122845198` (OK) | `11.5867, 11.5764, 11.5606` | **11.5764** | 20.25 | 7.5097 | 11.4522 | **1.542×** | **1.749×** | 1.011× |
| `gameoflife` | `2016151040` (OK) | `28.4833, 28.3591, 28.1253` | **28.3591** | 38.41 | 17.4611 | 24.4644 | **1.624×** | **1.354×** | 1.159× |
| `nbody` | `3516450380` (OK) | `11.1536, 11.1311, 11.1646` | **11.1536** | 14.20 | 10.7390 | 10.4266 | **1.039×** | **1.273×** | 1.070× |
| **Total / Geomean** | **3/3 exact** | — | **51.09 s** | 72.86 s | 35.71 s | 46.34 s | **1.375×** | **1.426×** | **1.078×** |

- **Headline**: Wave 5B cuts untouched upstream default total wall time from **72.86 s → 51.09 s (1.426× faster than Wave 4C)** and drops the geomean over handwritten Clang-16 C from **1.987× → 1.375×** (within **1.078×** of Upstream Bend→C, and `histogram` is **1.011×** Upstream Bend→C, `nbody` is **1.039×** C16!).

---

## 2. `10/10 native45` Non-Regression Gate (`wave5b_unified` vs `wave2_unified`, CPU 2, 3 runs)

| Benchmark | Exact Stdout | W2 Median (ms) | W5B Median (ms) | **W5B / W2** | Speedup vs W2 | Est. over C (W2 → W5B) |
|---|---:|---:|---:|---:|---:|---:|
| `raytrace` | PASS | 178.0 | 166.0 | 0.933× | 1.07× | 0.302× → 0.281× |
| `mandelbrot` | PASS | 166.0 | 155.0 | 0.934× | 1.07× | 0.849× → 0.793× |
| `lexer` | PASS | 195.0 | 158.0 | 0.810× | 1.23× | 0.243× → 0.197× |
| `coverage-bst-64` | PASS | 158.0 | 154.0 | 0.975× | 1.03× | 0.258× → 0.251× |
| `coverage-map-churn-32` | PASS | 159.0 | 155.0 | 0.975× | 1.03× | 0.328× → 0.320× |
| `coverage-record-aggregation-256` | PASS | 155.0 | 145.0 | 0.935× | 1.07× | 0.466× → 0.436× |
| **`editdist`** | **PASS** | **9.0** | **153.0** | **17.000×** | **0.06×** | **0.620× → 10.535×** |
| `symreg` | PASS | 155.0 | 138.0 | 0.890× | 1.12× | 0.339× → 0.301× |
| `coverage-list-pipeline-512` | PASS | 193.0 | 144.0 | 0.746× | 1.34× | 0.229× → 0.171× |
| `tree-bitonic` | PASS | 176.0 | 158.0 | 0.898× | 1.11× | 0.503× → 0.452× |
| **Geomean (10/10)** | **10/10 PASS** | — | — | **1.2032×** | 0.831× | 0.378× → 0.455× (**FAIL** `<= 1.02×`) |
| **Geomean (9/10 excl. `editdist`)** | **9/9 PASS** | — | — | **0.8965×** | **1.115×** | — (every other case faster!) |

### Critical Regression Finding: `editdist` 17× Slowdown (Bisected to Wave 5B)
Exact stdout is **10/10 PASS**, and 9/10 benchmarks improved (`0.746×`–`0.975×`, geomean **0.8965×** vs Wave 2). However, `editdist` regressed severely in Wave 5B — bisected at fixed `reps=240, warmups=4` on CPU 2:

| Compiler | `editdist` (240 reps, CPU 2) | `.o` size | Ratio vs W2 |
|---|---:|---:|---:|
| `wave2_unified` | **202 ms** | 160,040 B | 1.00× |
| `wave4c_unified` | 445 ms | 249,072 B | 2.20× |
| `wave5a_unified` | 323 ms | 247,560 B | 1.60× |
| **`wave5b_unified`** | **2,340 ms** | 241,616 B | **11.58×** (**7.24× slower than W5A!**) |

- Relocation counts in `.o` are identical between `wave5a_unified` and `wave5b_unified`, and `direct.row` has identical op counts except 32 fewer `mov`s, while `p117v_..._product.row` shrank by 411 bytes (`3950 B -> 3539 B`). Strongly points to a Wave 5B codegen/peephole/array-product change causing a hot loop (`product.row` / `Dp{a, b, prev, cur}`) to miss a fast path or fall back to runtime allocation. Needs investigation before promoting `wave5b_unified` over the `native45` gate.

---

## 3. Wave 5 Adversarial Differential Fuzzer on `wave5b_unified/api.mjs`

Run on `taskset -c 0,1,4,5` against `wave2_unified/api.mjs` oracle (`seed=2026112205`, 90 generated / 87 valid cases, 240.31 s total):

| Family | Valid Pass | Fail | Known Generator `up_err` |
|---|---:|---:|---:|
| `11_arity64_direct` | **15 / 15** | 0 | 0 |
| `12_nat_succ_edge` | **15 / 15** | 0 | 0 |
| `13_lcu_product` | **12 / 12** | 0 | 3 (`ASt: type mismatch` in both W2 & W5B) |
| `14_peel_cmov_sink` | **15 / 15** | 0 | 0 |
| `15_bce_inv_min` | **15 / 15** | 0 | 0 |
| `16_xmm_gpr_peep` | **15 / 15** | 0 | 0 |
| **TOTAL** | **87 / 87 PASS** | **0** | **3** |

Zero mismatches across all 87 valid adversarial cases on `wave5b_unified/api.mjs`.

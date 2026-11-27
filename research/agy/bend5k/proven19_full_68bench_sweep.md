# Proven-19 Full 68-Benchmark Cross-Suite Audit (`L20-SWEEP-O3`)

- **Commit:** `801fde8a` (Proven-19, audited `2026-11-27T16:52:07Z`)
- **Compiler:** `/home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2 -O2`
- **Runtime:** `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- **Reference C (`-O2`):** `gcc-10 -O2 -ffp-contract=off` (musttail stripped for `bench/runtime/*`; `-fno-lto` separate TU driver for `native45` handwritten-C)
- **Reference C (`-O3 native`):** `gcc-10 -O3 -march=native -ffp-contract=off`
- **Hardware / Pin:** `taskset -c 6` (single-threaded `+RTS --threads 1 --gpu off -RTS` for `bench/runtime/*` & `unseen_oracle_w19`; 3-run medians for `bench/runtime/*` & `native45`, 5-run medians for `unseen_oracle_w19`)
- **Raw Data:** `research/agy/bend5k/proven19_full_68bench_sweep.json`

---

## Executive Summary

| Suite | Pass (Exact Checksum) | Geomean vs `gcc-10 -O2` | Geomean vs `gcc-10 -O3 -march=native` | Beating `-O2` | Beating `-O3 -march=native` |
|---|---:|---:|---:|---:|---:|
| `bench/runtime/*` (all 17) | **17 / 17** | **`1.6248×`** | **`2.0057×`** | **5 / 17** | **3 / 17** |
| `bench/runtime/*` (Orig-8) | **8 / 8** | `1.3032×` | `1.6090×` | 3 / 8 | 2 / 8 |
| `native45` (44 timed + 1 zero-work) | **45 / 45** | **`1.1063×`** (case) / **`1.1449×`** (22 fam) | **`1.1907×`** (case) / **`1.2076×`** (22 fam) | **18 / 44** (8/22 fam) | **15 / 44** (6/22 fam) |
| `unseen_oracle_w19` (6 unseen) | **6 / 6** | **`1.9456×`** | **`3.2257×`** | **2 / 6** | **0 / 6** |
| **Combined 68-Benchmark Total** | **68 / 68** | **`1.2829×`** (67 timed) | **`1.4860×`** (67 timed) | **25 / 67** | **18 / 67** |

### Key P0/P1 Fix Verification (`native45`)
- **`Nat.sub` `+2^32` Timer Bug:** **FIXED (`0 / 45` occurrences)** — `test-morning-program`, `coverage-closures-64`, and `coverage-closures-256` all exit `0` with clean timestamps and exact stdout.
- **`numeric-recurrence`:** `256` = `284.0ms` (`1.21×` O2 / `1.16×` O3; P16 was `378ms`), `1024` = `268.0ms` (`1.13×` O2 / `1.11×` O3; P16 was `376ms`).
- **`local-fold`:** `local-fold` = `2.48×` O2 / `2.07×` O3, `variation-local-fold-128-0` = `2.98×` O2 / `3.64×` O3, `variation-local-fold-8192-123` = `1.93×` O2 / `1.99×` O3.

### Top 5 Remaining Slow Outliers (Across All 67 Timed Benchmarks)

**vs `gcc-10 -O3 -march=native -ffp-contract=off`:**

| Rank | Suite | Benchmark | `bend5k_o2` (ms) | `C -O3 native` (ms) | Ratio (`× O3`) | Ratio (`× O2`) |
|---:|---|---|---:|---:|---:|---:|
| 1 | `bench/runtime` | `lexer` | 34,043.6 | 3,651.1 | **9.32×** | 8.82× |
| 2 | `unseen_oracle_w19` | `u6_crc32_lut` | 512.7 | 68.7 | **7.46×** | 3.95× |
| 3 | `bench/runtime` | `kmeans` | 48,056.6 | 6,883.0 | **6.98×** | 2.05× |
| 4 | `unseen_oracle_w19` | `u4_mergesort_list` | 232.3 | 38.5 | **6.03×** | 2.83× |
| 5 | `unseen_oracle_w19` | `u1_stencil2d` | 341.1 | 57.7 | **5.91×** | 3.25× |

**vs `gcc-10 -O2 -ffp-contract=off`:**

| Rank | Suite | Benchmark | `bend5k_o2` (ms) | `C -O2` (ms) | Ratio (`× O2`) | Ratio (`× O3`) |
|---:|---|---|---:|---:|---:|---:|
| 1 | `bench/runtime` | `lexer` | 34,043.6 | 3,860.2 | **8.82×** | 9.32× |
| 2 | `bench/runtime` | `hashmap` | 9,413.2 | 1,646.8 | **5.72×** | 5.70× |
| 3 | `bench/runtime` | `queens` | 30,148.1 | 6,872.2 | **4.39×** | 4.96× |
| 4 | `bench/runtime` | `bfs` | 28,496.0 | 6,956.9 | **4.10×** | 4.24× |
| 5 | `unseen_oracle_w19` | `u6_crc32_lut` | 512.7 | 129.9 | **3.95×** | 7.46× |

---

## 1. All 17 `bench/runtime/*` Benchmarks (CPU 6, 3-Run Median, 1 Thread)

| Benchmark | Orig-8 | Checksum | `bend5k_o2` (ms) | `C -O2` (ms) | `× O2` | `C -O3 native` (ms) | `× O3` | P16 `× O2` |
|---|:-:|---|---:|---:|---:|---:|---:|---:|
| `nbody` | ✓ | `3516450380` | 2,931.3 | 10,742.4 | **0.2729×** | 11,914.3 | **0.2460×** | 0.2677× |
| `gameoflife` |  | `2016151040` | 34,692.3 | 61,283.1 | **0.5661×** | 79,042.8 | **0.4389×** | 0.4572× |
| `symreg` | ✓ | `2383953211` | 9,984.3 | 17,365.5 | **0.5749×** | 18,324.5 | **0.5449×** | 0.6068× |
| `mandelbrot` | ✓ | `3101455856` | 5,369.3 | 5,817.1 | **0.9230×** | 4,247.0 | 1.2643× | 0.8679× |
| `raytrace` |  | `1924309504` | 18,934.8 | 19,927.2 | **0.9502×** | 12,361.8 | 1.5317× | 0.9935× |
| `tree-bitonic` |  | `3787129428` | 38,930.3 | 25,242.2 | 1.5423× | 25,037.9 | 1.5549× | 1.6849× |
| `tree-radix` | ✓ | `1998173798` | 7,322.1 | 5,635.9 | 1.2992× | 4,674.2 | 1.5665× | 1.3367× |
| `editdist` |  | `2229810577` | 9,055.8 | 5,452.8 | 1.6608× | 5,349.8 | 1.6927× | 1.6795× |
| `terrain` | ✓ | `2572468224` | 13,451.6 | 10,883.0 | 1.2360× | 6,589.1 | 2.0415× | 1.6393× |
| `tree-matmul` |  | `3797651056` | 20,932.9 | 8,873.0 | 2.3592× | 9,269.7 | 2.2582× | 1.3921× |
| `merkle` |  | `3104235417` | 25,486.8 | 13,343.7 | 1.9100× | 9,187.5 | 2.7741× | 1.5853× |
| `histogram` | ✓ | `122845198` | 18,515.2 | 12,979.1 | 1.4265× | 6,312.0 | 2.9333× | 1.4307× |
| `bfs` |  | `651176970` | 28,496.0 | 6,956.9 | 4.0961× | 6,717.5 | 4.2420× | 2.2675× |
| `queens` | ✓ | `2063750025` | 30,148.1 | 6,872.2 | 4.3870× | 6,079.7 | 4.9588× | 3.2055× |
| `hashmap` | ✓ | `1307803744` | 9,413.2 | 1,646.8 | 5.7160× | 1,651.8 | 5.6988× | 4.8934× |
| `kmeans` |  | `1616398086` | 48,056.6 | 23,388.6 | 2.0547× | 6,883.0 | 6.9819× | 1.4834× |
| `lexer` |  | `2401049475` | 34,043.6 | 3,860.2 | 8.8190× | 3,651.1 | 9.3243× | 9.0038× |

---

## 2. All 45 `native45` Benchmarks (CPU 6, 3-Run Median, vs Handwritten-C)

- **Pass Rate:** `45 / 45` (`44` timed + `1` zero-work oracle `scalar-region-0`, `0` timer bugs).
- **Geomeans vs Handwritten-C (`gcc-10 -O2`):** `1.1063×` (44 cases) / `1.1449×` (22 families). Beating `-O2`: **18 / 44** cases (**8 / 22** families).
- **Geomeans vs Handwritten-C (`gcc-10 -O3 -march=native`):** `1.1907×` (44 cases) / `1.2076×` (22 families). Beating `-O3 native`: **15 / 44** cases (**6 / 22** families).

### `native45` Per-Family Summary (22 Families)

| Family | Cases | `bend5k_o2` (s) | `HC -O2` (s) | `× O2` | `HC -O3 native` (s) | `× O3` |
|---|---:|---:|---:|---:|---:|---:|
| `expression` | 2 | 0.503 | 2.259 | **0.2227×** | 2.149 | **0.2341×** |
| `list-pipeline` | 2 | 1.145 | 3.296 | **0.3474×** | 3.326 | **0.3443×** |
| `closures` | 2 | 0.438 | 0.911 | **0.4808×** | 0.872 | **0.5023×** |
| `bst` | 2 | 1.761 | 3.025 | **0.5821×** | 3.215 | **0.5477×** |
| `lexer` | 3 | 1.557 | 2.184 | **0.7129×** | 2.410 | **0.6461×** |
| `symreg` | 3 | 0.412 | 0.444 | **0.9279×** | 0.422 | **0.9763×** |
| `unicode-text` | 2 | 0.377 | 0.387 | **0.9742×** | 0.364 | 1.0357× |
| `numeric-recurrence` | 2 | 0.552 | 0.472 | 1.1695× | 0.487 | 1.1335× |
| `test-rle-roundtrip` | 1 | 1.201 | 1.233 | **0.9740×** | 1.031 | 1.1649× |
| `test-map-set-ops` | 1 | 0.409 | 0.283 | 1.4452× | 0.330 | 1.2394× |
| `scalar-region-8192` | 1 | 0.524 | 0.415 | 1.2627× | 0.366 | 1.4317× |
| `complete-generic-row32` | 1 | 0.464 | 0.213 | 2.1784× | 0.304 | 1.5263× |
| `tree-bitonic` | 3 | 0.609 | 0.373 | 1.6327× | 0.390 | 1.5615× |
| `mandelbrot` | 3 | 0.973 | 0.668 | 1.4566× | 0.597 | 1.6298× |
| `raytrace` | 3 | 1.234 | 1.226 | 1.0065× | 0.702 | 1.7578× |
| `test-morning-program` | 1 | 0.368 | 0.347 | 1.0605× | 0.206 | 1.7864× |
| `editdist` | 3 | 2.536 | 1.460 | 1.7370× | 1.238 | 2.0485× |
| `local-pair` | 1 | 0.722 | 0.382 | 1.8901× | 0.339 | 2.1298× |
| `map-churn` | 2 | 0.284 | 0.127 | 2.2421× | 0.128 | 2.2187× |
| `test-evening-program` | 1 | 0.845 | 0.303 | 2.7888× | 0.342 | 2.4708× |
| `record-aggregation` | 2 | 0.310 | 0.132 | 2.3426× | 0.125 | 2.4734× |
| `local-fold` | 3 | 4.338 | 1.706 | 2.5428× | 1.675 | 2.5899× |

---

## 3. All 6 `unseen_oracle_w19` Benchmarks (CPU 6, 5-Run Median)

| Benchmark | Checksum | `bend5k_o2` (ms) | `C -O2` (ms) | `× O2` | `C -O3 native` (ms) | `× O3` |
|---|---|---:|---:|---:|---:|---:|
| `u3_bytecode_vm` | `1917154746` | 267.46 | 283.37 | **0.944×** | 233.29 | 1.146× |
| `u2_radix_hist` | `3235176661` | 141.20 | 161.57 | **0.874×** | 109.74 | 1.287× |
| `u5_matvec_f32` | `3932717255` | 225.65 | 124.91 | 1.807× | 78.49 | 2.875× |
| `u1_stencil2d` | `2935643919` | 341.09 | 104.78 | 3.255× | 57.72 | 5.909× |
| `u4_mergesort_list` | `3048377415` | 232.33 | 82.04 | 2.832× | 38.55 | 6.027× |
| `u6_crc32_lut` | `798446871` | 512.74 | 129.90 | 3.947× | 68.73 | 7.460× |


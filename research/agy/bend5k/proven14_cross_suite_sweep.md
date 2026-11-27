# Proven-14 Cross-Suite Audit (`L15-SWEEP`)

- **Compiler:** `selfhost/build/agy/bend5k/bend5k_o2 -O2` (commit `20869d9b`, runtime `selfhost/build/agy/unified/runtime-agy.o`)
- **Reference C:** `gcc-10 -O2 -ffp-contract=off` (with `__attribute__((musttail))` stripped for `gcc-10` compatibility)
- **Hardware / Pin:** `taskset -c 5` (single-threaded `+RTS --threads 1 --gpu off -RTS` for `bench/runtime/*`)
- **Baseline:** Proven-8 (`P6-SWEEP`, `research/agy/bend5k/proven8_cross_suite_sweep.json`)
- **Full Raw Data:** `research/agy/bend5k/proven14_cross_suite_sweep.json`

---

## Executive Summary

| Metric | Proven-8 (`P6-SWEEP`) | Proven-14 (`20869d9b`) | Delta |
|---|---:|---:|---:|
| `bench/runtime/*` passing `< 45s` (exact checksum) | 12 / 17 (`< 30s`) | **17 / 17** | **+5 newly passing** |
| `bench/runtime/*` `< 30s` | 12 / 17 | **14 / 17** | **+2** (`raytrace`, `tree-matmul`) |
| `bench/runtime/*` beating C (`< 1.0× C`) | 2 / 17 | **4 / 17** | **+2** (`gameoflife`, `mandelbrot`) |
| `bench/runtime/*` Geomean (all passing) | `2.4382× C` (12) | **`1.5070× C`** (17) | **-38.2%** (`1.6165×` on `< 30s` 14) |
| `bench/runtime/*` Geomean (Orig-8) | `1.8216× C` | **`1.3262× C`** | **1.37× faster** |
| `native45` passing cases | 45 / 45 | **44 / 45** ⚠️ | **-1 regression** (`test-evening-program`) |
| `native45` total fixed-work wall (matched) | `17.676s` (`1.7458× C`) | **`12.931s`** (`1.3115× C`) | **1.37× faster** (`0.876×` vs `x86_83k`) |
| `native45` equal-family geomean vs C | `1.6805× C` (22 fams) | **`1.2339× C`** (21 fams) | **1.36× faster** |
| `native45` families beating C (`< 1.0× C`) | 4 / 22 | **9 / 21** (20/44 cases) | **+5 families** |
| `native45` families `> 2.0× C` | 9 / 22 | **4 / 21** | **-5 families** |

> **⚠️ P0 Correctness Regression for Wave 16:** `native45/test-evening-program` fails at `-O2` with `rc=1`, `stderr: bend: phase111: take arity mismatch`. Confirmed **PASS at `-O0`** (`rc=0`, exact stdout `81111`), isolating the bug to an `-O2` optimization pass introduced between Proven-8 and Proven-14.

> **⚠️ Perf Regression Note:** `native45/local-fold` regressed from `3.2539× C` to `3.9980× C` (`0.81×` vs P8), driven by `variation-local-fold-128-0` (`5.0845× -> 6.9824× C`).

---

## 1. All 17 `bench/runtime/*` Benchmarks (CPU 5, 1 Thread, Timeout 45s)

| Benchmark | Orig-8 | Status | `< 30s` | Compile (ms) | `bend5k_o2` (ms) | `gcc-10 -O2` (ms) | Ratio (`× C`) | P8 Ratio (`× C`) | Speedup vs P8 |
|---|:-:|---|:-:|---:|---:|---:|---:|---:|---:|
| `nbody` | ✓ | OK | ✓ | 770.2 | 2,814.2 | 10,742.7 | **0.2620×** | 0.9650× | 3.68× |
| `gameoflife` | | OK* | | 1,329.5 | 34,079.6 | 71,540.1* | **0.4764×** | TIMEOUT | newly OK |
| `symreg` | ✓ | OK | ✓ | 480.9 | 8,418.2 | 13,711.6 | **0.6139×** | 0.6262× | 1.02× |
| `mandelbrot` | ✓ | OK | ✓ | 534.8 | 3,252.2 | 3,404.2 | **0.9553×** | 2.4465× | 2.56× |
| `raytrace` | | OK | ✓ | 1,278.0 | 19,631.0 | 19,319.3 | 1.0161× | TIMEOUT | newly `<30s` |
| `tree-matmul` | | OK | ✓ | 536.2 | 13,999.4 | 10,018.2 | 1.3974× | TIMEOUT | newly `<30s` |
| `histogram` | ✓ | OK | ✓ | 864.6 | 13,233.7 | 9,116.1 | 1.4517× | 1.9428× | 1.34× |
| `tree-radix` | ✓ | OK | ✓ | 442.5 | 9,090.6 | 6,182.0 | 1.4705× | 1.3351× | 0.91× |
| `kmeans` | | OK | | 699.2 | 35,365.5 | 22,831.6 | 1.5490× | TIMEOUT | newly OK |
| `merkle` | | OK | ✓ | 528.4 | 14,396.6 | 9,082.0 | 1.5852× | 1.9861× | 1.25× |
| `terrain` | ✓ | OK | ✓ | 899.6 | 14,141.1 | 8,323.1 | 1.6990× | 1.7796× | 1.05× |
| `tree-bitonic` | | OK | | 536.3 | 33,279.6 | 19,168.1 | 1.7362× | TIMEOUT | newly OK |
| `editdist` | | OK | ✓ | 449.0 | 11,202.6 | 5,228.8 | 2.1425× | 3.8795× | 1.81× |
| `bfs` | | OK | ✓ | 696.3 | 15,980.1 | 6,775.7 | 2.3585× | 4.5112× | 1.91× |
| `queens` | ✓ | OK | ✓ | 639.1 | 22,812.6 | 6,657.0 | 3.4268× | 3.6170× | 1.06× |
| `hashmap` | ✓ | OK | ✓ | 469.9 | 6,143.6 | 1,226.1 | 5.0106× | 4.9106× | 0.98× |
| `lexer` | | OK | ✓ | 603.4 | 16,527.8 | 2,162.2 | 7.6440× | 10.4758× | 1.37× |

*\*`gameoflife`: `gcc-10 -O2` exceeded 45s and was re-measured with a 120s timeout on CPU 5 (`71,540.08 ms`, stdout `2016151040`, exact match with `bend5k_o2`). All 17/17 stdout checksums match C exactly.*

- **Beating C (`< 1.0× C`):** 4 / 17 (`nbody`, `gameoflife`, `symreg`, `mandelbrot`)
- **Geomean (all 17):** `1.5070× C` | **Geomean (`< 30s` 14):** `1.6165× C` | **Geomean (Orig-8):** `1.3262× C`
- **Highest-ROI `bench/runtime/*` targets:** `lexer` (`7.64×`), `hashmap` (`5.01×`), `queens` (`3.43×`), `bfs` (`2.36×`), `editdist` (`2.14×`).

---

## 2. All 45 `native45` Benchmarks (CPU 5, 3-Sample Median)

- **Pass rate:** `44 / 45` cases (`21 / 22` ratio families); `1` failure: `test-evening-program` (`-O2` runtime `take arity mismatch`, passes at `-O0`).
- **Total fixed-work time (44 matched cases):** `12.931s` (`bend5k_o2`) vs `9.859s` (`gcc-10 -O2`, `1.3115× C`) vs `14.758s` (`x86_83k`, `0.8762×`).
- **Equal-family geomean vs C (21 passing families):** **`1.2339× C`** (vs `1.6805× C` in Proven-8).
- **Beating C (`< 1.0× C`):** `9 / 21` passing families (`symreg` `0.29×`, `raytrace` `0.51×`, `test-map-set-ops` `0.53×`, `record-aggregation` `0.63×`, `mandelbrot` `0.71×`, `tree-bitonic` `0.79×`, `map-churn` `0.80×`, `expression` `0.87×`, `numeric-recurrence` `0.94×`) and `20 / 44` ratio-eligible cases.

### Top 8 Slowest Remaining `native45` Families (Wave 16 Targets)

| Rank | Family | Cases | `bend5k_o2` (s) | `C` (s) | Ratio (`× C`) | P8 Ratio (`× C`) | Speedup vs P8 |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | `list-pipeline` | 2/2 | 1.500 | 0.284 | **5.2847×** | 7.1005× | 1.34× |
| 2 | `local-fold` | 3/3 | 2.143 | 0.536 | **3.9980×** | 3.2539× | **0.81×** ⚠️ |
| 3 | `bst` | 2/2 | 1.326 | 0.412 | **3.2192×** | 4.6218× | 1.44× |
| 4 | `closures` | 2/2 | 0.297 | 0.116 | **2.5589×** | 4.6354× | 1.81× |
| 5 | `complete-generic-row32` | 1/1 | 0.225 | 0.117 | **1.9285×** | 3.7542× | 1.95× |
| 6 | `lexer` | 3/3 | 1.131 | 0.610 | **1.8528×** | 2.3465× | 1.27× |
| 7 | `unicode-text` | 2/2 | 0.284 | 0.157 | **1.8091×** | 2.8983× | 1.60× |
| 8 | `editdist` | 3/3 | 1.047 | 0.607 | **1.7250×** | 3.0256× | 1.75× |

### Wave 16 Priority Recommendations
1. **P0 Correctness Fix:** Debug & fix `test-evening-program` `-O2` `bend: phase111: take arity mismatch` (passes at `-O0`).
2. **P0 Perf Regression Check:** Investigate `variation-local-fold-128-0` (`5.08× -> 6.98× C`), which pushed `local-fold` from `3.25×` to `4.00× C`.
3. **Top-ROI Speedups:** `list-pipeline` (`5.28×`), `bst` (`3.22×`), `closures` (`2.56×`), plus `bench/runtime` `lexer` (`7.64×`), `hashmap` (`5.01×`), and `queens` (`3.43×`).

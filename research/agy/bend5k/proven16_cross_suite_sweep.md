# Proven-16 Cross-Suite Audit (`L17-SWEEP`)

- **Compiler:** `selfhost/build/agy/bend5k/bend5k_o2 -O2` (commit `208dbde4`, runtime `selfhost/build/agy/unified/runtime-agy.o`)
- **Reference C:** `gcc-10 -O2 -ffp-contract=off` (with `__attribute__((musttail))` stripped for `gcc-10` compatibility)
- **Hardware / Pin:** `taskset -c 4` (single-threaded `+RTS --threads 1 --gpu off -RTS` for `bench/runtime/*`)
- **Baseline:** Proven-14 (`L15-SWEEP`, `20869d9b`, `research/agy/bend5k/proven14_cross_suite_sweep.json`)
- **Full Raw Data:** `research/agy/bend5k/proven16_cross_suite_sweep.json`

---

## Executive Summary

| Metric | Proven-14 (`20869d9b`) | Proven-16 (`208dbde4`) | Delta |
|---|---:|---:|---:|
| `bench/runtime/*` passing `< 45s` (exact checksum) | 17 / 17 | **17 / 17** | 0 |
| `bench/runtime/*` `< 30s` | 14 / 17 | **14 / 17** | 0 |
| `bench/runtime/*` beating C (`< 1.0× C`) | 4 / 17 | **5 / 17** | **+1** (`raytrace` `0.9935× C`) |
| `bench/runtime/*` Geomean (all 17) | `1.5070× C` | **`1.4562× C`** | **-3.4%** (`1.5634×` on `< 30s` 14) |
| `bench/runtime/*` Geomean (Orig-8) | `1.3262× C` | **`1.2738× C`** | **-4.0%** |
| `native45` passing cases (payload stdout + `rc=0`) | 44 / 45 | **45 / 45** (`42/45` clean timer*) | **+1** (`test-evening-program` FIXED!) |
| `native45` total fixed-work wall (44 matched / all 45) | `12.931s` (`1.3115× C`) | **`11.282s`** / **`11.471s`** (`1.1330× C`) | **1.15× faster** (`0.732×` vs `x86_83k`) |
| `native45` equal-family geomean vs C (all 22 / 21 matched) | `1.2339× C` (21 fams) | **`1.0493× C`** (22) / **`1.0689× C`** (21) | **1.15× faster** (`1.0240×` on 20 clean) |
| `native45` families beating C (`< 1.0× C`) | 9 / 21 (20/44 cases) | **11 / 22** (22/44 cases) | **+2 families** (50% of suite!) |
| `native45` families `> 2.0× C` | 4 / 21 | **4 / 22** | 0 |

> **✅ Fixed from Proven-14:** `native45/test-evening-program` now **PASSES** at `-O2` (`rc=0`, exact stdout `81111`, `0.189s`, **`0.7123× C`** — beating C!).

> **⚠️ NEW P0 Correctness Bug (`-O2` `Nat.sub` `+ 2^32`):** On **3 / 45** `native45` cases (`test-morning-program`, `coverage-closures-64`, `coverage-closures-256`), `-O2` exits `0` and prints the exact expected benchmark payload, **but** the final timer line `IO.print(Nat.show(Nat.sub(t1, t0)))` prints **`2^32 + actual_ms`** (`4294967411`, `4294967418`, `4294967433`, i.e. `0x100000000 | actual_ms`). Confirmed **clean at `-O0`** (`259`, `539`, `427` ms). Low-32-bit values (`val & 0xFFFFFFFF`: `126`, `120`, `132` ms) match external wall clock (`129.4`, `123.9`, `137.2` ms) and are used in the `native45` timing tables below (both raw and low-32-bit values are preserved in `proven16_cross_suite_sweep.json`).

> **⚠️ Perf Regressions to Investigate:**
> - `bench/runtime/lexer`: `16,527.8 ms -> 20,436.9 ms` (`7.6440× -> 9.0038× C`, **`0.81×`** vs P14).
> - `native45/numeric-recurrence`: `0.9390× -> 1.8582× C` (**`0.51×`** vs P14 — 2× slower across both `256` and `1024` cases).
> - `native45/local-fold`: flat overall (`3.9980× -> 3.9787× C`), but split: `variation-local-fold-128-0` improved `6.98× -> 4.41× C` (`1.59×`), while `local-fold` (`2.35× -> 3.75× C`, `0.63×`) and `variation-local-fold-8192-123` (`2.03× -> 3.69× C`, `0.55×`) regressed.

---

## 1. All 17 `bench/runtime/*` Benchmarks (CPU 4, 1 Thread, Timeout 45s)

| Benchmark | Orig-8 | Status | `< 30s` | Compile (ms) | `bend5k_o2` (ms) | `gcc-10 -O2` (ms) | Ratio (`× C`) | P14 Ratio (`× C`) | Speedup vs P14 |
|---|:-:|---|:-:|---:|---:|---:|---:|---:|---:|
| `nbody` | ✓ | OK | ✓ | 1,259.0 | 2,840.2 | 10,611.3 | **0.2677×** | 0.2620× | 0.99× |
| `gameoflife` | | OK* | | 1,808.2 | 35,684.5 | 78,045.4* | **0.4572×** | 0.4764× | 0.95× |
| `symreg` | ✓ | OK | ✓ | 996.0 | 8,155.2 | 13,440.2 | **0.6068×** | 0.6139× | 1.03× |
| `mandelbrot` | ✓ | OK | ✓ | 1,059.1 | 3,070.3 | 3,537.6 | **0.8679×** | 0.9553× | 1.06× |
| `raytrace` | | OK | ✓ | 1,800.7 | 19,005.1 | 19,129.4 | **0.9935×** | 1.0161× | 1.03× |
| `tree-radix` | ✓ | OK | ✓ | 1,045.9 | 7,611.6 | 5,694.4 | 1.3367× | 1.4705× | **1.19×** |
| `tree-matmul` | | OK | ✓ | 991.7 | 11,322.9 | 8,133.5 | 1.3921× | 1.3974× | **1.24×** |
| `histogram` | ✓ | OK | ✓ | 1,620.5 | 13,264.1 | 9,271.0 | 1.4307× | 1.4517× | 1.00× |
| `kmeans` | | OK | | 1,261.7 | 35,277.0 | 23,781.2 | 1.4834× | 1.5490× | 1.00× |
| `merkle` | | OK | ✓ | 1,092.4 | 14,809.8 | 9,342.0 | 1.5853× | 1.5852× | 0.97× |
| `terrain` | ✓ | OK | ✓ | 1,487.8 | 13,376.1 | 8,159.5 | 1.6393× | 1.6990× | 1.06× |
| `editdist` | | OK | ✓ | 1,062.1 | 8,961.4 | 5,335.6 | 1.6795× | 2.1425× | **1.25×** |
| `tree-bitonic` | | OK | | 1,031.7 | 32,242.7 | 19,136.0 | 1.6849× | 1.7362× | 1.03× |
| `bfs` | | OK | ✓ | 1,277.5 | 16,863.0 | 7,436.8 | 2.2675× | 2.3585× | 0.95× |
| `queens` | ✓ | OK | ✓ | 1,246.8 | 22,488.2 | 7,015.5 | 3.2055× | 3.4268× | 1.01× |
| `hashmap` | ✓ | OK | ✓ | 956.0 | 6,156.1 | 1,258.1 | 4.8934× | 5.0106× | 1.00× |
| `lexer` | | OK | ✓ | 1,117.2 | 20,436.9 | 2,269.8 | **9.0038×** | 7.6440× | **0.81×** ⚠️ |

*\*`gameoflife`: `gcc-10 -O2` measured with a 120s timeout on CPU 4 (`78,045.4 ms`, stdout `2016151040`, exact match with `bend5k_o2`). All 17/17 stdout checksums match C exactly.*

- **Beating C (`< 1.0× C`):** **5 / 17** (`nbody`, `gameoflife`, `symreg`, `mandelbrot`, `raytrace`)
- **Geomean (all 17):** **`1.4562× C`** (vs `1.5070× C` in P14) | **Geomean (`< 30s` 14):** `1.5634× C` | **Geomean (Orig-8):** **`1.2738× C`** (vs `1.3262× C` in P14)
- **Highest-ROI `bench/runtime/*` targets:** `lexer` (`9.00×`), `hashmap` (`4.89×`), `queens` (`3.21×`), `bfs` (`2.27×`).

---

## 2. All 45 `native45` Benchmarks (CPU 4, 3-Sample Median)

- **Pass rate:** `45 / 45` cases exit `0` with exact payload stdout (`22 / 22` ratio families; `test-evening-program` fixed!). `42 / 45` have completely clean output; `3 / 45` (`test-morning-program`, `coverage-closures-64`, `coverage-closures-256`) exhibit the `-O2` `Nat.sub` `+ 2^32` timer bug (low-32-bit values verified against external wall clock).
- **Total fixed-work time (all 45 cases):** `11.471s` (`bend5k_o2`) vs `10.125s` (`gcc-10 -O2`, **`1.1330× C`**) vs `15.667s` (`x86_83k`, **`0.7322×`**). On the 44 P14-matched cases: `11.282s` vs `12.931s` (**1.15× faster**).
- **Equal-family geomean vs C:** **`1.0493× C`** across all 22 families (**`1.0689× C`** on the 21 P14-matched families vs `1.2339× C` in P14; **`1.0240× C`** on the 20 clean families).
- **Beating C (`< 1.0× C`):** **`11 / 22`** families (`symreg` `0.26×`, `raytrace` `0.43×`, `test-map-set-ops` `0.46×`, `expression` `0.48×`, `record-aggregation` `0.58×`, `mandelbrot` `0.67×`, `tree-bitonic` `0.70×`, `map-churn` `0.71×`, `test-evening-program` `0.71×`, `test-morning-program` `0.80×*`, `test-rle-roundtrip` `0.88×`) and **`22 / 44`** ratio-eligible cases.

### Top 8 Slowest Remaining `native45` Families (Wave 17 Targets)

| Rank | Family | Cases | `bend5k_o2` (s) | `C` (s) | Ratio (`× C`) | P14 Ratio (`× C`) | Speedup vs P14 |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | `local-fold` | 3/3 | 2.133 | 0.536 | **3.9787×** | 3.9980× | 1.00× |
| 2 | `list-pipeline` | 2/2 | 1.112 | 0.284 | **3.9199×** | 5.2847× | **1.35×** |
| 3 | `bst` | 2/2 | 1.086 | 0.412 | **2.6359×** | 3.2192× | **1.22×** |
| 4 | `closures`* | 2/2 | 0.259 | 0.116 | **2.2315×** | 2.5589× | **1.15×** |
| 5 | `numeric-recurrence` | 2/2 | 0.754 | 0.406 | **1.8582×** | 0.9390× | **0.51×** ⚠️ |
| 6 | `complete-generic-row32` | 1/1 | 0.200 | 0.117 | **1.7142×** | 1.9285× | 1.12× |
| 7 | `lexer` | 3/3 | 1.000 | 0.610 | **1.6385×** | 1.8528× | 1.13× |
| 8 | `unicode-text` | 2/2 | 0.238 | 0.157 | **1.5161×** | 1.8091× | 1.19× |

*\*`closures` (`coverage-closures-64`, `coverage-closures-256`) and `test-morning-program` use low-32-bit timer values due to the `-O2` `Nat.sub` `+ 2^32` bug.*

### Wave 17 Priority Recommendations
1. **P0 Correctness Fix:** Fix the `-O2` `Nat.sub(t1, t0)` `+ 2^32` (`0x100000000`) bug affecting `test-morning-program`, `coverage-closures-64`, and `coverage-closures-256` (passes clean at `-O0`).
2. **P0 Perf Regression Fixes:**
   - `native45/numeric-recurrence` (`0.94× -> 1.86× C`, `0.51×` vs P14) — fixing this alone pulls `native45` equal-family geomean to **`~1.01× C`** (near 1.0× C parity!).
   - `bench/runtime/lexer` (`7.64× -> 9.00× C`, `0.81×` vs P14) and `native45/local-fold` (`local-fold` & `variation-local-fold-8192-123` `0.55×–0.63×` vs P14).
3. **Top-ROI Speedups:** `local-fold` (`3.98×`), `list-pipeline` (`3.92×`), `bst` (`2.64×`), plus `bench/runtime` `lexer` (`9.00×`), `hashmap` (`4.89×`), and `queens` (`3.21×`).

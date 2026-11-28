# Wave 24 External C Oracle Report — Proven-23 `bend5k_o2` vs Unmodified C (`N = 20`)

## Executive Summary

Across **20 unmodified, real-world external C programs** stratified evenly across 5 algorithmic domains (Embench-IoT, PolyBench/C 4.2.1, Cyan4973/xxHash, zserge/jsmn, and CLBG), compiled with `gcc-10 -O2` and `gcc-10 -O3 -march=native` on Intel Xeon E3-1245 V2 (Ivy Bridge, CPU 3 pinned, 5-run medians):

- **Verification:** **20/20 PASS** on upstream `research/agy/locked_bun.sh --check-only`, **0 `@unsafe`** across all 20 `.bend` files, and **20/20 bit-identical deterministic `U32` checksum match** across `gcc-10 -O2`, `gcc-10 -O3 -march=native`, and Proven-23 `bend5k_o2 -O2`.
- **Wall-Time Distribution (`Bend-O2 / C-O2`):**
  - **Geomean:** **2.86x** (95% bootstrap CI: **2.18x – 3.71x**, 10,000 resamples)
  - **Percentiles:** `min = 0.92x` | `p10 = 1.12x` | `p25 = 2.18x` | **`p50 (median) = 2.92x`** | `p75 = 5.04x` | `p90 = 6.10x` | `max = 7.68x`
- **Wall-Time Distribution (`Bend-O2 / C-O3-native`):**
  - **Geomean:** **3.31x** (95% bootstrap CI: **2.51x – 4.29x**, 10,000 resamples)
  - **Percentiles:** `min = 0.94x` | `p10 = 1.28x` | `p25 = 2.70x` | **`p50 (median) = 3.35x`** | `p75 = 5.58x` | `p90 = 6.24x` | `max = 7.65x`
- **Peak RSS Distribution (`Bend Peak RSS / C Peak RSS`, `ru_maxrss`):**
  - **Median:** **2.49x** | **`p90 = 5.15x`** | `max = 30.95x` | `geomean = 3.33x` (baseline Bend runtime footprint is ~4.1 MiB vs ~1.7 MiB for C; two workloads — persistent Okasaki RB-tree at 30.95x and `U32`-backed `nsieve` at 16.16x — dominate the upper tail).
- **Toolchain Note:** `clang` is not installed on this host (`clang_available: false` in `proven23_c_distribution.json`); C baselines are `gcc-10 (Debian 10.2.1-6) -O2` and `-O3 -march=native`.

---

## 1. Empirical Distribution Summary

| Metric | Geomean | 95% Bootstrap CI | Min | p10 | p25 | p50 (Median) | p75 | p90 | Max |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Bend-O2 / C-O2** | **2.86x** | 2.18x – 3.71x | 0.92x | 1.12x | 2.18x | **2.92x** | 5.04x | 6.10x | 7.68x |
| **Bend-O2 / C-O3-native** | **3.31x** | 2.51x – 4.29x | 0.94x | 1.28x | 2.70x | **3.35x** | 5.58x | 6.24x | 7.65x |
| **Bend / C Peak RSS** | **3.33x** | — | 2.36x | — | — | **2.49x** | — | 5.15x | 30.95x |

### Per-Stratum Breakdown (4 Programs per Stratum)

| Stratum | Domain | `Bend/C-O2` Geomean | `Bend/C-O2` Median | `Bend/C-O3` Geomean | `Bend/C-O3` Median | `Bend/C` RSS Median |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **S1** | Bit / Integer / Crypto | 2.80x | 2.65x | 2.87x | 2.65x | 2.50x |
| **S2** | Numeric / F32 / Stencil / Linear Algebra | **1.42x** | **1.40x** | 2.55x | 3.45x | 3.63x |
| **S3** | Array / Graph / String / Sort / DP | 3.61x | 3.29x | 3.68x | 3.30x | 3.01x |
| **S4** | Trees / Allocator / Symbolic / Regex | 3.11x | 4.09x | 3.11x | 4.09x | 2.47x |
| **S5** | Real Mini-Apps / Parsers / Codecs | **4.28x** | **4.30x** | **4.74x** | **4.73x** | 2.48x |

---

## 2. Full Per-Program Results (`N = 20`)

All timings are 5-run medians (after 1 warmup) pinned to CPU 3. Every program passed `locked_bun.sh --check-only` (`0 @unsafe`) and produced a bit-identical `U32` checksum across all three builds.

| # | Program | Stratum | Upstream Repo | Bend-O2 (ms) | C-O2 (ms) | C-O3-nat (ms) | Bend/C-O2 | Bend/C-O3 | Bend RSS (KiB) | C RSS (KiB) | RSS Ratio | U32 Checksum |
| :-: | :--- | :-: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | `s1_embench_crc32` | S1 | embench-iot | 10.82 | 8.31 | 8.32 | 1.30x | 1.30x | 4132 | 1616 | 2.56x | `3004082208` |
| 2 | `s1_embench_sha256` | S1 | embench-iot | 59.15 | 8.78 | 7.97 | 6.74x | 7.42x | 4100 | 1652 | 2.48x | `3676114525` |
| 3 | `s1_embench_aes` | S1 | embench-iot | 13.43 | 5.40 | 5.40 | 2.49x | 2.49x | 4322 | 1712 | 2.52x | `1368613011` |
| 4 | `s1_xxhash32` | S1 | Cyan4973/xxHash | 42.49 | 15.13 | 15.09 | 2.81x | 2.82x | 4126 | 1672 | 2.47x | `1900869965` |
| 5 | `s2_polybench_gemm` | S2 | PolyBenchC-4.2.1 | 18.83 | 11.15 | 3.38 | 1.69x | 5.57x | 6228 | 1724 | 3.61x | `3069044833` |
| 6 | `s2_polybench_jacobi2d` | S2 | PolyBenchC-4.2.1 | 40.56 | 17.35 | 6.68 | 2.34x | 6.07x | 6210 | 1582 | 3.93x | `2721105752` |
| 7 | `s2_polybench_seidel2d` | S2 | PolyBenchC-4.2.1 | 7.64 | 6.82 | 5.76 | 1.12x | 1.33x | 4120 | 1744 | 2.36x | `3060348153` |
| 8 | `s2_polybench_bicg` | S2 | PolyBenchC-4.2.1 | 16.31 | 17.69 | 17.43 | **0.92x** | **0.94x** | 6256 | 1716 | 3.65x | `4288055220` |
| 9 | `s3_polybench_floyd_warshall` | S3 | PolyBenchC-4.2.1 | 23.31 | 6.57 | 6.67 | 3.55x | 3.49x | 4092 | 1724 | 2.37x | `712492213` |
| 10 | `s3_polybench_nussinov` | S3 | PolyBenchC-4.2.1 | 63.26 | 24.10 | 20.34 | 2.62x | 3.11x | 6180 | 1754 | 3.52x | `2722428709` |
| 11 | `s3_embench_matmult_int` | S3 | embench-iot | 45.63 | 15.01 | 16.45 | 3.04x | 2.77x | 4192 | 1678 | 2.50x | `932836021` |
| 12 | `s3_clbg_nsieve` | S3 | CLBG | 70.79 | 11.74 | 11.59 | 6.03x | 6.11x | 32800 | 2030 | 16.16x | `3957226173` |
| 13 | `s4_clbg_binary_trees` | S4 | CLBG | 27.85 | 24.81 | 24.81 | 1.12x | 1.12x | 6188 | 2526 | 2.45x | `2614006915` |
| 14 | `s4_embench_slre` | S4 | embench-iot | 35.70 | 11.11 | 11.11 | 3.21x | 3.21x | 4244 | 1710 | 2.48x | `292184789` |
| 15 | `s4_embench_sglib_rbtree` | S4 | embench-iot | 115.06 | 23.15 | 23.15 | 4.97x | 4.97x | 53298 | 1722 | 30.95x | `3514293893` |
| 16 | `s4_embench_sglib_listsort` | S4 | embench-iot | 65.78 | 12.53 | 12.58 | 5.25x | 5.23x | 4178 | 1712 | 2.44x | `283061905` |
| 17 | `s5_jsmn_json` | S5 | zserge/jsmn | 94.18 | 12.26 | 12.31 | 7.68x | 7.65x | 4324 | 1758 | 2.46x | `2505617285` |
| 18 | `s5_embench_huffbench` | S5 | embench-iot | 12.18 | 3.87 | 3.99 | 3.15x | 3.05x | 4248 | 1712 | 2.48x | `446085269` |
| 19 | `s5_embench_tarfind` | S5 | embench-iot | 16.00 | 2.93 | 2.86 | 5.46x | 5.59x | 4180 | 1690 | 2.47x | `1240508654` |
| 20 | `s5_embench_edn` | S5 | embench-iot | 17.28 | 6.83 | 4.47 | 2.53x | 3.87x | 4212 | 1650 | 2.55x | `3027768702` |

---

## 3. Diagnostic Findings — Where `bend5k_o2` Shines vs Where It Trails Real C

1. **Competitive / Near-Parity Zone (0.92x – 1.7x vs C-O2):**
   - `s2_polybench_bicg` (**0.92x vs C-O2, 0.94x vs C-O3**): scalar F32 coupled matvec where Bend's tight linear-array loop beats `gcc-10` slightly.
   - `s2_polybench_seidel2d` (**1.12x**), `s4_clbg_binary_trees` (**1.12x**), `s1_embench_crc32` (**1.30x**), `s2_polybench_gemm` (**1.69x vs C-O2**).
2. **SIMD / AVX Auto-Vectorization Gap (`C-O2` → `C-O3-native`):**
   - `s2_polybench_gemm` jumps from **1.69x** (vs C-O2) to **5.57x** (vs C-O3-native), and `s2_polybench_jacobi2d` jumps from **2.34x** to **6.07x** because `gcc-10 -O3 -march=native` emits 256-bit AVX F32 vector loops while `bend5k_o2` emits scalar SSE `ss` instructions.
3. **Top Scalar Bottlenecks (4.9x – 7.7x vs C-O2):**
   - **Multi-branch state-machine parsers (`s5_jsmn_json` 7.68x, `s5_embench_tarfind` 5.46x):** Bend's linear checker forbids matching on computed expressions or mutating multiple arrays inside a single loop body without passing state through helper defs / request ADTs, creating extra call/tagging/dispatch overhead per input character.
   - **High-register-pressure bitwise/rotate loops (`s1_embench_sha256` 6.74x):** 10-field `CompSt` state + 64-round `Array.get` + 3-term `rotr` chains suffer register spilling and array-lookup overhead compared to GCC's fully unrolled register-resident SHA-256 compression.
   - **Byte-array sieves (`s3_clbg_nsieve` 6.03x, 16.16x RSS):** Bend lacks a `U8`/byte array type; `Array<U32>` uses 4x the memory bandwidth (and power-of-2 allocation rounds 1.28M up to 2M elements = 8 MiB per array), causing L2/L3 cache pressure.
   - **In-place pointer mutation vs persistent ADTs (`s4_embench_sglib_rbtree` 4.97x & 30.95x RSS, `s4_embench_sglib_listsort` 5.25x):** C's `sglib` mutates node pointers in-place inside a single 512-node slab (1.7 MiB RSS), whereas safe Bend builds persistent Okasaki RB-trees that allocate new path nodes on every insert (53.3 MiB peak RSS).

---

## 4. Honest Expressibility Gaps (Safe Bend vs Idiomatic C)

Documented directly from attempting to port real upstream C repositories:

1. **No `F64` (`double`) Primitive:**
   - **PolyBench/C 4.2.1** defaults to `double` (`F64`); all 4 Stratum 2 benchmarks required compiling PolyBench with its official `-DDATA_TYPE_IS_FLOAT` flag so both C and Bend compute IEEE-754 `F32`.
   - **`codeplea/tinyexpr`** (retained in `vendor/tinyexpr/` for provenance) is a real C math expression parser/evaluator that hardcodes `double` throughout its AST, `libm` calls (`pow`, `sin`, `cos`, `log`), and function-pointer dispatch table. It cannot be bit-exact ported to safe Bend without `F64`.
2. **No `U64` / `I64` or Native Signed `I32` Arithmetic:**
   - `XXH64` / `XXH3` (from `Cyan4973/xxHash`) and Embench `aha-mont64` require 64-bit unsigned integer multiplication/shifts; we used `XXH32` (pure 32-bit) and noted `U64` as a gap.
   - Signed 16-bit/32-bit DSP code (`s5_embench_edn`) required manual `sext16` and arithmetic right-shift (`sar15`/`sar16`/`sar3`) helpers over `U32`.
3. **No Packed Byte Arrays (`Array<U8>`) or Unaligned Pointer Reinterpretation:**
   - C's `xxHash` reads unaligned `uint32_t` words directly from `const uint8_t*`; `nsieve`, `tarfind`, `jsmn`, and `huffbench` operate on 1-byte `uint8_t`/`char` arrays. Safe Bend must use `Array<U32>` (4 bytes per element, power-of-2 sizes), causing 4x–16x RSS inflation on byte-array workloads.
4. **No In-Place Cyclic/Intrusive Pointer Mutation:**
   - `sglib.h` intrusive doubly-linked lists, parent-pointer trees, and in-place pointer swaps cannot be expressed directly in affine/linear safe Bend without index-based arenas or persistent algebraic trees (which incurred 30.95x RSS on `sglib_rbtree`).
5. **No Mutual Recursion & No Computed-Value `match` Scrutinees:**
   - Upstream `bend2` requires every `def` to be defined before use (only direct self-recursion) and forbids `match` or tuple destructuring on computed expressions. Porting recursive C algorithms (`slre`, `jsmn`, `rbtree`, `listsort`, `huffbench`) required defunctionalized request ADTs (`EvalReq`, `InsReq`, `FuReq`) and explicit `Nat` fuel parameters.
6. **External C Libraries (`apr_pools`, OpenMP):**
   - `clbg/bench/algorithm/binarytrees/2.c` depends on `<apr_pools.h>` (not installed on this host) and `#pragma omp parallel`; our harness provides a minimal single-threaded bump-pointer `apr_pools.h` shim (`vendor/harnesses/apr_pools.h`) and compiles without `-fopenmp` for a fair single-threaded comparison.

---

## 5. Provenance & Pinned Upstream Sources

Full SHA-256 checksums of all 57 unmodified upstream files are recorded in `vendor/SOURCES.json`.

| Repository | URL | Pinned Commit SHA | License |
| :--- | :--- | :--- | :--- |
| `embench-iot` | `https://github.com/embench/embench-iot.git` | `09c2ed8c3b7008c95d08b038de4a3f6dc103ed70` | GPL-3.0-or-later (`tarfind`: MIT) |
| `xxHash` | `https://github.com/Cyan4973/xxHash.git` | `2ec67caeb18ec15ae60c0853174331089acddfc0` | BSD-2-Clause |
| `PolyBenchC-4.2.1` | `https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git` | `3e872547cef7e5c9909422ef1e6af03cf4e56072` | BSD-style (OSU) |
| `jsmn` | `https://github.com/zserge/jsmn.git` | `25647e692c7906b96ffd2b05ca54c097948e879c` | MIT |
| `clbg` | `https://github.com/hanabi1224/Programming-Language-Benchmarks.git` | `ad18b203dd1769724f4eea94fc3ac1e99f6593e0` | MIT |
| `tinyexpr` (gap ref) | `https://github.com/codeplea/tinyexpr.git` | `ba2e32bbcc2d1e644a7e132d24c2f542821cabe0` | zlib |

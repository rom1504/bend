# Sealed External C Corpus Estimator (`N = 20`, Wave 24)

This directory contains a **zero-self-authorship-bias** external C benchmark suite for estimating where Proven-23 `bend5k_o2 -O2` stands against real, unmodified, idiomatic C programs compiled with `gcc-10 -O2` and `gcc-10 -O3 -march=native`.

## Design & Anti-Gaming Rules
1. **Unmodified external C sources:** All 20 C benchmarks live untouched in `vendor/` (original `.c`/`.h` + `LICENSE` files; exact repository URLs, pinned commit SHAs, licenses, and per-file SHA-256 digests are recorded in `vendor/SOURCES.json`). Tiny wrappers in `vendor/harnesses/h_*.c` invoke the unmodified upstream functions and print a deterministic `U32` checksum.
2. **5 balanced strata (4 programs each, `N = 20`):**
   - **S1 — Bit / Integer / Crypto:** Embench-IoT `crc32`, `nettle-sha256`, `nettle-aes`; Cyan4973 `xxHash` (`XXH32`)
   - **S2 — Numeric / F32 / Stencil / Linear Algebra:** PolyBench/C 4.2.1 `gemm`, `jacobi-2d`, `seidel-2d`, `bicg` (`DATA_TYPE_IS_FLOAT`)
   - **S3 — Array / Graph / String / Sort / DP:** PolyBench/C 4.2.1 `floyd-warshall`, `nussinov`; Embench-IoT `matmult-int`; CLBG `nsieve`
   - **S4 — Trees / Allocator / Symbolic / Regex:** CLBG `binary-trees`; Embench-IoT `slre`, `sglib-rbtree`, `sglib-listsort`
   - **S5 — Real Mini-Apps / Parsers / Codecs:** `zserge/jsmn`; Embench-IoT `huffbench`, `tarfind`, `edn`
3. **100% safe Bend (`0 @unsafe`):** Every program under `bend/` must pass upstream `research/agy/locked_bun.sh --check-only` with zero `@unsafe` annotations and match the unmodified C oracle's deterministic `U32` checksum bit-for-bit.
4. **Honest measurement:** Pinned to CPU 3 (`taskset -c 3`), 1 warmup + 5 timed runs (median wall time in ms), plus exact per-child Peak RSS (`ru_maxrss` in KiB via a minimal `vfork` + `execvp` + `wait4` C runner so Python's own RSS never contaminates child RSS).

## Usage

```bash
python3 research/agy/bend5k/external_c_oracle_w24/evaluate.py --cpu 3 --runs 5
```

Outputs `proven23_c_distribution.json` (machine-readable distribution + raw timings + RSS). See `REPORT.md` for the full statistical analysis and expressibility gaps.

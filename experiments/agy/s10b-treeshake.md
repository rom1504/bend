# Experiment S10-B: Compiler Tree-Shaker (`wave15_unified/compiler.bend`)

- **Hypothesis:** Deterministically unifying CLI dispatch, constant-folding 0-arg `() -> Bool` feature flags, and running exact transitive reachability from `main` on `selfhost/build/agy/wave15_unified/compiler.bend` will cut compiler size and FID count while preserving all 7 native x86-64 CLI modes and **100% bit-identical `-O2` output**.
- **Outcome:** **PASS / PROMOTE-READY**
  - **Source reduction:** `91,122 -> 80,477` lines (`-11.68%`), `3.87 MB -> 3.41 MB` (`-12.02%`), `9,610 -> 9,162` defs (`-448`), `931 -> 891` laws (`-40`), `426 -> 415` types (`-11`).
  - **FID reduction (`K=10` native):** `64,869 -> 61,822` (`-3,047` FIDs, `-4.70%`), increasing FID headroom **`5.6×`** (`663 -> 3,710`).
  - **`x86-iface` sum:** `144.74 s -> 137.06 s` (`-5.31%`).
  - **Gates:** `--check-only` PASS (`0` errors, `8,946` `@unsafe` defs); **`7/7` benchmarks (`compiler_slice -O0/-O2`, `gameoflife`, `histogram`, `bst`, `editdist`, `expression`) 100% SHA-256 `.o` bit-identical (`n6_o2 == n7_pruned`)**.
- **Evidence:**
  - [treeshake_w15.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/treeshake_w15.py)
  - [verify_and_bench.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/verify_and_bench.py)
  - [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/REPORT.md)
  - [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10b_treeshake/results.json)

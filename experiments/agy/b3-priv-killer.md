# Experiment: B3 Residual `x187_priv` `O(N²)` Killer & Branch-Liveness Translation Validator

- **Hypothesis:** After `O2-F` fixed `w4b_find_loop`, residual `x187_priv` time (`42.2 s` net on `m01` with `n8_o2`) is dominated by HAMT (`KDef` map) hashing/leaf-update churn (`index_hash`, `w5c_p131i_leaf`, `index_remove`, `term_drop`) and the `O(M · L log L)` quadratic `x185_d_union` in `x185_dead_body`. Replacing these with 100% semantically identical `O(|yes|+|no|)` delta-union and empty-map/single-bucket/skip-tombstone fast paths cuts `x187_priv` with **0% compiled-program `-O2` regression**, and a standalone CFG liveness checker prevents Wave 16-class compare/branch liveness bugs.
- **Status:** **VALIDATED** (ready for Wave 18 composition; disjoint from B2 and B4).
- **Artifacts:**
  - Patcher: [apply_b3.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b3_priv_killer/apply_b3.py)
  - Translation Validator: [check_cmp_jcc_tv.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b3_priv_killer/check_cmp_jcc_tv.py)
  - Full Report & Structured Results: [REPORT.md](file:///home/ai/bend2_agy/research/agy/boot_200s/b3_priv_killer/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/boot_200s/b3_priv_killer/results.json)
- **Key Measurements:**
  - `m01` `gdb` profile on `n8_o2` (`35` `x187_priv` samples, `42.2 s` net): `index_hash` `23%`, `term_drop` `14%`, `w5c_p131i_leaf` `11%`, `index_remove` `6%`.
  - Full `wave17_unified/compiler.bend` + `apply_b3.py` (`locked_bun.sh --check-only`): `0` type errors, `0` linearity errors, idempotent 6/6 hunks.
  - Native `-O2` A/B benchmark (`x185_dead_body` + HAMT, `M=160` `P113DIf`, `L=120` live vars): **`2,537.60 ms` → `217.51 ms` (`11.67×` speedup, `-91.4%`, bit-identical `out=19240`)**.
  - `check_cmp_jcc_tv.py --self-test`: **`7/7` PASS** (rejects Wave 16 `w5c2_bits_nz` bad rewrite naming `%rdx` live on `taken (.L_b0)` at `xorl $1, %edx`; accepts `O2-C` fixed rewrites).
  - `n8_o2` smoke checks: `compiler_slice.bend -O2` → `34` (`5.77 ms`), `editdist.bend -O2` → `2065873279` (`8.96 ms`), `coverage-bst-64.bend -O2` → `861157620` (`6.16 ms`).
- **Promotion Decision:** Ready for Wave 18 integration alongside B2 and B4; zero changes to `x191_frame_forward` / `w7_post_select_full`.

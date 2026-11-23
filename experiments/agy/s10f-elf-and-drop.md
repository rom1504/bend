# Experiment S10-F: `x187_pub` + `x187_elf` + `-O2` Fast Sink

- **Date**: 2026-11-23
- **Hypothesis**:
  1. Unboxed 2-field `S10fT` byte emission, hot-8 `seen_mask` / `S10fHotIdx` relocation caching (87.1% of relocs), single-hash symbol open/close, precomputed base frames, lean `-O0` `p111_rt_sink`/`p111_rt_keep` calls (~1.0–1.5M fewer byte cons cells), 8×-unrolled `s10f_span8`/`s10f_rev8`, and single-pass symbol partitioning will cut `x187_pub + x187_elf` by 2–3×.
  2. Auditing `-O2` `p111_rt_sink` sites and upgrading any remaining bare/tag-only sites to `w14e_sh_fast_sink` will eliminate unguarded drops without regressing `hot_bench`.
- **Artifact**: [apply_s10f.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10f_elf_and_drop/apply_s10f.py), [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10f_elf_and_drop/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10f_elf_and_drop/results.json).
- **Correctness**:
  - `--check-only` on `wave15_unified/compiler.bend` + `apply_s10f.py`: **PASS (`0` errors, 9,473 defs, idempotent)**.
  - v1 end-to-end `.o` emission + SHA-256 diff on `compiler_slice.bend` caught and fixed `s10f_t_shift_cl` byte-order and `s10f_emit_bin_op` `x185_id_to_const` parity in v2.
- **Measurement & Promotion**:
  - Audit proved 100% (231/231) of general `-O2` `p111_rt_sink` sites already emit `agy_rt_sink_skip_text`; upgraded the remaining 7 bare/tag-only sites (`x198pw_worker`, `agy_map_get`, `agy_map_set`, `agy_map_sink_rsi`).
  - Full all-`-O2` A/B speedup + `64/64 native64 -O0/-O2` + `15/15 Observer -O2` gates deferred to Wave 16 Integration rebuild (mixed `-O0`/oracle-stub single-module relink hit stub-list mismatch).

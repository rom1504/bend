# Wave 13-C: Fast `x187_pub` (`2.56–2.93×` Speedup, 100% Bit-Identical `.o`)

- **Date:** 2026-11-23
- **Patch & Evidence:** [w13c_fast_x187pub.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.patch), [REPORT.md](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/results.json)
- **Target:** `x187_pub` (`29.2%` / `9.30 s` of `m11` and `13.8%` / `14.97 s` of `m05` on `n4_o2`).

## Summary of Changes (100% Pure Bend)
1. **Fused Direct-to-`X187Build` Public Segment Emitter (`w13c_pub_emit_fast`):** Emits x86-64 bytes directly onto `t_rev` for `x202k_template`, prologue/epilogue, `Set`/`Load`/`Store`/`Bin`/`Offset`/`Return`/`If`/`Call` and 0-arity `p111_rt_ctor`, bypassing `X188Seq`/`X187Instruction` allocation, `w10f_fn_seq_go` traversal, and 65-char `.L<symbol>_b<U32.show(n)>` local label formatting (replaced by 4-char `.L#<tag>`).
2. **Pre-Assembled `p111_rt_sink` (`150 B`) & `p111_rt_keep` (`152 B`) Constant Templates:** Eliminates `5,169` per-call `X188Seq` + `x187_encode` + 4-label expansions in `m11` alone.
3. **Symbol-Dispatched `x185_late_stmts` + Single-Hash `x181_frame_home`:** Skips all 10 late expanders for non-`N111Call` statements and non-expandable calls, deduplicates `p128bf_match`, and hashes each local once in `x181_frame_home`.

## Measured Results (CPU `0` & CPU `1`)
- **`m11.bend` (`x86-module-fast`, `3,549` segs):** `x187_pub` **`11,212 ms → 4,372 ms` (`2.56×`, `-61.0%`)**, `6,165,176 B` **`100%` SHA-256 bit-identical** (`a1bcd3b85096ad50`).
- **`rung2_frontend.bend` (`x86-object-fast`, `10,373` segs):** `x187_pub` **`30,046 ms → 10,253 ms` (`2.93×`, `-65.9%`)**, wall `153.46 s → 128.89 s` (`-24.57 s`), `25,942,432 B` **`100%` SHA-256 bit-identical** (`656a394cbbdd1210`).
- **Gates:** `--check-only` **PASS (`0` type errors)** | `64/64 native64` (`x86-object-fast`) **PASS (`38.7 s`)** | `64/64 native64` (`-O2`) **PASS (`66.4 s`)** | `15/15` Observer Gate **PASS (`0` violations)**.
- **Projected `n4_o2` impact:** Cuts `m11` `x187_pub` `9.30 s → ~3.63 s` (`-5.67 s`) and `m05` `x187_pub` `14.97 s → ~5.85 s` (`-9.12 s`).

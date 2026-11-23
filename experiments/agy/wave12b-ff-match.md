# Experiment: Wave 12-B — Root-Cause Fix for `ff_match` Exponential Wildcard-Duplication Blowup

- **Date:** 2026-11-23
- **Status:** **QUALIFIED & PROMOTED**
- **Report:** [`research/agy/w12_campaign/w12b_ff_match/REPORT.md`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/REPORT.md)
- **Patch:** [`research/agy/w12_campaign/w12b_ff_match/w12b_ff_match.patch`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/w12b_ff_match.patch) (`18` hunks, `431` lines against `selfhost/build/agy/wave10_unified/compiler.bend`)
- **Machine-readable results:** [`research/agy/w12_campaign/w12b_ff_match/results.json`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/results.json)

## Hypothesis
Deeply nested overlapping `match` patterns with `U32` literals and wildcard fallbacks (`p186ch_expand`, `w2_asr_strip_self`, `w5b_try_rol16`, `w5b_try_cmp_jcc`) explode combinatorially in `p86_plan` and `x198pw_plan` because `f_context_pattern` expands every `U32` literal into 66 bit-level constructors (`U32`/`WCon`/`True`/`False`/`WNil`), causing `ff_match` to duplicate overlapping/wildcard rows across all 32 reachable `Bool`-bit `Miss` branches (`64 × 64 = 4,096` `Mat` nodes in `w2_asr_strip_self`, `32 × 64 = 2,048` in `p186ch_expand`).

## Attempts
1. **Prototype 1 (Rejected):** Added `w12_has_var`/`w12_pat_sub2` and 1-ctor word ADT `Efq` short-circuiting in `ff_hit_done`. Rejected because the `64 × 64` reachable `Bool`-bit `Mat` nodes remained, and the extra `w12_has_var` walk regressed `p86_plan` (`28,950 -> 34,135 ms` on `repro_p186ch`, `31,276 -> 34,283 ms` on `repro_w2_asr`).
2. **Prototype 2 (Promoted):** Direct `#U32` literal pattern matching (`Ctr("#U32", n)` -> `Mat("#U32", n, [hit, miss])`) with full dependent type checking (`check_mat`/`ka_mat`), normalization (`norm_match`/`g_match`), binder-ceiling safety (`w7c_norm_max_term`/`norm_max_walk`), mixed `U32`/`#U32` fallback expansion (`w12_split_mixed`), O(1) `"_"` wildcard skip in `f_var_rows`/`f_hit_row`, and direct `nw_walk`/`p112m_body` native lowering.

## Evidence (CPU `6`, `-O2` `x86-object`)
- **`repro_w2_asr` (unflattened, `out=5`):** `p86_plan` `31,276 -> 483 ms` (**`64.8x`**), `x198pw_plan` `11,744 -> 764 ms` (**`15.4x`**), total wall `45,968 -> 4,275 ms` (**`10.8x`**).
- **`repro_p186ch` (unflattened, `out=35`):** `p86_plan` `28,950 -> 627 ms` (**`46.2x`**), `x198pw_plan` `9,402 -> 1,097 ms` (**`8.57x`**), total wall `42,009 -> 5,327 ms` (**`7.89x`**).
- **`repro_w5b_rol16` (unflattened, `out=102`):** `p86_plan` `1,238 -> 547 ms` (**`2.26x`**), total wall `9,943 -> 6,406 ms` (**`1.55x`**).
- **`repro_w5b_cmp_jcc` (unflattened, `out=102`):** `p86_plan` `1,530 -> 685 ms` (**`2.23x`**), `x198pw_plan` `1,547 -> 1,298 ms` (**`1.19x`**).
- **Gates:** `--check-only` PASS (`0` errors, `8,679` defs), `64/64 native64` (`-O2`) PASS (`89.9 s`), `15/15` Observer Gate PASS (`44+2` ABI + `15/15` probes, `0` violations).

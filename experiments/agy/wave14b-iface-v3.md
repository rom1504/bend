# Wave 14-B: Native `n5_o2 x86-iface` Profile & Pure-Bend `x86-iface v3`

**Date:** 2026-11-23  
**Status:** **PASSED** (`--check-only` 0 errors; `1.324×` on `m06` & `1.579×` on `m10` native `-O0` apples-to-apples; `1.763×` on `m06` & `1.987×` on `m10` with `m11` at `-O2`; 100% exact `stamp` & 100% SHA-256 bit-identical downstream `m07.o` and `m11.o`)

## Headline Findings
1. **Native `x86-iface` Profile (`n5_o2` `sample-threads.c` + instrumented `m11` sub-stage timers on `m06` & `m10`, CPUs `0, 1`):**
   - On `m10` (`42.1 MB` `.p130`), the 4 phases broke down as: **`3_fast_abi` `32.1%`** (dominated by `p113pl_candidates` at **`24.6%`**), **`.p130` encode+write `24.7%`**, **`p86_plan_loaded` `20.2%`** (`typecheck` + `annotate_selected` on `~830` upstream stubs + unused `driver_report_data`), **`p130` read+decode `14.4%`**, and **`parse` `8.8%`**.
   - Root-cause discovery: `5,781 / 8,841` (`65.4%`) of all `k14_wave13` compiler defs are CPS stubs, yet `p113pl_candidates` was lowering all `588–615` suffix defs into full `P113DStmt` IR before `p113d_passes` discarded every caller of an upstream CPS stub or HO chooser (`nt_choose`/`kc`).
2. **Pure-Bend `x86-iface v3` ([w14b_iface_v3.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/w14b_iface_v3.patch), `0` new types, `0` C, `0` JS):**
   - **OPT #1:** CPS+HO transitive pruning (`w14a_collect_cps` + `w14d_cps_seed` + `w7_pre_peel`) + `w13d_p113pl_candidates_fast` + skip `p128br_scan` & `nq_signatures`.
   - **OPT #2:** Zero-fallback direct-dispatch word-pair `.p130` decoder (`w14_p88_cache_prepare`, inlining `Con`/`KTerm`/`KIndexLeaf`/`KIndexNode`/`Empty` = `92.5%` of all `779k` records).
   - **OPT #3:** Strictly-linear fast `.p130` encoder (`w14_emit_checked`, pre-interned top-10 strings + pre-allocated `Absent` + leaf `ADT` interning).
   - **OPT #4:** Fast `p86_plan` (`w14_plan_loaded` + `w14d_plan_context`: skip unused `driver_report_data`, suffix-only `driver_emit_owned`, skip annotating upstream stubs).
3. **Verified Native Dogfood (`m11` 1-module rebuild) & Soundness Gates:**
   - **`m06`:** `32,430 ms -> 24,491 ms` (**`1.324×`** `-O0` vs `-O0`; **`18,391 ms`** = **`1.763×`** with `m11 -O2`), `stamp` exact, **`m07.o` SHA-256 bit-identical** (`72ca833b5667f17c...`).
   - **`m10`:** `47,823 ms -> 30,282 ms` (**`1.579×`** `-O0` vs `-O0`; **`24,067 ms`** = **`1.987×`** with `m11 -O2`), `stamp` exact, **`m11.o` SHA-256 bit-identical** (`2be0f658a6825bd8...`).
   - **`--check-only`:** **PASS (`0` type/linearity errors)** on patched `wave13_unified/compiler.bend`.

## Full Artifacts
- [REPORT.md](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/REPORT.md)
- [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/results.json)
- [w14b_iface_v3.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/w14b_iface_v3.patch)

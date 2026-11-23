# Wave 14-C: Native `n5_o2` `m11` Zero-Loss Profile & `K=8` vs `K=14` True-Cold Pipelining

**Date:** 2026-11-23  
**Status:** **COMPLETE — `K=8` REJECTED FOR TRUE-COLD (`242.75 s` vs `K=14` `216.38 s`); ZERO-LOSS `m11` PROFILE (`4,083` SAMPLES, `0` DROPPED/OVERRUNS) IDENTIFIES `<= 14 s` LEVERS**

## Headline Findings

1. **`K=8` vs `K=14` Zero-Cache True-Cold (`n5_o2`):**
   - **Hypothesis falsified:** Reducing `K=14` (`13` hops) -> `K=8` (`7` hops) did **not** speed up zero-cache true-cold.
   - `K=8` 7-hop `x86-iface` chain took **`207.10 s`** vs `K=14`'s 13-hop **`196.34 s`** (`+10.76 s`), and `K=8`'s larger `m07` leaf doubled the post-iface tail (`36.15 s` vs `19.48 s`), yielding **`242.75 s` 7-core pipelined true-cold** vs `K=14`'s **`216.38 s`** (`+26.37 s` slower) and **`36.7 s` leaf edit** vs `20.0 s`.
   - **Why:** `.p130` decode (`prep`) is only `~10–16 s` summed across all modules; `x86-iface` is dominated by `p86_plan` + interface construction over the module's own defs (super-linear on dense `m00` with `1,938` defs / `1,653` exports = `42.41 s` alone).
   - **Silver lining:** `K=8` cut FIDs by **`6,207`** (`58,973 / 65,532` vs `65,180 / 65,532`, `10%` headroom) and `n6_k8` linked (`90.5 MB`) and passed `compiler_slice.bend` smoke (`out=34`).
   - **Decision:** Keep **`K=14`** (removed `k8_wave13/`, preserved `split_k8_w13.py`). Breaking `<= 100 s` true-cold requires **accelerating `x86-iface` itself** (W14-B), not shrinking `K`.

2. **Zero-Loss `n5_o2` Profile of `m11` (`20.32 s` wall, `20.19 s` CPU, `4,083` samples @ `5000 us`, `0` dropped, `0` overruns, `+1.02%` overhead):**
   - **`--trace` breakdown:** `x198pw_plan` **`7,782 ms` (`38.3%`)**, `p86_plan` **`5,629 ms` (`27.7%`)**, `x187_pub` **`2,511 ms` (`12.4%`)**, `prep` **`2,023 ms` (`10.0%`)**, `x187_elf` **`1,950 ms` (`9.6%`)**, `read` `179 ms`, `x187_priv` `131 ms`.
   - **Physical buckets:** `generated_bend` `53.71%` (`10.85 s`), `reclamation` `24.34%` (`4.92 s`: `term_drop` `20.28%` + `span_fade` `4.07%`), `ownership_and_products` `10.68%` (`2.16 s`: `p125_rt_ctor2` `4.95%`, `p198_rfc_take2` `2.94%`, `p111_rt_take` `2.20%`, `p111_rt_ctor` `1.59%`, `ctr_take` `1.32%`).
   - **Top Bend leaves:** `String.append` (`4.11%`), `agy_str_eq` (`1.93%`), `index_find` (`1.59%`), `p98_tag_eq` (`1.49%`), `index_hash` (`1.45%`), `String.eq` (`1.10%`), `w6_local_find` (`0.93%`), `nt_reverse` (`0.78%`), `p88_string_eq` (`0.78%`), `p88_number_read` (`0.76%`), `p131i_insert` (`0.76%`).
   - **Actionable levers (`20.3 s -> 11.5–13.8 s`):**
     1. Pure-Bend x86-64 `-O2` inlined immediate-skip before `term_drop` + inlined bump-alloc `ctor2` (`-2.0 to -3.0 s`).
     2. `U32`-tag `KTerm`/`p98_tag_eq` + closure-free `w6_local_find` + inlined `String.eq` (`-2.5 to -3.5 s`).
     3. Reduce `String.append` in `x198pw_plan` + borrow `+tree` in `index_find` (`-1.0 to -1.5 s`).
     4. Tighten `.p130` word-pair decode in `prep` (`-0.8 to -1.2 s`).

## Full Report & Evidence
- [REPORT.md](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/REPORT.md)
- [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/results.json)
- [m11_profile.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14c_k8_and_prof/m11_profile.json)

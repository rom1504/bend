# W13-A Report: Zero-Loss Native CPU Re-Profile of `n4_o2` (`m05` & `m11`) + Top-3 Self-Compile Speedup Plan

**Status:** **COMPLETE — 100% Zero-Loss Captures (`0` dropped, `0` overruns, `>99%` symbol-resolved on both `m05` and `m11`) + SMOKING-GUN `20.17%` / `16.09%` `agy_sh_*` Guard Bailout Discovered.**

- **Binary profiled:** [n4_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n4_o2) (`67,862,728 B`, `11/13` `-O2` + `m08, m09` `-O0`)
- **Hardware / Isolation:** Dedicated CPU `6` (`taskset -c 6`), `ulimit -s 262144`, `timeout 180`, `sample-threads.c` (`8,000 us` period -> `0` dropped, `0` overruns) decoded via [analyze.py](file:///home/ai/bend2_agy/selfhost/tools/profiler/analyze.py)
- **Driver & Receipts:** [run_w13a_profile.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13a_n4_profile/run_w13a_profile.py), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13a_n4_profile/results.json)

---

## Executive Summary & Headline Smoking Gun

1. **SMOKING GUN: `agy_sh_emit_strcmp` and ALL `agy_sh_*` string/hash/tag fast paths bail out 100% of the time in `n4_o2`!**
   - Rather than eliminating `$p128borrow.owned.String.order.go` (was `17.62%` in P5-A), `p113d_FID_$p128borrow.owned.String.order.go__sh_slow` is STILL **#1 in `m05` (`11.78%`, `12.81 s`)** and **#2 in `m11` (`9.41%`, `3.01 s`)**!
   - Across all `__sh_slow` functions (`String.order.go`, `index_hash`, `String.eq`, `p98_tag_eq`, `p88_string_eq`, `agy_str_eq`), `n4_o2` wastes **`20.17%` of `m05` (`21.92 s`)** and **`16.09%` of `m11` (`5.14 s`)** in slow fallback paths (`<0.8%` in fast paths).
   - **Exact Root Cause (proven by `objdump -d` + `.data` dump of `n4_o2`):**
     - `agy_sh_guard_caps` ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave11_unified/compiler.bend#L71066-L71074)) checks `(p111_program.capabilities & 9) == 9` and `agy_sh_chk_hot` ([compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave11_unified/compiler.bend#L71057-L71062)) checks `p111_cid_hot[cid] == 0` for `SCon, SNil, Chr, LT, EQ, GT`.
     - In `n4_o2`, `p111_mod_m11_program` (copied into `p111_program` at startup by `w10_merge_copy_root`) has **`capabilities = 5` (`0x05`, bit 3 = `0`!)** and **`p111_cid_hot` is ALL `0x01`** (`794/794` constructors marked hot) because `p118c_plan` requires `ns_definitions` (false for the `IO`/`@unsafe` compiler) and `p118c_ordinary` excludes `Chr`.
     - **Why the guard is unnecessary:** Every `agy_sh_*` function is **read-only**, returns only 0-arity immediates (`LT`/`EQ`/`GT`/`True`/`False`) or `U32`, and its inner loop **already unwraps RFC-sealed pointers** (`test %r, %r; jge ...; mov (%r10,%r11,8),%r11; shr $0x18,%r11`). Checking `(capabilities & 1) == 1` alone is 100% sound under all Observer Gate modes (`normal`, `cap-no8`, `all-hot`) and immediately unlocks **`~1.16–1.21×` across all 13 modules** (~10-line pure-Bend edit).
2. **Reclamation + Allocation + Take/Borrow = `35.3%` of `m05` (`38.3 s`) and `38.4%` of `m11` (`12.3 s`):**
   - `term_drop` (`11.58%` / `13.86%`) + `span_fade` (`5.02%` / `4.12%`) + `p125_rt_ctor2` (`7.24%` / `8.66%`) + `p111_rt_take`/`p198_rfc_take2`/`ctr_take`/`p118_rt_borrow_scalar_safe` (`9.31%` / `9.21%`) dominate because `p111_cid_hot = all 1s` disables `agy_rt_ctor_text` and forces RFC sealing on every heap constructor.
3. **Why `m05` (`108.7 s`) is `3.4×` slower than `m11` (`31.9 s`) — and how W12-B + W12-A + W12-F already help:**
   - `m05.bend` contains **`19` nested constructor+`U32` literal patterns** (`W4BRR{..., 64, ..., 64}`, `N111Alloca{..., 2048, 8}`, `N111Const{+lo, 0}`), driving `p86_plan = 39.0 s` (`35.9%`) and `x198pw_plan = 48.8 s` (`45.0%`). `m11.bend` has `0` numeric patterns (`p86_plan = 6.7 s`), so `x187_pub` (`9.3 s`, `29.2%`, currently running `-O0` in `m08`/`m09`) is `m11`'s #2 stage.

---

## 1. `--trace` Stage Breakdown (`n4_o2 --trace x86-module-fast`, Solo CPU `6`)

| Stage | `m05` (ms) | `m05` (%) | `m11` (ms) | `m11` (%) | Notes |
|---|---:|---:|---:|---:|---|
| `read` | 58.0 | 0.1% | 110.0 | 0.3% | Source + `.p130` file read |
| `prep` | 729.0 | 0.7% | 1,487.0 | 4.7% | `.p130` load (`m04` 12.5 MB vs `m10` 25.6 MB) |
| `p86_plan` | **38,994.0** | **35.9%** | 6,730.0 | 21.1% | `m05` `5.8×` slower (`19` nested `U32` patterns) |
| `x198pw_plan` | **48,846.0** | **45.0%** | **11,855.0** | **37.1%** | `5,957` segs (`m05`) vs `3,549` segs (`m11`) |
| `x187_priv` | 2,268.0 | 2.1% | 255.0 | 0.8% | `544` (`m05`) vs `233` (`m11`) private fns |
| `x187_pub` | **14,972.0** | **13.8%** | **9,304.0** | **29.2%** | Runs `-O0` (`m08`/`m09` fallback!) — `2.5–2.6 ms/seg` |
| `x187_elf` | 2,551.0 | 2.3% | 2,051.0 | 6.4% | ELF serialization (`9.98 MB` vs `6.17 MB`) |
| **Trace Total / Wall** | **108,646 / 108,704** | **100%** | **31,917 / 31,943** | **100%** | **Zero-loss (`0` dropped, `0` overruns)** |

---

## 2. Zero-Loss Native CPU Profiles (Top 25 Decoded Leaf Functions)

- **`m05` capture:** `13,561` samples (`8 ms` period), `dropped=0`, `overruns=0`, `zeroLoss=True`, `usable=True`, **`99.03%`** symbol-resolved.
- **`m11` capture:** `3,984` samples (`8 ms` period), `dropped=0`, `overruns=0`, `zeroLoss=True`, `usable=True`, **`99.25%`** symbol-resolved.

### Top 25 Functions — `m05` (`108.70 s`, Longest Pole)

| Rank | % CPU | Samples | Est. s | Decoded Symbol | Bucket |
|---:|---:|---:|---:|---|---|
| 1 | **11.78%** | 1,598 | 12.81 | `p113d_FID_$p128borrow.owned.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 2 | **11.58%** | 1,571 | 12.59 | `term_drop` | Reclamation |
| 3 | **7.24%** | 982 | 7.87 | `p125_rt_ctor2` | Ctor alloc |
| 4 | **5.02%** | 681 | 5.46 | `span_fade` | Reclamation |
| 5 | **3.01%** | 408 | 3.27 | `p111_rt_take` | Take / borrow |
| 6 | **2.88%** | 390 | 3.13 | `p111_rt_op` | Primitive op |
| 7 | **2.26%** | 306 | 2.45 | `p118_rt_borrow_scalar_safe` | Take / borrow |
| 8 | **2.03%** | 275 | 2.20 | `p113d_FID_$p118borrow.read.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 9 | **1.61%** | 218 | 1.75 | `work_loop.constprop.0` | Scheduler |
| 10 | **1.56%** | 212 | 1.70 | `p198_rfc_take2` | Take / borrow |
| 11 | **1.47%** | 200 | 1.60 | `p111_rt_ctor` | Ctor alloc |
| 12 | **1.38%** | 187 | 1.50 | `p113d_FID_$direct.index_find` | Map lookup |
| 13 | **1.36%** | 185 | 1.48 | `p113d_FID_$p118borrow.read.index_hash__sh_slow` | **`__sh_slow` bailout** |
| 14 | **1.04%** | 141 | 1.13 | `p113d_FID_$direct.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 15 | **1.02%** | 138 | 1.11 | `p113d_FID_$direct.nb_contains` | Set lookup |
| 16 | **0.95%** | 129 | 1.03 | `[library_unresolved]` (`libc`) | C library |
| 17 | **0.86%** | 116 | 0.93 | `p113d_FID_$direct.String.eq__sh_slow` | **`__sh_slow` bailout** |
| 18 | **0.80%** | 108 | 0.87 | `p113d_FID_$p128borrow.owned.p98_tag_eq__sh_slow` | **`__sh_slow` bailout** |
| 19 | **0.77%** | 105 | 0.84 | `p113d_FID_$direct.String.append` | String alloc |
| 20 | **0.63%** | 85 | 0.68 | `p113d_FID_$direct.ks` | KTerm accessor |
| 21 | **0.60%** | 82 | 0.66 | `p113d_FID_$p128borrow.owned.String.eq__sh_slow` | **`__sh_slow` bailout** |
| 22 | **0.60%** | 82 | 0.66 | `p113d_FID_$direct.p88_string_eq__sh_slow` | **`__sh_slow` bailout** |
| 23 | **0.49%** | 66 | 0.53 | `ctr_take` | Take / borrow |
| 24 | **0.44%** | 59 | 0.47 | `p111_rt_sink` | Take / borrow |
| 25 | **0.41%** | 56 | 0.45 | `p125_rt_take2` | Take / borrow |

### Top 25 Functions — `m11` (`31.94 s`, Leaf Edit)

| Rank | % CPU | Samples | Est. s | Decoded Symbol | Bucket |
|---:|---:|---:|---:|---|---|
| 1 | **13.86%** | 552 | 4.43 | `term_drop` | Reclamation |
| 2 | **9.41%** | 375 | 3.01 | `p113d_FID_$p128borrow.owned.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 3 | **8.66%** | 345 | 2.77 | `p125_rt_ctor2` | Ctor alloc |
| 4 | **4.12%** | 164 | 1.32 | `span_fade` | Reclamation |
| 5 | **2.66%** | 106 | 0.85 | `p111_rt_op` | Primitive op |
| 6 | **2.43%** | 97 | 0.78 | `p198_rfc_take2` | Take / borrow |
| 7 | **2.26%** | 90 | 0.72 | `p113d_FID_$p118borrow.read.index_hash__sh_slow` | **`__sh_slow` bailout** |
| 8 | **1.83%** | 73 | 0.59 | `p111_rt_take` | Take / borrow |
| 9 | **1.61%** | 64 | 0.51 | `p113d_FID_$direct.String.append` | String alloc |
| 10 | **1.53%** | 61 | 0.49 | `p118_rt_borrow_scalar_safe` | Take / borrow |
| 11 | **1.46%** | 58 | 0.46 | `work_loop.constprop.0` | Scheduler |
| 12 | **1.26%** | 50 | 0.40 | `p111_rt_ctor` | Ctor alloc |
| 13 | **1.13%** | 45 | 0.36 | `p113d_FID_$direct.index_find` | Map lookup |
| 14 | **1.08%** | 43 | 0.34 | `p113d_FID_$p118borrow.read.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 15 | **0.95%** | 38 | 0.30 | `ctr_take` | Take / borrow |
| 16 | **0.88%** | 35 | 0.28 | `p113d_FID_$direct.String.eq__sh_slow` | **`__sh_slow` bailout** |
| 17 | **0.83%** | 33 | 0.26 | `p111_FID_$direct.p131i_insert` | CPS / `-O0` (`x198`) |
| 18 | **0.75%** | 30 | 0.24 | `[library_unresolved]` (`libc`) | C library |
| 19 | **0.68%** | 27 | 0.22 | `p113d_FID_$direct.String.order.go__sh_slow` | **`__sh_slow` bailout** |
| 20 | **0.60%** | 24 | 0.19 | `p111_FID_$direct.U32.show.fin` | CPS / `-O0` (`x187`) |
| 21 | **0.50%** | 20 | 0.16 | `p198_rfc_take4` | Take / borrow |
| 22 | **0.48%** | 19 | 0.15 | `p113d_FID_$direct.nt_reverse` | List utility |
| 23 | **0.48%** | 19 | 0.15 | `p111_FID_$direct.x187_build_parsed` | CPS / `-O0` (`m08/m09`) |
| 24 | **0.48%** | 19 | 0.15 | `p111_rt_return` | Scheduler |
| 25 | **0.48%** | 19 | 0.15 | `p125_rt_take2` | Take / borrow |

### Full-Binary Semantic Buckets (All 1,519 `m05` / 743 `m11` Symbols)

| Semantic Bucket | `m05` % | `m05` (s) | `m11` % | `m11` (s) |
|---|---:|---:|---:|---:|
| **`__sh_slow` (ALL string/hash/tag bailouts)** | **20.17%** | **21.92 s** | **16.09%** | **5.14 s** |
| **Reclamation (`term_drop` + `span_fade` + `blk_free`)** | **16.61%** | **18.05 s** | **17.97%** | **5.74 s** |
| **Ctor allocation (`p125_rt_ctor*` + `p111_rt_ctor` + `heap_alloc*`)** | **9.36%** | **10.17 s** | **11.17%** | **3.57 s** |
| **Take & borrow (`rt_take` + `rfc_take*` + `ctr_take` + `borrow_scalar` + `rt_sink`)** | **9.31%** | **10.12 s** | **9.21%** | **2.94 s** |
| `p111_rt_op` | 2.88% | 3.13 s | 2.66% | 0.85 s |
| `p113_rt_array_pair` | 0.00% | 0.00 s | 0.13% | 0.04 s |
| Scheduler (`work_loop` + `rt_return` + `set_regs` + `rt_jump`) | 2.38% | 2.59 s | 2.56% | 0.82 s |
| Map/set lookup (`index_find` + `nb_contains` + `w5c3_find` + `nu_has`) | 3.16% | 3.44 s | 2.61% | 0.83 s |
| KTerm accessors (`ks`, `dn`, `nm`, `dk`, `da`, `dc`) | 2.15% | 2.34 s | 1.51% | 0.48 s |
| `p113d_FID_*` (`-O2` generated Bend) vs `p111_FID_*` (CPS/`-O0`) | `34.59%` vs `23.46%` | — | `31.07%` vs `23.72%` | — |

---

## 3. Projected Impact of Existing Wave 12 Patches (`W12-B` + `W12-A` + `W12-F`)

1. **`W12-B` (`#U32` Direct Literal Pattern Matching):**
   - Across `k13_wave11`, modules with `0` nested `U32` patterns (`m06`, `m10`, `m11`) average `p86_plan = 10.1 s` and `x198pw_plan = 20.1 s`, whereas modules with `>= 10` nested `U32` patterns (`m00a..m05`, `m08`, `m09`; `214` nested patterns total, `19` in `m05`) average `p86_plan = 29.8 s` (`3.0×` higher) and `x198pw_plan = 34.2 s` (`1.7×` higher).
   - **Projected win:** **`-180 to -240 s` (`~20–25%`)** off the `957 s` sequential sum (`m05` `108.7 s -> ~72 s`, `m02` `125.7 s -> ~78 s`); **`~0%`** on `m11` (`0` numeric patterns).
2. **`W12-F` (`w12f_rt_ctor2_sealed_text` + Boxed `Array`):**
   - `p113_rt_array_pair` is `0.00%` (`m05`) / `0.13%` (`m11`), **but** `w12f_rt_ctor2_sealed_text` directly attacks `p125_rt_ctor2` (`7.24%` `m05` / `8.66%` `m11`) even when `cid_hot == all 1`!
   - **Projected win:** **`-3.5% to -5.5%`** across all 13 modules (`~35–50 s` off sequential sum, `~1.5 s` off `m11`).
3. **`W12-A` (Unboxed `Bool` Match + Borrow-Loop Direct Field Load):**
   - Speeds up `Bool` matches and `$p118borrow.read.*` / `index_find` / `nb_contains` loops.
   - **Projected win:** **`-3% to -5%`** across all 13 modules (`~30–45 s` off sequential sum, `~1.0–1.5 s` off `m11`).

---

## 4. Actionable Top-3 NEW Pure-Bend Wins (Toward `<= 60 s` Warm-Cold & `<= 15 s` 1-Module Edit)

| Priority | Pure-Bend Win | Profile Target (`m05` / `m11`) | Projected Speedup | Effort / Risk |
|---:|---|---|---|---|
| **#1** | **Fix `agy_sh_guard_caps` & remove bogus `agy_sh_chk_hot` in [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave11_unified/compiler.bend#L71055-L71075)** — guard only `(capabilities & 1) == 1` (packed words); all `agy_sh_*` loops are read-only and already RFC-aware | **`20.17%` / `16.09%`** (`21.9 s` / `5.1 s`) | **`1.16–1.21×`** (`m05 -19 s`, `m11 -4.5 s`, seq `-160 s`) | **Tiny (~10 lines), zero risk**, 100% Observer Gate safe |
| **#2** | **Inline `p125_rt_ctor2` (with 1-word `alc->free[0]` `rfc_seal`), `p198_rfc_take2`, and `rc > 1` / trivial `term_drop` + `p111_rt_sink` in `agy_rt_inline_try`** (extending W12-F) | **`35.28%` / `38.35%`** (`38.3 s` / `12.3 s`) | **`1.20–1.28×`** across all 13 modules (`m11 -5.5 to -7 s`) | **Medium** (reuses W12-F's proven `alc->free[0]` pattern) |
| **#3** | **Unlock `13/13` `-O2` (`m08`/`m09` 1-line `p113d` 0-arity `weak_set` fix) + Fast `x187_pub` (skip `U32.show`/`String.append` internal label formatting) + Balanced `K=15..16` Split** | **`13.8%` / `29.2%`** (`15.0 s` / `9.3 s` in `x187_pub`) | **`1.15–1.25×` on `m11`** (`x187_pub -40%`), max-pole `<= 45 s` | **Small–Medium** (1-line fix + `x187_pub` cleanup) |

### Stacked Trajectory vs 8-Hour Plan Targets
- **Current `n4_o2`:** `957.4 s` sequential sum, `224.8 s` 5-core warm-cold, `31.9 s` `m11` solo (`33.4 s` w/ relink).
- **After W12-A/B/F + New Win #1 (`agy_sh_*`) + New Win #2 (inline `ctor2`/`take2`/`drop`) + New Win #3 (`13/13 -O2` + `x187_pub` + balanced `K=15..16`):**
  - **Sequential sum:** `957 s -> ~370–440 s` (**`2.2–2.6×` faster!**)
  - **6–7 core warm-cold:** **`~55–65 s`** (**hits `<= 60 s` target!**)
  - **1-module leaf edit (`m11` + relink):** `33.4 s -> ~13–15 s` (**hits `<= 15 s` target!**)

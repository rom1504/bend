# Wave 13 Report: `wave13_unified`, Full `14/14` `-O2` Native `n5_o2` (`2.66×` Faster), and `76.9 s` Warm-Cold / `216.4 s` True-Cold 7-Core Native Self-Reproduction

**Date:** 2026-11-23  
**Status:** **PASSED — FULL `14/14` `-O2` NATIVE `n5_o2` & 100% NATIVE 7-CORE SELF-REPRODUCTION VERIFIED**

## 1. Headline Achievements

1. **Wave 13 Unified Pure-Bend Compiler (`selfhost/build/agy/wave13_unified/{compiler.bend, api.mjs}`):**
   - Composed all **9 Wave 12 wins** (`W13-A Win #1`, `W11-C` 0-arity CPS stub fix, `W12-B` `#U32` match, `W12-E` `x86-iface v2`, `W12-A` Bool/borrow, `W12-D` dual-array LCU + `W12FwdDrop`, `W12-F` boxed `Array.get/set`, `W12-G` 7-family 1×, `W13-B` compact `ctor2`/`take`) **+** **W13-C** (`2.56×` faster fused direct-to-`X187Build` `x187_pub`) **+** **W13-D** (`1.835×` faster `x198pw_plan_fast` with `p126sc_candidates` ABI parity restored) **+** **W13-INT FID-budget recovery** (`w6_canon_seg` `fuel=256`, `w6_dedup_segments` `rounds=2`).
   - Verified with **`0` type/linearity errors** (`--check-only`), **`64/64` `-O0` PASS (`24.9 s`)**, **`64/64` `-O2` PASS (`74.2 s`)**, and **`15/15` Observer Gate PASS (`0` violations)**.

2. **First Full `14/14` `-O2` Native Compiler Binary (`selfhost/build/agy/wave13-native-mod/n5_o2`, `72.28 MB`):**
   - **Zero `-O0` fallbacks** (`14/14` `-O2`, `65,180 / 65,532` FIDs, `0` C, `0` `objcopy`, `0` `--allow-multiple-definition`, `0` link warnings).
   - **`compiler_slice.bend` (`-O0`):** **`3,006.9 ms`** vs Wave 11 `n4_o2`'s `8,013 ms` (**`2.66×` faster**) and Wave 10 `n3_w10`'s `11,139 ms` (**`3.70×` faster**).
   - **3-Family `-O2` Runtime Smoke on `n5_o2`:** `histogram = 45.89 ms`, `nbody = 96.47 ms`, `gameoflife = 437.88 ms` (all checksums exact).

3. **100% Native 7-Core Self-Reproduction (`n5_o2 -> n6_w13` / `n6_cold`, CPUs `0..6`, 0 JS / 0 C / 0 `objcopy`):**
   - **Warm-`.p130` 7-Core Native Cold E2E (`n5_o2 -> n6_w13`):** **`76.93 s`** (`76.38 s` compile across `14/14` modules, **`6.24×`** parallel scaling, **`67.5 ms`** native `x86-merge-obj` SHA-256 bit-identical to JS, `480.7 ms` link) — **`2.92×` faster** than Wave 11 (`224.81 s`) and **`6.42×` faster** than Wave 10 (`493.54 s`).
   - **Zero-Cache True-Cold Pipelined 100% Native E2E (`.bend` -> `n6_cold`):** **`216.38 s` (`3m 36s`)** (`CPU 0` native `13/13` `x86-iface` chain = **`196.34 s`**, **`5.44×` faster** than JS `1,067.5 s`; `CPUs 1..6` pipelined `x86-module-fast` finished with only a `19.48 s` tail; **`14/14` `.o`s 100% SHA-256 bit-identical** to warm-`.p130`; `n6_cold` smoke `out=34`) — **`~2.70×` faster** than Wave 11's `~585 s` projected true-cold!
   - **Native 1-Module Incremental Body Edits on `n5_o2` (CPU `0`):**
     - **Leaf edit (`m11`):** **`20.00 s`** (`19.24 s` compile + `0.46 s` relink, `13/14` `.o` SHA-256 untouched, live `stage=read_w13` & `out=34`) — **`1.67×` faster** than Wave 11 (`33.37 s`).
     - **Mid-stack body-only edit (`m06`):** **`23.56 s`** (`22.72 s` compile + `0.48 s` relink; native `x86-iface` **`12.93 s`** = **`3.67×` faster** than Wave 11's `47.50 s`, proved `.p130` stamp **UNCHANGED**, `13/14` `.o` SHA-256 untouched, `out=34`).

## 2. Bottleneck Finding for Next Wave (`<= 100 s` True-Cold)
In the 7-core zero-cache true-cold pipeline (`216.38 s`), **`90.7%` (`196.34 s`) is the sequential `CPU 0` `x86-iface` chain**, while the 6 parallel `x86-module-fast` workers absorb all 14 compiles underneath with only a `19.48 s` tail. Accelerating `x86-iface` (e.g., W13-E `p86_plan` speedup + avoiding redundant `p113d`/type-check work in `x86-iface`) is the single remaining lever to break **`<= 100 s` true-cold E2E**.

## 3. Artifacts & Provenance
- **W13-INT Integration & Self-Reproduction:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13_int_n5_o2/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13_int_n5_o2/results.json), [compose_w13.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13_int_n5_o2/compose_w13.py), [split_k14_w13.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13_int_n5_o2/split_k14_w13.py), [run_w13_n5_o2.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13_int_n5_o2/run_w13_n5_o2.py)
- **Published Binaries:** [n5_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave13-native-mod/n5_o2) (`72.28 MB`), [n6_w13](file:///home/ai/bend2_agy/selfhost/build/agy/wave13-native-mod/n6_w13) (`94.29 MB`)
- **Verified Cache:** `/tmp/agy_k14_w13_cache/{iface,obj_o0}` (`13` `.p130` + `14` `.o` + `merge_n6_w13.o`; `/tmp/agy_k13_w11_cache/` removed; `/dev/md2` free = `6.4 GiB`)

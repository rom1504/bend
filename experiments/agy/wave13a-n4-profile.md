# Wave 13-A: Zero-Loss Native CPU Re-Profile of `n4_o2` (`m05` & `m11`)

- **Date:** 2026-11-23
- **Binary:** [n4_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n4_o2) (`11/13` `-O2` + `m08, m09` `-O0`)
- **CPU / Method:** CPU `6` (`taskset -c 6`), `ulimit -s 262144`, `sample-threads.c` (`8,000 us` period -> `0` dropped, `0` overruns, `zeroLoss=True`, `usable=True`), decoded with [analyze.py](file:///home/ai/bend2_agy/selfhost/tools/profiler/analyze.py).
- **Full Report & Data:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13a_n4_profile/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13a_n4_profile/results.json)

## Key Findings

1. **Smoking Gun (`20.17%` of `m05` / `16.09%` of `m11`): 100% `agy_sh_*` Fast-Path Bailout**
   - `p113d_FID_$p128borrow.owned.String.order.go__sh_slow` is still **#1 in `m05` (`11.78%`, `12.81 s`)** and **#2 in `m11` (`9.41%`, `3.01 s`)**, and all `__sh_slow` fallbacks total **`20.17%` (`21.92 s`) in `m05`** and **`16.09%` (`5.14 s`) in `m11`**.
   - Disassembly + `.data` inspection of `n4_o2` proved `p111_mod_m11_program.capabilities = 5` (bit 3 = `0`) and `p111_cid_hot` is all `0x01` (`794/794` hot), causing `agy_sh_guard_caps` (`capabilities & 9 == 9`) and `agy_sh_chk_hot` (`cid_hot[cid] == 0`) to bail out 100% of the time — even though all `agy_sh_*` loops are read-only and already unwrap RFC-sealed pointers.
   - **Fix (Win #1):** Guard only `(capabilities & 1) == 1` (~10 lines in `compiler.bend:71055-71075`) -> immediate **`1.16–1.21×`** across all 13 modules (`-160 s` sequential sum), 100% Observer Gate compliant.
2. **Reclamation + Allocation + Take/Borrow = `35.3%` (`m05`) / `38.4%` (`m11`)**
   - `term_drop` (`11.58%`/`13.86%`), `span_fade` (`5.02%`/`4.12%`), `p125_rt_ctor2` (`7.24%`/`8.66%`), and `p111_rt_take`/`p198_rfc_take2`/`ctr_take`/`p118_rt_borrow_scalar_safe` (`9.31%`/`9.21%`).
   - **Fix (Win #2):** Extend W12-F's `agy_rt_inline_try` to inline `p125_rt_ctor2` with 1-word `alc->free[0]` `rfc_seal`, inline `p198_rfc_take2`, and inline `rc > 1` / trivial `term_drop` + `p111_rt_sink` -> **`1.20–1.28×`** across all 13 modules.
3. **Stage Breakdown & `m08`/`m09` `-O0` Fallback (`x187_pub = 29.2%` of `m11`)**
   - `m05` (`108.70 s`): `p86_plan = 38.99 s` (`35.9%`), `x198pw_plan = 48.85 s` (`45.0%`), `x187_pub = 14.97 s` (`13.8%`). `m05.bend` has `19` nested `U32` literal patterns (`W12-B` projects `-25–33%` on `m05`, `-180–240 s` sequential sum).
   - `m11` (`31.94 s`, `0` numeric patterns): `x198pw_plan = 11.86 s` (`37.1%`), `x187_pub = 9.30 s` (`29.2%`), `p86_plan = 6.73 s` (`21.1%`).
   - **Fix (Win #3):** Land the 1-line `p113d` 0-arity `weak_set` fix to compile `m08`/`m09` at `-O2` + eliminate `U32.show`/`String.append` internal label formatting in `x187_pub` + rebalance split (`K=15..16`) -> **`<= 60 s` warm-cold** and **`<= 15 s` 1-module edit**.

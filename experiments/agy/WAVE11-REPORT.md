# Wave 11 Report: Pure-Bend Compiler Recovery (`3.17×–6.09×`), `K=13` Split & Native `n4_o2` (`2.20×` Faster 5-Core Self-Reproduction)

**Date:** 2026-11-23  
**Status:** **PASSED — ALL GATES VERIFIED**

## 1. Headline Achievements

1. **Wave 11 Pure-Bend Unified Compiler (`selfhost/build/agy/wave11_unified/{compiler.bend, api.mjs}`):**
   - Integrated all **8 pure-Bend upgrades** (P5-E scoped `nq_signature_user` `$product.*` recovery, P5-B `-O2` `p114r` modular fix, P5-A `m00` 2-fn match-bomb fix, P5-F `m04` 5-fn `-O2` cliff fix, P5-D `fast_iface_emit`, `String.order.go` borrow fast path, `--trace-slow <ms>`, W11-B `p113k_function` pure-leaf exemption).
   - Verified with **`0` type errors** (`8,808` defs), **`64/64 native64` PASS**, **`15/15` Observer Gate PASS**, and **`A -> B` `-O2` modular PASS** (`0` C, `0` `objcopy`, `0` link warnings).
   - **Compiled-program runtime recovery (`3.17×–6.09×` vs Wave 10, `1.02×–2.94×` vs Wave 8):**
     - `histogram`: **`41.38 ms`** native `n4_o2` (`58.47 ms` JS) vs `356.03 ms` Wave 10 (**`8.60×` / `6.09×`**)
     - `nbody`: **`93.99 ms`** native `n4_o2` (`94.64 ms` JS) vs `516.56 ms` Wave 10 (**`5.50×` / `5.46×`**)
     - `gameoflife`: **`457.80 ms`** native `n4_o2` (`447.24 ms` JS) vs `1,419.35 ms` Wave 10 (**`3.10×` / `3.17×`**; **`2.94×`** vs Wave 8)
     - `editdist`: **`22.00 ms`** vs `93.75 ms` Wave 10 (**`4.26×`**)
     - `bst`: **`31.00 ms`** vs `107.89 ms` Wave 10 (**`3.48×`**)

2. **`K=13` Acyclic Split (`k13_wave11/`) & Native `n4_o2` / `n5_w11` (`selfhost/build/agy/wave11-native-mod/`):**
   - Split `m00` into `m00a` (`148.2 KB`) + `m00b` (`148.1 KB`), eliminating the old `437.7 s` `m00` bottleneck (`m00a = 42.1 s`, `m00b = 55.7 s` natively — **`4.48×` faster**!).
   - All `13/13` `-O2` modules compiled cleanly (`64,900 / 65,532` FIDs, `0` `p114r` orphans, `m04` `-O2` regalloc cliff completely resolved) and linked cleanly (`63.68 MB`, `0` warnings).
   - **Exact `2/9,082` remaining `p113d` 0-arity stub finding (Wave 12 1-line follow-up):** Two 0-arity functions in `m07` (`w4g_live_base`, `x185_d_base`) emit only `T p111_FID_*` in `m07.o`, while `m08`/`m09` emit orphan weak `p113d_FID_*` `jmp self` stubs from `.p130`. Recompiling only `m08`/`m09` at `-O0` produced **`n4_o2` (`11/13` `-O2` + `m08, m09` `-O0`, `67.86 MB`)**, passing every native gate.
   - **100% Native 5-Core Cold Self-Reproduction (`n4_o2 -> n5_w11`, CPUs `0..4`, 0 JS, 0 C, 0 `objcopy`):**
     - **E2E wall time: `224.81 s` (`3m 45s`)** — **`2.20×` faster** than Wave 10's `493.54 s` (`4.27×` parallel scaling on 5 cores; `1.40×` single-core native speedup; `145.4 ms` native `x86-merge-obj` SHA-256 bit-identical to JS).
   - **Native Incremental 1-Module Body Edits on `n4_o2` (CPU `0`):**
     - **Leaf edit (`m11`):** **`33.37 s`** (`32.61 s` compile + `0.47 s` relink, `12/13` `.o` SHA-256 unchanged, live `stage=read_w11` & `out=34`).
     - **Mid-stack body-only edit (`m06`):** **`42.92 s`** (`42.13 s` compile + `0.47 s` relink; native `x86-iface` `47.50 s` proved `.p130` stamp UNCHANGED, `12/13` `.o` SHA-256 unchanged, `out=34`).
   - **Native `x86-iface` Speed (`n4_o2` on CPU `0`):**
     - `m00a` (`26.30 s`, `2.34×` vs JS), `m00b` (`26.34 s`, `2.05×` vs JS), `m01` (`53.06 s`, `2.27×` vs Wave 10 native), `m06` (`47.50 s`), all **SHA-256 bit-identical** to JS.
     - **Projected 5-core pipelined true-cold** (`CPU 0` `.p130` chain + `CPUs 1..4` module compiles): **`~585 s` (`~9.7 min`)**.

## 2. Artifacts & Provenance
- **W11-A Composition & Verification:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11a_compose/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11a_compose/results.json)
- **W11-C Native `n4_o2` & 5-Core Self-Reproduction:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11c_n4_o2/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11c_n4_o2/results.json), [run_w11c_n4_o2.py](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11c_n4_o2/run_w11c_n4_o2.py)
- **Published Binaries:** [n4_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n4_o2) (`67.86 MB`), [n5_w11](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n5_w11) (`86.56 MB`)
- **Preserved Cache:** `/tmp/agy_k13_w11_cache/{iface,obj_o0}` (`260 MB`, `/dev/md2` free = `6.3 GiB`)

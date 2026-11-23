# Experiment: W12-INT — Wave 12 Unified Pure-Bend Compiler Composition & `k14_wave12/` Split

- **Date:** 2026-11-23
- **Status:** **PROMOTED** (`selfhost/build/agy/wave12_unified/{compiler.bend, api.mjs}` + `research/agy/w10_mod_bend/k14_wave12/`)
- **Primary Report:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12_int_compose/REPORT.md)
- **Receipts:** [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12_int_compose/results.json), [compose_w12.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12_int_compose/compose_w12.py), [split_k14_w12.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12_int_compose/split_k14_w12.py)

## Hypothesis
All 9 independently verified Wave 12 / Wave 13 pure-Bend wins (W13-A Win #1, W11-C 0-arity CPS stub fix, W12-B `#U32` match, W12-E `x86-iface v2`, W12-A unboxed Bool & borrow-loop direct load, W12-D dual-array LCU & `W12FwdDrop`, W12-F boxed `Array.get`/`Array.set`, W12-G 7-family regalloc/peepholes, and W13-B compact `ctor2`/`take`/`rfc_check_fields` subset) compose cleanly onto `wave11_unified/compiler.bend` with zero soundness regressions, preserve lean `.o` sizes, fix the 0-arity CPS modular `-O2` stub bug, stack speedups on `terrain` and `hashmap`, and split cleanly into a balanced `K=14` acyclic module set (`m00a, m00b, m01..m04, m05a, m05b, m06..m11`).

## Key Results
- **Composition:** Clean 9-win composition (`3,523,878 B -> 3,607,289 B`, `+83,411 B`), `0` patch conflicts.
- **Soundness:** `--check-only` (`0` errors across `8,951` defs), `64/64 native64` PASS (`65.0 s`), `44+2` ABI + `15/15` Observer Gate PASS (`0` violations), and A -> B `-O2` modular test with 0-arity CPS (`b_zero_cps`) + 0-arity direct (`b_zero_direct`) PASS (`out=203`, `0` orphan weak `p113d_FID_` stubs, `0` link warnings).
- **Paired Interleaved Runtime (CPU `4`, `x86-object -O2`):**
  - `terrain`: `21.39 s -> 17.30 s` (**`1.236×`**)
  - `hashmap`: `7.03 s -> 5.85 s` (**`1.201×`**)
  - `editdist`: `22 ms -> 21 ms` (**`1.048×`**), `histogram`: **`1.006×`**, `nbody`: **`1.003×`**, `gameoflife`: `440.8 ms`, `bst`: `31 ms` (all checksums exact).
- **`K=14` Split:** `409` types, `9,225` defs, `898` laws (`0` lost, `0` dup, `0` forward cycles); `m00a=150.8 KB`, `m00b=150.6 KB`, `m05a=148.5 KB`, `m05b=147.2 KB`.

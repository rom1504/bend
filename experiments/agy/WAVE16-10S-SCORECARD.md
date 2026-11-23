# Wave 16 `<= 10 s` Cold Self-Compile Campaign Scorecard

## Composition & Verification Status
| Deliverable | Status | Artifact / Exact Metric |
|---|---|---|
| **8-Patch Unified Composition** (`S10-D`+`S10-E --no-lexer`+`S10-A`+`S10-C`+`S10-H`+`S10-F`+`S10-B`+`S10-G`) | **PASS** | [wave16_unified/compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend) (`3,497,142 B`, `82,253 lines`, `-9.74%` vs W15) |
| **`locked_bun.sh --check-only`** | **PASS** | **0 type errors, 0 linearity errors** (`9,127` `@unsafe` defs) |
| **Balanced Acyclic Splits (`K=10/16/24`)** | **PASS** | `K=10` `1.002x`, `K=16` `1.009x`, `K=24` `1.005x` (`0` lost/dup/cycles) |
| **Wave 16 Exact `p113d` Direct Oracle** | **PASS** | [p113d_oracle_w16.txt](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/p113d_oracle_w16.txt) (`2,574` direct defs; fixes `f_raw_skip` delta vs W15 oracle) |
| **`K=10` FID Budget (`n6_o2` bootstrap)** | **PASS** | `65,377 / 65,532` FIDs (`0` overlaps); `n7_o0` linked (`102.9 MB`, `merge=216.3 ms`, `link=498.6 ms`) |
| **`n7_o2` / `n7_o2_nodrop` Mint & 8-Core Cold Bench** | **READY** | Scripts ready ([mint_and_bench_w16.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/mint_and_bench_w16.py), [run_w16_k10.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/run_w16_k10.py)) — hit `21:58 UTC` hard deadline right after oracle extraction |
| **Zero-Regression Gate (`158/158` + 7-family proxy)** | **READY** | [run_w16_gate.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/w16_final/run_w16_gate.py) ready to execute immediately on `n7_o2` |

# Experiment: O2-B Loop-Gated `-O2` Fast Path (`o2b_classify_fn`)

- **Date:** 2026-11-24
- **Role:** O2-B (CPUs `2, 3`)
- **Decision:** **HOLD / DO NOT PROMOTE AS-IS** (preserved as falsified-hypothesis provenance + actionable root-cause data)
- **Artifacts:**
  - Patcher: [`research/agy/o2_50s/o2b_loop_gate/apply_o2b.py`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2b_loop_gate/apply_o2b.py)
  - Report: [`research/agy/o2_50s/o2b_loop_gate/REPORT.md`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2b_loop_gate/REPORT.md)
  - Raw Results: [`research/agy/o2_50s/o2b_loop_gate/results.json`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2b_loop_gate/results.json)

## Hypothesis
Bypassing `w7_post_select_full` on all `!hasBackEdge && !hasXmm && !hasRtOp` functions (including `<= 96`-item non-loop functions) using a single O(N) linear classifier `o2b_classify_fn` would cut `x187_priv` by `4–6×` with `0%` regression on the 7 proxy families + `terrain`.

## Experimental Evidence
1. **`--check-only` (`locked_bun.sh`):** `0` type errors, `0` linearity errors (`9,133` `@unsafe` notice).
2. **`compiler_slice.bend` (`-O2`, 3-run median, CPU 2, `n8_base` vs `n8_o2b`):**
   - `x187_priv`: `3,002.0 ms -> 3,069.0 ms` (`0.98×`)
   - `x187_pub`: `3,169.0 ms -> 2,782.0 ms` (`1.14×`)
   - `total`: `15,821.0 ms -> 15,479.0 ms` (`1.02×`)
3. **`terrain` `-O2` compile time:** `74,633.4 ms -> 50,546.1 ms` (**`1.48×`**).
4. **7 Proxy Families + `terrain` runtime (`-O2`, CPU 2, exact checksums verified on all 8):**
   - `expression`: `0.9875×`, `nbody`: `1.0014×`, `histogram`: `1.0018×`, `editdist`: `1.0025×`, `list`: `1.0051×`, `gameoflife`: `1.0141×`, `bst`: **`1.0267×`**, `terrain`: **`1.0363×`**.
5. **Qualification (`-O2`, CPUs `2, 3`):**
   - Live-Metadata Observer Gate: **`15/15 PASS`, `0` violations** (`25.92 s`).
   - `native64`: `57/64 PASS` (7 `(emit)` failures on `-O0`-built `n8_o2b` under 60s timeout).
6. **Baseline `k10_wave16/m09_zero.bend` `-O2` trace (`n7_o2`, CPU 3):**
   - `x187_priv` (451 fns) = `3,120 ms` (`2.5%`); **`x187_pub` (5,090 segs) = `64,317 ms` (`52.3%`)**; `x198pw_plan = 41,515 ms` (`33.8%`); `total = 122,863 ms`.

## Conclusion
- `wave16_unified/compiler.bend` already bypassed `w7_post_select_full` for `hasCall && !hasXmm && len > 96 && !hasLoop`. Extending the bypass to `<= 96`-item non-loop functions does **not** achieve `4–6×` on `x187_priv` (`0.98×` on `compiler_slice`) and introduces `+2.7%` (`bst`) / `+3.6%` (`terrain`) compiled-program regressions due to skipping leaf/GPR peepholes on small helpers.
- The true `-O2` backend bottlenecks to attack next are `x187_pub` (`64.3 s` on `m09`) and pre-`x191_frame_forward` `-O2` passes inside `x187_priv` (`x185_late_stmts`, `p117h_walk`, `x190_stmts`).

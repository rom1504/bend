# O2-B: Loop-Gated `-O2` Fast-Path Investigation (`o2b_classify_fn`)

**Status:** **Completed — Evaluated & Held (Do Not Promote As-Is)**  
**Patcher:** [`apply_o2b.py`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2b_loop_gate/apply_o2b.py) (clean & idempotent on both `selfhost/build/agy/wave16_unified/compiler.bend` and `k10_wave16/m08.bend`; `0` type/linearity errors under `locked_bun.sh --check-only`)  
**Evidence:** [`results.json`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2b_loop_gate/results.json)  
**Experiment Log:** [`experiments/agy/o2b-loop-gate.md`](file:///home/ai/bend2_agy/experiments/agy/o2b-loop-gate.md)

---

## Executive Summary

We implemented a single O(N) linear classifier (`o2b_classify_fn`) in `x191_frame_forward` / `w4_post_select` that computes `{hasXmm, hasNegRbp, hasLbl, hasImulq, hasCall, hasRtOp, hasBackEdge, gt96}` in one pass (replacing redundant `w4_peep_flat` + `w5_scan_flags` + O(N²) `w4b_find_loop` calls) and routes all `!hasBackEdge && !hasXmm && !hasRtOp` functions (including `<= 96`-item non-loop functions) to O(N) `w4_peep_list` cleanup while keeping 100% of `w7_post_select_full` untouched for `hasBackEdge || hasXmm || hasRtOp`.

### Key Measurements (Strict Apples-to-Apples `n8_base` vs `n8_o2b`, CPU 2, `ulimit -s 262144`)

| Metric | `n8_base` | `n8_o2b` | Ratio / Delta |
|---|---:|---:|---:|
| **`compiler_slice.bend` `-O2` Total** (3-run med) | `15,821.0 ms` | `15,479.0 ms` | **`1.02×`** (`-342 ms`) |
| — `x187_priv` (48 fns) | `3,002.0 ms` | `3,069.0 ms` | `0.98×` |
| — `x187_pub` (103 segs) | `3,169.0 ms` | `2,782.0 ms` | **`1.14×`** (`-387 ms`) |
| **`terrain` `-O2` Compile Time** | `74,633.4 ms` | `50,546.1 ms` | **`1.48×`** (`-24.1 s`) |
| **`nbody` `-O2` Compile Time** | `9,163.2 ms` | `8,569.1 ms` | **`1.07×`** |
| **`gameoflife` `-O2` Compile Time** | `12,742.4 ms` | `12,285.1 ms` | **`1.04×`** |

### Zero Compiled-Program Regression Check (7 Proxy Families + `terrain`, `-O2`, CPU 2)

All 8 benchmarks compiled, linked, and passed exact expected checksums; however, `.o` outputs differed on small (`<= 96`-item) non-loop helper functions:

| Benchmark | SHA-256 Match | Runtime Ratio (`o2b / base`) | Verdict |
|---|---|---:|---|
| `expression` | DIFF | **`0.9875×`** | Faster |
| `nbody` | DIFF | `1.0014×` | Parity |
| `histogram` | DIFF | `1.0018×` | Parity |
| `editdist` | DIFF | `1.0025×` | Parity |
| `list` | DIFF | `1.0051×` | Parity |
| `gameoflife` | DIFF | `1.0141×` | `+1.4%` |
| `bst` | DIFF | `1.0267×` | **`+2.7%` regression** |
| `terrain` | DIFF | `1.0363×` | **`+3.6%` regression** |

### Qualification Gates
- **`locked_bun.sh --check-only` (`compiler_o2b.bend`):** **PASS** (`0` type errors, `0` linearity errors; standard `9,133` `@unsafe` notice).
- **Idempotency (`apply_o2b.py`):** **PASS** (`ALREADY_APPLIED` on second run).
- **Live-Metadata Observer Gate (`-O2`, CPUs `2, 3`):** **`15/15 PASS`, `0` violations** (`25.92 s`).
- **`native64` Conformance (`-O2`, CPUs `2, 3`, 60s timeout on `-O0`-built `n8_o2b`):** `57/64 PASS` (7 `(emit)` failures on `-O0`-compiled `n8_o2b` due to 60s timeout / `s10h` dead-stub harness).

---

## Root-Cause Diagnosis (Why `x187_priv` Did Not Drop `4–6×`)

1. **`wave16_unified/compiler.bend` ALREADY bypassed `w7_post_select_full` for large non-loop functions** (`hasCall && !hasXmm && len > 96 && !hasLoop` in `x191_frame_forward`, lines 64834–64844).
2. **Extending the bypass to `<= 96`-item non-loop functions** gave `1.14×` on `compiler_slice` `x187_pub` and `1.48×` on `terrain` compile time, but **`0.98×` on `compiler_slice` `x187_priv`** — proving that the remaining `x187_priv` `-O2` time is NOT in `w4_post_select` on small non-loop functions, but rather in:
   - **Pre-`x191_frame_forward` `-O2` passes** (`x185_array_function`, `p117h_walk`, `x185_late_stmts`, `x185_prepare_body`, `x190_stmts` instruction selection), AND
   - **Functions WITH `hasBackEdge`** (tail-recursive loops in the compiler itself) that still run full `w7_post_select_full`.
3. **Why `bst` (`+2.7%`) and `terrain` (`+3.6%`) regressed:** Small (`<= 96`-item) non-loop helper functions (especially leaf helpers with `!hasCall`) lost `w4_leaf_shrink`, `w5b_run_leaf_promote`, and `w5c_gpr_peep_c`.
4. **Baseline `m09_zero.bend` `-O2` stage breakdown (`n7_o2`, CPU 3):** `read=33 ms`, `prep=248 ms`, `p86_plan=11,039 ms`, `x198pw_plan=41,515 ms`, `x187_priv=3,120 ms` (451 fns), **`x187_pub=64,317 ms` (5,090 segs!)**, `x187_elf=2,394 ms`, `total=122,863 ms`. Notice `x187_pub` (not `x187_priv`) is the dominant backend stage on `k10_wave16/m09` (`52.3%` of total compile time!).

## Recommendation
**Do not promote** the `<= 96`-item non-loop bypass as-is (misses `4–6×` `x187_priv` target and adds `+2.7%`–`+3.6%` on `bst`/`terrain`). Instead:
1. Keep `o2b_classify_fn` (single-pass O(N) back-edge + flag classifier) as a clean replacement for O(N²) `w4b_find_loop` when gating `> 96`-item non-loop functions (0% compiled-program regression!).
2. Target the **actual** `-O2` self-compile killers: `x187_pub` (`64.3 s` on `m09`, driven by `x193f_public` + `x181_function` on 5,090 CPS segments) and pre-`x191_frame_forward` IR passes in `x187_priv` (`x185_late_stmts`, `p117h_walk`, `x190_stmts`).

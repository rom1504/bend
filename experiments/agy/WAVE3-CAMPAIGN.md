# Wave 3 Campaign — Correctness Confidence (Fuzzing + Lean Laws + Observer) & 10× Self-Compilation Speedup

- **Branch**: `selfhost/agy` (starting from audited checkpoint `78009428`)
- **Start Time**: `2026-11-22 02:21 UTC` (1-hour budget)
- **Starting Baseline (`78009428`)**:
  - Generated-program speed (`native45`): **`0.4527×` C fixed-work batch** (`4.583 s` vs `10.125 s` C), **`0.2006×` C geomean** (`0.3118×` Non-CTFE 40)
  - Conformance: `134/134` hosted-B1 + `132/132` native `N2` + `6/6` Base-pin regression + `180/180` Codex pinned-Base differential panel
  - Self-compile speed (`N2 → N3` on `2.47 MB` `compiler.bend`, CPU 2, 1 thread): **`496.86 s`** (target: push as far toward **~30–100 s** as possible without regressing `0.4527×` C!)

## 4 Parallel Wave 3 Tracks

| Track | Role | Target | Report |
|---|---|---|---|
| **Track Q1** | `Differential Fuzzer & Bug Hunter` | 200+ random grammar-based differential programs (`upstream == Phase205 == Wave2`) across all 7 pass families + `observer.c` live-metadata gate on Wave 2 fast paths | `experiments/agy/wave3-fuzz-correctness.md` |
| **Track Q2** | `Lean 4 Algebraic Laws Engineer` | Machine-checked Lean 4 proofs for `AGY-001` (`bf_linearize`), `AGY-005b` (`absorbing`), `AGY-W2B-DEADARR`, `W2D` `U32` intervals, `AGY-005a` (`ctfe_as_nat` guard) | `experiments/agy/wave3-lean-laws.md` |
| **Track S1** | `Self-Compile Profiler & Algo Killer` | Profile `N2 → N3` (`497 s`), eliminate O(N²)/redundant book scans (`CTFE`/`W2D`/`p114h`/`lookup`/`x187`), preserve bit-identical `native45` | `experiments/agy/wave3-selfcompile-algo.md` |
| **Track S2** | `Self-Compile Hot-Loop & Runtime Optimizer` | Optimize hottest `N2` compiler loops (`index_get`, `String`, `KTerm`, `x188`/`x187` ELF emit, `runtime-agy.o`) while preserving `44/44 ABI` + `0.4527×` C | `experiments/agy/wave3-selfcompile-hotloops.md` |

## Progress Log
- `02:21 UTC`: Launched Wave 3 Tracks Q1, Q2, S1, S2 in parallel.
- `02:29 UTC`: **Track Q2 COMPLETE** (`experiments/agy/wave3-lean-laws.md`): **17 exported Lean `v4.32.0` theorems** machine-checked in `research/agy/wave3_lean/Wave2Laws.lean` (exit 0, zero warnings, zero `sorry`, standard axioms only) covering `AGY-001` (`bf_linearize`), `AGY-005b` (`absorbing`), `AGY-W2B-DEADARR`, `W2D` `U32` intervals, and `AGY-005a` (`ctfe_as_nat` guard).
- `02:56 UTC`: **Track Q1 COMPLETE** (`experiments/agy/wave3-fuzz-correctness.md`, `wave3-fuzz-report.json`):
  - **Differential Fuzzer**: **245 / 245 PASS** (`0` wrong-code mismatches across all 7 pass families, `upstream == Wave 2 Unified`).
  - **Live-Metadata `observer.c` Gate**: `44+2/46` ABI/observer + `15/15` boot-time probes PASS; **caught `Q1-BUG-001` (live)** in `agy_map_del_machine` (missing `!cid_hot[mnode]` check) + **`Q1-BUG-002` (latent)** in `apply_list_arr.py`.
- `03:00 UTC`: **Q1-BUG-001 & Q1-BUG-002 FIXED & VERIFIED**: Patched `research/agy/wave2c_map/apply_map_fast.py` and `research/agy/wave2c_recagg/apply_list_arr.py`, recomposed `wave2_unified`, verified `repro_mapdel_livehot` (`violations=0`, down from `2`) and `observer_wave2_gate.py` (`44+2/46` ABI/observer + `15/15` live-metadata probes PASS).
- `03:10 UTC`: **Track S1 COMPLETE** (`experiments/agy/wave3-selfcompile-algo.md`): Full 505 s `SIGPROF` profile of `N2 → N3` proved there is no single O(N²) bug — cost is flatly in C runtime (`44.8%`, 226 s), cons-list `String` eq/hash (`24.8%`, 125 s), and single-threaded `x181`–`x190` codegen (`34%`, 170 s). `apply_sc_algo.py` (8 algorithmic opts) verified `19/19 focused19` + `9/9 BIT-EXACT` on hosted B1 and cut `505.00 s → 485.47 s` (`-3.9%`, eliminating `String.order.go` 100%).
- `03:14 UTC`: **Track S2 COMPLETE** (`experiments/agy/wave3-selfcompile-hotloops.md`): `build_rt_w3.py` (`runtime-opt-w3.o`) + `apply_sc_hot.py` (`C1`–`C4`) delivered **`1.65×` faster full `compiler.bend` self-compile** (`810.40 s → 489.93 s`, same host load, **`EXACT_FIXED_POINT=True`**, `1.26×` on 5-case small proxy), while passing `71/71` ABI exports, `44/44 abi-contract.c` + `2/2 observer.c`, `65,888/65,888` sqrt, `19/19 focused19`, `10/10` adversarial, and **`0.9663×` geomean (`-3.4%` faster)** on `native45` user benchmarks.

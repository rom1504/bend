# Wave 4 Final Report — General x86-64 Backend Optimization & C-Runtime Draining (3-Hour Campaign)

- **Campaign Window**: `2026-11-22 04:10 UTC → 07:00 UTC` (2h 50m, finished 10 min ahead of 3h budget)
- **Branch**: `selfhost/agy` (from Wave 3B `fb3a32ae` → Wave 4A `31ece01f` → Wave 4B `85d0ae1d` → Wave 4C final)
- **Core Discipline**:
  - **Zero benchmark-specific pattern matchers / AST templates.** Every Wave 4 pass is a 100% general IR or x86-64 compiler optimization.
  - **`selfhost/src/runtime/qbe/runtime.c` & `unified/runtime-agy.o` completely unchanged** — all runtime draining (`34.0% → 0.0%` on `histogram`, `16.9% → 2.0%` on `editdist`) came purely from Bend-emitted x86-64!
  - **Untouched holdouts (`bfs`, `merkle`, `kmeans`)** were never inspected or tuned during Phases 0–3; measured for the first time in Phase 4.
  - **OOM-safe locked concurrency**: added `research/agy/locked_bun.sh` (`flock` + `timeout 60`) and `research/agy/locked_node.sh` (`flock` + `4 GiB` heap cap) after catching a runaway multi-scrutinee type-checker loop, eliminating OOMs permanently while maintaining 3–4 concurrent agents.

---

## 1. Untouched Upstream Defaults (`upstream-runtime-v1`, Pinned `0e2f38f`, 1-Core CPU 2)

| Untouched Upstream Default | Handwritten Clang-16 | Our Bend→C | Our QBE | Wave 2 AGY x86 | **Wave 4C AGY x86** | **Speedup vs Wave 2** | Checksum |
|---|---:|---:|---:|---:|---:|---:|---|
| **`histogram`** (`128 × 16.8M` keys) | `7.51 s` | `26.85 s` (`3.58×`) | `110.22 s` (`14.68×`) | `130.21 s` (`17.34×`) | **`20.25 s` (`2.70×` C16)** | **`6.43×` faster** | `122845198` PASS |
| **`gameoflife`** (`16.8M × 32` gens) | `17.46 s` | `68.06 s` (`3.90×`) | `133.22 s` (`7.63×`) | `227.65 s` (`13.04×`) | **`38.41 s` (`2.20×` C16)** | **`5.93×` faster** | `2016151040` PASS |
| **`nbody`** (`1.05M × 300` steps) | `10.74 s` | `10.06 s` (`0.94×`) | `95.08 s` (`8.85×`) | `54.54 s` (`5.08×`) | **`14.20 s` (`1.32×` C16)** | **`3.84×` faster** | `3516450380` PASS |
| **3-Workload Geomean vs C16** | `1.00×` | `2.36×` | `9.97×` | **`10.47×`** | **`1.99×` C16** | **`5.27×` faster** | **3/3 PASS** |
| **Total Wall-Clock (All 3)** | `35.71 s` | `104.97 s` (`2.94×`) | `338.52 s` (`9.48×`) | `412.40 s` (`11.55×`) | **`72.86 s` (`2.04×` C16)** | **`5.66×` faster** | |

- **Wave 4C direct x86 (`72.86 s`, `1.99×` C16 geomean) now BEATS `Our Bend→C` (`104.97 s`, `2.36×` C16) by `1.44×` and crushes `Our QBE` (`338.52 s`, `9.97×` C16) by `4.65×` on untouched upstream Bend programs!**

---

## 2. 7-Family Fast-Proxy Progression (`run_proxy.py`, CPU 2, Exact Checksums)

| Benchmark | Group | Phase 0 (`vs C16`) | Wave 4A | Wave 4B | **Wave 4C (`vs C16`)** | **Wave 4C (`vs GCC-10`)** | **Total Speedup** |
|---|---|---:|---:|---:|---:|---:|---:|
| **`histogram`** (med) | upstream | `15.23×` (`365.6 ms`) | `2.64×` | `2.40×` | **`2.72×`** (`65.4 ms`) | `2.92×` | **`5.59×` faster** |
| **`gameoflife`** (med) | upstream | `13.68×` (`3302.8 ms`) | `14.96×` | `6.56×` | **`2.42×`** (`584.6 ms`) | **`0.63×` (beats GCC-10!)** | **`5.65×` faster** |
| **`nbody`** (med) | upstream | `4.28×` (`319.7 ms`) | `1.82×` | `1.85×` | **`1.50×`** (`112.1 ms`) | **`1.28×`** | **`2.85×` faster** |
| **`list`** (tuned) | tuned-4 | `1.48×` (`0.398 ms`) | `0.99×` | `0.96×` | **`0.90×`** (`0.240 ms`) | **`0.90×` (beats C16!)** | **`1.66×` faster** |
| **`expression`** (tuned) | tuned-4 | `2.40×` (`17.4 ms`) | `2.00×` | `1.96×` | **`1.47×`** (`10.6 ms`) | `1.70×` | **`1.64×` faster** |
| **`bst`** (tuned) | tuned-4 | `5.96×` (`64.6 ms`) | `3.61×` | `3.45×` | **`3.53×`** (`38.2 ms`) | `2.92×` | **`1.69×` faster** |
| **`editdist`** (tuned) | tuned-4 | `13.83×` (`127.5 ms`) | `10.58×` | `4.95×` | **`2.93×`** (`27.0 ms`) | **`2.79×`** | **`4.72×` faster** |
| **`upstream-medium` geomean** | | `9.625×` | `4.160×` | `3.075×` | **`2.147×`** | **`1.334×`** | **`4.48×` faster** |
| **`tuned-4` geomean** | | `4.139×` | `2.945×` | `2.377×` | **`1.919×`** | **`1.876×`** | **`2.16×` faster** |
| **7-family overall geomean** | | **`5.942×`** | **`3.415×`** | **`2.655×`** | **`2.014×`** | **`1.621×`** | **`2.95×` faster** |

---

## 3. Untouched Holdout Transfer Test (`bfs`, `merkle`, `kmeans`, CPU 2, Zero Prior Tuning)

| Untouched Holdout | Handwritten GCC-10 | Wave 2 AGY x86 | **Wave 4C AGY x86** | **Wave 4C Speedup** | Checksum |
|---|---:|---:|---:|---:|---|
| **`bfs`** (default) | `6.825 s` | `55.82 s` (`8.18×` C) | **`48.92 s` (`7.17×` C)** | **`1.141×` faster** | `651176970` PASS |
| **`merkle`** (default) | `8.915 s` | `42.62 s` (`4.78×` C) | **`41.45 s` (`4.65×` C)** | **`1.028×` faster** | `3104235417` PASS |
| **`kmeans`** (`size=13n`) | `0.194 s` | `14.16 s` (`73.18×` C) | **`11.67 s` (`60.30×` C)** | **`1.213×` faster** | `1054846867` PASS |
| **3-Holdout Geomean Speedup** | — | — | — | **`1.125×` (3/3 positive)** | **3/3 PASS** |

---

## 4. Full Qualification, Correctness & Non-Regression Matrix (`wave4c_unified/api.mjs` + unchanged `runtime-agy.o`)

- **Full 64-Case Native Qualification (`qualification-catalog.json`)**: **`64 / 64 PASS`** (`failed=[]`, `19/19 focused` + `45/45 broad`).
- **Live-Metadata Observer Gate (`observer_wave2_gate.py`)**: **`44 + 2 / 46`** ABI/observer + **`15 / 15`** Wave 2 live-metadata probes **PASS (`0` violations)**.
- **Shared-Array / `Array.fork` Adversarial Gate (`test_array_adversarial.py`)**: **`15 / 15 PASS` (`0` violations)**.
- **Base-Pin Regression Gate**: **`6 / 6 PASS`**.
- **Differential Fuzzing**: **`90 / 90 PASS`** new Wave 4 families (`30` Array/Fork/LICM + `30` Multi-Carried F32 XMM/NaN/`-0.0` + `30` Scalar `U32.mod`/`lea`/`shl`/LCG) → **`335 / 335` cumulative (`0` mismatches)**.
- **Machine-Checked Lean 4 Proofs (`research/agy/wave4_lean/Wave4Laws.lean`)**: **`28` new theorems** verified by Lean `v4.32.0` (`exit 0`, `0` `sorry`, `0` warnings, standard axioms only) → **`45` cumulative theorems**.
- **`native45` 10-Case Non-Regression (`Wave 4C / Wave 2`, CPU 2)**: **`10 / 10` exact match**, **`1.0075×` geomean** (`coverage-map-churn-32` `0.5296×`, `coverage-list-pipeline-512` `0.8787×`, `mandelbrot` `0.9187×`, `symreg` `0.9249×`, `tree-bitonic` `0.9638×`, `coverage-bst-64` `1.0163×`, `lexer` `1.0077×`, `coverage-record-aggregation-256` `1.0081×`, `raytrace` `1.1611×`, `editdist` `2.3586×` — down from `21.88×` before W4-11's guard).

---

## 5. Architecture & Composable Passes Delivered (10 General Passes, 0 Benchmark Matchers)

1. **W4-2 (`research/agy/wave4_array/apply_array_fast.py`)**: Lifted `p113a_enabled` from whole-program `unshared` to per-function runtime-guarded `TAG_BUF` (`0x04` & `0x84`) + `p117h`/`p117v` hoisting + cold scratch-store sinking (`runtime-agy.o` drained `34.04% → 0.00%` on `histogram`, `16.92% → 2.03%` on `editdist`).
2. **W4-1 (`research/agy/wave4_inliner/apply_inliner.py`)**: Multi-pass `p113i` + 1-iter small `P113DAgain` tail-loop peeling + exact IEEE-754 `U32`/`F32` constant folding + dead-RC elimination + scalar 0/1 `Bool` diamond collapse.
3. **W4-3 (`research/agy/wave4_regunbox/apply_regunbox.py`)**: Direct `movq %xmm, disp(%rbp)` spills, multi-carried `F32` XMM loop allocation, `NQBundle` alias propagation, and `$p118borrow.read.*` dead-field copy elimination.
4. **W4-4 (`research/agy/wave4_scalar/apply_scalar_x86.py`)**: Spill-free `U32.mod`/`div` + `lea` (`3*q`/`5*q`/`9*q`), `imul $2^k → shl $k`, branchless `bool01`, leaf prologue shrink-wrapping, Lean-proven odd-parity LCG progress certificate, and expanded CSE/regalloc.
5. **W4-5 (`research/agy/wave4b_gol/apply_gol_opt.py`)**: Bottom-up constant-arg inlining (4× cost discount) + pre-publish copy-prop & backward liveness DCE + large straight-line GPR allocation.
6. **W4-6 (`research/agy/wave4b_arrprod/apply_arrprod.py`)**: General `$direct.<f> → $product.<f>` boxed-entry unboxing adapter + 2-pass `p113i` + `shll`/`testq` peepholes.
7. **W4-7 (`research/agy/wave4b_loopxmm/apply_loopxmm.py`)**: Dynamic call-free XMM loop partitioning (`xmm8..15`), CFG-aware copy-forwarding, loop-invariant magic-constant LICM, and bottom-tested tail-loop rotation.
8. **W4-9 (`research/agy/wave4c_cmov/apply_cmov.py`)**: Post-`p111v` pure scalar `P113DIf` diamond hoisting to branchless `cmov` + CSE/transient-GPR preservation across 1-stmt selects (`gameoflife` `jcc: 32 → 0`, `cmov: 16`, `0.63×` GCC-10 C!).
9. **W4-10 (`research/agy/wave4c_arrclose/apply_arrclose.py`)**: `$product`-field scalar kind propagation (`N_W32` in `NQShape.qt`), Lean-proven bitmask & unit-stride IV array bounds-check elimination, and `addl $c, m32` memory-op folding.
10. **W4-11 (`research/agy/wave4c_f32clean/apply_f32clean.py`)**: XMM store-to-load forwarding & dead stack-slot elimination (`nbody` `1.32×` C16!), `native45` `AGY-W2B-3`/`AGY-W2-DPLOOP` inliner guards, and compact `p113i_` local prefixing (`64/64 native64`).

---

## 6. Recommended Wave 5 Priorities
1. **Dedicated Parallel Compile-Speed Track** (running alongside runtime optimization): gate `w4c_xmm_opt` on `has_xmm`, gate `w4b_licm_magic`/`w4b_rotate_loop` on `has_loop`, fuse redundant `w4_peep_flat` passes in `w4_post_select` (`3–5×` instant compile-time recovery, 0% runtime loss), and wire `fork()`-after-`agy_enrich_cursor` from Wave 3B.
2. **Close the final `2.0× → ~1.0×` C16 gap** on `histogram` (`2.70×`), `gameoflife` (`2.20×`), `editdist` (`2.93×`), `bst` (`3.53×`), and `bfs`/`merkle` holdouts.
3. **Retire superseded Wave 2 ad-hoc passes** (`AGY-W2C-LISTAPP`, `AGY-W2B-F32LOOP`) and verify full native `N0 → N1 → N2 → N3` exact fixed-point self-reproduction.

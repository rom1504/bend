# AGY-001 · General Binary-Fork `Nat`-Depth `U32.add` Reduction Linearization

- **Status**: **Verified & measured win (all 45/45 `native45` oracles pass)**
- **Artifacts**:
  - Bend pass: `research/agy/bf_linearize.bend`
  - Applier: `research/agy/apply_bf.py`
  - Full 45-case benchmark harness: `research/agy/bench_all44.py`
  - Full 45-case results (`AGY-001` + `AGY-002`): `selfhost/build/agy/full44-bf01-rt01/summary.json`

## Mechanism
Recognizes any pure, safe checked Bend definition `f(d: Nat, x: U32, a_1..a_k) -> U32` where `0n => BASE` and `1n+p => let a = f(p, x, a...); b = f(p, x + (STEP << p), a...) in a + b`, and rewrites it into:
1. `f$agy_orig`: renamed original fallback for `d >= 32n`.
2. `f$agy_bf(rem: Nat, x: U32, acc: U32, a...) -> U32`: checked tail-recursive `Nat` loop (lowers to a flat `p113d` register loop with zero continuation frames or scheduler transitions).
3. `f$agy_disp` + `f`: guarded by `Nat.sub(d, U32.to_nat(31))` so `d <= 31n` runs `f$agy_bf` and `d >= 32n` falls back to `f$agy_orig`.
All generated definitions pass `check_definition_body`, `ka_def`, and `jl_checked_error`.

## Measurements (CPU 2, alternating rounds, exact stdout verified on 45/45 cases)
- **Isolated `AGY-001` (`bf01-screen7`, same `runtime-live-scan.o`, 4 rounds)**:
  - `raytrace`: `959.0 ms → 307.5 ms` (**0.321×**, **3.12× faster**)
  - `mandelbrot`: `540.0 ms → 288.5 ms` (**0.534×**, **1.87× faster**)
- **Combined `AGY-001` + `AGY-002` (`runtime-opt.o`), full 45-case `native45` suite (3 rounds)**:
  - **All 45 / 45 oracles PASSED** (including `scalar-region-0` zero-work control).
  - **Geomean cand/base (44 timed)**: **0.9045× (−9.55%)**
  - **Geomean vs mature Bend C**: `0.941×` → **0.8514× C**
  - **Fixed-work batch vs C**: `1.547×` (`15.667 s`) → **1.3930× C** (`14.103 s` vs `10.125 s` C, **−1.564 s**)
  - **Cases > 2× C**: `15 / 44` → **10 / 44** (`raytrace` `1.643× → 0.501× C`, `mandelbrot` `2.010× → 1.097× C`, `lexer` `2.014× → 1.734× C`, `test-rle-roundtrip` `2.309× → 1.965× C`, `coverage-unicode-text-16/64` `0.965× / 0.908× C`).

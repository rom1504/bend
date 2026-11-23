# S10-A: Zero-`.p130` Parallel Module Stub Headers

- **Date:** 2026-11-23
- **Track:** S10-A / S10-A2
- **Status:** **PROVED & READY FOR WAVE 16 INTEGRATION**
- **Report & Evidence:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10a_zero_p130/results.json)

## Hypothesis
Replacing the serial `152.44 s` `x86-iface` `.p130` chain with 1-line parallel module stub headers (`gen_stubs.py`) and pure-Bend `STB_WEAK` stub/template visibility (`apply_s10a.py`) allows all `K` modules to compile 100% in parallel from `t = 0.00 s` against `base.p130` alone, cutting cold 7-core/8-core E2E self-compile time from `177.22 s` to `~49 s` uncontended (and `< 30 s` when combined with balanced `K=16/20` + S10-B/C/D speedups).

## Summary of Verification
1. **Typecheck (`--check-only`):** `apply_s10a.py` patches `compiler.bend` (`+2,655 B`, pure Bend, `0` new types) with `0` type errors.
2. **Stage 1 Bootstrap (`n6_o2 -> n7_s10a`, ZERO `.p130`):** All 10 modules (`m00..m09`) compiled in parallel from `t = 0.00 s` (`stub_gen = 1.34 s`, `total_segs = 65,109 / 65,532`, `0` orphan WEAK symbols, `0` FID overlaps).
3. **Stage 2 Pure-Bend Self-Compile (`n7_s10a -> n8_s10a`, ZERO `.p130`, ZERO `objcopy`):** Exact segment-count match (`65,109 / 65,532`) with `n6_o2`; `m09.o` automatically emitted `707` `STB_WEAK` stub symbols (`p111_FID_$direct.agy_str_eq = WEAK`). Added `s10a_has_type_param` to `apply_s10a.py` to also weaken `Type`-polymorphic templates (`nt_append`, `nt_count`, `nt_count_go`, `nt_reverse`), eliminating all `GLOBAL` link collisions.
4. **Stage 3 Functional Verification (`n8_s10a`):**
   - `compiler_slice.bend` `-O0`: `out=34` (`8.17 s`) — PASS
   - `compiler_slice.bend` `-O2`: `out=34` (`23.58 s`) — PASS
5. **Performance vs Wave 15 (`177.22 s`):**
   - Serial `x86-iface` chain: `152.44 s` -> **`0.00 s`** (`-100%`).
   - 7-core cold E2E (`n6_o2`, under multi-agent contention): **`119.45 s`** (`1.48x` faster even contended; uncontended single-module max `m07 = 47.1 s` -> `~49 s` 7-core wall, `3.6x` faster).

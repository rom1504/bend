# Experiment O2-E: `x187_priv` / `x187_pub` Core Codegen (`x181` / `x185` / `x187_encode`) & `-O2 --nodrop`

- **Date**: 2026-11-24
- **Owner**: O2-E (CPUs 6, 7)
- **Patch**: [`research/agy/o2_50s/o2e_priv_core/apply_o2e.py`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2e_priv_core/apply_o2e.py)
- **Report & Data**: [`REPORT.md`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2e_priv_core/REPORT.md), [`results.json`](file:///home/ai/bend2_agy/research/agy/o2_50s/o2e_priv_core/results.json)

## Hypothesis
1. Direct-to-`X187Build` fast-path encoding for the top-15 x86-64 opcodes in `w7c_fast_inst_c` (100% bit-identical to `x187_encode`), eliminating redundant loop analysis (`x191_loop_reads`, 2-pass `x190_l_fixed`) on non-loop functions in `x190`/`x185`, and routing cold public segments (weak cross-module stubs & `is_direct == True` wrappers) through `s10c_pub_emit_fast` will accelerate `-O2` codegen with zero runtime regression.
2. Enabling `--nodrop` during `-O2` compilation will materially reduce `-O2` compile wall time while keeping peak RSS bounded.

## Evidence
- `apply_o2e.py` applies idempotently to `selfhost/build/agy/wave16_unified/compiler.bend` with **0 type/parse errors** under `--check-only`.
- **`n7_o2 --nodrop` on `m09_zero.bend -O2`**: `137,452 ms -> 90,035 ms` (**`1.53×`** faster, `-47.4 s`), peak RSS `468.5 -> 451.7 MiB` (`x187_priv` `1.64×`, `x187_pub` `1.64×`, `x198pw_plan` `1.53×`).
- **`n7_o2 --nodrop` on `compiler_slice.bend -O2`**: `5,273.6 -> 4,764.3 ms` (**`1.11×`** faster), peak RSS `104.2 -> 104.4 MiB` (`x187_priv` `1.44×`, `x187_pub` `1.14×`).
- **Critical profile finding**: `x187_pub` accounts for **84,657 ms (61.6%)** of `m09 -O2` compile time due to running full 12-pass `-O2` on weak stubs and `is_direct == True` wrappers; O2E-3 directly targets this.
- **A/B on `-O0`-minted `n8_base` vs `n8_o2e` (`compiler_slice -O2`)**: `15,943.0 -> 15,755.8 ms` (`14,877.1 ms` with `--nodrop`), output `34` verified. Full 64/64 + 15/15 + 8-benchmark gate awaits Wave 17 composition with O2-C (which fixes Wave 16's `x198o_progress_get` hang and S10-H cross-module `p113d` stub omission).

## Decision
**PROMOTE `apply_o2e.py` + `--nodrop` for Wave 17 `-O2` composition** alongside O2-A, O2-B, and O2-C, and run the unified qualification + 8-benchmark gate on the composed Wave 17 compiler.

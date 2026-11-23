# Experiment: S10-E — `p86_plan` Frontend Speedup

- **Date:** 2026-11-23
- **Hypothesis:** Eliminating redundant annotation/validation/check/parse work inside `p86_plan` (`annotate` 39.5%, `parse` 32.5%, `check` 22.5%, `glue` 5.5% on `m09_zero.bend`) can cut `p86_plan` by `2.5–3×` without regressing `-O2` codegen or soundness.
- **Patcher:** [apply_s10e.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10e_fast_p86/apply_s10e.py)
- **Report:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10e_fast_p86/REPORT.md)
- **Results:** [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10e_fast_p86/results.json)
- **Status:** `--check-only` PASS (`0` errors across `9,399` `@unsafe` defs), 5 touched `k10` modules compiled & linked cleanly; runtime A/B and `64/64 native64 -O0` + `15/15 Observer -O0` handed off to W16-INT (recommend testing the 9 non-lexer hunks first and isolating the 4 lexer hunks due to `live`-mode `prep` timeout observed on `tiny.bend`).

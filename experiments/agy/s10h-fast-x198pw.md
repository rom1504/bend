# S10-H: Fast `-O0` `x198pw_plan_fast` Lowering

## Hypothesis
Cutting redundant lowering work inside `x198pw_plan_fast` (`-O0` only) — specifically eliminating S10-A zero-`.p130` stub lowering (`559–1,303` stubs/module), skipping `-O2` `p126sc_candidates` mutual-recursion fusion, using O(1) `bangMap` in `p167ob_remaining`, and filtering direct stubs out of `p112s_prepare` — will substantially reduce `x198pw_plan_fast` without regressing `-O2` or overflowing 16-bit FIDs.

## Rejected Hypothesis: Pure CPS (`--abi cps` / Skipping `p113d_passes`)
- **Result:** **REJECTED** (`1.4×–4.4×` slower in `x198pw_plan` + `data width overflow` on `m04` at `6,872` segments).
- **Evidence:** Direct `n6_o2 --trace x86-module-fast` runs on `k10_wave15` `m01..m08` in `research/agy/s10_campaign/s10h_fast_x198pw/results.json`.

## Implemented Patch
- **Patcher:** `research/agy/s10_campaign/s10h_fast_x198pw/apply_s10h.py` (stacks cleanly after `apply_s10a.py` + `apply_s10c.py`, self-contained in `m09`, `-O0` only).
- **Verification:** `locked_bun.sh --check-only` PASS (`0` type errors, `0` linearity errors, `9,404` `@unsafe` defs); idempotency PASS.
- **Next Step:** Run full A/B timing + `64/64 native64 -O0` + `15/15 Observer -O0` during Wave 16 Integration.

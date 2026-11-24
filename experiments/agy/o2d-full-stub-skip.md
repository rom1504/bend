# Experiment: O2-D Full Zero-`.p130` Stub Skip + `K=16`/`K=24` `-O2` Enabler

- **Date:** 2026-11-24
- **Owner:** O2-D (CPU 5)
- **Hypothesis:** Skipping `p111` CPS lowering + `p164a_segment` wrapper generation + `x187_pub` machine-code emission for S10-A zero-`.p130` stubs (in BOTH `-O0` and `-O2`), extending `S10-H` direct-stub skip into `-O2` (`p168_request_mode` + `p169a_view`), and replacing dead synthetic `.exp` currying `P167Factory` chains with direct worker demands will eliminate stub `WEAK` codegen, fix W16-MINT Finding #3 (`p111_FID_$direct.<stub>` → `p113d_FID_$direct.<stub>` mismatch), and unlock `K=16`/`K=24` well below the 65,532 16-bit FID cap.
- **Patch:** [apply_o2d.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2d_full_stub_skip/apply_o2d.py)
- **Report & Evidence:** [REPORT.md](file:///home/ai/bend2_agy/research/agy/o2_50s/o2d_full_stub_skip/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/o2_50s/o2d_full_stub_skip/results.json)

## Correctness & Measurement Summary
- **`--check-only`:** PASS (`0` type errors, `0` linearity errors across `9,146` `@unsafe` defs; idempotent).
- **Smoke (`compiler_slice.bend` on `-O0`-minted `n8_o2d`):** `-O0` PASS (`out=34`, `377,176 B`), `-O2` PASS (`out=34`, `388,208 B`).
- **Measured ELF Symbol & Segment Reductions (`n7_o2` vs `n8_o2d`):**
  - `k10/m09` (`-O0`): `p111_def` `5,076` → `3,660` (`-27.9%`), `p111_und` `0` → `859`, `p111_weak_def` `895` → `36` (`-96.0%`), `p113d_und` `303` → `0`, `segs` `5,076` → `4,519` (`-11.0%`), normalized `x187_elf` `1.98×` faster.
  - `k16/m09` (`-O0`): `p111_def` `5,017` → `4,143`, `p111_und` `0` → `555`, `p111_weak_def` `584` → `29` (`-95.0%`).
  - `k16/m15` (`-O0`): `segs` `3,197` → `2,780` (`-13.0%`), `p111_def` `3,197` → `2,187` (`-31.6%`), `p111_und` `0` → `593`, `p111_weak_def` `624` → `31` (`-95.0%`).
- **Base Deduplication Audit:** Base `WEAK` segments are only `29–47` per module (`~500–900` total across `K=16`/`K=24`), so Base dedup is unnecessary; the dominant FID cost is synthetic `.exp` currying factories (`5,584` in `K=16`, `6,022` in `K=24`), targeted by `o2d_exp_main_dispatch`.
- **Promotion Decision:** Ready for Wave 17 (`n8_o2`) composition and full `-O2` mint verification on `K=10`/`K=16`/`K=24`.

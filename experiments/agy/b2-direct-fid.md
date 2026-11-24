# B2: Direct-Only FID Omission & Explicit Cross-Module Contracts

- **Status:** Verified (`--check-only` `0` errors, `n8_b2` minted, `compiler_slice.bend` `-O0`/`-O2` `out=34`, decisive cross-module contract suite 100% PASS in `-O0` and `-O2`).
- **Artifacts:**
  - Patch: [apply_b2.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/apply_b2.py) (`+6,838 B`, `0` new types, idempotent, self-contained across module splits)
  - Test Suite: [test_b2_contracts.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/test_b2_contracts.py)
  - Full Report & Data: [REPORT.md](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/REPORT.md), [results.json](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/results.json)

## Summary of Findings
1. **Explicit Cross-Module Contracts & Direct-Only FID Omission:** Replaced `o2d_is_exp_main_go` / `o2d_exp_main_dispatch` in `p167l_dispatch` with `b2_is_exp_main_go` / `b2_exp_main_dispatch` supporting defining-module contracts (`_d*` direct-only with 0 `p111` FIDs, `_b*` direct+worker, `_c*` closure/factory, `_w*`/`_` legacy worker) with fail-loud contract enforcement so internal callee changes cannot silently break already-compiled caller `.o` files.
2. **Exact ELF Root-Cause on `k16_wave17` (`m00..m15`):**
   - `m00..m04` emit `~2,400` `p164a_segment` wrappers (`70.3%` of `m00`, `43.4%` of `m01`), of which `~1,000+` are direct-only and eliminated by `_d*`.
   - `m14` (`2,644` def segs) and `m15` (`2,203` def segs) have **`0` `p164a_segment` wrappers** and **`0` `P167Factory` chains**; **98.6%** of their segments are non-direct CPS workers + `$p111.k.*` continuations caused by `568` mutual-recursion SCCs (`3,162` defs) rejected by `p113d_passes` (acyclic + self-rec only).
3. **Decisive Contract Suite (`-O0` & `-O2`):** Monolithic (`174`) == Split A (2 mods, `174`) == Split B (3 mods, `174`); callee body change + relink byte-identical old caller `.o` == `207`; direct-only FID omission, cross-module closure factory (`_c`), mutual-rec CPS continuation (`_w`), and fail-loud contract violation all verified PASS.

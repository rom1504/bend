# B2: Direct-Only FID Omission & Explicit Cross-Module Contracts (`REPORT.md`)

## Executive Summary
- **Deliverable:** [apply_b2.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/apply_b2.py) — clean, idempotent, self-contained pure-Bend patch against [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave17_unified/compiler.bend) (`+6,838 B`, `0` new types, `0` C/JS changes).
- **Type & Linearity Check (`locked_bun.sh --check-only`):** **PASS** (`0` type errors, `0` linearity errors; idempotent re-run verified).
- **Native Mint (`n8_b2`, `k10_wave17`, `65,315 / 65,532` FIDs) & Smoke (`compiler_slice.bend`):**
  - `-O0` (`x86-object-fast`): **PASS** (`out = 34`, `20,826.3 ms`)
  - `-O2` (`x86-object`): **PASS** (`out = 34`, `12,658.5 ms`)
- **Decisive Cross-Module Contract Suite ([test_b2_contracts.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b2_direct_fid/test_b2_contracts.py)):** **100% PASS in BOTH `-O0` and `-O2`!**
  - Monolithic (`174`) == Split A (2 modules, `174`) == Split B (3 modules, `174`).
  - Callee body change (`174 -> 207`) + relink with **byte-identical old caller `.o`** (`caller_obj_byte_identical: true`) == `207`.
  - Direct-only export (`_d_0 = add_mul`) verified via `readelf -sW`: `p113d_FID_$direct.add_mul` is `GLOBAL`, while `p111_FID_$direct.add_mul` (`p164a_segment`) and `p111_FID_add_mul` (`P167Factory`) are **omitted (0 FIDs)**.
  - Closure/factory export (`_c_2 = make_adder`) verified across module boundaries via higher-order `apply_two(make_adder(7), make_adder(11), 10)`.
  - Mutual-recursion CPS worker export (`_w_3 = cps_sum`) verified across module boundaries.
  - **Fail-loud contract enforcement:** making `_d_0 = add_mul` non-direct internally causes compilation to fail loudly with `b2 contract violation: direct-only export add_mul was not lowered direct`, preventing silent ABI breakage of already-compiled caller `.o` files.

---

## Root-Cause ELF Audit of `k16_wave17` (`m00..m15`)

`readelf -sW` across the Wave 17 `-O2` `k16_wave17` objects revealed the exact composition of every module:

| Module | `p111_def` | `$p111.k.*` | `p164a_wrap` (needed by `UND`) | `nonwrap` (CPS) | `p113d_def` | `und_dir` |
|---|---:|---:|---:|---:|---:|---:|
| `m00` | `1,334` | `173` | **`938` (`551`)** | `148` | `1,460` | `0` |
| `m01` | `1,259` | `453` | **`546` (`288`)** | `205` | `735` | `109` |
| `m02` | `1,850` | `1,055` | **`373` (`184`)** | `375` | `484` | `232` |
| `m03` | `1,659` | `1,033` | **`237` (`142`)** | `346` | `318` | `366` |
| `m04` | `1,932` | `1,320` | **`202` (`102`)** | `370` | `283` | `482` |
| `m14` | `2,644` | **`2,093`** | **`0` (`0`)** | **`522`** | `43` | `554` |
| `m15` | `2,203` | **`1,749`** | **`0` (`0`)** | **`422`** | `20` | `588` |

### Key Architectural Findings
1. **Early modules (`m00..m04`)**: `p164a_segment` CPS adapters account for **70.3% of `m00`** (`938 / 1,334`) and **43.4% of `m01`** (`546 / 1,259`), of which **`~1,000+` across `K=16` are 100% unused** (direct-only) — and **100% are eliminated** for pure direct-only library modules using `_d*` contracts.
2. **Late modules (`m14`, `m15`)**: `m14` (`2,644` defined segs + `554` `UND` stubs = `3,198` segs) and `m15` (`2,203` defined segs + `588` `UND` stubs = `2,801` segs) have **`0` `p164a_segment` wrappers** and **`0` `P167Factory` currying chains**. Instead, **98.6% of their segments** are genuine non-direct CPS workers + `$p111.k.*` continuations (`~4.0` continuations/fn) caused by **`568` mutual-recursion SCCs (`3,162` defs)** rejected by `p113d_passes` (which only admits acyclic + self-recursive functions), cascading to ~3,500 transitive callers. Unlocking `~2×–4×` on `m14`/`m15` requires mutual-recursion direct lowering (a separate Wave 18 pass), NOT wrapper omission.

---

## Explicit Cross-Module Contract Semantics (`apply_b2.py`)

In a defining module's synthetic `.exp` `def main() -> U32:`, each binding declares the exact callable entries guaranteed by that module (verified in both `-O0` and `-O2` via `b2_exp_main_dispatch`):

| Binding Prefix | Contract | Guaranteed Symbols | `p167l` Demand | Fail-Loud Verification |
|---|---|---|---|---|
| `_d* = fn` | Direct-Only | `p113d_FID_$direct.<fn>` only | **None (0 FIDs!)** | Fails if `dx(entry) != 1` (not direct) |
| `_b* = fn` | Direct + Worker | `p113d_FID_$direct.<fn>` + `p111_FID_$direct.<fn>` | `p113d_public(book, fn)` | Fails if `dx(entry) != 1` (not direct) |
| `_c* = fn` | Closure / Factory | `p111_FID_<fn>` (`P167Factory`) + `p111_FID_$direct.<fn>` | `nc_ref_name` + `p113d_public` | Fails if absent from catalogue |
| `_w* = fn` / `_ = fn` | CPS Worker (legacy) | `p111_FID_$direct.<fn>` | `p113d_public(book, fn)` | Backward-compatible with `O2-D` |

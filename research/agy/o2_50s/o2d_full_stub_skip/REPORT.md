# O2-D: Full Zero-`.p130` Stub Skip + `K=16`/`K=24` `-O2` Enabler (`REPORT.md`)

## Executive Summary
- **Deliverable:** [apply_o2d.py](file:///home/ai/bend2_agy/research/agy/o2_50s/o2d_full_stub_skip/apply_o2d.py) — clean, idempotent, pure-Bend patch against [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave16_unified/compiler.bend) (`+7,772 B`, `0` new types, `0` C/JS changes).
- **Type & Linearity Check (`--check-only`):** **PASS** (`0` type errors, `0` linearity errors across `9,146` `@unsafe` defs; idempotent re-run verified).
- **Smoke (`compiler_slice.bend`, `n8_o2d` `-O0`-minted binary):**
  - `-O0` (`x86-object-fast`): **PASS** (`out = 34`, `377,176 B`)
  - `-O2` (`x86-object`): **PASS** (`out = 34`, `388,208 B`)
- **Verified Impact on S10-A Stubs (`k10/m09`, `k16/m09`, `k16/m15`):**
  - **`k10/m09`:** `p111_def` dropped **`5,076` → `3,660`** (**`-27.9%`**, `-1,416` emitted functions), `p111_und` rose **`0` → `859`** (every S10-A stub is now a clean `UND` relocation with zero body lowering and zero `x187_pub` machine code!), `p111_weak_def` dropped **`895` → `36`** (**`-96.0%`**, only Base remains weak), **`p113d_und` dropped `303` → `0`** (structurally eliminating W16-MINT Finding #3!), and `x187_elf` improved **`1.98×`** (normalized to `-O2` binary speed).
  - **`k16/m09`:** `p111_def` dropped **`5,017` → `4,143`**, `p111_und` = `555`, `p111_weak_def` dropped **`584` → `29`** (`-95.0%`).
  - **`k16/m15`:** `segs` dropped **`3,197` → `2,780`** (`-13.0%`), `p111_def` dropped **`3,197` → `2,187`** (`-31.6%`), `p111_und` = `593`, `p111_weak_def` dropped **`624` → `31`** (`-95.0%`).

---

## Root-Cause Findings (Exact ELF Audits)

1. **Why `W16-MINT` Still Emitted All Stubs in `p111` + `x187_pub`:**
   - `S10-H` only skipped `p113d` direct-stub codegen in `-O0` (`s10c_plan_fast`), leaving **`p167l_dispatch`** (both `-O0` and `-O2`) lowering all S10-A CPS stubs (`_f = _cps => _cps; f(...)`) via `w6_worker_non_direct` -> `p111_lower` AND emitting `p164a_segment` wrappers for all direct stubs (`859` stub `WEAK` functions in `k10/m09` alone!).
   - Furthermore, **`S10-H` was never wired into `-O2` (`p168_request_mode`)**, so `-O2` was still running `p112s_prepare`, `p128br_scan`, `w7_filter_remaining`, `p113pl_candidates`, `p113d_passes`, and `x187_priv` on all S10-A stubs!
2. **Base Segment Audit (Bonus Check):**
   - `readelf -sW` on `k10/m09`, `k16/m00`, `k16/m09`, `k16/m15`, and `k24/m00` proved that Base `WEAK` segments are only **`29–47` per module** (`~500–900` total across `K=16`/`K=24`, NOT `16,000–24,000`). Keeping those `~35` Base segments `WEAK` guarantees zero missing Base symbols across arbitrary splits at negligible FID cost (`< 1.4%` of 65,532).
3. **True FID Multiplier Blocking `K=16`/`K=24` (`~25,000–30,000` FIDs):**
   - In non-entry modules (`m00..m{K-2}`), synthetic `.exp` roots (`def main() -> U32: _ = f1; _ = f2; ...; 0`) have `4,851` exports in `K=10`, `5,584` in `K=16`, and `6,022` in `K=24`.
   - Each `_ = f` caused `p167l_dispatch` to emit a full curried `P167Factory` + `(arity - 1)` `$p111.k.*` continuation segments (`~4–5` FIDs per export = `~25,000–30,000` dead FIDs!), even though `0` arity >= 1 functions are ever passed as first-class cross-module closures.

---

## What `apply_o2d.py` Patches (4 Clean Changes, Both `-O0` and `-O2`)

1. **`p167l_dispatch` (Both `-O0` and `-O2`):**
   - Detects S10-A stubs via `o2d_stub_kind(book, source) > 0` and calls `o2d_stub_dispatch`, which emits a zero-statement external segment descriptor `N111Segment{seg_name, seg_arity, 0, 0, seg_flags, []}` — **zero `p111_lower`, zero `$p111.k.*` continuations, zero `p164a_segment` wrappers, zero transitive demands**.
   - Detects synthetic `.exp` export roots (`o2d_is_exp_main_go`) and calls `o2d_exp_main_dispatch`, which directly demands each exported def's worker (`p113d_public(book, f)`) and emits a 4-statement `return 0` body for `main` — eliminating dead `P167Factory` currying chains.
2. **Empty-Body External Stub Codegen Skip (`-O0` & `-O2`):**
   - `s10f_pub_emit_seg` & `s10c_pub_emit_seg` (`-O0`) and `w11_program_public_mod` (`-O2`) skip machine-code emission whenever `List.is_empty(&2, N111Stmt, body)`, leaving `p111_FID_<name>` as `UND` to link directly against the owning module's `GLOBAL`.
   - `p167v_one` (`-O2` verifier) accepts empty-body external stub segments.
3. **`-O2` Direct-Stub Skip (`p168_catalogued`, `p168_prepared`, `p168_selected`, `p168_candidates`, `p169a_view`):**
   - Mirrors `S10-H` into the `-O2` pipeline: filters stubs out of `p112s_prepare`, `p128br_scan`, `w7_filter_remaining`, `p113pl_candidates`, and seeds `p113d_passes` + `w4p_adapt_functions` + `p169a_view` (`o2d_p118b_verify_functions`) with `o2d_ready_stubs`.

---

## Integration Note for Wave 17 Composition
- `apply_o2d.py` applies cleanly and idempotently on top of `selfhost/build/agy/wave16_unified/compiler.bend` (`--check-only` `0` errors).
- Once minted as an `-O2` binary (`n8_o2`), both `-O0` and `-O2` will run with full S10-A stub skip (direct + CPS) and zero dead `p111_FID_$direct.<stub>` wrappers, structurally fixing W16-MINT Finding #3 and unlocking `K=16`/`K=24`.
- Note: The `o2d_is_exp_main_go` matcher was refined after our initial `-O0` mint (which matched exact `nm == "_"`) to also match Bend-renamed `_*`/empty `Bind` names and `Num`/`U32`/`Ctr` leaf tags; Wave 17 mint should verify `m00` segment drop on `k16_wave16`/`k24_wave16` on first run.

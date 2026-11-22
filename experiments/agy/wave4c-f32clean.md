# Wave 4 Phase 3 — Track W4-11: `nbody` XMM Spill/Copy Closer (`1.85× → 1.23×` C16 / `1.05×` GCC-10) + `native45` Inliner Guards + Compact `p113i_` Prefixes

- **Date:** 2026-11-22
- **Composable Patcher:** [apply_f32clean.py](file:///home/ai/bend2_agy/research/agy/wave4c_f32clean/apply_f32clean.py)
- **Baseline:** `selfhost/build/agy/wave4b_unified/compiler.bend` → `selfhost/build/agy/wave4c_f32clean/compiler.bend` (`2,677,596 B`) + `selfhost/build/agy/wave4c_f32clean/api.mjs` (compiled via `locked_bun.sh`)
- **Rules Compliance:** 100% general passes (zero benchmark-specific pattern matchers); `bfs`, `merkle`, `kmeans` untouched; exact IEEE-754 `F32` semantics preserved (no FMA contraction; `nbody` checksum `728502159` bit-exact); strictly 1-scrutinee helper defs; scratch footprint `10 MiB` (`< 40 MiB`).

---

## Executive Summary

| Deliverable / Gate | Baseline (`wave4b_unified` / `wave4a_unified`) | `wave4c_f32clean` | Delta / Verdict |
|---|---:|---:|---|
| **`nbody` (upstream-medium, CPU 2)** | `138.12 ms` (`1.58×` GCC-10, `1.85×` C16) | **`92.19 ms`** (**`1.05×` GCC-10**, **`1.23×` C16**) | **`1.50×` speedup (`-45.9 ms`)**, exact `728502159` |
| **`histogram` (upstream-medium, CPU 2)** | `57.52 ms` (`2.57×` GCC-10, `2.40×` C16) | **`57.11 ms`** (`2.55×` GCC-10, `2.38×` C16) | Slight win (`-0.4 ms`), exact `3307081914` |
| **`native45` `editdist` vs Wave 2** | `21.875×` regression (`AGY-W2-DPLOOP` broken) | **`1.053×`** (`133ms → 140ms`, `overC 0.652×`) | **FIXED (`AGY-W2-DPLOOP` restored)** |
| **`native45` `coverage-bst-64` vs Wave 2** | `5.958×` regression (`AGY-W2B-3` bypassed) | **`0.992×`** (`249ms → 247ms`, `overC 0.256×`) | **FIXED (`AGY-W2B-3` restored, faster than W2)** |
| **`native45` `raytrace` vs Wave 2** | `0.988×` (`170ms → 168ms`) | **`0.890×`** (`172ms → 153ms`, `overC 0.268×`) | **`+12%` faster than Wave 2** (XMM pass win!) |
| **`native45` `mandelbrot` vs Wave 2** | `0.913×` (`161ms → 147ms`) | **`0.906×`** (`171ms → 155ms`, `overC 0.770×`) | **`+10%` faster than Wave 2** |
| **`broad/5` `p113i_` >128-char IR failure** | `0/5` (`invalid/reserved local name`) | **`5/5 PASS`** (emit + exec exact) | **FIXED (`broad/editdist`, `broad/local-pair`, etc.)** |
| **`focused19` Conformance Gate** | `19/19 PASS` | **`19/19 PASS`** | **PASS** |
| **`observer_wave2_gate` (Live Metadata)** | `15/15 PASS (0 violations)` | **`15/15 PASS (0 violations)`** + `44+2` ABI | **PASS** |

---

## 1. Root-Cause Disassembly & General XMM Passes (`nbody` `138.1 ms → 92.2 ms`)

Disassembling `wave4b_unified`'s `p113d_$product.loop3` (`997` lines, `216 mov`, `151 movd`, `58 movq`) revealed two dominant bottlenecks in spilled FP loops:
1. **Immediate `movq %xmm0, disp(%rbp)` → `movd`/`addss`/`mulss`/`divss disp(%rbp), %xmm0` store-forwarding stalls:** Once `xmm2..xmm7` (6 temp regs) filled with live force/delta vectors, every remaining intermediate spilled via 64-bit `movq` and immediately reloaded via 32-bit `movd`/SSE op on the very next 1–3 instructions (~50+ store-forwarding stalls per step on Ivy Bridge).
2. **Backedge stack-to-stack & stack-to-GPR copies (`18` pairs = `36` instructions/step):** Updated positions and velocities were written to fresh temp stack slots (`-0xee8(%rbp)..-0x10a8(%rbp)`) and then copied via `%r10` into parameter slots (`-0x50(%rbp)..-0xc8(%rbp)`) or GPRs (`%r9, %r13, %r15`) at the backedge even though the old parameter slot was already dead.
3. **Intra-block stack-to-stack copies (`movq src(%rbp), %r10; movq %r10, dst(%rbp)`):** Scalar `N111Set` copies between spilled `F32` temps (`ir`, `ir3`) round-tripped through `%r10`.

### General Passes Added in `w4_post_select` (`w4c_xmm_opt`)
All passes operate on `List<&2, X187Parsed>` using O(1) radix-trie slot maps (`W4CMap`) and strictly 1-scrutinee helpers (gated by `!w4c_has_leaq_rbp(items)` for slot-deletion/coalescing soundness):
1. **XMM Store-to-Load Forwarding Peephole (`w4c_xmm_peep`, lazy `w4c_or_peep` O(N)):**
   - `movq %xmmA, off(%rbp); movd off(%rbp), %xmmA` → drop redundant `movd`.
   - `movq %xmmA, off(%rbp); movd off(%rbp), %xmmB` → `movaps %xmmA, %xmmB`.
   - `movq %xmmA, off(%rbp); <fop> off(%rbp), %xmmB` → `<fop> %xmmA, %xmmB`.
   - 3-inst `movq %xmm0, off(%rbp); <ld> s1, %xmm0; <fop> off(%rbp), %xmm0` and `movq %xmm0, off(%rbp); <fop1> %xmm0, %xmm0; <fop2> off(%rbp), %xmm0` (verified via CFG-aware `w4c_xmm_dead(1, rest, fnItems, 400, 2)`) → save in `%xmm1` + forward `%xmm1` to subsequent `<fop> off(%rbp), %xmmB` (`w4c_fwd_xmm1`).
   - 5-inst 2-term `%xmm0`/`%xmm1` tree collapse (`w4c_try_tree5`): keeps both subtrees in `%xmm0` and `%xmm1` with zero spills.
2. **Intra-Block Stack-Copy Forwarding (`w4c_copy_slot_fwd`):** Eliminates `movq src(%rbp), %r10; movq %r10, dst(%rbp)` when `dst` is single-write and read only in the remainder of the basic block while `src` is unmodified.
3. **Backedge Dead-Slot & GPR Coalescing (`w4c_backedge_coalesce`):** Coalesces block-local temp slots directly into dead target stack slots (`dst(%rbp)`) or GPRs (`movd %xmmA, %rXd`, zero-extending to 64 bits) when the target is untouched between def and copy.
4. **Dead Negative-`%rbp` Stack-Slot Store Elimination (`w4c_dead_slot_elim`):** Deletes write-only stores to negative-`%rbp` slots with 0 reads across the function.

**Impact on `p113d_$product.loop3`:**
- Lines: `997 → 826` (`-171`)
- `movq` spills: `58 → 21` (**`-64%`**)
- `mov` GPR copies: `216 → 165` (`-51`, all 18 backedge copies eliminated)
- `nbody` runtime: **`138.12 ms → 92.19 ms`** (**`1.05×` GCC-10**, **`1.23×` Clang-16**)
- `raytrace` runtime (side benefit!): **`172 ms → 153 ms`** (**`0.890×` vs Wave 2**, `+12%` faster!)

---

## 2. General `native45` Inliner Guards (`AGY-W2B-3` & `AGY-W2-DPLOOP`)

1. **`AGY-W2B-3` Guard (`p169o_closed` / `p169o_walk` / `p169o_next`):**
   - Computes `zipOwners = w4c_zip_owners_map(book)` (reusing the exact structural `agy_zip_owners(book, book, [])` predicate) and excludes certified `"$direct." ++ owner` functions from `p113i` table publication so callers keep their direct call into the `AGY-W2B-3` zipper wrapper.
   - Restores `native45` `coverage-bst-64` from `5.958×` → **`0.992×`** vs Wave 2.
2. **`AGY-W2-DPLOOP` Guard (`p113i_function`):**
   - `w4c_is_dp_stencil(params, result, body)` skips inlining into 7-param, 4-result tail-recursive (`P113DAgain`) array-pair (`p113_rt_array_pair`) stencil loops so `agy_dp_certify` matches intact at `x181_direct`.
   - Restores `native45` `editdist` from `21.875×` → **`1.053×`** vs Wave 2 (`agy_dp_slow_*` emitted).

---

## 3. Compact Nested `p113i_` Local Prefixes (`broad/5` Fix)

- In `p112f_name`: when both `prefix` and `name` start with `"p113i_"`, emits `prefix ++ String.drop(name, 6n)` (`"p113i_0_1_0_local_x"`, +2 chars/level instead of +14 chars/level) — injective, preserves `"p113i_"` prefix invariants, and stays well under `p111v_name_chars`'s 128-char limit.
- Updated `p113j_buffer_peel` (`w4c_peel_i_chain` / `w4c_skip_digits`) to peel arbitrary-depth `"p113i_" (<digits> "_")* "local_"` chains.
- Verified **5/5 PASS** (emit + exact stdout) on `broad/editdist`, `broad/local-pair`, `broad/complete-generic-row32`, `broad/variation-editdist-0-17`, and `broad/variation-editdist-3-123`.

---

## 4. Verification Receipts

- **Proxy-4 (`run_proxy.py --only nbody,histogram,bst,editdist --runs 3`, CPU 2):**
  - `nbody`: `92.192 ms` (`1.05×` GCC-10 `87.429 ms`, `1.23×` C16 `74.7 ms`, PASS)
  - `histogram`: `57.108 ms` (`2.55×` GCC-10 `22.414 ms`, `2.38×` C16 `24.0 ms`, PASS)
  - `bst` (tuned-4): `36.529 ms` (`2.79×` GCC-10, `3.37×` C16, PASS)
  - `editdist` (tuned-4): `43.750 ms` (`4.52×` GCC-10, `4.75×` C16, PASS)
  - Emit time: `21.47s` (down from `30.31s`).
- **`focused19`:** `19/19 PASS`.
- **`observer_wave2_gate`:** `44+2` ABI/metadata probes PASS + `15/15 PASS (0 violations)`.
- **`native45` 4-bench calibrated A/B vs `wave2_unified` (CPU 2, 3 interleaved runs):**
  - `editdist`: `133ms → 140ms` (`1.053×`, exact)
  - `coverage-bst-64`: `249ms → 247ms` (`0.992×`, exact)
  - `raytrace`: `172ms → 153ms` (`0.890×`, exact)
  - `mandelbrot`: `171ms → 155ms` (`0.906×`, exact)
  - 4-bench geomean: `0.9579×` (`1.044×` speedup over Wave 2).
- **`broad/5`:** `5/5 PASS` (emit + exact stdout).

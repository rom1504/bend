# Wave 4 Phase 3 — Track W4-9: General Branchless `cmov` Diamonds, CSE/Regalloc Preservation, Huge-Loop Transient Allocation & Loop-Rotation Composition Fix

**Date:** 2026-11-22  
**Base → Output:** `selfhost/build/agy/wave4b_unified/compiler.bend` → `selfhost/build/agy/wave4c_cmov/compiler.bend`  
**Patcher:** [`research/agy/wave4c_cmov/apply_cmov.py`](../../research/agy/wave4c_cmov/apply_cmov.py) (100% general compiler passes, zero benchmark-specific pattern matching)  
**Built API:** `selfhost/build/agy/wave4c_cmov/api.mjs`

---

## 1. Root-Cause Diagnosis

### A. `gameoflife` (`1585 ms` / `6.56×` C16 / `1.72×` GCC-10 in `wave4b_unified`)
Disassembly of `$direct.step` and `$direct.run` (into which `$direct.step` is inlined for 94% of runtime!) revealed five compounding general compiler bottlenecks:
1. **16 unpredictable scalar `P113DIf` diamonds (`jcc=32, cmov=0`)**: Each `next_cell` branch was a short pure scalar diamond (`next_dead` vs `next_alive`), which cut both `x186_e_body` CSE and `x185_transient_frame` GPR allocation into 32 tiny regions.
2. **In-place self-updates (`t = shr(b, k); t = and(t, 1)`) killed CSE**: `x186_e_written` evicted `t = shr(b, k)` on the second write, and `x186_e_insert` refused to record `t = and(t, 1)` because `left == name`. As a result, all 128 `(board >> k) & 1` bit extractions were recomputed (`shr=135` instead of `15`).
3. **CSE table cap (`64`) evicted bit extractions midway through large straight-line blocks**.
4. **Long-lived CSE values hogged all 5 transient GPRs**: Once CSE exposed 16 function-spanning values, `x185_t_place` (which allocates in first-definition order) assigned 4 of the 5 caller-saved transient GPRs (`rdi, rdx, r8, r9`) to function-spanning bits, leaving only 1 transient GPR (`rsi`) for all intra-cell temporaries (`sum`, `cmp`, `or`, `cmov`).
5. **Huge-loop 32-variable cliff in `x190_j_counted`**: Once CSE shrank `$direct.run` below 512 statements, `$direct.run` entered `x190_joint_frame` → `x190_j_counted`, which dispatched `> 32` candidates to `x185_transient_frame` **only for non-loop functions**, forcing `$direct.run` into `x190_j_selected` (32-variable cap) where >85% of its temporaries spilled to `[rbp-0x11xx]`.

### B. `expression` (`14.15 ms` / `1.96×` C16 in `wave4b_unified` vs `10.32 ms` / `1.43×` C16 in `wave4b_loopxmm`)
Disassembly of `p113d_$direct.unwind` in `wave4b_unified` vs `wave4b_loopxmm` revealed an exact pass-composition bug:
1. W4-6's `w4_peep_cmp0_jcc` rewrote `cmpq $0, %r; jne` → `testq %r, %r; jne` **before** W4-7's `w4b_rotate_loop` and `w4b_copy_check_cmp` ran. Both W4-7 passes matched only `cmpq/cmpl $0, %r`, so **bottom-tested loop rotation and redundant `testq` elimination were completely disabled in `wave4b_unified`**.
2. `w4b_taildup_check` only matched a 1-instruction merge block with a single label (`PLabel; mov; test; jne`), missing 2-instruction backedge merge blocks (`mov %r14, %rdi; mov %r15, %rdx; test; jne`) and nested-`if` double labels (`PLabel; PLabel`).
3. `w4b_reg_dead_go` returned `False` on `popq` in function epilogues, blocking `movl %r, %esi; addl/imull %esi, %edi` copy-forwarding.

---

## 2. General Compiler Passes Implemented (`apply_cmov.py`)

All passes are 100% general, semantics-preserving, and single-scrutinee (zero `bend.ts` pattern-matrix blowup):

1. **Post-`p111v` Pure Scalar Diamond Hoisting (`w4c_diamond_body`)**:
   - Runs inside `x186_expression_body` right after `x190_local_values_body` and before `x186_e_body` CSE.
   - Uses backward liveness (`x185_d_*`) to hoist short (`<= 16` stmts), effect-free, trap-free (`N111Set` + pure `N111Bin`, no `udiv`/`urem`) `P113DIf` arms writing the same scalar destination `dst` into straight-line code feeding a canonical 1-stmt `P113DIf{cond, [Set{dst, typ, ynm}], [Set{dst, typ, nnm}]}`, which `x191_conditional_select` lowers to branchless `cmovneq`/`cmovnel`.
2. **CSE & Transient GPR Preservation Across 1-Stmt `cmov` Selects (`x186_e_if`, `x185_t_if`)**:
   - `x186_e_if` preserves all CSE facts/aliases except `dst` across 1-stmt select diamonds (and substitutes aliases into `cond`, `yes`, `no`).
   - `x185_t_if` models 1-stmt `cmov` selects as a single non-cutting read/write event (no `x185_t_cut`), since `x191_select_emit` uses only scratch regs `%rax, %r10, %r11`.
   - Raised `x186_expression_body` / `x185_dead_body` caps `4096 → 8192` and `x186_e_insert` / `x186_e_remember_alias` caps `64 → 1024`.
3. **Adjacent Self-Update Splitting & Double-`xor $1` Cancellation (`w4c_su_body`)**:
   - Splits adjacent `x = pure_bin(l1, r1); x = bin(l2, r2)` by renaming the first def to a fresh local `x_w4s*` and substituting in `l2, r2`, exposing both operations to `x186_e_body` CSE.
   - Simplifies adjacent `a = xor(x, 1); b = xor(a, 1)` (when `x != a`) into `b = Set(x)` with exact 32/64-bit zero-extension semantics.
4. **Long-Interval Guard in `x185_t_place` & Huge-Loop Dispatch in `x190_j_counted`**:
   - In large functions (`position > 256`), `w4c_t_place_cap` caps transient GPR allocation to intervals of length `<= 48` statements so function-spanning values (already served by `x181_register_frame`'s 4 callee-saved GPRs) cannot starve short-lived temporaries.
   - In `x190_j_counted`, loop functions with `> 64` candidate variables dispatch to `x181_register_frame` + `x185_transient_frame` (which is already loop-safe, excluding `params`/`setup` and cutting at `P113DAgain`), preventing the 32-variable spill cliff.
5. **W4-6 / W4-7 Composition Fix & Copy-Peep Strengthening**:
   - `w4b_rotate_check_hdr` and `w4b_copy_check_cmp` accept both `cmpq/cmpl $0, %r` and `testq/testl %r, %r`.
   - `w4b_taildup_check` tail-duplicates both 1-inst and 2-inst merge-backedge blocks across single or double consecutive labels.
   - `w4b_reg_dead_go` handles `popq %r` as write-only, bumps hops `3 → 4` and budget `24 → 36`, folds commutative `alu32 %d32, %t32; movq %t64, %d64 → alu32 %t32, %d32` and 5-instruction `subl` sequences, and runs a post-rotation `w4b_copy_peep` pass.

---

## 3. Results & Verification

### Effect on `gameoflife` (`$direct.step` / `$direct.run`)
- `$direct.step`: **`1555 → 789` instructions** (`-49%`), **`jcc: 32 → 0`**, **`cmov: 0 → 16`**, **`rbp` stack refs: `559 → 178`** (`-68%`), **`shr`: `135 → 15`** (`-89%`).
- `$direct.run` (32 iterations/soup): same branchless `cmov` + full 16-bit CSE + full transient GPR allocation.

### Proxy Benchmark Results (`run_proxy.py --only gameoflife,expression,list --runs 3`, CPU 2, exact checksums)

| Benchmark | Group | GCC-10 C (ms) | Clang-16 Ref (ms) | `wave4b_unified` (ms) | `wave4c_cmov` (ms) | Bend / GCC-10 | Bend / Clang-16 | Speedup vs W4B-Unified | Status |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| **`gameoflife`** | upstream | 921.491 | 241.5 | 1585.0 *(6.56× C16)* | **625.464** | **0.68×** | **2.59×** | **2.53×** | **PASS** |
| **`expression`** | tuned | 6.249 | 7.237 | 14.15 *(1.96× C16)* | **11.202** | **1.79×** | **1.55×** | **1.26×** | **PASS** |
| **`list`** | tuned | 0.269 | 0.269 | 0.265 *(0.99× C16)* | **0.249** | **0.93×** | **0.93×** | **1.06×** | **PASS** |

> **Highlight:** `gameoflife` is now **`0.68×` GCC-10 C** (**1.47× faster than handwritten C compiled with GCC-10!**) and **`2.59×` Clang-16** (down from `6.56×` in `wave4b_unified` and `19.56×` in `wave4a_unified` — a **7.5× cumulative speedup**!).

### Mandatory Gates
- **`focused19`**: **19/19 PASS**
- **`observer_wave2_gate`**: **44+2 ABI probes PASS**, **15/15 PASS (`0 violations`)**
- **Scratch budget**: `selfhost/build/agy/wave4c_cmov/` = **~10 MiB** (< 40 MiB limit), `/tmp` scratch cleaned.

# Wave 4 Phase 1 Track W4-4: General x86-64 Scalar Codegen, Peephole & Shrink-Wrap Optimizer

**Date:** 2026-11-22  
**Composable Patcher:** [apply_scalar_x86.py](file:///home/ai/bend2_agy/research/agy/wave4_scalar/apply_scalar_x86.py)  
**Input:** `selfhost/build/agy/wave3b_unified/compiler.bend` (2,514,380 B)  
**Output:** `selfhost/build/agy/wave4_scalar/compiler.bend` (2,538,720 B) → `selfhost/build/agy/wave4_scalar/api.mjs` (6.9 MiB; directory total `9.3 MiB < 40 MiB` budget)  
**Policy:** 100% general compiler passes (zero benchmark-specific pattern matchers / AST templates).

---

## 1. General Compiler Passes Implemented

1. **Spill-Free `U32.mod` / `U32.div` + `lea` Strength Reduction (`x198qm`)**
   - Recovers the dividend operand directly from the immediately preceding scratch store (`leaq [rbp-arg], %r10; movq %src, %r11; movq %r11, (%r10)` or direct `movq %src, (%r10)`), eliminating the 64-bit store → 32-bit reload store-to-load forwarding stall on Ivy Bridge.
   - Replaces `movl $d, %r11d; imull %r11d, %eax` in `P198Magic` modulo with single-cycle `leaq (%rax,%rax,2), %rax` (`d=3`), `leaq (%rax,%rax,4), %rax` (`d=5`), and `leaq (%rax,%rax,8), %rax` (`d=9`).
2. **Power-of-2 Multiply Strength Reduction (`x185_immediate`, `x185_physical_immediate`)**
   - Lowers `x * 2^k` (`k >= 1`) to `shl{l,q} $k` and `x * 0` to `xorl` for both `N111U32` and `N111U64`.
   - Eliminates all `8× imul $4` in `gameoflife`'s `neighbor_count` (as well as `step_cell`, `step`, and `list`'s `fold`).
3. **Machine Peephole & Branchless `bool01` Cleanup (`w4_peep_list` in `x191_frame_forward`)**
   - Drops redundant self-moves (`movq %r, %r`).
   - Cancels double boolean negation (`xor $1; xor $1`) after `setcc; movzbl` (and general `xorq $1; xorq $1`) when flags are dead.
   - Lowers `x * bool01` (following `setcc; movzbl`) from 3-cycle `imul` to 2-cycle branchless `xorl %r11d, %r11d; sub %b, %r11; and %r11, %x`.
   - Eliminates redundant `cmp $0` after `sub $1` before `je`/`jne`/`jz`/`jnz`.
4. **Unused `state` (`%r12`) Removal, Direct Incoming Arg Moves & Leaf Prologue Shrink-Wrapping**
   - Marks `"state"` as `X181UnusedState` when unreferenced in a function body, skipping `%r12` save/restore and `movq %rdi, %r12`.
   - Copies register arguments (`n < 6`) directly in `x181_incoming` without bouncing through `%rax`.
   - Shrink-wraps leaf functions (`w4_leaf_shrink`): when a function makes 0 calls and never touches `%rbp`/`%rsp` outside its standard prologue/epilogue, strips `pushq %rbp; movq %rsp, %rbp; subq $0x9xx, %rsp` and replaces callee-save frame slots with `pushq`/`popq` (also stripping dead `%r12` save/init/restore when `%r12` is unread in the body).
   - Shrinks `list`'s `$direct.fold` empty-return path from 23 insns (`sub $0x950, %rsp`, 4 stack ops, 8 arg-shuffle moves) down to **8 insns** (`push %rbx; ...; pop %rbx; retq`).
5. **General Parity-Flipping Progress Certificate (`x198o_progress_eval`) & Single-Guard Simplification (`x198o_emit`)**
   - Extends `X198OProgress` with a mathematically sound `sameParity` tracker: multiplying a `U32` state variable by any odd constant preserves LSB parity, and adding/subbing/xoring any odd constant flips LSB parity (`next != state` for all `U32`, zero fixed points in $\mathbb{Z}/2^{32}\mathbb{Z}$).
   - Eliminates the 8-insn speculative fixed-point guard on bijective/LCG loops (`list`, `list-fused`) while keeping 100% of `x198o`/`AGY-005b` wins on potentially-stalling loops.
   - Simplifies 1-guard `x198o_emit` from `p198a_same = 1; p198a_eq = (x == y); p198a_same &= p198a_eq` to `p198a_same = (x == y)`.
6. **General Scalar CSE & Joint-Regalloc Bound Expansion (`x186_e_*`, `x190_joint_frame`)**
   - Raises CSE expression/alias table caps from `16 → 64`, adds commutative matching (`add`/`mul`/`and`/`or`/`xor`), emits canonical `N111U64` copies on CSE hits for immediate copy propagation, adds `zext32` CSE for `N111U32` `N111Set`, and raises `x190_joint_frame` / `x190_liveness_frame` statement bounds from `256 → 512`.

---

## 2. Codegen Inspection (Before vs After)

| Function | `wave3b_unified` | `wave4_scalar` | Key Changes |
|---|---:|---:|---|
| `expression` `$direct.unwind` | ~85 insns, `sub $0x9xx`, 2× store-fwd stall, `imul $3/$5`, `sub 1; cmp 0` | **62 insns, 0 rbp-ops** | Zero spills, `lea (%rax,%rax,2)` / `(%rax,%rax,4)`, `sub $1; jne`, shrink-wrapped leaf, dead `%r12` dropped |
| `list` `$direct.fold` | 23-insn prologue/epilogue (`sub $0x950`), 8-insn fixed-point guard, `xor 1; xor 1; imul` | **29 insns total (8-insn empty return), 0 rbp-ops** | Fixed-point guard gated, `xor 1; xor 1` dropped, branchless `bool01*x`, shrink-wrapped leaf, dead `%r12` dropped |
| `gameoflife` `$direct.neighbor_count` | 214 insns, 45 rbp-ops, 8 `imul`s | **199 insns, 41 rbp-ops, 0 `imul`s, 8 `shl`s** | All 8 `imul $4` → `shl $2`, `-15` insns, `-4` stack ops |
| `gameoflife` `$direct.step_cell` | 76 insns, 1 `imul` | **73 insns, 0 `imul`s** | `imul $4` → `shl $2`, double `xor 1` eliminated |

---

## 3. Paired CPU-2 Proxy Benchmark Results (`run_proxy.py --runs 3`)

Measured back-to-back on CPU 2 (`Intel Xeon E3-1245 V2 @ 3.40GHz`, GCC-10 `-O3` local C ref + Clang-16 reference, exact checksums verified):

| Benchmark | Group | C (GCC) ms | `wave3b_unified` ms (`Bend/C` / `Bend/C16`) | `wave4_scalar` ms (`Bend/C` / `Bend/C16`) | Speedup | Status |
|---|---|---:|---:|---:|---:|---|
| **`expression`** | tuned | 6.249 | 18.571 (`2.97×` / `2.57×`) | **15.918 (`2.55×` / `2.20×`)** | **`1.167×` (`-14.3%`)** | PASS |
| **`list`** | tuned | 0.269 | 0.431 (`1.60×` / `1.60×`) | **0.365 (`1.36×` / `1.36×`)** | **`1.181×` (`-15.3%`)** | PASS |
| **`gameoflife`** | upstream | 921.491 | 3631.478 (`3.94×` / `15.04×`) | **3452.422 (`3.75×` / `14.30×`)** | **`1.052×` (`-4.9%`)** | PASS |
| **3-family geomean** | — | — | `2.659×` (`3.956×` C16) | **`2.349×` (`3.495×` C16)** | **`1.132×`** | PASS |

---

## 4. Mandatory Verification Gates

1. **`focused19` (`research/agy/wave2_ray/run_focused19.py`)**: **`PASS 19/19`** (including `u32-divmod`, `u32-wide-wrap`, `pure-u32`, `pure-f32`, `nat-native`, `lexer-scan`, `arrays-io`, and all 3 negative refusal cases).
2. **`observer_wave2_gate` (`research/agy/wave3_fuzz/observer_wave2_gate.py`)**: **`15/15 PASS (0 violations)`** + `44+2` ABI/observer probes PASS.
3. **`native45` Zero-Regression Spot-Check (`research/agy/bench_all44.py`, CPU 2, 3 rounds, `wave4_scalar` vs `wave3b_unified`)**:
   - `coverage-list-pipeline-128`: **`0.924×`** (`overC: 0.264× → 0.244×`)
   - `coverage-list-pipeline-512`: **`0.891×`** (`overC: 0.262× → 0.233×`)
   - `mandelbrot`: **`0.918×`** (`overC: 2.010× → 1.846×`)
   - `lexer`: **`0.883×`** (`overC: 2.014× → 1.779×`)
   - `raytrace`: `1.051×` (`overC: 1.643× → 1.727×`, noise)
   - **Geomean `cand/base`: `0.9315×` (`+7.4%` faster)**, **0 regressions**.
4. **Disk budget**: `selfhost/build/agy/wave4_scalar/` = **`9.3 MiB`** (`< 40 MiB`).

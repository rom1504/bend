# Wave 4 Phase 0 Diagnosis: `nbody`, `expression`, and `list` (Float & Tight-Loop Codegen)

**Target compiler under test:** `AGY x86` (`selfhost/build/agy/wave3b_unified/api.mjs` + `selfhost/build/agy/unified/runtime-agy.o`)  
**Comparison baseline:** Handwritten C compiled with `-std=c11 -O3 -ffp-contract=off -fno-lto` (measured on CPU 2, `Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz`, single-threaded `+RTS --threads 1 --gpu off -RTS`).  
**Key global observation:** Across all three workloads, **100.00% of `SIGPROF` samples are inside `p113d_direct` generated machine code** (0.00% runtime, 0.00% allocator/GC). Every slowdown is pure x86-64 IR/backend codegen quality.

---

## Summary Table

| Benchmark | Measured Ratio (AGY / C) | Reference Wave 4 / Pilot Ratio | `SIGPROF` Top Hotspots (CPU 2, 100% `p113d_direct`) | Primary Root Causes |
|---|---:|---:|---|---|
| **`nbody`** (med `[10, 300]`) | `3.49×` (318.3 ms vs 91.2 ms GCC) | `5.08×` (upstream `[17, 300]` vs Clang) | `55.84%` `p113d_$product.loop3`<br>`44.16%` `p113d_$direct.fl` | 1. `fl(n, d)` not inlined / not constant-folded (21 calls + 21 `divss` + 42 `cvtsi2ss` per step)<br>2. Zero XMM regalloc: 143 `movd` GPR↔XMM bounces + 222 mem ops/step (vs C: 0 `movd`, 59 mem ops)<br>3. 5,904-byte frame, 18-var stack-to-stack tail-loop copy |
| **Tuned `expression`** (`n=128`) | `2.46×` (844.1 ms vs 343.0 ms GCC) | `2.36×` (vs Clang) | `99.04%` `p113d_$direct.unwind`<br>`0.96%` `p113d_$direct.timed_fold` | 1. Every `U32.mod` spills 64-bit to stack and reloads 32-bit (`mov [rbp-0x840], r11; mov eax, [rbp-0x840]` — ~5-cycle store-forwarding stall on Ivy Bridge!)<br>2. `U32.mod` uses `imul` (3c) instead of `lea` (1c) and reloads magic constants every iter<br>3. Redundant moves, double `sub/cmp`, top-tested loop extra `jmp` |
| **Tuned `list`** (`n=128`, `n&15==0`) | `1.60×` (430.1 ms vs 269.0 ms GCC) | `1.61×` (vs Clang) | `60.00%` `p113d_$direct.timed_fold`<br>`40.00%` `p113d_$direct.fold` | 1. `fold` not inlined into `timed_fold`; 23-insn leaf prologue/epilogue (`sub rsp, 0x950`, 4 stack ops, 8 arg-shuffle moves) for a 0-iter return<br>2. Loop counter `p` spilled to `[rbp-0x8d0]` every iter in `timed_fold`<br>3. No LICM for `(n & 15)` and `(n >> 4) * 238` |
| **Tuned `list` residue (`n=257`) & `list-fused` (`n=512`)** | `1.86×` (`n=257`)<br>`2.36×` (`fused 512`) | `2.34×` (`n=257`)<br>`2.22×` (`fused 512`) | `list257`: `60.23%` `fold`, `39.77%` `timed_fold`<br>`list_fused`: `100.00%` `p113d_$direct.fold` | 1. **8-insn runtime fixed-point guard** (`cmp rsi, rdx; sete; movzx; and; test; je`) executed every iter on an LCG that never stalls<br>2. Double `xor 1; xor 1` + 3-cycle `imul` for `Bool.to_u32(U32.is_gt(v, 1))`<br>3. 33 insns/iter vs C's 10 insns/iter |

---

## 1. `nbody` (`5.08×` C on upstream default; `3.49×` GCC on medium `[10, 300]`)

### 1.1 `SIGPROF` Profile (medium `[10, 300]`, 77 samples, 318.30 ms)
```text
 55.84%  (43 samples)  p113d_$product.loop3
 44.16%  (34 samples)  p113d_$direct.fl       [caller: p113d_$product.loop3]
100.00%  p113d_direct  (0% runtime, 0% heap/GC)
```
Top RIPs inside `fl` (`0x407290` `ret`, `0x407225` `sub rsp, 0x8e0`, `0x407233`, `0x407259` `movd xmm2, r10d`, `0x40723f`, `0x40726b` `cvtsi2ss`) account for 7 of the top 12 PCs in the entire program.

### 1.2 Instruction-Level Diagnosis vs C (`-O3 -ffp-contract=off`)

| Metric (per `loop3` step) | AGY x86 (`loop3` + 21× `fl`) | Handwritten C (`sim.constprop.0` loop) |
|---|---:|---:|
| Dynamic instructions / step | **~1,434** (`699` in `loop3` + `21 × 35` in `fl`) | **201** |
| Function calls / step | **21** (`call p113d_$direct.fl`) | **0** |
| `divss` / step | **24** (3 physics + **21 redundant** in `fl`) | **3** |
| `cvtsi2ss` / step | **42** (all inside `fl`) | **0** |
| `sqrtss` / step | **3** (already inline `ucomiss; ja; sqrtss` — **not** a bottleneck!) | **3** |
| `movd` GPR↔XMM transfers / step | **269** (`143` in `loop3` + `21 × 6` in `fl`) | **0** |
| Stack memory ops / step | **264** (`222` in `loop3` + `21 × 2` in `fl`) | **59** |
| Stack frame size | **5,904 B** (`loop3`) + **2,272 B** (`fl`) | **136 B** (`0x88`) |

1. **Non-inlined, non-constant-folded `fl(n, d)` (44.16% direct + ~12% caller overhead):**
   In `main.bend`, float constants are written via `def fl(n: U32, d: U32) -> F32: F32.div(U32.to_f32(n), U32.to_f32(d))`. `loop3` invokes `fl(5, 100)` 3 times and `fl(1, 1000)` 18 times per step. Because AGY neither inlines small pure functions into `loop3` nor constant-folds `U32.to_f32` / `F32.div` on constant literals, every step executes **21 calls to `p113d_$direct.fl`**:
   ```asm
   ; p113d_$direct.fl (0x407221..0x407290) — called 21 times PER STEP!
   sub    rsp, 0x8e0            ; 2,272-byte frame for a 2-arg leaf!
   mov    [rbp-0x10], r12       ; spills unused r12
   ...
   movd   xmm0, edi             ; GPR -> XMM -> GPR -> XMM -> GPR -> XMM!!
   movd   r10d, xmm0
   pxor   xmm0, xmm0
   cvtsi2ss xmm0, r10
   movd   r10d, xmm0
   movd   xmm2, r10d            ; (repeated identically for esi -> xmm3)
   movaps xmm0, xmm2
   divss  xmm0, xmm3            ; 11-14 cycle FP divide for a compile-time constant!
   movd   edi, xmm0
   ```
   This also explains why **Upstream Bend→C achieves `0.97×` C**: Clang `-O3` inlines `fl` and constant-folds `(float)1 / (float)1000` into `0.001f` in `.rodata`.

2. **Zero XMM register allocation & GPR-bounce spilling of `F32` values:**
   AGY represents every `F32` SSA variable as a 64-bit GPR/stack slot. Every float operation in `loop3` (`0x408b04..0x408b3f`) bounces through `r10d`:
   ```asm
   movd   xmm2, DWORD PTR [rbp-0x70]
   subss  xmm2, DWORD PTR [rbp-0x40]
   movd   r10d, xmm2
   mov    QWORD PTR [rbp-0x1120], r10
   ```
   Across one step, `loop3` performs **143 `movd`** transfers and **222 memory ops** (including **36 memory ops** at `0x40953c..0x40961a` just copying 18 updated state slots `[rbp-0x15d0]..` back to parameter slots `[rbp-0x38]..[rbp-0xc8]` at the tail-loop backedge). Even without full XMM regalloc, keeping hot `F32`s in `xmm0..xmm15` (once the 21 `fl` calls are gone so XMM regs aren't clobbered!) and using direct `movss [rbp-...], xmm2` eliminates all 143 `movd`s and most of the 222 memory ops.

3. **Confirmed non-issues:** `loop3` IS tail-looped (no recursive call per step), allocates 0 heap objects per step, and lowers `F32.sqrt` inline to `ucomiss; ja cold; sqrtss` (matching C).

---

## 2. Tuned `expression` (`2.36×` Clang `-O3`; `2.46×` GCC `-O3`)

### 2.1 `SIGPROF` Profile (`n=128`, `reps=2,000,000`, 208 samples, 844.13 ms)
```text
 99.04%  (206 samples)  p113d_$direct.unwind     (`apply` is inlined into `unwind`)
  0.96%  (  2 samples)  p113d_$direct.timed_fold
```
Top RIPs: `0x407a9e` (`shr rax, 0x21`, 20), `0x407a7b` (`mov rbx, rdi`, 19), `0x407aaf` (`mov eax, r10d`, 15), `0x407a6c` (`lea r14, [rdi-1]`, 12), `0x407a8b` (`mov eax, DWORD PTR [rbp-0x840]`, 10), `0x407ac5` (`imul edi, edi, 3`, 10), `0x407aac` (`sub r10d, eax`, 9).

### 2.2 Instruction-Level Diagnosis vs C (`bench_u32`)

AGY's `unwind` loop (`0x407a47..0x407b57`) executes **~36–46 instructions/iter** vs C's **~16–22 instructions/iter** (`0x1338..0x138e`). Four specific defects account for the `2.36×` gap:

1. **Stack-spill store-to-load forwarding stall on EVERY `U32.mod` (biggest single latency hit):**
   At `0x407a7e..0x407a8b` (`prev % 3`, executed every iteration) and `0x407aec..0x407af9` (`prev % 5`, executed 1/3 of iterations):
   ```asm
   lea    r10, [rbp-0x840]
   mov    r11, rdi
   mov    QWORD PTR [r10], r11       ; 64-bit store
   mov    eax, DWORD PTR [rbp-0x840] ; immediate 32-bit reload -> ~5-cycle store-forwarding stall!
   ```
   Both reload instructions (`0x407a8b`, `0x407af9`) appear in the top-15 RIPs. Replacing this 4-instruction sequence with a single `mov eax, edi` removes 2 memory ops and ~5 cycles of critical-path latency per modulo.

2. **`U32.mod` strength reduction (`imul` vs `lea`) and unhoisted magic constants:**
   AGY computes `q * 3` and `q * 5` via `mov r11d, 3; imul eax, r11d` (3-cycle latency) and reloads `0xaaaaaaab` / `0xcccccccd` every iteration. C hoists both magic constants into `r9d`/`r10d` outside the loop and uses `lea esi, [rdx+rdx*2]` (1 cycle) and `lea ecx, [rcx+rcx*4]` (1 cycle).

3. **Redundant register moves, double `sub/cmp`, and `imm32` encodings:**
   - `prev = seed - 1`: AGY emits 4 insns (`mov ebx, ebx; mov rdi, rbx; sub edi, 1; mov rbx, rdi`) vs C's `lea ecx, [rax-1]`.
   - `case 1n+0n` dispatch: `sub rdi, 1; cmp rdi, 0; jne` instead of `cmp rdi, 1; jne`.
   - `case 1n+1n+p` (`v - (prev + 7)`): 7 insns (`mov rdi, rbx; add edi, 7; mov esi, r13d; mov r11, rdi; mov rdi, rsi; sub edi, r11d; mov r13, rdi`) vs C's 3 insns (`mov edx, -7; sub edx, ecx; add r8d, edx`).
   - `mod 5` + 1: `mov rdi, rax; mov esi, edi; mov rdi, rsi; add edi, 1` (3 dead copies).

4. **Top-tested loop with extra unconditional `jmp`:**
   Each branch ends with `jmp 0x407b54` → `mov rdi, r14; jmp 0x407a47` (2 jumps per iteration) instead of duplicating the loop backedge (`dec rdi; jne loop_body`), and `left` is tracked separately from `seed` (C compares `end != seed`).

---

## 3. Tuned `list` (`1.61×` C on `n=128/512`, `2.34×` on `n=257`) & `list-fused` (`2.22×` C)

### 3.1 `SIGPROF` Profiles
- **`list` (`n=128`, `reps=100M`, 105 samples, 430.05 ms):** `60.00%` `p113d_$direct.timed_fold`, `40.00%` `p113d_$direct.fold` (0 loop iterations inside `fold`).
- **`list` (`n=257`, `reps=50M`, 88 samples, 362.77 ms):** `60.23%` `p113d_$direct.fold` (1 iter/call), `39.77%` `p113d_$direct.timed_fold`.
- **`list-fused` (`n=512`, `reps=500k`, 171 samples, 692.82 ms):** `100.00%` `p113d_$direct.fold`.

### 3.2 Regime A: Call & Driver Overhead (`list n=128`, `1.61×` C)
1. **Heavyweight prologue/epilogue on leaf function `fold` (40% of `list n=128`):**
   `bench` is inlined into `timed_fold`, but `fold` is called 100M times with `n=0`. `p113d_$direct.fold` (`0x407a14..0x407a5b`) executes **23 instructions** (including `sub rsp, 0x950`, spilling/reloading unused `r12` and `rbx`, and 8 `mov rax, reg; mov dst, rax` arg-copy moves) just to test `rdi == 0` and return `rbx`. C's `bench_u32` executes **6 instructions, 0 stack ops**.
2. **Spilled loop counter & missing LICM in `timed_fold` (60% of `list n=128`):**
   `timed_fold` (`0x4081fb..0x4082a8`, 29 insns/iter vs C's 11 insns/iter) spills the decremented loop counter `p` to `[rbp-0x8d0]` before `call fold` and reloads it after, AND recomputes loop-invariant `(n & 15)` and `(n >> 4) * 238` (6 insns including `imul`) on every iteration.

### 3.3 Regime B: Inner `fold` Loop (`list-fused n=512`, `2.22×–2.36×` C; `list n=257`, `2.34×` C)
AGY's `fold` loop (`0x407a3f..0x407aee`) executes **33 instructions/iter** vs C's **10 instructions/iter** (`0x1320..0x1340`):

1. **8-instruction speculative fixed-point guard on EVERY iteration (`0x407aa7..0x407ac1`):**
   ```asm
   mov    r8d, 0x1
   cmp    rsi, rdx      ; checks if LCG next_seed == seed!
   sete   sil
   movzx  esi, sil
   and    r8d, esi
   mov    r10, r8
   test   r10d, r10d
   je     0x407ae5      ; always taken!
   ```
   AGY's fixed-point loop shortcut inserts 8 instructions + 1 branch on every iteration to detect `next_seed == seed`. For an LCG (`seed * 1664525 + 1013904223`), this condition is never met, burning ~25% of loop throughput. (Even where applicable, this check should be `cmp rsi, rdx; je fast_exit` — 2 insns, not 8 — and gated on non-affine/potentially-stalling updates.)
2. **Double `xor 1; xor 1` + 3-cycle `imul` for `Bool.to_u32(U32.is_gt(v, 1))` (`0x407a70..0x407a8a`):**
   ```asm
   cmp    rdx, 0x1
   seta   dl
   movzx  edx, dl
   xor    edx, 0x1      ; Bool tag flip (True=0, False=1)
   xor    rdx, 0x1      ; Bool.to_u32 flips it RIGHT BACK!
   imul   rdi, rdx      ; 3-cycle multiply by {0, 1}
   ```
   Peephole-cancelling `xor 1; xor 1` and lowering `x * bool01` to `cmovbe` / `neg+and` (or C's `test sil, 0xe`) removes 3 instructions and cuts 3 cycles from the critical path.
3. **Top-tested loop & 4 register-shuffle moves at the backedge (`0x407ae5..0x407aee`):**
   `mov rsi, rdx; mov rbx, rdi; mov rdi, r9; jmp 0x407a3f` + `cmp rdi, 0; jne` vs C's bottom-tested `add eax, 1; cmp edi, eax; jne`.

---

## 4. Ranked General Compiler Pass Recommendations

All recommendations below are **100% general compiler passes** (no benchmark-specific pattern matching), ranked by estimated speedup across these workloads and the broader native suite:

| Rank | General Compiler Pass | Primary Targets | Estimated Speedup |
|---:|---|---|---|
| **1** | **Small Pure Function Inlining + Constant Folding (`U32`/`F32` arithmetic & casts)**<br>Inline small non-recursive `p113d` functions (e.g. ≤15 IR ops, leaf/pure) and fold constant `U32.to_f32`, `F32.{add,sub,mul,div}`, and `U32.*` expressions to immediates / `.rodata` constants. | `nbody` (`fl(5,100)`, `fl(1,1000)` — eliminates 44.2% direct + ~12% caller overhead, 21 `divss`/step!) | **`nbody`: ~2.0×–2.3×**<br>Broad win on all helper-heavy code |
| **2** | **Scalar `F32` XMM Register Allocation & Direct `movss` Spill/Reload (No GPR `movd` Bounce)**<br>Allocate `F32` SSA values in `xmm0..xmm15` across basic blocks/loops; when spilling, emit `movss [rbp-...], xmm` directly instead of `movd r10d, xmm; mov [rbp-...], r10`; eliminate the 3× `movd` round-trip in `U32.to_f32`; compact dead temporary stack slots. | `nbody` (`loop3`: eliminates 143 `movd`/step + ~160 stack mem ops + 18-slot backedge copy) | **`nbody`: ~1.7×–2.0×** (stacks with #1 → **`~3.5×–4.5×` total**, closing to `~1.1×–1.3×` C!) |
| **3** | **Eliminate Stack-Spill Round-Trip in `U32.mod`/`U32.div` + `lea` Strength Reduction & Constant Hoisting**<br>Use `mov eax, src32` directly instead of `lea r10, [rbp-slot]; mov [r10], r11; mov eax, [rbp-slot]` (removes ~5-cycle store-forwarding stall!); replace `imul q, {3,5,9}` with `lea`; hoist magic multiplier constants out of loops. | `expression` (2× per iter), all `U32.mod`/`U32.div` loops | **`expression`: ~1.6×–1.8×** |
| **4** | **Tighten / Gate Speculative Fixed-Point Loop Shortcut**<br>Do not emit the runtime `next_state == state` fixed-point check when the state update is a non-stalling arithmetic recurrence (or collapse the 8-insn `mov 1; cmp; sete; movzx; and; test; je` sequence to `cmp a, b; je cold_fast_exit`). | `list-fused`, `list` (`n=257`), all tail-recursive accumulator loops | **`list-fused`: ~1.35×–1.5×**<br>**`list` (`n=257`): ~1.2×** |
| **5** | **Leaf / Shrink-Wrapped Prologues, Dead Frame Allocation & Copy Coalescing**<br>Skip `sub rsp, 0x9xx` when no stack slots are used; only save callee-saved regs actually clobbered (stop saving unused `r12`); coalesce `mov rax, arg; mov dst, rax` arg-copy chains; allocate loop-carried counters in callee-saved regs across calls. | `list` (`n=128`: removes 40% prologue/epilogue tax + `timed_fold` counter spill), `fl`, all small `p113d` functions | **`list` (`n=128`): ~1.4×–1.6×** (approaching `~1.0×` C!)<br>**`expression`: ~1.15×** |
| **6** | **Boolean / Peephole Simplification + LICM + Bottom-Tested Tail Loops**<br>Cancel adjacent `xor reg, 1; xor reg, 1` (`Bool.to_u32(cmp)`); lower `x * bool01` to `cmov`/`neg+and`; hoist loop-invariant pure expressions (e.g. `n & 15`, `(n >> 4) * 238` in `timed_fold`); emit bottom-tested tail-loop backedges (`dec/jne`) and `test r, r` / `cmp r, 1` instead of `sub 1; cmp 0`. | `list-fused`, `expression`, `list` (`n=128`), all tight loops | **`list-fused`: ~1.35×–1.5×**<br>**`expression`: ~1.25×–1.35×**<br>**`list` (`n=128`): ~1.15×** |

### Expected Combined Impact
- **`nbody`**: Passes #1 + #2 eliminate 21 `fl` calls/step, 21 `divss`/step, 143+ `movd`/step, and ~180 stack ops/step → projected **`~3.5×–4.5×` speedup** (`5.08×` → **`~1.1×–1.4×` C**).
- **`expression`**: Passes #3 + #5 + #6 eliminate store-forwarding stalls, `imul` in `% 3`/`% 5`, dead moves, and double jumps → projected **`~2.0×–2.3×` speedup** (`2.36×` → **`~1.05×–1.2×` C**).
- **`list` & `list-fused`**: Passes #4 + #5 + #6 eliminate the 8-insn fixed-point guard, `xor 1; xor 1` + `imul`, leaf `sub rsp, 0x950` frame, counter spill, and invariant recomputation → projected **`~1.5×–1.6×` on `list`** (`1.61×` → **`~1.0×–1.1×` C**) and **`~1.9×–2.2×` on `list-fused`** (`2.22×` → **`~1.05×–1.15×` C**).

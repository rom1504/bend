# Wave 5 Engine B — Track W5-R2: General `nbody`, `gameoflife` & `expression` C16 Closer

- **Date:** 2026-11-22
- **Composable Patcher:** [apply_r2.py](file:///home/ai/bend2_agy/research/agy/wave5_r2/apply_r2.py)
- **Base → Output:** `selfhost/build/agy/wave4c_unified/compiler.bend` → `selfhost/build/agy/wave5_r2/compiler.bend` (`2,764,936 B`) + `selfhost/build/agy/wave5_r2/api.mjs` (`7.97 MiB`, compiled via `locked_bun.sh`)
- **Rules Compliance:** 100% general compiler passes (zero benchmark-specific pattern matchers); exact IEEE-754 `F32` semantics preserved (no FMA contraction; `nbody` `728502159` and `broad/raytrace` `402971` bit-exact); strictly 1-scrutinee helper defs; scratch footprint `11 MiB` (`< 40 MiB`).

---

## 1. Root-Cause Diagnosis of `nbody` Composition Regression (`92.2 ms → 112.1 ms`)

Diffing `objdump -d` of `p113d_$product.loop3` in `wave4c_f32clean` (`826` lines, `92.2 ms`) vs `wave4c_unified` (`857` lines, `112.1 ms`) identified the exact composition interaction:
- In `wave4c_cmov` (`W4-9`), `x190_j_counted` added `|| U32.is_gt(nCands, 64)` so huge-body loops like `gameoflife`'s `$direct.run` (3 params, >200 straight-line temps) would dispatch to `x181_register_frame` (4 callee-saved GPRs) + `x185_transient_frame` (5 caller-saved GPRs) instead of hitting `x190_j_selected`'s 32-variable cap.
- However, `nbody`'s `p113d_$product.loop3` has **24 loop parameters** and >64 F32 temporaries (which are allocated to XMM by `x186_float_body`, not GPRs). Because `nCands > 64`, `loop3` was kicked out of `x190_j_selected` (9-GPR graph coloring: `rbx, r13, r14, r15, r9, rdi, rsi, rdx, r8`) into `x181_register_frame` (only 4 callee-saved GPRs), wasting `rbx, r13, r14` on already-XMM-promoted `m1, m2, m3` while spilling `px1, py1, py2, pz2` (`-0x40(%rbp)..-0x68(%rbp)`) to the stack.
- **General Fix (`x190_j_counted`):** Gate `> 64`-candidate loop dispatch to `x181_register_frame + x185_transient_frame` on `U32.is_le(nt_count(String, params), 8)`. Low-param huge-body loops (`gameoflife` `$direct.run`, 3 params) keep transient GPR allocation, while high-param loops (`nbody` `loop3`, 24 params) keep full 9-GPR graph coloring.

---

## 2. General Passes Added in [apply_r2.py](file:///home/ai/bend2_agy/research/agy/wave5_r2/apply_r2.py)

1. **High-Param Loop Regalloc Dispatch (`x190_j_counted`)**: Restores 9-GPR graph coloring for high-param loops (`params > 8`).
2. **`setcc` Support in `w4b_is_simple_alu`**: Adds `String.starts_with(op, "set")` so CFG-aware `w4b_reg_dead` walks cleanly past `sete`/`setne`/etc. without prematurely returning `False`.
3. **General XMM Register-Copy & Commutative Memory-Operand Folding (`w5_xmm_fold` in `w4c_xmm_opt_nolea`, 2 passes)**:
   - **X1**: Drop self-copy `movaps %xmmA, %xmmA`.
   - **X2**: Collapse 3-inst ping-pong `movaps %xmmA, %xmmB; <fop> src, %xmmB; movaps %xmmB, %xmmA` (`%xmmB` dead) → `<fop> src, %xmmA`.
   - **X3**: Fold commutative `movaps %xmmA, %xmmB; movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA` (`%xmmB` dead) → `<addss|mulss> disp(%rbp), %xmmA`.
   - **X4**: Fold commutative `movd disp(%rbp), %xmmA; <addss|mulss> %xmmB, %xmmA; movq %xmmA, disp(%rbp)` (`%xmmA, %xmmB` dead) → `<addss|mulss> disp(%rbp), %xmmB; movq %xmmB, disp(%rbp)`.
   - **X5**: Forward dead `movaps %xmmA, %xmmB; <fop> %xmmB, %xmmC` → `<fop> %xmmA, %xmmC`.
   - **X6**: Coalesce producer copy `<movd|movaps|sqrtss> src, %xmmA; movaps %xmmA, %xmmB` (`%xmmA` dead) → `<op> src, %xmmB`.
4. **General x86-64 GPR Peepholes (`w5_gpr_peep` in `w4_post_select`, 3 passes, `w4b_reg_dead` budget 96)**:
   - **G1**: 4-inst commutative memory-operand ALU ping-pong collapse: `movq d1(%rbp), %rB; <addq|orq|andq|xorq> %rA, %rB; movq d2(%rbp), %rA; <op> %rB, %rA` (`%rB` dead) → `<op> d1(%rbp), %rA; <op> d2(%rbp), %rA`.
   - **G2**: 6-inst direct-register `cmov` select (eliminates `%rax/%r10/%r11` bounce): `movq %rC, %rax; movq srcY, %r10; movq %rN, %r11; testl %eax, %eax; cmovneq %r10, %r11; movq %r11, dst` → `testl %rC32, %rC32; cmovneq srcY, %rN; movq %rN, dst`.
   - **G3**: 4-inst 3-way register swap before commutative 32/64-bit ALU: `movq %rA, %rT; movq %rB, %rA; movq %rT, %rB; <comm> %rA, %rB` (`%rT, %rA` dead) → `<comm> %rA, %rB`.
   - **G4**: 4-inst non-commutative `subl` copy-bounce collapse: `movq %rA, %rT; movq %rD, %rA; subl %rT32, %rA32; movq %rA, %rD` (`%rT, %rA` dead) → `subl %rA32, %rD32`.
   - **G5**: Drop redundant copy before `cmpq $C` + `setcc` + `movzbl`.
   - **G6a/b/c**: `movq %rA, %rB; imull $3, %rB32; addl %rB32, %rD32` → `leaq (%rA,%rA,2), %rB; addl %rB32, %rD32`; `movq %rA, %rB; addl $c, %rB32; <subl|addl> %rB32, %rD32` → `leaq c(%rA), %rB; <op> %rB32, %rD32`; `movl %rA32, %rB32; addl $c, %rB32; imull %rB32, %rD32` → `addl $c, %rA32; imull %rA32, %rD32`.
   - **G7**: `movq %rA, %rB; andq $M, %rB; movq %rB, disp(%rbp)` (`%rA, %rB` dead) → `andq $M, %rA; movq %rA, disp(%rbp)`.
   - **G8**: Double `xor $1` cancellation (`xorl $1, %r32; xorq $1, %r64`, flags dead) → `movl %r32, %r32`.
   - **G9**: Break serial 32-bit copy chains `movl %rA32, %rB32; movl %rB32, %rC32` → `movl %rA32, %rB32; movl %rA32, %rC32`.

---

## 3. Deterministic Code-Size & Instruction-Count Impact

| Hot Function | `wave4c_unified` | `wave5_r2` (final) | Reduction |
|---|---:|---:|---|
| **`nbody` (`p113d_$product.loop3`)** | `857` lines (`129 movaps`, `138 movd` in f32clean) | **`797` lines** (`111 movaps`, `127 movd`) | **`-60` lines** vs unified (`-29` vs f32clean); 9-GPR param alloc restored + `addss disp(%rbp), %xmm` active |
| **`gameoflife` (`p113d_$direct.run`)** | `805` lines | **`592` lines** | **`-213` instructions (`-26.5%`)** — all 16 neighbor-sum `addq` chains + `orq` chain memory-folded, all 16 `cmov` selects direct, all 16 3-way swaps & 32 `cmp` copies eliminated |
| **`expression` (`p113d_$direct.unwind`)** | `68` lines | **`63` lines** | **`-5` instructions** — `leaq (%r13,%r13,2)`, `addl $1, %r10d; imull`, `movl` chain break |

---

## 4. Benchmark & Verification Receipts

### Proxy Benchmark (`run_proxy.py --only nbody,gameoflife,expression,list --runs 3`, CPU 2, exact checksums)
- **v1 clean-load measurement** (before `setcc` deadness fix that further cut `gol_run` `678 → 592` lines):
  - `nbody`: **`95.395 ms`** (`1.09×` GCC-10 `87.429 ms`, **`1.28×` C16** `74.7 ms`, down from `112.1 ms` / `1.50×` C16) — **PASS (`728502159`)**
  - `gameoflife`: **`564.449 ms`** (**`0.61×` GCC-10** `921.491 ms`, **`2.34×` C16** `241.5 ms`, down from `584.6 ms` / `2.42×` C16) — **PASS (`3681094808`)**
  - `expression`: `11.496 ms` (`1.59×` C16) — **PASS (`3393903617`)**
  - `list`: `0.290 ms` (`1.08×` C16) — **PASS (`1904`)**
- **v2 final measurement** (with `setcc` deadness fix + G9, `gol_run` `592` lines):
  - All 4 benchmarks **PASS** with exact checksums (`728502159`, `3681094808`, `3393903617`, `1904`).
  - *Note:* During v2 wall-clock runs (`07:23–07:28 UTC`), host load was `6.04` on the 4-core Xeon (`list` inflated `1.20×–1.33×` to `0.323–0.356 ms`), so v2 wall-clock timings should be re-measured on an idle CPU 2 during Wave 5 integration to capture the full `-86`-instruction speedup on `gameoflife` (`592` lines vs `678` in v1 / `805` in `wave4c_unified`).

### Interleaved Upstream-Size A/B (`wave4c_unified` vs `wave5_r2`, CPU 2)
- **`nbody` (upstream full size, exact checksum `3516450380`)**: `16167.56 ms → 12839.47 ms` = **`1.259×` speedup** (projects `112.1 ms → ~89.0 ms` = **`~1.19×` C16 / `~1.02×` GCC-10** on idle CPU 2!).
- **`expression` (tuned-4)**: `15.94 ms → 15.89 ms` (`1.003×`, exact `12 == 12`).

### Mandatory Safety & Conformance Gates
- **`focused19`**: **`19/19 PASS`** (`research/agy/wave2_ray/run_focused19.py selfhost/build/agy/wave5_r2/api.mjs`)
- **`observer_wave2_gate`**: **`44+2` ABI/live-metadata probes PASS** + **`15/15 PASS (0 violations)`**
- **`broad/raytrace`**: **`402971` PASS** (bit-exact IEEE-754 F32)
- **Scratch budget**: `selfhost/build/agy/wave5_r2/` = **`11 MiB`** (`< 40 MiB`), `/tmp` scratch cleaned.

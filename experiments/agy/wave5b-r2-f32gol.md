# Wave 5B Engine B — Track W5B-R2: General F32/Bitwise Closer (`gameoflife`, `nbody`, `expression`)

- **Date:** 2026-11-22
- **Composable Patcher:** [apply_w5b_r2.py](file:///home/ai/bend2_agy/research/agy/wave5b_r2/apply_w5b_r2.py) (`--src <in> --dst <out>`)
- **Base → Output:** `selfhost/build/agy/wave5a_unified/compiler.bend` → `selfhost/build/agy/wave5b_r2/compiler.bend` (`2,886,752 B`) + `selfhost/build/agy/wave5b_r2/api.mjs` (`11 MiB` total dir, `< 20 MiB` budget)
- **Compliance:** 100% general compiler passes (zero benchmark-specific symbol/shape matchers); zero edits to `runtime.c` / `runtime-agy.o`; untouched final holdouts (`queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap`); exact IEEE-754 `F32` semantics preserved (`sqrtss` verified `diffs=0` vs libm `sqrtf` across all 10 IEEE-754 classes: `+0, -0, +1, -1, +inf, -inf, +qNaN, -qNaN, sNaN, -subnormal`).

---

## 1. General Compiler Passes Implemented

1. **Direct IEEE-754 `sqrtss` Emission (`x200r_sqrt_core`, `x195s_text`)**:
   - Replaces the 9-instruction `pxor/ucomiss/ja/sqrtss/jmp/call p200_rt_f32_sqrt_keep/movd/movd` wrapper with direct `sqrtss %xmm0, %xmm0` (bit-exact IEEE-754 on x86-64 SSE; Bend has no C `errno`).
   - Eliminates 18 instructions and 6 branches per iteration of `nbody`'s `$product.loop3` and turns F32-`sqrt` loops into true leaf functions (`hasCall = False`).
2. **Loop-Exit Condition Priority & Rotation Exit-Block Budget (`x191_loop_join`, `w4c_rotate_check_{test,cmp}`)**:
   - Gives loop-exit controlling branch conditions (where exactly one arm reaches `Again`) higher loop-read profitability priority in `x191_loop_join` and raises `w5_take_exit_gen` budget `256 → 512`.
3. **Cycle-Aware + `setcc; movzbl` Overwrite-Aware CFG Register Deadness (`w4b_reg_dead_step`)**:
   - Tracks visited labels (`seen: List<&2,String>`) on the DFS stack (revisiting a label without reading `r` proves `r` dead along that cycle, greatest fixpoint, `hops 4 → 8`).
   - Recognizes `<setcc> %r8; movzbl %r8, %r32` as a full 64-bit overwrite of `%r` (no prior value read), unlocking dead-register peepholes across `setcc` boundaries.
4. **General Leaf-Function Free-GPR Stack-Slot Promotion (`w5b_leaf_slot_promote` in `w4_post_select`)**:
   - On leaf functions (`!hasCall && hasNegRbp && !hasLeaqRbp`), detects completely unused `%rcx` and/or dead-`ctx` `%r12` (only callee-save/restore + unused `movq %rdi, %r12`), scans 64-bit GPR-only `-disp(%rbp)` slots (`disp <= -48`, with 8× weight on loop-header loads), and promotes the hottest eligible slots into `%rcx` / `%r12`.
   - In `gameoflife` (`$direct.run`), promotes the 2 hottest board-bit slots into `%rcx` and `%r12` (`-20` stack memory ops/iter). In `nbody` (`$product.loop3`), promotes the loop counter `s` (`-0x38(%rbp)`) into `%r12`.
5. **Extended General XMM & GPR Peepholes (`w5_xmm_fold`, `w5_gpr_peep`)**:
   - **X2-self**: Allows `fsrc == %xmmA` in `w5_x2_c` (`movaps A,B; mulss A,B; movaps B,A` → `mulss A,A`).
   - **X7 / X9**: Dead-source in-place 1-op / 2-op SSE chains ending in `movq %xmmB, d(%rbp)`.
   - **X8**: Forward dead `movaps A,B` across an intervening `movaps C,D` into `<fop> B,D`.
   - **G1-gen**: Generalizes `w5_g1` to accept `{d(%rbp), %rC}` in both source positions (`mem+mem`, `mem+reg`, `reg+mem`, `reg+reg`), collapsing `mov %rcx/%r12, %rdi; add %rsi, %rdi` chains after slot promotion.
   - **G7-shift**: Extends `w5_g7` (`movq A,B; <op> $k,B; movq B,d(%rbp)`) to `shlq` and `shrq`.
   - **G10**: Collapses dead copy chains `movq A,B; movq B,C` → `movq A,C` (and drops `movq A,B; movq B,A`).
   - **G12**: Folds `cmpq $0, %rC; sete %rC8; movzbl %rC8, %rC32; ... testl %rC32, %rC32; cmov(n)eq src, dst` (`%rC` untouched & dead) → `testq %rC, %rC; cmov(n)eq_inv src, dst` (`-48` instructions in `gameoflife`).
   - **G15**: Folds `movq d1(%rbp), %rA; movq d2(%rbp), %rB; <comm64> %rA, %rB` (`%rA` dead) → `movq d2(%rbp), %rB; <comm64> d1(%rbp), %rB`.

---

## 2. Deterministic Code-Size & Instruction-Count Impact

| Hot Function | `wave5a_unified` | `wave5b_r2` (v4) | Delta |
|---|---:|---:|---|
| **`gameoflife` (`$direct.run`)** | `584` lines (`181` `(%rbp)`) | **`481` lines (`161` `(%rbp)`)** | **`-103` instructions (`-17.6%`), `-20` stack ops/iter** |
| **`nbody` (`$product.loop3`)** | `786` lines (`111 movaps`, `127 movd`) | **`722` lines (`100 movaps`, `121 movd`)** | **`-64` instructions**, 0 `sqrtf` calls/branches, `s` in `%r12` |
| **`expression` (`$direct.unwind`)** | `62` lines | **`57` lines** | **`-5` instructions** (`lea 7(%r13),%rdi; sub %edi,%ebx`) |

---

## 3. Benchmark & Verification Receipts

### Interleaved A/B on CPU 2 (`wave5a_unified` vs `wave5b_r2`, 5 rounds, exact checksums)
| Benchmark | `wave5a_unified` | `wave5b_r2` (v4) | Speedup | vs GCC-10 | vs Clang-16 | Checksum |
|---|---:|---:|---:|---:|---:|---|
| **`gameoflife`** | `490.55 ms` | **`449.01 ms`** | **`1.093×`** | **`0.49×`** | **`1.86×`** | `3681094808` (EXACT) |
| **`nbody`** | `93.36 ms` | **`91.95 ms`** | **`1.015×`** | **`1.05×`** | **`1.23×`** | `728502159` (EXACT) |
| **`expression`** (proxy v2/v4) | `10.60 ms` | **`10.02 ms`** | **`1.058×`** | `1.60×` | **`1.38×`** | `3393903617` (EXACT) |

### Full 7-Family Proxy (`run_proxy.py --runs 3`)
- All 7 families **PASS** (`histogram`, `gameoflife`, `nbody`, `list`, `expression`, `bst`, `editdist`) with 100% exact checksums; `list` `0.238 ms` (`0.88×` C16).

### Mandatory Safety, Conformance & Compile-Time Gates
- **`focused19`**: **`19/19 PASS`** (`research/agy/wave2_ray/run_focused19.py`)
- **`observer_wave2_gate`**: **`44+2` ABI/live-metadata probes PASS** + **`15/15 PASS (0 violations)`** (`research/agy/wave3_fuzz/observer_wave2_gate.py`)
- **`raytrace` (F32 bit-exact)**: **`1924309504` PASS** (`phase37/fixtures-historical/raytrace.bend`)
- **`bench_compile.py`**: `TOTAL = 22.62 s` (`plan = 3.04 s`, `emit = 19.53 s`; `nbody = 2.56 s`, `gameoflife = 5.56 s`, `raytrace = 2.77 s`) — **zero compile-time regression**.
- **Disk budget**: `selfhost/build/agy/wave5b_r2/` = **`11 MiB`** (`< 20 MiB`), `/tmp` scratch cleaned.

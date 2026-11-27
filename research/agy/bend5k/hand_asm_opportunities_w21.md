# Wave-21 Verified Hand-ASM Ceiling Probes & General Compiler Laws

- **Host / Pin**: Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge: `sse4_1`, `sse4_2`, `popcnt`, `avx`), pinned via `taskset -c 5`, 5-run medians (1 warmup + 5 timed runs).
- **Compiler Baseline**: Proven-20 `bend5k_o2 -O2` (`sha256: b0b265e9...`, base commit `89d393d6`), linked against unmodified `runtime-agy.o` (`sha256: afdcbaa7...`).
- **C Oracles**: `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
- **Verification Methodology**: Every hand-assembled x86-64 (`.S`) probe redirects **only** its target hot symbol(s) inside the unmodified Proven-20 ELF64 `.o` via `SHT_SYMTAB` `SHN_UNDEF` redirection, runs inside the unmodified Bend runtime with **0 ABI changes** (exact 64-bit `Array<T>` slots and tagged record handles), and is gated on **bit-identical U32 stdout checksum** against both C oracles.
- **Reproducible Artifacts**:
  - Runner: `research/agy/bend5k/hand_asm_w21/run_probes.py`
  - Verified JSON: `research/agy/bend5k/asm_ceiling_probes_w21.json`
  - Probes (`.S`): `research/agy/bend5k/hand_asm_w21/probes/`
  - Fresh Non-Suite Kernels (`.bend` + `.c`, all passing `locked_bun.sh --check-only`): `research/agy/bend5k/hand_asm_w21/kernels/`

---

## 1. Executive Summary Table (CPU 5, 5-Run Medians)

| # | Workload | Pool | Checksum | Proven-20 `bend5k_o2` | `gcc-10 -O2` | `gcc-10 -O3 -march=native` | Best Hand-ASM Probe (0 ABI change) | Speedup vs Proven-20 | Probe vs C-O2 | Probe vs C-O3-nat |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | `t4_utf8_state_machine` | W20 Test-Sealed | `1748043129` | 117.79 ms (`8.91×` / `11.05×`) | 13.22 ms | 10.66 ms | **16.84 ms** (`b_branchless_cp_dfa`) | **7.00×** | 1.274× | 1.580× |
| 2 | `t2_poly_eval_f32` | W20 Test-Sealed | `1184144837` | 121.60 ms (`1.25×` / `6.82×`) | 97.12 ms | 17.84 ms | **19.48 ms** (`b_avx1_8wide_64bit_slots`) | **6.24×** | **0.201×** | **1.092×** |
| 3 | `v3_base64_codec` | W20 Validation | `2753502860` | 46.15 ms (`5.20×` / `5.08×`) | 8.87 ms | 9.08 ms | **9.23 ms** (`a_inline_64b_lut_hoist`) | **5.00×** | **1.041×** | **1.017×** |
| 4 | `t1_rle_lz_hash` | W20 Test-Sealed | `284161573` | 68.73 ms (`2.22×` / `2.40×`) | 30.91 ms | 28.67 ms | **34.64 ms** (`a_unbox_dual_hoist`) | **1.98×** | **1.121×** | **1.208×** |
| 5 | `k1_varint_decode` | Fresh Non-Suite | `3101729924` | 44.48 ms (`2.15×` / `2.25×`) | 20.68 ms | 19.73 ms | **20.60 ms** (`a_unbox_hoist_rol`) | **2.16×** | **0.996×** | **1.044×** |
| 6 | `k2_csr_spmv` | Fresh Non-Suite | `1512865573` | 33.57 ms (`3.29×` / `3.43×`) | 10.20 ms | 9.78 ms | **13.67 ms** (`a_quad_hoist_inline`) | **2.46×** | 1.340× | 1.398× |
| 7 | `k3_soa_particle_acc` | Fresh Non-Suite | `892493655` | 69.78 ms (`5.25×` / `10.04×`) | 13.29 ms | 6.95 ms | **12.18 ms** (`b_avx1_8wide_64bit_slots`) | **5.73×** | **0.916×** | 1.753× |

### Staged Variant Breakdown (Decomposing Speedup Factors)
- **`t4_utf8_state_machine`**: `117.79 ms` -> `17.11 ms` (**6.88×** from `.rodata` LUTs + `URes` unboxing + `buf` hoist) -> `16.84 ms` (**7.00×** adding branchless `cmovne` for `next_cp`). Remaining ~6 ms over `gcc -O3` (`10.66 ms`) is Bend startup + unprobed `fill_bytes` + 8-byte array slot stride.
- **`t2_poly_eval_f32`**: `121.60 ms` -> `103.34 ms` (**1.18×** from scalar XMM constant hoisting + `SPair`/array hoisting, hitting `1.064×` vs `gcc -O2`) -> **`19.48 ms`** (**6.24×** total, **5.30×** pure AVX1 gain over scalar XMM!) using 8-wide AVX1 (`ymm`) directly over Bend's 64-bit `Array<F32>` slots (`1.092×` vs `gcc -O3 -march=native`, **0 ABI change**).
- **`k3_soa_particle_acc`**: `69.78 ms` -> `18.02 ms` (**3.87×** from quad-array hoist + `P4` unboxing + scalar XMM, eliminating `7× p113_rt_array_pair` + `7× p111_rt_op`) -> **`12.18 ms`** (**5.73×** total, beating `gcc -O2` at `0.916×`!) using 8-wide AVX1 over 64-bit slots. Remaining gap vs `gcc -O3` (`6.95 ms`) is L2 working-set doubling (4 arrays × 16384 × 8B = 512 KB > 256 KB Ivy Bridge L2 vs 256 KB in C) + 64-bit slot gather/scatter shuffles.

---

## 2. Mechanical Root-Cause Disassembly Analysis

### 1. `t4_utf8_state_machine` (`$direct.scan_utf8`: 117.79 ms -> 16.84 ms, **7.00×**)
- **Proven-20 Disassembly**: `insns=1405, spills=116, jcc=133, rodata=0`, `p111_rt_ctor=3`, `p113_rt_array_pair=1`.
- **Root Causes**:
  1. **`.rodata` LUT recognizer completely failed on both `cls_lut` (32 cases) and `trans_lut` (32 cases)**: `objdump` shows `rodata=0, jcc=30` in BOTH `cls_lut` and `trans_lut`. Even after inlining into `scan_utf8`, they expanded into **two 30-branch linear `cmp/jne` chains** (60+ data-dependent branches per byte!). Why? Both tables contain repeated constants (`0`, `1`, `4`) and `0`-valued arms; CSE/constant-sharing turned arm return literals into register copies, breaking the literal-`IConst`-only LUT recognizer.
  2. **Loop-carried 6-field record re-boxing**: `URes{buf, st, cp, h, valid, errs}` is unboxed and re-allocated (`p111_rt_ctor` ×3, `p111_cid_hot` ×3) on every byte, causing **116 stack spills**.
  3. **Un-hoisted array**: `buf` is unpacked from `URes` and passed to `dfa_step`, leaving `p113_rt_array_pair` inside the loop.
- **Hand-ASM Ceiling**: Replacing both tables with 32-byte `.rodata` tables + register-allocated `URes` fields + hoisted `buf` cuts the loop from 1,405 instructions / 133 `jcc` / 116 spills to **35 instructions / 5 `jcc` / 0 spills**, yielding **7.00×** speedup (`16.84 ms`, `1.27×` C-O2).

### 2. `t2_poly_eval_f32` (`$direct.sweep_arr`: 121.60 ms -> 19.48 ms, **6.24×**)
- **Proven-20 Disassembly**: `insns=1210, spills=33, jcc=61, simd=0`, `p111_rt_ctor=2`, `p111_rt_op=2`, `p113_rt_array_pair=1`.
- **Root Causes**:
  1. **Scalar 1-wide F32 vs 8-wide AVX1 (`5.30×` of the `6.24×` gap)**: Each element performs 4 Newton-Raphson iterations = 56 FP ops + 4 `divss`. On Ivy Bridge, `divss` has 14-cycle latency / 7-cycle throughput, whereas 8-wide `vdivps %ymm` computes 8 floats in 21 cycles (2.6 cycles/float), and `vmulps`/`vaddps`/`vsubps` are 8× wider.
  2. **Scalar loop overhead (`1.18×` of the `6.24×` gap)**: Proven-20 reloads all 14 F32 constants via `mov $imm, %eax; movd %eax, %xmm` on every element, bounces `p` through GP `%esi` (`movd %xmm0, %esi`), re-boxes `SPair{xs, out}` (`p111_rt_ctor` ×2), and calls `p111_rt_op` for `Array.set`.
- **Hand-ASM Ceiling**: Even **without changing Bend's 64-bit `Array<F32>` slot layout**, gathering 8 F32s via `vmovups`+`vshufps $0x88`+`vinsertf128` and scattering via `vunpcklps`/`vunpckhps` reaches **19.48 ms** (**6.24×** speedup, **0.201×** vs `gcc -O2`, **1.092×** vs `gcc -O3 -march=native`).

### 3. `v3_base64_codec` (`$direct.scan_groups`: 46.15 ms -> 9.23 ms, **5.00×**)
- **Proven-20 Disassembly**: `scan_groups` has `insns=819, spills=85, jcc=58`, **`$direct.b64_lut` called 8 times (4 per path)**, `p113_rt_array_pair=3`, `p111_rt_ctor=2`.
- **Smoking-Gun Anti-Overfitting Catch in `$direct.b64_lut`**:
  - `objdump` of `$direct.b64_lut` reveals `cmp $0x2b, %r8; jae 34902; lea .rodata(%rip), %rax; mov (%rax,%r8,4), %eax` followed by a **20-branch linear `cmp/jne` chain for indices `43..63`** (`jcc=20`)!
  - Why did the `.rodata` LUT recognizer truncate at index `43` (`0x2b`)? At arm 52 (`0x34`), the return value is `48` (`0x30`), which collided with an earlier comparison constant `0x30` in `%r11`; CSE replaced the literal `IConst 48` with a register copy (`mov %r11, %rax`), aborting the `IConst`-only LUT collector for all remaining arms `43..63`!
  - Furthermore, because `b64_lut` was bloated to 106 instructions by the truncated branch tail, the inliner refused to inline it into `encode_word` / `scan_groups`, causing **4.81M out-of-line function calls** + 85 spills in `scan_groups`.
- **Hand-ASM Ceiling**: Fixing the 64-entry `.rodata` table + inlining the 3-instruction lookup + unboxing `(buf, h)` + hoisting `buf` reaches **9.23 ms** (**5.00×** speedup, **1.017×** vs `gcc -O3 -march=native` — matching C!).

### 4. `t1_rle_lz_hash` (`$direct.scan_lz`: 68.73 ms -> 34.64 ms, **1.98×**)
- **Proven-20 Disassembly**: `insns=1059, spills=101, jcc=75`, `p113_rt_array_pair=6`, `p111_rt_ctor=2`.
- **Root Causes**:
  1. **Dual-array hoisting failure across continuation chain**: `src` and `ht` are carried inside `LSt{src, ht, h}` and threaded through 5 continuation helpers (`step_s0 -> step_s1 -> step_s2 -> step_ht -> step_sp`). Proven-20 fails to hoist `ht` (and emits `6× p113_rt_array_pair` slow-path guards) and re-boxes `LSt` on every step.
  2. **101 stack spills** from keeping live intermediate handles across the unhoisted guards.
- **Hand-ASM Ceiling**: Unboxing `LSt{src, ht, h}` + hoisting BOTH `src` and `ht` bases once in the preheader eliminates all 101 spills and all `p113_rt_array_pair` / `p111_rt_ctor` calls, hitting **34.64 ms** (**1.98×** speedup, `1.121×` C-O2 / `1.208×` C-O3-native).

### 5. `k1_varint_decode` (Fresh Kernel 1, `$direct.scan_varint`: 44.48 ms -> 20.60 ms, **2.16×**)
- **Proven-20 Disassembly**: `insns=607, spills=43, jcc=26`, `p111_rt_ctor=2`, `p113_rt_array_pair=1`.
- **Root Causes**:
  - Proven-20 unboxed `VSt`'s *entry parameters* of `scan_varint`, **but still re-boxed `VSt` inside the loop** via `step_byte_branch` (`p111_rt_ctor=2`) and spilled 43 times!
  - Additionally, `(x << 13) | (x >> 19)` in `mix32` is lowered to 3 instructions instead of a single 1-cycle `roll $13`.
- **Hand-ASM Ceiling**: Eliminating per-step `VSt` re-boxing + hoisting `buf` + `roll $13` reaches **20.60 ms** (**2.16×** speedup, **0.996×** vs `gcc -O2` / `1.044×` vs `gcc -O3 -march=native`).

### 6. `k2_csr_spmv` (Fresh Kernel 2, `$direct.scan_rows` + `$direct.scan_edges`: 33.57 ms -> 13.67 ms, **2.46×**)
- **Proven-20 Disassembly**:
  - `$direct.scan_rows`: `insns=1428, spills=88, jcc=138`, `p111_rt_ctor=2`, `p113_rt_array_pair=2`, calls `$direct.scan_edges` out-of-line on every row (655k calls!).
  - `$direct.scan_edges`: `insns=407, spills=38, jcc=22`, `p111_rt_ctor=1`, `p113_rt_array_pair=3`.
- **Root Causes**:
  - **Multi-array hoisting failure (4 arrays: `row_ptr`, `col_idx`, `vals`, `x`)**: Every row allocates an `EAcc{col_idx, vals, x, sum}` record, calls `scan_edges`, re-decodes 3 array handles inside `scan_edges`, and allocates `EAcc` on every edge.
- **Hand-ASM Ceiling**: Hoisting all 4 array bases once before the outer row loop + inlining `scan_edges` + eliminating `CSt`/`EAcc` hits **13.67 ms** (**2.46×** speedup, `1.34×` C-O2; remaining 3.5 ms is L2 working-set doubling from 64-bit array slots + `fill_*` startup).

### 7. `k3_soa_particle_acc` (Fresh Kernel 3, `$direct.integrate`: 69.78 ms -> 12.18 ms, **5.73×**)
- **Proven-20 Disassembly**: `insns=2036, spills=63, jcc=102, simd=0`, `p113_rt_array_pair=7`, `p111_rt_op=7`, `p111_rt_ctor=2`.
- **Root Causes**:
  1. **Quad-array hoisting failure + `P4` record re-boxing (`3.87×` scalar gap)**: `Array.get` + `Array.set` across 4 parallel `Array<F32>`s (`px, py, vx, vy`) emits `7× p113_rt_array_pair` + `7× p111_rt_op` + `2× p111_rt_ctor` per particle!
  2. **Scalar vs 8-wide AVX1 (`1.48×` additional speedup -> `5.73×` total)**: Vectorizing the 4-array SoA F32 update to 8-wide `ymm` over Bend's 64-bit slots reaches **12.18 ms** (**0.916×** vs `gcc -O2`!).

---

## 3. Top 5 General Compiler Laws for Wave 22 & `law_gate.py`

Every law below is **algorithm-agnostic**, directly falsifiable via `objdump -dr` structural metrics in `law_gate.py`, and proven by our verified hand-ASM probes to close `2×`–`7×` gaps across both retired Wave-20 suites and brand-new non-suite kernels.

### Law L22-1: Complete `.rodata` LUT Lowering (Pre-CSE & Unbounded) + Mandatory Leaf LUT Inlining
- **Root Cause Fixed**: In Proven-20, `.rodata` LUT lowering runs *after* CSE/constant-sharing (or rejects `0`/duplicate constants), causing **complete failure** on `t4` (`cls_lut`, `trans_lut`: 30 branches each, `rodata=0`) and **mid-table truncation at index 43** on `v3` (`b64_lut`: 20-branch tail, `insns=106`), which in turn prevents leaf inlining into hot loops.
- **General Compiler Pass**:
  1. Run dense `Nat`-match constant-table recognition **before** CSE/constant-sharing (or resolve `ICopy`/shared-constant arms back to their compile-time `U32` constant), with no arbitrary small table cap (support up to 256+ entries, `0`-valued arms, duplicate values, and full 32-bit unsigned constants).
  2. Always emit compact `.byte` (when `max <= 255`) or `.long` `.rodata` tables with a single `cmp $N; jae default; movzbl/mov (%rax,%idx), %eax`.
  3. **Inline** any lowered leaf `.rodata` LUT function directly into hot loop callers (4 instructions vs function call overhead + register clobbering).
- **Verified Speedup Ceiling**: **`5.00×`** on `v3_base64_codec` (`46.15 -> 9.23 ms`, `1.017×` C-O3-nat); **`~4–5×`** of the `7.00×` speedup on `t4_utf8_state_machine`.
- **Generalizes To**: UTF-8/JSON/regex DFAs, Base64/hex/URL codecs, CRC/AES S-boxes, Huffman/varint length tables, bytecode decoders.
- **Falsifiable `law_gate.py` Contract**: On a holdout 64-entry LUT with `0`-valued arms, repeated constants, and values colliding with arm indices (`v3` pattern + `t4` 32-entry DFA pattern):
  - `rodata_relocs >= 1`, `jcc <= 2` in the LUT function (0 linear branch tail).
  - `0` out-of-line `call`s to leaf LUT helpers inside the calling loop.
- **Estimated Scope**: ~45 LOC.

### Law L22-2: Multi-Array Preheader Hoisting & Continuation-Chain Fusion (N-Array SoA / CSR / LZ)
- **Root Cause Fixed**: Proven-20's Linear-Array Hoist (Law 4) only hoists a single top-level array parameter and breaks down whenever 2–4 arrays are unpacked from a loop-carried record (`LSt{src,ht,h}`, `SPair{xs,out}`, `CSt{row_ptr,col_idx,vals,x,h}`, `P4{px,py,vx,vy}`) or threaded through linear continuation helpers (`step_b0 -> step_b1 -> step_b2`, `step_s0 -> ... -> step_sp`). Result: `3–7× p113_rt_array_pair` + `2–7× p111_rt_op` per iteration!
- **General Compiler Pass**:
  1. Inline single-use linear continuation chains (`Array.get`/`Array.swap`/`Array.set` wrappers) into the enclosing self-TCO loop **before** array-hoist analysis.
  2. Hoist **all** loop-invariant `Array<T>` handles (whether direct parameters or fields of a loop-carried single-constructor record, up to K=8 arrays) into loop-preheader `(base_ptr, mask)` registers, lowering both `Array.get` and linear `Array.set`/`Array.swap` to direct `mov (%base,%idx,8)` / `mov %val, (%base,%idx,8)` with zero `p113_rt_array_pair` / `p111_rt_op` calls in the hot loop.
- **Verified Speedup Ceiling**: **`1.98×`** on `t1_rle_lz_hash`, **`2.46×`** on `k2_csr_spmv`, **`3.87×`** scalar on `k3_soa_particle_acc`.
- **Generalizes To**: LZ77/hash-table compressors, CSR/CSC sparse graph & matrix kernels, SoA physics/audio/image pipelines, multi-buffer codecs.
- **Falsifiable `law_gate.py` Contract**: On holdout 2-array (`Array.get` + `Array.swap`) and 4-array (`SoA` read+write) loops inside a single-constructor record:
  - `0` `p113_rt_array_pair` and `0` `p111_rt_op` calls in the hot loop.
  - `preheader_array_decodes >= N_arrays`.
- **Estimated Scope**: ~80 LOC.

### Law L22-3: Full Single-Constructor Record Unboxing Across Self-TCO Loops & Branch-Merging Helpers
- **Root Cause Fixed**: Even when a function's *entry* is unboxed (as in `k1_varint_decode`), any branching helper (`step_byte_branch`, `dfa_update`, `sweep_step`) that returns a single-constructor record (`URes`, `VSt`, `LSt`, `SPair`, `P4`, `EAcc`) causes Proven-20 to emit `p111_rt_ctor` + `p111_cid_hot` + `p111_program` checks on every iteration, triggering 40–116 stack spills.
- **General Compiler Pass**:
  - When a self-TCO loop carries a single-constructor record `R{f0..fk}` (uniquely owned and returned on exit), unbox `f0..fk` into SSA loop-carried registers across the **entire** loop body (including inlined multi-branch helpers like `dfa_update` / `step_byte_branch`), and mutate/construct `R` **only once** at the loop exit (`case 0n:`).
  - For nested loops where an inner loop returns a transient record (`EAcc` in `k2_csr_spmv`), inline the inner loop or return multi-scalar values without heap-boxing the transient record.
- **Verified Speedup Ceiling**: **`2.16×`** on `k1_varint_decode` (`44.48 -> 20.60 ms`, `0.996×` C-O2); essential enabler for `t4` (`7.00×`), `t1` (`1.98×`), `k2` (`2.46×`), `k3` (`3.87×` scalar).
- **Generalizes To**: Every stateful scanner, parser, lexer, DFA, varint/TLV decoder, and multi-accumulator loop in pure functional Bend.
- **Falsifiable `law_gate.py` Contract**: On a holdout 5-field single-constructor record carried across a branching self-TCO loop:
  - `0` `p111_rt_ctor` calls in the loop body (at most 1 at loop exit).
  - `spills <= 8` in the hot loop.
- **Estimated Scope**: ~75 LOC.

### Law L22-4: Auto-Vectorized 4-Wide SSE / 8-Wide AVX1 F32 Loops Over Unmodified 64-Bit Slots
- **Root Cause Fixed**: Proven-20's SIMD pass (Contract H) only recognizes a narrow `nbody`-like inner reduction shape and emits `simd=0` on general element-wise `Array<F32> -> Array<F32>` map/sweep/SoA loops (`t2_poly_eval_f32`: `6.82×` behind C-O3-nat; `k3_soa_particle_acc`: `10.04×` behind C-O3-nat).
- **General Compiler Pass**:
  - For any counted, branch-free, pure-F32 loop over hoisted `Array<F32>`s with unit-stride index `i` (after Laws L22-2 & L22-3 unbox the record and hoist arrays):
    1. Vectorize 8-wide (`ymm` AVX1: `vmovups`+`vshufps $0x88`+`vinsertf128` gather, `vmulps`/`vaddps`/`vsubps`/`vdivps`, `vunpcklps`/`vunpckhps` scatter, + `vzeroupper`) directly over Bend's existing 64-bit array slots (**0 ABI change**!).
    2. Hoist all loop-invariant F32 constants via `vbroadcastss .rodata(%rip), %ymm` (0 `movd` inside loop).
    3. Emit a scalar tail loop for `rem % 8`.
- **Verified Speedup Ceiling**: **`6.24×`** on `t2_poly_eval_f32` (`121.60 -> 19.48 ms`, **0.201×** C-O2 / **1.092×** C-O3-nat!); **`5.73×`** on `k3_soa_particle_acc` (`69.78 -> 12.18 ms`, **0.916×** C-O2!).
- **Generalizes To**: Polynomial/transcendental sweeps, Newton-Raphson solvers, FIR/IIR/stencil filters, SoA physics/particle integrators, ML activation/normalization layers.
- **Falsifiable `law_gate.py` Contract**: On a holdout element-wise `Array<F32>` map/sweep (with Horner polynomial + `F32.div`) AND a 4-array SoA `Array<F32>` integrator:
  - Packed FP vector ops (`vmulps`/`vaddps`/`vsubps`/`vdivps` or `mulps`/`addps`) >= 4 in hot loop.
  - `0` `movd` instructions and `0` `p111_rt_op` calls inside the vector loop.
- **Estimated Scope**: ~110 LOC.

### Law L22-5: XMM Constant Hoisting & Peephole Bitwise Idioms (`rol`/`ror`, `cmov`)
- **Root Cause Fixed**:
  1. In scalar F32 loops (`t2_a`, `k3_a`), Proven-20 materializes every F32 constant inside the loop via `mov $0x3c800000, %eax; movd %eax, %xmm4` (14× per iteration in `t2`!) and occasionally bounces FP temporaries through GP registers via `movd`.
  2. In bitwise integer mixers (`k1`, hashes, crypto), `(x << k) | (x >> (32 - k))` is lowered to 3 instructions instead of a single `roll $k` / `rorl $k`, and simple 2-way scalar selects (`next_cp` in `t4`) emit predictable-hostile branches instead of `cmov`.
- **General Compiler Pass**:
  1. LICM for FP constants (`vbroadcastss`/`movss .rodata(%rip)` hoisted to loop preheader) + strict XMM residency (0 GP↔XMM `movd` in FP loops).
  2. Peephole rotate fusion: `U32.or(U32.shln(x, k), U32.shrn(x, 32-k))` -> `roll $k, %reg`.
  3. If-conversion (`cmov`) for branch-free scalar 2-way `Bool` matches with <= 4 ALU ops per arm.
- **Verified Speedup Ceiling**: **`1.18×`** pure scalar gain on `t2` (bringing scalar Bend to `1.064×` vs `gcc -O2`); contributes to `t4` (`7.00×`) and `k1` (`2.16×`, `0.996×` vs `gcc -O2`).
- **Falsifiable `law_gate.py` Contract**:
  - `0` `movd` instructions inside pure-F32 loops.
  - `roll`/`rorl` emitted for `U32.or(U32.shln(x, 13n), U32.shrn(x, 19n))`.
- **Estimated Scope**: ~40 LOC.

---

## 4. Recommended Wave-22 Priority Order (ROI = Speedup × Generality / LOC)

| Priority | Law | Target Headroom (Verified) | Est. LOC | General Impact |
|---:|---|---|---:|---|
| **1** | **L22-1** Complete `.rodata` LUT + Leaf Inlining | `5.00×` (`v3`), `~4–5×` (`t4`) | ~45 | Fixes silent LUT truncation & CSE breakage across all table-driven DFAs/codecs |
| **2** | **L22-3** Full Record Unboxing Across Loops/Branches | `2.16×` (`k1`), enables `t4`/`t1`/`k2`/`k3` | ~75 | Eliminates `p111_rt_ctor` & 40–116 spills in every stateful Bend loop |
| **3** | **L22-2** Multi-Array Preheader Hoist & Continuation Fusion | `1.98×` (`t1`), `2.46×` (`k2`), `3.87×` (`k3` sc.) | ~80 | Eliminates `p113_rt_array_pair`/`p111_rt_op` in all multi-array algorithms |
| **4** | **L22-4** 8-Wide AVX1 F32 Over 64-Bit Slots (0 ABI change) | `6.24×` (`t2`), `5.73×` (`k3`) | ~110 | Closes `6–10×` SIMD gap on element-wise F32 & SoA loops without touching ABI |
| **5** | **L22-5** XMM Constant Hoist + `rol`/`cmov` Peepholes | `1.18×` scalar FP + branchless DFAs/hashes | ~40 | Polishes scalar loops to `~1.00×` `gcc-10 -O2` floor |

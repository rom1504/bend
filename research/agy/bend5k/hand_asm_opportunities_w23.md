# Wave-23 Verified Hand-ASM Ceiling Probes & General Compiler Laws (for Wave 24)

- **Host / Pin**: Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge: `sse4_1`, `sse4_2`, `popcnt`, `avx`), pinned via `taskset -c 3`, 5-run medians (1 warmup + 5 timed runs).
- **Compiler Baseline**: Proven-22 `bend5k_o2 -O2` (`sha256: b3d1cf31...`, base commit `8630548f`), linked against unmodified `runtime-agy.o` (`sha256: afdcbaa7...`).
- **C Oracles**: `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
- **Verification Methodology**: Every hand-assembled x86-64 (`.S`) probe redirects **only** its target hot symbol(s) inside the unmodified Proven-22 ELF64 `.o` via `SHT_SYMTAB` `SHN_UNDEF` redirection, runs inside the unmodified Bend runtime with **0 ABI changes** (exact 64-bit `Array<T>` slots, tagged `AATree` handles, and exact unboxed-record multi-argument conventions), and is gated on **bit-identical U32 stdout checksum** against both C oracles.
- **Reproducible Artifacts**:
  - Runner: `research/agy/bend5k/hand_asm_w23/run_probes.py`
  - Verified JSON: `research/agy/bend5k/hand_asm_w23/asm_ceiling_probes_w23.json`
  - Probes (`.S`, 10 verified variants across all 6 workloads): `research/agy/bend5k/hand_asm_w23/probes/`

---

## 1. Executive Summary Table (CPU 3, 5-Run Medians)

| # | Workload | Retired W22 Pool | Checksum | Proven-22 `bend5k_o2` | `gcc-10 -O2` | `gcc-10 -O3 -march=native` | Best Hand-ASM Probe (0 ABI change) | Speedup vs Proven-22 | Probe vs C-O2 | Probe vs C-O3-nat |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | `v4_aatree_persist_map` | Validation | `2883763830` | 42.77 ms (`4.64×` / `4.92×`) | 9.21 ms | 8.70 ms | **13.25 ms** (`b_insert_and_lookup_direct`) | **3.23×** | **1.439×** | **1.523×** |
| 2 | `t3_kmp_multi_scan` | Test-Sealed | `1602941613` | 28.04 ms (`3.18×` / `3.40×`) | 8.81 ms | 8.24 ms | **9.21 ms** (`a_scan_text_fused`) | **3.04×** | **1.045×** | **1.118×** |
| 3 | `t2_radix2_fft_f32` | Test-Sealed | `4264586127` | 24.78 ms (`3.38×` / `4.10×`) | 7.33 ms | 6.05 ms | **7.83 ms** (`b_frames_fused_sse`) | **3.17×** | **1.068×** | **1.294×** |
| 4 | `v3_dsu_kruskal_union` | Validation | `2423000577` | 31.41 ms (`3.13×` / `3.51×`) | 10.05 ms | 8.96 ms | **9.40 ms** (`a_run_edges_fused`) | **3.34×** | **0.935×** | **1.049×** |
| 5 | `t1_lzw_dict_coder` | Test-Sealed | `683566485` | 29.24 ms (`3.22×` / `3.09×`) | 9.07 ms | 9.46 ms | **10.80 ms** (`b_run_bytes_fused`) | **2.71×** | **1.191×** | **1.142×** |
| 6 | `v1_sha256_compress` | Validation | `1895370468` | 25.13 ms (`2.25×` / `2.43×`) | 11.17 ms | 10.35 ms | **11.33 ms** (`b_run_blocks_fused`) | **2.22×** | **1.014×** | **1.095×** |

### Staged Variant Breakdown (Isolating Individual Compiler Laws)
- **`v4_aatree_persist_map`**: `42.77 ms` -> `29.07 ms` (**1.47×** from deforesting `LookReq` in `$direct.aa_lookup` alone, saving 13.70 ms) -> **`13.25 ms`** (**3.23×** total, **2.19×** additional gain from deforesting `InsReq` + `match-as` identity reuse + FBIP unique-node reuse & in-place `aa_skew`/`aa_split` rotations in `$direct.aa_insert`, allocating genuine Bend `Node`s at `Leaf{}` only!).
- **`t2_radix2_fft_f32`**: `24.78 ms` -> `10.13 ms` (**2.45×** from hoisting 4 `Array<F32>`s + fusing `run_stages -> run_groups -> run_bfly` in scalar F32) -> **`7.83 ms`** (**3.17×** total, **1.29×** additional gain from fusing `bitrev_perm` + `norm_loop` + 4-wide SSE `mulps`/`addps`/`subps` on stages `half >= 4`, reaching `1.068×` C-O2 with exact IEEE-754 bit-identical output!).
- **`t1_lzw_dict_coder`** *(critical negative/positive control!)*: `29.24 ms` -> `29.40 ms` (**0.99×** when deforesting `ProbeStep` inside `$direct.ht_probe_go` *without* inlining into `$direct.run_bytes`, because avg probe length is ~1.2 steps and the call-boundary boxing of `PCont` + `PR` dominates 100%!) -> **`10.80 ms`** (**2.71×** total, `1.191×` C-O2 / `1.142×` C-O3-nat when inlining `ht_probe_go` + `handle_insert` + `clear_arr` into `run_bytes` with `hk`/`hv` hoisted!).
- **`v1_sha256_compress`**: `25.13 ms` -> `18.07 ms` (**1.39×** from register-allocating `a..h` + hardware `rorl` in `$direct.run_rounds` alone, eliminating 276 loop spills!) -> **`11.33 ms`** (**2.22×** total, **1.59×** additional gain from fusing `fill_w16` + `expand_w` + `run_rounds` + `add_state` in `$direct.run_blocks` with `w`/`k` hoisted once and `rorl` in `sig0`/`sig1`, reaching **`1.014×` C-O2**!).

---

## 2. Mechanical Root-Cause Disassembly Analysis (Proven-22 `-O2`)

### 1. `v4_aatree_persist_map` (`42.77 ms -> 13.25 ms`, **3.23×**)
- **Proven-22 Disassembly**:
  - `$direct.aa_insert`: **`insns=7589, spills=1449, ctor=27, take=9`**!
  - `$direct.aa_lookup`: **`insns=950, spills=85, ctor=3, take=3`**!
  - `$direct.aa_skew`: `insns=1489, spills=219, ctor=5, take=2`; `$direct.aa_split`: `insns=2560, spills=438, ctor=9, take=3`.
- **Root Causes**:
  1. **Continuation-ADT Boxing (`InsReq` & `LookReq`)**: Just like `t4_interval_tree_query` in W22, data-dependent `U32.cmp(k, tk)` forces `IRoot`/`ICmp` and `LRoot`/`LCmp` continuation ADTs, causing `aa_lookup` to allocate 3 objects per lookup step and `aa_insert` to explode to **7,589 instructions and 1,449 spills**!
  2. **Identity Reconstruction + Missing FBIP Unique-Node Reuse**: In `aa_skew` and `aa_split`, every non-rotating branch rebuilds `Node{lv, k, v, ...}` from scratch (`5–9× p111_rt_ctor`), and `aa_insert` allocates fresh `Node`s along the entire unwind spine even when the tree is linearly owned (`refcount == 1`).
- **Hand-ASM Ceiling**: Deforesting `LookReq` alone cuts runtime by 32% (`42.77 -> 29.07 ms`, **1.47×**); deforesting `InsReq` + `match-as` + FBIP in-place `aa_skew`/`aa_split` rotations cuts runtime to **`13.25 ms`** (**3.23×**, `1.439×` C-O2 — the remaining `0.44×` gap vs C-O2 is purely Bend's 40B 64-bit-slot `Node` allocation via `p111_rt_ctor` at leaves + `do_inserts`/`do_queries` wrapper overhead).

### 2. `t3_kmp_multi_scan` (`28.04 ms -> 9.21 ms`, **3.04×**)
- **Proven-22 Disassembly**:
  - `$direct.scan_text`: `insns=550, spills=103, ctor=1, arr=3`, calls `$direct.kmp_fallback_go` out-of-line **1,146,880 times**!
  - `$direct.kmp_fallback_go`: `insns=192, spills=23, arr=2`.
- **Root Cause**: `scan_text` calls an inner self-TCO loop (`kmp_fallback_go`, avg ~0.3 iterations/char) that takes `pat` and `pi` inside a `FallStep` record and returns `FallRes`. Because Proven-22 refuses to inline inner self-TCO loops, it pays 1.15M out-of-line calls + `FallStep`/`FallRes` boxing + **5× `p113_rt_array_pair`** (`3` in `scan_text` + `2` in `kmp_fallback_go`) + 126 spills!
- **Hand-ASM Ceiling**: Inlining `kmp_fallback_go` into `$direct.scan_text` and hoisting `text`, `pat`, `pi` once before the 8192-char loop (`t3_a_scan_text_fused.S`) hits **`9.21 ms`** (**3.04×**, **`1.045×` C-O2**!).

### 3. `t2_radix2_fft_f32` (`24.78 ms -> 7.83 ms`, **3.17×**)
- **Proven-22 Disassembly**:
  - `$direct.run_bfly`: **`insns=1297, spills=523, ctor=2, arr=6, op=4`**!
  - `$direct.bitrev_perm`: `insns=690, spills=128, ctor=2, arr=4, op=4`!
  - `$direct.norm_loop`: `insns=657, spills=223, ctor=2, arr=2, op=2`!
- **Root Causes**:
  1. **4-Array Nested-Loop Hoisting Failure**: `run_stages -> run_groups -> run_bfly` threads `FS{re, im, twr, twi}` across 3 nested loops, and `bfly_wr -> bfly_wi -> bfly_vr -> bfly_vi -> bfly_ur -> bfly_ui` is a 6-deep continuation chain doing 6 `Array.get`s + 4 `Array.set`s. Proven-22 fails to hoist any of the 4 arrays, emitting `6× p113_rt_array_pair + 4× p111_rt_op + 2× p111_rt_ctor` and **523 spills**!
  2. **Scalar vs 4-Wide SSE F32**: Stages `s = 2..8` (`half = 4..256`, 78% of all butterflies) and `norm_loop` have contiguous unit-stride `u` and `v` accesses that vectorize cleanly to 4-wide SSE `mulps`/`addps`/`subps` (bit-identical to `-ffp-contract=off`).
- **Hand-ASM Ceiling**: Scalar 4-array hoist + loop fusion (`t2_a_stages_scalar_hoist.S`) hits **`10.13 ms`** (**2.45×**); full frame fusion + 4-wide SSE (`t2_b_frames_fused_sse.S`) hits **`7.83 ms`** (**3.17×**, **`1.068×` C-O2**!).

### 4. `v3_dsu_kruskal_union` (`31.41 ms -> 9.40 ms`, **3.34×**)
- **Proven-22 Disassembly**:
  - `$direct.run_edges`: **`insns=1647, spills=263, ctor=2, arr=2, op=7, take=4`**, calls `$direct.dsu_find_go` **4×** per edge!
  - `$direct.dsu_find_go`: `insns=646, spills=75, ctor=4, arr=2, op=1`.
- **Root Cause**: Identical to `t3_kmp_multi_scan`: `dsu_find_go` is a tiny inner self-TCO path-halving loop (avg ~1.5 iterations) called twice per edge (`dsu_find(u)` and `dsu_find(v)`), boxing `FindStep` and `FindOut` and preventing `par` and `rnk` from being hoisted across the 8192-edge loop!
- **Hand-ASM Ceiling**: Inlining both `dsu_find` loops + hoisting `par`/`rnk` once in `$direct.run_edges` (`v3_a_run_edges_fused.S`) hits **`9.40 ms`** (**3.34×**, **`0.935×` C-O2 — beating `gcc-10 -O2` by 6.5%!**).

### 5. `t1_lzw_dict_coder` (`29.24 ms -> 10.80 ms`, **2.71×**)
- **Proven-22 Disassembly**:
  - `$direct.ht_probe_go`: **`insns=2480, spills=317, ctor=8, arr=2, take=6`**!
  - `$direct.run_bytes`: `insns=894, spills=161, ctor=2, op=2, take=1`, calls `$direct.ht_probe_go` out-of-line 655,320 times!
- **Root Cause**: Proven by our controlled A/B probe:
  - Variant A (`t1_a_ht_probe_deforest.S`, deforesting `ProbeStep` inside `ht_probe_go` alone) stays at **`29.40 ms` (`0.99×`)** because `run_bytes` still boxes `PCont` before calling `ht_probe_go` and `ht_probe_go` boxes `PR` on return, and `hk`/`hv` are re-decoded on every byte!
  - Variant B (`t1_b_run_bytes_fused.S`, inlining `ht_probe_go` + `handle_insert` + `clear_arr` into `run_bytes` with `hk`/`hv` hoisted) drops straight to **`10.80 ms`** (**2.71×**, **`1.191×` C-O2 / `1.142×` C-O3-nat**!).

### 6. `v1_sha256_compress` (`25.13 ms -> 11.33 ms`, **2.22×**)
- **Proven-22 Disassembly**:
  - `$direct.run_rounds`: **`insns=1259, spills=276, ctor=4, arr=2, rol=0`**!
  - `$direct.expand_w`: `insns=335, spills=36, arr=4, op=1, rol=0`!
  - `$direct.run_blocks`: `insns=2014, spills=254, ctor=1, take=6, keep=2`, calls `fill_w16`, `expand_w`, `run_rounds` out-of-line 24,000 times!
- **Root Causes**:
  1. **Zero Hardware Rotate Fusion (`rol=0`)**: All 10 SHA-256 rotates (`rotr7/18/17/19/2/13/22/6/11/25`) emit 4-instruction `shrn/shln/or` sequences instead of 1-cycle `rorl $k`.
  2. **Live-Range Register Spilling (276 spills in `run_rounds`)**: Even though Proven-22 unboxed `SR{S8{a..h}, w, k}` at `run_rounds` entry, the 8 state words `a..h` + `w`/`k` pointers spill to the stack 276 times per loop body!
  3. **Un-fused Block Pipeline**: `run_blocks` calls `fill_w16`, `expand_w` (`4× p113_rt_array_pair`), and `run_rounds` (`4× p111_rt_ctor`, `2× p113_rt_array_pair`) out-of-line 24,000 times.
- **Hand-ASM Ceiling**: Register allocation + `rorl` in `run_rounds` alone (`v1_a_rounds_regalloc_ror.S`) gives **`18.07 ms`** (**1.39×**); full block fusion + `w`/`k` hoist + `rorl` in `expand_w`/`run_rounds` (`v1_b_run_blocks_fused.S`) hits **`11.33 ms`** (**2.22×**, **`1.014×` C-O2**!).

---

## 3. Ranked General Compiler Laws for Wave 24

Every law below is **algorithm-agnostic**, backed by controlled A/B hand-ASM evidence on retired Wave-22 workloads, and directly falsifiable in `law_gate.py`.

### Law L24-1 (Priority #1): Inner Self-TCO Loop Inlining + Outer-Loop Multi-Array Preheader Hoisting
- **Evidence**: Closes **5 of 6** workloads to **`0.935×–1.191×` C-O2**!
  - `v3_dsu_kruskal_union`: **3.34×** (`0.935×` C-O2 — beats `gcc-10 -O2`!)
  - `t3_kmp_multi_scan`: **3.04×** (`1.045×` C-O2)
  - `t1_lzw_dict_coder`: **2.71×** (`1.191×` C-O2; controlled A/B proves **0.99×** without outer-loop inlining vs **2.71×** with!)
  - `t2_radix2_fft_f32`: **2.45×** scalar (`1.382×` C-O2) / **3.17×** with frame fusion + SSE (`1.068×` C-O2)
  - `v1_sha256_compress`: **+1.59×** on top of regalloc+`rorl` (**2.22×** total, `1.014×` C-O2)
- **General Compiler Pass**:
  1. Allow inlining of **small inner self-TCO loops** (<= ~60 IR ops, e.g. `kmp_fallback_go`, `dsu_find_go`, `ht_probe_go`, `run_bfly`, `expand_w`) into their enclosing self-TCO caller loop **before** record-unboxing and array-hoist analysis, turning inner loop arguments (`FallStep`, `FindStep`, `ProbeStep`) into plain SSA phi/loop registers with 0 call-boundary boxing!
  2. Extend preheader `Array<T>` base-pointer hoisting to **all arrays carried across nested loops and multi-step `Array.get`/`Array.set` continuation chains** (up to `K=6` arrays, e.g., `re/im/twr/twi`, `text/pat/pi`, `par/rnk`, `hk/hv`, `w/k`), eliminating every `p113_rt_array_pair` and `p111_rt_op` inside hot loops.
- **Falsifiable `law_gate.py` Contract**: On holdout outer-loop calling a small inner self-TCO loop over 2–4 `Array<T>`s: `0` out-of-line inner loop calls, `0` `p113_rt_array_pair`, and `0` `p111_rt_ctor` inside the outer loop body.

### Law L24-2 (Priority #2): Continuation-ADT Deforestation + `match-as` Identity Reuse + FBIP Unique-Node Reuse
- **Evidence**: `v4_aatree_persist_map`: **1.47×** (`aa_lookup` `LookReq` deforestation alone) -> **3.23×** (`aa_insert` `InsReq` deforestation + `match-as` + FBIP in-place `aa_skew`/`aa_split`, `1.439×` C-O2). Directly confirms Wave-22 Laws `L22-W22-1` and `L22-W22-2` on a brand-new persistent balanced-tree family!
- **General Compiler Pass**:
  1. **Continuation-ADT Deforestation**: When a recursive function matches a multi-constructor request ADT (`InsReq`, `LookReq`, `ProbeStep`) and recurses with a statically known constructor `Kj{e0..ek}`, jump directly to the `Kj` arm with `e0..ek` in registers (0 `p111_rt_ctor`).
  2. **`match-as` Identity Reuse**: Replace `case C{f0..fk}: ... C{f0..fk}` with the scrutinee handle directly (0 `p111_rt_ctor` on non-rotating tree branches in `aa_skew`/`aa_split`).
  3. **FBIP Unique-Node Reuse**: When a linearly owned `Node` (`testq %h, %h; jns .Lreuse`) is consumed and rebuilt with the same constructor/arity, mutate changed fields in-place.
- **Falsifiable `law_gate.py` Contract**: On a holdout persistent balanced-tree `insert` + `lookup`: `0` `p111_rt_ctor` in `lookup`; `p111_rt_ctor` only in `Leaf{}` base case of `insert`.

### Law L24-3 (Priority #3): Hardware Rotate Fusion (`rorl`/`roll`) + Loop-Carried Scalar Register Allocation
- **Evidence**: `v1_sha256_compress`: **1.39×** (`25.13 -> 18.07 ms`) in `$direct.run_rounds` alone from keeping `a..h` in registers (0 spills vs Proven-22's **276 spills**) + 1-cycle `rorl` (0 `rorl` in Proven-22!).
- **General Compiler Pass**:
  1. **Bitwise Rotate Peephole**: Lower `U32.or(U32.shrn(x, k), U32.shln(x, 32-k))` -> `rorl $k, %reg` and `U32.or(U32.shln(x, k), U32.shrn(x, 32-k))` -> `roll $k, %reg` (cuts 4 insns -> 1 insn per rotate across SHA-256, ChaCha20, SipHash, BLAKE2).
  2. **Loop-Body Register Prioritization**: Prioritize loop-carried scalar state variables (`a..h`, indices, accumulators) and hoisted array base pointers into callee-saved registers (`%rbx, %r12..%r15`) before spilling cold temporaries, slashing 100–500 spill loops down to ~0 spills.
- **Falsifiable `law_gate.py` Contract**: On a holdout 8-word ARX round loop with `rotr`: `rorl >= 6` and `spills <= 12` (down from 276).

### Law L24-4 (Priority #4): 4-Wide SSE F32 Auto-Vectorization (for Unit-Stride `Array<F32>` Loops)
- **Evidence**: `t2_radix2_fft_f32`: **+1.29×** pure vectorization + frame-fusion gain over already-hoisted scalar F32 (`10.13 -> 7.83 ms`, **3.17×** total, **`1.068×` C-O2**), while remaining **100% IEEE-754 bit-identical** to `-ffp-contract=off`!
- **General Compiler Pass**: For innermost unit-stride `Array<F32>` loops (trip count multiple of 4, no loop-carried dependency on `k..k+3`), gather 4 contiguous 64-bit array slots via `movups` + `shufps $0x88`, execute 4-wide `mulps`/`addps`/`subps`, and scatter back via `movss`/`shufps $0x39`.
- **Falsifiable `law_gate.py` Contract**: On a holdout unit-stride `Array<F32>` butterfly/scale loop: `mulps`/`addps`/`subps` emitted and bit-identical F32 checksum preserved.

---

## 4. Recommended Wave-24 Priority Table (ROI = Speedup × Breadth / LOC)

| Priority | Law | Verified Speedup Ceiling | Breadth (Retired W22) | Est. LOC |
|---:|---|---|---|---:|
| **1** | **L24-1** Inner Self-TCO Loop Inlining + Outer Multi-Array Hoist | **2.45×–3.34×** (`0.935×–1.191×` C-O2) | **5 / 6** (`v3`, `t3`, `t1`, `t2`, `v1`) | ~110 |
| **2** | **L24-2** Continuation-ADT Deforestation + `match-as` + FBIP Reuse | **3.23×** (`1.439×` C-O2) | **2 / 6** (`v4`, `t1`) + all ADT trees | ~140 |
| **3** | **L24-3** Hardware `rorl`/`roll` Fusion + Loop-Carried Regalloc | **1.39×** standalone, **2.22×** fused (`1.014×` C-O2) | **1 / 6** (`v1`) + all ARX/crypto/high-live loops | ~70 |
| **4** | **L24-4** 4-Wide SSE `F32` Loop Vectorization (64-bit slot gather/scatter) | **+1.29×** over scalar (**3.17×** total, `1.068×` C-O2) | **1 / 6** (`t2`) + all DSP/linear-algebra F32 | ~95 |

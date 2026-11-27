# Wave-22 Verified Hand-ASM Ceiling Probes & General Compiler Laws

- **Host / Pin**: Intel(R) Xeon(R) CPU E3-1245 V2 @ 3.40GHz (Ivy Bridge: `sse4_1`, `sse4_2`, `popcnt`, `avx`), pinned via `taskset -c 5`, 5-run medians (1 warmup + 5 timed runs).
- **Compiler Baseline**: Proven-21 `bend5k_o2 -O2` (`sha256: ba0df181...`, base commit `2f59e12b`), linked against unmodified `runtime-agy.o` (`sha256: afdcbaa7...`).
- **C Oracles**: `gcc-10 -O2 -ffp-contract=off` and `gcc-10 -O3 -march=native -ffp-contract=off`.
- **Verification Methodology**: Every hand-assembled x86-64 (`.S`) probe redirects **only** its target hot symbol(s) inside the unmodified Proven-21 ELF64 `.o` via `SHT_SYMTAB` `SHN_UNDEF` redirection, runs inside the unmodified Bend runtime with **0 ABI changes** (exact 64-bit `Array<T>` slots, tagged `ITree`/`Trie`/`BTree` handles, and exact unboxed multi-return conventions), and is gated on **bit-identical U32 stdout checksum** against both C oracles.
- **Reproducible Artifacts**:
  - Runner: `research/agy/bend5k/hand_asm_w22/run_probes.py`
  - Verified JSON: `research/agy/bend5k/asm_ceiling_probes_w22.json`
  - Probes (`.S`, 12 verified variants): `research/agy/bend5k/hand_asm_w22/probes/`
  - Fresh Non-Suite Kernels (`.bend` + `.c`, both passing `locked_bun.sh --check-only`): `research/agy/bend5k/hand_asm_w22/kernels/`

---

## 1. Executive Summary Table (CPU 5, 5-Run Medians)

| # | Workload | Pool | Checksum | Proven-21 `bend5k_o2` | `gcc-10 -O2` | `gcc-10 -O3 -march=native` | Best Hand-ASM Probe (0 ABI change) | Speedup vs Proven-21 | Probe vs C-O2 | Probe vs C-O3-nat |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | `t4_interval_tree_query` | Retired W21 Test-Sealed | `3103892638` | 57.44 ms (`5.59×` / `5.58×`) | 10.28 ms | 10.29 ms | **11.76 ms** (`b_insert_and_query_direct`) | **4.88×** | **1.144×** | **1.143×** |
| 2 | `v4_huffman_trie_codec` | Retired W21 Validation | `4277058299` | 88.16 ms (`7.74×` / `9.54×`) | 11.39 ms | 9.24 ms | **9.87 ms** (`b_decode_words_fused`) | **8.93×** | **0.867×** | **1.068×** |
| 3 | `t2_chacha20_quarter` | Retired W21 Test-Sealed | `1185483819` | 45.41 ms (`4.76×` / `5.06×`) | 9.53 ms | 8.98 ms | **7.94 ms** (`b_sse2_4wide_rows`) | **5.72×** | **0.833×** | **0.884×** |
| 4 | `t1_csr_dijkstra_relax` | Retired W21 Test-Sealed | `2992686248` | 34.68 ms (`3.28×` / `2.76×`) | 10.56 ms | 12.56 ms | **11.28 ms** (`a_5array_hoist_fused`) | **3.07×** | **1.068×** | **0.898×** |
| 5 | `v3_bloom_dedup_ring` | Retired W21 Validation | `4154903119` | 34.00 ms (`2.14×` / `2.14×`) | 15.92 ms | 15.90 ms | **17.62 ms** (`a_dual_hoist_rmw`) | **1.93×** | **1.107×** | **1.108×** |
| 6 | `k1_bsearch_branchless` | Fresh Non-Suite W22 | `2353581905` | 103.10 ms (`2.24×` / `2.28×`) | 45.99 ms | 45.19 ms | **50.28 ms** (`b_hoist_cmov`) | **2.05×** | **1.093×** | **1.113×** |
| 7 | `k2_tree_nontail_fold` | Fresh Non-Suite W22 | `2883565381` | 204.90 ms (`1.89×` / `2.75×`) | 108.44 ms | 74.57 ms | **91.47 ms** (`b_leaf_inline`) | **2.24×** | **0.844×** | **1.227×** |

### Staged Variant Breakdown (Decomposing Speedup Factors)
- **`t4_interval_tree_query`**: `57.44 ms` -> `23.52 ms` (**2.44×** from deforesting `QReq` in `$direct.query_overlap` alone, saving 33.92 ms) -> **`11.76 ms`** (**4.88×** total, **2.00×** additional gain from deforesting `InsReq` + FBIP unique-node reuse in `$direct.insert_iv`, reaching `1.143×` vs C-O3-nat with genuine Bend `INode` heap objects!).
- **`v4_huffman_trie_codec`**: `88.16 ms` -> `12.87 ms` (**6.85×** from eliminating `TNode{l,r}` identity reconstruction + unboxing `DSt` across `$direct.decode_bits`) -> **`9.87 ms`** (**8.93×** total, **1.30×** additional gain from fusing `decode_bits` into `$direct.decode_words` + unboxed `RSt` multi-return, **beating `gcc-10 -O2`** at `0.867×`!).
- **`t2_chacha20_quarter`**: `45.41 ms` -> `13.59 ms` (**3.34×** from 2-level nested record unboxing `ChaMat -> 4× Row4 -> 16 U32s` + hardware `roll $16/$12/$8/$7`) -> **`7.94 ms`** (**5.72×** total, **1.71×** pure 4-wide SSE2/SSSE3 gain over scalar, **beating `gcc-10 -O3 -march=native` by 11.6%** at `0.884×`!).
- **`k1_bsearch_branchless`**: `103.10 ms` -> `88.81 ms` (**1.16×** control: hoisting `arr` + fusing `bsearch_step` while keeping conditional branch `ja`) -> **`50.28 ms`** (**2.05×** total, **1.77×** pure branchless `cmovbel` gain over branching, reaching `1.093×` C-O2!).
- **`k2_tree_nontail_fold`**: `204.90 ms` -> `100.24 ms` (**2.04×** from shrink-wrapped `BLeaf` fast-path + 24B `BNode` frame + invariant heap register, beating `gcc-10 -O2` at `0.924×`) -> **`91.47 ms`** (**2.24×** total, **0.844×** C-O2, from child-leaf specialization eliminating 50% of recursive calls).

---

## 2. Mechanical Root-Cause Disassembly Analysis

### 1. `t4_interval_tree_query` (`57.44 ms -> 11.76 ms`, **4.88×**)
- **Proven-21 Disassembly**:
  - `$direct.insert_iv`: `insns=2851, spills=448, jcc=207`, **`11× p111_rt_ctor`**, `11× p111_cid_hot`, `11× p111_program`, `4× p111_rt_take`, `4× recursive call`.
  - `$direct.query_overlap`: `insns=1421, spills=166, jcc=136`, **`4× p111_rt_ctor`**, `4× p111_cid_hot`, `4× p111_program`, `4× p111_rt_take`.
- **Why `t4` is `5.59×` (std) / `7.50×` (family) slower than C**:
  1. **Continuation-ADT State-Machine Explosion (`QReq` & `InsReq`)**: Because Bend2 forbids scrutinizing computed expressions directly in `match` and has no mutual recursion, idiomatic Bend2 tree algorithms encode data-dependent control flow (`max_hi < qlo`, `nlo <= qhi`, `lo < nlo`) via fuel-bounded self-recursive continuation ADTs (`QReq = QRoot | QCheck | QRight`, `InsReq = IRoot | ICmp | IGo`). Proven-21 **heap-allocates and immediately destroys 3–4 transient continuation-ADT nodes per tree node visited** (`4× p111_rt_ctor` + `4× p111_rt_take` in `query_overlap`; `11× p111_rt_ctor` in `insert_iv`), exploding register pressure to **166–448 stack spills**!
  2. **Lack of FBIP (Functional But In-Place) Unique-Node Reuse in `insert_iv`**: Along every root-to-leaf insertion path, `t` is linearly owned (`refcount == 1`), yet Proven-21 allocates a fresh `INode` at every level on unwind instead of reusing the unique `INode` slot in-place.
- **Hand-ASM Ceiling**:
  - Variant A (`t4_a_query_direct_tree.S`: `72 insns, 8 jcc, 0 relocs`): deforesting `QReq` in `query_overlap` alone cuts total time by **59%** (`57.44 -> 23.52 ms`, **2.44×**).
  - Variant B (`t4_b_insert_and_query_direct.S`: `179 insns, 17 jcc, 2× p111_rt_ctor` at `Empty{}` leaves only): deforesting `InsReq` + FBIP in-place update on unique `INode`s cuts total time to **`11.76 ms`** (**4.88×**, **1.143×** vs C-O3-nat!).

### 2. `v4_huffman_trie_codec` (`88.16 ms -> 9.87 ms`, **8.93×**)
- **Proven-21 Disassembly**:
  - `$direct.decode_bits`: `insns=1026, spills=103, jcc=100`, **`2× p111_rt_ctor`**, `2× p111_cid_hot`, **`5× p111_rt_take`**, `1× p111_rt_keep`.
  - `$direct.decode_words`: `insns=326, spills=21, jcc=34`, calls `$direct.decode_bits` out-of-line 92,160 times (`1× p111_rt_keep`, `1× p111_rt_sink`, `1× p111_rt_take`).
- **Smoking-Gun Root Cause of the `7.74×–12.7×` Slowdown**:
  1. **Unnecessary Identity Constructor Reconstruction (`TNode{l, r}` -> `TNode{l, r}`)**: Look at `check_leaf` in `v4_huffman_trie_codec_std.bend`:
     ```bend
     match next:
       case TLeaf{+sym}: ...
       case TNode{l, r}: DSt{TNode{l, r}, nplen, h, total}
     ```
     Because Bend2 lacks `@`-patterns (`as`-bindings), matching `TNode{l, r}` and rebuilding `TNode{l, r}` causes Proven-21 to **heap-allocate a brand-new `TNode` (`p111_rt_ctor` + `p111_rt_take` × 5) on EVERY SINGLE NON-LEAF BIT** (~2.46M heap allocations for a read-only static trie!).
  2. **Per-Bit `DSt` Re-Boxing + Out-of-Line `decode_bits` Call**: `decode_bits` re-boxes `DSt{cur, plen, h, total}` inside the 32-bit loop, and `decode_words` calls `decode_bits` out-of-line 92,160 times.
- **Hand-ASM Ceiling**:
  - Variant A (`v4_a_decode_bits_zero_alloc.S`: `73 insns, 5 jcc, 1× p111_rt_ctor` at exit): reusing `next` directly + unboxing `DSt` across all 32 bits delivers **`6.85×`** (`88.16 -> 12.87 ms`).
  - Variant B (`v4_b_decode_words_fused.S`: `69 insns, 5 jcc, 0 relocs`): fusing `decode_bits` into `decode_words` with Bend5k's own unboxed `RSt` multi-return `(%rax, %rdx, %rcx)` hits **`9.87 ms`** (**8.93×**, **0.867×** vs C-O2!).

### 3. `t2_chacha20_quarter` (`45.41 ms -> 7.94 ms`, **5.72×**)
- **Proven-21 Disassembly**:
  - `$direct.run_dr`: `insns=1433, spills=265, jcc=93`, **`5× p111_rt_ctor`**, `3× p111_rt_take`, **`0× rol`**!
  - `$direct.qr`: `insns=91, spills=7`, emits `mov + shl + shr + or` (4 insns) for every `rotl16/12/8/7` instead of 1-cycle `roll`!
  - `$direct.run_blocks`: `insns=2502, spills=286, jcc=279`, `4× p111_rt_ctor`, `10× p111_rt_take`, `4× p111_rt_keep`.
- **Root Causes**:
  1. **Shallow (1-Level Only) Record Unboxing**: `ChaMat = CM{r0: Row4, r1: Row4, r2: Row4, r3: Row4}` is a 2-level nested single-constructor record. Proven-21 unboxes `CM` at `run_dr`'s boundary, but **still heap-allocates 4 `Row4` records + 1 `ChaMat` (`5× p111_rt_ctor`) on EVERY double-round** (480,000 × 5 = 2.4M allocations) and spills **265 times**!
  2. **Missing Hardware Rotate Fusion**: All 32 rotates per double-round lower to 4 instructions (`mov/shl/shr/or`) instead of 1-cycle `roll $k`.
  3. **Scalar vs 4-Wide SSE2/SSSE3 SLP**: Each `Row4{a, b, c, d}` is a natural 128-bit `__m128i` lane vector (`paddd`, `pxor`, `pshufb` for `rotl16`/`rotl8`, `pshufd` for diagonal shifts).
- **Hand-ASM Ceiling**:
  - Variant A (`t2_a_scalar_unbox_rol.S`: `225 insns, 3 jcc, 32× roll, 0 relocs`): 2-level record unboxing + `roll` reaches **`13.59 ms`** (**3.34×**).
  - Variant B (`t2_b_sse2_4wide_rows.S`: `111 insns, 3 jcc, 80× SSE2/SSSE3 ops, 0 heap relocs`): 4-wide SSE2/SSSE3 reaches **`7.94 ms`** (**5.72×**, **0.833×** C-O2, **0.884×** C-O3-nat — **beating `gcc-10 -O3 -march=native`**!).

### 4. `t1_csr_dijkstra_relax` (`34.68 ms -> 11.28 ms`, **3.07×**)
- **Proven-21 Disassembly**:
  - `$direct.sweep_vertices`: `insns=973, spills=134, jcc=92`, `3× p113_rt_array_pair`, `1× p111_rt_ctor`, calls `$direct.relax_edges` out-of-line.
  - `$direct.relax_edges`: `insns=518, spills=102, jcc=27`, `3× p113_rt_array_pair`, `1× p111_rt_op`, `1× p111_rt_ctor`.
- **Root Causes**: `Graph = Gr{rptr, rlen, col, wt, dist, relax}` carries **5 arrays** across a 3-deep loop nest (`run_sweeps -> sweep_vertices -> relax_edges`) and a 5-deep continuation chain (`relax_v -> relax_w -> relax_dv -> maybe_relax -> pack_graph`). Proven-21 fails to hoist any of the 5 arrays across the nested loops, emitting `6× p113_rt_array_pair` + `1× p111_rt_op` + `2× p111_rt_ctor` and **236 stack spills**.
- **Hand-ASM Ceiling**: Hoisting all 5 array bases once before the 12-sweep loop + fusing `sweep_vertices`/`relax_edges` (`t1_a_5array_hoist_fused.S`: `110 insns, 13 jcc, 0 relocs`) hits **`11.28 ms`** (**3.07×**, **1.068×** C-O2, **0.898×** C-O3-nat!).

### 5. `v3_bloom_dedup_ring` (`34.00 ms -> 17.62 ms`, **1.93×**)
- **Proven-21 Disassembly**:
  - `$direct.step_keys`: `insns=1186, spills=256, jcc=43`, **`4× p113_rt_array_pair`**, **`3× p111_rt_op`**, `2× p111_rt_ctor`.
- **Root Causes**: Even though Proven-21 unboxed `DSt{bloom, ring, head, hits, uniques, acc, seed}` at `step_keys` entry, the 3 sequential read-modify-writes on `bloom` (`Array.get` + `Array.set` × 3) plus conditional `Array.swap` on `ring` across `probe0 -> probe1 -> probe2 -> finish_key -> ring_insert` broke array hoisting (`4× p113_rt_array_pair` + `3× p111_rt_op`) and triggered **256 stack spills**!
- **Hand-ASM Ceiling**: Hoisting both `bloom` and `ring` + fusing the 5-step continuation + direct RMW (`v3_a_dual_hoist_rmw.S`: `147 insns, 5 jcc, 1× p111_rt_ctor` at exit) hits **`17.62 ms`** (**1.93×**, **1.107×** C-O2 / **1.108×** C-O3-nat).

### 6. `k1_bsearch_branchless` (Fresh Non-Suite Kernel 1, `103.10 ms -> 50.28 ms`, **2.05×**)
- **Proven-21 Disassembly**:
  - `$direct.run_queries`: `insns=320, spills=29, jcc=25, cmov=0`, calls `$direct.bsearch_step` out-of-line 1,000,000 times (`2× p113_rt_array_pair`, `1× p111_rt_take`).
  - `$direct.bsearch_step`: `insns=380, spills=46, jcc=22, cmov=2`, `2× p111_rt_ctor`, `1× p113_rt_array_pair`.
- **Root Causes**:
  1. Out-of-line inner loop `bsearch_step` + `Array<U32> & U32` pair boxing (`2× p111_rt_ctor`, `3× p113_rt_array_pair`).
  2. **Branch Misprediction Floor**: Binary search over random keys has 50/50 unpredictable comparisons at every level (14M unpredictable branches). Our controlled comparison (`k1_a_hoist_branch.S`: `88.81 ms`, `1.16×` vs `k1_b_hoist_cmov.S`: **`50.28 ms`**, **`2.05×`**, `1.093×` C-O2) proves that **hardware `cmovbel` alone accounts for `1.77×`** of the speedup!

### 7. `k2_tree_nontail_fold` (Fresh Non-Suite Kernel 2, `204.90 ms -> 91.47 ms`, **2.24×**)
- **Proven-21 Disassembly**:
  - `$bor.fold_tree`: `insns=95, spills=3, jcc=4`, `0× p111_rt_ctor`, `0× p111_rt_keep`!
- **Why was Proven-21 still `1.89×` slower than C-O2 (`204.90 ms` vs `108.44 ms`) despite ZERO heap allocs and ZERO refcount calls?!**
  1. **No Shrink-Wrapping on the Leaf Fast-Path**: 50% of all 24.56M calls hit `BLeaf{v}` (an inline 1-field tag `0x010027...` requiring 4 ALU instructions and 0 memory loads!). Yet `$bor.fold_tree` executes a full `push rbp; push rbx..r15; sub $0x90, %rsp` prologue and epilogue on EVERY leaf call!
  2. **Bloated Non-Tail Stack Frame & `ctx` Reloading**: On `BNode`, Proven-21 pushes all 6 callee-saved registers + allocates a 144-byte stack frame and reloads `heap = (%rdi)` on every node, instead of pushing 3 registers (24B) and keeping `heap` invariant in `%r12`.
  3. **Child-Leaf Specialization**: Inlining `BLeaf` evaluation at the parent `BNode` call site (`k2_b_leaf_inline.S`) eliminates 50% of all `call`/`ret` instructions, cutting time from `100.24 ms` (`2.04×`, `0.924×` C-O2) down to **`91.47 ms`** (**2.24×**, **0.844×** C-O2!).

---

## 3. Top 5 General Compiler Laws for Wave-22 Batch 2 (`L22-SPEED-GENERAL`) & `law_gate.py`

Every law below is **algorithm-agnostic**, directly falsifiable via `objdump -dr` structural metrics in `law_gate.py`, and proven by our verified hand-ASM probes to close `1.9×`–`8.9×` gaps across retired Wave-21 suites and fresh non-suite kernels.

### Law L22-W22-1: Zero-Allocation Identity Constructor Reuse (`match-as`) & FBIP Unique-Node Reuse
- **Root Cause Fixed**:
  1. In `v4_huffman_trie_codec`, `case TNode{l, r}: DSt{TNode{l, r}, ...}` re-allocates an identical `TNode` on every non-leaf bit (`2.46M` unnecessary heap allocations -> `6.85×` slowdown!).
  2. In `t4_interval_tree_query`, `insert_iv` linearly owns every `INode` along the insertion path (`refcount == 1`), yet allocates a new `INode` on every unwind step instead of mutating the unique slot in-place.
- **General Compiler Pass**:
  1. **Identity Constructor Reuse (`match-as`, ~25 LOC)**: Inside any `case C{f0..fk}:` arm of `match x:`, if an expression constructs `C{f0..fk}` with the exact unpacked field variables in order (no mutation), replace the `Ctor` IR node directly with `x` (with `keep` only if `x` is borrowed/shared, 0 `p111_rt_ctor`!).
  2. **FBIP Unique-Node Reuse (~55 LOC)**: In a linear `match x:` arm `case C{f0..fk}:` that consumes `x` once and returns `C{g0..gk}` of the same arity/ctor, check uniqueness (`testq %x, %x; jns .Lreuse`, bit 63 == 0); on the fast path, overwrite only the changed fields in-place and return `x` with **0 allocation and 0 freelist traffic**!
- **Verified Speedup Ceiling**: **`6.85×`** on `v4_huffman_trie_codec` (`a_decode_bits_zero_alloc`, `8.93×` with fusion); **`~2.0×`** on `t4_interval_tree_query` `insert_iv` (`4.88×` combined with Law L22-W22-2).
- **Generalizes To**: Every persistent tree/trie/list/AST traversal, functional map/insert/delete, red-black/AVL/interval trees, Huffman/radix/prefix tries.
- **Falsifiable `law_gate.py` Contract**:
  - On a holdout `match x: case TNode{l, r}: Pair{TNode{l, r}, k}` function: `0` `p111_rt_ctor` calls for `TNode`!
  - On a holdout linear BST `insert` returning `Node{...}`: fast-path in-place reuse branch (`testq; jns`) present, `p111_rt_ctor` called only in the slow/leaf path.
- **Estimated Scope**: ~80 LOC total (~25 LOC `match-as` + ~55 LOC FBIP reuse).

### Law L22-W22-2: Continuation-ADT Deforestation (Tail-State-Machine Elimination)
- **Root Cause Fixed**: In Bend2, data-dependent branches inside recursive ADT functions (`t4_interval_tree_query`: `QReq = QRoot | QCheck | QRight`, `InsReq = IRoot | ICmp | IGo`) are written as fuel-bounded self-recursive functions taking a multi-constructor continuation ADT. Proven-21 heap-allocates 3–4 transient continuation-ADT objects per tree node (`4–11× p111_rt_ctor`, `166–448` spills!).
- **General Compiler Pass**:
  - When a self-recursive function `f(..., req: Req, ...)` immediately switches on `req` (`match req: case K0{...}: ... case K1{...}: ...`) and tail-calls `f(..., Kj{e0..ek}, ...)` with a statically known constructor `Kj`:
    - **Jump directly to the `Kj` arm's basic block** with `e0..ek` passed in SSA registers — **never heap-allocating `Kj{...}`!**
    - For non-tail self-calls `f(..., K0{child}, ...)`, specialize an entry point `f$K0(..., child, ...)` that passes `child` directly in a register without wrapping it in `K0{child}`!
- **Verified Speedup Ceiling**: **`2.44×`** on `t4_interval_tree_query` (`query_overlap` alone: `57.44 -> 23.52 ms`), **`4.88×`** combined with `insert_iv` (`11.76 ms`, `1.143×` C-O3-nat!).
- **Generalizes To**: Every fuel-bounded Bend2 tree/graph recursion, state-machine parser, interpreter step loop, and CPS-converted recursive algorithm.
- **Falsifiable `law_gate.py` Contract**: On a holdout 3-constructor `QReq` tree-query function:
  - `0` `p111_rt_ctor` calls in the `QReq` dispatch loop (`query_overlap`).
  - `spills <= 16` (down from 166!).
- **Estimated Scope**: ~95 LOC.

### Law L22-W22-3: Recursive Multi-Level Record Unboxing + Hardware Rotate Fusion (`rol`/`ror`) & 4-Wide SSE2 SLP
- **Root Cause Fixed**:
  1. Proven-21 only unboxes 1 level of single-constructor records, leaving nested records (`ChaMat{r0: Row4, r1: Row4, r2: Row4, r3: Row4}` in `t2_chacha20_quarter`) heap-allocated (`5× p111_rt_ctor` per double-round, 265 spills!).
  2. `U32.or(U32.shln(x, k), U32.shrn(x, 32-k))` still lowers to 4 instructions (`mov/shl/shr/or`) instead of 1-cycle `roll $k`.
  3. 4-wide homogeneous U32 record operations (`Row4{a,b,c,d}` add/xor/rotl) remain scalar instead of 128-bit SSE2/SSSE3 (`paddd`/`pxor`/`pshufb`).
- **General Compiler Pass**:
  1. **Recursive Record Flattening (~45 LOC)**: Flatten nested single-constructor records (up to 16 scalar leaf fields) recursively across self-TCO loops and inlined helpers.
  2. **Hardware Rotate Peephole (~15 LOC)**: Lower `U32.or(U32.shln(x, k), U32.shrn(x, 32-k))` -> `roll $k, %reg` (and symmetric right-rotate -> `rorl $k`).
  3. **Optional 4-Wide Integer SLP (~85 LOC)**: Pack 4-way isomorphic `U32` add/xor/rotate trees (e.g. `Row4` ARX rounds) into 128-bit XMM registers (`paddd`/`pxor`/`pshufb`).
- **Verified Speedup Ceiling**: **`3.34×`** scalar (`45.41 -> 13.59 ms`) from recursive unboxing + `roll`; **`5.72×`** (`7.94 ms`, **0.884×** vs `gcc-10 -O3 -march=native`!) with 4-wide SSE2/SSSE3!
- **Generalizes To**: ChaCha20/Salsa20/BLAKE2/SHA-256/SipHash crypto & hashing, nested geometry/matrix/quaternion records (`Mat4`, `Transform`, `AABB`).
- **Falsifiable `law_gate.py` Contract**:
  - On a holdout nested 2-level single-constructor record loop (`Outer{Inner{a,b}, Inner{c,d}}`) with `rotl32`: `0` `p111_rt_ctor` in the loop body, `roll`/`rorl >= 4`.
- **Estimated Scope**: ~60 LOC (scalar unboxing + `rol`), +~85 LOC (4-wide SSE2 SLP).

### Law L22-W22-4: N-Array Preheader Hoisting (K ≤ 8) + Nested-Loop / Continuation-Chain Fusion
- **Root Cause Fixed**: Proven-21's array hoister breaks on 2–5 arrays inside a loop-carried record (`t1`: 5 arrays in `Graph`; `v3`: 2 arrays in `DSt` with 3× RMW + `Array.swap`) and across nested loops (`t1`: `run_sweeps -> sweep_vertices -> relax_edges`; `v4`: `decode_words -> decode_bits`; `k1`: `run_queries -> bsearch_step`), leaving `3–6× p113_rt_array_pair`, `1–3× p111_rt_op`, and `100–256` stack spills!
- **General Compiler Pass**:
  1. Inline single-use linear continuation chains (`probe0->probe1->probe2`, `relax_v->relax_w->relax_dv`) and small inner self-TCO loops (`relax_edges`, `decode_bits`, `bsearch_step`) into the enclosing loop **before** array-hoist analysis.
  2. Hoist up to `K=8` loop-invariant `Array<T>` handles (including fields of a single-constructor record, and across `Array.get`/`Array.set`/`Array.swap` RMW sequences) into loop-preheader base registers.
- **Verified Speedup Ceiling**: **`3.07×`** on `t1_csr_dijkstra_relax` (`1.068×` C-O2 / `0.898×` C-O3-nat); **`1.93×`** on `v3_bloom_dedup_ring` (`1.107×` C-O2); **`+1.30×`** fusion multiplier on `v4_huffman_trie_codec` (`8.93×` total).
- **Generalizes To**: CSR/CSC graph algorithms (Dijkstra, Bellman-Ford, PageRank, SpMV), Bloom filters, hash tables, ring buffers, binary search, multi-buffer codecs.
- **Falsifiable `law_gate.py` Contract**:
  - On a holdout 5-array nested loop (`Graph{a0..a4}`) and a 2-array 3-probe RMW loop (`bloom` + `ring`): `0` `p113_rt_array_pair` and `0` `p111_rt_op` calls in the hot loop.
- **Estimated Scope**: ~85 LOC.

### Law L22-W22-5: Shrink-Wrapped Leaf Fast-Paths for Non-Tail Recursive ADTs + General `cmov` If-Conversion
- **Root Cause Fixed**:
  1. In `k2_tree_nontail_fold`, `$bor.fold_tree` already has 0 allocations and 0 refcount traffic, yet is `1.89×` slower than C-O2 (`204.90 ms` vs `108.44 ms`) because it pushes 6 callee-saved registers + allocates a 144B stack frame even on the 50%-frequent inline `BLeaf` base case, and reloads `heap = (%rdi)` on every `BNode`.
  2. In `k1_bsearch_branchless`, `choose_lo(U32.is_le(v, key), lo, cand)` is lowered with a branch (or un-fused pair-boxing) in the hot binary-search loop, paying a ~15-cycle Ivy Bridge branch misprediction penalty per level (`1.77×` pure slowdown vs `cmovbel`).
- **General Compiler Pass**:
  1. **Shrink-Wrapping & Minimal Recursive Frames (~40 LOC)**: Emit base-case / inline-leaf checks (`tag == 1`, no recursive calls) *before* saving callee-saved registers and allocating the stack frame, and save only actually clobbered callee-saved registers (plus pass `heap` in a register for `$bor.*` internal recursive helpers).
  2. **General `cmov` If-Conversion (~25 LOC)**: Lower any pure 2-way `Bool`-match selecting between two scalar register/ALU values (<= 3 ops per arm) to `cmp` + `cmovcc`.
- **Verified Speedup Ceiling**: **`2.04×–2.24×`** on `k2_tree_nontail_fold` (`0.924×–0.844×` vs C-O2!); **`1.77×`** pure `cmov` gain (`2.05×` total) on `k1_bsearch_branchless` (`1.093×` C-O2!).
- **Generalizes To**: Every non-tail recursive tree/AST/expression evaluator, binary search, branchless min/max/clamp, and branchless DFA state update.
- **Falsifiable `law_gate.py` Contract**:
  - On a holdout non-tail binary tree fold (`BLeaf | BNode`): leaf path executes `0` `push` / `sub $imm, %rsp` instructions before `ret`.
  - On a holdout binary-search loop with `choose_lo(U32.is_le(v, key), lo, cand)`: `cmov` count `>= 1` and `0` conditional branches on the comparison in the inner loop.
- **Estimated Scope**: ~65 LOC total (~40 LOC shrink-wrap + ~25 LOC `cmov`).

---

## 4. Recommended Wave-22 Batch 2 Priority Order (ROI = Speedup × Generality / LOC)

| Priority | Law | Verified Speedup Ceiling | Est. LOC | General Impact |
|---:|---|---|---:|---|
| **1** | **L22-W22-1** `match-as` Identity Reuse + FBIP Unique-Node Reuse | **`6.85×`** (`v4`), **`~2.0×`** (`t4` ins.) | ~80 | Eliminates millions of spurious ADT re-allocations in tries/trees/ASTs |
| **2** | **L22-W22-2** Continuation-ADT Deforestation | **`2.44×`** (`t4` q.), **`4.88×`** (`t4` all) | ~95 | Eliminates Bend2's #1 recursive-ADT state-machine tax (`4–11× p111_rt_ctor`) |
| **3** | **L22-W22-4** N-Array Preheader Hoist (K≤8) + Nested-Loop Fusion | **`3.07×`** (`t1`), **`1.93×`** (`v3`), **`+1.30×`** (`v4`) | ~85 | Closes multi-array CSR/Bloom/bsearch/codec gaps to `~1.05×` C-O2 |
| **4** | **L22-W22-3** Recursive Record Unboxing + `rol` (+ 4-Wide SSE2) | **`3.34×`** sc. / **`5.72×`** SSE2 (`t2`) | ~60 (+85) | Eliminates nested-record boxing & unlocks `roll` + SIMD ARX beating C-O3 |
| **5** | **L22-W22-5** Shrink-Wrapped Leaf Fast-Path + General `cmov` | **`2.04×–2.24×`** (`k2`), **`1.77×`** (`k1`) | ~65 | Brings pure non-tail recursion & binary search to `0.84×–1.09×` C-O2 |

---

## 5. Bonus Soundness Finding (Proven-21 `-O2` `$bor` Miscompilation)

While constructing Fresh Kernel 2, we discovered a **real Proven-21 `-O2` miscompilation bug** (reported here for the soundness/compiler team; Fresh Kernel 2 was finalized as `k2_tree_nontail_fold` which matches 4-way across `bun --check-only`, `bend5k -O2`, `gcc -O2`, and `gcc -O3 -march=native`):
- **Trigger**: A non-tail binary-recursive function `range_sum(t: BTree, mode: Nat/Bool/Visit, +qlo: U32, +qhi: U32) -> U32` that matches `t` (with `BNode` calling `range_sum` twice via `U32.add(...)` and calling a helper `classify_tree` on `l`/`r`) and gets specialized into `$bor.range_sum` at `-O2`.
- **Observed Behavior**: Upstream `bun` reference, `gcc-10 -O2`, and `bend5k_o2 -O0` all produce **`703409789`** (single-query `285056`), whereas `bend5k_o2 -O2` produces **`571768773`** (`FNV(0) × 400000` — `$bor.range_sum` returns `0` on every call!).
- **Action**: Wave-22 soundness/differential audit (`L22-ORACLE-DIFF`) should add a non-tail binary-recursive borrowed-ADT test with nested `Nat`/`Bool` dispatch to catch and fix this `$bor` bug.

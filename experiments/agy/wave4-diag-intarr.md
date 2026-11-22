# Wave 4 Phase 0 Diagnosis: Integer & Array Benchmarks (`histogram`, `gameoflife`, `editdist`, `bst`)

**Date:** 2026-11-22  
**Compiler under test:** `selfhost/build/agy/wave3b_unified/api.mjs` + `selfhost/build/agy/unified/runtime-agy.o`  
**Profiler:** `SIGPROF` (`research/agy/wave3_sc_hot/prof.c`, pinned to CPU 2 via `taskset -c 2`), `objdump -d`  
**C baseline:** `gcc -std=c11 -O3 -ffp-contract=off -fno-lto` (plus reference Clang `-O3` ratios from `research/agy/wave4_bench/inputs/tuned/RESULTS.md` and upstream Wave 4 baseline).

---

## Executive Summary

| Benchmark | Knobs / Args | AGY Wall (CPU 2) | GCC `-O3` Wall | Reported AGY / Clang `-O3` | `runtime-agy.o` Share | Bend `p113d_*` Share | #1 Root Cause |
|---|---|---:|---:|---:|---:|---:|---|
| **`histogram`** (medium) | `[18, 7, 24]` | `0.3832 s` | `0.0220 s` (`17.4×`) | `17.34×` (upstream) | **34.04%** | **65.96%** | Whole-program `p113a_certificate` kills inline array ops (`p111_rt_op` + `p113_rt_array_pair` = 33.0%); `U32.min`/`Bool.pick` (18.1%), `bump`/`bump.at` (17.0%), `prng`/`key` (14.9%) not inlined |
| **`gameoflife`** (medium) | `[12, 32]` | `3.4021 s` | `0.9474 s` (`3.59×`) | `13.04×` | **0.12%** | **99.76%** | `p113i` inliner exhausts `budget=1024` after 3/16 `step_cell` calls & never inlines `neighbor_count` (75.9%): 29 calls/gen + no constant-folding of `pos=0..15` + 45 stack spills + 8× `imul $4` + 0 CSE in `neighbor_count` |
| **Tuned `editdist`** | `reps=3000 n=2 seed=17` | `1.6186 s` (`1608 ms`) | `0.1281 s` (`125 ms`, `12.9×`) | `14.99×` | **16.92%** | **83.08%** | `columns` not `$product`-unboxed → heap-allocs & frees `Tuple{arr,hin}` every iter; whole-program `p113a` disabled (`p113_rt_array_pair`+`p111_rt_op` = 15.2%); `symbol`+`$p118borrow.read.symbol` = 26.4%; `Bool.to_u32` (2×/iter) = 11.4% |
| **Tuned `bst`** | `reps=600000 n=64 seed=17` | `1.4790 s` (`1475 ms`) | `0.2937 s` (`289 ms`, `5.1×`) | `6.14×` | **14.13%** | **85.87%** | `repeat_key` not inlined into `sorted_fold` (257 calls/rep, ~200 with `v=0` → 52.2%); `bump` not inlined into `collect` + unhoisted array checks (33.2%); `blk_new.constprop.0` scalar zero-fill of `[0:U32*512n]` every call (13.6%) |

**Critical cross-cutting discovery:** Parallel fork/join and scheduler overhead is **< 0.5%** on all 4 benchmarks. Nearly **100% of the 6×–17× gap** comes from **5 general compiler passes** missing or over-restricted in `wave3b_unified/compiler.bend`.

---

## 1. `histogram` (`17.4×` C on medium `[18, 7, 24]`, checksum `3307081914`)

### 1.1 Exact `SIGPROF` Profile (94 samples, `0.3832 s` on CPU 2)

| Share | Cum. | Samples | Symbol | Category |
|---:|---:|---:|---|---|
| **18.09%** | 18.09% | 17 | `p111_rt_op` | `runtime-agy.o` (C) |
| **14.89%** | 32.98% | 14 | `p113_rt_array_pair` | `runtime-agy.o` (C) |
| **12.77%** | 45.74% | 12 | `p113d_$direct.Bool.pick` | Bend `p113d` |
| **11.70%** | 57.45% | 11 | `p113d_$product.bump.at` | Bend `p113d` |
| **10.64%** | 68.09% | 10 | `p113d_$direct.prng` | Bend `p113d` |
| **7.45%** | 75.53% | 7 | `p113d_$product.count.go` | Bend `p113d` |
| **6.38%** | 81.91% | 6 | `p113d_$direct.fill.go` | Bend `p113d` |
| **5.32%** | 87.23% | 5 | `p113d_$direct.U32.min` | Bend `p113d` |
| **5.32%** | 92.55% | 5 | `p113d_$direct.bump` | Bend `p113d` |
| **4.26%** | 96.81% | 4 | `p113d_$direct.key` | Bend `p113d` |
| 1.06% | 97.87% | 1 | `p113d_$direct.col.one` | Bend `p113d` |
| 1.06% | 98.94% | 1 | `p113d_$direct.zero.go` | Bend `p113d` |
| 1.06% | 100.00% | 1 | `term_drop` | `runtime-agy.o` (C) |

**Runtime vs Bend split:** `runtime-agy.o` = **34.04%**; Bend `p113d_*` = **65.96%**. Zero samples in `Array.fork`/`Array.join`/scheduler.

### 1.2 Instruction-Level Disassembly Findings

1. **Every single `Array.get` and `Array.set` calls out to C (`p111_rt_op` + `p113_rt_array_pair` = 32.98%):**
   - In `p113d_$direct.fill.go` (`0x405a25`, 86 insns) and `p113d_$product.bump.at` (`0x406086`, 39 insns), every `ks[j] <- v` / `t[i] <- v+1` packs 3 words onto the stack at `-0x850(%rbp)` / `-0x840(%rbp)` and executes `callq p111_rt_op` (op `0x49`, `Array.set`), which runs a switch jump-table dispatch + tag/shift/mask decoding (~50 insns).
   - In `p113d_$product.count.go` (`0x40adda`, 103 insns) and `p113d_$direct.bump` (`0x40611e`, 46 insns), every `ks[q]` / `t[i]` packs 2 words onto the stack and executes `callq p113_rt_array_pair` (op `0x48`, `Array.get`, ~45 insns).
   - **Exact compiler root cause (`selfhost/build/agy/wave3b_unified/compiler.bend:29291-29301`):** `p113a_certificate` requires a **whole-program** `scalar && nr_unshared(book, names)` certificate before `p113a` (inline U32 array fast-path) or `p117v` (loop-invariant base/mask hoisting) will run on *any* function. Because `histogram` calls `Array.fork`/`Array.join`, `nr_unshared` is `False`, disabling inline array ops for the entire binary — even though the `p113a` fast-path already checks `(arr >> 56) == 4 && (arr & 0xffffffffff) >= heap_min` at runtime (which rejects RFC-wrapped/shared handles safely, and even forked `U32` slices in single-threaded / disjoint-slot passes have tag `4` when unboxed!).
2. **`U32.min` → `Bool.pick` burns 18.09% of total runtime per key in `count.go`:**
   - `p113d_$direct.U32.min` (`0x40ad87`, 28 insns, `sub $0x930,%rsp`) computes `cmp %rsi,%rdx; setb %dl; movzbl %dl,%edx` and calls `p113d_$direct.Bool.pick` (`0x40a179`, **141 insns**, `sub $0x920,%rsp`).
   - `Bool.pick` is polymorphic over `A`, so it checks both unboxed `1` and boxed `Bool.True` `(0x10002)` tags **twice**, and then emits **full inline `p111_rt_sink` refcount-drop code** on the unchosen `U32` argument!
   - Compare C (`histogram_c` `0x1200..0x1219`): the entire `count.go` inner loop is **6 instructions total**:
     ```asm
     mov    (%rcx),%edi
     cmp    $0xfe,%edi
     ja     12d8
     add    $0x4,%rcx
     addl   $0x1,(%rdx,%rdi,4)
     cmp    %rcx,%r10
     jne    1200
     ```
     AGY executes **~350+ instructions and 5 function calls** (`U32.min` → `Bool.pick`, `bump` → `p113_rt_array_pair` → `bump.at` → `p111_rt_op`, plus `p113_rt_array_pair` for `ks[q]`) per key — **~58× more instructions than C**.
3. **`fill.go` → `key` → `2× prng` (21.28% combined) has 3 nested out-of-line calls per key + stack round-trip for `% 256`:**
   - `fill.go` calls `key` (`0x4059aa`, 36 insns, `0x930` frame), which calls `prng` (`0x40595d`, 26 insns, `0x8d0` frame) twice.
   - At `0x4059fd..0x405a10`, `U32.mod(x, 256)` spills `%rdi` to `-0x840(%rbp)` and immediately reloads `mov -0x840(%rbp),%eax; and $0xff,%eax`.
   - C inlines `key` + `prng` and SSE2-vectorizes 4 keys/iter (44 insns / 4 keys = 11 insns/key).

---

## 2. `gameoflife` (`13.04×` Clang `-O3`, `3.59×` GCC `-O3` on medium `[12, 32]`, checksum `3681094808`)

### 2.1 Exact `SIGPROF` Profile (849 samples, `3.4021 s` on CPU 2)

| Share | Cum. | Samples | Symbol | Category |
|---:|---:|---:|---|---|
| **75.85%** | 75.85% | 644 | `p113d_$direct.neighbor_count` | Bend `p113d` |
| **16.73%** | 92.58% | 142 | `p113d_$direct.step_cell` | Bend `p113d` |
| **6.71%** | 99.29% | 57 | `p113d_$direct.step` | Bend `p113d` |
| 0.35% | 99.65% | 3 | `p113d_$direct.run` | Bend `p113d` |
| 0.12% | 99.76% | 1 | `p113d_$product.chunk` | Bend `p113d` |
| 0.12% | 99.88% | 1 | `p111_rt_return` | `runtime-agy.o` (C) |
| 0.12% | 100.00% | 1 | `p111_$direct.chunk` | Bend `p111` |

**Runtime vs Bend split:** `runtime-agy.o` = **0.12%**; Bend `p113d_*` = **99.76%**. Pure scalar integer code!

### 2.2 Instruction-Level Disassembly Findings

1. **`p113i` single-pass inliner + `budget=1024` cliff leaves 29 out-of-line calls per `step()`:**
   - In `p113d_$direct.step` (`0x407dee`, 280 insns, `sub $0xaf0,%rsp`), `p113i_function` (`compiler.bend:28970`) starts with `budget=1024` and runs a single non-recursive pass. It inlines **only `step_cell(b, 0)`, `step_cell(b, 1)`, and `step_cell(b, 2)`**, then hits its budget and emits **13 out-of-line `callq step_cell`** (`pos = 3..15`, `0x408118..0x408238`)!
   - Worse, because `p113i` is single-pass, even the 3 inlined `step_cell(b, 0..2)` bodies STILL execute `callq neighbor_count` out-of-line! Result: **29 function calls per generation** (`13 step_cell + 16 neighbor_count`), each allocating `~2.4 KiB` of stack frame (`0x9c0` / `0x9a0`) and saving/restoring 4–5 callee-saved registers.
   - **Zero constant folding after inlining:** In `step` at `0x407ed3..0x407ef6` (for constant `pos=1`), AGY literally emits `movabs $0x0,%r13; imul $0x4,%r13,%r13; add $0x1,%r13; mov %r11d,%ecx; shr %cl,%r13` instead of `shr $1,%ebx`!
   - By contrast, Clang `-O3` inlines all 16 `step_cell(b, 0..15)` + `neighbor_count` into `board_step(b)`, folds every constant bit index `((r±1)&3)*4 + ((c±1)&3)` at compile time, and eliminates all 29 calls and all variable shifts (explaining why Clang `-O3` is `3.6×` faster than GCC `-O3`, which kept `step_cell` out-of-line, and `13.04×` faster than AGY!).
2. **`neighbor_count` (`0x407901`, **214 instructions**, 75.85% of runtime) suffers catastrophic register spills, zero CSE, and `imul $4`:**
   - **Register-pressure blowup from right-nested add tree:** `neighbor_count` evaluates all 8 `cell_get(...)` terms *before* summing them at `0x407c85..0x407ca8`. Holding 5 live partial results (`r8, r9, r13, r14, r15`) plus `r12, rbx, rsi, rdx` exhausts the allocator, causing neighbors 5–8 (`0x407a76..0x407c7e`) to spill **every single intermediate instruction** to `-0x928(%rbp)`..`-0x990(%rbp)` (**~45 stack loads/stores** inside a 3-argument pure leaf function!).
   - **Zero CSE:** `(r-1)&3*4`, `(r+1)&3*4`, `(c-1)&3`, `(c+1)&3` are each recomputed 3 times from scratch.
   - **Strength reduction missing:** `imul $0x4,%reg,%reg` (3-cycle latency) is emitted **8 times** instead of `shl $2` / `lea (,%reg,4)` (1-cycle).
   - **Compare GCC `-O3` `step_cell` (`0x1190`, 82 insns):** Combines `neighbor_count` + `next_cell` in **82 instructions with 0 stack spills**, accumulating the sum eagerly via `lea (%rax,%r8,1),%r9d` and reusing `(r±1)&3*4` and `(c±1)&3`.
3. **Peephole bloat in `step_cell` (`0x407cc7`, 76 insns, 16.73%):**
   - Double negation `xor $0x1,%edi; xor $0x1,%rdi` (`0x407d6f..0x407d75`, `0x407dae..0x407db4`) for `b2u`, plus redundant `mov %rdi,%rax; mov %rax,%r12` prologue copies.

---

## 3. Tuned `editdist` (`14.99×` Clang `-O3`, `12.9×` GCC `-O3`, checksum `466389572`)

### 3.1 Exact `SIGPROF` Profile (402 samples, `1.6186 s` on CPU 2, `3000 10 2 17`)

| Share | Cum. | Samples | Symbol | Category |
|---:|---:|---:|---|---|
| **39.05%** | 39.05% | 157 | `p113d_$direct.columns` | Bend `p113d` |
| **18.91%** | 57.96% | 76 | `p113d_$p118borrow.read.symbol` | Bend `p113d` |
| **11.44%** | 69.40% | 46 | `p113d_$direct.Bool.to_u32` | Bend `p113d` |
| **8.96%** | 78.36% | 36 | `p113_rt_array_pair` | `runtime-agy.o` (C) |
| **7.46%** | 85.82% | 30 | `p113d_$direct.symbol` | Bend `p113d` |
| **6.22%** | 92.04% | 25 | `p111_rt_op` | `runtime-agy.o` (C) |
| **3.23%** | 95.27% | 13 | `p113d_$direct.add_bit` | Bend `p113d` |
| **2.49%** | 97.76% | 10 | `p113d_$direct.random_word` | Bend `p113d` |
| 0.75% | 98.51% | 3 | `p125_rt_ctor4` | `runtime-agy.o` (C) |
| 0.50% | 99.00% | 2 | `term_drop` | `runtime-agy.o` (C) |
| 0.50% | 99.50% | 2 | `p113d_$direct.build_masks` | Bend `p113d` |
| 0.25% | 99.75% | 1 | `p111_rt_keep` | `runtime-agy.o` (C) |
| 0.25% | 100.00% | 1 | `p111_rt_sink` | `runtime-agy.o` (C) |

**Runtime vs Bend split:** `runtime-agy.o` = **16.92%**; Bend `p113d_*` = **83.08%**.

### 3.2 Instruction-Level Disassembly Findings

In C (`editdist_c` `0x1430..0x14c6`), the entire 256-column Myers bit-parallel inner loop is **53 instructions, 0 calls, 0 heap ops, 0 stack spills** (reads `mask[s&3]` in 1 `mov` and `delta[j]` in 1 `movzbl`).  
In AGY, `p113d_$direct.columns` (`0x40b3e6`, **729 instructions total**, ~350+ executed/iter + **7 calls/iter**) suffers **5 stacked bottlenecks**:

1. **Per-iteration heap allocation & deallocation of `Tuple{arr, hin}` inside `columns`!**
   - `columns` was **NOT** `$product`-unboxed (compiled as `$direct.columns`, taking boxed `r: Array<U32> & U32` in `%r13`).
   - At the end of every loop iteration (`0x40bf75..0x40c027`), `columns` **pops a 2-word heap node from the freelist** (`p125_rt_ctor2` inline fast-path, ~35 insns) to box `Tuple{arr2, hin}`!
   - At the top of the very next iteration (`0x40b91e..0x40bc20`), `columns` **immediately unpacks and pushes that exact 2-word node back onto the freelist** (`p125_rt_take2` inline fast-path, ~60 insns executed, 150 insns of code bloat)!
2. **26.37% of total runtime + 2 heap RC updates/iter just to index a 4-element `Masks4{a,b,c,d}` (`symbol` 7.46% + `$p118borrow.read.symbol` 18.91%):**
   - `columns` runs inline `p111_rt_keep` (`0x40bc37..0x40bcd5`) to bump `m`'s refcount on the heap, then calls `$direct.symbol` (`0x409338`, 104 insns), which runs inline `p118_rt_borrow_scalar_safe` → calls `$p118borrow.read.symbol` (`0x408b9d`, **398 insns!**) → chains `cmp 0 / sub 1 / cmp 0 / sub 1`, checks ctor tag `0xa4` twice, **copies all 4 fields of `Masks4` to stack `-0x840(%rbp)`**, then copies all 4 again to `-0x9e8..-0xa00(%rbp)` just to return ONE field! Then `$direct.symbol` runs inline `p111_rt_sink` (`0x409405..0x4094a1`) to decrement `m`'s refcount back down!
   - Compare C: `mov 0x20(%rsp,%rcx,4),%eax` (**1 instruction** vs ~120 insns + 2 calls + 2 RC writes).
3. **15.18% in C runtime calls for `Array.set` (`p111_rt_op` 6.22%) and `Array.get_unchecked` (`p113_rt_array_pair` 8.96%):**
   - Just like `histogram`, `editdist` fails the whole-program `p113a_certificate` (because `batch` uses a parallel fork `a b = batch(...) batch(...)`), even though `pair()`'s `Array<U32>` is 100% local and unshared! Even `Array.get_unchecked` falls back to `p113_rt_array_pair`!
4. **11.44% in out-of-line `Bool.to_u32` (called 2× per iteration, `0x40bd35` & `0x40bde7`):**
   - `columns` already computes unboxed `0/1` via `cmp $0x0,%rdi; sete %dil; movzbl %dil,%edi`, then calls `p113d_$direct.Bool.to_u32` (`0x4078ce`, 57 insns, `0x900` frame) which tests both unboxed `1` and boxed `0x10002` twice just to return the exact same `0` or `1`!
5. **Out-of-line `random_word` call (2.49%) + heavy scalar spilling:**
   - Inside `columns`, `j`, `mv`, `score`, `hin`, `eq`, `xv`, `neg`, `diff`, `hp`, `hm` are all spilled to `-0x38(%rbp)`..`-0xa10(%rbp)` (~25 stack loads/stores per iteration).

---

## 4. Tuned `bst` (`6.14×` Clang `-O3`, `5.1×` GCC `-O3`, checksum `286708568`)

### 4.1 Exact `SIGPROF` Profile (368 samples, `1.4790 s` on CPU 2, `600000 100 64 17`)

| Share | Cum. | Samples | Symbol | Category |
|---:|---:|---:|---|---|
| **27.72%** | 27.72% | 102 | `p113d_$direct.repeat_key` | Bend `p113d` |
| **24.46%** | 52.17% | 90 | `p113d_$product.sorted_fold` | Bend `p113d` |
| **20.11%** | 72.28% | 74 | `p113d_$direct.collect` | Bend `p113d` |
| **13.59%** | 85.87% | 50 | `blk_new.constprop.0` | `runtime-agy.o` (C) |
| **13.04%** | 98.91% | 48 | `p113d_$product.bump` | Bend `p113d` |
| 0.54% | 99.46% | 2 | `p113d_$direct.timed_fold` | Bend `p113d` |
| 0.54% | 100.00% | 2 | `term_drop` | `runtime-agy.o` (C) |

**Runtime vs Bend split:** `runtime-agy.o` = **14.13%**; Bend `p113d_*` = **85.87%**.

### 4.2 Instruction-Level Disassembly Findings

Unlike `histogram` and `editdist`, `bst` **passes** `p113a_certificate` (no parallel fork), so `sorted_fold` gets `p117v` hoisted array reads (`mov (%r10,%rdi,4),%r14d`) and `collect`/`bump` get inline `p113a` array fast-paths. Yet `bst` is still `6.14×` slower than Clang `-O3` because of **3 clean bottlenecks**:

1. **`sorted_fold` calls `repeat_key` out-of-line 257× per rep — ~200 of them with `v == 0` (52.18% combined!):**
   - `p113d_$direct.repeat_key` (`0x40792c`, 31 insns) is a tiny tail-recursive loop (`P113DAgain`), which `p113i_eligible` rejects (`p137qi_returns` does not inline tail-recursive callees).
   - For `n = 64` keys across `257` buckets, ~200 buckets have `v = 0`. In C (`bst_c` `0x1330..0x135a`), an empty bucket takes **5 instructions** (`mov (%r9,%rdi,4),%ecx; test %ecx,%ecx; je next; add $1,%rdi; cmp $0x101,%rdi`).
   - In AGY, every empty bucket executes a full `callq repeat_key` (`push %rbp; sub $0x920,%rsp; save r12/rbx; cmp $0,%rdi; restore; retq` = **20 instructions + call/ret overhead**), AND `sorted_fold` spills `left`, `mask`, `base_ptr` to `-0x910(%rbp)`..`-0x950(%rbp)` every iteration!
2. **`collect` (20.11%) does NOT inline `bump` (13.04%) and repeats unhoisted array guards + dead scratch stores (33.15% combined):**
   - `collect` (`0x408412`, 121 insns) did NOT get `p117v` loop-invariant hoisting because `a` is passed to out-of-line `bump` (`0x4082e5`, 73 insns).
   - Per key, `collect` runs a 15-insn tag/bounds/mask check + dead stores to `-0x850(%rbp)` + stack pair round-trip at `-0x908(%rbp)` + `callq bump`, and `bump` **re-runs the exact same 25-insn tag/bounds/mask check + dead stores to `-0x840(%rbp)`** (written unconditionally before the fast-path branch!).
   - Total: **~95 insns + 1 call/key** vs C's **14 insns/key** (`bst_c` `0x1305..0x1328`). Also `U32.mod(seed, 257)` (`0x408496..0x4084a3`) spills `seed` to `-0x850(%rbp)` and immediately reloads it!
3. **`blk_new.constprop.0` (`0x4115b0`, 13.59% of runtime) allocates & scalar-zero-fills `[0 : U32*512n]` on every call:**
   - Every `bench()` call allocates a 512-word U32 array via `p111_rt_op(0x47)` → `blk_new.constprop.0`, whose fill loop (`0x411700..0x411722`) tests `test %r14b,%r14b` and reloads `(%r8)` **on every single 4-byte store** (512 iterations × 6 insns = ~3,072 insns/call!).
   - Compare C (`bst_c` `0x12da..0x12ec`): stack `uint32_t counts[257]` zeroed via `mov $0x80,%ecx; xor %eax,%eax; rep stosq` (**1 instruction, 0 heap traffic**).

---

## 5. Ranked General Compiler Pass Recommendations

All recommendations below are **100% general** (zero benchmark-specific pattern matching), directly addressing the verified root causes across all 4 workloads:

| Rank | General Compiler / Runtime Pass | Target Root Cause | Affected Benchmarks | Est. Speedup |
|---:|---|---|---|---|
| **1** | **Per-function / runtime-guarded `p113a` inline array fast-path + `p117v` LICM (remove whole-program `p113a_certificate` gate)** | `p113a_certificate` (`compiler.bend:29291`) disables inline `Array.get`/`Array.set` & `p117v` hoisting globally whenever *any* def in the book forks or uses non-scalar arrays. `p113a` already checks `(arr >> 56) == 4 && loc >= heap_min` at runtime; lift the gate to per-function (and sink cold `scratch` arg stores into the fallback branch!). | `histogram` (`p111_rt_op`+`p113_rt_array_pair` = 33.0%), `editdist` (15.2%), `bst` (`collect`+`bump` dead stores & LICM) | **`2.0–3.5×`** on `histogram`, **`1.3–1.6×`** on `editdist` |
| **2** | **Multi-pass / higher-budget `p113i` inliner + allow small tail-loops & `p111_rt_op`/`p111_rt_fail`/`p111_rt_sink` callees + post-inline constant folding** | Single-pass `p113i` (`budget=1024`, `site<16`, `p113i_clean` rejecting `rt_op`/`rt_fail`/`rt_sink`, rejecting `P113DAgain` loops) blocks inlining of `step_cell` (13/16) & `neighbor_count` (`gameoflife`), `U32.min`/`Bool.pick`/`bump`/`bump.at`/`prng`/`key` (`histogram`), `Bool.to_u32`/`symbol`/`random_word` (`editdist`), and `repeat_key`/`bump` (`bst`). Adding post-inline constant folding collapses `step(b)` bit indices to immediates. | **ALL 4 benchmarks** (`gameoflife` 99%, `bst` 85%, `histogram` 60%, `editdist` 40%) | **`3.0–6.0×`** on `gameoflife`, **`2.0–3.0×`** on `bst` & `histogram`, **`1.5–2.0×`** on `editdist` |
| **3** | **Extend `$product` unboxing to tail-recursive functions returning a product + eliminate redundant `Bool` tag/RC checks (`Bool.to_u32`, `Bool.pick` on scalar types)** | `editdist`'s `columns` (`r: Array<U32> & U32 -> Array<U32> & U32`) is not `$product`-unboxed, causing a heap `ctor2`+`take2` every iteration. Meanwhile `Bool.to_u32` (11.4% in `editdist`) and `Bool.pick` (12.8% in `histogram`) test boxed `Bool` tags and emit `p111_rt_sink` on unboxed `U32`s. | `editdist` (~35%+), `histogram` (18.1%) | **`1.8–2.5×`** on `editdist`, **`1.25×`** on `histogram` |
| **4** | **Scalar register allocation, CSE, & strength reduction (`shl` for power-of-2 `imul`, eliminate `scratch` spill round-trips, accumulate associative sums eagerly, drop dead field copies in `$p118borrow.read.*`)** | `neighbor_count` spills ~45 temps to stack and runs 8× `imul $4` with 0 CSE; `$p118borrow.read.symbol` copies all 4 `Masks4` fields twice to stack to return 1; `U32.mod` spills operand to stack and reloads it; `columns` & `sorted_fold` spill loop invariants. | `gameoflife` (75.9%), `editdist` (26.4%+), `bst`, `histogram` | **`2.0–3.0×`** on `gameoflife`, **`1.3–1.6×`** on `editdist` |
| **5** | **Fast-path `memset` / hoisted fill loop in `blk_new` (`runtime-agy.o`) + stack-allocated/reused small fixed-size `Array<U32>` escape analysis** | `blk_new.constprop.0` (`13.59%` of `bst`) runs a branchy 6-insn/element scalar loop to fill `[0 : U32*512n]`. Hoisting `is_ref` out of the fill loop and using `memset(ptr, 0, n*4)` when `val == 0` cuts `blk_new` by ~10× immediately; non-escaping small fixed-size arrays can later be stack-allocated. | `bst` (13.6%), `editdist` (`[2:U32*256n]`), any short-array kernel | **`1.15×`** on `bst` (instant runtime win), more with stack-array escape analysis |

### Projected Combined Impact (All 5 Passes)
- **`histogram`**: `17.4×` → **`~1.5–2.5×` C** (remaining gap is SSE2 auto-vectorization of `fill.go`).
- **`gameoflife`**: `13.04×` Clang → **`~1.3–2.0×` Clang** (inlining + constant folding + CSE + zero-spill regalloc collapses `step` to pure immediate bit ops).
- **Tuned `editdist`**: `14.99×` Clang → **`~1.5–2.2×` Clang** (eliminating per-iter `Tuple` alloc, `p118borrow` overhead, `Bool.to_u32`, and C array calls brings `columns` down from ~350 insns to ~65 insns).
- **Tuned `bst`**: `6.14×` Clang → **`~1.3–1.8×` Clang** (inlining `repeat_key` + `bump` + `p117v` hoisting in `collect` + `memset` in `blk_new`).

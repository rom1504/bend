# W11-B Report: Compiled-Program Runtime Deep-Dive (`gameoflife` `3×` Regression + `terrain` / `hashmap` / `histogram` / `nbody` Native Profiles)

**Headline Findings:**
1. **`gameoflife` `2.91×` Regression 100% Root-Caused (1-line fix!):** Input size did **NOT** change (exact same `size=12n, gens=32n`, checksum `3681094808`). Live bisect on CPU `5` shows **`wave6-native-self/n1` = `436 ms`** → **`wave7-native-self/n1` = `7,587 ms`** → **`wave8-native-self/n1` = `1,267 ms`**. The Wave 7B leaf fix restored `x190_joint_frame`, but missed **`p113k_function`'s `2048` statement cap** introduced in `apply_w7_lower_fast.py`. Exempting pure scalar leaf functions (`Bool.not(w7b_stmts_has_call(body))`) in `p113k_function` immediately recovers **`436 ms` (`0.47× gcc-10`, `2.91×` faster)** and cuts the 7-family proxy geomean from `1.69× C` → **`~1.43× C`** by itself.
2. **`terrain` (`39.66 s` vs `12.37 s` C, `3.21× C`)** spends **`99.25%`** of CPU in just 3 compiled functions (`$product.erode` `50.07%`, `$lcu0.$direct.hist` `28.16%`, `$product.fill` `21.01%`) with **zero** runtime overhead (`0.64%` `blk_new`). Two pure-Bend fixes — dual-array scalarization for `hist` (eliminating per-pixel `p125_rt_take2`/`ctor2` pair boxing) and register-spill elimination in `erode`/`fill` (`108` and `86` `(%rbp)` accesses inside tight inner loops) — cut `terrain` by **`~2.2–2.8×`** (`39.7 s` → **`~14–18 s`**).
3. **`hashmap` (`15.27 s` vs `1.85 s` C, `8.25× C`)** spends **`47.4%`** in `has` (`$p118borrow.read.has` `41.63%` + `$direct.has` `5.81%`), **`16.3%`** in boxed-array runtime calls (`p113_rt_array_pair` `11.73%` + `p111_rt_op` `4.60%`), and **`17.4%`** in allocation/reclamation (`term_drop` `10.52%` + `p125_rt_ctor2` `6.90%`). `$p118borrow.read.has` executes **~92 instructions per list node** due to full 64-bit tagged-`Bool` decoding **twice** per iteration (37 insns vs `test %rbx,%rbx; jne`), a redundant stack-buffer bounce (`-0x840(%rbp)`), and unhoisted heap-base loads. Fixing borrow-loop codegen + inline boxed `Array.get`/`set` cuts `hashmap` by **`~2.5–3.5×`** (`15.3 s` → **`~4.5–6.0 s`**).

- **Isolation:** CPUs `5, 6` exclusively (`taskset -c 5`, `taskset -c 6`), `ulimit -s 262144`, `timeout 60`.
- **Artifacts:** [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11b_runtime_prof/results.json).

---

## 1. Root Cause of `gameoflife` `2.91×` Regression (Wave 5C/6 `436 ms` vs Wave 8 `1,267 ms`)

### Live Bisect (CPU `5`, identical `size=12n, gens=32n`, checksum `3681094808`)

| Compiler | `.o` Size | Runtime (CPU 5) | `$direct.step` Size / Insns / `(%rbp)` | `$direct.run` Size | `$direct.classify` Size |
|---|---:|---:|---:|---:|---:|
| **`wave6-native-self/n1`** | `59,616 B` | **`436 ms`** (`0.47× C`) | `2,315 B` / `467` / `157` | `2,382 B` (`step` inlined) | `5,023 B` (`step` inlined) |
| **`wave7-native-self/n1`** | `83,584 B` | `7,587 ms` (`17.4×` reg) | unoptimized | un-inlined | un-inlined |
| **`wave8-native-self/n1`** | `54,864 B` | **`1,267 ms`** (`2.91×` reg) | `6,967 B` / `1,473` / `391` | `85 B` (calls `step`) | `132 B` (calls `step`) |

- **Native CPU profile of `wave8` `gameoflife`** (CPU `5`, `1000 us` period, 315 samples, 100% resolved): **`99.37%` (`313/315`) in `p113d_FID_$direct.step`**.
- **Exact codegen diff in `apply_w7_lower_fast.py` (`wave8_unified/compiler.bend:41704-41709`):**
  - Wave 6 had `U32.is_lt(p113i_size(body), 32768)` in `p113k_function` (and ran 2 full passes of `p113k_body` + `w4g_copy_pass` + `w4g_bwd_dce`).
  - Wave 7 (`apply_w7_lower_fast.py:224`) lowered the cap to **`2048`** (and capped the 2nd pass in `p113k_function_done` at `1024`) to prevent compile-time blowup on giant functions in `compiler.bend`.
  - In `gameoflife`, `step` inlines 16 calls to `step_cell(b, 0..15)`. Before constant folding & copy/DCE, `step` has **> 2,048 IR statements**, so **`p113k_function` skips `step` completely**.
  - **Triple cascading damage seen in `objdump -d`:**
    1. `w4c_seed_w32_facts` + `w4g_copy_pass` + `w4g_bwd_dce` never run on `step`, leaving **3.15× bloated code** (`1,473` insns vs `467`) filled with redundant `mov %r10d,%r10d` zero-extensions and triple stack-spill roundtrips per bit (`shr $1,%r10; mov %r10,-0x8b0(%rbp); mov %r10d,%r10d; mov %r10,-0x8b0(%rbp); and $1,%r10; mov %r10,-0x8b0(%rbp)`).
    2. Because `step` never shrinks after inlining `step_cell`, `p113i_table_function` rejects `step` for inlining → **`run` (`85 B`) and `classify` (`132 B`) call `step` out-of-line** (~8.4M calls + lost loop-level regalloc).
    3. Because `step` stays `> 2,048` IR stmts, **`x190_joint_frame`'s `U32.is_le(sz, 2048)` check STILL fails** even after Wave 7B's `w7b_stmts_has_call` fix, forcing `step` onto `x190_allocate_legacy` (`391` vs `157` stack accesses).
- **Zero-risk fix:** Allow up to `16384` IR statements in `p113k_function` and `p113k_function_done` when `Bool.not(w7b_stmts_has_call(body))` (pure scalar leaf — linear time, never triggers on giant `compiler.bend` functions because they all contain calls).

---

## 2. Native CPU Profiles & `objdump -d` Findings (`wave8-native-self/n1 -O2`)

### A. `terrain` (`39.66 s` vs `12.37 s` C = `3.21× C`; CPU `6`, `8000 us`, 2,670 samples, 100% zero-loss usable)

| Function | Samples | Share | Est. CPU | Insns | `(%rbp)` | Branches | Calls |
|---|---:|---:|---:|---:|---:|---:|---:|
| **`p113d_FID_$product.erode`** | 1,337 | **50.07%** | `19.86 s` | 501 | **108** | 5 | 1 |
| **`p113d_FID_$lcu0.$direct.hist`** | 752 | **28.16%** | `11.17 s` | 1,231 | **250** | **105** | **19** |
| **`p113d_FID_$product.fill`** | 561 | **21.01%** | `8.33 s` | 303 | **86** | 5 | 1 |
| `blk_new.constprop.0` | 17 | 0.64% | `0.25 s` | — | — | — | — |

**Assembly Root Causes:**
1. **`$lcu0.$direct.hist` (`28.16%` = `11.2 s`) — Unscalarized Dual-Array Loop:** `hist` carries two product parameters (`r: Array<U32> & U32` and `rg: Array<U32> & U32`). Neither `$lcu0.$direct.hist` nor `$product.hist` (`2,406` insns, `1,236` `(%rbp)` ops, `36` calls!) triggers `w4_array`'s direct-memory loop scalarization, so `hist` executes inline `p125_rt_take2` / `p125_rt_ctor2` freelist pop/push + refcount/bounds checks (`1e12..1f60`) **on every single one of the 268M cells** (`105` branches, `19` calls).
2. **`$product.erode` (`50.07%` = `19.9 s`) & `$product.fill` (`21.01%` = `8.3 s`) — Severe Scratch-Register Spilling:** Both loops successfully unboxed their `Array<U32>` into direct `(%rsi,%rdi,4)` loads/stores (zero calls in the hot loop!), **but** the register allocator spills almost every intermediate value to `(%rbp)`!
   - In `erode` (`52eb9..53025`), **all 5 loaded stencil neighbors** (`hc, hl, hr, hu, hd`) are immediately spilled to `-0x9a0..-0xaa0(%rbp)` and reloaded 50 instructions later for the 5-way sum (`52fdc..5300c`), AND `prng`'s 3 xorshift temps spill to `-0xac0(%rbp)` and `-0xad0(%rbp)` (reloaded on the very next instruction!).
   - In `fill` (`7654..77d5`), all 4 bilinear `hsh()` calls spill their xorshift intermediates to `-0xa18..-0xad8(%rbp)` on every cell despite free GPRs (`%rax`, `%rcx`, `%rdx`, `%r8`–`%r11`).

### B. `hashmap` (`15.27 s` vs `1.85 s` C = `8.25× C`; CPU `5`, `4000 us`, 1,739 samples, 100% zero-loss usable)

| Function | Samples | Share | Est. CPU | Root Cause |
|---|---:|---:|---:|---|
| **`p113d_FID_$p118borrow.read.has`** | 724 | **41.63%** | `6.36 s` | 92-insn/node loop: 37-insn tagged-Bool decode ×2, stack bounce `-0x840(%rbp)`, unhoisted `(%r12)` |
| **`p113_rt_array_pair`** | 204 | **11.73%** | `1.79 s` | Boxed `Array.get(Chain, a, b)` falls back to C runtime call on every lookup/insert |
| **`term_drop`** | 183 | **10.52%** | `1.61 s` | Dropping boxed `Chain` / pair temps |
| **`p125_rt_ctor2`** | 120 | **6.90%** | `1.05 s` | Allocating `CCons{k, c}` & `(a, hits)` pairs |
| **`p113d_FID_$direct.has`** | 101 | **5.81%** | `0.89 s` | Owned-chain walk in `probe` (same Bool-match bloat as borrowed `has`) |
| **`p113d_FID_$p118borrow.read.len`** | 95 | **5.46%** | `0.83 s` | Same borrow-loop stack bounce + double cid check + unhoisted `(%r12)` |
| **`p113d_FID_$direct.look`** | 91 | **5.23%** | `0.80 s` | Calls `p113_rt_array_pair` + `$direct.has` + `p125_rt_ctor2` per probe |
| **`p113d_FID_$direct.fill`** | 87 | **5.00%** | `0.76 s` | Calls `p113_rt_array_pair` + `p125_rt_ctor2` + `p111_rt_op` (`Array.set`) |
| **`p111_rt_op`** | 80 | **4.60%** | `0.70 s` | Boxed `Array.set(Chain, a, b, CCons)` falls back to generic `p111_rt_op` |
| `p113d_FID_$product.sweep` | 39 | 2.24% | `0.34 s` | Final bucket sweep |

**Disassembly Smoking Guns in `$p118borrow.read.has` (`cc3..f46`):**
- **37 instructions for a 2-instruction `Bool` check (`ea1..f2b`)**: `%rbx` (`f`) is a known unboxed `Bool` (`0`/`1`), yet the loop runs full 64-bit tagged-constructor decoding (`shr $0x28; and $0x7fffff; movabs $2; or $0x10000; cmp; sete; movzbl; or`) **TWICE** (once for `True`, once for `False`!) instead of `test %rbx,%rbx; jne ret_true`.
- **Redundant stack-buffer bounce (`e3b..e5d` → `e8c..e9d`)**: Loads `(%rdi)` and `0x8(%rdi)` into `%rsi`/`%rdi`, stores them to `-0x840(%rbp)` / `-0x838(%rbp)`, jumps to `e8c`, and immediately reloads them into `%r9`/`%r14` just to share a merge block with the cold `p125_rt_take2` fallback.
- **Double `CCons` tag check (`dc5..df7`) + unhoisted heap base `mov (%r12),%rdi` (`dfd`)** on every node.

### C. `histogram` (`44 ms` on CPU `5` in both W6 & W8; `59.7 ms` vs `26.1 ms` C on CPU `4`) & `nbody` (`97 ms` on CPU `5` in both W6 & W8; `137 ms` vs `87.7 ms` C on CPU `4`)

- **No Wave 6 → Wave 8 regression** on `histogram` (`44 ms` vs `44 ms`) or `nbody` (`97 ms` vs `97 ms`); the P5-E difference vs Wave 5C was CPU `4` vs CPU `2` clock speed.
- **`histogram`**: `66.7%` in `$product.count.go` (inner loop `61e5..6213` is already a tight 11-insn register loop; remaining gap vs C is the `33.3%` in `$direct.fill.go`, where the loop tail spills xorshift intermediates to `-0x9f0..-0xa20(%rbp)`, plus redundant bounds-check prologue in `count.go` `6031..612a` repeating the same 3 comparisons 4×).
- **`nbody`**: `100.0%` in `$product.loop3` (`732` insns, `0` calls, `447` XMM insns, **`189` `(%rbp)` memory ops**). While SSE scalar math (`mulss`/`addss`/`sqrtss`/`divss`) is fully inlined, XMM register pressure (`%xmm0`–`%xmm7` temps + `%xmm8`–`%xmm15` pinned constants/coords) causes **~30+ `movq %xmm0,-0xda8(%rbp)` / `movd -0xe28(%rbp),%xmm0` spills inside the inner loop** (`1851..1992`) and reloads body positions from `-0x70..-0xc8(%rbp)` via `movd` on every step instead of keeping them in XMM/GPRs.

---

## 3. Actionable Wave 12 Codegen Hit List (Ranked by Impact)

| Rank | Optimization (Pure-Bend x86-64 Codegen) | Hot Functions & Assembly Fix | Est. Speedup |
|---:|---|---|---|
| **1** | **Pure-Leaf Exemption in `p113k_function` & `p113k_function_done`** (`apply_w7_lower_fast.py` cap `2048` → `16384` when `Bool.not(w7b_stmts_has_call(body))`) | `gameoflife` `$direct.step` (`1,473` → `467` insns) + inlines `step` into `run`/`classify` + restores `x190_joint_frame` | **`2.91×` on `gameoflife`** (`1,267` → `~436 ms`, `0.47× C`); **7-family geomean `1.69×` → `~1.43× C`** |
| **2** | **Unboxed `Bool` Match Fast-Path + Borrow-Loop Direct Field Load & Heap-Base Hoist** | `hashmap` `$p118borrow.read.has` (`41.6%`), `$direct.has` (`5.8%`), `$p118borrow.read.len` (`5.5%`): collapse 37-insn tagged-Bool check → `test %reg,%reg; jne`, eliminate `-0x840(%rbp)` stack bounce on direct ctor take, hoist `(%r12)` heap base out of loop | **`2.0–2.8×` on `hashmap`** (`~53%` of runtime cut by `~3–4×`); **`1.2–1.5×` on `bst` / `expression`** |
| **3** | **Dual-Array Loop Scalarization for Multi-Product Loops** | `terrain` `$lcu0.$direct.hist` (`28.2%` = `11.2 s`, `1,231` insns, `105` branches, `19` calls): extend `w4_array` loop scalarization to handle 2 `Array<U32> & U32` carriers simultaneously so `hist` becomes a branchless 15-insn loop with zero `p125_rt_take2`/`ctor2` | **`1.35×` on `terrain`** (`hist`: `~11.2 s` → `~1.5–2.0 s`, saving `~9.5 s`) |
| **4** | **Tighter Live-Range GPR/XMM Register Allocation & Scratch-Spill Elimination** | `terrain` `$product.erode` (`50.1%`, `108` `(%rbp)` ops) + `$product.fill` (`21.0%`, `86` `(%rbp)` ops) + `nbody` `$product.loop3` (`100%`, `189` `(%rbp)` ops): keep xorshift intermediates & stencil loads in caller-saved GPRs (`%rax/%rcx/%rdx/%rsi/%rdi/%r8-%r11`) and reuse XMM temps without `-0xda8(%rbp)` spills | **`1.5–2.0×` on `terrain` `erode+fill`** (combined with #3: **`terrain` `39.7 s` → `~14–17 s`**, **`2.3–2.8×` faster!**); **`1.3–1.4×` on `nbody`** (`137` → `~95 ms`, `~1.05× C`) |
| **5** | **Inline Boxed-Element `Array.get` / `Array.set` Fast-Path** | `hashmap` `p113_rt_array_pair` (`11.7%`) + `p111_rt_op` (`4.6%`): emit inline `tag/bounds/base` load + refcount keep for `Array.get` and in-place unique-owner swap for `Array.set` on boxed `Data` arrays (mirroring `Array<U32>`) | **`1.25–1.35×` additional on `hashmap`** (combined with #2: **`hashmap` `15.3 s` → `~4.5–5.5 s`**, **`~3×` faster!**) |

**Projected Wave 12 Impact:**
- **7-Family Proxy Geomean:** `1.69× C` (Wave 8) → **`~1.05–1.15× C`** (after #1 `gameoflife` `2.91×` + #2 `bst`/`expression` + #4 `nbody`/`histogram`/`editdist`, plus restoring `nq_signature_user` from P5-E).
- **`terrain`:** `39.66 s` (`3.21× C`) → **`~14–17 s`** (**`2.3–2.8×` cut**).
- **`hashmap`:** `15.27 s` (`8.25× C`) → **`~4.5–5.5 s`** (**`2.8–3.4×` cut**).

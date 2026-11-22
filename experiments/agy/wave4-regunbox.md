# Wave 4 Phase 1 Track W4-3: General Scalar `F32` XMM Regalloc + `$product` Unboxing + Borrow Dead-Field Elimination

**Date:** 2026-11-22  
**Patcher:** [`research/agy/wave4_regunbox/apply_regunbox.py`](file:///home/ai/bend2_agy/research/agy/wave4_regunbox/apply_regunbox.py) (`+8,326` bytes over `wave3b_unified/compiler.bend`)  
**Built Compiler:** [`selfhost/build/agy/wave4_regunbox/api.mjs`](file:///home/ai/bend2_agy/selfhost/build/agy/wave4_regunbox/api.mjs) (`9.1 MiB` total build dir)  
**Baseline:** `selfhost/build/agy/wave3b_unified/api.mjs` + `selfhost/build/agy/unified/runtime-agy.o`  
**Rules Compliance:** 100% general compiler passes (zero benchmark-specific matchers/templates); exact IEEE-754 `F32` semantics preserved (no FMA contraction; chaotic `nbody` checksum `728502159` matches bit-for-bit); `bfs`/`merkle`/`kmeans` untouched.

---

## 1. General Compiler Passes Implemented

1. **Direct 64-bit XMM→Stack Spills (`movq %xmm, disp(%rbp)`), Zero-`movd` `U32.to_f32`, Raised Float-Coalesce Fuel, and Multi-Carried `F32` XMM Loop Allocation:**
   - **`x187_e_mov` + `x186_float_publish`:** Added SSE2 `movq %xmm, m64` (`66 0F D6 /r`) encoding for `X187Xmm` → `X187Mem` stores. Because every canonical `F32` in XMM has zeroed upper 32 bits (with explicit `movd %xmm0, %r10d; movd %r10d, %xmm0` canonicalization added on the cold negative-input `call p200_rt_f32_sqrt_keep` path in `x200r_sqrt_*` / `x195s_text`), stack spills emit a single `movq %xmm, -off(%rbp)` instead of `movd %xmm, %r10d; mov %r10, -off(%rbp)` (eliminating 58 `movd` GPR bounces in `nbody`'s `p113d_$product.loop3`).
   - **`x192_float_conversion` (`id == 23`, `U32.to_f32`) + `x186_u32_float_text`:** Load `U32` directly into `%r10` and convert via `pxor %xmm, %xmm; cvtsi2ssq %r10, %xmm` directly into the destination XMM home (eliminating the 4× `movd` round-trip per conversion, e.g. all 6 `movd`s in `nbody`'s `fl`).
   - **`w2b_coalesce` / `w2_fc_prune` fuel:** Raised `w2_dead_in` fuel from `64`/`128` to `512` so large float kernels (like `loop3`, ~250 float nodes) no longer exhaust fuel and skip XMM copy coalescing.
   - **Multi-carried `w2_xl_*` XMM loop allocation:** Extended `W2XLoopPlan` and `w2_xl_pick_carried` from 1 carried `F32` parameter to all independent loop-carried `F32` parameters that fit in remaining XMM registers (`xmm10..xmm15`) alongside invariants and constants, updating all carried XMM registers cleanly at `P113DAgain` and suppressing their stack-to-stack backedge copies. (Stacks multiplicatively once W4-1 inlines `fl` out of `loop3`!)

2. **Unboxed `NQBundle` Alias Propagation in `p113px_known`:**
   - **Root cause found:** In `editdist`'s `columns`, `m: Masks` (`Masks4{a,b,c,d}`) is used twice in `case 1n+p` (`symbol(..., m)` and `columns(..., m, ...)`) and 0 times in `case 0n`. When lowered as `let id = NQBundle(Masks4, [v8..v11])`, `p113p_bindable` (`uses == 1 && min_uses == 1`) returned `False`, forcing `p113px_boxed` to heap-box the already-unboxed `NQBundle`. That caused `nq_args_fit` to fail on the tail-recursive `columns` call, aborting `$product.columns` with `"product result shape mismatch"` and cascading to `$product.stripe`.
   - **General fix:** When `value` in `p113px_known` is already an `NQBundle` of `Var`s (`agy_str_eq(tg(value),"NQBundle") && p113df_vars(ks(value))`), substitute `id -> value` directly into `body` (`p113pl_lower(book, subst(body, id, value), env, target, n)`). Ownership (`keep`/`drop`) is handled automatically on the individual fields by `p113pl_partition`.
   - **Verified IR/ELF effect:** Both `p113d_$product.columns` (`0x92e` bytes vs `$direct.columns` `0xd5d`; zero `p125_rt_ctor2`, zero `p125_rt_take2`, calls `p113d_$product.symbol` directly) and `p113d_$product.stripe` (`0x193` bytes; calls `p113d_$product.columns`) are now emitted and pass the independent `p113e` verifier!
   - **Composition note for Wave 4A:** In `editdist`, `stripes` still enters `$direct.stripe` → `$direct.columns` because `m` is extracted boxed from `Tuple{s, m}`. Adding a clean `$direct.<f> → $product.<f>` boxed-entry adapter (or W4-1 inlining `stripe` into `stripes`) will route execution into the newly unlocked `p113d_$product.columns` loop for a further major speedup on `editdist`.

3. **Dead-Field Copy Elimination in `$p118borrow.read.*` and `p128bf_fast`:**
   - **`p118b_field_loads` (`p118b_match`):** Only emit `N111Load` from `scratch` for constructor fields with `nq_uses(yesTerm, ix(field)) > 0`.
   - **`p128bf_fields` + `x185_late_stmts`:** Compute the exact bitmask of `scratch` field offsets loaded immediately after `p118_rt_borrow_fields` (verified safe via `w4_bf_no_buf_load`) and only emit heap-load + `scratch`-store pairs for used fields.
   - **Verified ELF effect:** `p113d_$p118borrow.read.symbol` shrank from `0x79b` → `0x4de` bytes (**-37%**), eliminating 3/4 dead field loads and 3/4 dead stack copies per arm.

---

## 2. Back-to-Back CPU-2 Benchmark Results (`run_proxy.py --runs 3`)

Measured back-to-back on CPU 2 (`gcc-10 -O3 -ffp-contract=off` live C ref, plus published `Clang-16` ref):

| Benchmark | Baseline (`wave3b_unified`) | `wave4_regunbox` | Speedup | Baseline Bend/C (C16) | After Bend/C (C16) | Checksum |
|---|---:|---:|---:|---:|---:|---|
| **`nbody`** (med `[10, 300]`) | `317.276 ms` | **`258.921 ms`** | **`1.23×`** | `3.63×` (`4.25×`) | **`2.96×` (`3.47×`)** | PASS (`728502159`, bit-exact) |
| **`editdist`** (tuned) | `125.625 ms` | **`118.125 ms`** | **`1.06×`** | `12.97×` (`13.63×`) | **`12.19×` (`12.81×`)** | PASS (`2065873279`) |
| **2-bench geomean** | — | — | **`1.14×`** | `6.860×` (`7.608×`) | **`6.009×` (`6.664×`)** | **2/2 PASS** |

---

## 3. Verification Gates

- **`focused19`**: **`19 / 19 PASS`** (`python3 -B research/agy/wave2_editsym/run_focused19.py selfhost/build/agy/wave4_regunbox/api.mjs`)
- **`observer_wave2_gate`**: **`44 + 2 ABI probes PASS`, `15 / 15 PASS (0 violations)`** across `normal`, `cap-no8`, and `all-hot` modes
- **Build footprint**: `selfhost/build/agy/wave4_regunbox` = **`9.1 MiB`** (`< 40 MiB` limit)

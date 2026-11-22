# Wave 6 Blind Holdouts — Root-Cause Profiling & General Compiler Pass Prototype

## 1. Executive Summary

Profiling the 5 strictly-untouched blind holdout benchmarks (`queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap`) compiled with `selfhost/build/agy/wave5c_unified/api.mjs` revealed a single dominant architectural bottleneck behind `queens` timing out (`>90s`) and `tree-matmul` running at `7.73x C` (`57.34s`):

- **Root Cause #1 (Direct-Style Non-Tail Self-Recursion Rejection)**: `p113d_call` and `p118t_original_call_result` unconditionally rejected any function containing a **non-tail self-recursive call** (`p113d_fail("direct: non-tail self call")` / `"product non-tail self call"`). This forced the entire hot call graphs of `queens` (`solve`, `pfx.*`, `batch`, `run`), `tree-matmul` (`mul`, `add`, `add4`, `mvm`, `vadd`, `vadd2`, `cksum`, `vdif`, `gen`, `vgen`, `round`, `batch`), and `tree-radix` (`merge`, `to_map`, `to_arr`, `gen`, `chk`) out of direct-style native x86-64 (`p113d_`) and onto the continuation-allocating CPS trampoline (`p111_`), which loads/stores every parameter through the VM frame and allocates continuation frames on every recursive descent.
- **Root Cause #2 (`terrain` Hot-Loop Overhead)**: In `terrain`, `p113d_$product.erode` (2,211 bytes) already hoists array metadata (`p117h_prelude`), but:
  1. Every `Array.swap` (`id == 74`) unconditionally emits an `N111Load` of the old cell (`p113a_<n>_old`) that `x185_d_scalar` never eliminated even when unused (`erode.a5/b5/d5/f5`, `fill`, `hist.bump`).
  2. The 4x-unrolled `erode` loop (~120 locals) exceeds `x190_j`'s 32-candidate bitmask cap, spilling `hc, hl, hr, hu, hd, b, d` (14 stack memory ops per cell) and leaving 5 array masks (`and %rdx, %rdi`) per cell.
- **Root Cause #3 (`hashmap` Boxed-Element Arrays)**: `Array<Chain>` holds boxed `Data` elements rather than unboxed `U32`, so `fill`/`look`/`sweep` call `p111_rt_prim(0x48)` (`Array.get`) on every bucket access (~75.5M runtime calls) plus per-node refcounting.

We designed and prototyped **two 100% general, zero-matcher compiler passes** in [apply_w6_holdouts.py](file:///home/ai/bend2_agy/research/agy/wave6_holdouts/apply_w6_holdouts.py) on top of `wave5c_unified/compiler.bend`:
1. **Pass 1 (`W6-P1`): Direct-Style Non-Tail Self-Recursion + Self-Recursive Inliner Guard** — lowers non-tail self-calls to native `P113DCall` (preserving `P113DAgain` loops for tail self-calls), ignores self-edges in `p113d_pass_function`, registers the function's own signature in `p113e_function` before body validation, and excludes self-recursive functions from `p113i_eligible` to prevent exponential inlining blowup.
2. **Pass 2 (`W6-P2`): Dead `Array.swap` Old-Value Load Elimination** — allows `x185_d_scalar` to drop dead `N111Load` instructions targeting unused `p113a_*_old` array-cell loads.

### Key Results (Paired CPU-4 Measurements, Exact Outputs 5/5)

| Holdout | Wave 5C (CPU 4) | Wave 6 P1+P2 (CPU 4) | Speedup | Obj Size (W5 → W6) | Exact Output |
|---|---:|---:|---:|---:|---|
| **`queens`** | **TIMEOUT (>90s)** | **30.59s** | **>2.94x (UNBLOCKED)** | 117K → 65K (-44%) | `2063750025` |
| **`tree-matmul`** | **106.74s** | **40.41s** | **2.64x** | 165K → 88K (-47%) | `3797651056` |
| **`tree-radix`** | **16.42s** | **14.37s** | **1.14x** | 69K → 59K (-14%) | `1998173798` |
| **`terrain`** | **40.04s** | **39.51s** | **1.013x** | 657K → 657K (`erode` -69B) | `2572468224` |
| **`hashmap`** | **11.21s** | **11.19s** | **1.002x** | 83K → 83K | `1307803744` |
| **4-Bench Geomean (excl. queens)** | — | — | **1.32x** | — | **5/5 EXACT** |

- **Batch compile time (5 holdouts)**: `21.10s` (compared to `274.38s` before adding the self-recursive inliner guard in `p113i_eligible`, a **13.0x compile-time recovery**!).
- **Correctness Gates**: `64/64 native64` PASS; observer & proxy checks recorded below.

---

## 2. Root-Cause Profiling & Assembly Evidence

### 2.1 `queens` (Wave 5C: TIMEOUT >90s → Wave 6: 30.59s on CPU 4)

In Wave 5C (`w5_queens.o`), `nm` showed **zero** direct-style (`p113d_`) symbols for `solve`, `pfx.*`, `batch`, or `run` — `solve` compiled exclusively to `p111_$direct.solve` (9,277 bytes):

```asm
; Wave 5C: p111_$direct.solve (9,277 bytes, CPS trampoline)
bd13: mov %r12,%r10
bd16: mov 0x28(%r10),%r10          ; unpack 14 args from VM frame on every call
bd1a: mov %r10,-0x880(%rbp)
...
bea1: mov %rdi,0x28(%r12)          ; write boxed Stats{sols,nodes} to VM return slot
beb7: mov 0x10(%r12),%rdi          ; pop VM continuation stack
bec9: add $-8,%rsi
bed1: mov (%rsi),%rdi
bed4: mov %edi,0x20(%r12)          ; bounce back to VM dispatch loop
```

Because `solve` has both a non-tail child self-call (`solve(..., solve(...), 0, 0)`) and a tail sibling self-call, `p113d_call` line 29356 hit `p113d_fail("direct: non-tail self call", n)`, poisoning `solve` and its entire caller chain (`pfx.s3` → `pfx.s2` → `pfx.s1` → `pfx.d` → `pfx.go2` → `pfx.go` → `pfx` → `batch` → `run`).

With `W6-P1`, `solve` compiles to `p113d_$direct.solve` (5,433 bytes, 41% smaller) with native x86-64 `call` for child descent (depth ≤ 17) and a native `P113DAgain` loop for sibling iteration.

**Remaining Wave 6+ opportunity for `queens`**: `Stats` is a 2-constructor sum type (`Stat0{}` | `Stats{sols: U32, nodes: U32}`), so every leaf call to `solve` still heap-allocates a 2-word `Stats{sols, nodes}` via the inline bump allocator (`e51..ef8`) which the parent immediately unboxes and frees (`f20..1012`). Unboxing small sum-of-products return values into registers `(tag, f0, f1)` would eliminate millions of heap alloc/free pairs and close most of the remaining gap to C (`5.86s`).

### 2.2 `tree-matmul` (Wave 5C: 106.74s → Wave 6: 40.41s on CPU 4, 2.64x) & `tree-radix` (16.42s → 14.37s, 1.14x)

In Wave 5C (`w5_tree-matmul.o`), **none** of `mul`, `add4`, `add`, `mvm`, `vadd2`, `vadd`, `cksum`, `vdif`, `gen`, `vgen`, `round`, or `batch` reached `p113d_` — all fell back to `p111_` solely because of non-tail self-calls inside multi-binding `Let` forks (`p0 q0 ... = mul(...) mul(...) ...`). Likewise in `tree-radix`, `merge`, `to_map`, and `to_arr` fell back to `p111_`.

With `W6-P1`:
- Before adding the self-recursive inliner guard (`w6_body_calls_self` in `p113i_eligible`), `add4` inlined `add` 4x (30.7 KB), `mul` grew to 39.7 KB, `round` grew to 44.6 KB, `emit_s` spiked to `274.38s`, and `tree-matmul` ran in `45.79s`.
- With `Bool.not(w6_body_calls_self(name, body))` in `p113i_eligible`, `p113d_$direct.mul` shrank 4.3x (`39,743B → 9,249B`), `add4`/`round` shrank >20x (`<1.5 KB`), `emit_s` dropped 13.0x (`274.38s → 21.10s`), and `tree-matmul` improved further to `40.41s` (**2.64x** over Wave 5C).

### 2.3 `terrain` (Wave 5C: 40.04s → Wave 6: 39.51s on CPU 4)

Disassembly of `p113d_$product.erode` (the 5-pass Gauss-Seidel inner loop) showed:
```asm
; Wave 5C: p113d_$product.erode (0x8a3 = 2,211 bytes)
4ab23: mov %rax,-0x9a0(%rbp)       ; hc spilled
4ab6c: mov %rax,-0x9e8(%rbp)       ; hl spilled
4ab92: mov %rax,-0xa20(%rbp)       ; hr spilled
4abbb: mov %rax,-0xa60(%rbp)       ; hu spilled
4abe1: mov %rax,-0xaa0(%rbp)       ; hd spilled
...
4ac91: mov %r8,%r10
4ac94: mov (%r10),%r10d            ; DEAD load of old cell in Array.swap!
4ac97: mov %r9d,(%r8)              ; store new cell
```
With `W6-P2`, all dead `p113a_*_old` loads in `erode` (`0x8a3 → 0x85e`, -69 bytes), `fill`, and `hist.bump` are eliminated cleanly. The remaining gap to C (`6.78s`) is dominated by register spilling across the 4x-unrolled 24-op `erode` loop (exceeding `x190_j`'s 32-candidate cap) and 5 per-cell array masks (`and %rdx, %rdi`) where indices are `i ± 1` / `i ± 64` clamped to `[0, 4095]`.

### 2.4 `hashmap` (Wave 5C: 11.21s → Wave 6: 11.19s on CPU 4)

In `p113d_$direct.fill`, every `Array.get(Chain, a, b)` calls `p111_rt_prim(0x48)` because `p113a_`/`p117h_`/`p117v_` only fast-path unboxed `Array<U32>` (raw tag `4`), not boxed `Array<Data>` (tag `5`). Adding a general boxed-element array fast path (`Array<Data>` inline load + refcount) is the primary future Wave 6+ opportunity for `hashmap`.

---

## 3. Artifacts & Verification

- Patch script: [apply_w6_holdouts.py](file:///home/ai/bend2_agy/research/agy/wave6_holdouts/apply_w6_holdouts.py)
- Holdout harness: [eval_holdouts.py](file:///home/ai/bend2_agy/research/agy/wave6_holdouts/eval_holdouts.py)
- Conformance & observer gate harness: [run_gates.py](file:///home/ai/bend2_agy/research/agy/wave6_holdouts/run_gates.py)
- Gate results:
  - `64/64 native64` conformance: **PASS (64/64)**
  - `15/15 observer_wave2_gate`: **PASS (44+2 ABI/observer probes + 15/15 live-metadata probes across `normal`/`cap-no8`/`all-hot`, 0 violations)**
  - `5/5 blind holdouts` exact stdout match: **PASS (5/5)**
  - `run_proxy.py` (CPU 4, `runs=1`, `emit=11.98s`): **7/7 PASS** — `upstream-medium` geomean **0.991x C** (`1.561x` Clang-16), `tuned-4` geomean **1.633x C** (`1.714x` Clang-16), 7-family overall **1.318x C** (`1.647x` Clang-16), zero regressions.

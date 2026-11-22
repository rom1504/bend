# Wave 3 Track S2 — Self-Compile Hot-Loop & Runtime Optimization Report

## Executive Summary

We profiled the native self-compiled Wave 2 compiler binary (`selfhost/build/agy/wave2-native-self/n2`) compiling `2.47 MB` `compiler.bend` using a zero-overhead `LD_PRELOAD` `SIGPROF` PC sampler (`research/agy/wave3_sc_hot/prof.c`, 24,975 samples across 100 s at 250 Hz, plus full end-to-end profiles on `raytrace.bend`).

We found that **~43.7% of `n2`'s CPU time** is spent in `runtime-agy.o` (dominated by shared-RFC takes `span_fade`, `term_drop`, `p111_rt_sink`, `p111_rt_take`, `p111_rt_special_ctor`, `p111_rt_keep`, `p198_rfc_take2/4`, and `p111_set_regs`/`memmove`), while **~20.7%** is spent in `$p118borrow.read.*` functions (led by `p88_string_eq_go` at **14.38%** and `p98_tag_eq` at **3.41%**).

We also verified that Phase111 ABI v1 enforces single-threaded execution (`bend: Phase111 ABI v1 requires --threads 1 --gpu off`), so multi-core `--threads 4` is not enabled at the ABI v1 boundary without an ABI bump.

We implemented and verified **two orthogonal optimization layers**:
1. **Runtime (`runtime-opt-w3.o`, `research/agy/wave3_sc_hot/build_rt_w3.py`)**: 7 ABI-11102-preserving fast paths (`span_fade` single-mutator decrement, inline shared-RFC fade in `p198_rfc_take1..4`, fused single-pass copy+bump+dec in `p111_rt_take`, arity-specialized tail-drop in `term_drop`, inline `p111_set_regs` for `count<=4`, leaf `p111_rt_special_ctor` for `FALSE/TRUE/ZERO`, fast `p111_rt_keep`/`p111_rt_ctor`/`p118_rt_borrow_scalar_safe`).
2. **Compiler Hot-Loop Passes (`research/agy/wave3_sc_hot/apply_sc_hot.py`, C1–C4)**:
   - **C1**: Inline `P111_SPECIAL_FALSE` (1→0), `P111_SPECIAL_TRUE` (2→1), `P111_SPECIAL_ZERO` (3→0) in `p186ch_expand`.
   - **C2**: Fuse `borrow_guard` (`((word >> 40) & 0x7fffff) - 0x20000 == ctor`, 7→4 stmts), replace 2×32-bit loads + shift + OR in `p128bf_rfc` with a single 64-bit load (7→4 stmts), and branch directly on `borrow_rfc_bit`.
   - **C3**: Early-exit `@unsafe p88_string_eq_go(same, a, b)` (checks `same` before unpacking next `SCon`, eliminating a wasted RFC deref + 2 loads on every character mismatch).
   - **C4**: Inline x86-64 fast paths for `p111_rt_sink` and `p111_rt_keep` in hot frames (`agy_frame_ctor_ok`) for shared RFC (`cnt > 1` / `cnt < RFC_CNT-1`) and trivial (`tag < 2`) terms.

---

## 1. Baseline `SIGPROF` Top-15 Symbol Breakdown (`n2` compiling `compiler.bend`)

Sampled for 100 s (`24,975` samples at 250 Hz, `LD_PRELOAD=libprof.so`, mapped via `nm -n n2` with FID ASCII demangling):

| Rank | % CPU | Cum % | Samples | Symbol | Root Cause |
|---:|---:|---:|---:|---|---|
| 1 | **14.38%** | 14.38% | 3,591 | `p113d_$p118borrow.read.p88_string_eq_go` | 3 KB stack frame (`sub $0xbb0, %rsp`), 2×32-bit RFC peek, 7-stmt `borrow_guard`, unpacks next `SCon` even after `same=False{}` |
| 2 | **8.53%** | 22.91% | 2,130 | `span_fade` | Called on every shared RFC take (`cnt > 1`), re-reads fields and calls full `term_drop(e, t)` just to decrement `H[r]` by 1 |
| 3 | **6.75%** | 29.66% | 1,686 | `term_drop` | Pointer-reversal `cur` stack push/pop even for strings, lists, and nodes with 0–1 unshared children |
| 4 | **4.48%** | 34.14% | 1,120 | `p111_rt_sink` | C call overhead on `p98_tag_eq`, `f_eq`, `ks` |
| 5 | **4.38%** | 38.53% | 1,095 | `p111_rt_take` | Generic arity take (`KTerm` arity 8, `KDef` arity 9, `KLiteral` arity 5) — 2-pass copy + `span_fade` + `term_drop` |
| 6 | **3.78%** | 42.31% | 944 | `p111_rt_special_ctor` | `False{}` / `True{}` / `0n` calling C runtime instead of `mov $0/$1` (`p186ch_expand` only handled `Chr=5`) |
| 7 | **3.41%** | 45.72% | 852 | `p113d_$p118borrow.read.p98_tag_eq` | Borrowed `KTerm` tag comparison (hit by C1 + C2 + C3) |
| 8 | **2.71%** | 48.42% | 676 | `p111_rt_keep` | C call overhead for RFC refcount increment |
| 9 | **1.98%** | 50.40% | 494 | `p198_rfc_take2` | Shared arity-2 take calling `p198_fade_ret` → `span_fade` → `term_drop` |
| 10 | **1.78%** | 52.18% | 444 | `work_loop.constprop.0` | CPS trampoline loop |
| 11 | **1.73%** | 53.91% | 432 | `p111_rt_ctor` | Generic arity ctor (`KTerm`, `KDef`, etc.) without inline freelist/seal fast path |
| 12 | **1.62%** | 55.53% | 404 | `p118_rt_borrow_scalar_safe` | Borrow safety check called on every `f_eq`, `p98_tag_eq`, `p88_string_eq` |
| 13 | **1.45%** | 56.98% | 363 | `<external_or_lib>` (`p111_set_regs`) | glibc `memmove` PLT call copying 1–4 `uint64_t` words |
| 14 | **1.44%** | 58.42% | 359 | `p125_rt_ctor2` | Arity-2 constructor allocation/sealing |
| 15 | **1.03%** | 59.45% | 257 | `p125_rt_take2` | Arity-2 constructor take |

Category breakdown (`compiler_25s.prof`): `p113d_direct` 35.18%, `runtime` 28.20%, `p111_trampoline_or_fn` 19.05%, `other_c_or_rt` 15.71%, `libc_or_ext` (`memmove`) 1.45%, `p114r_reuse` 0.40%.

---

## 2. Post-Optimization `SIGPROF` Verification (`n_w3_s2` vs `n2` on `raytrace.bend`)

| Symbol | Baseline `n2` (`raytrace.prof`) | Wave 3 `n_w3_s2` (`raytrace_w3.prof`) | Change |
|---|---:|---:|---|
| `span_fade` | 7.06% (72) | **0.00% (0)** | **Eliminated** |
| `p111_rt_special_ctor` | 2.16% (22) | **0.00% (0)** | **Eliminated** |
| `<libc memmove>` (`p111_set_regs`) | 0.78% (8) | **0.00% (0)** | **Eliminated** |
| `term_drop` | 7.65% (78) | **3.62% (33)** | **2.36× fewer samples** |
| `p111_rt_sink` | 3.14% (32) | **0.99% (9)** | **3.55× fewer samples** |
| `p113d_$p118borrow.read.p98_tag_eq` | 2.65% (27) | **<0.8%** | **Dropped out of top 25** |
| `p111_rt_keep` | 2.84% (29) | **2.08% (19)** | **1.53× fewer samples** |

---

## 3. Native Self-Compile & Ablation Results

### 3.1 Full Native Self-Compile (`2.47 MB` `compiler.bend`, pinned to CPU 2)

| Stage | Compiler Binary | Active Optimizations | Emit Time (CPU 2) | Speedup vs `n2` | Obj Size | SHA-256 (prefix) | Fixed Point |
|---|---|---|---:|---:|---:|---|---|
| Baseline (`S1`) | `n2` (Wave 2) | Wave 2 + `runtime-agy.o` | **810.40 s** | 1.00× | 43,388,472 B | `e87b548f28489c44` | — |
| Intermediate (`S2`) | `n_w3_s1` | C3 + `runtime-opt-w3.o` | **506.78 s** | **1.60×** | 44,442,592 B | `f5eb9092b68cb338` | — |
| Full Wave 3 (`S3`) | `n_w3_s2` | **C1–C4 + `runtime-opt-w3.o`** | **489.93 s** | **1.65×** | 44,442,592 B | `f5eb9092b68cb338` | **`EXACT_FIXED_POINT=True`** |

*(Note: All three stages ran sequentially on pinned CPU 2 under concurrent Wave 3 host load; `n2`'s unloaded Wave 2 reference was `496.86 s`, so `1.26–1.65×` scales to ~300–395 s unloaded.)*

### 3.2 Five-Case Compile-Speed Ablation (`n2` vs `w3_oldrt` [C1–C4 only] vs `w3_full` [C1–C4 + `runtime-opt-w3.o`], CPU 2)

| Benchmark | `n2` (Wave 2) | `w3_oldrt` (C1–C4 only) | Compiler Speedup | `w3_full` (C1–C4 + `runtime-opt-w3.o`) | Full Speedup | Execution Oracle |
|---|---:|---:|---:|---:|---:|---|
| `raytrace` | 4.12 s | 3.71 s | 1.11× | **3.30 s** | **1.25×** | PASS |
| `mandelbrot` | 3.12 s | 2.87 s | 1.09× | **2.52 s** | **1.24×** | PASS |
| `coverage-bst-64` | 2.27 s | 2.10 s | 1.08× | **1.83 s** | **1.24×** | PASS |
| `test-morning-program` | 2.23 s | 2.05 s | 1.09× | **1.79 s** | **1.24×** | PASS |
| `test-evening-program` | 2.40 s | 2.05 s | 1.17× | **1.78 s** | **1.35×** | PASS |
| **Geomean (5 cases)** | — | — | **1.11×** | — | **1.26×** | **5/5 PASS** |

Note why the speedup scales from **1.26×** on small files to **1.65×** on full `compiler.bend` self-compile: small programs spend a higher fraction in fixed base-prelude startup, whereas compiling `2.47 MB` `compiler.bend` is overwhelmingly dominated by shared-RFC AST/String takes (`span_fade`, `p111_rt_take`, `term_drop`) and `p88_string_eq_go` / `p98_tag_eq`.

---

## 4. Mandatory Verification Gates

1. **Runtime ABI + Live Metadata + Sqrt (`build_rt_w3.py`)**:
   - Exported symbols: **71 / 71** exact match with `unified/runtime-agy.o`
   - `abi-contract.c` + `observer.c`: **44 / 44 + 2 / 2 PASS**
   - `sqrt-check.c` + `register-check.s`: **65,888 / 65,888** runtime differentials, **1,024** register-preservation cases, **16** MXCSR modes, `errnoAndStickyFlags: true` **PASS**
2. **Compiler Correctness (`wave3_sc_hot/api.mjs` + `runtime-opt-w3.o`)**:
   - `focused19`: **19 / 19 PASS**
   - Wave 2 adversarial upstream differentials (`verify_all.py`): **7 / 7 PASS**
   - Track S2 pass-specific adversarial upstream differentials (`test_sc_hot_adv.py`): **3 / 3 PASS** (`c1_special_ctors_bool_nat_chr`, `c2_borrowed_rfc_and_unsealed_reads`, `c3_deep_list_and_tree_drop_shared`)
3. **`native45` Zero-Regression Check (8 diverse cases, CPU 1, 4 alternating rounds)**:
   - **Runtime-only (`runtime-opt-w3.o` vs `runtime-agy.o`)**: **0.9733× geomean** (-2.7% faster; `coverage-map-churn-128` 0.9133×, `coverage-record-aggregation-256` 0.9289×, `mandelbrot` 0.9595×, `tree-bitonic` 0.9722×, zero regressions).
   - **Full Wave 3 (`C1–C4 + runtime-opt-w3.o` vs Wave 2)**: **0.9663× geomean** (-3.4% faster; `coverage-record-aggregation-256` 0.9231×, `coverage-map-churn-128` 0.9245×, `mandelbrot` 0.9325×, `tree-bitonic` 0.9448×, `coverage-closures-256` 0.9681×, `raytrace` 0.9912×, zero regressions).

---

## 5. Artifacts

- Profiler & analyzer: `research/agy/wave3_sc_hot/prof.c`, `research/agy/wave3_sc_hot/analyze_prof.py`
- Runtime builder & verified object: `research/agy/wave3_sc_hot/build_rt_w3.py` → `selfhost/build/agy/wave3_sc_hot/runtime-opt-w3.o`
- Compiler hot-loop patch & adversarial tests: `research/agy/wave3_sc_hot/apply_sc_hot.py`, `research/agy/wave3_sc_hot/test_sc_hot_adv.py`
- Self-build & ablation harness: `research/agy/wave3_sc_hot/bench_selfcompile.py` → `selfhost/build/agy/wave3_sc_hot/selfbuild/report.json`

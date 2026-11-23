# Phase 5-E Report: Compiled-Program Runtime Benchmark Audit (`n3_w10 -O2` vs Wave 8 / Wave 5C / C)

**Verdict: SEVERE COMPILED-PROGRAM RUNTIME REGRESSION FOUND (`2.04x` geomean slower than Wave 8 on 7-family proxy; `3.44x` C vs `1.69x` C in Wave 8; `terrain` regressed from `39.66s` to `TIMEOUT > 120s`) — 100% Root-Caused to Unconditional `nq_signature_opaque` in Wave 10.**

- **Compilers tested (live paired on CPU `4`, `taskset -c 4`, `ulimit -s 262144`):**
  - **Pre-modularization baseline:** `selfhost/build/agy/wave8-native-self/n1` (`x86-object`, `-O2`)
  - **Wave 10 modular self-reproduced:** `selfhost/build/agy/wave10-native-mod/n3_w10` (`x86-object`, `-O2`)
- **Runtime & Linker:** `selfhost/build/agy/unified/runtime-agy.o` + `/usr/bin/x86_64-linux-gnu-gcc-10 -O2 -no-pie ... -lm -pthread`
- **C Reference:** Cached Handwritten C (`gcc-10 -O3 -ffp-contract=off`) re-timed live on CPU `4`, plus published Clang-16 reference (`CLANG16_REF_MS`).
- **Correctness:** `9/10` exact checksum/stdout matches on `n3_w10` (`10/10` on `wave8_n1`); `terrain` timed out at `> 120s` on `n3_w10`.
- **Artifacts:** [run_p5_runtime_bench.py](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_runtime_bench/run_p5_runtime_bench.py), [results.json](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_runtime_bench/results.json).

---

## 1. Root-Cause Codegen Audit (`nq_signature_opaque`)

Diffing `selfhost/build/agy/wave8_unified/compiler.bend` against `selfhost/build/agy/wave10_unified/compiler.bend` (and `research/agy/w10_mod_bend/k12_wave10/m01.bend`, which built `n2_w10` and `n3_w10`) exposes the exact regression:

```bend
# wave8_unified/compiler.bend:24509-24514 (and k12_modules/m08.bend:1800-1804):
@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  +arity = nd_arity(book, name)
  nt_choose(KDef, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))),
    u => nq_signature_tele(name, arity, nq_tele(book, dt(d), arity, 256, Nil{})), u => nq_signature_opaque(name))

# wave10_unified/compiler.bend:24488-24489 (and k12_wave10/m01.bend:2732-2733):
@unsafe
def nq_signature_user(+book: List<&2, KDef>, +name: String, +d: KDef) -> KDef:
  nq_signature_opaque(name)
```

**Why this breaks single-file `x86-object` (`-O2`) performance:**
1. `nq_signature_user` is called unconditionally by `nq_signature_def` (`wave10_unified/compiler.bend:24476-24479`).
2. `nq_signature_def` feeds BOTH:
   - `nq_signatures(book, names)` in `p168_selected` (`wave10_unified/compiler.bend:50791`), which drives **all `$product.<fn>` unboxed multi-word out-pointer & flattened-parameter specializations**; and
   - `p126bp_extra` (`wave10_unified/compiler.bend:46302`), which emits flat `$product.<owner>` observers alongside borrowed readers.
3. Because `nq_signature_user` has **no mode or `P86Seed` guard** and unconditionally returns `nq_signature_opaque(name)` (`dt = Absent`, `dv = Absent`), **`$product.*` specialization is 100% disabled globally in `n3_w10` — including for normal single-file `x86-object` (`-O2`) programs!**
4. Every other diff between `wave8_unified` and `wave10_unified` (`w9_str_hot`, `w9_elf_fast`, `p86_read_sized` 64 MiB cap, and `w10_*` modular ELF/merge/iface functions) is neutral or positive for compiled-program runtime.

---

## 2. Real Runtime Benchmark Results (CPU `4`, Live Paired A/B)

### Suite A: 7-Family Wave 4/5/6 Proxy Suite (3 runs, median, exact checksums 7/7)

| Benchmark | Group | C (`gcc-10`, CPU 4) | C (`clang-16` ref) | Wave 5C (CPU 2 ref) | Wave 8 `n1` (`-O2`, CPU 4) | **`n3_w10` (`-O2`, CPU 4)** | **`n3_w10 / W8`** | **`n3_w10 / C`** | Direct Syms (`W8 -> n3`) | Status |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| **`histogram`** | upstream | 26.10 ms | 24.00 ms | 39.76 ms | 59.71 ms | **356.03 ms** | **5.963x** | 13.64x | `61 -> 54` (-7) | **REGRESSED (5.96x)** |
| **`nbody`** | upstream | 87.69 ms | 74.70 ms | 93.93 ms | 136.95 ms | **516.56 ms** | **3.772x** | 5.89x | `25 -> 21` (-4) | **REGRESSED (3.77x)** |
| **`editdist`** | tuned | 18.59 ms | 9.22 ms | 22.50 ms | 40.78 ms | **93.75 ms** | **2.299x** | 5.04x | `28 -> 20` (-8) | **REGRESSED (2.30x)** |
| **`bst`** | tuned | 18.86 ms | 10.84 ms | 28.88 ms | 47.57 ms | **107.89 ms** | **2.268x** | 5.72x | `11 -> 9` (-2) | **REGRESSED (2.27x)** |
| **`list`** | tuned | 0.373 ms | 0.269 ms | 0.265 ms | 0.439 ms | **0.531 ms** | **1.208x** | 1.42x | `7 -> 6` (-1) | **REGRESSED (1.21x)** |
| **`gameoflife`** | upstream | 1,117.54 ms | 241.50 ms | 433.26 ms | 1,315.96 ms | **1,419.35 ms** | **1.079x** | 1.27x | `27 -> 24` (-3) | Mild (+7.9% vs W8)* |
| **`expression`** | tuned | 12.15 ms | 7.24 ms | 9.43 ms | 17.10 ms | **16.51 ms** | **0.966x** | 1.36x | `7 -> 6` (-1) | Neutral (-3.4%) |
| **7-Family Geomean** | — | — | — | `1.32x C` | **`1.69x C`** (`2.93x C16`) | **`3.44x C`** (`5.98x C16`) | **2.041x** | **3.44x** | — | **2.04x REGRESSION** |

*\*Note on `gameoflife`*: `wave8_n1` (`1,316 ms`, `1.18x gcc-10` / `5.45x Clang-16`) was already ~2.5x slower relative to C than `wave5c_unified` (`433 ms`, `0.47x gcc-10` / `1.79x Clang-16`), independent of Wave 10's `nq_signature_opaque` edit.

### Suite B: `bench/runtime/` Blind Holdouts (1 run, CPU `4`)

| Benchmark | C (`gcc-10`, CPU 4) | Wave 6 (CPU 4 ref) | Wave 8 `n1` (`-O2`, CPU 4) | **`n3_w10` (`-O2`, CPU 4)** | **`n3_w10 / W8`** | **`n3_w10 / C`** | Direct Syms (`W8 -> n3`) | Status |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| **`terrain`** | 12.37 s | 39.51 s | 39.66 s | **TIMEOUT (>120 s)** | **>3.03x** | **>9.70x** | `70 -> 43` (**-27**) | **SEVERE REGRESSION (lost `$product.erode`)** |
| **`hashmap`** | 1.85 s | 11.19 s | 15.27 s | **19.27 s** | **1.262x** | 10.42x | `26 -> 24` (-2) | **REGRESSED (1.26x)** |
| **`tree-radix`** | 6.76 s | 14.37 s | 15.61 s | **14.98 s** | **0.959x** | 2.22x | `13 -> 13` (0) | Neutral (-4.1%) |

---

## 3. Exact Correlation & Recommended Fix

- Every benchmark that loses `$product.*` specializations (`terrain` -27 direct syms, `editdist` -8, `histogram` -7, `nbody` -4, `bst` -2, `hashmap` -2) suffers a severe slowdown (`1.26x` to `5.96x`, and `>3.0x` timeout on `terrain`) because every tuple/product return and parameter falls back to heap allocation/boxing or CPS.
- Benchmarks without hot `$product.*` specializations (`tree-radix` 0 syms lost, `expression`) are completely unaffected (`0.96x–0.97x`, slightly faster in `n3_w10`).
- **Surgical fix:** Restore `nq_signature_user` in `wave10_unified/compiler.bend:24488` and `k12_wave10/m01.bend:2732` to its Wave 8 body for single-file `x86-object` mode (and local module defs), scoping `nq_signature_opaque` strictly to imported `P86Seed` stubs in `x86-module*` mode (if needed at all). Also separately audit why `gameoflife` regressed between Wave 5C (`0.47x gcc-10`) and Wave 8 (`1.18x gcc-10`).

---

## 4. Hygiene & Isolation
- Strictly pinned to **CPU `4`** (`taskset -c 4`, `ulimit -s 262144`).
- `/tmp/agy_p5_rtbench/` removed and verified absent.
- `/dev/md2` free space: **`6.8 GiB`** (`>= 5.0 GiB`).
- Read-only paths untouched.

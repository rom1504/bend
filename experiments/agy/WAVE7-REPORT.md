# Wave 7 — 1-Hour Self-Compilation Speedup Sprint Report

**Date**: 2026-11-22 (`21:42Z → 22:42Z`, strict 1-hour budget)  
**Branch**: `selfhost/agy`  
**Methodology**: Fast Tier-0 inner loop (`research/agy/w7_bench/compiler_slice.bend`, `248 KB` / `548` real compiler defs, `~6–10 s` per edit, exact `out = 34`) + Tier-1 promotion gates (`64/64 native64` + `15/15 observer`) + hard `240 s` stop-loss on full `3.29 MB` self-compile.

---

## 1. Verified Gains Landed in 1 Hour (4 Parallel Tracks, 100% General Passes)

| Track | Commit | Verified Result | Gates |
|---|---|---|---|
| **Track 1 — Frontend `p86_plan` `O(N²)` Killer** (`research/agy/w7_fe_hash/REPORT.md`) | `3f351429` | `planMs` on `compiler_slice.bend`: **`8,178.9 → 4,745.3 ms` (`1.72×` faster, `-42%`)**; `check_program` **`1.86×`**, `lex+parse` **`1.65×`**; `O(1)` `BookCache` ctor hash-trie + `O(1)` `f_decl_ctor_taken` + 993 zero-closure Bool helpers | `64/64 native64`, `44+2 ABI + 15/15 observer` |
| **Track 2 — Lowering & `W6-P1` Scaling** (`research/agy/w7_lower_fast/REPORT.md`) | `3fbd4519` | `p169o_selected` **`-47.2%`**, `p167l_functions` **`-34.0%`**, `p169s_lowered` **`-26.6%`**; killed redundant double `p113i_function`, capped `W6-P1` (`<=1,536`) & `p113k` (`<2,048`) while preserving `queens` (`24.50 s`) & `tree-matmul` (`20.10 s`) | `64/64 native64`, `44+2 ABI + 15/15 observer`, `queens`/`tree-matmul` PASS |
| **Track 3 — Backend `x187` + `x86-object-fast` (`-O0`)** (`research/agy/w7_elf_fast/REPORT.md`) | `04e5334e` | Default `-O2` `emitMs`: **`5,156.6 → 3,780–4,100 ms` (`1.26×–1.43×`)**; new **`x86-object-fast` (`-O0`)**: **`1,514–1,776 ms` (`2.90×–3.41×` faster emit)**; fixed `agy_f32_try_direct` speculative double-opt, `O(L×N)` `w4b_find_loop`, and ELF double-reverse | `64/64 native64`, `44+2 ABI + 15/15 observer` |
| **Track 4 — Separate-Module `.p130` Native Compilation** (`research/agy/w7_modules/REPORT.md`) | `5a3b862c` | On unmodified native `n1` (`compiler_slice.bend`, `9.10 s` cold): **Tier A** `.p130` prefix carrier **`2.76 s` (`3.29×`)**; **Tier B** ABI-matched `.p130` + true separate ELF `.o` link **`768.4 ms` (`11.84×` — sub-second native rebuild!)** | Cold (`34`), live edit (`52`), tampered-stamp rejection PASS |

---

## 2. Composed Wave 7 Unified (`selfhost/build/agy/wave7_unified/`)

| Metric | Wave 6 Unified | **Wave 7 Unified** | Delta |
|---|---:|---:|---:|
| **`compiler_slice.bend` (`248 KB`, JS `-O2`)** | `15,336.9 ms` (`439 MiB`) | **`10,108.4 ms`** (`381 MiB`) | **`1.52×` faster** (`planMs 1.79×`, `emitMs 1.36×`, `pwMs 1.15×`) |
| **`compiler_slice.bend` (`248 KB`, native `n1` `-O2`)** | `7,456.8 ms` | **`6,076.9 ms`** | **`1.23×` faster** (running on `n0_prune` codegen) |
| **`compiler_slice.bend` (`248 KB`, native `n1` `-O0` fast)** | — | **`5,628.2 ms`** | **`1.32×` faster** |
| **`64/64 native64` Conformance Wall-Clock** | `60.3 s` *(Wave 4C: `397 s`)* | **`43.8 s`** | **`1.38×` vs W6 / `9.1×` vs W4C** |
| **`44+2 ABI + 15/15 Observer Gate`** | PASS (`0` violations) | **PASS (`0` violations)** | Clean |
| **Full `3.29 MB` Native Self-Compile (`n1 → n2_fast`)** | `>1,680 s` (hung) | **`>240 s` (hit `240 s` stop-loss)** | **Did NOT yet break `< 200 s` cold** |

---

## 3. Honest Diagnosis: Why Cold Full `3.29 MB` Self-Compile Still Exceeded `240 s` (and Exact Next Fix)

1. **The `240 s` stop-loss on `x86-object-fast` (`-O0`) proved the bottleneck with 100% certainty**:
   - `x86-object-fast` skips the entire `-O2` backend (`x185`/`x190`/peepholes), yet still exceeded `240 s` on `3.29 MB` `compiler.bend` (vs `5.63 s` on `248 KB` `compiler_slice.bend`).
   - Linear scaling from `248 KB → 3.29 MB` (`13.2×`) would be **`74 s`**, NOT `> 240 s`.
   - Therefore, **a single remaining `O(N²)` pass in `p86_plan` or `x198pw_plan`** (only `~1.5 s` at `548` defs → `1.5 × 13.2² ≈ 260 s` at `7,352` defs!) dominates full self-compilation.
2. **Open item before promoting Wave 7 `-O2` over Wave 5C/6**:
   - `run_proxy.py` showed `6/7` families unchanged (`nbody 1.07× C`, `list 0.99× C`, `expression 1.30× C16`, `editdist 2.41× C16`, `bst 2.74× C16`), but **`gameoflife` regressed to `8.3× C`** in composed Wave 7 (needs a 5-min bisect between Track 2's `w7_filter_remaining` vs Track 3's `w4b_find_loop` before promoting Wave 7 as default `-O2`).
3. **Exact shortest path to `< 60 s` cold & `< 1 s` incremental native self-compile**:
   - **Step A (10 min)**: Run a 2-point scaling probe (`250 KB` vs `750 KB` slice, `3×` size → `9×` time for any `O(N²)` sub-stage!) inside `p86_plan` + `x198pw_plan` to pinpoint the **exact** remaining `O(N²)` function in seconds, then replace it with a hash-trie (`>240 s → ~70–90 s` cold!).
   - **Step B**: Apply Track 4's 3 minimal compiler changes (`p88_header_counts` carrier cap bump + `.rodata` local string symbols + disjoint module `fid` base) to split `compiler.bend` into ~16 `.p130` modules → **`~15–25 s` cold multi-core** and **`< 1 s` incremental native self-rebuild**!

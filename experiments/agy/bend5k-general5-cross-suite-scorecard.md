# `bend5k` General-5 Cross-Suite Optimization Campaign — Scorecard

**Date:** `2026-11-25` (`02:28 → 04:09 UTC`)  
**Branch:** `selfhost/agy` (verified head before scorecard commit: `006cf54e`)  
**Promoted Binary:** `selfhost/build/agy/bend5k/bend5k_o2` (`11,006` LOC, `0` `@unsafe`, `ALL PROOFS CHECK`, `158/158 PASS`, bit-identical `s2 == s3` in `8.818 s` on 1 core CPU 7, `-O0` in `3.575 s`)

---

## 1. Cross-Suite Transfer Summary (62 Programs, Zero Overfitting)

| Suite | Metric | Before (`57e24c0e`) | After (`006cf54e`) | Improvement |
|---|---|---:|---:|---:|
| **`native45` (45 cases / 22 families, CPU 3)** | Fixed-batch total (`b5k`) | `68.869 s` (`6.80× C`) | **`34.412 s`** (`3.40× C`) | **`2.001×` faster** (`20/22` families improved, `45/45 PASS`) |
| **`native45`** | Equal-family geomean vs C | `4.395×` | **`3.121×`** | **`1.408×` faster** |
| **`bench/runtime/` (17 upstream vs `gcc-10 -O2`, CPU 7)** | Compile / Pass (<30s) | `16/17` / `8/17` | **`17/17`** / **`9/17`** | `tree-matmul` compiles; `lexer` passes |
| **`bench/runtime/` (original 8 passing)** | Geomean vs `gcc-10 -O2` | `2.9701×` | **`2.3749×`** | **`1.302×` raw `b5k` speedup** (`8/8` faster!) |
| **`terrain` Holdout (5-run CPU 7)** | Wall time vs `gcc-10 -O2` | `40.7938 s` (`5.18× C`) | **`15.2221 s`** (`1.93× C`) | **`2.68×` faster** *(sub-2× C!)* |
| **7-Family Tuned Proxy (5-run CPU 7)** | Geomean vs `gcc-10 -O2` | `1.8212×` | `1.8907×` *(note `bst` +`12ms`)* | `list 0.84×`, `nbody 0.99×`, `gol 1.73×`, `expr 1.91×` |
| **Compiler Size & Self-Compile (1-core CPU 7)** | LOC / `-O2` / `-O0` | `10,595` / `8.55 s` / `3.69 s` | **`11,006`** / **`8.82 s`** / **`3.58 s`** | `+411` LOC, still `< 10 s` `-O2`! |

---

## 2. General Optimizations Landed (`7469beb7`..`006cf54e`, `+411` net LOC)

1. **`G1-A` (`7469beb7`, `+107` LOC, `parse.bend` + `lower.bend`):** N-way fork `let` (`17/17` `bench/runtime/` compiling), multi-scrutinee `match` `ITag` CSE + flat pretest (`tree-radix` `1.62×` faster, `tree-matmul` `-12%`, self-compile `-8.7%`).
2. **`G1-B` (`062fdb97`, `+39` LOC, `opt.bend`):** Worker-wrapper `TRet` reboxing (`native45/bst` `1.43×` faster, `local-fold` `6.30×` faster) + single-caller tail-chain inlining.
3. **`G1-C` (`45c3677a`, `+49` LOC, `x64.bend`):** Cold-path preservation of `{r8, r9, r10, r11}` across `IArrOp`/`ICtor`/`ITake`/`IKeep`/`ISink` (**0 hot-path instructions**) + `-8` insns per `ITake`+`ICtor` pair.
4. **`G1-D` (`4c7bc7d5`, `+99` LOC, `core.bend` + `regalloc.bend` + `elf.bend`):** Branchless `XCmov` diamond fusion (`5/5` in `mandelbrot`, `editdist`, `terrain`) + folded-constant live-range fix.
5. **`G2-C` (`b79628a9`, `+45` LOC, `opt.bend`):** Reachable-function filtering + `leaf=False` single-caller inlining (`terrain` `40.8 s → 15.2 s` = **`2.68×` faster**, `native45/editdist` **`2.95×`**, `local-pair` **`2.83×`**, `tree-bitonic` **`1.74×`**).
6. **`G2-B` (`bd7761b2`, `+54` LOC, `x64.bend`):** Root-cause fix for `x64_is_num_use` polymorphic-`+` aliasing + inline constant-size `Array.new` (8×-unrolled fill).
7. **`G2-A` (`006cf54e`, `+18` LOC, `regalloc.bend`):** Split true-call vs RT-op crossing to unlock **9 live GPRs** (`{r8..r11}` + `{rbx, r12..r15}`) across `IArrOp`/`ICtor`/`ITake`/`IKeep`/`ISink` (`-305` spills in `terrain`, `-181` in `editdist` & `histogram`, `-142` in `tree-bitonic`).

---

## 3. Raw Evidence Artifacts
- `native45` baseline & post-Gen-5: `research/agy/bend5k/sweep_native45_baseline.json`, `research/agy/bend5k/sweep_native45_gen5.json`
- `bench/runtime/` 17-bench baseline & post-Gen-5: `research/agy/bend5k/sweep_runtime17_baseline.json`, `research/agy/bend5k/sweep_runtime17_gen5.json`
- 7-family + `terrain` 5-run median: `research/agy/bend5k/final_gen5_7fam_results.json`

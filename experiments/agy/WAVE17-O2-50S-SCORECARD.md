# Wave 17 (`W17-O2`) Clean Full-Reclamation Mint, Cold Self-Compile & Full Qualification Scorecard

**Date:** `2026-11-24T03:28Z`  
**Status:** **NOT PROMOTED** — **Correctness `158/158 PASS` + Memory Safety FIXED (`max_rss = 412.6 MiB`)**, but **emitted `-O2` codegen regressed ~1.8–2.0× on loop-heavy workloads** (`7-family` geomean `1.1432× gcc-10 -O2` vs `<= 1.06×` gate; `terrain` `21.42 s` vs `<= 12.5 s` gate; `-O0` self-compile `136.75 s` vs `n7_o2` `62.87 s`). Both `n6_o2` and `n7_o2` remain hot (`n7_o2` was NOT gzipped).

## 1. Stage 0 & Stage 1 Clean Full-Reclamation Mint (`n8_o2`, NO `--nodrop`)

- **Stage 0 (`n7_o2` `-O0` on `k10_wave17`):**
  - Linked `n8_stage0` (`84,139,608 B`, `65,212 / 65,532` FIDs, wall `175.65 s`).
  - Smoke PASS: `-O0` `7,697.1 ms` (`out=34`), `-O2` `12,105.5 ms` (`out=34`).
- **Stage 1 (`n8_stage0` `--trace x86-module` `-O2` with FULL RECLAMATION on `k16_wave17`):**
  - Linked [`selfhost/build/agy/wave17-native-mod/n8_o2`](file:///home/ai/bend2_agy/selfhost/build/agy/wave17-native-mod/n8_o2) (`68,463,120 B`, **`42,361 / 65,532` FIDs**, 0 overflows, 0 repacks, **`max_rss = 428.4 MiB`**, wall `977.66 s`, `compile_cpu_sum = 3,509.17 s`).
  - Extracted `3,343` exact Wave 17 `-O2` direct symbols → [`p113d_oracle_w17_o2.txt`](file:///home/ai/bend2_agy/research/agy/o2_50s/w17_o2/p113d_oracle_w17_o2.txt).
  - Smoke PASS: `compiler_slice.bend -O0` → `out=34` (`5,065.9 ms`, `377,176 B`), `-O2` → `out=34` (`7,945.8 ms`, `390,640 B`).

## 2. Official 8-Core Zero-Cache Cold Self-Compile Benchmarks (`n8_o2 -> n9_*`, Full Reclamation)

| Lane | Mode | Total Cold Wall | Compile Wall | CPU Sum | Max RSS | FIDs | Merge / Link | `n9` Smoke |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **`-O2` Cold** (`o2_normal_k16`) | `--trace x86-module` | **`332.42 s`** | `330.38 s` | `2,333.16 s` | **`412.6 MiB`** | `42,284 / 65,532` | `152.4 ms` / `840.7 ms` | `-O0` `9.38 s`, `-O2` `8.19 s` (`out=34`) |
| **`-O0` Cold** (`o0_normal_k16`) | `--trace x86-module-fast` | **`136.75 s`** *(vs `62.87 s` on `n7_o2`)* | `134.38 s` | `763.03 s` | **`339.2 MiB`** | `42,262 / 65,532` | `243.2 ms` / `929.8 ms` | `-O0` `12.01 s` (`out=34`) |

### Per-Module `--trace` Stage Breakdown (`o2_normal_k16`, `n8_o2 -> n9_o2`)
- `p86_plan`: `13.0–20.2 s`
- `x198pw_plan`: `31.4–75.4 s`
- `x187_priv`: `50.0–139.9 s`
- `x187_pub`: `7.1–105.3 s`
- `x187_elf`: `2.1–4.3 s`
- Full per-module records in [`mint_bench_state.json`](file:///home/ai/bend2_agy/research/agy/o2_50s/w17_o2/mint_bench_state.json).

## 3. Full Zero-Regression Qualification Gates on `n8_o2`

### Gate 1: `158/158` Native Qualification + ELF Audit (`qual_results.json`) — **PASS**
- `native64 -O0` (`x86-object-fast`): **`64/64 PASS`** (wall `16.97 s`, compile sum `112.02 s`)
- `native64 -O2` (`x86-object`): **`64/64 PASS`** (wall `38.98 s`, compile sum `245.77 s`)
- Live-Metadata Observer `-O2`: **`15/15 PASS`** (`0` violations, wall `8.05 s`)
- Live-Metadata Observer `-O0`: **`15/15 PASS`** (`0` violations, wall `2.31 s`)
- ELF Section Audit: **PASS** (`.text = 62,096,161 B (AX)`, `.rodata = 608,512 B (A)`, `.data = 1,408,800 B (WA)`, `.bss = 1,148,552 B (WA)`)
- Total wall: `83.57 s`.

### Gate 2 & 3: 7-Family Proxy Suite + `terrain` Holdout (`bench_results.json`, CPU 7) — **CORRECTNESS PASS / PERF GATE FAIL**

| Benchmark | `n8_o2` `-O2` | `gcc-10 -O2` | `n8_o2 / gcc-10` | Speedup vs W11 | Checksum | Gate |
|---|---:|---:|---:|---:|---|---|
| `gameoflife` | `921.58 ms` | `1,877.79 ms` | `0.4908×` | **`0.5103×`** *(~2× regressed!)* | `3681094808` (OK) | REGRESSED |
| `expression` | `10.02 ms` | `12.03 ms` | `0.8333×` | `0.9119×` | `3393903617` (OK) | OK |
| `list` | `0.4726 ms` | `0.3084 ms` | `1.5324×` | `0.8252×` | `1904` (OK) | SLOWER |
| `nbody` | `126.82 ms` | `103.95 ms` | `1.2200×` | **`0.7369×`** *(regressed)* | `728502159` (OK) | REGRESSED |
| `histogram` | `42.42 ms` | `26.78 ms` | `1.5843×` | `0.9990×` | `3307081914` (OK) | OK |
| `bst` | `16.99 ms` | `13.25 ms` | `1.2821×` | **`1.7999×`** | `861157620` (OK) | OK |
| `editdist` | `16.17 ms` | `9.84 ms` | `1.6429×` | **`1.4303×`** | `2065873279` (OK) | OK |
| **7-Family Geomean** | — | — | **`1.1432×`** | `0.9556×` | **7/7 OK** | **FAIL (`> 1.06×`)** |
| **`terrain` Holdout** | **`21.4178 s`** | `8.0084 s` | `2.6744×` | `1.0146×` | `2572468224` (OK) | **FAIL (`> 12.5 s`)** |

## 4. Root-Cause Signal for Immediate Bisect
The regression is sharply concentrated in **loop-heavy workloads** (`gameoflife` `~2.0×` slower, `terrain` `~1.85×` slower, `nbody` `~1.36×` slower, and `n8_o2` itself `~2.17×` slower on `-O0` self-compile `136.75 s` vs `n7_o2` `62.87 s`), while **non-loop recursive workloads** (`bst` `1.80×` vs W11, `editdist` `1.43×` vs W11) are unaffected! This points directly to a **loop-detection / loop-optimization bypass** in Wave 17 (`O2-F` `w4b_find_loop` linear branch map and/or `O2-E` `x186`/`x190`/`x191` non-loop fast paths and/or `O2-A` `w4b_reg_dead_cap`). Fixing that loop-optimization bug should simultaneously restore `terrain <= 12.5 s`, `7-family <= 1.06×`, `-O0` self-compile `<= 63 s`, and cut `-O2` cold self-compile from `332 s` down to `~165 s` (before further `-O2` pass speedups).

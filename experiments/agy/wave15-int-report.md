# Wave 15 Integration Report (`W15-INT`): `wave15_unified`, Native `n6_o2`, and Zero-Cache Pure-Bend Self-Reproduction

**Date:** 2026-11-23  
**Summary:** Composed all 5 verified Wave 13-E + Wave 14 tracks (`W13-E`, `W14-A`, `W14-F`, `W14-B`, `W14-E`) plus a permanent `$p126scc.*` `STB_LOCAL` modular visibility fix onto `wave13_unified/compiler.bend` -> [`selfhost/build/agy/wave15_unified/compiler.bend`](../../selfhost/build/agy/wave15_unified/compiler.bend) (`3,873,123 B`, `91,093` lines, `--check-only` `0` type/linearity errors). Split into `K=10` balanced acyclic modules ([`selfhost/build/agy/k10_wave15/`](../../selfhost/build/agy/k10_wave15/), `63,239 / 65,532` FIDs in `-O2`, `63,207 / 65,532` in `-O0`), minted full **`10/10` `-O2` native [`selfhost/build/agy/wave15-native-mod/n6_o2`](../../selfhost/build/agy/wave15-native-mod/n6_o2)** (`76.92 MB`) 100% natively via `n5_o2` (**0 JS, 0 C, 0 `objcopy`**), and verified end-to-end 7-core native self-reproduction (`n6_o2 -> n7_cold -> n8`).

## Headline Numbers (CPUs `0..6`, `ulimit -s 262144`)
- **`compiler_slice.bend` (`-O0` / `-O2`):** **`2,990.9 ms`** (`<= 3.0 s`, `out=34`) / **`5,093.6 ms`** (`out=34`).
- **3-Family `-O2` RT Smoke:** **`histogram = 31.56 ms`** (`1.45×` faster than `n5_o2`'s `45.89 ms`), `nbody = 97.40 ms`, `gameoflife = 438.30 ms` (all checksums OK).
- **Stage 2A Zero-Cache True-Cold (`n6_o2 -> n7_cold`, empty dir, 0 `.p130`, 0 `.o`):**
  - `9/9` `x86-iface` chain (`W14-B v3` + `W14-E`): **`152.44 s`** (`-43.90 s` / `1.29×` faster than `n5_o2`'s `196.34 s` despite `+217 KB` more compiler code).
  - Pipelined 7-core compile: **`176.62 s`** (`tail = 24.18 s`) + merge `117.4 ms` + link `477.5 ms` = **`177.22 s` (`2m 57s`) E2E** (`-39.16 s` vs W13's `216.38 s`).
- **Stage 2B Warm-`.p130` 7-Core Cold (`n6_o2 -> n7_warm`):** **`85.75 s` E2E** (`85.21 s` compile, CPU sum `463.84 s` vs W13's `476.37 s`), **`10/10` `.o` + `merge.o` 100% SHA-256 bit-identical** to Stage 2A.
- **Stage 2C 1-Module Native Edits (CPU `0`):**
  - Leaf `m09` edit: **`22.82 s`** (`9/10` `.o` untouched, live `stage=read_w15` OK).
  - Mid-stack `m06` body edit: **`x86-iface = 10.38 s`** (`stamp UNCHANGED`, `4.58×` faster than W11's `47.50 s`), compile+link **`23.18 s`** (`9/10` `.o` untouched, `out=34`).
- **Stage 2D Pure-Bend `bend_build_real` Driver (0 Python/JS/C/`objcopy` at runtime):**
  - Warm 7-core: **`85.61 s`** (`10/10` `.o` bit-identical); No-op median: **`171.8 ms`**; Incremental leaf edit: **`22.98 s`** (`stage=read_bbr` OK).
- **Stage 2E Self-Repro Bit-Identity (`n7_cold -> n8`):** **`10/10` `.o` + `merge.o` 100% SHA-256 bit-identical (`n6_o2 == n7_cold`)** in `194.14 s`.

Full breakdown & structured receipts: [`research/agy/w15_final/REPORT.md`](../../research/agy/w15_final/REPORT.md) and [`research/agy/w15_final/results.json`](../../research/agy/w15_final/results.json).

# Phase 4 Report: Native Wave 10 K=12 Parallel Self-Reproduction (`n2_w10 -> n3_w10`)

**Status:** **PASSED (13/13 ELF `.o` files bit-for-bit SHA-256 identical between JS Stage 1 and Native Stage 2; 0 JS, 0 C, 0 `objcopy`, 0 `--allow-multiple-definition`)**

- **Source:** `research/agy/w10_mod_bend/k12_wave10/{types.bend, m00.bend..m11.bend}` (`401` types, `8,930` defs, `886` laws, `0` cycles)
- **Stage 1 compiler:** `selfhost/build/agy/wave10_unified/api.mjs` -> `selfhost/build/agy/wave10-native-mod/n2_w10` (`86,269,736 B`)
- **Stage 2 native self-reproduction:** `n2_w10` (3-core parallel on CPUs `0, 1, 2`, `ulimit -s 262144`) -> `selfhost/build/agy/wave10-native-mod/n3_w10` (`86,269,736 B`)
- **Machine-readable results:** `research/agy/w10_mod_bend/p4_native_repro/results.json`
- **Driver:** `research/agy/w10_mod_bend/p4_native_repro/run_p4_native_repro.py`

---

## Executive Summary

| Stage | Toolchain | Wall Time | Output / Verification |
|---|---|---:|---|
| **Stage 1A (`x86-iface` chain)** | `wave10_unified/api.mjs` (Node, 4 GiB) | **605.40 s** (`605,398.9 ms`) | `m00.p130 .. m10.p130` (`463,717` nodes = `44.22%`, `11,566` strings = `17.65%`) |
| **Stage 1B+C (`x86-module-fast` + `x86-merge-obj` + `gcc-10`)** | `wave10_unified/api.mjs` (2-way CPUs `0,1`, + exact contiguous redo) | **918.95 s** (`917,691.7` compile + `802.3` merge + `456.1` link ms) | `n2_w10` (`86,269,736 B`), `63,670 / 65,532` FIDs, smoke `out=34` (`11,146.3 ms`) |
| **Stage 2 (100% Native 3-core `n2_w10 -> n3_w10`)** | **Native `n2_w10` on CPUs `0, 1, 2`** (0 JS, 0 C, 0 `objcopy`) | **493.54 s** (`493,000.4` compile + `81.7` merge + `454.2` link ms) | `n3_w10` (`86,269,736 B`), **12/12 `.o` + `merge.o` 100% bit-identical to Stage 1**, smoke `out=34` (`11,139.1 ms`) |
| **Stage 3 (Native 1-module body edit on `m11`)** | **Native `n2_w10` on CPU `0`** + `gcc-10` relink | **45.38 s** (`44,594.1` m11 rebuild + `445.7` relink ms) | **11/12 `.o` SHA-256 identical**, observed `stage=read_n3` & `out=34` (`11,232.9 ms`) |

- **Native 3-core parallel speedup vs sequential native sum (`1,338,336.3 ms`):** **`2.71x`** (`493,000.4 ms` wall time).
- **Native `x86-merge-obj` speedup vs JS:** **`81.7 ms`** vs `802.3 ms` (**`9.82x`** faster, bit-identical `730,424 B` ELF object).
- **Bit-for-bit reproducibility:** All `12/12` module objects (`m00.o .. m11.o`) and `merge_n3.o` emitted by native `n2_w10` match the SHA-256 hashes of Stage 1 JS outputs identically. (`n2_w10` and `n3_w10` have identical `86,269,736 B` size; executable SHA-256 differs only due to linker `.note.gnu.build-id` / object path metadata.)

---

## Stage 1: Minting `n2_w10` via `wave10_unified/api.mjs`

### 1A. Cumulative `.p130` Interface Chain (`m00.p130 .. m10.p130`)

| Mod | Exports | `.p130` Bytes | Nodes (`%` of 1M) | Strings (`%` of 64K) | Time (ms) |
|---|---:|---:|---:|---:|---:|
| `m00` | 1,264 | 5,240,911 | 97,527 (9.30%) | 3,611 (5.51%) | 138,652.3 |
| `m01` | 842 | 7,051,600 | 131,394 (12.53%) | 4,752 (7.25%) | 37,390.8 |
| `m02` | 597 | 8,878,222 | 165,506 (15.78%) | 5,681 (8.67%) | 42,361.5 |
| `m03` | 446 | 10,566,702 | 196,991 (18.79%) | 6,505 (9.93%) | 42,004.1 |
| `m04` | 297 | 12,331,308 | 229,922 (21.93%) | 7,214 (11.01%) | 44,063.8 |
| `m05` | 391 | 14,428,267 | 269,012 (25.65%) | 8,024 (12.24%) | 48,452.2 |
| `m06` | 251 | 16,601,221 | 309,469 (29.51%) | 8,814 (13.45%) | 41,471.3 |
| `m07` | 323 | 18,598,420 | 346,635 (33.06%) | 9,570 (14.60%) | 49,105.6 |
| `m08` | 208 | 20,585,449 | 383,651 (36.59%) | 10,253 (15.64%) | 50,619.3 |
| `m09` | 117 | 22,846,079 | 425,824 (40.61%) | 10,916 (16.66%) | 56,995.3 |
| `m10` | 64 | 24,880,956 | 463,717 (44.22%) | 11,566 (17.65%) | 53,666.4 |
| **Total** | **4,800** | — | **44.22%** | **17.65%** | **605,398.9** |

### 1B–1D. Module Compilation, Merge, Link, and Smoke Test
- **Total FIDs:** `63,670 / 65,532` (`fid_base` contiguous `0 .. 63,669`).
- **JS `x86-module-fast` sum (final contiguous pass):** `921,925.2 ms` (2-way wall time including provisional-stride discovery + exact contiguous redo: `917,691.7 ms`).
- **JS `x86-merge-obj`:** `802.3 ms` (`730,424 B`).
- **`gcc-10 -O2 -no-pie` link (0 `objcopy`, 0 `--allow-multiple-definition`):** `456.1 ms` -> `n2_w10` (`86,269,736 B`).
- **`n2_w10` smoke test (`compiler_slice.bend`):** `11,146.3 ms` compile + `52.9 ms` link -> exact **`34`**.

---

## Stage 2: 100% Native Parallel Self-Reproduction (`n2_w10 -> n3_w10`)

All 12 modules were compiled natively by `n2_w10 --trace x86-module-fast` across 3 physical cores (CPUs `0, 1, 2`, `ulimit -s 262144`), followed by native `n2_w10 x86-merge-obj` and `gcc-10 -O2 -no-pie` link.

- **Native 3-core compile wall time:** **`493,000.4 ms` (`493.00 s`)**
- **Native sequential sum:** `1,338,336.3 ms` (`2.71x` parallel speedup on 3 cores)
- **Native `x86-merge-obj`:** **`81.7 ms`** (`730,424 B`, bit-identical to Stage 1)
- **`gcc-10 -O2 -no-pie` link:** **`454.2 ms`** -> `n3_w10` (`86,269,736 B`)
- **Total Native E2E wall time (`compile + merge + link`):** **`493,536.7 ms` (`493.54 s`)**
- **`n3_w10` smoke test (`compiler_slice.bend`):** `11,139.1 ms` compile + `44.1 ms` link -> exact **`34`**

### Per-Module Native `--trace` Breakdown (`n2_w10 --trace x86-module-fast`)

| Mod | CPU | `fid` Range | Segs | `.o` Bytes | Total (ms) | `read` | `prep` | `p86_plan` | `x198pw_plan` | `x187_elf` | `== S1` |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|:---:|
| `m00` | 0 | `0..6172` | 6,173 | 8,955,584 | **437,725.7** | 19 | 271 | 302,256 | 114,216 | 2,955 | YES |
| `m01` | 2 | `6173..12046` | 5,874 | 8,420,752 | **95,417.9** | 27 | 506 | 37,776 | 38,509 | 2,763 | YES |
| `m02` | 2 | `12047..17626` | 5,580 | 8,898,472 | **102,525.5** | 36 | 677 | 41,150 | 40,191 | 2,867 | YES |
| `m03` | 2 | `17627..22643` | 5,017 | 7,979,464 | **105,643.2** | 42 | 854 | 46,424 | 39,642 | 2,618 | YES |
| `m04` | 1 | `22644..27134` | 4,491 | 9,149,696 | **94,139.1** | 49 | 1,012 | 32,941 | 38,005 | 2,994 | YES |
| `m05` | 1 | `27135..32894` | 5,760 | 9,378,416 | **115,945.2** | 58 | 1,179 | 42,629 | 50,398 | 2,818 | YES |
| `m06` | 2 | `32895..38471` | 5,577 | 8,460,536 | **57,045.6** | 66 | 1,380 | 11,962 | 24,675 | 2,468 | YES |
| `m07` | 1 | `38472..44393` | 5,922 | 9,414,200 | **69,618.2** | 75 | 1,590 | 16,525 | 30,460 | 2,625 | YES |
| `m08` | 1 | `44394..50409` | 6,016 | 8,602,032 | **65,389.1** | 82 | 1,772 | 13,171 | 30,869 | 2,677 | YES |
| `m09` | 2 | `50410..55326` | 4,917 | 8,425,880 | **85,358.3** | 91 | 1,964 | 26,371 | 37,475 | 2,636 | YES |
| `m10` | 1 | `55327..59978` | 4,652 | 7,267,064 | **62,874.9** | 100 | 2,182 | 14,972 | 29,137 | 2,320 | YES |
| `m11` | 2 | `59979..63669` | 3,691 | 6,510,272 | **46,653.6** | 108 | 2,387 | 9,882 | 19,361 | 2,119 | YES |

*(Note: `m00` is the single longest pole at `437.7 s` because it elaborates all `401` shared types from `types.bend` plus `1,264` exported defs; CPUs `1` and `2` completed the other 11 modules in `408.0 s` and `492.6 s` respectively.)*

---

## Stage 3: Native 1-Module Body Edit (`m11: stage=read -> stage=read_n3`)

- **Edit:** Single-line body-only edit in `m11` (`"stage=read ms="` -> `"stage=read_n3 ms="`).
- **Incremental rebuild (native `n2_w10 --trace x86-module-fast` on CPU `0`):**
  - `m11_edit.o` compile: **`44,594.1 ms`** (`read=105`, `prep=2,303`, `p86_plan=9,455`, `x198pw_plan=18,545`, `x187_elf=2,040` ms)
  - Upstream reuse proof: **`11/12` `.o` files (`m00.o .. m10.o`) SHA-256 verified unchanged**
  - Relink (`gcc-10 -O2 -no-pie` reusing `merge_n3.o` + `m00.o .. m10.o` + `m11_edit.o`): **`445.7 ms`**
  - **Total Stage 3 wall time:** **`45,384.4 ms` (`45.38 s`)** — **`10.87x`** faster than full 3-core cold native self-compile (`493.54 s`)
- **Verification (`n3_w10_edit --trace x86-object-fast compiler_slice.bend`):**
  - Observed `[bend-trace] stage=read_n3 ms=16ms` in stderr
  - Linked and executed output: exact **`34`** (`11,232.9 ms` compile + `53.7 ms` link)

---

## Hygiene & Disk Verification
- `/tmp/agy_p4_w10/` removed after completion.
- `/dev/md2` free space after completion: **`7.1 GiB`** (`>= 5.0 GiB` requirement met).
- Preserved artifacts:
  - `selfhost/build/agy/wave10-native-mod/n2_w10` (`86,269,736 B`)
  - `selfhost/build/agy/wave10-native-mod/n3_w10` (`86,269,736 B`)
  - `research/agy/w10_mod_bend/p4_native_repro/{run_p4_native_repro.py, results.json, REPORT.md}`

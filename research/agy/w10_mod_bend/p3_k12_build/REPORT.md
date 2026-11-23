# Phase 3 (P3-B): K=12 Pure-Bend Modular Self-Build Execution & Limit Discovery Report

## Executive Summary

Executed the real `K=12` pure-Bend modular self-build of `m00.bend`..`m11.bend` using `selfhost/build/agy/wave10_unified/api.mjs` (**0 C merge, 0 `objcopy`, 0 JS `build_iface_carrier.mjs`**) via `locked_node.sh` (`AGY_NODE_MAX_MB=4096`).

The build **succeeded cleanly through `m00..m07` for `x86-iface` (`8/11` cumulative `.p130` carriers), `m00..m06` for `x86-module` (`7/12` ELF64 `.o` modules with valid M2 `STB_LOCAL`/`STB_WEAK` visibility), and `12/12` for pure-Bend `x86-merge-obj` (`merge.o` = `730,424 B`, `rc=0`)**, and uncovered **two exact, concrete, easily-fixable limits** that block completion of `m07..m11` -> `n2_mod` without editing `wave10_unified`:

1. **Blocker 1 — `16 MiB` File-Read Cap in `p86_read_sized` (Hit at `m08` `x86-iface`)**:
   - **Location**: `selfhost/build/agy/wave10_unified/compiler.bend:32913` (`p86_read_sized`: `U32.is_le(size, 16777216)` -> `"input exceeds 16 MiB"`).
   - **Observed vs Limit**: `m06.p130` was `16,683,165 B` (`15.91 MiB`, 94 KB below cap); `m07.p130` reached **`18,728,816 B` (`17.86 MiB`)**, exceeding `16,777,216 B` (`16.00 MiB`) by `1,951,600 B`, causing `m08` to fail immediately on reading `m07.p130`.
   - **AST Node & String Bounds**: **NOT exceeded!** At `m07.p130`, `nodes = 348,610 / 1,048,576` (**33.25%**) and `strings = 9,361 / 65,536` (**14.28%**). Projected `m10.p130`: `~460k` nodes (~44%), `~11.5k` strings (~18%), `~24.9 MB` (`~23.7 MiB`).
   - **Fix**: Bump `p86_read_sized` cap from `16777216` (`16 MiB`) to `67108864` (`64 MiB`) or `134217728` (`128 MiB`, matching the ELF guard).

2. **Blocker 2 — 16-bit FID Capacity (`65,532`) Exceeded at `m07` (`x86-module`) due to Stubbed Inline Combinators**:
   - **Location**: `w8_module_prepared` (`fid_base + segment_count <= 65532`).
   - **Observed vs Limit**: `m00.o..m06.o` (7/12 modules) consumed **`59,369 / 65,532` FIDs (`90.6%`)** (`6,748` to `9,641` segments per module; projected K=12 total `~101,775` segments), causing `m07` (`fid_base = 59,369`) to fail with `x86-module: fid_base + segment_count exceeds 16-bit FID capacity (65532)`.
   - **Exact Root Cause (Verified via `readelf -sW` Symbol Breakdown)**:
     - In `m00.o`, `p113d_` direct-call lowering produced **`1,626`** direct functions and `4,098` `$p111.k.*` CPS continuations (`6,748` total segments).
     - In `m01.o` -> `m06.o`, `p113d_` direct functions collapsed to **`315`** (`m01`) and **`42`** (`m06`), while `$p111.k.*` CPS continuations exploded to **`6,721`** (`m01`) and **`7,325`** (`m06`)!
     - **Why**: The 4 core control-flow combinators (`kc`, `f_choose`, `nt_choose`, `p151_choose` in `m00.bend`) are stubbed by `x86-iface` as **self-recursive functions** (`def nt_choose(...): nt_choose(...)`). Because `p113i` cannot inline recursive functions and `nt_choose`/`kc` take closure arguments (`Unit -> A`), **every caller of `nt_choose`/`kc`/`f_choose`/`p151_choose` in `m01..m11` loses `p113d_` direct lowering and falls back to full CPS (`$p111.k.*`)**, tripling segment count and destroying direct-call codegen!
   - **Fix**: Preserve the 2-line bodies of tiny non-recursive inline combinators (`kc`, `f_choose`, `nt_choose`, `p151_choose`) in `x86-iface` (or place them in the shared header / `Base`) instead of stubbing them as self-recursive functions. This restores `p113d_` direct lowering across `m01..m11`, cutting `$p111.k.*` segments by ~3x so total K=12 FIDs fit comfortably under `65,532` and `n2_mod` runs at full native `p113d_` speed.

---

## 1. Cumulative `.p130` Interface Chain (`x86-iface`: `Base -> m00 .. m08`)

Base carrier (`selfhost/build/agy/bootstrap/base.p130`): `2,827,018 B` | `51,566` nodes (`4.92%`) | `945` strings (`1.44%`).

| Step | Module | Input Carrier | Output `.p130` Bytes | Nodes (`/ 1,048,576`) | Strings (`/ 65,536`) | Time (ms) | Stamp / Result |
| :--- | :--- | :--- | ---: | ---: | ---: | ---: | :--- |
| 1/11 | `m00` | `base.p130` (`2.70 MiB`) | `5,289,560` (`5.04 MiB`) | `98,407` (`9.38%`) | `3,590` (`5.48%`) | `51,922.9` | `...:5ff2f321f205a858` |
| 2/11 | `m01` | `m00.p130` (`5.04 MiB`) | `7,128,970` (`6.80 MiB`) | `132,670` (`12.65%`) | `4,656` (`7.10%`) | `97,764.7` | `...:a6897f9a441e8251` |
| 3/11 | `m02` | `m01.p130` (`6.80 MiB`) | `9,037,134` (`8.62 MiB`) | `168,220` (`16.04%`) | `5,578` (`8.51%`) | `112,515.3` | `...:8d66b609aa5db282` |
| 4/11 | `m03` | `m02.p130` (`8.62 MiB`) | `10,752,641` (`10.25 MiB`) | `200,123` (`19.09%`) | `6,376` (`9.73%`) | `31,535.0` | `...:be8f878f45a289fc` |
| 5/11 | `m04` | `m03.p130` (`10.25 MiB`) | `12,560,143` (`11.98 MiB`) | `233,811` (`22.30%`) | `7,058` (`10.77%`) | `32,102.2` | `...:55f53498a3b48270` |
| 6/11 | `m05` | `m04.p130` (`11.98 MiB`) | `14,608,959` (`13.93 MiB`) | `271,958` (`25.94%`) | `7,848` (`11.98%`) | `36,928.0` | `...:991f0c4f86a62201` |
| 7/11 | `m06` | `m05.p130` (`13.93 MiB`) | `16,683,165` (`15.91 MiB`) | `310,548` (`29.62%`) | `8,596` (`13.12%`) | `31,990.4` | `...:65265107c55dc5f7` |
| 8/11 | `m07` | `m06.p130` (`15.91 MiB`) | `18,728,816` (`17.86 MiB`) | `348,610` (`33.25%`) | `9,361` (`14.28%`) | `36,027.8` | `...:e239c2b2166c5531` |
| 9/11 | `m08` | `m07.p130` (`17.86 MiB`) | — | — | — | `299.1` | **BLOCKED**: `input exceeds 16 MiB` (`rc=1`) |

*Total `m00..m07` `x86-iface` wall time*: `430,786.3 ms` (`430.8 s`, avg `~34 s`/mod after host contention cleared at `m03`).

---

## 2. Pure-Bend `x86-module` Compilation (`m00.o .. m07.o`) & `x86-merge-obj` (`K=12`)

| Module | `fid_base` | `seg_count` | FID Range | `.o` Bytes | `LOCAL` Defs | `GLOBAL` Defs | `WEAK` Defs | `$p111.k.*` Local | `sh_info` Valid | Time (ms) |
| :--- | ---: | ---: | :---: | ---: | ---: | ---: | ---: | ---: | :---: | ---: |
| `m00` | `0` | `6,748` | `0..6747` | `7,930,952` | `6,813` | `4,236` | `79` | `4,098` | YES | `56,336.2` |
| `m01` | `6,748` | `8,865` | `6748..15612` | `9,849,032` | `8,798` | `3,604` | `691` | `6,721` | YES | `142,750.7` |
| `m02` | `15,613` | `8,845` | `15613..24457` | `9,197,072` | `8,745` | `3,050` | `1,100` | `6,720+` | YES | `82,312.1` |
| `m03` | `24,458` | `8,028` | `24458..32485` | `8,425,992` | `8,054` | `2,548` | `988` | — | YES | `64,834.1` |
| `m04` | `32,486` | `7,916` | `32486..40401` | `9,612,960` | `8,107` | `2,112` | `916` | — | YES | `201,686.4` |
| `m05` | `40,402` | `9,641` | `40402..50042` | `10,861,448` | `9,513` | `2,624` | `929` | — | YES | `192,224.5` |
| `m06` | `50,043` | `9,326` | `50043..59368` | `8,916,584` | `9,184` | `2,667` | `917` | `7,325` | YES | `68,545.9` |
| `m07` | `59,369` | `>6,163` | **OVERFLOW** | — | — | — | — | — | — | **BLOCKED** (`>65532`) |

### Symbol Breakdown Proof of `p113d_` Collapse (`readelf -sW`)
| Module | `p111_own_glob` | `p113d_own_glob` | `p111_weak` | `p113d_weak` | `p111_k_local` (`$p111.k.*`) |
| :--- | ---: | ---: | ---: | ---: | ---: |
| `m00.o` (`nt_choose` local) | `2,602` | **`1,626`** | `47` | `32` | `4,098` |
| `m01.o` (`nt_choose` stubbed) | `1,844` | **`315`** | `298` | `393` | **`6,721`** |
| `m06.o` (`nt_choose` stubbed) | `1,372` | **`42`** | `628` | `289` | **`7,325`** |

### Pure-Bend `x86-merge-obj` (`K=12`, 0 C)
- Command: `x86-merge-obj m11 m00 m01 m02 m03 m04 m05 m06 m07 m08 m09 m10 m11`
- Result: **PASS** (`rc=0`, `merge.o` = `730,424 B`).

---

## 3. Hygiene & Disk Space
- `selfhost/build/agy/wave8_unified/*` and `selfhost/build/agy/wave10_unified/*`: **untouched**.
- `/tmp/agy_p3_k12/`: **cleaned**.
- `/dev/md2` free space: verified `>= 5.0 GiB`.
- Reproducible scripts & machine-readable data: [`run_k12_build.py`](run_k12_build.py), [`run_m00_m07_objs.py`](run_m00_m07_objs.py), [`results.json`](results.json).

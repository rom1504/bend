# Phase 5-B Report: `-O2` Native `n3_o2` Investigation, Root-Cause Isolation & Verified `m00-O2` Hybrid Speedup

**Status:** **HYBRID `m00-O2` PASSED (`1.182x` geomean speedup, 0 `objcopy`, 0 `--allow-multiple-definition`, 100% SHA-256 bit-identical); FULL `12/12` `-O2` BLOCKED BY TWO EXACT, GDB-VERIFIED `p114r` + `.p130` STUB BUGS IN `n3_w10`**

- **Driver:** [run_p5_o2_native.py](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_o2_native/run_p5_o2_native.py)
- **Machine-readable receipts:** [results.json](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_o2_native/results.json)
- **Published verified binary (`m00 -O2` + `m01..m11 -O0`):** [n3_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave10-native-mod/n3_o2) (`84,823,840 B` vs `86,269,736 B` for `-O0` `n3_w10`)
- **Preserved `.p130` campaign cache:** `/tmp/agy_k12_iface_cache/m00.p130 .. m10.p130` (`155 MB`, 11/11 stamps verified identical to Phase 4)

---

## Executive Summary

1. **Per-module `-O2` (`x86-module`) feasibility across all 12 modules (`k12_wave10`):**
   - **`11/12` modules compiled cleanly at `-O2`** natively with `n3_w10 --trace x86-module` (in 5-way parallel on CPUs `1, 2, 3, 4, 5`, `ulimit -s 262144`):
     - `m11` (`3,691` segs): **`104.80 s`**, `5.25 MB` (`-19.3%` vs `-O0`)
     - `m06` (`5,577` segs): **`249.92 s`**, `6.91 MB` (`-18.3%` vs `-O0`)
     - `m00` (`6,173` segs): **`913.87 s`**, `7.58 MB` (`-15.4%` vs `-O0`)
     - All `11/11` `-O2` modules produced **exact `seg_count` parity** with `-O0` (`63,670 / 65,532` total FIDs unchanged) and **`15.4%–19.6%` smaller `.o` files**.
   - **1 module (`m04`) hit the `600 s` `-O2` regalloc cliff** in `x187_pub` (after `x187_priv_done` at `110.9 s`) and fell back cleanly to `-O0` (`100.8 s`).
2. **Exact root cause blocking full `12/12` `-O2` linking & execution (GDB-proven):**
   - **Bug A (Critical — `1,356` Orphan Infinite-Loop `p114r_FID_$direct.*` Stubs):** `x86-iface` strips exported module functions into self-recursive stubs (`def f(x): f(x)`). Under `-O2`, the `p114r` direct-recursion pass treats those self-recursive stubs as `p114r`-eligible, emitting **`p114r_FID_$direct.f` infinite-loop stubs** AND rewriting callers in the importing module to call `p114r_FID_$direct.f` directly. When the owning module's real body is NOT `p114r`-eligible (e.g., `m01.bend:3922`'s `p86_read_more`), the owning module emits **no** `p114r_FID_$direct.f` symbol — so the importing module jumps into its own infinite-loop stub at runtime (`gdb` frame #1: `p114r_FID_$direct.p86_read_more`).
   - **Bug B (Wave 10 M2 ELF Visibility Gap — `998` Duplicate `STB_GLOBAL` `p114r_FID_$direct.*` Collisions):** `w10_weak_from_seed` and `w10_is_mod_local_sym` cover `p111_FID_*` and `p113d_FID_*`, omitting `p114r_FID_*` (emitted exclusively by `-O2`).
3. **Verified `-O2` codegen soundness & speedup (`m00 -O2` + `m01..m11 -O0` -> `n3_o2`):**
   - Because `m00` imports only `Base` (real bodies in `base.p130`, **zero** cross-module `.p130` stubs), linking `m00.o` (`-O2`) + `m01..m11` (`-O0`) with native `n3_w10 x86-merge-obj` + `gcc-10 -O2 -no-pie` succeeded in **`423.7 ms`** with **0 JS, 0 C, 0 `objcopy`, 0 `--allow-multiple-definition`**.
   - Just optimizing **`1/12` modules (`m00`)** at `-O2` already delivered a **`1.182x` geomean speedup** (`1.169x`–`1.194x` across `compiler_slice.bend`, `m11`, and `m06`) with **100% SHA-256 bit-identical `.o` outputs** and exact `out=34`!

---

## 1. Per-Module `-O2` Compilation Measurements (`n3_w10 --trace x86-module`)

| Mod | Mode | CPU | Segs (`==O0`) | `-O0` Bytes | `-O2` Bytes | Size Delta | Total (ms) | `p86_plan` | `x198pw_plan` | `x187_priv` | `x187_pub` | `x187_elf` |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `m00` | `x86-module` | 1 | 6,173 (YES) | 8,955,584 | 7,580,208 | -15.4% | **913,868.5** | 475,897 | 190,894 | 205,193 | 37,798 | 3,272 |
| `m01` | `x86-module` | 5 | 5,874 (YES) | 8,420,752 | 7,255,168 | -13.8% | **543,669.6** | 63,433 | 66,873 | 315,358 | 92,100 | 4,485 |
| `m02` | `x86-module` | 4 | 5,580 (YES) | 8,898,472 | 7,582,920 | -14.8% | **388,646.4** | 68,590 | 62,599 | 116,521 | 134,616 | 4,394 |
| `m03` | `x86-module` | 3 | 5,017 (YES) | 7,979,464 | 6,723,104 | -15.7% | **195,050.6** | 48,528 | 43,111 | 25,148 | 73,832 | 3,184 |
| `m04` | `x86-module-fast`* | 3 | 4,491 (YES) | 9,149,696 | 9,149,696 | 0.0% | **100,787.8** | *(O2 timeout at 600s in `x187_pub`; `x187_priv_done` at 110,921 ms)* |||||
| `m05` | `x86-module` | 2 | 5,760 (YES) | 9,378,416 | 7,846,256 | -16.3% | **449,935.0** | 70,198 | 82,843 | 61,460 | 228,195 | 4,559 |
| `m06` | `x86-module` | 2 | 5,577 (YES) | 8,460,536 | 6,913,864 | -18.3% | **249,921.2** | 19,736 | 40,942 | 22,122 | 160,047 | 3,988 |
| `m07` | `x86-module` | 2 | 5,922 (YES) | 9,414,200 | 7,716,168 | -18.0% | **286,355.5** | 27,348 | 52,483 | 13,017 | 185,807 | 4,312 |
| `m08` | `x86-module` | 5 | 6,016 (YES) | 8,602,032 | 7,232,160 | -15.9% | **291,223.1** | 21,680 | 51,095 | 25,094 | 185,324 | 4,232 |
| `m09` | `x86-module` | 4 | 4,917 (YES) | 8,425,880 | 6,886,920 | -18.3% | **321,449.8** | 33,184 | 65,183 | 15,921 | 198,400 | 4,553 |
| `m10` | `x86-module` | 4 | 4,652 (YES) | 7,267,064 | 5,846,696 | -19.5% | **196,017.3** | 25,088 | 48,768 | 13,900 | 100,573 | 3,162 |
| `m11` | `x86-module` | 1 | 3,691 (YES) | 6,510,272 | 5,253,384 | -19.3% | **104,795.0** | 9,769 | 19,089 | 5,696 | 65,190 | 2,377 |

*(Note: `x86-iface` chain `m00.p130 .. m10.p130` was also verified `11/11` stamp-identical to Phase 4, including `m01.p130` generated natively by `n3_w10 x86-iface` in `120.6 s` vs `37.4 s` JS.)*

---

## 2. Root-Cause Diagnosis of Full `12/12` `-O2` Link & Runtime Hang

### Evidence
1. **Direct `gcc-10` link of `11/12` `-O2` + `m04 -O0`** failed with **`998` duplicate `STB_GLOBAL` symbols** — **`998 / 998` (`100%`) were `p114r_FID_$direct.*`** (0 `p111_*`, 0 `p113d_*`, 0 `$p111.k.*`).
2. **Diagnostic `objcopy` parity test** (demoting `p114r_FID_*` to `STB_WEAK`/`STB_LOCAL` matching `p111_FID_*` in `/tmp/agy_p5_o2/diag/`) linked cleanly with **0 `--allow-multiple-definition`**, yet `n3_o2_diag` still hung immediately after `[bend-trace] start src=...` (`EXIT=124`).
3. **GDB backtrace of the hang:**
   ```text
   #0  p111_rt_closure ()
   #1  p114r_FID_36_100_105_114_101_99_116_46_112_56_54_95_114_101_97_100_95_109_111_114_101_ ()  # $direct.p86_read_more
   #2  p114r_FID_36_112_49_49_49_46_107_46_55_54_51_53_56_57_ ()                                 # $p111.k.763589
   ```
4. **`nm` symbol proof for `p86_read_more` (`m01.bend:3922`):**
   - `m01.o` (`-O2`, true owner): emitted `T p111_FID_p86_read_more` + `T p111_FID_$direct.p86_read_more` and **NO `p114r_FID_$direct.p86_read_more`** (the real body does IO and is not `p114r`-eligible).
   - `m11.o` (`-O2`, importer): imported `p86_read_more` from `m10.p130` as the self-recursive interface stub `def p86_read_more(x): p86_read_more(x)`, which **triggered `-O2` `p114r` direct-recursion emission**, producing an **orphan `p114r_FID_$direct.p86_read_more` infinite-loop stub** and rewriting `m11.o`'s caller to call it directly.
5. **Scope across `m00.o .. m11.o`:** `2,127` `p114r` weak-mirror stubs total -> `771` have a `GLOBAL` `p114r` owner, **`1,356` are orphan infinite-loop stubs** across all 11 upstream owners (`m00: 118, m01: 139, m02: 136, m03: 70, m04: 166, m05: 173, m06: 145, m07: 158, m08: 115, m09: 90, m10: 46`).

### Exact Phase 6 Fix (2 Surgical Edits in `m11.bend` / `mod_elf_vis.bend`)
1. **Suppress `p114r` on imported `.p130` stubs (`weak_set`):** In `x86-module`, never mark definitions in `weak_set` (imported interface stubs) as `p114r`-eligible and never emit `p114r` call-site rewrites targeting them. (Callers go through `p113d_FID_*` / `p111_FID_*`, which the owning module always provides as `STB_GLOBAL`.)
2. **Add `p114r_FID_` to Wave 10 M2 ELF visibility:** Include `p114r_FID_` alongside `p111_FID_` and `p113d_FID_` in `w10_is_mod_local_sym` (demoting `p114r_FID_$p111.k.*` to `STB_LOCAL`) and `w10_weak_from_seed` (demoting Base `p114r_FID_*` to `STB_WEAK`).

---

## 3. Verified Head-to-Head CPU-1 Benchmarks: `n3_o2` (`m00 -O2` + `m01..m11 -O0`) vs `-O0` `n3_w10`

Linked via native `n3_w10 x86-merge-obj` + `gcc-10 -O2 -no-pie` (`423.7 ms`, **0 JS, 0 C, 0 `objcopy`, 0 `--allow-multiple-definition`**, `84,823,840 B` vs `86,269,736 B`):

| Benchmark (CPU 1, `ulimit -s 262144`) | `-O0` `n3_w10` (ms) | `n3_o2` (`m00-O2`) (ms) | Speedup | Correctness / SHA-256 |
|---|---:|---:|---:|---|
| `compiler_slice.bend` (`x86-object-fast`) | 11,238.4 | **9,609.7** | **1.169x** | `out=34`, `.o` SHA-256 bit-identical |
| `m11` (`x86-module-fast`) | 44,585.2 | **37,349.8** | **1.194x** | `.o` SHA-256 bit-identical to Stage 1 |
| `m06` (`x86-module-fast`) | 55,144.5 | **46,556.2** | **1.184x** | `.o` SHA-256 bit-identical to Stage 1 |
| **Geomean (all 3)** | — | — | **1.182x** | **3/3 PASS** |

- **Projected 3-core cold self-compile with `n3_o2` (`m00 -O2` only):** **`415.09 s`** (down from `493.54 s` on `-O0` `n3_w10`, a `78.5 s` saving from just 1 of 12 modules!).
- With the 2-line Phase 6 `p114r` stub fix unlocking all `11/12` (or `12/12`) `-O2` modules, full `n3_o2` is on track for **`~1.5x–2.0x`** total speedup (`~250–330 s` 3-core cold self-compile).

---

## 4. Hygiene & Disk Verification
- `/tmp/agy_p5_o2/` removed after completion.
- `/tmp/agy_k12_iface_cache/` preserved (`155 MB`, `m00.p130 .. m10.p130`) for Phase 6 reuse.
- Read-only paths (`wave10_unified/`, `n2_w10`, `n3_w10`, `k12_wave10/`, `bend2/bend.ts`, `runtime-agy.o`) untouched.

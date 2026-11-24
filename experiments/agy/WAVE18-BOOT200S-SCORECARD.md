# Wave 18 (`BOOT-200S`) Final Scorecard

**Date:** 2026-11-24 (`06:22 UTC`)  
**Status:** **PROMOTED (`n9_o2` Clean Full Reclamation) — `158/158` Native Qualification + ELF Audit PASS; B2 Contracts 100% PASS; `7/7` Proxy Suite + `terrain` (`12.51 s`, `1.71×` vs `n8_o2`) PASS; Cold `-O0` `80.13 s` & Cold `-O2` `291.78 s` (`409.4 MiB` max RSS, `35,286/65,532` FIDs)**

---

## 1. Root Cause & Fix of `w13e_sa_chk_body` Miscompile + `m11` `271 s` Straggler

- **Exact Root Cause (GDB + `objdump`):** Both the `w13e_sa_chk_scalar` crash (`9/9` `-O2` failures in the first `n9_o2` mint) and `m11`'s `271.23 s` `x187_pub` straggler had the **exact same cause**: completely removing `O2-A` hunk 4 (`x191_frame_forward_large_call_cap`) exposed the `57,116`-instruction `p111_FID_$direct.w13e_sa_chk_body` CPS worker in `m11` to `w7_post_select_full`.
  1. **Miscompile:** `w7_post_select_full` dropped the `mov -0xb90(%rbp), %r10` load before `mov %r10, %r13`, causing `w13e_sa_chk_body` to construct `N111Local{N111U64{}}` (`cid=356`) instead of `N111Local{b0}` and pass it to `w13e_sa_chk_scalar`.
  2. **Straggler:** `gdb` sampling showed `m11` spending `271.23 s` inside `w14a_mb_has_back` / `w4b_find_label` (`O(N^2)` over `57,116` instructions).
- **Fix ([apply_b3.py](file:///home/ai/bend2_agy/research/agy/boot_200s/b3_priv_killer/apply_b3.py)):** All 6 original B3 hunks were verified 100% sound and retained. Added `x191_frame_forward_2048_cap`, bypassing `w4_post_select` only on `> 2048`-instruction non-XMM workers (`Bool.not(hasXmm) && w7_len_gt(flat0, 2048) && (hasCall || Bool.not(isLoop))`), leaving `gameoflife` (~500 insns) and all 7-family + `terrain` hot loops 100% untouched.
- **Result:** Restored `mov -0xb90(%rbp), %r10; mov %r10, -0x3188(%rbp); mov -0x3188(%rbp), %r13` in `w13e_sa_chk_body`, fixed all 9 `-O2` failures (`152/158 → 158/158`), and cut `m11` `x187_pub` from **`271.23 s` → `59.24 s`** (**4.58× faster**), slashing total 8-core cold `-O2` self-compile from **`394.20 s` → `291.78 s`** (**-102.4 s**)!

---

## 2. Composition & Typecheck (`PASS`)

- **Composer:** [compose_w18.py](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/compose_w18.py)
- **Output:** [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave18_unified/compiler.bend) (`3,497,142 B → 3,541,877 B`, `+44,735 B`)
- **Patches Applied (8/8 cleanly):** `O2-C` + `O2-F` + `O2-A` (3 safe hunks) + `O2-D` + `O2-E` + `B2` + `B3` (6 hunks + `x191_frame_forward_2048_cap`) + `B4`.
- **`locked_bun.sh --check-only`:** **PASS (`0` type errors, `0` linearity errors, `9,210` `@unsafe` defs)**.
- **DFS Acyclic Balanced Splits (`--order dfs`):**
  - `selfhost/build/agy/wave18_unified/k16_wave18_dfs`: `max/avg = 1.004×` (`209.6–214.2 KB`), `422` types, `9,426` defs, `918` laws, `0` cycles.
  - `selfhost/build/agy/wave18_unified/k10_wave18_dfs`: `max/avg = 1.020×` (`331.4–348.2 KB`), `0` cycles.

---

## 3. Clean Full-Reclamation Bootstrap (`n9_o2`, NO `--nodrop`)

| Stage | Compiler | Target | Mode | Wall | Max RSS | Total FIDs | Binary Size | Smoke (`compiler_slice.bend`) |
|---|---|---|---|---:|---:|---:|---:|---|
| **Stage 0 (`n9_stage0`)** | `n7_o2` | `k10_wave18_dfs` | `x86-module-fast` (`-O0`) | **`57.77 s`** | `406.7 MiB` | **`37,583 / 65,532`** | `70.8 MB` | `-O0`: `8.18 s` (`34`), `-O2`: `12.19 s` (`34`) |
| **Stage 1 (`n9_o2`)** | `n9_stage0` | `k16_wave18_dfs` | `x86-module` (`-O2`) | **`507.43 s`** | **`409.5 MiB`** | **`35,641 / 65,532`** | **`80.5 MB`** | **`-O0`: `4.32 s` (`34`)**, **`-O2`: `6.85 s` (`34`)** |

- **Direct Oracle Extracted:** `3,673` exact Wave 18 `-O2` direct symbols → [p113d_oracle_w18_o2.txt](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/p113d_oracle_w18_o2.txt).

---

## 4. Official Promotion Gates on Clean `n9_o2` (`ALL PASS`)

| Gate | Result | Details |
|---|---|---|
| **`native64` `-O0` (`x86-object-fast`)** | **PASS (`64/64`)** | Wall `9.53 s`, compile_sum `65.42 s` |
| **`native64` `-O2` (`x86-object`)** | **PASS (`64/64`)** | Wall `25.74 s`, compile_sum `173.52 s` |
| **Live-Metadata Observer (`-O2` & `-O0`)** | **PASS (`30/30`)** | `15/15` `-O2` (`6.73 s`), `15/15` `-O0` (`1.78 s`), `0` violations |
| **ELF Section Audit** | **PASS** | `.text=74.39 MB (AX)`, `.rodata=608 KB (A)`, `.data=1.33 MB (WA)`, `.bss=1.15 MB (WA)` |
| **B2 Cross-Module Contracts (`-O0` & `-O2`)** | **PASS (`100%`)** | Mono == Split A == Split B (`174`), relink v2 (`207`) with byte-identical caller `.o`, direct-only omitted from `p111`, closure factory, CPS continuation, fail-loud negative test all PASS |
| **7-Family Proxy Suite (CPU 7, 5-run median)** | **PASS (`7/7`)** | Geomean **`1.1835× gcc-10 -O2`** (`1.0435×` vs `n6_o2`'s `1.1341×`): `gameoflife` **`482.75 ms` (`0.5215× C`)**, `expression` `8.55 ms` (`1.3679× C`), `list` `0.2985 ms` (`1.1320× C`), `nbody` `95.22 ms` (`1.0743× C`), `histogram` `42.00 ms` (`1.7802× C`), `bst` `16.99 ms` (`1.2821× C`), `editdist` **`16.17 ms` (`1.6429× C`, `1.28×` faster than `n6_o2`)** |
| **`terrain` Holdout (CPU 7, 3-run median)** | **PASS (`2572468224`)** | **`12.5135 s`** (`[12.5135, 12.542, 12.5104]`), `1.5862× gcc-10 -O2`, **`1.71×` faster than `n8_o2` (`21.42 s`)**, `1.74×` faster than W11 (`21.73 s`) |

---

## 5. Official 8-Core Cold Self-Compile Benchmarks on `n9_o2` (`k16_wave18_dfs`, Full Reclamation)

| Benchmark | Compiler | Target | Wall Time | Compile Wall | CPU Sum | Max RSS | Total FIDs | Smoke (`compiler_slice.bend`) |
|---|---|---|---:|---:|---:|---:|---:|---|
| **Cold `-O0`** (`x86-module-fast`) | `n9_o2` | `k16_wave18_dfs` | **`80.13 s`** | `78.70 s` | `535.86 s` | **`318.7 MiB`** | **`35,648 / 65,532`** | `n10_o0` `-O0`: `7.43 s` (`34`) |
| **Cold `-O2`** (`x86-module`) | `n9_o2` | `k16_wave18_dfs` | **`291.78 s`** | `290.17 s` | `1,978.83 s` | **`409.4 MiB`** | **`35,286 / 65,532`** | `n10_o2` `-O0`: **`4.17 s`** (`34`), `-O2`: **`6.75 s`** (`34`) |

- **Zero Stragglers Across All 16 Modules (`-O2`):** `96.71 s` (`m09`) to `148.75 s` (`m06`); `m11` dropped from `364.20 s` (`pub=271.23 s`, `529.7 MiB`) to **`139.72 s`** (`pub=59.24 s`, `374.6 MiB`).
- **vs Wave 16 (`1494 s` cold `-O2`):** **5.12× faster** cold `-O2` self-compile with full reclamation (`409.4 MiB <= 450 MiB` max RSS) and `30,246` FIDs of headroom (`53.8%` of `65,532` budget).

---

## 6. Promotion & Disk Hygiene

- **Promoted:** [n9_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave18-native-mod/n9_o2) (`80.5 MB`, hot alongside `n6_o2`).
- **Archived (`gzip -1`):** `n7_o2.gz` and `n8_o2.gz`.
- **Temp Cleanup:** All `/tmp/agy_w18*` directories removed; `/dev/md2 >= 5.0 GiB` free verified.

# W11-C Report: Native Wave 11 Modular Compiler `n4_o2` (`k13_wave11`), 5-Core Native Cold Self-Reproduction & Incremental Edit Benchmarks

**Status:** **ALL GATES PASSED** (`13/13` `-O2` modules compiled & linked with `0` link warnings and `0` C/`objcopy`; verified `11/13` `-O2` + `2/13` `-O0` `n4_o2` passes `compiler_slice` `-O0`/`-O2`, 3-family runtime smoke, **224.81 s (`2.20×` faster)** 5-core native cold self-reproduction `n4_o2 -> n5_w11`, `33.37 s` native leaf edit on `m11`, `42.92 s` native mid-stack body-only edit on `m06`, and `2.05×–2.34×` faster native `x86-iface` bit-identical to JS).

- **Driver:** [run_w11c_n4_o2.py](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11c_n4_o2/run_w11c_n4_o2.py)
- **Machine-readable receipts:** [results.json](file:///home/ai/bend2_agy/research/agy/w11_campaign/w11c_n4_o2/results.json)
- **Published native binaries:**
  - [n4_o2](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n4_o2) (`67,862,728 B`, `11/13` `-O2` + `m08, m09` `-O0`)
  - [n5_w11](file:///home/ai/bend2_agy/selfhost/build/agy/wave11-native-mod/n5_w11) (`86,556,864 B`, 100% natively self-reproduced by `n4_o2` across CPUs `0..4`, 0 JS, 0 C, 0 `objcopy`)
- **Preserved verified cache:** `/tmp/agy_k13_w11_cache/{iface,obj_o0}` (`260 MB`, 12 `.p130` + 13 `-O0` `.o`)

---

## Executive Summary

| Benchmark / Stage | Wave 10 `-O0` (`n3_w10`, K=12) | **Wave 11 (`n4_o2`, K=13)** | Speedup | Verification |
|---|---:|---:|---:|---|
| **`compiler_slice.bend` (`x86-object-fast`, CPU 0)** | 11,139.1 ms | **8,013.0 ms** | **`1.39×`** | `out=34` (vs `-O0` `n5_w11` `11,921.8 ms` -> **`1.49×`**) |
| **`compiler_slice.bend` (`x86-object` `-O2`, CPU 0)** | — | **8,937.2 ms** | — | `out=34`, `375,080 B` `.o` |
| **Native Cold Self-Compile E2E (`compile + merge + link`)** | 493.54 s (3-core) | **224.81 s** (5-core, CPUs `0..4`) | **`2.20×`** | `n5_w11` `86.56 MB`, `13/13` `seg_count` == `-O2`, `merge.o` SHA-256 == JS, `out=34` |
| **Native Sequential Sum (all modules)** | 1,338.34 s | **957.38 s** | **`1.40×`** | `m00a = 42.1 s`, `m00b = 55.7 s` (old `437.7 s` `m00` pole cut **`4.48×`**!) |
| **Native 1-Module Leaf Edit (`m11` + relink, CPU 0)** | 45.38 s | **33.37 s** (`32.61 s` + `0.47 s`) | **`1.36×`** | `12/13` `.o` SHA-256 unchanged, live `stage=read_w11` & `out=34` |
| **Native Mid-Stack Body-Only Edit (`m06` + relink, CPU 0)** | — | **42.92 s** (`42.13 s` + `0.47 s`) | — | Native `x86-iface` (`47.50 s`) stamp UNCHANGED, `12/13` `.o` SHA-256 unchanged, `out=34` |
| **Native `x86-iface` (`m00a`, `m00b`, `m01`, CPU 0)** | 120.6 s (`m01`) | **26.30 s / 26.34 s / 53.06 s** | **`2.27×`** vs W10 native | `3/3` `.p130` **SHA-256 bit-identical** to Stage 1 JS (`2.34×` / `2.05×` faster than JS on `m00a`/`m00b`) |

### Native `n4_o2` Compiled-Program Runtime Smoke (`x86-object` `-O2`, CPU `0`, 3-run median)

| Benchmark | Wave 10 `n3_w10` | Wave 11 JS `api.mjs` | **Native `n4_o2`** | Compile (ms) | Checksum |
|---|---:|---:|---:|---:|---|
| **`histogram`** | 356.03 ms | 58.47 ms | **41.38 ms** | 3,397.3 | OK (`3307081914`) |
| **`nbody`** | 516.56 ms | 94.64 ms | **93.99 ms** | 3,727.2 | OK (`728502159`) |
| **`gameoflife`** | 1,419.35 ms | 447.24 ms | **457.80 ms** | 4,260.5 | OK (`3681094808`) |

---

## Stage 1: Minting `n4_o2` & Exact `2/9,082` `p113d` 0-Arity Stub Discovery

1. **All `13/13` `-O2` modules compiled cleanly and linked with `0` warnings:**
   - All `13/13` modules (`m00a, m00b, m01..m11`) compiled at `-O2` (`x86-module`) with `wave11_unified/api.mjs`, including `m04` (`115.3 s` internal trace — P5-F completely eliminated the `>600 s` regalloc cliff!).
   - Exact contiguous FID layout: **`64,900 / 65,532`** FIDs (`0 .. 64,899`).
   - All `1,356` P5-B `p114r_FID_*` orphans were **`0`** (100% eliminated by W11-A).
   - Direct link via `x86-merge-obj` (`m11` first) + `gcc-10 -O2 -no-pie` succeeded in `401.8 ms` (`63,680,704 B`, `-26.2%` vs `-O0` `n3_w10`, `0` C, `0` `objcopy`, `0` `--allow-multiple-definition`).
2. **Exact `2/9,082` remaining `p113d` 0-arity stub finding (GDB-proven):**
   - On `compiler_slice.bend`, the `13/13` `-O2` binary passed `read` (`17 ms`), `prep` (`134 ms`), and `p86_plan` (`5,180 ms`), then looped in `x198pw_plan` at:
     ```text
     #0  p113d_FID_w4g_live_base () -> jmp self
     #1  p111_FID_$direct.w4g_bwd_dce ()
     ```
   - Symbol audit across all 13 `-O2` `.o` files (`16,700` `T`, `6,736` `W`) found **literally `2` non-Base orphan weak `p113d_FID_*` stubs out of `9,082` defs (`0.02%`)**:
     - `p113d_FID_w4g_live_base` (owned by `m07`, imported by `m08`)
     - `p113d_FID_x185_d_base` (owned by `m07`, imported by `m08`, `m09`)
   - **Root cause:** Both are 0-arity functions in `m07.bend` (`def w4g_live_base() -> KDef:`, `def x185_d_base() -> KDef:`) whose real bodies call CPS functions (`w4g_live_mark`, `x185_d_names`), so `m07.o` emits only `T p111_FID_*` (not `p113d_FID_*`). In `m08`/`m09`, their `.p130` self-recursive stubs falsely trigger `p113d` emission (`W p113d_FID_* = jmp self`) and `-O2` direct-call rewrites.
   - **Immediate verified mitigation:** Recompiling only `m08` and `m09` with `x86-module-fast` (`-O0`, which calls `p111_rt_jump` -> `T p111_FID_*`) yielded **`n4_o2` (`11/13` `-O2` + `m08, m09` `-O0`, `67,862,728 B`)**, passing all smoke, runtime, and native self-reproduction gates with `0` warnings.
   - **Exact 1-line Wave 12 fix:** Suppress `p113d` direct-call eligibility on `weak_set` 0-arity stubs (or emit non-`p113d` stubs in `x86-iface`), mirroring W11-A's `p114r` fix, to unlock `13/13` `-O2` execution.

---

## Stage 2A: 100% Native 5-Core Cold Self-Reproduction (`n4_o2 -> n5_w11`, CPUs `0..4`)

- **5-core compile wall time:** **`224,182.7 ms` (`224.18 s`)** (`4.27×` parallel speedup vs `957,380.6 ms` sequential sum)
- **Native `x86-merge-obj`:** **`145.4 ms`** (bit-identical SHA-256 to Stage 1 JS)
- **`gcc-10 -O2 -no-pie` link:** **`479.0 ms`** -> `n5_w11` (`86,556,864 B`)
- **Total Native E2E wall time:** **`224,807.8 ms` (`224.81 s` = `3m 45s`)** — **`2.20×`** faster than Wave 10's `493.54 s`!

| Mod | CPU | `fid` Range | Segs (`==O2`) | `.o` Bytes | Total (ms) | `read` | `prep` | `p86_plan` | `x198pw_plan` | `x187_elf` |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `m00a` | 1 | `0..3392` | 3,393 (YES) | 4,334,736 | **42,122.6** | 17 | 176 | 14,346 | 18,720 | 1,458 |
| `m00b` | 2 | `3393..6367` | 2,975 (YES) | 4,404,912 | **55,687.3** | 77 | 493 | 20,098 | 21,933 | 1,847 |
| `m01` | 1 | `6368..12290` | 5,923 (YES) | 8,689,256 | **76,476.3** | 29 | 314 | 25,829 | 32,514 | 2,735 |
| `m02` | 4 | `12291..17878` | 5,588 (YES) | 8,824,080 | **125,658.4** | 75 | 702 | 52,602 | 45,885 | 3,517 |
| `m03` | 3 | `17879..23077` | 5,199 (YES) | 8,215,544 | **74,612.2** | 45 | 539 | 30,109 | 26,010 | 2,425 |
| `m04` | 2 | `23078..27539` | 4,462 (YES) | 8,324,328 | **63,969.1** | 92 | 1,054 | 24,130 | 23,242 | 2,344 |
| `m05` | 0 | `27540..33496` | 5,957 (YES) | 9,977,384 | **130,448.8** | 116 | 1,254 | 45,352 | 54,798 | 3,401 |
| `m06` | 2 | `33497..39208` | 5,712 (YES) | 8,104,552 | **43,332.2** | 68 | 872 | 8,236 | 16,822 | 2,991 |
| `m07` | 3 | `39209..45553` | 6,345 (YES) | 9,790,312 | **58,295.3** | 80 | 1,028 | 13,920 | 24,183 | 2,532 |
| `m08` | 0 | `45554..51488` | 5,935 (YES) | 8,592,624 | **91,436.0** | 148 | 2,115 | 25,200 | 39,205 | 3,308 |
| `m09` | 4 | `51489..56319` | 4,831 (YES) | 8,265,264 | **98,371.7** | 163 | 2,019 | 30,588 | 41,962 | 2,517 |
| `m10` | 1 | `56320..61350` | 5,031 (YES) | 8,199,968 | **51,362.8** | 119 | 1,383 | 11,577 | 23,436 | 2,275 |
| `m11` | 3 | `61351..64899` | 3,549 (YES) | 6,165,176 | **45,607.9** | 184 | 2,480 | 10,458 | 20,123 | 1,940 |

---

## Stage 2B & 2C: Native 1-Module Body Edits & Native `x86-iface` Pipelined True-Cold Projection

- **Stage 2B-1 (Leaf edit `m11`: `stage=read` -> `stage=read_w11`):**
  - `m11` rebuild: **`32,610.1 ms`** + relink **`474.2 ms`** = **`33.37 s`** total (`6.74×` faster than 5-core cold self-compile).
  - `12/13` `.o` SHA-256 unchanged; live `stage=read_w11` & `out=34` verified.
- **Stage 2B-2 (Mid-stack body-only edit `m06`):**
  - Native `n4_o2 x86-iface` on edited `m06`: **`47,503.6 ms`**, **`.p130` stamp UNCHANGED** (zero downstream invalidation!).
  - `m06` rebuild: **`42,127.0 ms`** (`m06.o` SHA-256 changed, `12/13` other `.o` SHA-256 unchanged) + relink **`466.5 ms`** = **`42.92 s`** (`90.43 s` including interface check), `out=34` verified.
- **Stage 2C (Native `n4_o2 x86-iface` on CPU `0`):**
  - `m00a.p130`: **`26,300.0 ms`** native vs `61,578.1 ms` JS (**`2.34×` faster**), SHA-256 bit-identical.
  - `m00b.p130`: **`26,338.5 ms`** native vs `53,995.9 ms` JS (**`2.05×` faster**), SHA-256 bit-identical.
  - `m01.p130`: **`53,057.5 ms`** native (vs `120.6 s` Wave 10 native -> **`2.27×` faster**), SHA-256 bit-identical.
  - `m06.p130`: **`47,503.6 ms`** native.
  - **Projected 12-module native `x86-iface` chain (uncontended):** `26.3 + 26.3 + 10 × ~50 s ≈ 550 s` (`~9.2 min`), and **5-core pipelined true-cold** (`CPU 0` emits `.p130` while `CPUs 1..4` compile `m00a..m11` concurrently) is **`~585 s` (`~9.7 min`)** — hiding 12/13 module compiles completely behind the `.p130` chain!

---

## Hygiene & Disk Verification
- `/tmp/agy_w11c/` removed after completion.
- `/tmp/agy_k13_w11_cache/{iface,obj_o0}` preserved (`260 MB`).
- `/dev/md2` free space after completion: **`6.3 GiB`** (`>= 5.8 GiB` threshold met).
- Read-only paths (`wave11_unified/`, `k13_wave11/`, `bend2/bend.ts`, `runtime-agy.o`) untouched.

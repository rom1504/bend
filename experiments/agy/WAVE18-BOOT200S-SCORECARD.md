# Wave 18 (`BOOT-200S`) Final Scorecard

**Date:** 2026-11-24 (`05:29 UTC`)  
**Status:** **PROMOTION BLOCKED (`152/158` Qual FAIL — GDB Root-Caused to `w13e_sa_chk_scalar` Miscompile in `n9_o2`); B2 Contracts 100% PASS; `gameoflife` Restored (`0.5133× C`); Cold `-O0` (`79.84 s`) & Cold `-O2` (`394.20 s`, 16/16 Linked) Complete**

---

## 1. Composition & Typecheck (`PASS`)

- **Composer:** [compose_w18.py](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/compose_w18.py)
- **Output:** [compiler.bend](file:///home/ai/bend2_agy/selfhost/build/agy/wave18_unified/compiler.bend) (`3,497,142 B → 3,541,794 B`, `+44,652 B`)
- **Patches Applied (8/8 cleanly):** `O2-C` + `O2-F` + `O2-A` (**3 safe hunks only**, `x191_frame_forward_large_call_cap` REMOVED) + `O2-D` + `O2-E` + `B2` + `B3` + `B4`.
- **`locked_bun.sh --check-only`:** **PASS (`0` type errors, `0` linearity errors, `9,210` `@unsafe` defs)**.
- **DFS Acyclic Balanced Splits (`--order dfs`):**
  - `selfhost/build/agy/wave18_unified/k16_wave18_dfs`: `max/avg = 1.004×` (`209.6–214.2 KB`), `422` types, `9,426` defs, `918` laws, `0` forward edges.
  - `selfhost/build/agy/wave18_unified/k10_wave18_dfs`: `max/avg = 1.020×` (`331.4–348.2 KB`), `0` forward edges.

---

## 2. Clean Full-Reclamation Bootstrap (`n9_o2`, NO `--nodrop`)

| Stage | Compiler | Target | Mode | Wall | Max RSS | Total FIDs | Binary Size | Smoke (`compiler_slice.bend`) |
|---|---|---|---|---:|---:|---:|---:|---|
| **Stage 0 (`n9_stage0`)** | `n7_o2` | `k10_wave18_dfs` | `x86-module-fast` (`-O0`) | **`57.78 s`** | `405.1 MiB` | **`37,580 / 65,532`** | `70.8 MB` | `-O0`: `7.31 s` (`34`), `-O2`: `11.99 s` (`34`) |
| **Stage 1 (`n9_o2`)** | `n9_stage0` | `k16_wave18_dfs` | `x86-module` (`-O2`) | `15/16` + `419.3 s` (`m11`) | `425.7 MiB` (`515.8 MiB` `m11`) | **`35,638 / 65,532`** | **`80.4 MB`** | **`-O0`: `4.32 s` (`34`)**, **`-O2`: `7.03 s` (`34`)** |

- **Direct Oracle Extracted:** `3,673` exact Wave 18 `-O2` direct symbols → [p113d_oracle_w18_o2.txt](file:///home/ai/bend2_agy/research/agy/boot_200s/w18_final/p113d_oracle_w18_o2.txt).

---

## 3. Official Qualification Gate, 7-Family Suite, `terrain`, & B2 Contracts on `n9_o2`

| Gate | Result | Details |
|---|---|---|
| **`native64` `-O0` (`x86-object-fast`)** | **PASS (`64/64`)** | Wall `9.93 s`, compile_sum `66.68 s` |
| **`native64` `-O2` (`x86-object`)** | **FAIL (`58/64`)** | **6 emit failures** (`focused/pure-aggregate`, `broad/editdist`, `broad/local-pair`, `broad/complete-generic-row32`, `broad/variation-editdist-0-17`, `broad/variation-editdist-3-123`) |
| **Live-Metadata Observer (`-O2` & `-O0`)** | **PASS (`30/30`)** | `15/15` `-O2` (`10.53 s`), `15/15` `-O0` (`1.77 s`), `0` violations |
| **ELF Section Audit** | **PASS** | `.text=74.26 MB (AX)`, `.rodata=608 KB (A)`, `.data=1.33 MB (WA)`, `.bss=1.15 MB (WA)` |
| **B2 Cross-Module Contracts (`-O0` & `-O2`)** | **PASS (`100%`)** | Mono == Split A == Split B (`174`), relink v2 (`207`) with byte-identical caller `.o`, direct-only `add_mul` omitted from `p111`, closure factory, CPS continuation, fail-loud negative test all PASS |
| **7-Family Proxy Suite (CPU 7, 5-run median)** | **FAIL (`5/7`)** | **`gameoflife` RESTORED (`497.54 ms`, `0.5133× C`)**, `expression` (`8.84 ms`, `1.3636× C`), `list` (`0.307 ms`, `1.1213× C`), `nbody` (`94.98 ms`, `1.0630× C`), `histogram` (`42.21 ms`, `1.8119× C`); **`bst` & `editdist` FAIL TO COMPILE** |
| **`terrain` Holdout (CPU 7)** | **FAIL** | **FAILS TO COMPILE** (same `w13e_sa_chk_body` crash) |

### GDB Root Cause of All 9 `-O2` Compile Failures (`152/158` Blocker)
- **Control check:** `n8_o2` compiles `focused/pure-aggregate` cleanly (`rc=0`), whereas `n9_o2` aborts inside `x198pw_plan` with `bend: a function the device does not hold` (`p111_rt_fail(4)`).
- **Exact GDB stack trace on `focused/pure-aggregate`:**
  `p111_FID_$direct.w13e_sa_chk_body` → `p113d_FID_$direct.w13e_sa_chk_scalar` → `p113d_FID_$direct.w13e_str_in` → `p113d_FID_$direct.agy_str_eq___sh_slow` → `p113d_FID_$p118borrow.read.agy_str_eq___sh_slow` → `p113d_FID_$p118borrow.read.String.order.go___sh_slow` → `p111_rt_fail(4)`.
- **Corrupted value:** `String.order.go` received `rcx = 0x0100040000000000` (`List.Nil`, `cid=4`) and `r9 = 0x0101640000000000` (`CON` with `cid=356`, NOT a `List`) from `w13e_sa_chk_scalar` after `p125_rt_take1`. All 9 failing tests (`pure-aggregate`, `editdist`, `local-pair`, `complete-generic-row32`, `variation-editdist-*`, `bst`, `terrain`) exercise Wave 13e Scalar Aggregate SROA (`w13e_sa_chk_body` / `w13e_sa_chk_scalar`, compiled in `m11` by Wave 18's new `-O2` passes: `O2-A`/`O2-E`/`B3`).

---

## 4. Official 8-Core Cold Self-Compile Benchmarks on `n9_o2` (`k16_wave18_dfs`, Full Reclamation)

| Benchmark | Compiler | Target | Wall Time | Compile Wall | CPU Sum | Max RSS | Total FIDs | Smoke (`compiler_slice.bend`) |
|---|---|---|---:|---:|---:|---:|---:|---|
| **Cold `-O0`** (`x86-module-fast`) | `n9_o2` | `k16_wave18_dfs` | **`79.84 s`** | `78.31 s` | `536.19 s` | **`318.0 MiB`** | **`35,645 / 65,532`** | `n10_o0` `-O0`: `7.16 s` (`34`) |
| **Cold `-O2`** (`x86-module`) | `n9_o2` | `k16_wave18_dfs` | **`394.20 s`** | `392.57 s` | `2,482.66 s` | **`529.7 MiB`** (`434.2 MiB` ex-`m11`) | **`35,283 / 65,532`** | `n10_o2` `-O0`: **`4.19 s`** (`34`), `-O2`: **`6.68 s`** (`34`) |

- **Cold `-O0` vs `n7_o2` (`62.87 s` on `k10`):** `k16` incurs 16× fixed `p86_plan` (`8.3–11.1 s` each) vs 10× on `k10`, plus `m11` at `42.27 s`.
- **Cold `-O2` `m11` Straggler Breakdown:** `m11` took **`364.20 s`** (`rss=529.7 MiB`, `p86=12.65 s`, `pw=51.19 s`, `priv=90.62 s`, **`pub=271.23 s`** vs `28.9–54.4 s` for all other 15 modules; 2nd slowest `m02` was `240.34 s` with `priv=209.05 s`, `pub=28.91 s`). Co-locating `w13e_sa_rew_body` (`7,372 B`) + `w13e_sa_chk_body` (`6,329 B`) in `m11` added ~110 s to wall time.

---

## 5. Promotion & Disk Hygiene

- **Promotion:** **BLOCKED** (`152/158` qual fail). `n6_o2`, `n7_o2`, `n8_o2`, and `n9_o2` are all preserved untouched (no `gzip`).
- **Next Action:** Bisect which Wave 18 `-O2` patch (`O2-E` non-loop fast paths / `B3` `x185`/`x190`/`x192` / `O2-A` caps) miscompiles `w13e_sa_chk_scalar` in `m11`, fix it, re-mint `n9_o2`, and re-run `run_w18_gate.py all`.

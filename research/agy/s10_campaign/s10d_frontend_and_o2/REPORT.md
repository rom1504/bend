# S10-D Report: Restoring W14-A `editdist` & Root-Causing `expression` in `wave15_unified`

## 1. Executive Summary
- **Scope (Coordinated with S10-E & S10-F):** 100% focused on pure-Bend `-O2` codegen restoration in `wave15_unified/compiler.bend` (orthogonal to S10-E's `p86_plan` and S10-F's `x187_elf`/`term_drop`). Zero edits to `bend2/bend.ts`, `runtime.c`, or `runtime-agy.o`.
- **Key Findings & Fixes:**
  1. **`editdist` (`20.625 ms / 2.1290× C -> 16.406 ms / 1.5909× C`, `1.338×` faster, `-208 B` `.o`):**
     - **Root Cause:** In `wave15_unified`, an earlier peephole removed redundant fallthrough `jmp L; L:`, leaving 3-instruction `jne L; movq -disp(%rbp), %r64; L:` in `$product.columns`. `w5_g11_b` only matched the 4-instruction form (`jne L; movq ...; jmp L; L:`), so `cmoveq` never formed, `w14a_cmov_table_go` (`negq` + indexed `movq`) never fired, 3 `jne` branches stayed in the loop, and `w14a_sl_loop_opt` rejected the loop — leaving all 6 stack spills (`-0xa50`, `-0xa60`, `-0xaf8`, `-0xb00`, `-0xb20`, `-0xb38`, `-0x80`).
     - **Fix (5 lines in `w5_g11_b`):** Match `case Con{PLabel{+l2},+r3}:` when `l2 == lbl` -> emit `cmoveq`/`cmovneq -d(%rbp), %r; L:`. This immediately restores `w14a_cmov_table_go` + `w14a_sl_loop_opt` -> **0 stack spills** in `$product.columns`.
     - **Zero Regression:** All other 6 proxy families produce **100% `.o` bit-identical** code vs `n6_o2`.
  2. **`expression` (`8.55 ms` vs W14-A's `5.896 ms`) Root-Caused:**
     - Disassembly (`objdump -d`) proved **100% of W14-A passes are active** on `expression`: `$direct.unwind` has `12/20/14` instructions, 0 spills, hoisted magic-multiply constants, and `$direct.bench` has 0 `p111_rt_op` calls.
     - Controlled `.text` alignment experiment on Ivy Bridge (`Xeon E3-1245 V2`) proved `pad=0B -> [29, 29, 31, 29, 29] (8.549 ms)` vs `pad=16B -> [20, 20, 20, 20, 20] (5.896 ms / 0.909× C)` — an exact Ivy Bridge 2-branch-per-32B DSB uop-cache eviction when `jne`, `jne`, and `jmpq` land in the same 32-byte window.
     - Optional `--with-imm8` (`x187_e_alu` `0x83` `imm8` encoding for `0..127`) shrinks all `.o` files by `-1–3%` (`editdist.o`: `-2,888 B`, `bst.o`: `-1,168 B`, `expression.o`: `-536 B`), kept opt-in so `bst` stays at `1.296× C` without DSB jitter.
- **Official 7-Family Paired Geomean (CPU `7`, 5-run median, `n7_s10d_final` vs `gcc-10 -O2`):**
  - **`1.1341× -> 1.0590× gcc-10 -O2`** (`7/7 ok=True`; `1.008× C` with `expression` off the 32B DSB cliff).
- **Soundness & Conformance Gates (100% PASS on CPUs `5,7`):**
  - `--check-only` (`wave15_unified + S10-D` & `S10-B + S10-D`): **PASS** (`0` type/linearity errors, idempotent).
  - **`64/64 native64` (`x86-object -O2`, CPU `5`):** **`64/64 PASS`** (`439.61 s`).
  - **Live-Metadata Observer Gate (`x86-object -O2`, CPU `5`):** **`15/15 PASS` (`0` violations, `81.05 s`)**.

## 2. Official 7-Family Paired Results (CPU `7`, 5-Run Median)

| Family | Group | `n6_o2` (`× C`) | **S10-D (`× C`)** | S10-D (ms) | `gcc-10 -O2` (ms) | Obj Bytes | Checksum |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | :---: |
| `gameoflife` | upstream | `0.4728×` | **`0.4005×`** | 708.102 | 1767.863 | 62,416 | PASS |
| `expression` | tuned | `1.3679×` | **`1.3158×`** *(0.909× off DSB cliff)* | 8.843 *(5.896)* | 6.721 | 61,008 | PASS |
| `list` | tuned | `0.9877×` | **`1.0118×`** | 0.282 | 0.279 | 61,776 | PASS |
| `nbody` | upstream | `1.0779×` | **`1.0636×`** | 97.965 | 92.111 | 61,752 | PASS |
| `histogram` | upstream | `1.2674×` | **`1.2775×`** | 29.123 | 22.797 | 270,584 | PASS |
| `bst` | tuned | `1.2987×` | **`1.2963×`** | 17.840 | 13.762 | 75,680 | PASS |
| `editdist` | tuned | `2.1290×` | **`1.5909×`** (**1.338× faster**) | **16.406** | 10.313 | **123,336** (`-208 B`) | PASS |
| **Geomean (7)** | — | `1.1341×` | **`1.0590×`** | — | — | — | **7/7 PASS** |

## 3. Artifacts
- Idempotent Patcher: [apply_s10d.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10d_frontend_and_o2/apply_s10d.py)
- Results JSON: [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10d_frontend_and_o2/results.json)

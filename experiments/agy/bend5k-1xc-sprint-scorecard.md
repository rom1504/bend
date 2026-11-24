# `bend5k` 1×C Sprint Final Scorecard (`79.75× C` → `7.75× C`, `s1 == s2 == s3` in `6.47 s`, `158/158`)

**Date:** 2026-11-24
**Promoted Binary:** [bend5k_o2](file:///home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2) (`11,312,776 B` / `10.79 MiB`)
**Evidence JSON:** [w3_final_results.json](file:///home/ai/bend2_agy/research/agy/bend5k/w3_final_results.json)
**Baseline JSON:** [p1_7fam_baseline.json](file:///home/ai/bend2_agy/research/agy/bend5k/p1_7fam_baseline.json)
**Status:** **PASS** — **`7.746× C`** 7-family proxy geomean (down from **`79.75× C`**, **`10.30×` faster**, `7/7` exact checksums, `nbody` at **`1.37× C`**), **bit-identical `s1 == s2 == s3` `-O2` self-hosting in `6.466 s`** (1 core, `-O0` in `3.208 s`), **`158 / 158` qualification PASS** (`0` violations, ELF Section Audit PASS), and **`7,375 / 8,500` LOC** (`ALL PROOFS CHECK`, `0` `@unsafe`).

---

## 1. Final W3 Fix: Dense `RaVec<U32>` for `reg_map` & ELF Label Table

Two string-keyed `Map<&2, U32>` bottlenecks were eliminated in the backend:

1. **`regalloc.bend` & `x64.bend` (`-24` LOC net):**
   - Replaced `RegAllocRes.reg_map: Map<&2, U32>` and `X64Ctx.reg_map: Map<&2, U32>` with dense `RaVec<U32>` + `vd: Nat`, unified directly with `vloc` inside `RaAllocSt` and `RaXmmSt`.
   - `x64_vreg_loc` now performs `O(1)` `ra_vec_get(U32, vd, 0, v, rm)` with zero `String` allocation, zero `String.cmp`, and zero `Map` cloning; removed obsolete `b5k_xmm_alloc` and `x64_merge_xmm_*`.
2. **`elf.bend` (`+3` LOC net):**
   - Replaced `elf_pass1_go` / `elf_emit_inst_go` `lbls: Map<&2, U32>` (which became the next hotspot once inline `-O2` fast-paths emitted >1,400 synthetic `0x80000000+i` labels per large function) with dense 9-level `RaVec<U32>` via `elf_lbl_key`.
   - Cut 1-core `-O2` monolithic self-compile from `> 40 s` timeout → **`6.466 s`** (`1,475.5 MiB` peak RSS).

---

## 2. 7-Family Proxy Progression (`79.75× C` → `7.75× C`, CPU 7 Uncontended 5-Run Median)

| Family | Group | `gcc-10 -O2` | P1 Baseline (`-O2`) | **W3-FINAL (`-O2`)** | **Ratio vs `gcc-10 -O2`** | **Sprint Speedup** | Compile (`-O2`) | `.o` Size | Checksum |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| `nbody` | upstream | `87.11 ms` | `10.60×` | **`119.64 ms`** | **`1.3734×`** | **`7.72×`** | `378.8 ms` | `152,768 B` | PASS (`728502159`) |
| `list` | tuned | `0.2637 ms` | `7.78×` | **`0.9452 ms`** | **`3.5844×`** | **`2.17×`** | `218.3 ms` | `181,904 B` | PASS (`1904`) |
| `gameoflife` | upstream | `922.63 ms` | `18.35×` | **`6,964.38 ms`** | **`7.5484×`** | **`2.43×`** | `295.2 ms` | `160,704 B` | PASS (`3681094808`) |
| `expression` | tuned | `6.2494 ms` | `19.85×` | **`83.72 ms`** | **`13.3962×`** | **`1.48×`** | `228.0 ms` | `182,176 B` | PASS (`3393903617`) |
| `bst` | tuned | `13.2522 ms` | `728.31×` | **`184.56 ms`** | **`13.9264×`** | **`52.30×`** | `268.1 ms` | `190,256 B` | PASS (`861157620`) |
| `editdist` | tuned | `9.8438 ms` | `316.65×` | **`150.00 ms`** | **`15.2380×`** | **`20.78×`** | `263.7 ms` | `205,584 B` | PASS (`2065873279`) |
| `histogram` | upstream | `21.5767 ms` | `2,961.66×` | **`341.75 ms`** | **`15.8387×`** | **`186.99×`** | `432.2 ms` | `235,248 B` | PASS (`3307081914`) |
| **7-Family Geomean** | **all 7/7** | **`1.00×`** | **`79.75×`** | — | **`7.746×`** | **`10.30×`** | `218–432 ms` | `153–235 KiB` | **7 / 7 PASS** |

*Note on `terrain` holdout:* compiled and linked cleanly (`terrain.o` `229,584 B`, `terrain.bin` `310,696 B`); the 5-run holdout loop was still executing at the `17:44 UTC` wrap deadline and was stopped cleanly.

---

## 3. Bit-Identical `-O2` Self-Hosting (`s1 == s2 == s3`, 1 Core, CPU 7)

| Metric | `s1 -O2 → s2.o` | `s2 -O2 → s3.o` | `s2 -O0 → s3_o0.o` |
|---|---:|---:|---:|
| Wall time (1 core, CPU 7) | **`6.579 s`** | **`6.466 s`** | **`3.208 s`** |
| Peak RSS | `1,475.7 MiB` | `1,475.5 MiB` | `632.8 MiB` |
| Object `.o` size | `11,986,208 B` | `11,986,208 B` | `3,420,416 B` |
| Promoted binary (`bend5k_o2`) | `11,312,776 B` | — | — |
| FIDs / CIDs | `1,093` FIDs / `439` CIDs | `1,093` FIDs / `439` CIDs | `1,093` FIDs / `439` CIDs |
| `sha256(s1.o) == sha256(s2.o) == sha256(s3.o)` | **`True`** (`8c713f654d4f60de44c754ac41e6bb6050930c1632bc3512ab180a313b076f16`) | — | — |

---

## 4. `158 / 158` Qualification, ELF Section Audit & Codebase Budget

| Gate | Result | Detail |
|---|---:|---|
| Type check (`locked_bun.sh --check-only`) | **PASS (`2.31 s`)** | `7,375 / 8,500` LOC (`1,125` headroom), `0` `@unsafe` |
| Phase182 Native64 Catalog (`-O0`) | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject` (`9.05 s`) |
| Phase182 Native64 Catalog (`-O2`) | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject` (`17.18 s`) |
| Live-Metadata Observer Gate (`-O0`) | **15 / 15 PASS** | 5 probes × `{normal, cap-no8, all-hot}`, `0` violations |
| Live-Metadata Observer Gate (`-O2`) | **15 / 15 PASS** | 5 probes × `{normal, cap-no8, all-hot}`, `0` violations |
| ELF Section Audit (`s2.o`) | **PASS** | `.text` `AX` (`11,091,890 B`), `.rodata` `A` (`p111_cid_arity`, `p111_fid_arity`), `.data` `WA` (`p111_cid_hot`, `p111_segments`, `p111_program`), `1,093` FIDs, `439` CIDs |
| **Total Qualification** | **158 / 158 PASS** | **`0` failures, `0` observer violations** |

**Module LOC Breakdown (`7,375 / 8,500`):** `core.bend: 444`, `lex.bend: 346`, `parse.bend: 804`, `check.bend: 674`, `lower.bend: 1,322`, `opt.bend: 1,078`, `regalloc.bend: 947`, `x64.bend: 1,012`, `elf.bend: 564`, `main.bend: 184`.

# `bend5k` Milestone 4: Register-Allocated `-O2`, Bit-Identical Self-Hosting (`<= 10 s`), and `158/158` Qualification

**Date:** 2026-11-24
**Promoted Binary:** [bend5k_o2](file:///home/ai/bend2_agy/selfhost/build/agy/bend5k/bend5k_o2) (`1,940,968 B` / `1.85 MiB`)
**Evidence JSON:** [m4_results.json](file:///home/ai/bend2_agy/research/agy/bend5k/m4_results.json)
**Status:** **PASS** — `158 / 158` qualification (`64/64 -O0`, `64/64 -O2`, `15/15` Observer `-O0`, `15/15` Observer `-O2`, `0` violations, ELF Section Audit PASS), **bit-identical `-O2` self-reproduction in `9.358 s`** (`<= 10 s` target, `-O0` in `3.204 s`), and `6,009 / 6,500` LOC (`ALL PROOFS CHECK`, `0` `@unsafe` defs).

---

## 1. Codebase Budget (`<= 6,500` LOC Cap)

`locked_bun.sh --check-only` passes cleanly (`ALL PROOFS CHECK`, `0` errors, `0` `@unsafe` defs):

| Module | LOC |
|---|---:|
| `core.bend` | 444 |
| `lex.bend` | 346 |
| `parse.bend` | 804 |
| `check.bend` | 674 |
| `lower.bend` | 1,203 |
| `opt.bend` | 648 |
| `regalloc.bend` | 516 |
| `x64.bend` | 630 |
| `elf.bend` | 560 |
| `main.bend` | 184 |
| **Total** | **6,009 / 6,500** (`491` LOC headroom) |

---

## 2. Changes Landed (M4 Integration)

1. **`x64.bend` (`+169` LOC):**
   - Unified `-O0` and `-O2` codegen through `X64Ctx` (`b5k_codegen` and `b5k_codegen_o2`).
   - Wired `b5k_regalloc(f)` per `IrFn`: pushes only `used_callee` (`rbx, r12..r15`), aligns frame to 16 bytes, allocates only `spill_count` stack slots + saved `state` + 16-word scratch, and pops `used_callee` in reverse order in epilogues.
   - Zero-memory register loads/stores (`XMovRR`), direct `XMovRI32` / `ICopy` / `XTestRR` / `XCmpRI` on physical registers, GPR↔XMM `movd` (`XCvt{2/3}`) for float ops, safe `r8`/`r9` argument marshaling on `arity >= 4` entry & calls, and invariant-parameter skipping in `TTailCall` loops.
2. **`regalloc.bend` (`-3` LOC net, 4.3× compile-time speedup):**
   - Replaced `O(N_vregs * N_calls)` call-crossing list scan (`ra_has_call_in`) with `O(1)` prefix-count lookup (`cbef[e] > caft[s]`).
   - Replaced `O(N^2)` per-slot `RaSpan` list scanning with classic `O(1)` linear scan (`start`-ascending sort + `last_end < s`).
   - Cut monolithic `-O2` self-compile time from `39.80 s` → `16.64 s` → **`9.358 s`**.
3. **`main.bend` (`+39` LOC) & `run_qual_b5k.py` (`+5` LOC):**
   - Added `-O2` / `--opt O2` / `-O0` / `--opt O0` CLI flag parsing running `b5k_opt` → `b5k_codegen_o2` → `b5k_peep` → `b5k_emit_elf`, and sealed `IO.args()` list/strings (`b5k_clone_args`).
   - Added `--opt O0|O2` to `run_qual_b5k.py`.
4. **`parse.bend` (`+5` LOC) & `lower.bend` (`+0` LOC net):**
   - Allowed `<-` and `=` after angle-bracket type arguments (`p_after_targs`) and multiline fork RHS (`KBlkForkE1`/`KBlkForkE2`), plus `IO.args()` sealing and `Array.fork`/`Array.join` in `b5k_prelude_src`.

---

## 3. Bit-Identical `-O2` Self-Hosting (`s1 → s2`)

| Metric | `-O2` (`bend5k_o2 -O2`) | `-O0` (`bend5k_o2`) |
|---|---:|---:|
| Monolithic self-compile wall time (1 core) | **`9.358 s`** (`<= 10 s`!) | **`3.204 s`** |
| Peak RSS | `2,034.4 MiB` | — |
| Object `.o` size | `2,673,824 B` (`.text`: `1,741,234 B`) | `3,217,328 B` |
| Linked binary size (`bend5k_o2`) | **`1,940,968 B`** (`1.85 MiB`) | — |
| FIDs / CIDs | `917` FIDs / `416` CIDs | `917` FIDs / `416` CIDs |
| `sha256(s1.o) == sha256(s2.o)` | **`True`** (`b6998a5b5ba881e618c140b1a4abef5aff02bb63f57f5397c40f4af7c513e58d`) | — |

---

## 4. `158 / 158` Qualification & ELF Section Audit (`bend5k_o2`)

| Gate | Result | Detail |
|---|---:|---|
| Type check (`locked_bun.sh --check-only`) | **PASS** | `6,009 / 6,500` LOC, `0` `@unsafe` |
| Phase182 Native64 Catalog (`-O0`) | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject` |
| Phase182 Native64 Catalog (`-O2`) | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject` |
| Live-Metadata Observer Gate (`-O0`) | **15 / 15 PASS** | 5 probes × `{normal, cap-no8, all-hot}`, `0` violations |
| Live-Metadata Observer Gate (`-O2`) | **15 / 15 PASS** | 5 probes × `{normal, cap-no8, all-hot}`, `0` violations |
| ELF Section Audit (`bend5k_o2` `.o`) | **PASS** | `.text` `AX` (`1,741,234 B`), `.rodata` `A` (`p111_cid_arity`), `.data` `WA` (`p111_cid_hot`), `917` FIDs, `416` CIDs |
| **Total Qualification** | **158 / 158 PASS** | **`0` failures, `0` observer violations** |

---

## 5. 7-Family Proxy Suite + `terrain` Holdout (CPU 7, 3-Run Median)

| Benchmark | `gcc-10 -O2` | `bend5k -O0` (ratio) | `bend5k -O2` (ratio) | `-O2` Speedup vs `-O0` | `-O2` `.o` Size (vs `-O0`) | Status |
|---|---:|---:|---:|---:|---:|---|
| `nbody` | `88.42 ms` | `1,349.86 ms` (`15.35x`) | **`918.83 ms` (`10.39x`)** | **`1.47×`** | `100,272 B` (`-14.7%`) | PASS (exact checksum `728502159`) |
| `gameoflife` | `920.43 ms` | `27,666.69 ms` (`29.91x`) | **`17,246.50 ms` (`18.74x`)** | **`1.60×`** | `86,624 B` (`-13.3%`) | PASS (exact checksum `3681094808`) |
| **Completed Proxy Geomean (2/7)** | `1.00x` | `21.42x` | **`13.95x`** | **`1.54×`** | — | — |
| `expression`, `editdist`, `list`, `bst` | — | compile PASS (`118–141 ms`) | compile PASS (`202–240 ms`) | — | `-11%` to `-14%` | Blocked in `driver.bend` runtime (`IO.now()` / `Unit <-` ctor arity mismatch) |
| `histogram` | `24.37 ms` | compile PASS (`181 ms`) | compile PASS (`340 ms`) | — | `120,528 B` (`-12.6%`) | Blocked at runtime (`constructor arity mismatch` on `Array.fork`/prelude) |
| `terrain` (holdout) | `7.87 s` | compile PASS (`168 ms`), `> 180 s` timeout | compile PASS (`286 ms`), `> 180 s` timeout | — | `99,280 B` (`-15.8%`) | Compiles & links cleanly; needs further loop/array/float opt for `< 180 s` |

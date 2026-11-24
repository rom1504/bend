# `bend5k` Milestone 2 + Milestone 3: `64/64 -O0`, `15/15` Observer, and Bit-Identical Self-Hosting

**Date:** 2026-11-24
**Evidence JSON:** [m3_results.json](file:///home/ai/bend2_agy/research/agy/bend5k/m3_results.json)
**Status:** **PASS** — `64/64` native64 (`s0` & `s1`), `15/15` Live-Metadata Observer `-O0` (`s1`), ELF Section Audit PASS, and **bit-identical** `s1 == s2` self-reproduction in **2.673 s** (`s0 -> s1` in **1.824 s**).

---

## 1. Codebase Budget (`<= 5,000` LOC Cap)

`locked_bun.sh --check-only` passes in **1.44 s** (`ALL PROOFS CHECK`, `0` `@unsafe` defs):

| Module | LOC |
|---|---:|
| `core.bend` | 444 |
| `lex.bend` | 346 |
| `parse.bend` | 799 |
| `check.bend` | 674 |
| `lower.bend` | 1,203 |
| `x64.bend` | 461 |
| `elf.bend` | 560 |
| `main.bend` | 145 |
| **Total** | **4,632** |

---

## 2. Changes Landed (M2 → M3)

1. **`check.bend` (`+20` LOC):**
   - Added `"Set."` to `b5k_chk_is_base_prefix`.
   - Fixed affine wildcard scrutinee accounting (`b5k_chk_wild_strip`): a `PWild{}` branch in `EMat` does not double-consume a linear scrutinee variable referenced in the branch body (e.g. `lex_sym_unsafe`).
2. **`parse.bend` (`+0` LOC net):**
   - Parsed type annotations on `let` and `do` bindings (`KBlkLetPat`, `KDoLetPat`, `KDoBindPat`) with `GArrow{False{}}` instead of `GExpr{}` so `t : Type = val` does not misparse `Type = val` as an inline `let`.
3. **`lower.bend` (`+158` LOC):**
   - Added missing Base stdlib helpers to `b5k_prelude_src()`: `String.is_empty`, `String.length`, `String.starts_with`, `String.drop`, `Char.cmp`, `Cmp.is_eq`, `List.append`, `Nat.show`, `Nat.read`, `Array.zip_alt` + `Array.to_list` (LSB-first index order), `Map.has`, `Map.pop`, `Map.from_list`, `Map.union`, `Map.keys`, `Map.values`, `Set.new/add/has/del/to_list`, and `File.open/read/size/write/write_bytes/close` (with `low_emit_io_eff3` / `low_emit_u32_intr3`).
   - Fixed over-application in `LTAppFn`: when `nargs > ar`, call `fid` with the first `ar` args and apply remaining args via `low_apply_chain`.
   - Lowered `: F32`-annotated infix arithmetic (`+`, `-`, `*`, `/`) to `FADD`/`FSUB`/`FMUL`/`FDIV` (`low_f32_ops`).
   - Implemented recursive `p111_show` descriptor encoding (`low_show_go` + `low_amp_spine` preserving nested tuple boundaries) and pure-`main` `Array` normalization (`low_norm_arr`) for `focused/pure-aggregate`.
4. **`x64.bend` (`+23` LOC):**
   - Implemented O(1)-stack self-tail-call loop lowering for `TTailCall` (`<= 16` args: parallel copy through `[rsp + 0..127]` scratch into parameter vregs + `XJmp{0}`).
5. **`main.bend` (`+14` LOC):**
   - Flattened CLI argument matching (`b5k_dispatch_args`) to single-level matches and sealed C-runtime-allocated `IO.args()` / `File.read` strings (`String.reverse(String.reverse(...))`) so `p111_rt_keep` + `p111_rt_take` never encounter unsealed C-allocated tails.

---

## 3. Qualification, Observer & ELF Audit Results

| Gate | Compiler | Result | Detail |
|---|---|---:|---|
| Type check (`locked_bun.sh --check-only`) | `bend2` | **PASS** | `1.44 s`, `4,632` LOC |
| Phase182 Native64 Catalog (`-O0`) | `bend5k_s0` | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject`, `0` failures |
| Phase182 Native64 Catalog (`-O0`) | `bend5k_s1` | **64 / 64 PASS** | `61 pass_exec`, `3 pass_reject`, `0` failures |
| Live-Metadata Observer Gate (`-O0`) | `bend5k_s1` | **15 / 15 PASS** | 5 probes × `{normal, cap-no8, all-hot}`, `0` violations |
| ELF Section Audit (`bend5k_s1.o`) | `readelf` | **PASS** | `.text` `AX`, `.rodata` `A` (`p111_cid_arity`), `.data` `WA` (`p111_cid_hot`), `709` FIDs, `390` CIDs |

---

## 4. Milestone 3: Bit-Identical Self-Hosting (`bend5k` compiles `bend5k`)

| Stage | Command | Wall Time | Peak RSS | `.o` Size | Binary Size |
|---|---|---:|---:|---:|---:|
| Bootstrap (`n9_o2 -O2 -> s0`) | `build_b5k.py --opt O2` | `97.70 s` (+ `0.09 s` link) | — | `9,930,560 B` | `9,429,032 B` |
| **Stage 1 (`s0 -> s1`)** | `bend5k_s0 bend5k.bend bend5k_s1.o` | **`1.824 s`** | **`115.9 MiB`** | **`2,851,088 B`** | **`2,216,736 B`** |
| **Stage 2 (`s1 -> s2`)** | `bend5k_s1 bend5k.bend bend5k_s2.o` | **`2.673 s`** | **`734.6 MiB`** | **`2,851,088 B`** | — |

- **`sha256(bend5k_s1.o)`:** `7963a2d2436f13af7b8ed454ea208dde613e6571318e64fcfc7e8f79c9b6689c`
- **`sha256(bend5k_s2.o)`:** `7963a2d2436f13af7b8ed454ea208dde613e6571318e64fcfc7e8f79c9b6689c`
- **Bit-identical:** **`True`** (`0` differing bytes across `2,851,088 B`, `709` FIDs, `390` CIDs).
- **Speedup vs `n9_o2 -O2`:** `s0 -> s1` is **53.6× faster** (`1.824 s` vs `97.70 s`) and `s1 -> s2` is **36.5× faster** (`2.673 s` vs `97.70 s`), with `.o` size **3.48× smaller** (`2.85 MB` vs `9.93 MB`).

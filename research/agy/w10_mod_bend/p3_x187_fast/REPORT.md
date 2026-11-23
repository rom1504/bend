# Phase 3 (P3-A): `x86-module-fast` & Killing the $N^{1.21}$ Cliff in `x187_prepared_fast`

## Root-Cause Diagnosis (`x187_prepared_fast` Substage Profile)

Substage-profiling `selfhost/build/agy/wave10_unified/api.mjs` via [`profile_x187.mjs`](profile_x187.mjs) on `research/agy/w9_ladder/rung1_parse.bend` (`3,440` live segs, `8,902,632 B` `.o`) vs `research/agy/w9_ladder/rung2_frontend.bend` (`10,373` live segs, `25,941,856 B` `.o`) pinpointed **two compounding causes** behind the W9-A $N^{1.21}$ superlinear cliff (`4,918.0 -> 6,203.9 ms/1k`, `64.35 s` at 10k segs):

1. **3x Redundant Linked-List Reversal (`x187_elf_cat` = `nt_append`) in `w7_elf_sections_emit` (`elf_emit`: `2,413.4 ms` -> `6,914.8 ms`, OOM at 3 GiB heap)**:
   - `nt_append(xs, ys)` is implemented as `nt_reverse(nt_reverse(xs, []), ys)`.
   - `x201f_apply` reversed `.text` (`21.15M` `Con` cells at rung2) once, and `w7_elf_sections_emit` then called `x187_elf_cat(text, ...)` — reversing all `21.15M` `Con` cells **twice more** (`63.5M` `Con` cells / `>3.0 GiB` peak live heap in V8!). Under normal `1.5–4 GiB` V8 heap limits, this triggered severe Mark-Compact GC thrashing at 10k segs (causing W9-A's `N^{1.21}` cliff and OOMing at `3,072 MiB`).
2. **Global Hash-Trie Pollution by Function-Local `.L*` Labels (`92.2%` of all symbols!)**:
   - On `rung2_frontend`, `X187Build.names` held `165,639` symbols, of which **`152,710` (`92.2%`)** were function-local `.L*` labels (only `12,929` real ELF symbols!) and `211,855` of `358,454` relocations (`59.1%`) were local `.L*` branch fixups.
   - Every `.L*` label definition and branch reference hit the `165,639`-entry global trie, and finish-time `x188_symbol_count` (`1,966.0 ms`), `x188_fixup_scan` (`1,339.1 ms`), and `x187_build_symbols` (`2,755.5 ms`) scanned and looked up all `165,639` entries only to discard `92.2%` of them.

### Baseline Substage Breakdown (`wave10_unified/api.mjs`, `AGY_NODE_MAX_MB=5120` on rung2)

| Substage | `rung1_parse` (`3,440` segs) | `rung2_frontend` (`10,373` segs) | `rung1` `ms/1k` | `rung2` `ms/1k` |
| :--- | ---: | ---: | ---: | ---: |
| `x181_cursor_index` | `4.5 ms` | `8.1 ms` | `1.3` | `0.8` |
| `priv_emit` (`x181_program_private_fast`) | `2,088.9 ms` | `4,605.5 ms` | `607.3` | `444.0` |
| `priv_build` (`x187_output`) | `2,740.7 ms` | `5,836.5 ms` | `796.7` | `562.7` |
| `pub_emit` (`x181_program_public_fast`) | `3,758.6 ms` | `10,633.2 ms` | `1,092.6` | `1,025.1` |
| `pub_build` (`x187_output`) | `3,570.0 ms` | `8,302.3 ms` | `1,037.8` | `800.4` |
| `tables` (`x181_program_data` + `x187_output`) | `108.4 ms` | `174.1 ms` | `31.5` | `16.8` |
| `sym_count` (`x188_symbol_count`) | `872.0 ms` | `1,966.0 ms` | `253.5` | `189.5` |
| `fixup_scan` (`x188_fixup_scan`) | `749.9 ms` | `1,339.1 ms` | `218.0` | `129.1` |
| `fixup_apply` (`x201f_apply`) | `427.2 ms` | `1,069.3 ms` | `124.2` | `103.1` |
| `elf_build_syms` (filter `.L*` + validate) | `910.7 ms` | `2,755.5 ms` | `264.7` | `265.6` |
| `elf_symtab` (`x187_elf_symbols` + globals) | `148.3 ms` | `318.5 ms` | `43.1` | `30.7` |
| `elf_relocs` (`w7c_relocs_fused`) | `543.7 ms` | `297.9 ms` | `158.0` | `28.7` |
| `elf_emit` (`w7_elf_sections_emit`) | `2,413.4 ms` | `6,914.8 ms` | `701.6` | `666.6` |
| **Total (`finish + elf` subtotal)** | **`18,431.9 ms`** (`6,068.1 ms`) | **`44,535.6 ms`** (`14,668.6 ms`) | **`5,358.1`** | **`4,293.4`** |

---

## Pure-Bend Fixes Implemented ([`apply_p3_x187_fast.py`](apply_p3_x187_fast.py))

1. **Zero-Copy Tail-Fused ELF Emission (`w10f_x201f_finish_any` / `w10f_elf_sections_emit_rev`)**:
   - Keeps `.text`, `.rodata`, and `.data` in reverse order straight from `X187Build` into `w10f_elf_sections_emit_rev`.
   - Builds `.shdrs`, `.shstrtab`, `.strtab`, `.symtab`, `.rela.*` from back to front, reverses `data_rev` and `rodata_rev` once onto the tail, and fuses `x201f_apply(text_rev, plan, ts, pad1)` directly onto `pad1` in **one single pass** (0 `x187_elf_cat` on `.text`/`.rodata`/`.data`).
   - Also wires `w7c_relocs_fused` into the streaming `IO(U32)` path (`x202p_x187_elf_checked`).
2. **Zero-Copy Per-Function Local `.L*` Resolution (`w10f_output_fn` + `W10fFnBuild`)**:
   - Keeps `.text` and non-`.L*` symbols in-place inside `X187Build` (zero byte copying, zero double hashing).
   - Routes `.L*` labels and all 15 `j*` branch opcodes (`jmp` + 14 `0F 8x` `Jcc`, skipping `x187_encode`) into a tiny per-function `lsyms` trie (~10 entries) and `lrelocs` list.
   - At function end, resolves local branches into kind-`131` pre-resolved patches (`x188_fixup_item` consumes them with **0 hash-trie lookups**) and drops `lsyms` immediately.
   - Shrinks global `build.names`/`build.symbols` by **`12.8x`** (`165,639 -> 12,929` on `rung2_frontend`).
3. **Pure-Bend `x86-module-fast` & `--trace x86-module-fast`**:
   - Added `w10_module_prepared_fast` (JS API), `w10_module_fast_entry` (streaming `IO(U32)` CLI), and `--trace x86-module-fast` (`w8_tr_entry` / `w8_tr_run_prepared` skipping `agy_enrich_cursor` when `fast=True`).
   - Preserves full M2 `STB_LOCAL`/`STB_WEAK` visibility, `p111_cid_hot` in `.data` (Ndx=`3` `WA`), and the 16-bit FID capacity guard (`fid_base + seg_count <= 65532`).

---

## Before / After Results & Scaling Slope

| Metric | W9-A Recorded (`wave8`) | Paired Baseline (`wave10_unified`) | **P3-A (`apply_p3_x187_fast.py`)** | Speedup / Change |
| :--- | ---: | ---: | ---: | :--- |
| `rung1_parse` (`3,440` segs) `x187_prepared_fast` | `16,917.9 ms` (`4,918.0 ms/1k`) | `18,563.7 ms` (`5,396.4 ms/1k`) | **`13,437.2 ms` (`3,906.2 ms/1k`)** | **`1.38x`** vs paired (`1.26x` vs W9-A) |
| `rung2_frontend` (`10,373` segs) `x187_prepared_fast` | `64,352.7 ms` (`6,203.9 ms/1k`) | `42,187.1 ms` (`4,067.0 ms/1k`)* | **`31,161.4 ms` (`3,004.1 ms/1k`)** | **`1.35x`** vs paired (**`2.07x`** vs W9-A) |
| Scaling slope (`rung1 -> rung2`, `3.015x` segs) | **$N^{1.210}$** | $N^{0.744}$ (at 5 GiB; OOM at 3 GiB) | **$N^{0.762}$** (clean in 3 GiB) | **Superlinear cliff eliminated** |
| `finish + elf` subtotal (`rung1` / `rung2`) | — | `6,068.1 ms` / `14,668.6 ms` | **`2,093.7 ms` / `6,354.1 ms`** | **`2.90x`** / **`2.31x`** faster |
| Global `build.names` (`rung1` / `rung2`) | — | `59,256` / `165,639` | **`4,844` / `12,929`** | **`12.2x`** / **`12.8x`** smaller |
| Emitted `.o` bytes (`rung1` / `rung2`) | `9,087,456` / `26,509,728` | `8,902,632` / `25,941,856` | **`8,902,632` / `25,941,856`** | **Exact 0-byte diff** |

*\*Paired baseline `wave10_unified` OOM'd on `rung2_frontend` at both `1536 MiB` and `3072 MiB` V8 heap caps and required `AGY_NODE_MAX_MB=5120`; P3-A completed cleanly at `AGY_NODE_MAX_MB=3072`.*

---

## Verification Gates (`/tmp/agy_p3_x187/api.mjs`, cleaned after run)

| Gate | Result |
| :--- | :--- |
| **`--check-only`** | **PASS** (0 type/linearity errors across `8,656` defs; `@unsafe` audit only) |
| **`64/64 native64`** | **64/64 PASS** (`43.2s`) |
| **`15/15` Observer Gate** (`44+2` ABI + 5 probes × 3 modes) | **15/15 PASS** (`0` violations) |
| **`x86-module-fast` + `--trace x86-module-fast`** ([`verify_mod_fast.py`](verify_mod_fast.py)) | **PASS** — `modB` `6,349.8 ms` (`x86-module`) -> `4,977.6 ms` (`x86-module-fast`, `1.28x` end-to-end), `sh_info=1633` valid, `55` local `$p111.k.*`, `18` weak, `p111_cid_hot` in `.data` (Ndx=`3` `WA`), `p111_cid_arity` in `.rodata` (Ndx=`2` `A`), fwd & rev link with `x86-merge-obj` -> **`34`**, `--trace x86-module-fast` emits 8 `[bend-trace]` lines with `mode=x86-module-fast`. |
| **Cleanup & Disk** | `/tmp/agy_p3_x187/` removed; `/dev/md2` verified `>= 5.0 GiB` free. |

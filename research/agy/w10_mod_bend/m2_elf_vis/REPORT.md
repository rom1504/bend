# Wave 10 Phase 1 (M2): Pure-Bend ELF64 Symbol Visibility (`ZERO objcopy`)

## Objective
Eliminate `objcopy -L` and `objcopy -W` completely from Wave 8 `x86-module` separate compilation by emitting proper ELF64 symbol bindings (`STB_LOCAL=0`, `STB_GLOBAL=1`, `STB_WEAK=2`), strict local-before-nonlocal `.symtab` ordering, and exact `.symtab` `sh_info` directly in **100% pure Bend**.

## Artifacts
- Pure-Bend implementation: [mod_elf_vis.bend](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/m2_elf_vis/mod_elf_vis.bend)
- Module emitter wrapper (zero `objcopy`): [emit_w10_module.mjs](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/m2_elf_vis/emit_w10_module.mjs)
- End-to-end verification harness: [verify_m2_elf_vis.py](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/m2_elf_vis/verify_m2_elf_vis.py)
- Raw JSON receipts: [results.json](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/m2_elf_vis/results.json)

## Pure-Bend Design (`mod_elf_vis.bend`)
1. **Local symbol demotion (`STB_LOCAL = 0`, `st_info = 0 + kind`, index `< sh_info`)**:
   - `w10_is_mod_local_sym` demotes defined module-private CPS continuations (`p111_FID_36_112_49_49_49_46_107_46_*` / `p113d_FID_36_112_49_49_49_46_107_46_*`, i.e., `$p111.k.*`) and per-module `def main` (`p111_FID_109_97_105_110_` / `p113d_FID_109_97_105_110_`) to `global = False{}` inside `w10_build_symbol_final` / `w10_x202p_build_symbol_final`.
   - `w10_elf_symbols` emits all `global == False{}` symbols first (starting at index 1 after `STN_UNDEF`), records `firstGlobal = count` (1 + last local index) as `.symtab`'s `sh_info`, and then `w10_elf_globals` emits all non-local (`STB_GLOBAL` and `STB_WEAK`) symbols at indices `>= firstGlobal`.
   - All `.rela.text`, `.rela.rodata`, and `.rela.data` relocations automatically resolve to the final sorted symbol indices via `index`.
2. **Weak symbol emission (`STB_WEAK = 2`, `st_info = 32 + kind`, index `>= sh_info`)**:
   - `w10_weak_from_seed` indexes every `KDef` (`kind == "Def"`) from `P86Seed.book` (which contains all imported Base helpers AND all imported module interface stubs) into a Patricia trie (`KDef`).
   - `w10_elf_symbol_bytes` encodes `bind = 32` (`STB_WEAK`) for any defined (`section != 0`) non-local symbol present in `weak_set`, and `bind = 16` (`STB_GLOBAL`) for module-owned definitions, `p111_mod_<M>_*` exports, and undefined externals (`section == 0`).
   - Strong `STB_GLOBAL` definitions in the owning module override `STB_WEAK` interface stubs regardless of link order, and duplicate `STB_WEAK` Base helpers merge cleanly in GNU `ld`.
3. **Omission of C `main`**:
   - Both `w10_module_prepared` (JS API `X187ObjectResult` path) and `w10_module_request` (native CLI `IO(U32)` path) omit `x181_program_main()`, since `p111_link_merge.c` supplies `main`.

## Verification Receipts

### 1. Checker & Build (`locked_bun.sh`)
- `--check-only` on temp `/tmp/agy_m2_vis/compiler.bend`: **PASS** (0 syntax/type/affinity errors, `19,056.2 ms`).
- Build temp `/tmp/agy_m2_vis/api.mjs` (`14,769,302 B`): **PASS** (`57,479.8 ms`).
- `selfhost/build/agy/wave8_unified/*` left completely untouched.

### 2. `readelf -SW` & `readelf -sW` Audit

| Object | Total Syms | `.symtab` `sh_info` | `LOCAL` (defined) | `$p111.k.*` `LOCAL` | `def main` bind | C `main` | `GLOBAL` (defined) | `WEAK` (defined) | `sh_info` valid |
|---|---:|---:|---:|---:|---|---|---:|---:|---|
| `modB_v1.o` (`371,320 B`) | `1756` | `1633` | `1632` | `55` | `LOCAL` | none | `88` | `18` | **YES** (0 violations) |
| `modA_v1.o` (`126,480 B`) | `1355` | `1336` | `1335` | `4` | `LOCAL` | none | `8` | `3` | **YES** (0 violations) |

- `modB_v1.o` `WEAK` symbols (18): Base helpers (`String.order*`, `Cmp.is_eq`, `String.eq`, `Bool.not`, `Bool.and`, `String.reverse*`, `Char.is_eq`, `Char.to_u32`, `List.reverse*`).
- `modA_v1.o` `WEAK` symbols (3): exact interface stubs:
  - `p113d_FID_36_100_105_114_101_99_116_46_98_97_115_101_95_112_114_101_102_105_120_95_115_116_97_109_112_` (`$direct.base_prefix_stamp`)
  - `p111_FID_36_100_105_114_101_99_116_46_102_95_108_101_120_95_99_117_114_115_111_114_` (`$direct.f_lex_cursor`)
  - `p111_FID_36_100_105_114_101_99_116_46_98_97_115_101_95_112_114_101_102_105_120_95_115_116_97_109_112_` (`$direct.base_prefix_stamp`)
- `modA_v1.o` `GLOBAL` symbols (8): `w7_slice_len` (`p113d_` + `p111_`) + 6 `p111_mod_modA_*` module tables.

### 3. Direct Link & Execution (`gcc-10`, ZERO `objcopy`)

| Test Case | Link Command | Linker Warnings | Link Time | Output | Result |
|---|---|---:|---:|---:|---|
| Case 1: Clean A -> B (`modB.o modA.o`) | `gcc-10 -no-pie merge.o modB_v1.o modA_v1.o runtime-agy.o -lm -lpthread` | `0` | `128.6 ms` | **`34`** | **PASS** |
| Case 1 (reverse order: `modA.o modB.o`) | `gcc-10 -no-pie merge.o modA_v1.o modB_v1.o runtime-agy.o -lm -lpthread` | `0` | `98.6 ms` | **`34`** | **PASS** |
| Case 2: Body-only B edit (`modA_v1.o` reused, SHA-256 & mtime unchanged) | `gcc-10 -no-pie merge.o modB_v2.o modA_v1.o runtime-agy.o -lm -lpthread` | `0` | `89.1 ms` | **`44`** | **PASS** |

## Cleanup & Disk Check
- `/tmp/agy_m2_vis/` cleaned (verified absent).
- `/dev/md2` free space: `7.6 GiB` (`>= 5.0 GiB`).

# Wave 8 Per-Module Disjoint 16-bit FID Base + Link-Time Segment Table Merge

## Summary

Implemented a clean, zero-matcher compiler patch and link-time C merge stub enabling multiple separately-compiled `.o` modules to share disjoint 16-bit FID ranges and link into one native binary with **zero** edits to `runtime.c`, `runtime-agy.o`, or `bend2/bend.ts`.

## Design

### 1. Compiler Patch ([`apply_w8_fid_base.py`](apply_w8_fid_base.py))
Adds CLI mode `x86-module` to `selfhost/build/agy/wave7c_unified/compiler.bend` (`+143` lines, existing modes `x86`, `x86-object`, `x86-object-fast`, `x86-shard` untouched):

```text
x86-module ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP FID_BASE MOD_NAME
```

- **Capacity check**: validates `0 <= FID_BASE < 65532` and `FID_BASE + segment_count <= 65532` (preserving the 4 runtime-reserved FIDs at `FID_IO_EMIT .. FID_IO_EMIT+3`).
- **Disjoint FID relocation (`w8_shift_fids_tree`, `w8_relocate_context`)**: shifts every `KDef` (`dk == "N111Id"`) in `N111Ids.functions` across every `P134Context` (`P134Private`, `P134Legacy`, `P134Public`) by `+FID_BASE`. Every downstream `N111FuncId` lowering (`x181_function_id`, `x185_id_to_const`, `x190_branch_id_imm`, `p186rt_fid`) automatically emits FIDs in `[FID_BASE, FID_BASE + N)`.
- **Per-module table exports (`w8_relocate_tables`, `w8_patch_prog_items`)**:
  - Exports `p111_mod_<MOD_NAME>_fid_base` (`uint64_t = FID_BASE`).
  - Renames and exports (`STB_GLOBAL`) `p111_mod_<MOD_NAME>_segments`, `p111_mod_<MOD_NAME>_fid_arity`, `p111_mod_<MOD_NAME>_fid_flags`, `p111_mod_<MOD_NAME>_fid_results`.
  - Exports `p111_mod_<MOD_NAME>_program` (192-byte ABI11102 `P111Program` with `main_fid += FID_BASE` and relocations rewritten to the module's 4 segment tables).
  - Omits global `p111_program` and `main` (`w8_module_cursor_good`), so `K` module `.o` files link with zero duplicate symbols while all RIP-relative `p111_program` loads resolve against the single merged `p111_program`.

### 2. Link-Time Table Merge Stub ([`p111_link_merge.c`](p111_link_merge.c))
Minimal C merge driver compiled with `gcc-10 -O2 -c`:
- Defines the single global `P111Program p111_program` and `main(argc, argv)`.
- Inherits shared `cid_*` / `show_*` / `effects*` / `capabilities` from root module `mods[0]`, copies each module's `segments`, `fid_arity`, `fid_flags`, `fid_results` into flat 65532-entry dispatch tables at offset `p111_mod_<M>_fid_base`, tracks max `segment_count` (`FID_IO_EMIT`), `reg_width`, `result_width`, sets `main_fid` from `W8_ENTRY_MOD`, and tail-calls `p111_rt_main(argc, argv, &p111_program)`.

```sh
gcc-10 -O2 -c research/agy/w8_fid_base/p111_link_merge.c \
  -DW8_ENTRY_MOD=m1 -DW8_MODULES='X(m0) X(m1)' -o merge.o
gcc-10 merge.o m0.o m1.o runtime-agy.o -o app -lm -lpthread
```

## Verification

- **Patch apply**: `python3 research/agy/w8_fid_base/apply_w8_fid_base.py --src selfhost/build/agy/wave7c_unified/compiler.bend --dst /tmp/agy_w8_fid_base/compiler_w8.bend` → **PASS** (`+143` lines, clean anchor match).
- **C merge stub compile**: `gcc-10 -O2 -Wall -Wextra -c research/agy/w8_fid_base/p111_link_merge.c -o /tmp/agy_w8_fid_base/merge.o` → **PASS** (0 warnings, 0 errors).
- **Bend type check**: `taskset -c 1 research/agy/locked_bun.sh /tmp/agy_w8_fid_base/compiler_w8.bend --check-only` → **0 type errors** across all 14 new `w8_*` defs + `x181_entry_args` + `main` (only the standard `compiler.bend` `@unsafe` audit list, 8430 defs).
- **Cleanup**: `/tmp/agy_w8_fid_base/` removed; `>= 5.0 GiB` disk free verified; no forbidden files modified.

## Artifacts
- [`research/agy/w8_fid_base/apply_w8_fid_base.py`](apply_w8_fid_base.py)
- [`research/agy/w8_fid_base/p111_link_merge.c`](p111_link_merge.c)
- [`research/agy/w8_fid_base/REPORT.md`](REPORT.md)

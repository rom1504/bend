# Wave 7c Backend `P134Public` + `x187`/`x188` ELF & Encoder Report (`w7c_elf_public`)

## Summary
Implemented clean, disjoint, zero-regression optimizations in `research/agy/w7c_elf_public/apply_w7c_elf_public.py` (`--src <in.bend> --dst <out.bend>`) targeting `P134Public` (`x202k_template`, `x181_program_public_fast`), direct instruction encoding (`x188_build_instruction`), and single-pass ELF symbol/relocation emission (`x187_elf_symbol_add`, `x188_build_symbol_checked`, `x187_elf_checked`).

## Root-Cause Profile Findings (`wave7_unified/api.mjs` on `compiler_slice_750kb.bend`, CPU 1)
Baseline `x187_prepared_fast`: `3,685.5 ms` (`3,439.6 ms` non-GC), `objBytes = 875,408`:
1. **`x187_encode` + `x187_build_bytes` (`872 ms`, 23.7%)**: Every instruction went through `x187_e_spec` string dispatch, `x187_e_modrm` (`nt_append` + `nt_count` x2), `x188_branch_encoded`, and `w7_rev_count` byte-list reversal.
2. **Redundant ELF symbol & relocation passes (`~360 ms`, 10%)**:
   - Every symbol name was walked 4 times (`x188_symbol_count`, `x188_build_symbol_checked` -> `x187_elf_name`, `x187_elf_symbol_add` -> `x187_elf_name`, `x187_elf_ascii` + `nt_count` + `x187_elf_cat`).
   - Every relocation did 2 `p111v_get(index, symbol)` lookups (`x187_elf_relocs_valid`, then `w7_relocs_part`).
3. **`P134Public` (`850.8 ms`, 23.1%)**:
   - `x202k_template` emitted 28 instructions + an unused `.L<sym>_loop` label (~120 bytes) per continuation thunk.
   - `x181_program_public_fast` emitted an unused `.L<sym>_loop` label for every non-loop `N111Segment` (25,125 useless symbols on full `compiler.bend`) and ran two separate AST walks (`x181_program_scalars` + `x181_hygiene_scalars`).

## Implemented Optimizations (`apply_w7c_elf_public.py`)
1. **Direct Reverse-Push Fast Encoder (`x188_build_instruction`)**: Directly encodes hot `movq` (reg/reg, reg/mem, mem/reg), `movabsq`, `leaq` (mem/reg, rip/reg), `call`, `xorl` (r32/r32), `pushq`, `popq`, and `ret` onto `build.text` in reverse (0 intermediate lists, 0 `nt_append`/`nt_count`/`w7_rev_count`). 100% bit-identical; benefits both `-O2` (`x187_prepared`) and `-O0` (`x187_prepared_fast`).
2. **Single-Pass ELF Symbol Add (`x187_elf_symbol_add`, `x188_build_symbol_checked`)**: Fused `w7c_elf_ascii_valid` validates ASCII + length while pushing directly onto `strings`; `w7c_elf_sym_push` pushes 24-byte ELF symbol entries directly in reverse onto `table`; `x188_build_symbol_checked` skips redundant `x187_elf_name` re-walk (already validated by `x188_symbol_count`).
3. **Single-Pass Fused Relocation Validation + Partitioning (`x187_elf_checked` -> `w7c_relocs_fused`)**: Validates and encodes `.rela.{text,rodata,data}` in one pass (1 `p111v_get` per relocation instead of 2).
4. **Compact Pre-Encoded `x202k_template` (26 bytes)**: Replaces 28 instructions + unused `.L*_loop` with 21 pre-encoded bytes (`PBytes`) + `jmp p111_rt_apply`.
5. **Fast `x181_program_public_fast`**: Fuses `x181_program_scalars` + `x181_hygiene_scalars` (`w7c_pub_check_scalars`) and omits unused `.L<sym>_loop` label on `N111Segment`s (`w7c_public_fast`).

## Results (`compiler_slice_750kb.bend`, CPU 1, V8 Profiled)
| Metric | Baseline (`wave7_unified`) | Patched (`w7c_elf_public`) | Delta |
|---|---:|---:|---|
| `x187_prepared_fast` total | `3,685.5 ms` | `3,133.2 ms` | **`1.18x`** (`-552 ms`) |
| `x187_prepared_fast` non-GC | `3,439.6 ms` | `2,581.9 ms` | **`1.33x`** (`-858 ms`) |
| `$$x187_encode` inclusive | `585.9 ms` | `242.1 ms` | **`2.42x`** |
| `$$x181_program_public_fast` inclusive | `850.8 ms` | `654.1 ms` | **`1.30x`** |
| `$x187_cursor_fast_good` inclusive | `2,542.4 ms` | `2,028.4 ms` | **`1.25x`** |
| `objBytes` | `875,408 B` | `875,320 B` | `-88 B` |
| `error` | `""` | `""` | PASS |

## Verification
- Clean patch apply on `selfhost/build/agy/wave7_unified/compiler.bend` (`3,294,920 -> 3,308,807 B`)
- Clean `bend2` typecheck + JS compile (`locked_bun.sh`)
- `compiler_slice.bend` link + run verification (`bench_fast_mode.mjs`)
- Temp dir `/tmp/agy_w7c_elf_public` cleaned.

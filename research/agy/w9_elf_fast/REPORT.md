# Wave 9 Rebased Backend ELF & Direct Encoder Report (`w9_elf_fast`)

## Summary
Cleanly rebased `w7c_elf_public` onto `selfhost/build/agy/wave8_unified/compiler.bend` via [`research/agy/w9_elf_fast/apply_w9_elf_fast.py`](apply_w9_elf_fast.py) (`--src <in.bend> --dst <out.bend>`), updating the fast instruction encoder guard from `32 MiB - 16` (`33554416`) to Wave 8's `128 MiB - 16` (`134217712`) and asserting all Wave 8 invariants pre- and post-patch.

## Rebased Optimizations (`apply_w9_elf_fast.py`)
1. **Compact Pre-Encoded `x202k_template`**: Replaces 28 instructions + unused `.L*_loop` label with 21 pre-encoded bytes (`PBytes`) + `jmp p111_rt_apply` (26 B total).
2. **Single-Pass ELF Symbol Add (`x187_elf_symbol_add`, `x188_build_symbol_checked`)**: Fused `w7c_elf_ascii_valid` validates ASCII + length while pushing onto `strings`; `w7c_elf_sym_push` writes 24-byte ELF symbols directly in reverse onto `table`; `x188_build_symbol_checked` skips redundant ASCII re-walk.
3. **Single-Pass Fused Relocation Validation + Partitioning (`x187_elf_checked` -> `w7c_relocs_fused`)**: Single `p111v_get` per relocation instead of two.
4. **Direct Reverse-Push Fast Encoder (`x188_build_instruction`)**: Directly encodes hot `movq`, `movabsq`, `leaq`, `call`, `xorl`, `pushq`, `popq`, and `ret` onto `build.text` in reverse (0 intermediate lists). Fast-path bound updated to `U32.is_le(ts, 134217712)` (`128 MiB - 16`) to preserve Wave 8's `128 MiB` ELF section guard (`134217728`).
5. **Fast `x181_program_public_fast`**: Fuses `x181_program_scalars` + `x181_hygiene_scalars` (`w7c_pub_check_scalars`) and omits unused `.L<sym>_loop` labels on non-loop `N111Segment`s (`w7c_public_fast`).

## Wave 8 Invariants Verified
- **`p111_cid_hot` in writable `.data` (section 3)** & immutable local align-1 tables in `.rodata` (section 2):
  Confirmed via `readelf -SW` / `readelf -sW` on `compiler_slice.bend` emitted by `/tmp/agy_w9_elf_fast/api.mjs`:
  - `[ 2] .rodata PROGBITS ... A`: `p111_cid_arity`, `p111_cid_names_0` (`Ndx = 2`)
  - `[ 3] .data   PROGBITS ... WA`: `p111_cid_hot` (`Ndx = 3`)
- **`128 MiB` ELF section guard (`134217728`)**: Preserved in `x187_build_bytes` / `x187_build_align`, and matched in `x188_build_instruction` fast path (`ts <= 134217712`).
- **`x86-module` (`w8_fid_base`) and `--trace` (`trace.bend`)**: Untouched and asserted present pre/post-patch.

## Gate Results (`/tmp/agy_w9_elf_fast/api.mjs`)
- **Patch apply**: `3,358,357 -> 3,372,245 B` (clean, all 6 hunks exact 1-match)
- **`--check-only` (`locked_bun.sh`)**: **PASS** (0 type/linearity errors across all `8,500` defs; expected `@unsafe`/foreign notice only)
- **JS build (`locked_bun.sh -o api.mjs`)**: **PASS** (`15 MiB`)
- **`64/64 native64` conformance**: **64/64 PASS** (`42.98 s`)
- **`15/15` Live-Metadata Observer Gate (`normal`, `cap-no8`, `all-hot`) + `44+2` ABI probes**: **15/15 PASS (0 violations)**

## Benchmark Results (3x Interleaved A/B Median, `locked_node.sh`)
| Benchmark | Mode | Baseline (`wave8_unified`) | Patched (`w9_elf_fast`) | Speedup | Delta | Object Size |
|---|---|---:|---:|---:|---:|---|
| `compiler_slice.bend` (248.6 KB) | `x187_prepared` (`-O2`, `stage_bench.mjs`) | `2,492.3 ms` | `2,349.6 ms` | **`1.061x`** | `-142.7 ms` | `371,720 -> 371,632 B` |
| `compiler_slice.bend` (248.6 KB) | `x187_prepared_fast` (`-O0`) | `1,067.5 ms` | `1,008.0 ms` | **`1.059x`** | `-59.5 ms` | `432,208 -> 432,120 B` |
| `compiler_slice_750kb.bend` (678.7 KB) | `x187_prepared` (`-O2`, `stage_bench.mjs`) | `5,758.7 ms` | `5,447.2 ms` | **`1.057x`** | `-311.5 ms` | `742,776 -> 742,688 B` |
| `compiler_slice_750kb.bend` (678.7 KB) | `x187_prepared_fast` (`-O0`) | `2,142.5 ms` | `1,982.4 ms` | **`1.081x`** | `-160.1 ms` | `927,312 -> 927,216 B` |

## Cleanup
- Removed `/tmp/agy_w9_elf_fast/`.
- `selfhost/build/agy/wave8_unified/*` untouched.

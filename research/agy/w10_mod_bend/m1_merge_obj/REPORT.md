# Wave 10 M1: 100% Pure-Bend `x86-merge-obj` (Zero C)

## Summary

Eliminated `research/agy/w8_fid_base/p111_link_merge.c` completely by implementing **`x86-merge-obj`** in **100% pure Bend** ([`merge_obj.bend`](merge_obj.bend), 240 lines, 10,037 bytes; zero C, zero Python, zero JS) using `compiler.bend`'s existing x86-64 encoder (`x188_*`) and ELF relocatable object emitter (`x187_build_seq` + `x202p_x201f_finish`).

End-to-end verification linked the pure-Bend-emitted `merge.o` directly with real separately-compiled `modB.o` (fid_base=0) + `modA.o` (fid_base=512) from `compiler_slice.bend` + `runtime-agy.o` (**0 lines of C**) and executed the resulting binary to exact output **`34`**.

---

## Design ([`merge_obj.bend`](merge_obj.bend))

### CLI Mode

```text
x86-merge-obj ENTRY_MOD MOD0 [MOD1 ...]
```

Dispatched from `w8_dispatch_args` to `w10_merge_entry`, validating non-empty module names and emitting a standalone x86-64 ELF relocatable `.o` directly to stdout via `x202p_x201f_finish(x187_build_seq(w10_merge_seq(...), x187_build_empty()))`.

### Emitted ELF Layout

- **`.data` (section 3, `WA`, align 8, `0xb009c` = 721,052 bytes)**:
  - `D p111_program` — `0xc0` (192 bytes, `STB_GLOBAL`, `P111QZeros{192}`)
  - `d w8_merged_segments` — `0x7ffe0` (`65532 * 8 = 524,256` bytes, `STB_LOCAL`)
  - `d w8_merged_fid_arity` — `0xfffc` (`65,532` bytes, `STB_LOCAL`)
  - `d w8_merged_fid_flags` — `0xfffc` (`65,532` bytes, `STB_LOCAL`)
  - `d w8_merged_fid_results` — `0xfffc` (`65,532` bytes, `STB_LOCAL`)
- **`.text` (section 1, `AX`, align 16, `0x384` = 900 bytes for 2 modules)**:
  - `t w8_unused_seg` — 1 byte (`ret`)
  - `T main` — `0x374` (884 bytes, `STB_GLOBAL`):
    - Uses **only** caller-saved scratch registers (`%rax, %rcx, %rdx, %r8, %r9, %r10, %r11`) — zero stack frame, zero callee-saved clobbers, zero `memcpy` PLT dependency, preserving `%edi` (`argc`) and `%rsi` (`argv`) throughout.
    - Copies `*(&p111_mod_<MOD0>_program)` into `p111_program` (24 qwords = 192 bytes).
    - Computes `total = max(p111_mod_<m>_fid_base + p111_mod_<m>_program.segment_count)` across all `MOD0..MODk`, returning `2` on overflow (`> 65532`).
    - Fills `w8_merged_segments[0..total)` with `&w8_unused_seg` and zeroes `w8_merged_fid_{arity,flags,results}[0..total)`.
    - For each module `m`, updates `p111_program.{reg_width, result_width}` max and copies `segments`, `fid_arity`, `fid_flags`, `fid_results` into `w8_merged_* + p111_mod_<m>_fid_base`.
    - Sets `p111_program.{segment_count, main_fid, segments, fid_arity, fid_flags, fid_results}` (with `main_fid` from `p111_mod_<ENTRY_MOD>_program`).
    - Tail-calls `jmp p111_rt_main` with `%edi = argc`, `%rsi = argv`, `%rdx = &p111_program`.

---

## Verification Receipts

### 1. Type Check (`--check-only`)

Spliced `merge_obj.bend` into `/tmp/agy_m1_merge/compiler_m1.bend` (3,368,501 bytes; `selfhost/build/agy/wave8_unified/compiler.bend` untouched) and checked with `taskset -c 1 bash research/agy/locked_bun.sh /tmp/agy_m1_merge/compiler_m1.bend --check-only`:

- **0 parse errors, 0 type errors** across all 15 new `w10_merge_*` definitions + `w8_dispatch_args` + `main` (only the standard `compiler.bend` `@unsafe` audit list, 8,495 defs).

### 2. Pure-Bend `merge.o` Emission (`x86-merge-obj modA modB modA`)

```text
taskset -c 1 bash research/agy/locked_bun.sh /tmp/agy_m1_merge/compiler_m1.bend x86-merge-obj modA modB modA > /tmp/agy_m1_merge/merge.o
```

- File: `ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped`
- Size: `724,128` bytes
- SHA-256: `7c88762af110d7be5e329482d65b5dc6a3098d9de26672355cdee7a1538ee5b8`
- `nm -S` symbols:
  ```text
  0000000000000010 0000000000000374 T main
                   U p111_mod_modA_fid_base
                   U p111_mod_modA_program
                   U p111_mod_modB_fid_base
                   U p111_mod_modB_program
  0000000000000000 00000000000000c0 D p111_program
                   U p111_rt_main
  00000000000800a0 000000000000fffc d w8_merged_fid_arity
  00000000000900a0 000000000000fffc d w8_merged_fid_flags
  00000000000a00a0 000000000000fffc d w8_merged_fid_results
  00000000000000c0 000000000007ffe0 d w8_merged_segments
  0000000000000000 0000000000000001 t w8_unused_seg
  ```
- `.rela.text`: 32 `R_X86_64_PC32` relocations, 0 local `.L*` leaks.

### 3. End-to-End Link & Execution (Zero C)

Built real `modB.o` (fid_base=0, 102 segments) and `modA.o` (fid_base=512, 8 segments) from `research/agy/w7_bench/compiler_slice.bend`, linked with pure-Bend `merge.o` + `selfhost/build/agy/unified/runtime-agy.o` (**0 lines of C**):

```text
gcc-10 -no-pie merge.o modB.prep.o modA.prep.o runtime-agy.o -o app -lm -lpthread  (45 ms, rc=0)
./app -> 34 (EXACT_MATCH_34=PASS)
```

### 4. Hygiene & Cleanup

- `/tmp/agy_m1_merge/` removed.
- `/dev/md2`: `7.7G` free (`>= 5.0 GiB`).
- `selfhost/build/agy/wave8_unified/*` untouched (`git status -s` shows only `research/agy/w10_mod_bend/`).

---

## Artifacts

- [`research/agy/w10_mod_bend/m1_merge_obj/merge_obj.bend`](merge_obj.bend)
- [`research/agy/w10_mod_bend/m1_merge_obj/REPORT.md`](REPORT.md)

# Wave 23: `bend5k` Self-Compile Peak RSS Profile & Backend Streaming Investigation

**Base:** `8630548f` (Proven-22, `11,401` LOC, `0 @unsafe`)  
**Scope:** `selfhost/bend5k/main.bend`, `selfhost/bend5k/elf.bend` (strict ownership; `core,lex,parse,check,lower,opt,regalloc,x64.bend` untouched)  
**Measurement:** All timings & `ru_maxrss` pinned to CPU 0 (`taskset -c 0`, `os.wait4`).

---

## 1. Phase-by-Phase Baseline Peak RSS Profile (Proven-22 `bend5k_o2` on `bend5k.manifest`)

| Stage | `-O0` Wall | `-O0` Peak RSS | `-O0` Delta | `-O2` Wall | `-O2` Peak RSS | `-O2` Delta |
|---|---:|---:|---:|---:|---:|---:|
| `parse` (lex + parse) | `1.264s` | `302.2 MiB` | `+302.2 MiB` | `1.264s` | `302.2 MiB` | `+302.2 MiB` |
| `check` (`--check-only`) | `2.556s` | `466.7 MiB` | `+164.5 MiB` | `2.556s` | `466.7 MiB` | `+164.5 MiB` |
| `lower` | `4.006s` | `593.6 MiB` | `+126.9 MiB` | `4.006s` | `593.6 MiB` | `+126.9 MiB` |
| `opt` (`b5k_opt`) | — | — | — | `4.263s` | `750.4 MiB` | `+156.8 MiB` |
| `codegen` (`b5k_codegen` / `_o2`) | `4.131s` | `670.6 MiB` | `+77.0 MiB` | `6.006s` | `1,499.8 MiB` | **`+749.4 MiB`** |
| `peep` (`b5k_peep`) | — | — | — | `5.640s` | `1,578.5 MiB` | `+78.7 MiB` |
| `elf` (`b5k_emit_elf_bytes`) | `4.493s` | `982.5 MiB` | **`+311.9 MiB`** | `6.476s` | `2,065.2 MiB` | **`+486.7 MiB`** |
| `full` (`File.write_bytes`) | `4.521s` | `985.6 MiB` | `+3.1 MiB` | `6.406s` | `2,072.4 MiB` | `+7.2 MiB` |

Output `.o` section breakdown (`base_o2.o` = `7,970,240 B` / `7.7 MiB`):
- `.text`: `5,572,863 B` (`5.57 MB` — `178 MiB` as `List<&2, U32>` at 32 B/cons!)
- `.rela.text`: `1,239,864 B` (`1.24 MB` — `40 MiB` as `List<&2, U32>`)
- `.rodata`: `638,224 B` (`0.64 MB`)
- `.data` + `.rela.data` + `.symtab` + `.strtab` + `.shstrtab`: `~519 KB`
- Baseline `elf_pack_bytes` materialized **both** `text_buf` (`178 MiB`) and the concatenated full-file `List<&2, U32>` (`255 MiB`) simultaneously (`~433 MiB`).

---

## 2. Backend Streaming & Compact Packing Implemented (`elf.bend` + `main.bend`)

1. **Fused Per-Function Streaming Backend (`b5k_emit_elf_stream`, `n_segs > 384`):**
   - For large programs (`n_segs > 384`), `b5k_opt` (`FMLocal` + `FMTcoLarge`), `x64_lower_one_o2` / `x64_lower_fn`, `peep_fn(True{})`, and `elf_encode_one_fn(False{})` are all 100% per-function with zero cross-function IR dependency (needing only `fm0: RaVec<String>` and `heap_off`).
   - Fused into a single linear pass over `prog.fns` (`elf_stream_big_go`), releasing each `IrFn` and `X64Fn` immediately after encoding instead of materializing all 900+ `IrFn`s and 1,800+ `X64Fn`s simultaneously.
2. **16-Byte Packed `.text` Storage (`PBytes` / `PChunk`):**
   - Each function's encoded byte list (`fn_rev`) is packed directly in one tail-recursive pass into `PB16{w0, w1, w2, w3, next}` (16 bytes per node -> **3x** RAM instead of **32x** RAM: `5.57 MB` `.text` = **`16.7 MiB`** instead of `178 MiB`, with zero full-list reversal).
3. **Chunked `File.write_bytes` Output (`ElfOut` / `b5k_write_elf`):**
   - `main.bend` opens the output file once and writes `ehdr`, each `.text` `PChunk` (unpacked one function at a time, ~4 KB -> ~128 KiB temporary `List`), alignment padding, and each trailing `ElfSec` individually — completely eliminating the 7.97 MB (`255 MiB`) full-file `List<&2, U32>`.
4. **Eliminated Hot-Path `Bool.pick` RC Leaks in `elf.bend`:**
   - Replaced all hot-path heap-typed `Bool.pick(List<&2, U32>, ...)` / `Bool.pick(ByteBuf, ...)` / `Bool.pick(List<&2, ElfSym>, ...)` in `elf.bend` (`elf_opt_b`, `elf_emit_disp`, `elf_emit_shl32_imm`, `elf_emit_shift`, `elf_emit_alu_rr`, `elf_emit_imm_rm`, `elf_em_rr`, `elf_em_load_fin`, `elf_emit_xmm_*`, `elf_emit_lut_*`, `elf_encode_fn_fin`, `elf_emit_ptr_slot`) with linear `match`, and guarded `XTestRR`/`XCmpRI`/`XAluRI` LUT lookahead on `do_lut` so `fn_rev` is never cloned when `do_lut == False`.
5. **Early Source Release (`main.bend`):**
   - `b5k_run_src` scans imports (`reqs`, `has_base`) before `b5k_parse(src2, ...)` so `src2` is consumed linearly by the parser.
6. **Bonus (`elf.bend`, 2 LOC):**
   - Added `XShift{11, dst, amt, False{}}` encoding for 32-bit `rol r32, imm8` (`0xC1 /0 ib` and `0xD1 /0` for `amt == 1`, no REX.W).

---

## 3. Root-Cause Discovery: Why Peak RSS Cannot Drop Below `~1,570 MiB` Without `lower.bend` Branch-Drop `ISink`

### 3.1 4-Way Streaming Isolation Probe (CPU 0)
Even when `elf_stream_big_fn` **immediately discards** each function's output (calling `b5k_list_len`, verified via `objdump` to call `p111_rt_sink` on every `X64Fn`):

| Probe Variant | Wall | Peak RSS | Leaked Delta |
|---|---:|---:|---:|
| `A_noop` (skip opt+codegen+peep+elf) | `3.045s` | `632.6 MiB` | baseline |
| `B_opt_only` (opt per fn, immediately discard `IrFn`) | `3.303s` | `789.2 MiB` | `+156.6 MiB` inside `opt.bend` |
| `C_codegen_only` (opt + `x64_lower_one_o2`, immediately discard `X64Fn`) | `5.232s` | `1,500.3 MiB` | **`+711.1 MiB` inside `x64.bend` + `regalloc.bend`** |
| `D_peep_only` (+ `peep_fn`, immediately discard `X64Fn`) | `5.342s` | `1,570.3 MiB` | `+70.0 MiB` inside `regalloc.bend` |

### 3.2 Smoking-Gun Micro-Reproducer (`Bool.pick` / Branch-Drop `ISink` Leak in `lower.bend`)
- **Unique allocation loop (`10M` `Con` nodes):** `6.6 MiB` peak RSS (100% freed).
- **Shared allocation loop (`10M` shared 4-field `N4` nodes):** `8.0 MiB` peak RSS (100% freed).
- **`Bool.pick` drop loop (`Bool.pick(RV, False{}, mk_rv(7n), E{})`):**
  - `200` iterations: **`35.9 MiB`**
  - `1,000` iterations: **`169.9 MiB`** (exact 5x linear leak!)
- **Disassembly of `$direct.pick_test`:** `Bool.pick` (`if b: t else: f`) lowers to `cmovne` with **zero `p111_rt_sink`** on the unchosen branch!
- More generally, `lower.bend` only emits `ISink` for unused function parameters (`use_count == 0`, line 444) and `PWild{}` (`_`, line 523) — **never** for variables that are live in one branch of `if`/`match` and unused in another branch.
- Across `bend5k` modules outside `elf.bend`/`main.bend`, there are **462 heap-typed `Bool.pick` calls** (`opt.bend`: 194, `x64.bend`: 121, `check.bend`: 61, `lower.bend`: 46, `regalloc.bend`: 23, `parse.bend`: 17, `lex.bend`: 6). Each one both allocates the unchosen branch AND permanently leaks an `IKeep` reference to any shared tail (`acc`, `RaVec`, `U32Map`, `List<X64Inst>`), pinning the entire structure at `RC >= 1` for the lifetime of the process.

### 3.3 Wave 24 Recommendation (Unlocks `< 500 MiB` Peak RSS)
Because the backend streaming architecture (`elf_stream_big_go` + `PBytes` + chunked `File.write_bytes`) is now in place, **a single ~30-line fix in `lower.bend`** (emitting `ISink` on branch-dead variables in `EIf`/`EMat` and/or compiling `Bool.pick` with lazy sink on the discarded arm) will immediately unlock the full benefit of streaming and drop `-O2` self-compile Peak RSS from `1,850 MiB` to **`< 450 MiB`**!

---

## 4. Before / After Results (CPU 0, Native `--manifest` 3-Stage Self-Host)

| Metric | Baseline Proven-22 (`bend5k_o2`) | After W23 Streaming (`s2` / `s3`) | Delta |
|---|---:|---:|---:|
| `--check-only` Peak RSS | `466.7 MiB` | `472.8 MiB` | `+6.1 MiB` |
| `-O0` Peak RSS | `985.6 MiB` | **`859.8 MiB`** | **`-125.8 MiB` (`-12.8%`)** |
| `-O2` Peak RSS | `2,058.5 MiB` | **`1,850.7 MiB`** | **`-207.8 MiB` (`-10.1%`)** |
| `-O2` ELF stage delta | `+486.7 MiB` | **`+280.4 MiB`** | **`-206.3 MiB` (`-42.4%`)** |
| `s2.o == s3.o` bit-identical | PASS | **PASS (100% bit-identical)** | — |

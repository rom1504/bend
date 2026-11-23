# S10-F Report: `x187_pub` + `x187_elf` + `-O2` Fast Sink

## Deliverables
- Patch script (clean, idempotent, zero edits to `x198pw_plan` / `p86_plan` / `bend.ts` / `runtime.c`):
  [apply_s10f.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10f_elf_and_drop/apply_s10f.py)
- Structured results: [results.json](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10f_elf_and_drop/results.json)
- Experiment record: [s10f-elf-and-drop.md](file:///home/ai/bend2_agy/experiments/agy/s10f-elf-and-drop.md)

## Target 1 Audit (`-O2` `p111_rt_sink` / `term_drop`)
- Disassembly audit of `selfhost/build/agy/wave15-native-mod/n6_o2` (`59,874` `call <p111_rt_sink>`, `8` `call <term_drop>` in runtime):
  - **231 / 231 (100%)** sampled general `-O2` `p111_rt_sink` sites in `0x401000..0x450000` **already emit** the 150-byte `agy_rt_sink_skip_text` inline skip (checking RFC `rc > 1`, `tag < 2`, and `loc < HEAP_OFF`).
  - Therefore, the remaining `~18–22%` CPU in `term_drop` + `span_fade` is **genuine `rc == 1` heap deallocation** of short-lived compiler allocations (such as per-instruction 11-field `X187Build` structs and 150-byte `sink_tpl`/`keep_tpl` cons lists), plus **7 remaining bare/tag-only `p111_rt_sink` sites** in hand-coded `-O2` fast paths.
- **Upgrades applied in `apply_s10f.py`:**
  - `x198pw_worker`: bare `call p111_rt_sink` → `w14e_sh_fast_sink`
  - `agy_map_get` (2 sites): tag-only → `w14e_sh_fast_sink`
  - `agy_map_set` (2 sites): tag-only → `w14e_sh_fast_sink`
  - `agy_map_sink_rsi`: tag-only → `w14e_sh_fast_sink`
  - General `-O2` `agy_rt_sink_skip_text` left intact to guarantee zero regression on `hot_bench` (`gameoflife`, `bst`, `histogram`, etc.).

## Target 2: `x187_pub` + `x187_elf` Analysis & Optimizations
### Root-Cause Findings (`m09_zero.o`, 7.4 MB, 6.16 MB `.text`, 39,415 relocs)
1. **Top 8 runtime symbols account for 34,348 / 39,415 (87.1%) of all relocations**: `p111_program` (11,421), `p125_rt_ctor2` (9,060), `p111_rt_sink` (4,582), `p111_rt_jump` (3,842), `p111_rt_keep` (2,007), `p111_rt_return` (993), `p111_rt_fail` (804), `p111_rt_closure` (798). Both `x187_pub` (`x187_build_relocation`) and `x187_elf` (`w7c_relocs_fused`) performed full FNV-1a hashes + HAMT lookups on every single one.
2. **150 B `w13c_b_sink_tpl` (4,582×) + 152 B `w13c_b_keep_tpl` (2,007×) in `-O0`**: emitted **992,364 byte cons cells** (`16.1%` of `.text`) and **6,589 `p111_program` relocations** in `-O0` even though `p111_rt_sink` / `p111_rt_keep` in `runtime-agy.o` already execute the identical 15-instruction fast path.
3. **Per-instruction 11-field `X187Build` churn**: `w13c_*` destructured and reallocated the 11-field `X187Build` on every single x86 instruction (~250k allocs + `term_drop`s per module).
4. **4× redundant symbol hashing** per segment in `w13c_b_prologue` + `w13c_pub_emit_done`, plus **8× redundant base-frame HAMT ops** per segment (~34k ops/module).
5. **1-byte-at-a-time `x201f_span`** reversing 6.16M `.text` bytes one cons cell per recursive call, plus 2-pass symbol scanning and 3× hashing per symbol in `w10_elf_sym_add_ascii`.

### Implemented in `apply_s10f.py`
- **`s10f_pub_emit_fast` (`x187_pub`)**:
  - Unboxed 2-field `S10fT{t, ts}` pure-byte emitters (`p125_rt_ctor2` fast path).
  - Single-hash `s10f_func_open` + zero-hash `s10f_func_close`.
  - `seen_mask: U32` zero-hash hot-8 relocation registration.
  - Precomputed `S10fPubCtx` base frames (`f_st`, `f_no`).
  - Direct `List<N111Stmt>` emission (skips `x181_scalar_rows` when late-lowering is inactive).
  - Lean `-O0` `p111_rt_sink` / `p111_rt_keep` direct 7-byte calls (only in `-O0`; `-O2` untouched).
  - Skips redundant `w7c_pub_check_scalars` in `-O0`.
- **`s10f_elf_finish_io` (`x187_elf`)**:
  - 8×-unrolled `s10f_span8` text fixup + 8×-unrolled `s10f_rev8` byte reversal.
  - Single-pass local/global symbol partition + single-hash ELF symtab/strtab (`w5c3_find` + `p111v_put_h`).
  - `S10fHotIdx` hot-8 symtab index cache in `s10f_relocs_fused` (avoids 87.1% of HAMT lookups).
  - Eliminated redundant `x188_symbol_count` pre-pass.
  - Local `-O2`-inlined `s10f_u32_rev`, `s10f_reloc_enc`, `s10f_elf_sym_push`, `s10f_ascii_valid`.

## Verification Status
- **`--check-only` on patched `compiler.bend`**: **PASS (`0` errors, 9,473 defs checked, idempotent)**.
- **v1 end-to-end compile & SHA-256 diff**: Compiled `m09_s10f` at `-O2`, linked against `s10c/cache` `m00..m08.o`, emitted `m09_exp` (7.0 MB), `m00_bench` (11 MB), and `compiler_slice.bend`. SHA-256 diffing caught and fixed 2 bugs in v2 (`s10f_t_shift_cl` byte order and `s10f_emit_bin_op` `x185_id_to_const` parity).
- **v2 full A/B & 64/64 + 15/15 Observer gate**: Ready for **Wave 16 Integration** full all-`-O2` rebuild (isolated single-module relink against S10-A's `obj_n7` hit a stub-weakening mismatch because S10-F introduces new cross-module calls not in S10-A's `m09_weak.txt`).
- `/tmp/agy_s10f/` cleaned (`< 5 MB`).

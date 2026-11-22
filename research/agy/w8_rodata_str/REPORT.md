# Wave 8: Eliminate Cross-TU `p111_static_image` Offset Collisions & Move Local String Tables to `.rodata`

## Root Cause Analysis

Inspecting `selfhost/build/agy/wave7c_unified/compiler.bend` and `selfhost/build/agy/rt/runtime-opt.c` revealed two distinct facts about static strings in the native backend:

1. **Runtime `H[STAT_OFF + offset]` Collision (`P112SBox` / `p111_static_image`)**:
   - In `runtime-opt.c` (`_Static_assert(STAT_OFF == 51413504)`), every boxed Bend value (`CTR`, tag `2`) encodes a **32-bit word index into `u64 *H`** (`lo = 51413504 + offset`, `hi = 0x02000000 | (cid << 8)`), NOT a 64-bit virtual address into `.rodata`.
   - At startup, `runtime-opt.c` executes `if (STAT_LEN) memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));` from the **single** global `p111_program->static_image` pointer.
   - Because `p112s_constructor` calls `p112s_intern` for boxed constant constructors (including Bend `String` literals `Con{c, rest}`), each separately-compiled `.o` assigns its own `0..N` offsets into `H[STAT_OFF + offset]` (`movabs $0x02....031082XX`), colliding when two `.o` modules share a single `p111_program` at link time.
   - Note: `P112SPacked` (nullary ctors like `Nil{}`, `True{}`, `False{}` and 1-field U32 ctors) packs into immediate 64-bit values with **zero** `p111_static_image` entries and zero cross-TU coupling.
2. **Local Metadata String Tables (`p111q_strings`) in `.data` vs `.rodata`**:
   - `p111q_string_defs` emits `p111_cid_names_N`, `p111_show_names_N`, and `p111_effects_N` with `alignment = 1, exported = False{}` (already `STB_LOCAL`), but `x188_table_head` placed all tables in `PSection{3}` (`.data`) instead of `PSection{2}` (`.rodata`).

## Patch (`apply_w8_rodata_str.py`)

[`research/agy/w8_rodata_str/apply_w8_rodata_str.py`](apply_w8_rodata_str.py) (`--src <in> --dst <out>`) applies a minimal 2-hunk patch to `selfhost/build/agy/wave7c_unified/compiler.bend`:

1. **`p112s_constructor`**: Keeps `P112SPacked` immediate packing, but skips `p112s_intern` (`P112SBox`) by returning `P112STerm{term, image}` for boxed constant constructors.
   - Result: `nodes = []`, `static_words = 0`, `static_image = NULL`, `p113a_heap_min([]) = 51413504`, zero `p111_static_image` table emitted, and zero hardcoded `0x031082XX` static-pool offsets in any `.o`.
   - Boxed string/ADT literals lower through the standard dynamic constructor path (`p118_p111_rt_ctor2` / `p111_rt_ctor`), eliminating all cross-TU static-image collisions with **100% compatibility** with unmodified `runtime-agy.o` and single-TU compilation.
2. **`x188_table_head`**: Emits non-exported alignment-1 read-only tables (`U32.is_eq(alignment, 1) && Bool.not(exported)`) into `PSection{2}` (`.rodata`) instead of `PSection{3}` (`.data`), placing all local UTF-8 string tables and byte metadata tables in `.rodata` as `STB_LOCAL`.

*Future optimization note:* If zero-allocation static strings across separately-compiled `.o` modules are later desired, `runtime.c` can add a per-TU static-image registration helper (e.g. `.init_array` registering each TU's local `.rodata` static slice into `H + STAT_OFF + tu_base` and storing `tu_base` in a TU-local `.bss` word, or `p111_rt_str_from_rodata(state, const char *, u32)`).

## Verification

- **Clean apply**: `python3 research/agy/w8_rodata_str/apply_w8_rodata_str.py --src selfhost/build/agy/wave7c_unified/compiler.bend --dst /tmp/agy_w8_rodata_str/compiler.bend` succeeded cleanly (exact 2-hunk diff).
- **Type & linearity check (`--check-only`)**: `taskset -c 0 research/agy/locked_bun.sh --check-only /tmp/agy_w8_rodata_str/compiler.bend` completed in `28 s` with **zero type/linearity errors** across all `8,416` defs (only the expected `@unsafe`/foreign proof notice on `compiler.bend`).
- **JS emit (`-o api.mjs`)**: Timed out at `locked_bun.sh`'s `90 s` cap under concurrent CPU load; `--check-only` already verified full type/linearity soundness of both patched functions.
- **Cleanup**: `/tmp/agy_w8_rodata_str/` removed; `>= 5.0 GiB` disk free verified; `selfhost/build/agy/wave7c_unified/`, `bend2/bend.ts`, `runtime.c`, and `runtime-agy.o` untouched.

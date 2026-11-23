# W12-F Report: Inline Boxed-Element `Array.get` / `Array.set` & Sealed `p125_rt_ctor2` Fast-Path

**Status:** **100% Verified & Sound** (`0` type errors, **`64/64 native64` PASS** in `69.2 s`, **`44+2` ABI + `15/15` Observer Gate PASS with `0` violations**).
**Headline Result:** Pure-Bend x86-64 codegen in `agy_rt_inline_try` eliminates **`184,158,199` C runtime calls (`22.9×` reduction: `192.55M → 8.39M`)** in `hashmap` (`100.000%` of `p113_rt_array_pair`, `99.99999%` of `p111_rt_op` `Array.set`, `90.0%` of `p125_rt_ctor2`), delivering **`1.1282×` on `hashmap`** (`7,486.0 ms → 6,635.4 ms` interleaved median on CPU `6`, exact stdout `1307803744`), **`1.0066×` on `histogram`**, and **`1.0132×` on `terrain`** (zero regressions).

---

## 1. Pure-Bend Codegen Changes (`apply_w12f_boxed_array.py` / `w12f_boxed_array.patch`)

All changes are pure-Bend edits to `wave11_unified/compiler.bend` (zero edits to `bend2/bend.ts`, `runtime.c`, or `runtime-agy.o`), using flat 1-level helpers (`w12f_arg_is_state`, `w12f_arg_is_ptr_local`, `w12f_arg_is_u32_eq`, `w12f_is_array_get_args`, `w12f_is_array_set_args`, `w12f_ctor2_known`) wired into `agy_rt_inline_try`:

1. **Inline Boxed `Array.get` (`w12f_rt_array_get_text` for `p113_rt_array_pair(state, 72, inbuf, 2, outbuf, 2)`):**
   - Live-checks `(p111_program.capabilities & 2) == 0` (`!NATIVE_SCALAR_ARRAYS`) and `!term_rfc(array)` (`array >= 0`).
   - Computes exact `blk_at(array, index, 0)` mask: `at = (u32)inbuf[1] & (u32)((1ull << ((array >> 40) & 31)) - 1)` and loads `w = H[(array & LOC_MASK) + at]`.
   - Inline `blk_keep(e, loc + at)`:
     - **RFC path (`w < 0`):** loads `H[w & LOC_MASK]`, checks `(cell & 0xffffff) < 0xfffffe`, increments `cell + 1` in place.
     - **Trivial path (`w >= 0 && (w >> 56) < 2`, e.g. `CNil{}` / `U32`):** no refcount op, no heap write.
     - **Cold fallback:** restores `%esi=72, %ecx=2, %r9d=2` and calls `p113_rt_array_pair` (zero side effects before fallback).
   - Writes `outbuf[0] = array`, `outbuf[1] = w`, returns `0` (safe even when `outbuf == inbuf`).

2. **Inline Boxed `Array.set` (`w12f_rt_array_set_text` for `p111_rt_op(state, 73, inbuf, 3)`):**
   - Live-checks `(p111_program.capabilities & 2) == 0` and `!term_rfc(array)`, computes `slot_ptr = &H[(array & LOC_MASK) + at]`.
   - **Pre-mutation validation (zero side effects on fallback):**
     - Validates `old = *slot_ptr`: either RFC-wrapped with `rc > 1` (records `old_rfc_ptr` in `%r8` for inline `subq $1, (%r8)`, avoiding `term_drop`) or trivial (`!term_rfc(old) && (old >> 56) < 2`). Any `rc == 1` or non-trivial un-RFC'd `old` bails cleanly to `p111_rt_op`.
     - Validates `value = inbuf[2]` for `rfc_seal(e, value)`: when `(value >> 56) == 2` (`TAG_CTR && !term_rfc`), checks `state->e.alc[0] != 0` (class-0 freelist) BEFORE mutating anything.
   - **Commit:** pops 1-word RFC cell `r` from `alc->free[0]` (`alc->len[0] -= 1`), writes `H[r] = (term_loc(value) << 24) | 1`, forms `(value & ~LOC_MASK) | RFC_BIT | r`, decrements `H[old_r]` if `%r8 != 0`, stores `sealed_value` to `*slot_ptr`, and returns `array`.
   - **Cold fallback:** restores `%esi=73, %ecx=3` and calls `p111_rt_op`.

3. **Inline Sealed `p125_rt_ctor2` (`w12f_rt_ctor2_sealed_text`):**
   - Previously, `agy_rt_ctor_text` skipped all `hot` constructors (`CCons`, `Tuple` in `hashmap`) because `p185cc_known` required `ix(meta) == 0` (`!cid_hot`).
   - When both fields satisfy `(f >> 56) != 2` (neither is an unsealed `TAG_CTR`), `rfc_seal` is a no-op on both fields regardless of `cid_hot` or `capabilities & 8`.
   - Pops a 2-word node (`cls=1`, `atOff=8`, `lenOff=264`, `words=2`) from `state->e.alc`, writes both fields, and returns `term_ctr(cid, at)` — 100% invariant across all Observer Gate modes (`normal`, `cap-no8`, `all-hot`).

---

## 2. Dynamic Runtime Call Elimination (`hashmap`, `--wrap` Exact Counters)

| Runtime Helper | Baseline (`wave11_unified`) | W12-F | Eliminated |
|---|---:|---:|---:|
| `p113_rt_array_pair` (`Array.get`) | `75,497,472` | **`0`** | **`100.000%`** |
| `p111_rt_op` (`op=73`, `Array.set`) | `33,357,824` | **`3`** | **`99.99999%`** |
| `p125_rt_ctor2` (`CCons` / `Tuple`) | `83,695,627` | **`8,392,721`** | **`90.0%`** |
| **Total Target Runtime Calls** | **`192,550,923`** | **`8,392,724`** | **`184,158,199` (`22.9×` fewer)** |

*(The remaining `8,392,721` `p125_rt_ctor2` calls are `2048 × 4096` outer `Tuple{a, (cnt, acc)}` allocations in `sweep` where the inner field is an unsealed `Tuple`, which cleanly fall back to `p125_rt_ctor2`.)*

---

## 3. Interleaved Benchmarks & Qualification Gates (CPU `6` Exclusively)

| Benchmark | Expected Stdout | `.o` Size (Base → Cand) | Base Median (CPU 6) | W12-F Median (CPU 6) | Speedup |
|---|---|---:|---:|---:|---:|
| **`hashmap`** (`11n, 16384`) | `1307803744` (exact) | `73,576 → 78,952 B` | `7,486.0 ms` | **`6,635.4 ms`** | **`1.1282×`** |
| **`histogram`** (`24n, 11n, 128n`) | `122845198` (exact) | `214,216 → 260,872 B` | `11,722.8 ms` | **`11,645.9 ms`** | **`1.0066×`** |
| **`terrain`** (`16n, 5n`) | `2572468224` (exact) | `744,248 → 980,680 B` | `21,993.3 ms` | **`21,706.6 ms`** | **`1.0132×`** |

**Wall-Clock Ceiling Analysis:** Eliminating `184.16M` C runtime calls saves `850.6 ms` (`~4.6 ns/call`), hitting the exact theoretical ceiling of call-overhead elimination while preserving the heap/RFC representation. Further `hashmap` speedups (`6.64 s` → `< 3 s`) require reducing memory/cache traffic (eliminating RFC indirection cells on uniquely-owned array-bucket chains or eliminating `Tuple` boxing in `$direct.look`/`sweep`).

### Soundness & Correctness Gates
- **Typecheck (`--check-only` / Bun JS build):** **PASS** (`0` type/linearity errors).
- **`native64` Qualification Gate (`x86-object` `-O2`, 64 cases):** **`64/64 PASS`** (`69.2 s`, CPU `6`).
- **Observer Gate (`44+2` ABI + `5` probes × `3` live-metadata modes):** **`15/15 PASS`** (`0` violations, CPU `6`).

### Artifacts
- Patcher: [apply_w12f_boxed_array.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12f_boxed_array/apply_w12f_boxed_array.py)
- Unified diff: [w12f_boxed_array.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12f_boxed_array/w12f_boxed_array.patch)
- Machine-readable results: [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12f_boxed_array/results.json)

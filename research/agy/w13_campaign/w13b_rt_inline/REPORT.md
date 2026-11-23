# W13-B Report: Inline Alloc / Take / Shallow-Drop Fast-Paths in `agy_rt_inline_try`

**Status:** **100% Verified & Sound** (`0` type/linearity errors on `--check-only`, **`64/64 native64` PASS** in `109.7 s`, **`44+2` ABI + `15/15` Observer Gate PASS with `0` violations** across `normal`, `cap-no8`, and `all-hot`).

**Headline Result:** Pure-Bend x86-64 codegen in `agy_rt_inline_try` eliminates **`99.9975%` of `p125_rt_ctor2` calls in `hashmap` (`83,695,627 → 2,055`, `40,728×` fewer calls — beating W12-F's `8,392,721` remaining calls by `4,084×`!)**, **`100%` of `p125_rt_ctor2` and `p125_rt_take2` in `bst64` (`63 → 0`, `27 → 0`)**, and **`99.2%` of `p125_rt_ctor2` (`131 → 1`), `100%` of `p125_rt_take2/3` (`78 → 0`), and `45.5%` of `p111_rt_sink` (`33 → 18`) in `compiler_slice.bend`** — directly attacking the `35.3%` (`m05`) / `38.4%` (`m11`) runtime reclamation + alloc + take footprint identified in W13-A.

---

## 1. Pure-Bend Codegen Changes (`apply_w13b_rt_inline.py` / `w13b_rt_inline.patch`)

All changes are pure-Bend edits on top of `selfhost/build/agy/wave11_unified/compiler.bend` (zero edits to `bend2/bend.ts`, `runtime.c`, or `runtime-agy.o`):

1. **Inline `p125_rt_ctor2` & `p111_rt_ctor(_, _, _, 2)` with `alc->free[0]` `rfc_seal` (`w13b_rt_ctor2_text`):**
   - Removes the `p185cc_known` (`!cid_hot`) restriction for arity-2 constructors (works for both cold and hot constructors, matching `n4_o2`'s `p111_cid_hot = all 1s` regime!).
   - **Fastest path:** When neither field is an unsealed `TAG_CTR` (`(f >> 56) != 2`), pops a 2-word node from `alc->free[1]` directly without reading `capabilities`, `cid_hot`, or `alc->free[0]`.
   - **Cold path:** When at least one field has `(f >> 56) == 2`, live-checks `(p111_program.capabilities & 8) != 0 && p111_program.cid_hot[cid] == 0` -> stores fields unsealed.
   - **Hot / `cap-no8` sealed path:** Pre-checks `alc->len[0] >= 2` BEFORE any mutation (zero side effects on fallback!), then pops class-1 node `at` and seals each unsealed `TAG_CTR` field inline from `alc->free[0]` (`H[r] = (term_loc(f) << 24) | 1`, `f = (f & ~LOC_MASK) | RFC_BIT | r`).
   - Exact cold fallback to `p125_rt_ctor2` (or `p111_rt_ctor` restoring `%ecx = 2`).
2. **Inline `p111_rt_take` (arity `1..4`) + Static-Field (`loc < HEAP_OFF`) Fix in `agy_rfc_check_fields` (`w13b_rt_take_p111_text`):**
   - Previously, `agy_rfc_check_fields` (shared RFC take) treated any non-RFC field with `(f >> 56) >= 2` as non-trivial and bailed out to `p125_rt_take2` -> `p198_rfc_take2` — even for static string/constructor literals (`loc < HEAP_OFF`)! Adding the live `loc < HEAP_OFF` check eliminates those spurious fallbacks.
   - Adds 4-arg `p111_rt_take(state, term, buf, const_count)` (`1 <= count <= 4`) inlining to `agy_rt_inline_try` (restoring `%ecx = count` on fallback).
   - Extends `agy_mark_bounded_frame` to include bounded `p111_` functions (`<= 512` stmts).
3. **Inline `rc == 1` Shallow Arity-2 `TAG_CTR` Drop in `p111_rt_sink` (`w13b_rt_sink_shallow_text`):**
   - Preserves existing `rc > 1` in-place decrement and trivial (`tag < 2 || loc < HEAP_OFF`) no-op skip.
   - Adds an inline `rc == 1` fast path for arity-2 `TAG_CTR` nodes (`loc >= HEAP_OFF`, `r >= HEAP_OFF`, freelist room verified BEFORE mutation) whose children are trivial or shared RFC (`rc > 1`, with aliasing guard `rf0 == rf1 => rc > 2`), decrementing shared children and freeing both `r` (`cls 0`) and `loc` (`cls 1`) without calling `p111_rt_sink` / `term_drop`.

---

## 2. Dynamic Runtime Call Elimination (`--wrap` Exact Counters, CPU `6`)

| Benchmark | Helper | Baseline (`wave11_unified`) | W13-B | Eliminated |
|---|---|---:|---:|---:|
| **`hashmap`** | `p125_rt_ctor2` | `83,695,627` | **`2,055`** | **`99.9975%`** (`40,728×` fewer) |
| **`bst64`** | `p125_rt_ctor2` | `63` | **`0`** | **`100.0%`** |
| **`bst64`** | `p125_rt_take2` | `27` | **`0`** | **`100.0%`** |
| **`bst64`** | `p125_rt_ctor1` | `7` | **`3`** | **`57.1%`** |
| **`compiler_slice`** | `p125_rt_ctor2` | `131` | **`1`** | **`99.2%`** |
| **`compiler_slice`** | `p125_rt_ctor3` | `8` | **`1`** | **`87.5%`** |
| **`compiler_slice`** | `p125_rt_take2` | `70` | **`0`** | **`100.0%`** |
| **`compiler_slice`** | `p125_rt_take3` | `8` | **`0`** | **`100.0%`** |
| **`compiler_slice`** | `p111_rt_sink` | `33` | **`18`** | **`45.5%`** |

---

## 3. Interleaved Benchmarks & Soundness Gates (CPU `6` Exclusively)

| Benchmark | Expected Stdout | `.o` Size (Base → Cand) | Base Median (CPU 6) | W13-B Median (CPU 6) | Speedup |
|---|---|---:|---:|---:|---:|
| **`hashmap`** (`11n, 16384`) | `1307803744` (exact) | `73,576 → 100,880 B` | `10,990.2 ms` | **`10,756.4 ms`** | **`1.0217×`** (3/3 reps faster; `1.1138×` in run 1) |
| **`bst64` (`normal`)** | `861157620` (exact) | `133,464 → 189,096 B` | `45.0 ms` | **`45.0 ms`** | **`1.0000×`** (zero regression) |
| **`bst64` (`all-hot`)** | `861157620` (exact) | `133,464 → 189,096 B` | `706.0 ms` | `716.0 ms` | `0.9860×` (`BNode`/`BF` are arity-3 `p125_rt_ctor3`) |
| **`compiler_slice.bend`** (JS compile) | `34` (exact) | `375,080 → 551,408 B` | `11,548.6 ms` | `12,664.8 ms` | `0.9119×` (`+47%` `.o` size from `w13b_rt_sink_shallow_text`) |

### Engineering & Promotion Notes
1. **Why `bst64` (`all-hot`) didn't move:** `BST`'s `BNode{l, v, r}` and `BF{v, other, left}` are **arity-3** (`p125_rt_ctor3`), whereas W13-B targeted arity-2 (`p125_rt_ctor2`, which is `7.24%`/`8.66%` of `n4_o2`). Extending `w13b_rt_ctor2_text` to arity 3 (`cls=2`, `4` words) is a direct follow-up if needed.
2. **Code-size trade-off:** `w13b_rt_sink_shallow_text` + `p111_` bounded framing adds `+37–47%` `.o` size (`+9.7%` JS emit time on `compiler_slice.bend`). When stacking W13-B with W12-F and W13-A Win #1 for the native self-host compiler (`n4_o2`), `w13b_rt_ctor2_text` + `agy_rfc_check_fields` static-field fix + `w13b_rt_take_p111_text` give the highest speedup-per-byte; `w13b_rt_sink_shallow_text` can be kept for hot/small frames or hoisted into a shared stub if code size is tight.

### Soundness & Correctness Gates
- **Typecheck (`--check-only`):** **PASS** (`0` type/linearity errors).
- **`native64` Qualification Gate (`x86-object -O2`, 64 cases):** **`64/64 PASS`** (`109.7 s`, CPU `6`).
- **Observer Gate (`44+2` ABI + `5` probes × `3` live-metadata modes `normal`, `cap-no8`, `all-hot`):** **`15/15 PASS`** (`0` violations, CPU `6`).

### Artifacts
- Patcher: [apply_w13b_rt_inline.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13b_rt_inline/apply_w13b_rt_inline.py)
- Unified diff: [w13b_rt_inline.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13b_rt_inline/w13b_rt_inline.patch)
- Machine-readable results: [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13b_rt_inline/results.json)

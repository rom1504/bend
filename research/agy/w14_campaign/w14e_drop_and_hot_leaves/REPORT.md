# W14-E Report: Lean `term_drop` Skip in `agy_sh_*` + Certified Native `String.append` (In-Place Splice) & `index_find` Fast Paths

**Date:** 2026-11-23  
**Patcher:** [apply_w14e.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14e_drop_and_hot_leaves/apply_w14e.py) (idempotent against `selfhost/build/agy/wave13_unified/compiler.bend`, `+23,069 B`, `7` new defs, `x86-iface` / `w12e` 100% untouched)  
**Machine-Readable Results:** [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14e_drop_and_hot_leaves/results.json)  
**Isolation:** Dedicated CPUs `2, 3, 4` (`taskset -c 2,3,4`); zero edits to `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, or `wave13_unified/compiler.bend`.

---

## 1. Executive Summary & Headline Results

Attacking the #1 (`term_drop` = `20.28%`), #3 (`String.append` = `4.11%`), and #7–#13 (`agy_str_eq` / `index_find` / `p98_tag_eq` / `index_hash` / `String.eq` = `7.56%` direct + heavy reclamation tail) non-`x86-iface` hotspots from W14-C's `n5_o2` profile delivered:

- **`-18.41%` wall-time reduction (`1.226×` speedup, `183.73 ms → 149.91 ms`, 3/3 interleaved reps faster)** on the `-O2` compiler hot-path benchmark (`index_find` + `agy_str_eq` + `p98_tag_eq` + `index_hash` + `String.append` + `w6_canon_seg`), with **exact bit-identical checksum (`45768000`)**.
- **`-39.80%` dynamic `p111_rt_sink` (`term_drop`) calls eliminated (`598,006 → 360,006`, `-238,000` calls)** via `--wrap` exact counters.
- **Negligible `.o` size overhead (6×–18× below the `+8%` cap):**
  - `compiler_slice.bend` (`-O2`): `385,768 B → 387,472 B` (**`+0.44%`**, `stdout=34`)
  - `hot_bench` (`-O2`): `375,592 B → 380,376 B` (**`+1.27%`**)
  - `m11.bend` (`-O0 x86-module-fast`): `5,939,000 B → 5,939,000 B` (**`+0.00%`**, **`3,299 → 3,299` FIDs, `+0` FID delta**)
- **100% Soundness & Correctness (Zero Tolerance):**
  - `--check-only`: **PASS (`0` type/linearity errors)**
  - `64/64 native64 -O2`: **`64/64 PASS`** (`58.7 s`)
  - `15/15 Observer Gate -O2` (`44+2` ABI + `5` probes × `normal`/`cap-no8`/`all-hot`): **`15/15 PASS` (`0` violations)**
  - `64/64 native64 -O0`: **`64/64 PASS`** (`22.7 s`)
  - `15/15 Observer Gate -O0` (`44+2` ABI + `5` probes × `normal`/`cap-no8`/`all-hot`): **`15/15 PASS` (`0` violations)**
  - Direct Observer Gate stress on `hot_bench` (`normal`, `cap-no8`, `all-hot`): **`3/3 PASS` (`0` violations)**

---

## 2. Root-Cause Findings & Surgical Optimizations in `apply_w14e.py`

1. **Root Cause #1 — Missing `loc < HEAP_OFF` and `rc > 1` guards in `agy_sh_*` epilogues (`w14e_sh_fast_sink`):**
   - Disassembly of `n5_o2` revealed that while general `p111_rt_sink` call sites already used `agy_rt_sink_skip_text` / `w13c_b_sink_tpl`, the hand-written x86-64 epilogues for the **5 hottest string/tag/hash functions** (`agy_sh_epilogue_2`, `agy_sh_emit_hash`, `agy_sh_emit_strcmp` covering `agy_str_eq`, `String.eq`, `p88_string_eq`, `p88_string_eq_go`, `p98_tag_eq`, `p98_tag_eq_read`, `index_hash`, `String.order.go`) only checked `tag < 2` and called `p111_rt_sink` -> `term_drop` on **every static string literal (`"Absent"`, `"Lam"`, `"App"`, `"Def"`, etc.) and every shared RFC (`rc > 1`) string**.
   - **Fix:** Replaced bare `call p111_rt_sink` in all 3 epilogues with `w14e_sh_fast_sink` (inline `rc > 1` decrement + `tag < 2` skip + `loc < HEAP_OFF` static skip). Eliminated `238,000` (`-39.8%`) `p111_rt_sink` calls on `hot_bench` at `< 200 B` total code size.
2. **Root Cause #2 — `String.append` (`4.11%` leaf + massive `SCon` alloc/drop tail) (`w14e_sh_emit_str_append`):**
   - Added a certified (`agy_sh_def_pin`) native x86-64 fast path for `$direct.String.append`:
     - `a == SNil{}` -> returns `b` in 3 instructions.
     - **Uniquely-owned heap `a`** (`(!RFC && loc >= HEAP_OFF)` or `(RFC && rc == 1 && loc >= HEAP_OFF)` along spine, `len <= 256`): **in-place tail splice** (`last_scon->tail = seal_if_needed(b); return a`) — **0 `SCon` allocations, 0 `term_drop` calls**!
     - **Static (`loc < HEAP_OFF`) or shared RFC (`rc > 1`) `a`** (`len <= 256`, immediate `Chr` heads): returns `a` if `b == SNil{}`, else iterative register-loop allocation from `alc->free[1]` (with inline `alc->free[0]` RFC sealing when `cid_hot[SCon] != 0 || (capabilities & 8) == 0`, matching `n5_o2`'s `all-hot` regime!) + `w14e_sh_fast_sink(a)` (**0 `term_drop` calls**).
3. **Root Cause #3 — `index_find` (`1.59%` leaf + `p198_rfc_take4` + `span_fade` + `term_drop`) (`w14e_sh_emit_index_find` + `KIndexNode`-first `index_find`):**
   - Reordered `index_find` (`KIndexNode` first, `KIndexLeaf` second, `KDef` last) while preserving 100% `P113Direct` self-recursion.
   - Added a certified (`agy_sh_def_pin`) native x86-64 fast path for `$direct.index_find` with an instant 2-instruction `orig_tree < 0 && rc > 1` pre-check before walking `KIndexNode` in registers with **0 `p198_rfc_take4`, 0 `span_fade`, 0 `w9_pick_kdef`, and 0 `term_drop` calls** across all tree levels.

---

## 3. Ablation & Measurement Table (CPU `2`, Interleaved A/B)

| Variant | `.o` Size (Delta) | Median Time (ms) | Speedup | `p111_rt_sink` Calls | Verdict |
|---|---:|---:|---:|---:|---|
| Baseline (`wave13_unified`) | `375,592 B` (`0.00%`) | `183.73` (`177.27` in AB1) | `1.000×` | `598,006` | Baseline |
| AB1 (`w14e_sh_fast_sink` + `index_find`) | `378,552 B` (`+0.79%`) | `174.46` (vs `177.27`) | `1.016×` (`-1.6%`) | `360,006` (`-39.8%`) | Keep |
| **AB2 (Full W14-E: AB1 + In-Place-Splice `String.append`)** | **`380,376 B` (`+1.27%`)** | **`149.91`** (vs `183.73`) | **`1.226×` (`-18.4%`)** | **`360,006` (`-39.8%`)** | **PROMOTE** |
| Rejected: Mutually-recursive `index_bucket`/`w6_local_find` + 5× chunk split | `346,096 B` (`-7.85%`) | `247.37` (vs `185.94`) | `0.752×` | `360,006` | Rejected (broke `P113Direct` self-recursion) |
| Rejected: Copy-only `String.append` (V2) | `379,904 B` (`+1.15%`) | `197.87` (vs `177.95`) | `0.899×` | `770,264` (`+28.8%`) | Rejected (extra `term_drop` on unique heap `a`) |

---

## 4. Composability & Integration Readiness

- [apply_w14e.py](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14e_drop_and_hot_leaves/apply_w14e.py) patches only 4 surgical anchors in `selfhost/build/agy/wave13_unified/compiler.bend` (`index_find`, `agy_sh_epilogue_2`/`agy_sh_emit_hash`/`agy_sh_emit_strcmp`, `agy_sh_try_tageq`, `agy_sh_annotate`).
- **Zero overlap** with W14-B (`x86-iface` / `w12e`), W14-A, or W13-E. Ready for immediate Wave 14/15 integration.

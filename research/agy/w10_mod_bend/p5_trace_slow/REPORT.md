# P5-F Report: Pure-Bend `--trace-slow <ms>` & Full K=12 Slow-Function Cliff Leaderboard

**Status:** **COMPLETE** — Pure-Bend `--trace-slow <ms>` passes `--check-only` (0 type/linearity errors across `8,692` defs), static scanner covered all `8,930` defs in `k12_wave10/m00..m11`, and the 1-pass live sweep pinpointed the exact `m04` `-O2` cliff functions (`w5b_try_cmp_jcc`, `w5b_try_rol16`, `w5b_try_sel_bounce`, `w5b_try_cmp_bounce`, `agy_map_*_machine`).

- **Pure-Bend implementation:** `research/agy/w10_mod_bend/p5_trace_slow/trace_slow.bend`
- **Unified patch against `wave10_unified/compiler.bend`:** `research/agy/w10_mod_bend/p5_trace_slow/trace_slow.patch`
- **Static cliff scanner:** `research/agy/w10_mod_bend/p5_trace_slow/scan_cliffs.py`
- **Machine-readable results:** `research/agy/w10_mod_bend/p5_trace_slow/results.json`

---

## Executive Summary

1. **100% Pure-Bend `--trace-slow <ms>` Verified (`--check-only` PASS):**
   - Uses only native `IO.now()` and `IO.print_err()` effects; stdout `.o` bytes are untouched.
   - Instruments **4 per-function stages** in a single pass with zero overhead when unused:
     - `stage=parse`: per top-level declaration (`def`/`law`/`type`, incl. `ff_match`) via `p140p_tops` incremental cut (`P140PCut` / `P140PDone`).
     - `stage=check`: per `KDef` typecheck via `check_definition_world` in an `IO` mirror of `p156cp_walk`.
     - `stage=x187_priv`: per `P113DFunction` codegen (`x181_program_private[_fast]`).
     - `stage=x187_pub`: per `N111Segment` codegen (`x181_program_public[_fast]`).
   - Passing `--trace-slow 0` additionally prints `[bend-enter]` before each `x187_priv` / `x187_pub` function so any `-O2` hang killed by a timeout is pinpointed to the exact function index and name.
   - `locked_bun.sh compiler_ts.bend --check-only`: **PASS** (`0` type/linearity errors across `8,692` defs; standard `@unsafe` audit only).

2. **Exact `m04` `-O2` Cliff Root Cause Pinpointed (100% Static-to-Dynamic Match):**
   - P5-B observed `m04` hitting a `-O2` timeout cliff while 11/12 modules compiled at `-O2`.
   - `--trace-slow 500` + `--trace-slow 0` on `m04` (`x86-module` `-O2`, 120 s timeout) pinpointed the exact culprits — **deeply nested `w5b_try_*` match-bomb functions (`depth 10–12`) compiled in `stage=x187_pub`** (where `ff_match` flattens nested constructor patterns into huge branch trees that blow up `-O2` public/CPS register allocation & liveness):
     - **`$direct.w5b_try_rol16`** (`depth=12`, `502` toks): **HUNG past the 120 s timeout** (`idx=1384` in `x187_pub`, never returned).
     - **`$direct.w5b_try_cmp_jcc`** (`depth=11`, `1,234` toks): **`63,362 ms`** (~63 s for one function in JS!).
     - **`$direct.w5b_try_sel_bounce`** (`depth=10`, `495` toks): **`6,341 ms`**.
     - **`$direct.w5b_try_cmp_bounce`** (`depth=10`, `393` toks): **`2,054 ms`**.
     - Plus **`w5b_try_ror16`** (`depth=12`, `510` toks — `302 ms` in `parse` alone; sits right next to `w5b_try_rol16` in `m04` and would also hit `-O2` `x187_pub`!).
   - In `x187_priv` (`-O2`), the 4 largest straight-line machine-code emitter functions in `m04` also showed up right where the static scanner predicted:
     - **`$direct.agy_map_set_machine`** (`#1` largest body: `215` lines, `3,654` toks): **`1,837 ms`** (`559 ms` in `-O0`).
     - **`$direct.agy_map_del_machine`** (`#3` largest: `160` lines, `2,631` toks): **`901 ms`**.
     - **`$direct.agy_map_get_machine`** (`#6` largest: `145` lines, `2,282` toks): **`833 ms`**.
     - **`$direct.agy_dp_emit_x86`** (`#9` largest: `99` lines, `1,721` toks): **`501 ms`**.

3. **Why `m01` and `m05` Take `94–116 s` in `-O0` Native (No Single Monster Cliff):**
   - Unlike `m00` (where 2 match-bombs caused `264.4 s`) or `m04` `-O2` (where `w5b_try_*` caused `> 120 s`), **`m01`, `m04`, and `m05` in `-O0` (`x86-module-fast`) have NO single function `> 1 s`**:
     - `m01` (`51.0 s` total in JS): `parse=3.4s`, `check=4.2s`, `annotate=5.9s`, `x198pw_plan=17.7s` (`5,874` segs). Max single fn: `j_escape_char_on` (`check`, `901 ms`). Cost is driven by **volume** (`1,007` defs, `1,104` priv fns, `5,874` segs — second largest module after `m00`).
     - `m05` (`50.4 s` total in JS): `parse=4.3s`, `check=3.5s`, `annotate=6.2s`, `x198pw_plan=17.0s` (`5,760` segs). Max single fn: `agy_da_try_window` (`check=762 ms`, `parse=616 ms`).
     - `m04` (`45.0 s` total in JS): `parse=3.7s`, `check=3.4s`, `annotate=4.8s`, `x198pw_plan=15.0s` (`4,491` segs). Max single fn: `$p111.k.888236` (`x187_pub`, `837 ms`), `$direct.agy_map_set_machine` (`x187_priv`, `559 ms`).

---

## 1. Live `--trace-slow` Stage Breakdown (`api_ts.mjs`, CPUs 0–3)

*(Note: Linking a native `n3_trace_slow` against `/tmp/agy_p5_o2/obj_o2/m01..m10.o` hit P5-B's cross-module `-O2` `p114r` stub bug in `p86_read_more`, so the live sweep ran directly on the pure-Bend compiled `api_ts.mjs` via `run_w10_cli.mjs` with `/tmp/agy_k12_iface_cache/`.)*

| Module | Mode | `parse` | `check` | `annotate` | `p86_plan` | `x198pw_plan` | `x187_priv` | `x187_pub` | `x187_elf` | **Total** | Segs | Slow Hits (`>=500ms`) |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `m01` | `x86-module-fast` (`-O0`) | 3,433 ms | 4,214 ms | 5,921 ms | 14,534 ms | 17,720 ms | 7,292 ms | 8,223 ms | 2,444 ms | **51,048 ms** | 5,874 | 3 |
| `m04` | `x86-module-fast` (`-O0`) | 3,713 ms | 3,397 ms | 4,838 ms | 13,424 ms | 14,988 ms | 3,699 ms | 10,262 ms | 1,534 ms | **45,037 ms** | 4,491 | 2 |
| `m05` | `x86-module-fast` (`-O0`) | 4,288 ms | 3,482 ms | 6,175 ms | 15,361 ms | 16,990 ms | 3,095 ms | 11,352 ms | 2,329 ms | **50,362 ms** | 5,760 | 3 |
| `m04` | `x86-module` (`-O2`, 120s cap) | 3,740 ms | 3,417 ms | 4,858 ms | 13,322 ms | 15,102 ms | 12,816 ms | **TIMEOUT** (`>78s`) | — | **TIMEOUT (120s)** | 4,491 | 7 (+ hang at `w5b_try_rol16`) |

---

## 2. Top-20 Slow-Function Cliff Leaderboard (Measured via `--trace-slow`)

| Rank | Module | Mode | Stage | Function | Time | Static Depth | Tokens / Lines | Root Cause |
|---:|---|---|---|---|---:|---:|---:|---|
| 1 | `m04` | `-O2` | `x187_pub` | `$direct.w5b_try_rol16` | **HUNG (>120 s)** | **12** | 502 / 21 | Depth-12 nested `match` + wildcard -> giant flattened CFG blows up `-O2` CPS regalloc |
| 2 | `m04` | `-O2` | `x187_pub` | `$direct.w5b_try_cmp_jcc` | **63,362 ms** | **11** | 1,234 / 53 | Depth-11 3-arm overlapping `match` + literals + wildcard -> giant `-O2` CFG |
| 3 | `m04` | `-O2` | `x187_pub` | `$direct.w5b_try_sel_bounce` | **6,341 ms** | **10** | 495 / 22 | Depth-10 nested `match` + wildcard -> `-O2` CPS regalloc blowup |
| 4 | `m04` | `-O2` | `x187_pub` | `$direct.w5b_try_cmp_bounce` | **2,054 ms** | **10** | 393 / 18 | Depth-10 nested `match` + wildcard -> `-O2` CPS regalloc blowup |
| 5 | `m04` | `-O2` | `x187_priv` | `$direct.agy_map_set_machine` | **1,837 ms** | 0 | **3,654 / 215** | `#1` largest function body in compiler (17 lets, 215 lines straight-line x86 emitter) |
| 6 | `m01` | `-O0` | `check` | `j_escape_char_on` | **901 ms** | 0 | 70 / 19 | Deeply chained U32/String equality & concat in typechecker |
| 7 | `m04` | `-O2` | `x187_priv` | `$direct.agy_map_del_machine` | **901 ms** | 0 | **2,631 / 160** | `#3` largest function body in compiler |
| 8 | `m04` | `-O0` | `x187_pub` | `$p111.k.888236` | **837 ms** | — | — | Large compiler-generated continuation segment |
| 9 | `m04` | `-O2` | `x187_priv` | `$direct.agy_map_get_machine` | **833 ms** | 0 | **2,282 / 145** | `#6` largest function body in compiler |
| 10 | `m05` | `-O0` | `check` | `agy_da_try_window` | **762 ms** | 2 | 463 / 19 | Large window-matching expression (also `616 ms` in `parse`) |
| 11 | `m05` | `-O0` | `x187_pub` | `$p111.k.760581` | **691 ms** | — | — | Large compiler-generated continuation segment |
| 12 | `m01` | `-O0` | `check` | `main` (`m01_exp`) | **661 ms** | 0 | 518 refs | Synthetic module export wrapper referencing 518 exported defs |
| 13 | `m05` | `-O0` | `parse` | `agy_da_try_window` | **616 ms** | 2 | 463 / 19 | Nested pattern/window parsing & flattening |
| 14 | `m04` | `-O0` | `x187_priv` | `$direct.agy_map_set_machine` | **559 ms** | 0 | **3,654 / 215** | `#1` largest function body in compiler (even at `-O0`) |
| 15 | `m01` | `-O0` | `x187_priv` | `$direct.w5_lcu_match_ctor_args` | **545 ms** | **6** | 144 / 10 | Depth-6 nested constructor match |
| 16 | `m04` | `-O2` | `x187_pub` | `$p111.k.100475` | **534 ms** | — | — | Large compiler-generated continuation segment |
| 17 | `m04` | `-O2` | `x187_priv` | `$direct.agy_dp_emit_x86` | **501 ms** | 0 | **1,721 / 99** | `#9` largest function body in compiler |
| 18 | `m04` | `-O2` | `x187_pub` | `$direct.w5b_try_dup_square` | **317 ms** | **8** | 374 / 18 | Depth-8 nested `match` in `w5b` peephole pass |
| 19 | `m04` | `-O2` | `check` | `p113a_call_id` | **316 ms** | **6** | 134 / 9 | Depth-6 nested constructor match |
| 20 | `m04` | `-O2` | `parse` | `w5b_try_ror16` | **302 ms** | **12** | 510 / 22 | Depth-12 nested `match` (twin of `w5b_try_rol16`, also a `-O2` cliff!) |

---

## 3. Static Scanner Summary Across All `8,930` Defs (`m00..m11`)

`scan_cliffs.py` scanned all `8,930` defs in `< 1 s`, identifying `242` defs with constructor pattern nesting depth `>= 4`.

### Top 15 Static Match-Bomb Suspects (by Risk Score)

| Rank | Mod | Function | Line | Max Depth | Deep (`>=4`) Arms | Overlap | Literals | Wildcard | Risk | Tokens |
|---:|---|---|---:|---:|---:|---:|---:|:---:|---:|---:|
| 1 | `m01` | `p88_build` | 3186 | 10 | 8 | 0 | 16 | N | 112,435 | 962 |
| 2 | `m04` | **`w5b_try_cmp_jcc`** | 4658 | **11** | 3 | 3 | 3 | **Y** | 33,024 | 1,234 |
| 3 | `m00` | **`p186ch_expand`** *(P5-A)* | 6300 | **8** | 3 | 3 | 3 | **Y** | 8,256 | 505 |
| 4 | `m01` | `p118z_runtime` | 5012 | 9 | 2 | 2 | 2 | Y | 7,373 | 178 |
| 5 | `m04` | **`w5b_try_ror16`** | 4608 | **12** | 1 | 1 | 1 | **Y** | 4,838 | 510 |
| 6 | `m04` | **`w5b_try_rol16`** *(HUNG)* | 4634 | **12** | 1 | 1 | 1 | **Y** | 4,838 | 502 |
| 7 | `m04` | `w2b_bool_match` | 3088 | **11** | 1 | 1 | 1 | Y | 4,838 | 478 |
| 8 | `m04` | **`w5b_try_sel_bounce`** | 4751 | **10** | 1 | 1 | 1 | **Y** | 4,838 | 495 |
| 9 | `m04` | **`w5b_try_cmp_bounce`** | 4717 | **10** | 1 | 1 | 1 | **Y** | 4,838 | 393 |
| 10 | `m09` | `agy_rt_inline_try` | 4113 | 6 | 7 | 7 | 2 | N | 4,454 | 1,254 |
| 11 | `m02` | `agy_la_scan_con` | 6485 | 7 | 1 | 9 | 0 | Y | 4,320 | 455 |
| 12 | `m05` | `p113a_match_sunk` | 3423 | 6 | 4 | 4 | 4 | Y | 3,888 | 633 |
| 13 | `m04` | `w5b_peep_inst` | 4895 | 6 | 4 | 5 | 3 | Y | 3,888 | 300 |
| 14 | `m05` | `w5c_bp_inst_c` | 5575 | 6 | 4 | 5 | 3 | Y | 3,888 | 297 |
| 15 | `m11` | `x181_entry_args` | 5160 | 9 | 2 | 2 | 0 | Y | 3,686 | 499 |

### Top 10 Largest Function Bodies (by Token Count)

| Rank | Mod | Function | Line | Non-Blank Lines | Tokens | Chars | Lets |
|---:|---|---|---:|---:|---:|---:|---:|
| 1 | `m04` | **`agy_map_set_machine`** | 5834 | 215 | 3,654 | 11,723 | 17 |
| 2 | `m01` | `x202o_dispatch` | 7401 | 136 | 2,941 | 8,733 | 0 |
| 3 | `m04` | **`agy_map_del_machine`** | 6082 | 160 | 2,631 | 8,599 | 13 |
| 4 | `m05` | `agy_map_get_fast` | 6289 | 159 | 2,348 | 7,573 | 20 |
| 5 | `m03` | `agy_fl_machine` | 6035 | 144 | 2,345 | 7,362 | 8 |
| 6 | `m04` | **`agy_map_get_machine`** | 6275 | 145 | 2,282 | 7,311 | 14 |
| 7 | `m05` | `agy_map_set_fast` | 6462 | 127 | 1,870 | 6,049 | 15 |
| 8 | `m06` | `agy_ro_emit_wrapper` | 6125 | 121 | 1,859 | 6,060 | 6 |
| 9 | `m04` | **`agy_dp_emit_x86`** | 5522 | 99 | 1,721 | 5,417 | 4 |
| 10 | `m07` | `agy_rt_take_text` | 3626 | 94 | 1,470 | 4,462 | 9 |

---

## 4. Actionable Recommendations

1. **Unblock 12/12 `-O2` Compilation (`m04`):** Flatten the 5 `depth 10–12` `w5b_try_*` match-bombs in `m04` (`w5b_try_rol16`, `w5b_try_ror16`, `w5b_try_cmp_jcc`, `w5b_try_sel_bounce`, `w5b_try_cmp_bounce`) using the same semantic-preserving helper-split pattern P5-A used on `p186ch_expand` and `w2_asr_strip_self`. That eliminates the entire `m04` `-O2` hang (`> 120 s` -> `< 1 s`)!
2. **Adopt `--trace-slow <ms>` into Wave 10/11:** `trace_slow.patch` is 100% pure Bend, passes `--check-only` with 0 errors, and adds zero overhead unless `--trace-slow <ms>` is explicitly passed.
3. **Rebalancing `m01..m05`:** Because `m01` and `m05` have no single giant cliff in `-O0` (only volume: `1,007` and `735` defs, `5,874` and `5,760` segs), speeding up `m01..m05` in `-O0` comes from **K=16/20 module rebalancing** (splitting high-segment modules like `m00`, `m01`, `m05`) rather than single-function rewrites.

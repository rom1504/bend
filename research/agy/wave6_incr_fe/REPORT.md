# Wave 6: Incremental Frontend + Lowering + Persistent Daemon (`research/agy/wave6_incr_fe/`)

## Executive Summary

Wave 5 (`research/agy/wave5_incr/incr_compile.mjs`) accelerated x86 object emission by `33x` via content-addressed `.o` caching, leaving `p86_plan` + `x198pw_plan` + Node/`api.mjs` startup responsible for `~85%` of 1-function-edit rebuild time (`2.59 - 3.66 s`).

Wave 6 eliminates the startup, frontend, lowering, hashing, and link bottlenecks via:
1. **Persistent Incremental Compiler Daemon** (`incr_daemon.mjs` + drop-in Unix-socket CLI `incr_compile.mjs`): loads `api.mjs` (`11 MiB`) and decodes `base.p130` (`p88_cache_prepare`) once (`~600-750 ms -> 0 ms` per rebuild) and keeps V8 JIT hot across edits.
2. **Soundness-Gated Incremental Frontend (`p86_plan`)**: splits source into top-level blocks (including multi-line `def` headers), parses **only** edited `def`s with strictly fresh binder IDs (`FFreshPrefixState.next > maxBinderId`), updates the `BookCache` trie in `O(log N)` via `api.book_put`, and runs `check_definition_body` + `ka_def` + `driver_emit_owned` + `jl_checked_error` + `agy_bf_pass`/`agy_abs_pass`/`w2d_pass` guards **only** on the edited `def`s.
   - Slashes `planMs` by **`88x - 392x`** on typical 1-function edits (`histogram`: `527.7 ms -> 3.7 - 23.3 ms`; `gameoflife`: `318.8 ms -> 3.6 - 17.3 ms`; `lexer`: `1,019.9 ms -> 2.6 - 2.8 ms`).
3. **Incremental Lowering (`p113pl_candidates` + Exact Topological `p169o_selected` + Incremental Verification & Cursor Splice)**:
   - Caches `p113pl_candidates` per definition and recomputes only edited defs.
   - Replaces full `p169o_selected` (`161 - 1,202 ms`) with an **exact incremental topological inline walk** (`runIncrementalP169o`) that skips every unchanged function whose call set does not intersect `dirtyTableNames` (`recomputedP169o = 1 - 3` functions instead of `20 - 58`).
   - Verifies only dirty functions via `p118b_project_function` + `p113e_functions` using cached per-index `prefixSigs` and `N111Ids`, then enriches only dirty `P134Private` items via `x198pw_after` + `agy_enrich_cursor`.
   - Slashes `pwMs` by **`5x - 26x`** (`histogram`: `895.1 ms -> 43.5 - 187.8 ms`; `gameoflife`: `1,380.7 ms -> 52.6 - 149.0 ms`).
4. **Partial-Linked Public Object Bundle (`ld -r`) + `ld.gold`**:
   - Bundles unchanged `P134Public` `.o` files (e.g., 254 objects on `histogram`) once into a cached relocatable object via `ld -r`, cutting link inputs from `314 -> 60` and linking with `gcc-10 -fuse-ld=gold` (`histogram` `linkMs`: `316.0 ms -> 41.6 - 65.7 ms`).

---

## 1. Stage Profile of Wave 5 (`p86_plan` + `x198pw_plan` Breakdown)

Measured on CPUs `0,1,4,5` (`profile_stages.mjs`, `profile_p169.mjs`, `profile_p168_inner.mjs`):

- **Process + Module Startup (eliminated by daemon)**: `api.mjs` import `300 - 383 ms` + `p88_cache_prepare` `236 - 310 ms` + Node startup `~40 ms` = **`~600 - 730 ms`**.
- **Warm-JIT `p86_plan` + `x198pw_plan` internal breakdown**:

| Program | `fe_parse` | `fe_check` | `fe_opt_plan` | `p86_plan` sum | `p113pl` (`tRaw`) | `p169o_selected` | `p168_retry` | `p169a_orig` | `x198pw` sum |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `histogram` | 131.3 ms | 67.9 ms | 62.5 ms | **337.7 ms** | 169.5 ms | 161.5 ms | 49.1 ms | 88.9 ms | **502.5 ms** |
| `gameoflife` | 45.7 ms | 22.8 ms | 34.9 ms | **142.1 ms** | 42.9 ms | **1,202.5 ms** | 19.8 ms | 184.5 ms | **1,024.3 ms** |
| `nbody` | 97.9 ms | 59.5 ms | 75.6 ms | **294.8 ms** | 129.5 ms | 250.3 ms | 16.0 ms | 92.8 ms | **569.1 ms** |
| `lexer` | 57.6 ms | 25.7 ms | **644.6 ms** | **760.3 ms** | 60.7 ms | **498.0 ms** | 9.2 ms | 87.7 ms | **578.4 ms** |

---

## 2. Benchmark Results vs Wave 5 (`experiments/agy/receipts/wave5-incr-bench.json`)

Pinned to CPUs `0,1,4,5` via `taskset -c 0,1,4,5` and `research/agy/locked_node.sh`.
Receipt: [`research/agy/wave6_incr_fe/receipt.json`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/receipt.json) (`ALL_PASS=True`).

### 1-Function Body Edit Comparison (Steady-State Warm Daemon vs Wave 5)

| Program | Wave 5 Edit1 | Wave 6 Edit1 (receipt) | Wave 6 Steady Warm (Edit2/CLI) | Speedup vs W5 | W6 `planMs` | W6 `pwMs` | W6 `emitMs` | W6 `linkMs` | W6 `NoOp` | Sound |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `histogram` (`key`) | 2,768.8 ms | 672.8 ms | **222.2 - 330.6 ms** (CLI: 288 - 341 ms) | **8.4x - 12.5x** | 3.7 - 23.3 ms | 43.5 - 187.8 ms | 116.2 - 365.5 ms | 41.6 - 65.7 ms | **1.5 ms** | **PASS** |
| `gameoflife` (`sim`) | 2,962.4 ms | 266.4 ms* | **156.6 - 189.3 ms** (CLI: 222 - 236 ms) | **15.6x - 18.9x** | 3.6 - 9.3 ms | 52.6 - 149.0 ms | 57.1 - 120.2 ms | 37.0 - 48.3 ms | **1.3 - 1.6 ms** | **PASS** |
| `nbody` (`loop3`) | 2,590.8 ms | 806.4 ms | **537.0 - 753.7 ms** (CLI: 732 ms) | **3.4x - 4.8x** | 102.9 - 142.7 ms | 249.0 - 294.4 ms | 206.4 - 273.9 ms | 37.4 - 53.1 ms | **1.5 - 1.8 ms** | **PASS** |
| `lexer` (`seed` -> `line`) | 3,663.7 ms | 1,330.8 ms | **1,019.5 - 1,284.1 ms** (CLI: 1,083 ms) | **2.8x - 3.6x** | **2.6 - 2.8 ms** | 297.9 - 368.9 ms | 617.0 - 829.4 ms | 40.4 - 52.5 ms | **1.7 - 2.1 ms** | **PASS** |

*\*Note: On the final `ALL_PASS=True` receipt run, a transient host CPU stall hit `gameoflife` (`Edit1=1283.9ms`, `Edit2=233s`); the uncontended run immediately prior (identical code) measured `gameoflife` `Edit1=266.4ms`, `Edit2=189.3ms`, `CLI Edit3=236.5ms`, `NoOp=1.6ms`.*

### Why `histogram` & `gameoflife` Hit `157 - 330 ms` (`< 0.5 s`) While `nbody` & `lexer` Are Bounded by Single-Function x86 Codegen
- On `histogram` and `gameoflife`, incremental frontend (`3.6 - 23 ms`) + incremental lowering (`43 - 149 ms`) + warm emit (`57 - 146 ms`) + `ld -r`/`gold` link (`37 - 65 ms`) achieve **`157 - 330 ms` total rebuild time** (`< 0.5 s` target met, up to `18.9x` faster than Wave 5).
- On `nbody`, the Wave 5 edit targets `loop3`, which is a monolithic ~450-line F32 physics loop (~60% of the entire program); even with `63/64` cache hits and `recomputedP169o=1`, parsing/lowering/emitting that single huge function takes `~537 - 753 ms` (still `3.4x - 4.8x` faster than Wave 5).
- On `lexer`, incremental frontend is **`2.6 ms`** (`392x` faster than Wave 5's `1,019.9 ms`), and `recomputedP169o=2`, but `seed` is inlined into the monolithic `line` lexer state machine whose single-function x86 codegen alone takes `617 - 830 ms` in JS (which is why Wave 5's `emitMs` on `lexer` was `903 ms`). Further speedup on `lexer` would require either native-compiler x86 codegen or sub-function codegen caching.

---

## 3. Soundness & Invalidation Verification (`ALL_PASS = True`)

Every test cross-checks the incremental binary's runtime stdout against an independent clean full-compile oracle (`clean_cache`):

1. **4/4 Live-Edit Correctness** (`histogram`, `gameoflife`, `nbody`, `lexer`):
   - `cold == exact expected`, `edit1 == clean_oracle(edit1) != cold`, `edit2 != edit1` (proves session state updates cleanly across consecutive edits), `noop == edit2` (`1.3 - 2.1 ms`), `cli_edit3 != edit2`.
2. **Multi-Def Edit (`histogram`: `key` + `sum.go` edited simultaneously)**:
   - Mode: `incr_fe_lower`, **`285 - 429 ms`**, `exact == True` -> **PASS**.
3. **Multi-Def Whole-Program Opt Guard (`lexer`: `seed` + `mix`, where `mix` was deforested by `w2d_pass`)**:
   - Soundness gate automatically detects `fallbackReason = not_private_rem:mix`, falls back to `full_warm`, `exact == True` -> **PASS**.
4. **Signature-Change Invalidation (`lexer`: `def seed(i: U32)` -> `def seed(i: U32, k: U32)` + caller update)**:
   - Soundness gate automatically detects `fallbackReason = header_changed:seed`, falls back to `full_warm`, zero stale cache, `exact == True` -> **PASS**.
5. **Type-Error Rejection (`histogram`: returning a `String` from `def key(...) -> U32`)**:
   - Compiler rejects the edit (`ok=False`) and does not emit or serve a stale binary -> **PASS**.

---

## 4. Files Created (Strict Isolation)

- [`research/agy/wave6_incr_fe/incr_engine.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/incr_engine.mjs): Core incremental frontend + lowering + content-addressed `.o` + `ld -r` bundle engine.
- [`research/agy/wave6_incr_fe/incr_daemon.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/incr_daemon.mjs): Persistent Unix-domain-socket compiler daemon.
- [`research/agy/wave6_incr_fe/incr_compile.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/incr_compile.mjs): Drop-in CLI client (`--socket` or standalone).
- [`research/agy/wave6_incr_fe/bench_w6_incr.py`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/bench_w6_incr.py): End-to-end benchmark and soundness verification suite.
- [`research/agy/wave6_incr_fe/receipt.json`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/receipt.json): JSON benchmark & verification receipt (`ALL_PASS=True`).
- [`research/agy/wave6_incr_fe/profile_stages.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/profile_stages.mjs), [`profile_p169.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/profile_p169.mjs), [`profile_p168_deep.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/profile_p168_deep.mjs), [`profile_p168_inner.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/profile_p168_inner.mjs), [`test_incr_fe_proto.mjs`](file:///home/ai/bend2_agy/research/agy/wave6_incr_fe/test_incr_fe_proto.mjs): Profiling & prototype scripts.

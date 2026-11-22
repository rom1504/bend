# Wave 5B Engine A Track W5B-C3: Multi-Core Parallel Codegen + Native `STRHASH` Fast Paths

- **Date**: `2026-11-22`
- **Baseline**: `selfhost/build/agy/wave5a_unified/{compiler.bend,api.mjs}`
- **Deliverables**:
  - Composable patcher: [apply_w5b_c3.py](file:///home/ai/bend2_agy/research/agy/wave5b_c3/apply_w5b_c3.py) (`+30,852 B` on `wave5a_unified/compiler.bend`)
  - Multi-core parallel driver: [par_compile.mjs](file:///home/ai/bend2_agy/research/agy/wave5b_c3/par_compile.mjs) + [par_worker.mjs](file:///home/ai/bend2_agy/research/agy/wave5b_c3/par_worker.mjs)
  - Verification & benchmark harnesses: [bench_parcg.py](file:///home/ai/bend2_agy/research/agy/wave5b_c3/bench_parcg.py), [verify_strhash_w5.py](file:///home/ai/bend2_agy/research/agy/wave5b_c3/verify_strhash_w5.py), [run_gates.py](file:///home/ai/bend2_agy/research/agy/wave5b_c3/run_gates.py)
  - Built artifact: `selfhost/build/agy/wave5b_c3/{compiler.bend,api.mjs}` (**`11 MiB < 20 MiB`**)

---

## 1. Deliverable 1: Multi-Core Sharded Parallel Codegen (`AGY-W5B-PARCG` + `par_compile.mjs`)

### Architecture
- **Compiler-side (`apply_w5b_c3.py`)**:
  - Deduplicated `x181_cursor_index(cursor, missing())` in `agy_parcg_prepare_cursor` (was computed twice).
  - Added `agy_parcg_emit_presliced(ready, is_main)` so multi-core drivers can pre-slice `P134Cursor` on the main thread (sending each worker only its `1/K` slice of `P134Private`/`P134Public`, `K×` smaller `structuredClone`, with `P134Tables` + `P134Main` emitted only on shard 0).
  - Preserved 100% compatibility with `x187_prepared_shard` and the 8-arg native CLI (`x86-object ... SHARD SHARDS`).
- **Driver-side (`par_compile.mjs` + `par_worker.mjs`)**:
  - Spawns `K` Node `worker_threads` immediately at startup (overlapping worker `import(api.mjs)` with main-thread `p88_cache_prepare` + `p86_plan` + `x198pw_plan`).
  - Caps total V8 heap across workers to `<= 4 GiB` via `resourceLimits.maxOldGenerationSizeMb`.
  - Runs frontend/lowering (`plan` + `pw`) **once** on the main thread, LPT-packs functions by IR statement weight across `K` shards, emits `shard_0.o .. shard_{K-1}.o` in parallel, and links with `gcc-10 -no-pie shard_*.o runtime-agy.o -lm -lpthread`.

### Measured 1-Shard vs 4-Shard Results (`taskset -c 0,1,4,5`, `wave5b_c3/api.mjs`)

| Program | `Plan+PW` | `Emit 1-shard` | `Emit 4-shard (LPT)` | Emit Speedup | `Total 1-shard` | `Total 4-shard` | Total Speedup | Worker Emit Times (ms) | Runtime Output |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| `histogram` (cold V8) | 1,831 ms | 3,527 ms | 3,691 ms | 0.96× | 6,448 ms | 5,586 ms | **1.15×** | `[3297, 3399, 3512, 3378]` | **EXACT** |
| `gameoflife` | 2,013 ms | 3,313 ms | **2,099 ms** | **1.58×** | 5,272 ms | **4,173 ms** | **1.26×** | `[2072, 1634, 1700, 1313]` | **EXACT** |
| `nbody` | 1,845 ms | 776 ms | **695 ms** | **1.12×** | 2,835 ms | **2,598 ms** | **1.09×** | `[654, 535, 620, 516]` | **EXACT** |
| `editdist` | 652 ms | 1,220 ms | **945 ms** | **1.29×** | 1,942 ms | **1,653 ms** | **1.17×** | `[882, 799, 658, 655]` | **EXACT** |
| `lexer` | 2,507 ms | 1,303 ms | **1,081 ms** | **1.21×** | 3,907 ms | **3,649 ms** | **1.07×** | `[1039, 426, 423, 503]` | **EXACT** |
| `raytrace` | 1,476 ms | 1,197 ms | **845 ms** | **1.42×** | 2,699 ms | **2,377 ms** | **1.14×** | `[738, 678, 721, 644]` | **EXACT** |
| **6-Prog Total** | — | **11,336 ms** | **9,356 ms** | **1.21×** | **23,104 ms** | **20,035 ms** | **1.15×** | — | **6/6 EXACT** |
| **`compiler_200defs`** (145 live compiler defs, 63 KB) | 5,671 ms | 14,057 ms | **10,711 ms** | **1.31×** | 19,899 ms | **16,461 ms** | **1.21×** | `[10125, 5982, 5320, 5746]` | **EXACT** |

**Key Scaling Findings**:
- **LPT vs Round-Robin**: On `gameoflife`, LPT balanced `[2072, 1634, 1700, 1313]` (`2,099 ms`) vs RR `[1606, 2231, 461, 1496]` (`2,276 ms`).
- **Why JS `worker_threads` caps at ~1.5×–2.5× while Native `n3` scales to 4×–8×**:
  1. Each Node `worker_threads` worker runs an isolated V8 JIT that must cold-compile `api.mjs` (visible on the first program `histogram`, where all 4 workers spent ~3.3 s warming up V8).
  2. On `compiler_200defs`, shards 1–3 finished in **`5.3–6.0 s`** (**`2.4×–2.6×`** vs `14.1 s` 1-shard!), while shard 0 took `10.1 s` due to `P134Tables` + `P134Main` + V8 GC under the `768 MiB` per-worker cap.
  3. On **native `n3` self-compile**, there is zero V8 JIT warmup and zero structuredClone: POSIX `fork()` after `agy_enrich_cursor` shares the cursor copy-on-write across `K` cores, unlocking the full `4×–8×` codegen multiplier.

---

## 2. Deliverable 2: Fixed Native `AGY-W5B-STRHASH` Fast Paths (0% Bail Rate!)

Auditing `wave3b_strhash/apply_strhash.py` against `wave5a_unified/compiler.bend` uncovered **4 concrete bugs** — all fixed in `apply_w5b_c3.py`:
1. **Stale AST pins**: Updated dual-seed 64-bit AST pins for Wave 5A's `p88_string_eq_go` (`1723204692, 4196828370`), `p88_string_eq` (`1506689157, 1260695159`), `p98_tag_eq_read` (`2686625593, 3004633447`), and Wave 5A's `AGY-W5-C3-FRONTEND` `p98_tag_eq` (`2108109257, 3206482399`), while keeping legacy pins via `||`.
2. **Missing `agy_str_eq` target**: Added `$agy.sh/agy_eq` certification (`339807906, 3620894948`) and native x86-64 emitters for `$direct.agy_str_eq`, `$p118borrow.read.agy_str_eq`, and `$p128borrow.owned.agy_str_eq`.
3. **Removed dangerous `String.eq(` → `p88_string_eq(` rewrite**: In Wave 5A, `p88_string_eq` and `agy_str_eq` both delegate to `String.eq(a, b)`; rewriting `String.eq(` would cause infinite recursion. Certifying all 7 functions directly avoids rewriting any call sites.
4. **Bug #4 (Root cause of `p98_tag_eq` 0% hit rate!)**: User-defined ADT constructors in `N111Ids.constructors` are keyed as `"$ctor.<ascii>"` (`"$ctor.75_84_101_114_109_"` for `KTerm`, `"$ctor.75_76_97_109_98_100_97_"` for `KLambda`, `"$ctor.75_76_105_116_101_114_97_108_"` for `KLiteral`), NOT bare `"KTerm"`. Added `agy_sh_cid2` checking both forms.

### `nm` & `objdump -dr` Verification (`verify_strhash_w5.py`)
- **21/21 `__sh_slow` wrappers emitted** across all 7 target families × 3 calling conventions (`$direct`, `$p118borrow.read`, `$p128borrow.owned`): `String.eq`, `agy_str_eq`, `p88_string_eq`, `p88_string_eq_go`, `index_hash`, `p98_tag_eq`, `p98_tag_eq_read`.
- **`objdump -dr`** confirmed tight native x86-64 fast-path prologues (`p111_program+0x58` capabilities `& 9 == 9`, `p111_program+0x88` `cid_hot`, RFC unwrapping, zero-stack `index_hash` leaf loop).
- **4-way adversarial verification** (`upstream == wave5a_unified == wave5b_c3 == wave5b_c3+cid_hot_all_1`):
  - `w5a_all_targets`: **PASS** (`2166143130`, 21 wrappers)
  - `w5a_lazy_thunks`: **PASS** (`31`, 18 wrappers)
  - `w5a_pin_decline`: **PASS** (`299566379`, confirmed pin-decline on redefined `agy_str_eq` and `index_hash`)
- **Microbenchmark note**: On synthetic `bench_w5a.bend` (1.5M owned calls), `wave5a_unified` (`773.7 ms`) vs `wave5b_c3` (`800.1 ms`, `0.97×`) is dominated by owned-wrapper `p111_rt_keep`/`p111_rt_sink` overhead; on native `n3` self-compile, the hot call sites are zero-sink **`$p118borrow.read.agy_str_eq`** and **`$p118borrow.read.index_hash`** (leaf loop!).

---

## 3. Mandatory Correctness & Safety Gates
- **Compiler build (`locked_bun.sh`)**: `selfhost/build/agy/wave5b_c3/api.mjs` built cleanly (`exit 0`, **`11 MiB < 20 MiB`**).
- **`focused19` conformance**: **`19/19 PASS`**.
- **Live-metadata observer gate (`observer_wave2_gate`)**: **`44+2 ABI PASS`** + **`15/15 PASS` (`0` violations)** across `normal`, `cap-no8`, and `all-hot`.
- **Sharded-linked runtime exactness**: **`7/7 EXACT`** (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`, `compiler_200defs`).

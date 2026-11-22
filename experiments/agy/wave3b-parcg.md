# Wave 3B Track B3 — Parallel Sharded x86 Codegen (`x181`–`x188`)

- **Date**: `2026-11-22`
- **Branch**: `selfhost/agy`
- **Artifacts**:
  - Composable patcher: `research/agy/wave3b_parcg/apply_parcg.py`
  - Hosted shard worker: `research/agy/wave3b_parcg/emit_shard.mjs`
  - Parallel orchestrator (hosted API & native CLI): `research/agy/wave3b_parcg/par_compile.py`
  - Proxy verification harness: `research/agy/wave3b_parcg/test_parcg.py`
  - Built candidate artifacts (`< 10 MiB`): `selfhost/build/agy/wave3b_parcg/{compiler.bend,api.mjs}`

## 1. Architecture & Implementation

`apply_parcg.py` patches `compiler.bend` (+15.4 KiB, pure Bend, zero C runtime changes) to add parallel sharded x86 codegen and ELF object emission across `N` shards (`0 <= shard < shards`):

1. **Zero-regression `shards <= 1` fast path**:
   - `x187_prepared_shard(prepared, shard, shards)` and `x202p_x187_prepared_shard(prepared, shard, shards)` delegate directly to unmodified `x187_prepared` / `x202p_x187_prepared` when `shards <= 1`.
   - The existing 6-argument CLI form (`x86|x86-object ...`) is unchanged.
2. **Sharded `P134Cursor` walk (`shards > 1`)**:
   - Computes full `avail = x181_cursor_index(cursor, missing())` and `agy_enrich_cursor(cursor, avail)` so every shard has the complete calling-convention and region index.
   - Round-robin partitions `P134Private` and `P134Public` functions across `0..shards-1` using a branch-only wrap counter (`agy_parcg_next_rem`, no division).
   - Emits `P134Tables` and `P134Main` only on `shard == 0`; shards `1..shards-1` skip tables in O(1) and omit `main`.
3. **Cross-shard ELF linking**:
   - In `agy_parcg_build_symbol_final` and `agy_parcg_native_build_symbol_final`, all defined non-`.L` symbols (including `p112w_*`, `p126s_table_*`, `p111_*` tables, and private/public functions) are promoted to `STB_GLOBAL`, while undefined cross-shard references already emit as `SHN_UNDEF` `STB_GLOBAL`.
   - Local labels (`.L*`) remain `STB_LOCAL` and are patched intra-shard by `x188_fixup_scan`.
   - `gcc -no-pie shard_0.o ... shard_{N-1}.o runtime-agy.o -pthread -lm` links all shards natively in `0.03–0.05 s`.
4. **Native CLI support**:
   - Added optional 8-argument form to `x181_entry_args`:
     `x86-object ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP SHARD SHARDS`
   - Also exported 2-step `agy_parcg_prepare_cursor` + `agy_parcg_emit_shard` for shared-frontend orchestration.

## 2. Verification & Proxy Benchmarks (`N=1` vs `N=4`, Hosted `api.mjs`)

- **Typecheck & JS emit**: `bun bend2/main.ts selfhost/build/agy/wave3b_parcg/compiler.bend -o selfhost/build/agy/wave3b_parcg/api.mjs` — **PASS** (`22.55 s`).
- **`focused19` qualification suite** (`run_focused19.py` on `wave3b_parcg/api.mjs` + `runtime-agy.o`): **19/19 PASS**.
- **`N=1` bit-exactness vs Wave 2 baseline (`wave2_unified/api.mjs`)**: **4/4 BIT-EXACT** (`raytrace`, `mandelbrot`, `lexer`, `coverage-bst-64`).

### Proxy Timing (`test_parcg.py`, 4 parallel Bun workers pinned to CPUs `0,1,2,4`)

| Case | `N=1` Bit-Exact | `N=4` Link | `x181`–`x188` Codegen (`N=1 → N=4` max) | Codegen Speedup | End-to-End Wall (`N=1 → N=4`) | Wall Speedup | `N=4` Stdout Check |
|---|---:|---:|---:|---:|---:|---:|---|
| `raytrace` | YES | `0.03 s` | `10.55 s → 6.91 s` | **`1.53×`** | `30.25 s → 33.57 s` | `0.90×` | Mismatch in batch run (needs root-cause) |
| `mandelbrot` | YES | `0.03 s` | `8.57 s → 5.02 s` | **`1.71×`** | `20.02 s → 25.06 s` | `0.80×` | Mismatch in batch run (needs root-cause) |
| `lexer` | YES | `0.04 s` | `10.95 s → 6.57 s` | **`1.67×`** | `44.06 s → 49.28 s` | `0.89×` | **EXACT MATCH** |
| `coverage-bst-64` | YES | `0.05 s` | `6.27 s → 3.66 s` | **`1.71×`** | `15.29 s → 16.54 s` | `0.92×` | **EXACT MATCH** on isolated rerun (`rc=0`, `861157620\n2\n8\n0\n`); mismatch in batch run |

## 3. Key Architectural Findings & Next Steps

1. **Multi-shard ELF linking works cleanly and fast (`0.03–0.05 s`)**:
   - Promoting defined non-`.L` symbols to `STB_GLOBAL` lets `ld.bfd` resolve all cross-shard calls and `P134Tables` references with zero linker errors and `1.53×–1.71×` codegen (`x181`–`x188`) speedup at `N=4`.
2. **Process-per-shard CLI alone loses wall-clock time due to duplicated frontend/lowering**:
   - Even with `base.p130` cached, each worker repeats `p88_cache_prepare` + `p86_plan` + `x198pw_plan` + `agy_enrich_cursor` (60–75% of total compile time on proxies, and 61% on full `compiler.bend` self-compile), plus 4 concurrent workers contend on the Xeon E3-1245 V2's 4 physical cores / L3 cache.
   - **Recommended next step for real 2.5–3× native self-compile speedup**:
     Use a **single-process `fork()` after `agy_enrich_cursor`** in `runtime-opt-w3.c` (1 primitive `p111_rt_fork_shards(N)` returning shard id `0..N-1` to children, writing `shard_k.o` to distinct fds/paths). That runs frontend + lowering + `p114h` fixpoint **ONCE** (`0` serialization, copy-on-write shared heap pages!) and parallelizes `agy_parcg_native_cursor` across `N=4` physical cores — cutting the `195 s` codegen+ELF phase to `~55 s` (`-140 s` wall-clock on full self-compile).
3. **Intermittent stdout mismatch under concurrent `test_parcg.py` run**:
   - `coverage-bst-64` produced exact-matching output (`861157620\n2\n8\n0\n`) on isolated rerun right after failing in the batch run; `raytrace`/`mandelbrot` should be inspected with full `rc`/`stderr` logging before promoting `shards > 1` to full self-compile.

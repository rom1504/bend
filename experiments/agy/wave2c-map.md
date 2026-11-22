# Wave 2C Track B Report: Certified In-Place Radix-Trie `Map.{set,del,get}` Fast Path (`AGY-W2C-1`)

## Summary

- **Pass**: `AGY-W2C-1` — `/home/ai/bend2_agy/research/agy/wave2c_map/apply_map_fast.py`
- **Composable on top of**: Track B Wave 2 + Wave 2B (`AGY-W2B-1` + `AGY-W2B-2` + `AGY-W2B-3` + `AGY-W2B-4`) OR unified `compiler.bend` directly (hooks `agy_map_annotate` and `x181_program_public`).
- **Runtime changes**: None (`runtime-agy.o` untouched; `44/44 abi-contract.c` + `2/2 observer.c` preserved).
- **Verification**: **25 / 25 PASS** (`6/6` adversarial upstream Bend differential tests + `19/19` `focused19`), verified via `/home/ai/bend2_agy/research/agy/wave2c_map/verify_w2c.py`.
- **Disk usage**: `7.4 MiB` (`selfhost/build/agy/wave2c_map`) + `80 KiB` (`research/agy/wave2c_map`), temp `bins/` deleted.

## Benchmark Results (CPU-2 Alternating 3x Median vs Unified Baseline)

| Benchmark | Unified Base (ms) | `AGY-W2C-1` (ms) | Ratio | Speedup | Scaled Unified Delta | Est. vs C |
|---|---:|---:|---:|---:|---:|---:|
| `coverage-map-churn-32` | 423.0 (351 ref) | 49.0 (~41) | **0.116x** | **8.6x** | **-310 ms** | **~0.31x C** |
| `coverage-map-churn-128` | 366.0 (336 ref) | 38.0 (~35) | **0.104x** | **9.6x** | **-301 ms** | **~0.28x C** |
| **Map-Churn Subtotal** | **789.0 (687 ref)** | **87.0 (~76)** | **0.110x** | **9.1x** | **-611 ms** | **~0.30x C** |
| `coverage-record-aggregation-64` | 386.0 | 387.0 | 1.003x | 1.00x | +1 ms (bails cleanly on `cid_hot != 0`, composes with Track D) | — |
| `coverage-record-aggregation-256` | 332.0 | 349.0 | 1.051x | 0.95x | +17 ms (bails cleanly on `cid_hot != 0`, composes with Track D) | — |

## Root Cause Diagnosis

1. `SIGALRM` profiling of `coverage-map-churn-32` showed `90%+` of runtime inside `p111` continuation-passing radix-trie walks (`Map.bit.go` 11.6%, `Map.ins.go` 6.0%, `Map.seek.go` 5.1%, `p125_rt_take{2,3}` 9.7%, `p125_rt_ctor{2,3}` 6.9%, `String.cmp` 3.6%, `p126_rt_nat_divmod` 3.0%).
2. Every `Map.set` did two full tree traversals (`Map.seek` + `Map.put`/`Map.ins`), rebuilding every `MNode` along the path and re-traversing the `String` key from the head at every `MNode` to compute `Map.bit(key, pos)` via `Nat` division by 33.
3. `Char` (`Chr{code: U32}`) is unboxed as a raw `TAG_NUM` (`head >> 32 == 0`) by Bend2's newtype representation, while `String` (`SCon{head, tail}`) can be `TAG_CTR` or `RFC|TAG_CTR`.

## Design (`AGY-W2C-1`)

- **Book certification (`agy_map_book_ok`)**: Verifies Base's exact `Map` (`MTip/0`, `MLeaf/2`, `MNode/3`), `String` (`SNil/0`, `SCon/2`), `Char` (`Chr/1`), `Sigma` (`Tuple/2`), and `Map.{set,set.go,seek,put,ins,diff,bit,del,pop,get,get.go}` definitions in `book` before marking `$direct.Map.set`, `$direct.Map.del`, and `$direct.Map.get`.
- **Single-pass in-place x86 wrappers** (preserving `agy_map_slow_<sym>` as exact fallback):
  - **Live descriptor guards**: Checks `p111_program.capabilities & 9 == 9` and `!cid_hot[mleaf]` / `!cid_hot[mnode]` (for `set`/`del`) or `!cid_hot[tuple]` (for `get`) before any stack setup.
  - **Key unpacking**: Unpacks `key` once into a 64-char stack buffer `u32[64]` (handling unboxed `U32`, `TAG_PAK`, `TAG_CTR`, and `RFC|TAG_CTR` `SCon`/`Chr`). Bails cleanly on keys `>= 64` chars or unknown tags.
  - **O(1) `Map.bit(key, pos)`**: Exact magic multiply-shift `ci = (pos * 0xf83e0f84) >> 37`, `off = pos - ci * 33` (exact for all `pos < 65536`; guarded `pos < 2112`). Zero `divq` and zero string re-traversal.
  - **`Map.set`**: Descends uniquely owned cold heap `MNode`s (`TAG_CTR`, `loc >= HEAP_OFF`), recording `(slot_ptr, pos)` on the local stack (`depth < 64`). At `MLeaf`, compares key & computes `Map.diff` in one pass:
    - **Hit**: Overwrites `leaf.val` in-place (0 allocations), drops old `key` and `old_v` via `p111_rt_sink`.
    - **Miss**: Verifies class-1 and class-2 freelists non-empty before any mutation, allocates 1 `MLeaf` + 1 `MNode`, splices at the first `path[i].pos > diff`.
  - **`Map.del`**: Descends uniquely owned cold heap `MNode`s, tracking parent/grandparent slots. On hit, verifies `KEEP_WORDS` bounds (`len + 2 < 32768`, `len + 4 < 32768`) before mutating, frees `MLeaf` + parent `MNode` to class-1/2 freelists, splices sibling in-place, and drops `key`, `leaf_k`, `leaf_v` via `p111_rt_sink`.
  - **`Map.get`**: Read-only descent supporting both `TAG_CTR` and `RFC|TAG_CTR` / static maps; returns `Tuple{m, v}` when `v` is trivial (`tag < 2`) and bails cleanly on non-trivial heap values so RFC refcounts stay exact.

## Falsified Attempt (Preserved)

- **Hot-RFC in-place `Map.set` (`cid_hot != 0` via `p125_rt_ctor2/3` + `rc == 1` unwrapping)**: Attempted to also fire on `coverage-record-aggregation-64/256` where `p111_cid_hot` marks all ctors hot. Failed `map_rfc_shared` and `map_edge_keys` in adversarial testing and did not beat baseline on `record-aggregation` (which Track D already solved for `-626 ms`). Reverted cleanly to the cold-only fast path, restoring `25/25 PASS`.

## Verification Evidence

- Command: `python3 /home/ai/bend2_agy/research/agy/wave2c_map/verify_w2c.py --api /home/ai/bend2_agy/selfhost/build/agy/wave2c_map/api.mjs`
- Result: **25 / 25 PASS**:
  - `6/6` adversarial upstream Bend differential tests (`map_rfc_shared`, `map_static_root`, `map_edge_keys`, `map_long_key_bailout`, `map_heap_values`, `map_get_shared_unicode`)
  - `19/19` `focused19` qualification cases
- Composition command:
  ```bash
  python3 /home/ai/bend2_agy/research/agy/wave2c_map/apply_map_fast.py --src <prev_compiler.bend> --dst <next_compiler.bend>
  ```

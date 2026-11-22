# Wave 2C: Record Aggregation (`Map`) & List/Array Fast Paths

## Executive Summary

Wave 2C targeted the **998 ms** Record Aggregation + Generic Row32 pool (`coverage-record-aggregation-256`, `coverage-record-aggregation-64`, `complete-generic-row32`), plus bonus `coverage-map-churn-128`.

We designed and implemented **three general, sound, composable native x86 compiler passes** in two standalone patchers under `/home/ai/bend2_agy/research/agy/wave2c_recagg/`:

1. **`AGY-W2C-MAPFAST`** ([apply_map_fast.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_map_fast.py)): Certified native x86 fast paths for `Map.get` and `Map.set` with inline magic-`/33` `Map.bit`, inline `String` equality, and **uniquely-owned RFC (`tag == 0x82 && (rc_word & 0xffffff) == 1`)** in-place update on `Map.set`.
2. **`AGY-W2C-LISTAPP`** ([apply_list_arr.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_list_arr.py)): General, purely structural zero-stack-frame in-place owned list/string append for any TRMC worker (`$p118.trmc.*`) matching `Nil => finish(b); Con{h, t} => take(a, 2); extend(Con, [h], 1); again(t, b, ...)`. Works on `String.append`, `List.append`, and any user-defined list ADT.
3. **`AGY-W2C-ARRLIST`** ([apply_list_arr.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_list_arr.py)): Certified native x86 fast path for `Array.to_list.go` on raw `Array<U32>` (`tag == 0x04`), eliminating binary-tree `Array.split` / `p111_rt_special_take` / `p114r` frame churn.

### Benchmark Results (CPU-2 alternating medians vs Unified Baseline)

| Case | Unified Baseline (ms) | Cand/Base Ratio | Projected New (ms) | Est. Saved (ms) |
|---|---:|---:|---:|---:|
| `coverage-record-aggregation-256` | 352 | **0.211x** (4.74x faster) | 74 | **-278 ms** |
| `coverage-record-aggregation-64` | 334 | **0.274x** (3.65x faster) | 92 | **-242 ms** |
| `complete-generic-row32` | 312 | **0.735x** (1.36x faster) | 229 | **-83 ms** |
| **Target Pool Subtotal (3 cases)** | **998** | **0.396x** | **395** | **-603 ms** |
| `coverage-map-churn-128` (bonus) | ~120 | **0.812x** (1.23x faster) | ~97 | **-23 ms** |

Measured alternating medians (`bench_compare.py`, 3 rounds, CPU-2, exact stdout verified):
- `complete-generic-row32` (`reps=768`): `230.0 ms -> 169.0 ms` (`0.735x`)
- `coverage-record-aggregation-256` (`reps=768`): `1174.0 ms -> 248.0 ms` (`0.211x`)
- `coverage-record-aggregation-64` (`reps=896`): `413.0 ms -> 113.0 ms` (`0.274x`)
- `coverage-map-churn-128` (`reps=192`): `207.0 ms -> 168.0 ms` (`0.812x`)
- **4-case GEOMEAN**: **`0.4309x`**

## Root Causes Diagnosed (via SIGPROF + `objdump`)

1. **`coverage-record-aggregation-256` & `-64` (686 ms, 2.17–2.27x C)**:
   - `Map.get`, `Map.get.go`, `Map.set`, `Map.seek.go`, and `Map.put.go` all ran in `p111_` continuation-passing style, allocating continuation frames and rebuilding every `MNode` on the path even on read-only `Map.get` and existing-key `Map.set` updates.
   - At every trie level, `Map.bit(key, pos)` called `Nat.divmod(pos, 33n)` and walked `String` recursively.
   - **Critical runtime discovery**: `p125_rt_ctor3` allocates `&2`-quantified constructors (`Map<&2, V>`, `String`) as **RFC-boxed (`tag == 0x82`) with `rc == 1`**. Checking `tag == 0x02 || (tag == 0x82 && (heap[rfc_loc] & 0xffffff) == 1)` unlocked in-place updates on uniquely-owned `Map<&2, V>` and `String`, dropping `coverage-record-aggregation-256` from `0.702x` (with `Map.get` alone) to **`0.211x`** (**4.74x faster**, ~0.48x C!).
   - **Falsified hypothesis**: `x86_reg/apply.py` `apply_caps` regressed `coverage-record-aggregation-256` (`1.028x`), `-64` (`1.040x`), and `coverage-map-churn-128` (`1.032x`), so it was rejected.
2. **`complete-generic-row32` (312 ms, 2.68x C)**:
   - SIGPROF showed `30.0%` in `p118_rt_extend1` (TRMC `String.append` freeing owned `SCon` cells via `p125_rt_take2` only to immediately reallocate identical `SCon` cells via `p118_rt_extend1`) and `~13%` in `p114r_$direct.Array.to_list.go~0` + `p111_rt_special_take` (508 binary-tree `Array.split` calls per rep on 128-slot raw `Array<U32>`).
   - `AGY-W2C-ARRLIST` (`0.866x`) + `AGY-W2C-LISTAPP` (`0.735x`) cut 83 ms off `complete-generic-row32` and also accelerated `String.append` in `coverage-record-aggregation-*`.

## Soundness & Verification

- **Adversarial differential tests vs upstream Bend (`bun bend2/main.ts`)** ([test_w2c_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/test_w2c_adversarial.py)): **5/5 PASS**:
  1. `map_shared_immutability`: Shared `+m0` (`rc >= 2`) mutated via `Map.set` -> `m0` completely unchanged (`"50,10,42|9999,8888,7777"`).
  2. `map_unicode_prefix_wraparound`: Empty map, prefix keys (`""`, `"a"`, `"ab"`), Unicode keys (`"部門0"`, `"部門10"`), `U32` wraparound (`4294967295 + 5 = 4`) (`"77,1,2,3,4,100,99"`).
  3. `map_boxed_string_values`: Heap-boxed `String` values in `Map<&2, String>` (tests `p111_rt_keep` on hit and `p111_rt_sink` on overwrite) (`"ALPHA_NEW|beta|MISS"`).
  4. `list_string_append_shared_and_renamed`: Shared `String` prefix, shared tail inside owned prefix, empty LHS/RHS, and user-defined renamed list ADT (`MySeq`/`MyNil`/`MyCon`) both owned and shared (`"hello|hello_world|hello_bend|ABTAIL_1|XYTAIL_2|rhs|lhs|6,16,26"`).
  5. `array_tolist_edges`: 1-element and 16-element raw `Array<U32>`, non-empty `acc`, and boxed `Array<String>` bailout (`"42,1136,136|xy"`).
- **Focused19 qualification suite**: **`19 / 19 PASS`** (including all 3 expected-reject negative tests).
- **Full 6-pass composition check**: Composed `unified/compiler.bend` + `apply_rorec.py` + `apply_dp_loop.py` + `apply_f32_loop.py` + `apply_dead_arr_scan.py` + `apply_map_fast.py` + `apply_list_arr.py` -> **cleanly patched & typechecked (`Checked 5361 API exports`)** with zero anchor conflicts.

## Patcher Paths

- `/home/ai/bend2_agy/research/agy/wave2c_recagg/apply_map_fast.py` (`AGY-W2C-MAPFAST`)
- `/home/ai/bend2_agy/research/agy/wave2c_recagg/apply_list_arr.py` (`AGY-W2C-LISTAPP` + `AGY-W2C-ARRLIST`)
- `/home/ai/bend2_agy/research/agy/wave2c_recagg/test_w2c_adversarial.py`

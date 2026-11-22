# Tier-2 Adversarial & Conformance Audit: Wave 2C-RecAgg

**Audit Target:**
- `AGY-W2C-MAPFAST`: [apply_map_fast.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_map_fast.py)
- `AGY-W2C-LISTAPP` + `AGY-W2C-ARRLIST`: [apply_list_arr.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_list_arr.py)
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/test_tier2_adversarial.py)

## Overall Verdict: **PASS — CLEARED FOR TIER-3 INTEGRATION (POST-FIX)**

1. **Initial audit (`FAIL`)**: Caught **two real bugs** in `AGY-W2C-MAPFAST` (plus a matching defense-in-depth gap in `AGY-W2C-LISTAPP`):
   - **Bug A — Missing `loc >= HEAP_OFF` check (static term corruption)**:
     - `agy_map_set_fast` mutated static `MLeaf{"k", 10}` (`tag == 0x02`, `loc < HEAP_OFF`) in-place, permanently corrupting `static_map()` for all future calls (`mapset_static_map_corruption`: expected `3027`, observed `5994`).
     - Same missing `loc >= HEAP_OFF` guard in `agy_map_get_fast` before writing `p111_rt_keep(v)` back into `heap[leaf_loc + 1]`, and in `agy_la_emit_fast` (`apply_list_arr.py`) before patching `heap[loc + 1] = b`.
   - **Bug B — Unsealed `0x02` value stored into `0x82` `MLeaf` (double-free / fail-stop)**:
     - `agy_map_set_fast` stored raw `%r15` (`x`) directly into `heap[leaf_loc + 1]` without checking if `x` is an unsealed boxed value (`tag >= 2 && tag != 130`). Storing a freshly allocated `0x02` `String` into an `0x82` `MLeaf` and then sharing the map caused `bend: runtime fail-stop` (`mapset_unsealed_val_into_shared_map`).
2. **Fixes applied & verified (`PASS`)**:
   - Added `loc >= HEAP_OFF` (`((p111_program[64] + 127) & ~127) + 51413504`) guards to `agy_map_set_fast`, `agy_map_get_fast` (before writeback), and `agy_la_emit_fast`.
   - Added `(tag(x) < 2 || tag(x) == 130)` guard at `l_hit` in `agy_map_set_fast` before mutating `heap[loc + 1]`, cleanly bailing with zero mutation to `slow` (where `p111_rt_ctor` runs `rfc_seal`) for unsealed boxed values.
   - Rebuilt `/home/ai/bend2_agy/selfhost/build/agy/wave2c_recagg/api_w2c.mjs` (`Checked 4 API exports`) and verified **4/4 `test_tier2_adversarial.py` PASS** + **5/5 `test_w2c_adversarial.py` PASS**.

---

## 1. Other Soundness Checks (Verified Clean)
- **`Map.bit` magic-`/33`**: Verified `(pos * 0xF83E0F84) >> 37 == floor(pos / 33)` is exact for all `0 <= pos < 2^32`, and `pos >= 2^32` bails cleanly. Verified on >38-char keys (`pos >= 1100`), empty key `""`, and multi-byte Unicode keys (`map_long_keys_and_shared_child`: `101,202,303,404,606|9999`).
- **Overwriting boxed values in `Map.set`**: Verified `old_v` (`%r8`) and `key` (`%r14`) are sunk via `p111_rt_sink` whenever `tag >= 2`.
- **`AGY-W2C-ARRLIST`**: Verified `mode == 0`, `tag == 4`, `cls <= 24`, `loc >= 1`, calls `p125_rt_ctor2` (preserving `cid_hot` / `capabilities`), and sinks `a` via `p111_rt_sink`.

---

## 2. Verification Results
- **Hosted-B1 Conformance**:
  - `native64`: **64 / 64 PASS** (97.62s)
  - `runtime10`: **10 / 10 PASS** (6.57s)
  - `boundary13`: **13 / 13 PASS** (7.43s)
- **Tier-2 Adversarial (`test_tier2_adversarial.py`, post-fix, upstream == Phase 205 == `api_w2c.mjs`)**: **4 / 4 PASS**
  - `listapp_static_string_corruption`: **PASS** (`80`)
  - `mapset_static_map_corruption`: **PASS** (`3027`, fixed from `5994`)
  - `mapset_unsealed_val_into_shared_map`: **PASS** (`abcdef|abcdef|512`, fixed from `bend: runtime fail-stop`)
  - `map_long_keys_and_shared_child`: **PASS** (`101,202,303,404,606|9999`)
- **Wave 2C Adversarial (`test_w2c_adversarial.py`, post-fix)**: **5 / 5 PASS**

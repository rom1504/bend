# Tier-2 Adversarial & Conformance Audit: Wave 2C-Map (`AGY-W2C-1`)

- **Verdict**: **PASS (CLEARED for Tier-3 integration)**
- **Audit Target**:
  - Patcher: `/home/ai/bend2_agy/research/agy/wave2c_map/apply_map_fast.py`
  - Candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2c_map/api.mjs`
  - Runtime: `/home/ai/bend2_agy/selfhost/build/agy/unified/runtime-agy.o`
- **Fresh Adversarial Suite**: `/home/ai/bend2_agy/research/agy/wave2c_map/test_tier2_adversarial.py` (**5/5 PASS**, `upstream == Phase205 == Wave 2C-Map`)
- **Full Hosted-B1 Conformance**:
  - `native64`: **64/64 PASS** (185.10s)
  - `runtime10`: **10/10 PASS** (16.20s)
  - `boundary13`: **13/13 PASS** (20.10s)
  - Receipt: `/home/ai/bend2_agy/selfhost/build/agy/tier2_audit_w2c_map/conformance_report.json`

## 1. Code & Soundness Audit Summary

1. **Static Map Guard (`loc >= HEAP_OFF`)**:
   - Both `agy_map_set_machine` (lines 378, 418) and `agy_map_del_machine` (lines 616, 644) compute `HEAP_OFF = ((static_words + 127) & ~127) + 51413504` into `%r14` and check `loc >= HEAP_OFF` on EVERY `MNode` and `MLeaf` before any mutation.
   - Verified with static `MNode`/`MLeaf` mutated in a loop (`1_map_static_and_shared_sibling_del`).
2. **RFC / Unsealed `0x02`-in-`0x82` Invariant (Bug #7 check)**:
   - `agy_map_set_machine` checks `!cid_hot[mleaf]` and `!cid_hot[mnode]` (lines 324–332).
   - Both `agy_map_set_machine` (lines 366–371) and `agy_map_del_machine` (lines 607–612) match strict cold `0x02` (`mleaf_chk` / `mnode_chk`, NO `0x7fffff` mask), immediately bailing on any `0x82` (RFC-shared) `MNode` or `MLeaf`.
   - Newly allocated `MLeaf`/`MNode` are tagged cold `0x02` (`mleaf_hi`/`mnode_hi`), never `0x82`, so an unsealed `0x02` value is never stored into an `0x82` container.
   - Verified with freshly allocated `0x02` `String` values stored into `Map`, overwritten, and subsequently shared via `+m` (`4_map_unsealed_heap_val_then_share`).
3. **`Map.del` All Tree Shapes & Refcount/Value Dropping**:
   - Verified `MTip` root -> sinks `orig_key`, returns `MTip`.
   - Verified single-leaf root (`parent_loc == 0`) -> frees `leaf_loc` to class 1, returns `MTip`, sinks `orig_key`, `leaf_k`, `leaf_v`.
   - Verified 2-leaf root (`parent_loc != 0, parent_slot_ptr == 0`) -> frees `leaf_loc` + `parent_loc`, returns `sibling_term` (preserving any `0x82` RFC refcount on `sibling_term` unchanged).
   - Verified deep branch collapse (`parent_slot_ptr != 0`) -> splices `sibling_term` into `*parent_slot_ptr`, returns `orig_m`.
   - Checks `ALC_LEN[1] + 2 < 32768` and `ALC_LEN[2] + 4 < 32768` (`KEEP_WORDS`) before any mutation.
   - Verified in `1_map_static_and_shared_sibling_del` and `2_map_del_all_shapes_and_heap_vals`.
4. **Key Boundaries, Long Keys (`> 33` / `63` / `64` / `65` chars), Empty Key `""`, Unicode & Live Descriptor Guards**:
   - `agy_map_unpack_chr` handles unboxed `U32`, `TAG_PAK`, `TAG_CTR`, and `RFC|TAG_CTR` `Chr` (including 32-bit Unicode codepoints like `U+1F600`).
   - `agy_map_bit_at` magic constant `0xf83e0f84` (`(pos * 0xf83e0f84) >> 37`) is exact for all `pos < 2112`; guarded `cmpq $2112, %rax; jae l_bail` cleanly handles `klen = 64` vs `leaf_k` len 65 (`diff = 64 * 33 = 2112 -> bail`).
   - Live descriptor guard `p111_program.capabilities & 9 == 9` checked at entry of all 3 machines (`set`, `del`, `get`); `cid_hot[tup] == 0` checked at entry of `get`.
   - Verified in `3_map_key_len_63_64_65_and_unicode` and `5_map_heavy_churn_200_keys`.

## 2. Adversarial Differential Test Summary (`test_tier2_adversarial.py`)

| # | Test Case | Status (`upstream == Phase205 == Wave 2C-Map`) |
|---|---|---|
| 1 | `1_map_static_and_shared_sibling_del` | **PASS** |
| 2 | `2_map_del_all_shapes_and_heap_vals` | **PASS** |
| 3 | `3_map_key_len_63_64_65_and_unicode` | **PASS** |
| 4 | `4_map_unsealed_heap_val_then_share` | **PASS** |
| 5 | `5_map_heavy_churn_200_keys` | **PASS** |

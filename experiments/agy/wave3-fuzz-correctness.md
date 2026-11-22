# Wave 3 — Track Q1: Differential Fuzzer & Live-Metadata Observer Gate

- **Target Compiler**: `wave2_unified/api.mjs` (14 Wave 1 + Wave 2 passes) + `unified/runtime-agy.o`
- **Oracles**:
  - Upstream Bend (`bun bend2/main.ts`)
  - Phase 205 Baseline (`api-base/api.mjs` + `runtime-live-scan.o`, used for isolation)
- **Fuzzer Script**: [fuzz_diff.py](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/fuzz_diff.py) + [batch_emit.mjs](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/batch_emit.mjs)
- **Observer Gate**: [observer_wave2_gate.py](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/observer_wave2_gate.py) + [observer_gate_hook.c](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/observer_gate_hook.c)
- **JSON Receipt**: [wave3-fuzz-report.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave3-fuzz-report.json)

---

## Executive Summary

| Gate | Scope | Result | Verdict |
|---|---|---|---|
| **Grammar-Based Differential Fuzzer** | **245 distinct random Bend programs** (`35/family × 7 families`, seed `20261122`) | **245 / 245 PASS** (`0` wrong-code mismatches, `0` crashes) | **PASS** |
| **Runtime ABI + `observer.c`** | `abi-contract.c` + `observer.c` (`owner-hot`, `owner-cap`) on `runtime-agy.o` | **44 + 2 / 46 PASS** | **PASS** |
| **Wave 2 Boot-Time Live-Metadata Gate** | 5 fast-path probes × 3 modes (`normal`, `cap-no8`, `all-hot`) | **15 / 15 PASS** (`0` unsealed-child violations) | **PASS** |
| **Mid-Execution Live `cid_hot` Mutation Probe** | Live `cid_hot[MNode]=1` toggled between `Map.set` and `Map.del` | **FOUND & FIXED** (`violations=2` → **`violations=0`** post-fix) | **FIXED & PASS** |
| **Static Assembly Audit of Dormant Pass** | `AGY-W2C-LISTAPP` (`apply_list_arr.py`) | **2 LATENT BUGS FIXED** (`capabilities & 9`, `!cid_hot[con]`, `tag == 0x02` only) | **FIXED & PASS** |

---

## 1. Grammar-Based Differential Fuzzer (`245 / 245 PASS`)

All 245 deterministically generated programs (35 per family, base seed `20261122`, per-family seed `20261122 + family_idx * 100003`) achieved **bit-exact stdout equality** between Upstream Bend and Wave 2 Unified:

| Family | Target Passes | Programs | Pass | Mismatches | Notes |
|---|---|---:|---:|---:|---|
| `1_ctfe_arith` | `CTFE`, `AGY-005a/b`, `AGY-001` | 35 | **35** | 0 | Closed + dynamic nested `U32`/`Nat`/`F32`/`Bool`/`String`; `0`, `1`, `U32.max-1`, `U32.max`, `Succ{U32.to_nat(4294967295)}`, `-0.0`, `NaN`, `±Inf`, shifts `0..35`, `div/mod 0` |
| `2_rorec_adt` | `AGY-W2-ROREC` | 35 | **35** | 0 | 1-arg & 2-arg read-only recursive ADT→`U32` evaluators; nested LHS/RHS binops, diamond `0x82` DAGs, depths `0..300` crossing `budget=256`, post-call non-certified observer reuse |
| `3_f32_xmm` | Track A (`F32`/`XMM`/Tables/Fused compares), `AGY-W2B-F32LOOP` | 35 | **35** | 0 | `1..9` invariant & carried `F32` loop params, `F32.sqrt` edges, all 6 `F32.is_*` compares across XMM-clobbering calls, `F32.to_u32`, non-commutative `sub`/`div`, in-bounds & OOB table lookups |
| `4_map_ops` | `AGY-W2C-1` (`Map.set`/`get`/`del`), `AGY-W2C-MAPFAST` | 35 | **35** | 0 | Random 12..36 op sequences over `U32` & heap `String` values; empty/short/63/64/65/70-char/Unicode keys, static base maps, mid-sequence `+m` sharing snapshots |
| `5_bst_flow_reuse` | `AGY-W2B-1` (`Perceus`), `AGY-W2B-3` (`BST Zipper`), `AGY-W2B-4` (`flow`) | 35 | **35** | 0 | Random BST insert sequences (dups, `0`/`U32.max`, short fuel `0n..20n`, `Succ{U32.to_nat(U32.max)}`, partial-descent shared `0x82` subtrees, static trees) + `flow`/`warp` (depths `0..70`, `Node{sub,sub}`) + `Box3` reuse |
| `6_w2d_list_arr` | Track D (`W2D` `foldl` + `U32` intervals), `LISTAPP`, `ARRLIST` | 35 | **35** | 0 | Multi-builder `String` `foldl`, `U32` interval wraparound near `U32.max` + `mod 0`, fresh/shared/static `List.append`, `Array.to_list` on raw `Array<U32>` (`1..64`) and boxed `Array<String>` |
| `7_dp_deadarr` | `AGY-W2-DPLOOP`, `AGY-W2B-DEADARR` | 35 | **35** | 0 | 1D stencil `row` (`K ∈ {1..32}`, `n ∈ {0,1,K-1,K,K+1}`, `j` wraparound `4294967290`/`4294967295`, `U32.max` cells, multi-row swaps) + dead-array & live-array scans (`step 1` & `step 2`) |
| **TOTAL** | **All 14 Wave 1 & Wave 2 Passes** | **245** | **245** | **0** | Initial 245-program run had 1 generator linearity error (`7_dp_deadarr__028` used `+sh_prev` on linear `Array<U32>`, rejected identically by both upstream and Wave 2); fixed generator and re-ran `7_dp_deadarr` (`35/35 PASS`) |

---

## 2. Live-Metadata `observer.c` Gate & Fast-Path Audit

### 2.1 Runtime ABI + `observer.c` (`44 + 2 / 46 PASS`)
- Linked `research/phase198/runtime-broad/observer.c` + `selfhost/tests/phase183/abi-contract.c` against `selfhost/build/agy/unified/runtime-agy.o`.
- All **44** ABI contract checks + **2** live mutable metadata controls (`owner-hot`, `owner-cap` → `sealed 1 field 13`) **PASSED**.

### 2.2 Wave 2 Fast-Path Live-Metadata Matrix

| Wave 2 Fast Path | `capabilities & 9 == 9` | `!cid_hot[...]` | Boot-Time Gate (`normal` / `cap-no8` / `all-hot`) | Mid-Run Live `cid_hot` Mutation | Status |
|---|---|---|---|---|---|
| `AGY-W2B-1` Perceus Reuse (`apply_reuse.py`) | Checked (`take_reuse` & `ctor_reuse` normal) | Checked (`!cid_hot[target_ctor]`) | **3/3 PASS** | Safe (no call/IO between `take_reuse` and `ctor_reuse`) | **CLEAN** |
| `AGY-W2B-3` BST Zipper (`apply_bst_zipper.py`) | Checked (lines 300–303) | Checked (`!cid_hot[node]`, lines 304–308) | **3/3 PASS** | Safe (bails to `slow` on entry) | **CLEAN** |
| `AGY-W2B-4` Bitonic `flow` (`apply_flow_native.py`) | Checked (lines 195–198) | Checked (`!cid_hot[node]`, lines 199–203; `Leaf` has only unboxed `U32`) | **3/3 PASS** | Safe (bails to `slow` on entry) | **CLEAN** |
| `AGY-W2C-1` `Map.set` (`apply_map_fast.py`) | Checked (lines 320–323) | Checked (`!cid_hot[mleaf]`, `!cid_hot[mnode]`, lines 324–332) | **3/3 PASS** | Safe (bails to `slow` on entry) | **CLEAN** |
| `AGY-W2C-1` `Map.get` (`apply_map_fast.py`) | Checked (lines 753–756) | Checked (`!cid_hot[tup]`, lines 757–761) | **3/3 PASS** | Safe (bails to `slow` on entry) | **CLEAN** |
| `AGY-W2C-ARRLIST` (`apply_list_arr.py`) | Calls `p125_rt_ctor2` directly | Handled by `p125_rt_ctor2` | **3/3 PASS** | Safe | **CLEAN** |
| **`AGY-W2C-1` `Map.del` (`apply_map_fast.py`)** | Checked (lines 564–567) | **FIXED** (`!cid_hot[mnode]` added, lines 568–572) | **3/3 PASS** | **PASS (`violations=0` post-fix)** | **FIXED** |
| **`AGY-W2C-LISTAPP` (`apply_list_arr.py`)** | **FIXED** (`capabilities & 9 == 9`, lines 160–163) | **FIXED** (`!cid_hot[con_cid]`, lines 164–168) | **3/3 PASS** (dormant) | **FIXED** (`tag == 0x02` only) | **FIXED** |

---

## 3. Bugs Found & Proposed Fixes

### BUG #1 (LIVE, REPRODUCED): `AGY-W2C-1` `Map.del` skips `!cid_hot[mnode]` live-metadata guard

- **Location**: [apply_map_fast.py](file:///home/ai/bend2_agy/research/agy/wave2c_map/apply_map_fast.py#L563-L568) (`agy_map_del_machine`, lines 563–568 & 691–696).
- **Root Cause**: `agy_map_del_machine` checks `capabilities & 9 == 9` on entry, but omits the `!cid_hot[mnode]` check present in `agy_map_set_machine` (lines 324–332). When `cid_hot[MNode]` is mutated live to `1` after `Map.set` builds an unsealed `0x02` map (the exact `observer.c` `owner-hot` contract), `Map.del` still takes the fast path, collapses a child `MNode`, and splices the unsealed `0x02` sibling directly into the parent `MNode` (`movq %rbx, (%r9)` on line 695). By contrast, the slow path (`Map.del.go`) reconstructs the parent `MNode` via `p125_rt_ctor3`, which sees `cid_hot[MNode] == 1` and seals its children (`0x82`).
- **Minimal Reproducer**:
  - [repro_mapdel_livehot.bend](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/repro_mapdel_livehot.bend)
  - [repro_mapdel_livehot_hook.c](file:///home/ai/bend2_agy/research/agy/wave3_fuzz/repro_mapdel_livehot_hook.c)
  - Observed output on `wave2_unified/api.mjs` + `runtime-agy.o`:
    ```text
    [HOOK] Armed cid_hot[MNode=45]=1 after 3rd MNode return!
    [HOOK] Post-Map.del MNode child[1]: tag=0x02 cid=45
    [HOOK] Post-Map.del MNode child[2]: tag=0x02 cid=44
    2862221093
    [HOOK] mnode_returns=3 armed=1 violations=2
    ```
- **Proposed Fix** (5 instructions in `agy_map_del_machine`, right after line 567 of [apply_map_fast.py](file:///home/ai/bend2_agy/research/agy/wave2c_map/apply_map_fast.py#L563-L568)):
  ```bend
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{mnode,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
  ```
- **Post-Fix Verification (APPLIED & RECOMPOSED)**:
  - Applied both fixes, recomposed `selfhost/build/agy/wave2_unified/compiler.bend` (2,475,442 bytes) via `compose_wave2.py`, and rebuilt `wave2_unified/api.mjs` via `stage0-library.mjs` (`Checked 5817 API exports`).
  - Re-ran `repro_mapdel_livehot`:
    ```text
    [HOOK] Armed cid_hot[MNode=45]=1 after 3rd MNode return!
    2862221093
    [HOOK] mnode_returns=2 armed=1 violations=0
    ```
  - Re-ran `observer_wave2_gate.py`: **44 + 2 / 46** ABI + `observer.c` PASS, **15 / 15** Wave 2 live-metadata probes PASS (`0 violations`).

### BUG #2 (LATENT / DORMANT): `AGY-W2C-LISTAPP` missing live-metadata guards & RFC `0x82(rc=1)` child-sealing violation

- **Location**: [apply_list_arr.py](file:///home/ai/bend2_agy/research/agy/wave2c_recagg/apply_list_arr.py#L147-L218) (`agy_la_emit_fast`).
- **Why Currently Dormant**: `agy_la_scan_con` (line 71) checks `String.eq(sym, "p111_rt_take")`, whereas `$p118.trmc.*` functions have already been specialized to `p125_rt_take2` before `x181_direct` runs. Thus `LISTAPP` never fires in `wave2_unified`.
- **Two Latent Soundness Bugs if Ever Activated**:
  1. **Live-metadata bypass**: `agy_la_emit_fast` checks neither `p111_program.capabilities & 9 == 9` nor `!p111_program.cid_hot[con_cid]`, mutating `heap[loc + 1] = b` in-place without sealing `b`.
  2. **RFC `0x82` child-sealing violation (`ERR_RFCS`)**: Lines 183–190 accept `tag == 0x82` with `rc == 1`, then line 211 writes an unsealed `0x02` tail `b` (`%rdx`) directly into `heap[loc + 1]` while returning the `0x82` root. If the returned `0x82` list is subsequently shared (`+r`, incrementing `rc` 1→2) and taken via `p125_rt_take2`, `span_fade` in [runtime.c](file:///home/ai/bend2_agy/selfhost/src/runtime/qbe/runtime.c#L1062-L1071) sees `!term_rfc(f) && !term_triv(f)` inside an `0x82` node and posts fatal **`ERR_RFCS`**.
- **Proposed Fix**: If `LISTAPP` is ever enabled (or cleaned up), add `capabilities & 9 == 9` and `!cid_hot[con_cid]` entry guards and restrict the in-place walk to `tag == 0x02` only (bailing to `slow_sym` on any `0x82` node).

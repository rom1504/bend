# P5-D Report: Fast `x86-iface` — Eliminating Redundant Lowering, Duplicate Parsing, and Redundant `.p130` Encoding

**Status:** **PASSED (100% bit-for-bit identical `.p130` on `m00..m02`; 11/11 exact match to Phase 4 across `m00..m10`; 100% bit-for-bit SHA-256 identical `m11.o` emitted by native `n3_w10` from the fast `m10.p130`; `--check-only` 0 type errors across all 8,669 defs)**

- **Pure-Bend patch:** `research/agy/w10_mod_bend/p5_fast_iface/fast_iface_emit.bend` (0 new types, 0 JS, 0 C, 0 `runtime.c` changes)
- **Build & test driver:** `research/agy/w10_mod_bend/p5_fast_iface/build_and_test.py`
- **Machine-readable results:** `research/agy/w10_mod_bend/p5_fast_iface/results.json`
- **Isolation:** CPU `6` (`taskset -c 6`), `ulimit -s 262144` for native `n3_w10`, read-only on `selfhost/build/agy/wave10_unified/` and `research/agy/w10_mod_bend/k12_wave10/`.

---

## 1. Diagnosis: Where Baseline `x86-iface` Spent Its Time

Fine-grained stage profiling of `wave10_unified/api.mjs` (`w10_iface_request`) on `m00`, `m01`, `m02` (CPU `6`) revealed **four major bottlenecks**:

| Stage | `m00` (ms) | `m01` (ms) | `m02` (ms) | Root Cause |
|---|---:|---:|---:|---|
| `p86_plan` | 72,501.9 (46.6%) | 17,585.7 (27.2%) | 17,710.6 (24.9%) | Parses + checks + annotates full module |
| **`w10_if_load_suffix`** | **43,817.9 (28.2%)** | **3,314.1 (5.1%)** | **3,406.3 (4.8%)** | **Duplicate full parse!** Re-parses the exact same source already parsed inside `p86_plan` |
| **`p168_request_mode`** | **28,123.1 (18.1%)** | **19,747.4 (30.6%)** | **18,793.3 (26.4%)** | Runs full `w4p` unboxing, `p168_closed` inlining/scalar retry, and **`p111_program` full CPS lowering** |
| **`p169s_lowered` + `x198pw_after`** | **3,618.7 (2.3%)** | **4,436.7 (6.9%)** | **5,020.7 (7.1%)** | Runs full IR verification, runtime tables, fusion index, region registry, and 7 x86 annotation passes — **0 ABI diff** |
| `base_prefix_resume_saved` + `world_prepare` | 1,759.1 (1.1%) | 7,801.3 (12.1%) | 9,528.5 (13.4%) | Re-replays `base_state` from scratch instead of resuming `base_world` |
| **`enc_book` + `enc_state` + `enc_world` + `enc_ready`** | **4,896.9 (3.1%)** | **10,596.9 (16.4%)** | **15,270.1 (21.5%)** | Re-walks `s_book` **6×** across `s_book`, `world.{prefix,final,book,checked,seen}`, and `s_ready.names` + left-associated `++` chains |
| **Profile Total** | **155,584.4** | **64,597.6** | **71,147.1** | — |
| **Baseline Native `n3_w10` CLI (CPU 6)** | **675,954.5** | **186,648.7** | **172,760.2** | Bit-identical to JS baseline |

---

## 2. Four Pure-Bend Optimizations (`fast_iface_emit.bend`)

All four optimizations are 100% pure Bend, add **zero new types**, and preserve **100% bit-for-bit identical `.p130` output**:

1. **Single-Parse (`w10_if_run_prepared` -> `w10_if_run_trace` -> `p86_plan_loaded`)**:
   - Parses the module **once** via `f_prefix_complete_ready_seed` + `f_prefix_complete_source` + `f_prefix_graph_trace`, passing `load: FPrefixLoad` directly into `p86_plan_loaded(seed, load)` and reusing `load.suffix` directly.
   - Eliminates `w10_if_load_suffix` completely (`-43.8 s` on `m00`, `-3.3 to -3.4 s` on `m01..m10`).
2. **Direct-ABI-Only Lowering (`w10_if_fast_abi_req` / `_prep` / `_scan`)**:
   - Computes `W10IfAbi{direct, public}` directly from `p112s_prepare` + `p128br_scan` + `p113pl_candidates` + `p113d_passes`, and builds `public` directly by mapping `req.names` through `p113d_public(book, name)` (`w10_if_add_public_names`).
   - Completely skips `p111_runtime_admission`, `p167ob_permission`, `p113a_certificate`, `p167ob_seed_verify`, `w4p_adapt_functions`, `p168_closed`/`p169o_closed`, `p167l_functions`/`p111_program` (full CPS lowering!), `p169s_lowered` (IR verification + tables + fusion + registry), and `x198pw_after` (all 7 x86 annotation passes).
   - Verified **`0` ABI diffs** across all defs (`m00`: 1,407 defs / 214 CPS; `m01`: 1,094 defs / 453 CPS; `m02`: 891 defs / 479 CPS).
   - Cuts ABI lowering on `m02` from **`23,814 ms` -> `4,926 ms` (`4.83×` faster)**.
3. **World-Resumed Stub Checking (`base_prefix_resume_world`)**:
   - Replaces `base_prefix_resume_saved(base_state, base_book, fresh_suffix, ...)` with `base_prefix_resume_world(base_world, fresh_suffix, ...)`, reusing `base_world`'s already-prepared `book`, `checked`, and `seen` indexes.
   - Cuts `stub_and_world` on `m02` from **`9,792 ms` -> `5,054 ms` (`1.94×` faster)**.
4. **Zero-Redundancy `.p130` Encoding (`w10_if_w`, `w10_if_enc_book_defs`, `w10_if_enc_world_fast`, `w10_if_enc_ready_fast`)**:
   - Replaces left-associated `w10_if_word(a) ++ w10_if_word(b) ++ ...` chains with zero-copy right-consing `w10_if_w(n, tail)`.
   - Reuses `e1` (`s_state`) and `e0` (`s_book`) node IDs directly for `world.state` and `world.prefix`.
   - Builds an O(1) `def_cache: KDef` (`name -> enc_id`) while encoding `s_book` for every `KDef` whose name appears once in `s_book` and is not in `s_state.patches`, avoiding redundant AST re-traversals across `world.{final,book,checked,seen}` and `s_ready.names`.
   - Cuts `enc_state + enc_world + enc_ready` on `m02` from **`11,848 ms` -> `3,056 ms` (`3.88×` faster)**.

---

## 3. Results & Verification

### 3.1 Same-Load A/B Comparison on CPU 6 (`m00..m02`, JS CLI)

| Mod | Baseline JS (ms) | Fast JS (ms) | Speedup (Same Load) | Saved (ms) | `.p130` Bit-Identical? |
|---|---:|---:|---:|---:|:---:|
| `m00` | 146,012.0 | **107,955.6** | **1.35×** | 38,056.4 | **YES (SHA-256 identical)** |
| `m01` | 60,872.1 | **24,231.2** | **2.51×** | 36,640.9 | **YES (SHA-256 identical)** |
| `m02` | 74,023.2 | **27,158.7** | **2.73×** | 46,864.5 | **YES (SHA-256 identical)** |
| **Sum `m01..m02`** | **134,895.3** | **51,389.9** | **2.62×** | **83,505.4** | **YES** |
| **Sum `m00..m02`** | **280,907.3** | **159,345.5** | **1.76×** | **121,561.8** | **YES (3/3)** |

### 3.2 Full 11-Module Chain (`m00.p130 .. m10.p130`) vs Phase 4 Baseline

*(Note: Phase 4 ran on an idle host; this run executed on CPU `6` alongside 5+ parallel agents sharing L3/DRAM bandwidth.)*

| Mod | Fast JS (ms) | Phase 4 Idle (ms) | Speedup vs P4 Idle | Bytes | Nodes | Strings | Exact P4 Match? |
|---|---:|---:|---:|---:|---:|---:|:---:|
| `m00` | 107,955.6 | 138,652.3 | 1.28× | 5,240,911 | 97,527 | 3,611 | **YES** |
| `m01` | 24,231.2 | 37,390.8 | 1.54× | 7,051,600 | 131,394 | 4,752 | **YES** |
| `m02` | 27,158.7 | 42,361.5 | 1.56× | 8,878,222 | 165,506 | 5,681 | **YES** |
| `m03` | 26,526.1 | 42,004.1 | 1.58× | 10,566,702 | 196,991 | 6,505 | **YES** |
| `m04` | 25,754.8 | 44,063.8 | 1.71× | 12,331,308 | 229,922 | 7,214 | **YES** |
| `m05` | 29,271.6 | 48,452.2 | 1.66× | 14,428,267 | 269,012 | 8,024 | **YES** |
| `m06` | 25,429.6 | 41,471.3 | 1.63× | 16,601,221 | 309,469 | 8,814 | **YES** |
| `m07` | 27,679.0 | 49,105.6 | 1.77× | 18,598,420 | 346,635 | 9,570 | **YES** |
| `m08` | 29,093.9 | 50,619.3 | 1.74× | 20,585,449 | 383,651 | 10,253 | **YES** |
| `m09` | 34,274.1 | 56,995.3 | 1.66× | 22,846,079 | 425,824 | 10,916 | **YES** |
| `m10` | 33,262.2 | 53,666.4 | 1.61× | 24,880,956 | 463,717 | 11,566 | **YES** |
| **Total (`m00..m10`)** | **390,636.8** | **604,782.6** | **1.55×** | — | **44.22%** | **17.65%** | **11/11 YES** |

### 3.3 End-to-End Native Verification (`n3_w10` on `m11` using fast `m10.p130`)
- **`--check-only`** on patched `fast_compiler.bend` (8,669 defs): **PASS (0 type errors, `26,769.8 ms`)**.
- **Native `n3_w10 --trace x86-module-fast`** on `m11` fed our fast `m10.p130`:
  - `rc=0`, `45,009.3 ms`, `6,510,272 B`
  - **`m11.o` SHA-256 == Phase 4 `n3_w10` `m11.o` (`exact_m11_o_sha256 = True`)**.

---

## 4. Cleanup & Disk Hygiene
- `/tmp/agy_p5_iface/` removed.
- `selfhost/build/agy/wave10_unified/` and `research/agy/w10_mod_bend/k12_wave10/` left 100% untouched.

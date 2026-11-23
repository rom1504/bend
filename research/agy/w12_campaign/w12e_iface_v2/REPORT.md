# W12-E Report: Pure-Bend `x86-iface v2` — Eliminating O(K²) `.p130` Hash-Consing, Redundant World Replay, and Upstream Stub Re-Scanning

**Status:** **PASSED (`1.98–2.02×` speedup on `m06`/`m10`, `1.48×` on `m02`; `--check-only` 0 type errors; 100% exact `stamp` match across all tested modules `m01`/`m02`/`m05`/`m06`/`m09`/`m10`; 100% SHA-256 bit-identical downstream `x86-module-fast` `.o` output on `m02.o`, `m07.o`, `m10.o`, and `m11.o`)**

- **Pure-Bend implementation:** [fast_iface_v2.bend](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/fast_iface_v2.bend) (0 new types, 0 JS, 0 C, 0 `runtime.c` changes)
- **Unified patch against `wave11_unified/compiler.bend`:** [w12e_iface_v2.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/w12e_iface_v2.patch)
- **Build & verification driver:** [build_and_test.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/build_and_test.py)
- **Machine-readable results:** [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/results.json)
- **Isolation:** CPU `5` (`taskset -c 5`), hard `timeout 120` per test, read-only on `selfhost/build/agy/wave11_unified/` and `research/agy/w10_mod_bend/k13_wave11/`.

---

## 1. Diagnosis: Sub-Stage Profile of Wave 11 `x86-iface` (`m01`, `m05`, `m09`)

Fine-grained instrumentation of `selfhost/build/agy/wave11_unified/api.mjs` on `m01` (`2,341` base defs), `m05` (`5,780` base defs), and `m09` (`8,823` base defs) on CPU `5` revealed three major remaining bottlenecks totaling **76–77% of non-parse/check runtime**:

| Sub-Stage | `m01` (ms) | `m05` (ms) | `m09` (ms) | % of `m09` | Scaling / Root Cause |
|---|---:|---:|---:|---:|---|
| `read_files` + `p88_cache_prepare` | 522.8 | 974.0 | 1,447.4 | 3.8% | O(K) carrier read & decode |
| `parse_and_load` | 3,037.5 | 3,623.1 | 2,717.4 | 7.2% | O(1) module parse |
| `p86_plan_loaded` (`check` + `annotate_selected`) | 8,533.3 | 8,343.7 | 5,429.1 | 14.3% | O(1) new-module typecheck & annotate |
| `abi_p112s_prepare` | 699.0 | 566.7 | 555.6 | 1.5% | O(1) static prep |
| **`abi_p128br_scan` + `abi_p113pl_and_passes`** | **4,643.1** | **4,299.5** | **5,195.7** | **13.7%** | **Re-scans ~755 upstream stubs** (`58%` of `filtered` on `m09`!) |
| `stub_stamp` + `strip_and_fresh` + `f_ready` | 213.3 | 223.5 | 266.5 | 0.7% | O(1) stubbing + O(K) `f_ready_prefix_prepare` |
| **`stub_base_prefix_resume_world`** | **1,018.9** | **7,512.2** | **2,238.4** | **5.9%** | Re-typechecks already-checked stubbed defs (0 new patches!) |
| **`stub_p86_checked_prefix` + `world_prepare`** | **776.5** | **5,241.3** | **3,638.4** | **9.6%** | **O(K)** full-prefix replay + discarded `ready` check |
| **`enc_book_defs`** | **2,827.6** | **5,188.1** | **7,850.7** | **20.7%** | **O(K)** 425k-entry `rm` Patricia trie hash-consing |
| **`enc_world_fast` + `enc_state_fresh` + `enc_ready`** | **2,790.2** | **4,945.1** | **8,492.2** | **22.4%** | **O(K)** `rm` trie + 6× re-encoding of 319 `base.bend` patches & 889 `law`+`def` pairs |
| **Total Profiled** | **25,066.1** | **40,936.9** | **37,850.4** | **100%** | — |

Key empirical invariants discovered during profiling:
1. **`new_patches == 0`, `delta == 576`, `stamp == 573`, `todos == 0`** across all stub-only modules (`m01`, `m05`, `m09`): `base_prefix_resume_world` produces zero new patches on stubbed `Def`s whose signatures were already typechecked in `p86_plan_loaded`.
2. **`p113pl_candidates` accounts for 91% (`3,724 ms`) of `abi_p113pl_and_passes`**, and **`58.4%` (`755 / 1,293`)** of its inputs are already-stubbed upstream defs from `m00..m_{i-1}`.
3. **319 `base.bend` patched defs and ~889 `law`+`def` pairs** were excluded from Wave 11's `def_cache` and re-encoded 5–6× across `world.{final, book, checked, seen}` and `ready.names`, while every single record performed a `p111v_get`/`p111v_put` in a 425k-entry `rm` Patricia trie.

---

## 2. Three Pure-Bend Optimizations in `fast_iface_v2.bend`

All three optimizations are 100% pure Bend, introduce **zero new types**, and preserve exact `.p130` semantics and downstream `.o` bit-identity:

1. **Zero-`rm` + Complete Multi-Cache `.p130` Encoder (`w10_if_emit_rec`, `w10_if_enc_book_defs2`, `w10_if_enc_final_defs`, `w10_if_enc_world_v2`)**:
   - Pre-allocates `Nil{}` at record `0` (`w10_if_enc_nil` is O(1) with zero allocation) and replaces `w10_if_intern_rec` (`p111v_get`/`p111v_put` on a 425k-entry `rm` Patricia trie) with O(1) `w10_if_emit_rec` consing.
   - Eliminates all redundant `KDef` re-encoding across all 6 views using 4 specialized O(1) caches:
     - `ucache` (unique non-dup `s_book` defs) seeds `fcache`;
     - `fcache` (every def in `world.final`, including merged `law`+`def` pairs) serves `world.book`;
     - `pcache` (`s_state.patches`) + `fcache` serves `world.checked`;
     - `lcache` (last-wins `s_book` defs) serves `world.seen` and `ready.names`.
   - Converts `w10_if_take_batch` from left-associated `acc ++ h` to right-associated `h ++ rest_str` (batch size 128).
   - Keeps `m10.p130` (the largest module of all 11) at **`741,321` nodes (`70.7%` of the `1,048,576` limit — `307,255` nodes of headroom)**, down from `1,022,273` (`97.5%`) before `fcache`/`lcache`.
2. **Incremental O(|suffix|) World & Ready Extension (`w10_if_emit_extended`, `w10_if_ready_extend`, `w10_if_book_put_fast`)**:
   - When `w10_if_all_stub_defs(fresh_suffix)` is `True` (all stubbed `Def`s, zero `ADT`s — true for `m01..m10`), extends `base_world` and `base_ready` directly in O(|suffix|) using `book_put_many_cached` (skipping O(N) prefix validation, `base_prefix_resume_world`, `p86_checked_prefix`, and `base_prefix_world_prepare`).
   - Preserves the exact `base_prefix_resume_world` fallback whenever `ADT`s are present (e.g., `m00`).
3. **Upstream-Stub Fast-Path in `w10_if_fast_abi` (`w10_if_peel_stub`, `w10_if_drop_upstream_stubs`, `w10_if_split_upstream`)**:
   - Strips `Ann` wrappers (`w10_if_strip_ann`) to classify already-stubbed upstream defs in `sbook` in O(1):
     - Direct stub (`λx1..xk. f(x1)...(xk)`) → inserts `(p113d_public(book, name), "P113Direct", k)` directly into `seeded_sigs` for `p113d_passes`;
     - CPS stub (`λx1..xk. let _f = ... in f(x1)...(xk)`) → skips completely;
     - Non-stub `base.bend` defs and all `suffix` defs → analyzed normally.
   - Cuts `p113pl_candidates` input size by ~49–58% with **0 ABI diffs** (`stamp_identical = True` on every module).

---

## 3. Verification & Benchmark Results (CPU `5`)

### 3.1 Compiler Typecheck & Build
- **`--check-only`** on patched `v2_compiler.bend` (`3,537,485 B`, 9,082 defs): **PASS (0 type errors, `15,036.8 ms`)**.
- **JS compile** (`v2_api.mjs`, `14,540,379 B`): **PASS (`45,888.4 ms`)**.

### 3.2 Same-Load A/B Comparison on CPU `5` (Wave 11 Baseline vs W12-E `x86-iface v2`)

| Module | Prefix Size | Wave 11 Baseline (ms) | W12-E v2 (ms) | Speedup | Baseline Nodes | v2 Nodes (% of 1M) | Exact Stamp Match? |
|---|---:|---:|---:|---:|---:|---:|:---:|
| `m02` | Small (`m01`) | 29,226.1 | **19,712.6** | **1.48×** | 165,506 | 277,137 (26.4%) | **YES** |
| `m06` | Medium (`m05`) | 25,337.6 | **12,552.5** | **2.02×** | 309,469 | 503,759 (48.0%) | **YES** |
| `m10` | Largest (`m09`) | 34,114.0 | **17,205.1** | **1.98×** | 463,717 | 741,321 (70.7%) | **YES** |
| **Sum (`m02+m06+m10`)** | — | **88,677.7** | **49,470.2** | **1.79×** | — | — | **3/3 YES** |

*(Iter-1 A/B on `m01`/`m05`/`m09` prior to the `fcache`/`lcache` + `w10_if_strip_ann` fixes also passed with 100% stamp identity and `1.16×`/`1.41×`/`1.78×` speedups; Iter-2 pushed `m06`/`m10` to `2.02×`/`1.98×` while cutting `m10` nodes from `97.5%` down to `70.7%`.)*

### 3.3 Downstream `x86-module-fast` `.o` Bit-Identical Parity (CPU `5`)

| Downstream Module | Input `.p130` | Baseline `.o` (ms / bytes) | v2 `.o` (ms / bytes) | SHA-256 Bit-Identical? |
|---|---|---:|---:|:---:|
| `m02.o` *(iter-1)* | `m01.p130` | 44,357.6 ms / 8,899,248 B | 44,967.8 ms / 8,899,248 B | **YES (`SHA256_IDENTICAL=True`)** |
| `m07.o` *(iter-2)* | `m06.p130` | 38,102.4 ms / 9,414,976 B | 37,617.8 ms / 9,414,976 B | **YES (`SHA256_IDENTICAL=True`)** |
| `m10.o` *(iter-1)* | `m09.p130` | 33,161.7 ms / 7,267,832 B | 33,789.5 ms / 7,267,832 B | **YES (`SHA256_IDENTICAL=True`)** |
| `m11.o` *(iter-2)* | `m10.p130` | 27,550.7 ms / 6,510,272 B | 28,493.1 ms / 6,510,272 B | **YES (`SHA256_IDENTICAL=True`)** |

---

## 4. Impact on Cold Native Self-Compile Goal & Next Steps

- On mid-to-late modules (`m06..m10`), `x86-iface v2` achieves **`~2.0×` speedup** over Wave 11 (P5-D), bringing total `x86-iface` speedup over Wave 10 baseline to **`~5.2×`**.
- Remaining time in `x86-iface v2` on `m09`/`m10` is now dominated by irreducible new-module work: `p86_plan_loaded` (`~5.3 s`: typecheck `4.0 s` + `annotate_selected` `0.9 s`) and `parse_and_load` (`~2.6 s`), plus `~1.5 s` encoding and `~1.8 s` suffix-only ABI scan.
- **Promotion readiness:** [w12e_iface_v2.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12e_iface_v2/w12e_iface_v2.patch) is clean, self-contained, 100% pure Bend (0 new types), `--check-only` verified, and ready for Wave 12 unified integration.

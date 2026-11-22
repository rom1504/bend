# Wave 8 Report: `x198pw_plan` 3.33 MB Substage Profile & Surgical Fix (`w8_pw_3mb`)

## 1. Exact `3.33 MB` Substage Timings (`wave7c_unified/api.mjs` -> `wave7c_unified/compiler.bend`)

Profiled with [prof_3mb.mjs](file:///home/ai/bend2_agy/research/agy/w8_pw_3mb/prof_3mb.mjs) via `locked_node.sh` (`AGY_NODE_MAX_MB=8192`, CPU 5, `timeout 180s`, unbuffered `fs.writeSync(2, ...)` after every substage):

| Substage | Time (ms) | Heap / RSS after | Notes |
|---|---:|---:|---|
| `p88_cache_prepare` | `337.4 ms` | `35 MB / 173 MB` | |
| `p86_plan` | `121,518.8 ms` | `5,333 MB / 5,628 MB` | Frontend check |
| `p111_runtime_admission` | `31.5 ms` | `5,319 MB / 5,629 MB` | |
| `nc_compile_error_known` | `12.4 ms` | `5,335 MB / 5,629 MB` | |
| `p167ob_permission` | `1,298.3 ms` | `5,331 MB / 5,629 MB` | |
| `p113a_certificate` | `24.5 ms` | `5,307 MB / 5,629 MB` | |
| `p144o_constructors` | `21.4 ms` | `5,325 MB / 5,629 MB` | |
| **`p112s_prepare`** | **`16,247.9 ms`** | `3,580 MB / 6,478 MB` | **#2 culprit (151x blowup from `107.7 ms` on `679 KB`!)** |
| `nc_bangs_names` | `1,244.8 ms` | `3,584 MB / 6,478 MB` | |
| `p128br_scan` | `2,663.3 ms` | `3,591 MB / 6,479 MB` | |
| `p167ob_seed_verify` | `27.1 ms` | `3,598 MB / 6,479 MB` | |
| `p167ob_remaining` | `128.4 ms` | `3,607 MB / 6,479 MB` | |
| `nq_signatures` | `1,101.9 ms` | `3,614 MB / 6,481 MB` | |
| `w7_filter_remaining` | `2,988.6 ms` | `3,646 MB / 6,481 MB` | |
| **`p113pl_candidates`** | **`>32,400 ms` (TIMEOUT at 180s)** | `3,646+ MB / 6,481+ MB` | **#1 culprit (`>46x` blowup from `699.8 ms` on `679 KB`!)** |

## 2. Root Causes Identified

1. **`p113pl_candidates` (`>32.4 s` on 3.33 MB — #1 culprit)**:
   - `p118t_original_live` (called on every AST node inside `p113pl_lower`) is a **17-deep nested `nt_choose` closure chain** (up to **34 JS closure allocations per AST node** on top of a `3.65 GB` live V8 heap / `6.48 GB` RSS, triggering heavy V8 GC thrashing).
   - `p113pl_app` has a **5-deep nested `nt_choose` closure chain** per `App` node.
   - `p113pl_candidates` calls `nb_contains(bangs, name)` (**O(|bangs|) linear list scan**) on every remaining def and is non-tail-recursive (`nt_append` across ~8,000+ defs).
   - `p121f_plan` and `p121c_admitted` unconditionally walk `j_fusion_after` and `j_call_spine` on every def *before* checking `j_fusion_def`.
2. **`p112s_prepare` (`16.25 s` on 3.33 MB — #2 culprit)**:
   - `p112s_term`, `p112s_rebuild`, `p112s_constructor`, `p112s_intern`, and `p112s_defs` allocate nested `nt_choose` closures on every AST node across all 8,563 defs on top of the `5.33 GB` live `p86_plan` heap.
   - `p112s_intern` and `p112s_node_index` call `index_find(..., 32)` / `index_set(..., 32)` instead of `w5c3_find` / `p131i_insert`.

## 3. Delivered Surgical Patch

Patch script: [apply_w8_pw_3mb.py](file:///home/ai/bend2_agy/research/agy/w8_pw_3mb/apply_w8_pw_3mb.py) (`--src <in> --dst <out>`).
- Replaces all `nt_choose` chains in `p118t_original_live`, `p113pl_app`, `p112s_term`, `p112s_rebuild`, `p112s_constructor`, `p112s_intern`, and `p112s_defs` with zero-closure direct `match` helpers.
- Pre-indexes `bangs` into a `KDef` hash trie once in `p113pl_candidates` (`w8_bangs_index` + `w5c3_find`) and converts `p113pl_candidates` to a tail-recursive accumulator loop.
- Guards `j_fusion_def` before `j_fusion_after`/`j_call_spine` in `p121f_plan` and `p121c_admitted`.
- Switches `p112s_intern` and `p112s_node_index` from `index_find`/`index_set` to `w5c3_find`/`p131i_insert`.

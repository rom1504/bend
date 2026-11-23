# W14-B Report: Native `n5_o2 x86-iface` Profile & Pure-Bend `x86-iface v3` Optimizer

**Date:** 2026-11-23  
**Status:** **PASSED (`--check-only` 0 type/linearity errors; `1.324×` on `m06` & `1.579×` on `m10` apples-to-apples `-O0` native; `1.763×` on `m06` & `1.987×` on `m10` with `m11` at `-O2`; 100% exact `stamp` match & 100% SHA-256 bit-identical downstream `m07.o` and `m11.o`)**

---

## 1. Isolation & Provenance
- **Dedicated CPUs:** CPUs `0, 1` ONLY (`taskset -c 0`, `taskset -c 1`); CPUs `2..7` strictly untouched.
- **Read-only inputs:** `selfhost/build/agy/wave13_unified/`, `selfhost/build/agy/wave13-native-mod/n5_o2`, `/tmp/agy_k14_w13_cache/{iface,obj_o0}`.
- **Deliverables:**
  - Patch: [w14b_iface_v3.patch](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/w14b_iface_v3.patch) (`35,309 B`, `691` lines, pure Bend against `wave13_unified/compiler.bend`, `0` new types, `0` C, `0` JS).
  - Receipts: [results.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/results.json), [profile_baseline.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/profile_baseline.json), [stage_breakdown.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/stage_breakdown.json), [bench_v3_final.json](file:///home/ai/bend2_agy/research/agy/w14_campaign/w14b_iface_v3/bench_v3_final.json).
  - Experiment summary: [wave14b-iface-v3.md](file:///home/ai/bend2_agy/experiments/agy/wave14b-iface-v3.md).

---

## 2. Native `n5_o2 x86-iface` Profile (`m06` & `m10`, CPU `0`)

### 2A. Leaf CPU Sampling (`sample-threads.c` + `analyze.py`, `n5_o2`)
- **`m06` (`m05b.p130` `24.7 MB` -> `28.3 MB`, `13.71 s`, `885` samples at `15,000 us`, `zero_loss=True`, `usable=True`):**
  - Runtime reclamation (`term_drop` `19.10%` + `span_fade` `6.55%`): **`25.65%`**
  - Runtime ownership/ctor (`p125_rt_ctor2` `5.31%`, `p111_rt_take` `3.50%`, `p111_rt_ctor` `1.69%`, `p198_rfc_take2` `2.03%`): **`11.41%+`**
  - `3_fast_abi` leaf functions (`String.append` `2.94%`, `p98_tag_eq` `2.37%`, `index_hash` `1.24%`, `agy_str_eq` `1.24%`, `ns_context` `1.02%`, `index_find` `0.68%`): **`24.63%`**
  - `1_p130_read_decode` (`p88_string_eq` `1.24%`, `p151_roles` `0.56%`, `p88_number_read` `0.56%`, `p130m_word` `0.45%`): **`5.99%`**
  - `4_p130_encode_write` (`w10_if_w` `0.90%`, `w10_if_take_batch` `0.45%`, `io_str` `0.68%`): **`1.69%+`**
- **`m10` (`m09.p130` `38.4 MB` -> `42.1 MB`, `14.61–18.66 s`):** same distribution (`term_drop` `19.0–19.9%`, `span_fade` `5.1–6.3%`, `3_fast_abi` `24.6–25.2%`, `1_p130_read_decode` `7.1–7.3%`, `4_p130_encode_write` `2.2–2.8%`).

### 2B. Exact Wall-Clock Sub-Stage Attribution (Instrumented 1-Module `m11` Rebuild)
Because runtime helpers (`term_drop`, `p125_rt_ctor2`, `String.append`, `index_find`) are shared across all 4 phases, we instrumented `w10_iface_request` via a 1-module `m11` rebuild (`n6_stage` `-O0`) to pinpoint the exact wall-clock % of every sub-stage:

| Phase / Sub-Stage | `m06` (`43.87 s` total) | `m10` (`46.81 s` total) | Key Root Cause |
|---|---:|---:|---|
| **1. `p130` read + decode (`1a+1b`)** | **`7,660 ms` (`17.5%`)** | **`6,743 ms` (`14.4%`)** | `p88_records` allocates `p151_roles` list, `values` list, `List.reverse`, `P88Step`/`P88State` per field across `779,398` records (`m10.p130`) |
| **2a. `parse` (`hdr`..`trace`)** | `~6,790 ms` (`15.5%`) | `~4,130 ms` (`8.8%`) | `f_prefix_complete_source` + `f_prefix_graph_trace` |
| **2b. `p86_plan_loaded`** | **`12,201 ms` (`27.8%`)** | **`9,450 ms` (`20.2%`)** | Fine breakdown (`n6_fine`): `typecheck` `2.27–2.48 s`, `annotate_selected` `1.05–1.25 s` (annotating `~830` upstream stubs!), `driver_report_data` `0.18–0.23 s` (unused!), `driver_emit_owned`+`j_compile_error` `0.21–0.30 s` |
| **3. `w10_if_fast_abi` TOTAL** | **`11,707 ms` (`26.7%`)** | **`15,026 ms` (`32.1%`)** | **`3e_p113pl_candidates` = `8,045 ms` (`18.3%`) on `m06` and `11,514 ms` (`24.6%`) on `m10`!** |
| — `3a_p112s_prepare` | `1,680 ms` (`3.8%`) | `1,331 ms` (`2.8%`) | Static node image scan |
| — `3b_p128br_scan` | `854 ms` (`1.9%`) | `571 ms` (`1.2%`) | Yielded `workers = 0` on both `m06` and `m10` |
| — `3c_filter_split` + `3d_nq_sigs` | `701 ms` (`1.6%`) | `935 ms` (`2.0%`) | `nq_signatures` unused (`0` `$product.*` candidates) |
| — **`3e_p113pl_candidates`** | **`8,045 ms` (`18.3%`)** | **`11,514 ms` (`24.6%`)** | Lowered `588–615` defs into full `P113DStmt` IR even though **65.4%** (`5,781 / 8,841`) of all compiler defs are CPS (calling upstream CPS stubs or HO choosers `nt_choose`/`kc`)! |
| — `3f_p113d_passes` + `3g_abi_maps` | `427 ms` (`1.0%`) | `675 ms` (`1.4%`) | Direct ABI fixed-point |
| **4. `.p130` encode + write (`4a+4b+4c`)** | **`5,476 ms` (`12.5%`)** | **`11,548 ms` (`24.7%`)** | **`4c_world_encode_stream` = `5,175 ms` (`m06`), `11,222 ms` (`m10`)** (`42.1 MB`, `779,398` recs, `562k` Patricia trie string lookups for top-10 tags/empty) |

### 2C. `.p130` Structural Redundancy Audit (`m10.p130`: `42.06 MB`, `779,398` records)
- `tag 1 (Con)`: `380,206` recs (`48.8%` of recs, `29.1%` of words)
- `tag 2 (KTerm)`: `281,124` recs (`36.1%` of recs, `53.8%` of words; `133,368` leaf `KTerm`s with `85,883` duplicates)
- `tag 3 (KLambda)`: `44,479` recs (`5.7%`)
- `tag 6 (KIndexLeaf)` + `tag 7 (KIndexNode)`: `59,966` recs (`7.6%`, 3 separate Patricia tries for `world.book`, `world.seen`, `ready.names`)
- `tag 5 (KDef)`: `13,242` recs (`1.7%`; `3,060` direct stubs, `5,781` CPS stubs, `437` other Base/HO defs)

---

## 3. Pure-Bend `x86-iface v3` Optimizations Implemented

1. **OPT #1 (CPS+HO Transitive Pruning + `w13d_p113pl_candidates_fast` + Skip `p128br_scan` & `nq_signatures`):**
   - `w14a_collect_cps` collects all upstream CPS stubs (`sk == 2`) alongside `w14d_cps_seed()` (`nt_choose`, `kc`, `f_choose`, `p151_choose`, `IO.bind`, `IO.pure`) into a non-admissible `cps` set.
   - `w14a_prune_active` seeds `w7_pre_peel` with `cps`, transitively pruning every suffix function that directly or transitively calls any upstream CPS stub or HO chooser in `< 50 ms` (**`826 -> 406`** on `m06`, **`698 -> 297`** on `m10` even before HO seeding, and even fewer with `w14d_cps_seed()`!).
   - Feeds only surviving candidates to `w13d_p113pl_candidates_fast` (skipping `nq_signatures`, `p121f_plan`, `p198e_plan`, `p125p_select`, and `$product.*` flat lowering) and skips `p128br_scan`.
2. **OPT #2 (Zero-Fallback Direct-Dispatch Word-Pair `.p130` Decoder `w14_p88_cache_prepare`):**
   - Directly decodes `tag 1` (`Con`, `48.8%`), `tag 2` (`KTerm`, `36.1%`), `tag 6` (`KIndexLeaf`, `3.8%`), `tag 7` (`KIndexNode`, `3.8%`), and `tag 0` (`Empty`) = **`92.5%` of all records** with inline 2-word `SCon` pattern matching (zero `p151_roles`, zero `List.length`, zero `values` list, zero `List.reverse`, zero `P88Step`/`P88State` per field).
   - Rare tags (`3, 4, 5, 8, 9, 10, 11`) decode via `w14_dec_rare_fields` and **return to `w14_dec_recs`** (zero fallback to `p88_records`).
   - *Ablation lesson preserved:* Earlier iteration fell back to `p88_fields` -> `p88_records` on record #10 (giving `0 ms` decode gain); removing `w14_dec_leaf`+`w14_dec_node` cost `+4.8 s` on `m10`, confirming their huge impact.
3. **OPT #3 (Strictly-Linear Fast `.p130` Encoder `w14_emit_checked`):**
   - Pre-interns the top-10 strings (`""`, `"Absent"`, `"Var"`, `"App"`, `"All"`, `"ADT"`, `"Ref"`, `"Ann"`, `"Src"`, `"Def"`) at IDs `0..9` with O(1) first-char dispatch (`w14_fast_str_id`), eliminating `~450,000` Patricia trie hashes/lookups per `m10` encode.
   - Pre-allocates `Empty` (ID `0`) and `Absent` (ID `1`), and interns leaf `ADT` `KTerm`s in `W10IfEnc.rm` (`-1.06 MB` on `m10.p130`).
   - Keeps `enc: W10IfEnc` **100% strictly linear** (no `+enc` anywhere; earlier `+enc` iteration added `+10 s` of refcount churn!).
4. **OPT #4 (Fast `p86_plan` `w14_plan_loaded` + `w14d_plan_context`):**
   - Skips unused `driver_report_data(original)`.
   - Runs `driver_emit_owned` on `suffix` only (instead of scanning all 8,500 native upstream defs).
   - Adds upstream stubs to `ann_stops` in `annotate_selected(context, rbook, astops)` while preserving `stops` for `p86_plan_annotated`, skipping annotation of `~830` upstream stubs.

---

## 4. Native Benchmark & Verification Results (CPUs `0, 1`)

All benchmarks were dogfooded natively via a 1-module rebuild of `m11` (`20.9 s` at `-O0`, `54.3 s` at `-O2`) linked against `/tmp/agy_k14_w13_cache/obj_o0/{m00a..m10}.o`:

| Module | `n6_base` (`-O0`) | `n6_v3` (`-O0`) | Speedup (`-O0` vs `-O0`) | `n6_v3` (`m11 -O2`, rest `-O0`) | Speedup (`m11 -O2`) | `.p130` Size | Stamp Exact | Downstream `.o` SHA-256 Parity |
|---|---:|---:|---:|---:|---:|---:|:---:|:---|
| **`m06`** | `32,430.0 ms` | **`24,491.2 ms`** | **`1.324×`** | **`18,390.9 ms`** | **`1.763×`** | `28.26 -> 27.64 MB` (`-2.21%`) | **EXACT** | **`m07.o` BIT-IDENTICAL** (`72ca833b5667f17c...`) |
| **`m10`** | `47,822.7 ms` | **`30,282.1 ms`** | **`1.579×`** | **`24,067.1 ms`** | **`1.987×`** | `42.06 -> 41.00 MB` (`-2.51%`) | **EXACT** | **`m11.o` BIT-IDENTICAL** (`2be0f658a6825bd8...`) |

- **Typecheck Gate (`locked_bun.sh --check-only` on patched `wave13_unified/compiler.bend`):** **PASS (`0` type/linearity errors)**.
- **Projected Impact on Full `14/14` `-O2` `n5_o2` Native `x86-iface` Chain (`196.34 s` baseline):**
  - Conservative `-O0`-ratio projection (`1.32–1.58×`): **`196.3 s -> ~130–140 s`** (`m06`: `13.17 s -> ~9.95 s`, `m10`: `15.70 s -> ~9.94 s`).
  - Note that compiling `m11` alone at `-O2` cut an additional **`6.1–6.2 s`** off both `m06` and `m10` because the new `w14_p88_decode_fast` and `w14_enc_*` hot loops run directly in `m11`.
  - **Next-wave lever to reach `<= 75 s`:** In `w10_if_enc_world_v2` + `w10_if_stream_carrier` (currently in `m10.bend`, untouched by our `m11`-only dogfood), eliminating the `String.append` copy in `w10_if_take_batch` and interning all leaf `KTerm`s (`Ref`/`Var`/`Set`/`Typ`) + sharing `world.book`/`world.seen`/`ready.names` index nodes can cut `.p130` from `41 MB -> ~22 MB` and shave another `~30–40%` off both encode and decode!

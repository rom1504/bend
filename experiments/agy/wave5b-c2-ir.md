# Wave 5B Engine A Track W5B-C2: Frontend / IR / Lowering & Closure Killer

## Summary
- **Patcher**: `research/agy/wave5b_c2/apply_w5b_c2.py` (composable `--src <in> --dst <out>` on `selfhost/build/agy/wave5a_unified/compiler.bend`, `+34,781` bytes).
- **Artifacts**: `selfhost/build/agy/wave5b_c2/{compiler.bend,api.mjs}` (`12 MiB` total, well under the `20 MiB` budget).
- **Scope**: Strictly frontend, core term/lookup, text/intrinsic, scalar-array, and IR lowering (`terms_at`, `lookup`, `j_*`, `nt_*`, `ni_*`, `nc_*`, `ns_*`, `nu_*`, `nq_*`, `norm_max`, `p111_*`, `p112f_*`, `p113k_*`, `p113l_*`, `p113pl_*`, `p113px_*`, `p123p_*`, `p126dp_*`, `p131i_*`, `p205v_*`). Zero edits to `x181..x202`, `w4_*`/`w5_*`, `apply_parcg.py`, or `apply_strhash.py`.
- **Correctness**:
  - **6/6 BIT-EXACT `.o` SHA-256** vs `wave5a_unified` (`histogram`, `gameoflife`, `nbody`, `editdist`, `lexer`, `raytrace`).
  - **19/19 `focused19`** PASS.
  - **15/15 `observer_wave2_gate.py`** PASS (`44+2` ABI/observer probes + `5 × 3` live-metadata modes, `0` violations).

## Performance Results

### 1. Pipeline Breakdown (`profile_pipeline.mjs`, unprofiled, 6 diverse programs)
| Phase | `wave5a_unified` | `wave5b_c2` | Speedup | Saved |
|---|---:|---:|---:|---:|
| **`p86_plan`** (Frontend/Typecheck/Opt) | `4,044 ms` | **`2,043 ms`** | **`1.98×`** | `-2,001 ms` |
| **`x198pw_plan`** (Lowering/Borrow/Verifier/Direct) | `8,340 ms` | **`3,918 ms`** | **`2.13×`** | `-4,422 ms` |
| **`p86_plan + x198pw_plan` (W5B-C2 target)** | `12,384 ms` | **`5,961 ms`** | **`2.08×`** | **`-6,423 ms`** |
| `x187_prepared` (Backend x86/ELF emit) | `13,236 ms` | `11,123 ms` | `1.19×` | `-2,113 ms` |
| **TOTAL (6 programs)** | `25,620 ms` | **`17,085 ms`** | **`1.50×`** | **`-8,535 ms`** |

Per-program `profile_pipeline.mjs` (`wave5a_unified` → `wave5b_c2`):
- `lexer`: `plan 2525 → 969 ms` (`2.61×`), `pw 2211 → 1028 ms` (`2.15×`), `emit 2289 → 1754 ms`, `total 7026 → 3752 ms` (`1.87×`), SHA `bc419c9a50d09530` (EXACT)
- `raytrace`: `plan 449 → 353 ms` (`1.27×`), `pw 1398 → 591 ms` (`2.37×`), `emit 1525 → 1230 ms`, `total 3373 → 2174 ms` (`1.55×`), SHA `eb7ca663c860d693` (EXACT)
- `gameoflife`: `plan 148 → 111 ms` (`1.33×`), `pw 1879 → 1092 ms` (`1.72×`), `emit 3479 → 2895 ms`, `total 5506 → 4098 ms` (`1.34×`), SHA `3ad8a4c2ef3f21fa` (EXACT)
- `histogram`: `plan 371 → 258 ms` (`1.44×`), `pw 917 → 470 ms` (`1.95×`), `emit 3215 → 2733 ms`, `total 4503 → 3461 ms` (`1.30×`), SHA `4fb5af3b598fd453` (EXACT)
- `nbody`: `plan 411 → 252 ms` (`1.63×`), `pw 1519 → 482 ms` (`3.15×`), `emit 671 → 563 ms`, `total 2601 → 1297 ms` (`2.01×`), SHA `2b015942167f7fba` (EXACT)
- `editdist`: `plan 139 → 100 ms` (`1.39×`), `pw 417 → 255 ms` (`1.64×`), `emit 2056 → 1948 ms`, `total 2612 → 2303 ms` (`1.13×`), SHA `3719f255601a503d` (EXACT)

### 2. `bench_compile.py` (6/6 BIT-EXACT `.o` SHA-256)
| Program | Base Plan | W5B-C2 Plan | Base Emit (`pw+x187`) | W5B-C2 Emit | Emit Speedup | SHA-256 |
|---|---:|---:|---:|---:|---:|---|
| `histogram` | `690.0 ms` | `489.0 ms` | `4878.8 ms` | `4127.9 ms` | `1.18×` | EXACT (`59babda90855`) |
| `gameoflife` | `167.6 ms` | `128.0 ms` | `4965.7 ms` | `4853.8 ms` | `1.02×` | EXACT (`649a45ed9a30`) |
| `nbody` | `397.1 ms` | `427.1 ms` | `2437.6 ms` | `1414.3 ms` | `1.72×` | EXACT (`640aa65aa791`) |
| `editdist` | `206.3 ms` | `182.8 ms` | `1833.3 ms` | `1513.8 ms` | `1.21×` | EXACT (`668f0ded8525`) |
| `lexer` | `1486.1 ms` | `739.5 ms` | `2486.3 ms` | `1936.8 ms` | `1.28×` | EXACT (`bc419c9a50d0`) |
| `raytrace` | `355.0 ms` | `362.8 ms` | `2075.8 ms` | `1804.5 ms` | `1.15×` | EXACT (`eb7ca663c860`) |
| **TOTAL** | **`3302.0 ms`** | **`2329.3 ms`** | **`18677.5 ms`** | **`15651.0 ms`** | **`1.19×`** | **6/6 EXACT** |

Total `bench_compile.py` jobs time: `22,025.8 ms → 18,022.5 ms` (`1.22×` overall, `-4.00 s`).

## Key Optimizations Implemented (20 Composable Patches)
1. **Core Term & Book Lookup Closure Killer (`terms_at`, `lookup`, `j_strip`, `j_call_spine`, `j_env`, `j_app_type`, `norm_max`)**: Eliminated `kc` closure allocations on the hottest per-node accessors (`kid`/`terms_at`, `lookup`, `j_strip`, `j_call_spine`) via 1-scrutinee helpers and direct `KTerm`/`KDef` matches + native `String.eq` and `U32.max`.
2. **String/Text & Primitive-Name Fusion (`nt_clean`, `nt_replace`, `nc_primitive_name`, `nc_native_def`, `nc_native_marked`, `nc_native_primitive`, `nc_primitive_arity`, `ni_template`, `nc_atomic`, `nc_array_known`, `p111_op_id`)**:
   - Replaced 70-deep `ni_template_prior` and 86-deep `p111_op_id_prior` nested `nt_choose` chains with O(1) first-character dispatch (`u`/`f`/`n`/`b`/`a`) + zero-closure `String.eq`.
   - Added O(1) first-char guard in `nc_native_marked`, O(1) `String.eq` fast-path for common Base primitives + single-pass `w5c2_clean_lower` in `nc_primitive_name` (eliminating the triple scan `is_clean` + `clean_slow` + `to_lower`).
   - Replaced `nc_primitive_arity`'s `ni_template` + `nt_replace(fmt, "$1", "?")` string scan with direct zero-closure arity dispatch.
   - Rewrote `nt_clean` (fast-path clean check + zero-closure `SCon` rebuild) and `nt_replace` (first-char guard + zero-closure `SCon` rebuild, eliminating O(L²) `acc ++ SCon{h, ""}`).
3. **`p113k_*` Constant/Bit-Bound Propagation & Patricia-Trie Join Closure Killer**:
   - Replaced 32-iteration closure-allocating `p113k_bits` with a 5-step binary-search bit-length (0 closures, mathematically identical for all `U32`).
   - Eliminated all `nt_choose` closures across `p113k_exact`, `p113k_bound`, `p113k_get`, `p113k_atom`, `p113k_join_fact`, `p113k_join_record_{h,b}`, `p113k_join_{leaf,nn_diff,nn,node}`, `p113k_limit`, `p113k_ones`, `p113k_mask_covers`, `p113k_result_type`, `p113k_bin_stmt`, `p113k_scalar_if`, `p113k_body_next`, `p113k_body_if`.
4. **`p113l_*` & `p123p_*` Redundant-Lookup & Closure Killer**:
   - Guarded `p113l_comparison` and `p123p_pick` on `String.eq(op, "eq") || String.eq(op, "ne")` before performing hash-trie `p113k_replace`/`p123p_test` lookups; removed all `nt_choose` closures in `p113l_*` and `p123p_*`.
5. **IR Lowering, Liveness & Scalar-Array Closure Killer (`nu_*`, `nc_word`, `nc_unann`, `nc_occurs`, `nc_uses_term`, `nc_live_uses`, `ns_*`, `nq_layout_subst`, `p111_partition_step`, `p111_keep`, `p112f_name`, `p113pl_{lower,live}`, `p113px_let`, `p126dp_value_shape`, `p131i_original_set`, `p205v_range`/`p205v_range_cmp`)**:
   - Eliminated `nt_choose`/`kc` closures across all hot lowering, `NU_Set` Patricia-trie, and `p205v_range` loops; avoided double `j_strip(t)` in `p205v_range`.

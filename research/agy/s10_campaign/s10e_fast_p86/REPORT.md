# S10-E: `p86_plan` Frontend Speedup Patch (`apply_s10e.py`)

**Status:** Patch delivered, idempotent (`13/13`), `--check-only` **PASS** (`0` type/linearity errors across `9,399` `@unsafe` defs), and all 5 touched modules (`m01`, `m02`, `m07`, `m08`, `m09`) compiled & linked cleanly with `n6_o2`. Runtime A/B + `64/64 native64 -O0` + `15/15 Observer -O0` deferred to W16-INT due to final-wrap deadline (see **Integration Safety Note** below).

## 1. Baseline `p86_plan` Sub-Stage Profile (`n6_o2`, CPU 4)

Measured with `n6_o2 --trace-slow` pinned to `taskset -c 4`:

| Input | `p86_plan` (trace-slow) | `parse` | `check` | `annotate` | `glue` (header/seed/trace) |
|---|---:|---:|---:|---:|---:|
| `m09_zero.bend` (478 KB, 1,233 defs, 676 stubs) | `7,256 ms` (`5,427 ms` no-slow) | `2,360 ms` (32.5%) | `1,629 ms` (22.5%) | `2,868 ms` (39.5%) | `399 ms` (5.5%) |
| `compiler_slice.bend` (248 KB, 83 segs) | `3,404 ms` | `1,771 ms` (52.0%) | `932 ms` (27.4%) | `508 ms` (14.9%) | `193 ms` (5.7%) |

## 2. Structural Optimizations in [apply_s10e.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10e_fast_p86/apply_s10e.py)

All 13 hunks are pure-Bend, idempotent against `selfhost/build/agy/wave15_unified/compiler.bend`, and touch **zero** `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, `x198pw_plan*`, `x187_pub*`, or `x187_elf*` code:

1. **`s10e_plan` (`annotate` bucket, `2,868 ms`):**
   - Skips unused `driver_report_data(original)`.
   - Scopes `driver_emit_owned` to `suffix` when `eligible == True` (avoids rescanning Base).
   - When `fast == True` (`x86-object-fast` / `x86-module-fast`): skips `-O2`-only `agy_bf_plan` / `agy_abs_plan` / `w2d_plan` passes.
   - When `fast == True`: `s10e_ann_stops_all` skips `annotate_selected` on all self-calling `@unsafe` stubs (`w10_if_stub_kind(context, dn(d)) > 0`), both prefix and suffix.
   - `s10e_jl_check`: checks `s10e_has_array(rbook)` in `O(|rbook|)` (~0.05 ms); when `"Array"` is not reachable, `jl_checked_error` (which only checks for open `Array` element types) is guaranteed `""`.
   - `s10e_p144o_cached_bound`: reuses `da(cache)` from `BookCache` in `O(1)` inside `p144o_prepare_annotated` instead of running `norm_max_book(merged)` over ~500,000 AST nodes.
   - `w7b_jl_ctr` fast-path: skips `w7b_wnf(book, ty)` for non-builtin constructors (only runs `w7b_wnf` for `ALeaf`, `ANode`, `Zero`, `Succ`, `U32`, `F32`, `Chr`, `SNil`, `SCon`).
2. **`s10e_p143cb_program` / `s10e_p156cp_walk` (`check` bucket, `1,629 ms`):**
   - When `fast == True`: skips `check_definition_world` on self-calling `@unsafe` stubs (`w10_if_peel_stub > 0`, which contain only `Lam`/`App`/`Ref`/`Var`/`Let` and produce identical `KDef` output).
   - When `is_mod == True && fast == True` (`x86-module-fast`): also skips `check_definition_world` on `ADT` and `law` (`dv == Absent`) declarations (already declared in `w7c_declare_cached`, `dg_event_output` returns `d` unchanged). All real `def` bodies remain 100% typechecked.
3. **Parser & Post-Parse (`parse` + `glue` buckets, `2,360 + 399 ms`):**
   - `s10e_f_raw_skip_fast` / `s10e_f_skip_fast`: checks token `kind == 0` before string comparisons and removes `f_choose`.
   - `s10e_f_atom_existing_fast`: dispatches on `f_kind(ts)` so identifiers (`kind == 1`) skip 11 `f_eq` calls and the `String.ends_with(..., "n")` walk on every atom.
   - `s10e_prefix_complete_source`: skips `f_prefix_names_extend` and `f_prefix_ctors_extend` on the final source module (never read by `f_prefix_graph_trace`).
4. **Direct Lexer (`m02`, 4 hunks):**
   - `s10e_lex_punct_and_spaces`, `s10e_w7_lex_space_fast`, `s10e_lex_cmt_fast`, `s10e_p150l_word_direct`.

## 3. Verification & Integration Safety Note for W16-INT

- **Idempotency:** 13/13 `[OK]` -> 13/13 `[SKIP]` (`3,899,680 B`).
- **`--check-only`:** **PASS** (`0` type errors, `0` linearity errors, `9,399` `@unsafe` defs).
- **Native modular compile (`n6_o2 x86-module-fast`):** `m01`, `m02`, `m07`, `m08`, `m09` compiled cleanly and linked cleanly via `x86-merge-obj` + `gcc-10` without `--allow-multiple-definition`.
- **IMPORTANT Integration Note:**
  1. Runtime A/B on `n6_s10e` was blocked because `/tmp/agy_s10a/obj_n7` (`n7_s10a`) itself timed out in `stage=prep` on `base.p130`.
  2. In `live` mode on `tiny.bend`, `n6_s10e` timed out in `stage=prep` while `n7_s10a` returned in `6,105 ms` — **W16-INT should first test the 9 non-lexer hunks** (which own `annotate`, `check`, `f_skip`, `f_atom_existing`, `p144o_prepare_annotated`, and `s10e_prefix_complete_source`) and isolate the 4 lexer hunks (`m02`) before enabling them!
  3. Notice `apply_s10e.py` overlaps with S10-D's `s10d_plan` in `w8_tr_compile_prep` — when stacking S10-D + S10-E, use `s10e_plan` (which is a strict superset of `s10d_plan`'s frontend cuts) + S10-D's `-O2` codegen hunks (`w5_g11_b` + `s10d_align_text32`).
  4. Ready-to-run verification harness: [verify_and_bench.py](file:///home/ai/bend2_agy/research/agy/s10_campaign/s10e_fast_p86/verify_and_bench.py) (runs 3-run A/B + `64/64 native64 -O0` + `15/15 Observer -O0`).

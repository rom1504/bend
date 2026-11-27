# `bend5k` Full Upstream Conformance & Verification Report (L18-CONF-X86)

**Base commit:** `031f8405` (Proven-17) · **CPU pin:** `taskset -c 2`  
**Candidate `s2`/`s3` SHA-256:** `d5fb0cd83b2d954fed9ae361a1c19cdbaa836b148b7769015ae4957e6c388950` (`s2.o == s3.o`, `-O2`, bit-identical)  
**Owned files modified:** `selfhost/bend5k/check.bend`, `selfhost/bend5k/lower.bend`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (**`12,112 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Before vs After)

| Suite / Gate | Proven-17 (`031f8405`) | **L18-CONF-X86 (`s2`)** | Delta vs Proven-17 |
|---|---:|---:|---:|
| **Differential `check_conformance.py --suite all`** | `92 / 92` (`0` false_acc, `0` false_rej, `0` invalid `.o`) | **`102 / 102` (`0` false_acc, `0` false_rej, `0` invalid `.o`)** | **`+10` Dependent NbE Phase 2 cases (`v3_dependent`: `12 -> 22`)** |
| **Upstream positive `tests/**` `--check-only`** | `1,167 / 1,178` (`99.1%` non-foreign, `11` rejects) | **`1,188 / 1,194` (`99.50%` non-foreign, `6` rejects)** | **All `11` Proven-17 rejects closed (`-5` net rejects, `+0.4 pp`)** |
| **Upstream negative `tests/**` `--check-only` (549 fixtures)** | `204 / 549` rejected (`37.2%`, `345` false_acc) | **`241 / 549` rejected (`43.9%`, `308` false_acc)** | **`+37` invalid programs now rejected (`-37` false-accepts)** |
| **Full `tests/**` closed-main x86 `#|` exact stdout** | `594 / 813` (`73.1%`; `593 / 774 = 76.6%` non-symbolic) | **`662 / 813` (`81.4%`; `662 / 774 = 85.5%` non-symbolic)** | **`+68` exact x86 `#|` passes (`+8.3 pp`)** |
| **`tests/{base,run,rfc}` x86 `#|` exact stdout** | `147 / 159` (`92.5%`) | **`147 / 159` (`92.5%`, `42/42` `tests/base` at `-O0`)** | `-O0` vs `-O2` split isolates `list_fold` as sole `-O2`-only wrong answer |
| **Phase182 + Observer Qualification Gate (O0 + O2)** | `158 / 158 PASS` | **`158 / 158 PASS` (`0` violations)** | 0 regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 2`)** | `9/9` strict, `10/10` GREEN | **`9/9` strict, `10/10` GREEN** | 0 regressions |
| **3-stage `-O2` self-hosting (`s2 == s3`)** | PASS | **PASS** (`s2.o == s3.o`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK`** (`0 @unsafe`, `12,112 / 15,000` LOC) | PASS |

---

## 2. Changes Implemented (`0 @unsafe`)

### A. `selfhost/bend5k/lower.bend`
1. **General `show_desc` builder (`low_show_go`, `low_subst_go`)**:
   - Added `Unit` (`Unit{}`), `Equal` / `EEq` / `EOp{20, _, _}` (`{==}`), `Maybe` (`None{}`/`Some{v}`), `Result` (`Fail{e}`/`Done{v}`), `Either` (`Inl{v}`/`Inr{v}`), `Sigma` (`Tuple`), `Array` inside ADTs (`case 6` in `runtime-opt.c`), and **generic user-defined `TypeDef` printing** with type-parameter substitution (`low_subst_expr`) and cycle-safe recursive back-edges (`ShowSeen`).
   - Restricted `low_amp_spine` / `STEnc` tuple encoding strictly to `EOp{5, a, b}` (`&`) and mapped `EOp{20, _, _}` (`==`) to `ShowBuild{[5], ...}` (`{==}`).
2. **Live `~` comptime template parameters (`low_param_is_erased`, `low_param_arity_live`, `low_param_emask_live`)**:
   - Since `parse.bend` marks `~` parameters with `erased = True{}`, `lower.bend` now keeps non-universe parameters that are used in the function body live in both `arity`, `emask`, and `low_bind_params` (fixing `tests/comptime/*` and `tests/check/list_order.bend` constructor arity mismatches).
3. **Partial application of binary intrinsics (`low_intr_is_bin`, `LTAppIntr1`)**:
   - Automatically eta-expands 1-arg applications of binary intrinsics (e.g., `Nat.add(1n)`, `U32.add(5)`).
4. **Scalar `U32{w}` / `F32{w}` pattern & ctor unwrapping**:
   - Handled `kind 14` (`U32`) and `kind 16` (`F32`) in `low_pat_ctr_step` and `kind 14` in `low_emit_ctor_kind`.

### B. `selfhost/bend5k/check.bend`
1. **Closed all `11` Proven-17 positive `--check-only` rejections**:
   - `exs`-stripped `LawDef` return-type inference (`b5k_chk_law_has_free_var`, `b5k_chk_exs_goal`, `b5k_chk_def_rty`) for `assert_full_spec`, `division_algorithm`, `exists_where`, `exists_witness`, `nested_exists`.
   - Arrow peeling (`b5k_chk_peel_pms`, `b5k_chk_peel_ret`) for `fits_residual_fallback`.
   - Dead wildcard tail relaxation (`b5k_chk_is_dead_tail`) for `dead_arm_shared`.
   - Qualified `.Bool`/`.List`/`.Tuple` compatibility and def-shadowed Base ctor suffix fallback (`b5k_chk_lookup_ctor_k`) for `ops_own`, `sugar_list_own`, `ctr_named_def`, `sugar_ctr_tld`.
2. **Dependent NbE Phase 2 (`b5k_chk_eval_w`, `b5k_chk_eq_call_sig`)**:
   - Closed 0/1/2-arg pure user-def unfolding in `b5k_chk_eval_w` (with `CEnvBind`, `EIf`, and 1-scrutinee `EMat` on `Bool`/`Nat`/`CVCtr`).
   - Full argument + return-type validation for `Empty.absurd(T, e)`, `Equal.sym(T, a, b, e)`, and `Equal.trans(T, a, b, c, e1, e2)`.
   - Added 10 new positive + negative cases to `v3_dependent` (`12 -> 22` cases, `102/102` total differential conformance).
3. **Upstream Negative-Fixture False-Accept Reduction (`345 -> 308`, `-37` false-accepts)**:
   - Unfilled hole (`EHole{}`) rejection in `WExpr`.
   - Non-Data `+` dup-field rejection on all types including `is Type` (`tests/grade/reject_plus_field.bend`).
   - `do`-block `StLet` non-variable destructuring rejection (`tests/check/monad_do_destructure.bend`).
   - Structural self-recursion / termination check (`RecCtx`, `b5k_chk_rec_call_err`), rejecting 0-param self-recursion (`tests/halt/polymorphic_self_recursion.bend`), local HOAS applications (`tests/halt/nsi_necessity.bend`, `tests/halt/distinct_material.bend`), and non-decreasing calls (`tests/halt/` false-accepts: `23 -> 10`).
   - Rejecting universe (`Type`/`Data`/`Kind`) returned directly against a `TEq` goal (`9` `goal_ladder_state_*` cases).

---

## 3. Silent Wrong Answers (`-O0` vs `-O2`) & Full `tests/**` X86 Breakdown

### A. `-O0` vs `-O2` Silent Wrong Answers Across All `1,071` Runnable Fixtures
- **Exactly `1` `-O2`-only silent wrong answer**:
  - `tests/base/list_fold.bend` (line 15: `List.sort(~String, ~String.is_le, ["pear", "apple", "fig"])`):
    - **`-O0`:** `[apple, fig, pear]` (**EXACT PASS — `42/42` `tests/base` at `-O0`**)
    - **`-O2`:** `[pear, apple, fig]` (root cause: `-O2` optimization pass in `opt.bend`, outside L18-CONF-X86 ownership; standalone `List.sort(~String, ~String.is_le, ...)` passes at `-O2`, failing only when `List.sort` is called after earlier `U32.is_le`/`U32.is_ge` sorts in the same module).

### B. Full `tests/**` Runnable `#|` Audit (`662 / 813` closed-main = `81.4%`; `662 / 774` non-symbolic = `85.5%`)

| Category | Count | Notes / Smallest Reproducers |
|---|---:|---|
| **Exact `#|` PASS** | **662** | `+68` vs Proven-17 (`594 -> 662`) |
| **Open-main (`main must be a closed ordinary segment`)** | 252 | Open lambda/type printing tests (predominantly `tests/flatten/`) |
| **Symbolic/open `stdout_diff`** | 39 | Expected stdout contains `=>`, `λ`, `@`, or `Error:` |
| **Value / show `stdout_diff` (`-O0` & `-O2` both diff)** | 58 | `GLamMat` ctor-name erasure in `parse.bend` (`closure_match_lambda`, `eta_ctor_arm`, `eta_default_arm`), `string_match_sparse`, `u32_to_nat_widen` (32-bit `Succ`), `template_key_shape` (nested `Pair` field), `list_fold` (`-O2`-only) |
| **Runtime errors / crashes** | 45 | `13` `take arity mismatch` (`Word`/`WCon` bit-patterns), `13` `runtime fail-stop`, `10` `memory fault` (deep-tail stack overflow + wide ctors), `8` `constructor arity mismatch`, `1` `Nat > 2^48-1`, `1` `entry/width mismatch` |
| **Compile / link** | 8 | `6` `non-decreasing self-recursion` (e.g. `@unsafe` `tests/check/unsafe_loop.bend`, `tests/rfc/drop_spine_wide.bend`), `2` `link_err` (`respelled_{first,second}` duplicate imported symbol) |
| **Foreign provider** | 6 | Intentionally rejected by fixed-runtime policy |

### C. Remaining Negative-Fixture Gaps (`308` false-accepts out of `549`)
- `tests/proof/goal_ladder_state_{007,021,025}.bend`: `%rewrite` body `Type` inside a `do`/`match` where `parse.bend` drops the `%rewrite` motive into `EAnn{..., EHole{}}` or erases the outer `TEq` goal; full dependent motive substitution requires preserving `%rewrite` AST nodes in `parse.bend` (outside L18-CONF-X86 ownership).
- `tests/check/` (`100`), `tests/parse/` (`37`), `tests/flatten/` (`36`), `tests/import/` (`31`): primarily parser-level syntax restrictions (`parse.bend`), full dependent conversion/unification, and strict-positivity / linearity-grade checks.

# `bend5k` Full Frontend Conformance & Verification Report (L16-CONF-FRONT)

**Base commit (`HEAD`):** `3a32068b` (Proven-15 / L15-CHECK-2) · **CPU pin:** `taskset -c 0`  
**Candidate `s2` SHA-256:** `8b31e197cd1c05ffe46f6683b9ac3fff4337b8d5e060ead4e0eefd91427c46d0` (`s1.o == s2.o == s3.o`, `-O2`)  
**Owned files modified:** `selfhost/bend5k/lex.bend` (`323 -> 328`, `+5` LOC), `selfhost/bend5k/parse.bend` (`589 -> 667`, `+78` LOC), `selfhost/bend5k/check.bend` (`804 -> 862`, `+58` LOC), `research/agy/bend5k/check_conformance_report.md` (**`+141` net LOC**, `0 @unsafe`, `12,768 / 15,000` assembled LOC)

---

## 1. Executive Summary

| Suite / Gate | L15-CHECK-2 (`3a32068b`, `HEAD`) | **L16-CONF-FRONT (`s2`)** | Delta vs `HEAD` |
|---|---:|---:|---:|
| **Frozen 60-case corpus (`frozen60`)** | `23 acc / 37 rej / 0 false_acc / 0 false_rej` | **`23 acc / 37 rej / 0 false_acc / 0 false_rej`** | **60 / 60 (0 regressions)** |
| **Parametric 20-case corpus (`v2_parametric`)** | `8 acc / 12 rej / 0 false_acc / 0 false_rej` | **`8 acc / 12 rej / 0 false_acc / 0 false_rej`** | **20 / 20 (0 regressions)** |
| **Combined `check_conformance.py --suite all`** | `80 / 80` (`0` invalid `.o`) | **`80 / 80` (`0` invalid `.o`, `0` crashes, `0` timeouts)** | **80 / 80** |
| **Upstream `tests/` positive runnable (strict `1,276` / L15-style `1,298`)** | `940 / 1,276` (`73.7%`) · `946 / 1,294` (`73.1%`) | **`1,130 / 1,276` (`88.6%`) · `1,145 / 1,298` (`88.2%`)** | **`+190` / `+199` (`+15.1 pp`)** |
| **Non-foreign positive runnable acceptance** | `940 / 1,192` (`78.9%`) | **`1,130 / 1,180` (`95.8%`) · `1,145 / 1,197` (`95.7%`)** | **`+16.9 pp` (`97.6%` of single-file non-foreign)** |
| **Parser rejections on positive `tests/`** | `138` (`143` on `1,294`) | **`10`** | **`-128` (`-92.8%`)** |
| **Checker rejections on positive `tests/`** | `114` (`119` on `1,294`) | **`40` (`42` on `1,298`, of which `24` are multi-file local imports)** | **`-74` (`-64.9%`)** |
| **Phase182 + Observer Qualification Gate** | `158 / 158 PASS` | **`158 / 158 PASS`** (`64 O0 + 64 O2 + 30 Observer O0/O2`) | 0 regressions |
| **`bench/runtime/*` `.o` bit-identity vs `HEAD`** | `17 / 17 SAME` | **`17 / 17 SAME`** | 0 diffs |
| **3-stage `-O2` self-hosting (`s1 == s2 == s3`)** | PASS | **PASS** (`6.81s -> 6.84s -> 6.96s`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK`** (`0 @unsafe`, `12,768 / 15,000` LOC) | PASS |

---

## 2. General Frontend Fixes Implemented (`+141` net LOC, `0 @unsafe`)

1. **`selfhost/bend5k/lex.bend` (`323 -> 328`, `+5` LOC):**
   - Removed unused contextual identifiers (`as`, `exs`, `where`, `with`) from the reserved keyword table (`lex_kw_code`), allowing them as variable/field names (fixing `contextual_keyword.bend`, `show/array_elements.bend`, etc.).
   - Added `&0` quantity literal (`TkSym{271}`) and 3-character quantity meet operator `<&>` (`TkSym{272}`).
   - Added `\u{...}` Unicode escape support in character literals (`lex_tok_chr` / `lex_chr_uni_done`).
   - Improved scientific-notation `F32` scaling (`lex_f32_bits_exp`) to perform a single power-of-10 divide/multiply.
2. **`selfhost/bend5k/parse.bend` (`589 -> 667`, `+78` LOC):**
   - Lambda-match syntax `\{ Ctor: expr; ...; fallback }` (`GLamMat` / `KLamMatArm` / `p_lam_mat_step`).
   - Dependent Sigma binder `&x: T -> Body` in `p_ev_expr`, `GArrow`, and `GTypeArg`, plus `@x: T -> ...` inside `GArrow` and `KPiPm`.
   - Quantity literal `&0`, prefix `+` on grade-filled types (`+List<U32>`), and binary meet operator `<&>`.
   - Indented lambda bodies (`x => \n <block>` via `GSuite{}`), indented `<-` / `=` RHS suites in `do` and `let`, multi-line `def ... -> \n <ret>:`, `def f?(...)` unsafe mark, inline `type` constructors (`type Nn is Data: Zz{} Ss{p: Nn}`), multi-line `<...>` type params/args, and multi-line `++`/`&` continuations.
   - Contextual `exs` and `where` clauses inside `law` declarations (`GLawBody` / `KLawWhere`).
   - `do`-block type-only discarding binds (`Result<...> <- ...`, `Unit <- ...` without shadowing `Unit`), `;`-separated `do` statements, typed inline `let` (`x : T = v; ...`), array-write statement rebinding (`a[i] <- v` binds `a`), and `%h@e : motive; body` rewrite syntax (including newline after `;`).
   - Restricted `{...}` postfix constructor application in `p_ev_post` to `EVar` heads (fixing fork values `{5 : U32} {(2+3*4:U32):U32}`), and added `*`, `^`, `>>` to `p_after_targs`.
   - Erased local let tagging (`-x = val` tagged with `EAnn{val, ERefl{}}` so `check.bend` checks scope/types without affine consumption).
3. **`selfhost/bend5k/check.bend` (`804 -> 862`, `+58` LOC):**
   - Operator-family suffix handling in `EAnn{EOp{op, a, b}, typ}` (`op >= 20`): treats `(a < b : F32)` / `(a < b : U32)` as `Bool` and `{a == b : T}` / `(a == b : T)` without falsely expecting the operand family `T` as the comparison's result type.
   - Erased-argument affine accounting (`param_ers` in `DefInfo` / `CallSig` / `WArgs`): arguments passed into erased (`-`) parameter positions are still scope- and type-checked, but do not consume live affine uses.
   - Erased-universe and equality-proof return detection (`b5k_chk_ret_is_erased`) + erased local let (`EAnn{val, ERefl{}}`) + multi-line `%e : motive` goal relaxation (`b5k_chk_is_refl`).
   - Added missing `Base` constructors (`Event`: `Key`, `Text`, `Press`, `Move`, `Leave`, `Lost`, `Look`, `Scroll`, `Focus`, `Close`; `Tool`: `Tool.Mouse`, `Tool.Finger`, `Tool.Pen`) and `Base` module prefixes (`Equal.`, `Empty.`, `Quant.`, `TCP.`, `UDP.`, `Process.`).
   - User-defined `U32` constructor check in `b5k_chk_lit` (`safe_box_word_def.bend`).

---

## 3. Differential Conformance (`check_conformance.py --suite all`, CPU 0)

| Suite | `agree_accept` | `agree_reject` | `false_accept` | `false_reject` | Invalid `.o` (`-O2`) | Crashes / Timeouts |
|---|---:|---:|---:|---:|---:|---:|
| `frozen60` (60 cases) | **23** | **37** | **0** | **0** | **0** | 0 / 0 |
| `v2_parametric` (20 cases) | **8** | **12** | **0** | **0** | **0** | 0 / 0 |
| **Total (`all`, 80 cases)** | **31** | **49** | **0** | **0** | **0** | **0 / 0** |

Median `bend5k --check-only` latency across all 80 cases: **`5.47 ms`** (total `439.27 ms`). `4` valid proof/grade cases are honestly tracked as `incomplete_proofs` (no BendTT `--verdict`).

---

## 4. Upstream `tests/` Positive Runnable Screen & Remaining Bucket Breakdown

Screened across `tests/**/*.bend` with `taskset -c 0 <s2> --check-only`:
- **Strict positive runnable (`1,276` files, `1,180` non-foreign):** **`1,130 / 1,276` (`88.6%` overall, `95.8%` of non-foreign)** — `10` parse, `40` check, `96` foreign.
- **L15-style positive runnable (`1,298` files, `1,197` non-foreign):** **`1,145 / 1,298` (`88.2%` overall, `95.7%` of non-foreign)** — `10` parse, `42` check, `101` foreign.
- **Single-file non-foreign acceptance:** `1,145 / (1,197 - 24 multi-file local imports) = 1,145 / 1,173` (**`97.6%`**).

### Remaining `10` Parser Rejections (down from `143`, `-93.0%`)
1. `unexpected token in expression` (**7**): `tests/check/let_levels.bend`, `tests/eval/do_notation_nested.bend`, `tests/eval/do_notation_qualified.bend`, `tests/parse/do_head_sugar.bend`, `tests/parse/do_line_depth.bend`, `tests/parse/let_in_argument.bend`, `tests/reg/rwt_type_share.bend`.
2. `unexpected top-level token` (**2**): `tests/check/ctr_param_chain.bend` (600-param multi-line type), `tests/gfx/app_linear.bend`.
3. `expected 'case'` (**1**): `tests/parse/elif_alignment.bend` (layout-free unaligned `case`).

### Remaining `40` Checker Rejections on `strict_1276` (down from `114`, `-64.9%`)
1. **Multi-file local `import "./..." as M` references (`24`):** `L.t` (3), `L.two` (2), `C.seven` (2), `alias_lib.two`, `W.f`, `M.lt`, `M.get`, `M.F`, `M.quad`, `L.peek`, `far.sum`, `imported_adt_alias`, etc. (expected boundary: single-file checker without module loader).
2. **`affine variable consumed more than allowed` (`9`, down from `16`):** `erased_local_dead_value.bend` (in-line erased/nested cases), `eta_recursive_type.bend`, `rebuild_levels.bend`, `type_erased_runtime.bend`, `dup_many.bend`, `share_cell_cycle.bend`, `template_inst_model.bend`, `template_proof_kind.bend`, `stuck/max.bend`.
3. **`constructor does not belong to goal` (`3` non-import):** `word_lemmas.bend`, `main_forged_io.bend`, `word_add_comm.bend`.
4. **Misc (`4`):** `assert_full_spec.bend`, `ops_own_lib.bend`, `sugar_list_own_lib.bend`, `f32_literal_unfolds.bend` (float literal rounding between `1.25e-2` and `0.0125`).

### Sample Upstream Verification (`12` Newly-Accepted Fixtures vs `locked_bun.sh --check-only`)
`11 / 12` exact agreement (`up=0, s2=0` on `map_set_array_kit`, `sugar_ops`, `string_contains`, `float_bitwise_eq_000`, `dependent_pair_destructure`, `beta_ann_match`, `meet_order_fits`, `canonical_freeze_000`, `app_play`, `chan_pipe`, `exists_where`; `1` known diff on `f32_literal_unfolds.bend`).

---

## 5. Full Qualification & Self-Hosting Evidence (CPU 0)

| Gate | Result | Evidence |
|---|---|---|
| Upstream frontend check (`locked_bun.sh --check-only`) | **PASS** | `ALL PROOFS CHECK`, `0 @unsafe`, `12,768 / 15,000` LOC |
| 3-stage self-hosting (`s1 -> s2 -> s3`, `-O2`) | **PASS** | `s1.o == s2.o == s3.o` SHA-256 `8b31e197cd1c05ffe46f6683b9ac3fff4337b8d5e060ead4e0eefd91427c46d0` (`6.81s -> 6.84s -> 6.96s`) |
| Phase182 Qualification (`run_qual_b5k.py -O0`) | **64 / 64 PASS** | 61 exec + 3 reject (`5.74s`) |
| Phase182 Qualification (`run_qual_b5k.py -O2`) | **64 / 64 PASS** | 61 exec + 3 reject (`33.89s`) |
| Live-Metadata Observer Gate (`observer_wave2_gate` O0+O2) | **30 / 30 PASS** | 0 `OBSERVER_VIOLATION`s across `normal`, `cap-no8`, `all-hot` |
| **Combined Qualification Gate** | **158 / 158 PASS** | `64 + 64 + 30 = 158` |
| `bench/runtime/*` `.o` bit-identity vs `HEAD` | **17 / 17 SAME** | 0 diffs, 0 failures across all 17 benchmarks |

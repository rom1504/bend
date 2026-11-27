# `bend5k` Frontend & Checker Soundness Conformance Report (L19-CONF-SOUND)

**Base commit:** `bde38487` (Proven-18) · **Branch:** `l19-conf-sound` · **CPU pin:** `taskset -c 4`  
**Candidate `s1`/`s2`/`s3` SHA-256:** `fbfbba3c0dfe70b747f84059c3b9128f37a57f20bddc2638b51fe962df329c94` (`s1.o == s2.o == s3.o`, `-O2`, bit-identical)  
**Owned files modified:** `selfhost/bend5k/parse.bend`, `selfhost/bend5k/main.bend`, `selfhost/bend5k/check.bend`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (**`13,126 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Before vs After)

| Suite / Gate | Proven-18 (`bde38487`) | **L19-CONF-SOUND (`s2`)** | Delta vs Proven-18 |
|---|---:|---:|---:|
| **Differential `check_conformance.py --suite all`** | `102 / 102` (`0` FA, `0` FR, `0` invalid `.o`) | **`130 / 130` (`0` FA, `0` FR, `0` invalid `.o`)** | **`+28` new soundness cases (`v3_dependent`: `22 -> 50`)** |
| **Codex 8/8 Spot-Check False-Accepts** | `5 / 8` fixed (`007`, `021`, `025` FA) | **`8 / 8` FIXED (`0` FA)** | **All 3 `%rewrite` motive spot-checks closed** |
| **Upstream positive `tests/**` `--check-only` (non-foreign)** | `1,190 / 1,199` (`99.25%`) | **`1,193 / 1,199` (`99.50%`; `1,193 / 1,196 = 99.75%` excl. 3 transitive foreign)** | **`+3` net positive passes (`+0.25 pp`)** |
| **Upstream negative `tests/**` `--check-only` (550 true check-only)** | `306 / 550` FA (`244 / 550 = 44.4%` rej) | **`127 / 550` FA (`423 / 550 = 76.9%` rej)** | **`-179` false-accepts eliminated (`58.5%` FA reduction, `+32.5 pp` rej)** |
| **Phase182 Qualification Gate (`run_qual_b5k.py`, O0 + O2)** | `64 / 64` + `64 / 64` PASS | **`64 / 64` O0 + `64 / 64` O2 PASS** | `0` regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 4`)** | `9/9` strict, `10/10` GREEN | **`9/9` strict, `10/10` GREEN** | `0` regressions |
| **3-stage `-O2` self-hosting (`s2.o == s3.o`)** | PASS | **PASS** (`s1.o == s2.o == s3.o`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK`** (`0 @unsafe`, `13,126 / 15,000` LOC) | PASS |

---

## 2. Upstream `tests/**` Before vs After by Namespace

Measured on the full `tests/**/*.bend` suite (`1,749` non-foreign fixtures with `#|` expectations; `12` runtime-only `#|exit 1` tests accepted by upstream `locked_bun.sh --check-only` are classified under positive `--check-only`, leaving `550` true `--check-only` negative fixtures and `1,199` positive fixtures).

| Namespace | POS Proven-18 | **POS L19 (`s2`)** | NEG Total | P18 FA | **L19 FA (`s2`)** | Delta FA |
|---|---:|---:|---:|---:|---:|---:|
| `base` | `42 / 42` | **`42 / 42`** | `4` | `0` | **`0`** | `0` |
| `check` | `123 / 125` | **`124 / 125`** | `167` | `100` | **`65`** | **`-35`** |
| `compile` | `138 / 139` | **`138 / 139`** | `10` | `4` | **`0`** | **`-4`** |
| `comptime` | `29 / 29` | **`29 / 29`** | `22` | `21` | **`7`** | **`-14`** |
| `cost` | `4 / 4` | **`4 / 4`** | `1` | `0` | **`0`** | `0` |
| `eval` | `36 / 36` | **`36 / 36`** | `4` | `1` | **`0`** | **`-1`** |
| `flatten` | `186 / 186` | **`186 / 186`** | `59` | `37` | **`11`** | **`-26`** |
| `gfx` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `grade` | `2 / 2` | **`2 / 2`** | `15` | `10` | **`3`** | **`-7`** |
| `halt` | `9 / 9` | **`9 / 9`** | `27` | `12` | **`3`** | **`-9`** |
| `import` | `31 / 31` | **`31 / 31`** | `45` | `31` | **`9`** | **`-22`** |
| `io` | `123 / 125` | **`122 / 125`** | `25` | `0` | **`0`** | `0` |
| `page` | `4 / 4` | **`4 / 4`** | `19` | `13` | **`2`** | **`-11`** |
| `parse` | `85 / 86` | **`86 / 86`** | `86` | `37` | **`21`** | **`-16`** |
| `printer` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `proof` | `84 / 85` | **`85 / 85`** | `35` | `22` | **`2`** | **`-20`** |
| `reg` | `111 / 112` | **`111 / 112`** | `4` | `3` | **`0`** | **`-3`** |
| `rfc` | `13 / 14` | **`14 / 14`** | `0` | `0` | **`0`** | `0` |
| `run` | `104 / 104` | **`104 / 104`** | `6` | `0` | **`0`** | `0` |
| `show` | `13 / 13` | **`13 / 13`** | `0` | `0` | **`0`** | `0` |
| `spec` | `2 / 2` | **`2 / 2`** | `13` | `8` | **`0`** | **`-8`** |
| `state` | `8 / 8` | **`8 / 8`** | `8` | `7` | **`4`** | **`-3`** |
| `stats` | `5 / 5` | **`5 / 5`** | `0` | `0` | **`0`** | `0` |
| `stuck` | `26 / 26` | **`26 / 26`** | `0` | `0` | **`0`** | `0` |
| **TOTAL** | **`1,190 / 1,199` (`99.25%`)** | **`1,193 / 1,199` (`99.50%`)** | **`550`** | **`306`** | **`127`** | **`-179` (`-58.5%`)** |

*Note on the `6` remaining positive rejects (`1,193 / 1,199`): `3` are transitive foreign-provider policy rejections (`tests/io/cid_capture.bend`, `tests/io/marshal_imported_nullary.bend`, `tests/reg/far_import.bend`), leaving only `3` non-foreign positive rejects (`1,193 / 1,196 = 99.75%`): `tests/check/string_literal_descends.bend`, `tests/io/tcp_send_slow_peer.bend`, and `tests/compile/closure_match_lambda.bend`.*

---

## 3. Changes Implemented (`0 @unsafe`)

### A. `selfhost/bend5k/parse.bend`
1. **Preserve `%rewrite` motives (`KRewriteEq`, `KRewriteMot`, `KRewriteBody`)**: Encodes `%eq : mot; body` as `ELet{PWild{}, EAnn{ERefl{}, EEq{eq, mot}}, body}` so `check.bend` validates the rewrite premise and body without altering `lower.bend`.
2. **Preserve `@unsafe def` & `def f?` (`is_unsafe: Bool`)**: Stores `"@unsafe"` in `Def.import_path` (when `is_import == False{}`) so `check.bend` exempts unsafe defs from structural termination and forward-reference rejection.
3. **Preserve `GLamMat` constructor names (`KLamMatArm`)**: Tags constructor-pattern lambda-match arms with `EAnn{body, ERef{csym}}` so `check.bend` validates constructor existence and erased-parameter matches.
4. **General syntax restrictions**: Required `is <Data|Type|Kind>` on `type`, `import` before declarations, `do <Monad><...>:`, typed `do`-block `let`, power-of-2 array `*` count, variable name on typed `let` (preserving `: T` via `KLetTy`), leading typed `~` comptime params only (rejecting `~` in Pi/arrow types), empty `()` rejection, `{a op b : T}` brace-operator rejection, reserved universe names rejected as lambda binders, and lowercase `foo<T>` type-arg call tagging.

### B. `selfhost/bend5k/main.bend`
1. **Import hygiene**: Scans all `import ` lines (including leading `/` paths and multi-space formatting), rejects non-`.bend` imports, duplicate aliases, alias/local-declaration prefix collisions, and local `Base`-shadowing defs (`Nat.add`/`Nat.sub`/`Nat.mul`/`U32`) when `import Base` is active.
2. **Transitive import deduplication**: Deduplicates transitive imports by alias, fixing the `tests/import/respelled_{first,second}.bend` duplicate symbol link errors.

### C. `selfhost/bend5k/check.bend`
1. **Codex 8/8 & `%rewrite` validation (`TNonUniv{}`, `b5k_chk_rwt_eq_bad`)**: Rejects bare universes (`Type`/`Data`/`Kind`/`Set`) returned against type-family or post-rewrite goals (closing `tests/proof/goal_ladder_state_{007,021,025}.bend` and all 20 `goal_ladder_state_*` false-accepts) and rejects non-equation `%rewrite` premises.
2. **Lexicographic structural termination (`RecCtx`, `b5k_chk_lex_ok`, `b5k_chk_pms_rename`)**: Full left-to-right lexicographic descent with `sub`/`sub2` nested subterms, literal max tracking, rebuilt-shell check, constructor-field / 0-field / `PVar`-rename `arg_is_same`, `@unsafe`/`def f?` exemption, and 0-arg self-recursion rejection (`tests/halt/`: `12 -> 3` FA; fixed `unsafe_loop`, `drop_spine_wide`, `spin_machine`, `descent_rebuilt_shell`).
3. **Declaration & match soundness**: Duplicate type/ctor/field/def/param checks, untyped `def` without `law`, unimplemented `law` without `def`, forward-ref check, pattern arity, scrutinee locality/computed/erasure/ctor/fn bans, binder-order ban (with source-order `b5k_chk_pats` reversal and nested `banned` tracking), 1- and 2-scrutinee exhaustiveness (with live-`Empty` and 0-ctor empty-match rules), and `GLamMat` annotation/ctor/erasure checks.
4. **Erasure, comptime `~`, grade & function checking**: `VarBind.erased` & `VarBind.is_comp` tracking, comptime closedness/position/arity validation, non-`Data` `+` binder rejection (def params + `ELet`), grade upcast rejection (`&1 -> &2`), `TFun` domain contravariance, over-application checks, O(1) shadowed literal-sugar checks (`b5k_chk_has_tdef_fast`), and neutral symbolic NbE (`CVNeutVar`, `CVNeutApp`, `ELam` canonical neutral) in `b5k_chk_refl_goal`.

---

## 4. Major Remaining Gaps (`127` False-Accepts — 1-Line Reproducers)

| Namespace | Remaining FA | Major Gap Families & 1-Line Reproducers |
|---|---:|---|
| `check` | `65` | Full dependent conversion / Pi-Sigma-Vec index unification (`tests/check/cop_adt_param_000.bend`: mismatched indexed ADT parameter), capture/alpha-renaming under binders (`tests/check/binder_name_capture.bend`), and comptime splice goal typing (`tests/check/comp_splice_tuple_goal.bend`). |
| `parse` | `21` | Lexer-level token boundary / glued-operator rules (`tests/parse/operator_glued_call.bend`: `f(1)+2` without whitespace; `tests/parse/hex_no_digits.bend`: `0x`; `tests/parse/invalid_string_escape.bend`; `tests/parse/bare_caret_dead.bend` — requires `lex.bend`, outside L19 ownership). |
| `flatten` | `11` | Multi-scrutinee (>2) pattern-matrix exhaustiveness (`tests/flatten/nontotal_multi_scrutinee_000.bend`), consumed-column tracking (`tests/flatten/consumed_column_error_002.bend`), and `match` used directly as a sub-term (`tests/flatten/match_as_term.bend`). |
| `import` | `9` | Cross-module `@unsafe` propagation in `--check-only` (`tests/import/unsafe_used.bend`), constructor-of-datatype alias shadowing (`tests/import/alias_shadow.bend`, `tests/import/ctr_of_datatype.bend`). |
| `comptime` | `7` | Comptime specialization termination & growth checks (`tests/comptime/err_grow.bend`: growing `~` recursion; `tests/comptime/err_capture.bend`: runtime var captured in `~` template). |
| `state` | `4` | Dependent goal-state refinement across stuck constructors / type families (`tests/state/ctor_stuck_goal.bend`, `tests/state/type_family_goal.bend`). |
| `grade` | `3` | Deep grade-cast / rewrite grade-leak checks (`tests/grade/reject_cast.bend`, `tests/grade/reject_local_grade.bend`, `tests/grade/reject_rewrite.bend`). |
| `halt` | `3` | Size-change termination graph / joint-group descent (`tests/halt/size_change_reject_000.bend`, `tests/halt/joint_group_sum.bend`, `tests/halt/ann_transparency.bend`). |
| `page` | `2` | Type-inference error on unannotated concat / deep list walk (`tests/page/concat_type_infer.bend`, `tests/page/deep_list_walk.bend`). |
| `proof` | `2` | Function extensionality rejection (`tests/proof/no_funext_000.bend`: `{ (x => x) == (x => f(x)) }`) and dependent goal-ladder state `015` (`tests/proof/goal_ladder_state_015.bend`). |

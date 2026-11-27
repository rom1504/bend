# `bend5k` Frontend & Checker Soundness Conformance Report (L21-CONF-SOUND-100)

**Base commit:** `89d393d6` (Proven-20) · **CPU pin:** `taskset -c 1`  
**Candidate `s1`/`s2`/`s3` SHA-256:** `4eef47a6e4941e34bce4acf485b3399324c5801483da178c7c9719b7c27a284d` (`s1.o == s2.o == s3.o`, `-O2`, 3-stage bit-identical)  
**Owned files modified:** `selfhost/bend5k/lex.bend`, `selfhost/bend5k/parse.bend`, `selfhost/bend5k/check.bend`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (**`13,366 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Proven-20 / L20 vs L21-CONF-SOUND-100)

| Suite / Gate | Proven-20 (`89d393d6`) | **L21-CONF-SOUND-100 (`s2`)** | Delta vs Proven-20 |
|---|---:|---:|---:|
| **Differential `check_conformance.py --suite all --cpu 1`** | `160 / 160` (`0` FA, `0` FR, `0` invalid `.o`) | **`200 / 200` (`52` accept, `148` reject, `0` FA, `0` FR, `0` invalid `.o`, `4.63 ms` median)** | **`+40` new L21 soundness cases (`v3_dependent`: `80 -> 120`)** |
| **Upstream positive `tests/**` `--check-only` (non-foreign)** | `1,196 / 1,196` (`100.00%`, `0` FR) | **`1,196 / 1,196` (`100.00%`, `0` FR)** | `0` regressions |
| **Upstream negative `tests/**` `--check-only` (550 true check-only)** | `40 / 550` FA (`510 / 550 = 92.7%` rej) | **`0 / 550` FA (`550 / 550 = 100.00%` rej)** | **`-40` false-accepts eliminated (`100.0%` FA reduction, `+7.3 pp` rej)** |
| **Phase182 Qualification Gate (`run_qual_b5k.py`, O0 + O2, CPU 1)** | `64 / 64` + `64 / 64` PASS | **`64 / 64` O0 (`9.91s`) + `64 / 64` O2 (`109.64s`) PASS** | `0` regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 1`)** | `11 / 11` STRICT + `13 / 13` GEN-MATRIX | **`11 / 11` STRICT PASS + `13 / 13` `[GEN-MATRIX]` GREEN** | `0` regressions |
| **3-stage `-O2` self-hosting (`s2.o == s3.o`, CPU 1)** | PASS | **PASS** (`s0->s1`: `14.73s`, `s1->s2`: `16.67s`, `s2->s3`: `15.53s`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK` (`55.36s` user, `0 @unsafe`, `13,366 / 15,000` LOC)** | PASS |

---

## 2. Upstream `tests/**` Before vs After by Namespace (`550 / 550` Negative, `1,196 / 1,196` Positive)

| Namespace | POS L20 | **POS L21 (`s2`)** | NEG Total | L20 FA | **L21 FA (`s2`)** | Delta FA |
|---|---:|---:|---:|---:|---:|---:|
| `base` | `42 / 42` | **`42 / 42`** | `4` | `0` | **`0`** | `0` |
| `check` | `125 / 125` | **`125 / 125`** | `167` | `29` | **`0`** | **`-29` (100%)** |
| `compile` | `139 / 139` | **`139 / 139`** | `10` | `0` | **`0`** | `0` |
| `comptime` | `29 / 29` | **`29 / 29`** | `22` | `0` | **`0`** | `0` |
| `cost` | `4 / 4` | **`4 / 4`** | `1` | `0` | **`0`** | `0` |
| `eval` | `36 / 36` | **`36 / 36`** | `4` | `0` | **`0`** | `0` |
| `flatten` | `186 / 186` | **`186 / 186`** | `59` | `3` | **`0`** | **`-3` (100%)** |
| `gfx` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `grade` | `2 / 2` | **`2 / 2`** | `15` | `0` | **`0`** | `0` |
| `halt` | `9 / 9` | **`9 / 9`** | `27` | `0` | **`0`** | `0` |
| `import` | `31 / 31` | **`31 / 31`** | `45` | `3` | **`0`** | **`-3` (100%)** |
| `io` | `123 / 123` | **`123 / 123`** | `25` | `0` | **`0`** | `0` |
| `page` | `4 / 4` | **`4 / 4`** | `19` | `1` | **`0`** | **`-1` (100%)** |
| `parse` | `86 / 86` | **`86 / 86`** | `86` | `1` | **`0`** | **`-1` (100%)** |
| `printer` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `proof` | `85 / 85` | **`85 / 85`** | `35` | `1` | **`0`** | **`-1` (100%)** |
| `reg` | `111 / 111` | **`111 / 111`** | `4` | `0` | **`0`** | `0` |
| `rfc` | `14 / 14` | **`14 / 14`** | `0` | `0` | **`0`** | `0` |
| `run` | `104 / 104` | **`104 / 104`** | `6` | `0` | **`0`** | `0` |
| `show` | `13 / 13` | **`13 / 13`** | `0` | `0` | **`0`** | `0` |
| `spec` | `2 / 2` | **`2 / 2`** | `13` | `0` | **`0`** | `0` |
| `state` | `8 / 8` | **`8 / 8`** | `8` | `2` | **`0`** | **`-2` (100%)** |
| `stats` | `5 / 5` | **`5 / 5`** | `0` | `0` | **`0`** | `0` |
| `stuck` | `26 / 26` | **`26 / 26`** | `0` | `0` | **`0`** | `0` |
| **TOTAL (non-foreign)** | **`1,196 / 1,196` (`100.00%`)** | **`1,196 / 1,196` (`100.00%`)** | **`550`** | **`40`** | **`0`** | **`-40` (`-100.0%`)** |

*Note: Independent BendTT kernel proof (`--verdict`) remains explicitly distinct from `bend5k --check-only`.*

---

## 3. Root-Cause Fixes Implemented (`0 @unsafe`, `13,366 / 15,000` LOC)

### A. Proof-Module `@unsafe` & Unsafe-Base Propagation (`7` FAs closed)
- Added `b5k_chk_proof_unsafe` in `check.bend`: proof-only modules (no `main` def) reject any local or imported `@unsafe` def as well as any type/def reference to `@unsafe` Base primitives (`Array.join`, `Array.fork`, `Array.get_unchecked`), closing `tests/import/unsafe_{lib,unused,used}.bend` and `tests/check/unsafe_{relies,field,kind,kind_def}.bend` while preserving all runnable `@unsafe` programs with `def main`.

### B. `Data` Kind / Universe Discipline (`7` FAs closed)
- Added `EAll` and `is Type` datatype rejection against `#Data` goals at call sites (`cop_inline_witness_002`, `data_bound_instantiation`).
- Added `b5k_chk_types_db_go` and `b5k_chk_mret_db_bad` to enforce `Data`-bounded datatype parameter instantiation across constructor fields and def return types (`data_self_ref`, `nested_field_bound`, `let_dependent_domain_bad`).
- Extended `b5k_chk_let_plus_bad` to reject `+x = val` on `is Type` datatypes and `Type`-kinded type variables (`cop_let_formation`, `let_plus_dependent_type`).

### C. Dependent Equality, Match-Arm Specialization, Rewrites & NbE (`7` FAs closed)
- Made `CVCtr` construction in `b5k_chk_eval_w` preserve partial/head constructors even when deep fields hit fuel, closing `tests/page/deep_list_walk.bend` in O(1) steps.
- Added `b5k_chk_spec_goal` (match-arm `TEq`/`TFam` specialization with `strict: Bool`) and `b5k_chk_rwt_from_def` (actual rewritten residual `TEq` computation for `%eq : mot`), closing `ctor_stuck_goal`, `missing_ih_rewrite`, `goal_ladder_state_015`, and `rewrite_goal`.
- Added carrier type tracking (`car: ChkTy`) on `TEq` and top-level `_` carrier compatibility checking in `b5k_chk_rwt_ty_bad`, closing `tests/parse/rewrite_ctor_brace.bend`.
- Added forward/pending-def neutral evaluation (`b5k_chk_def_is_pending`) in `b5k_chk_eval_w` for `<&>` meets, closing `meet_stuck_pending_ref`.

### D. Binder Capture, Stuck Type Families & Template Keys (`6` FAs closed)
- Added `TFam2`, `TTyVar`, local `TFun` call-sig peeling (`b5k_chk_call_sig_lookup`), dependent lambda argument substitution (`b5k_chk_subst_call_atys`), and capture-free 2-arg lambda beta-reduction in `b5k_chk_eval_w`, closing `binder_name_capture` and `capture_soundness`.
- Added recursive constructor pattern binding (`b5k_chk_cv_pat_bind_go`) and `~` unwrapping in `b5k_chk_eval_w` with `TFam` reduction comparison in `b5k_chk_ty_ok_go`, closing `template_key_empty` and `template_key_nan`.
- Rejected `{==}` and match-arm literals against stuck `match`-defined `TFam` goals, closing `default_arm_family` and `switch_miss_guard`.

### E. Flatten, Destructuring & Frontend Hygiene (`13` FAs closed)
- **Flatten (`4` FAs):** Split-column inner-match banning (`b5k_chk_split_col_vars` matching outer ctor tag, closing `consumed_column_error_002`), strict local-binder constructor destructure rejection (`destructure_let_001`), tuple-destructure on `EApp` rejection (`comp_splice_tuple_goal`), and bare constructor in unannotated `let` rejection (`match_as_term`).
- **Literals, `do` headers, `<...>` & grades (`9` FAs):** Distinct `Nat` literal marker (`TkSym{279}` -> `EAnn{ENum{v}, ESet{}}`) and `Quant` literal marker (`EAnn{ENum{v}, EUnit{}}`) with shift-RHS `Nat` goals (`typed_let_mismatch`, `relation_install_lock`); unannotated return-type operator check (`template_ns_late`); `do M<...>` header preservation & quantity-padding validation (`do_header_typed`, `do_header_quantity_span`); uppercase non-Base `<...>` tagging (`def_type_args`, `def_type_args_none`); inline `&x: A -> B` `Exists` gating (`error_window_inline_exists`); `Kind(q <&> r)` vs `Kind(q)` meet-order rejection (`meet_order_rejects`).

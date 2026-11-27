# `bend5k` Frontend & Checker Soundness Conformance Report (L20-CONF-SOUND-FULL)

**Base commit:** `801fde8a` (Proven-19) · **Branch:** `l20-conf-sound` · **CPU pin:** `taskset -c 2`  
**Candidate `s2`/`s3` SHA-256:** `df0567d839d9604882c7660eab31e66fbd6104bdfe4299e271123f1d9b2f5405` (`s2.o == s3.o`, `-O2`, 3-stage bit-identical)  
**Owned files modified:** `selfhost/bend5k/lex.bend`, `selfhost/bend5k/parse.bend`, `selfhost/bend5k/main.bend`, `selfhost/bend5k/check.bend`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (**`13,657 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Proven-19 vs L20-CONF-SOUND-FULL)

| Suite / Gate | Proven-19 (`801fde8a`) | **L20-CONF-SOUND-FULL (`s2`)** | Delta vs Proven-19 |
|---|---:|---:|---:|
| **Differential `check_conformance.py --suite all --cpu 2`** | `130 / 130` (`0` FA, `0` FR, `0` invalid `.o`) | **`160 / 160` (`0` FA, `0` FR, `0` invalid `.o`, `6.15 ms` median)** | **`+30` new L20 soundness cases (`v3_dependent`: `50 -> 80`)** |
| **Upstream positive `tests/**` `--check-only` (non-foreign)** | `1,193 / 1,196` (`99.75%`, 3 FRs) | **`1,196 / 1,196` (`100.00%`, `0` FRs)** | **`+3` positive fixes (`string_literal_descends`, `tcp_send_slow_peer`, `closure_match_lambda`)** |
| **Upstream negative `tests/**` `--check-only` (550 true check-only)** | `127 / 550` FA (`423 / 550 = 76.9%` rej) | **`40 / 550` FA (`510 / 550 = 92.7%` rej)** | **`-87` false-accepts eliminated (`68.5%` FA reduction, `+15.8 pp` rej)** |
| **Phase182 Qualification Gate (`run_qual_b5k.py`, O0 + O2)** | `64 / 64` + `64 / 64` PASS | **`64 / 64` O0 (`9.08s`) + `64 / 64` O2 (`83.05s`) PASS** | `0` regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 2`)** | `11 / 11` STRICT PASS | **`11 / 11` STRICT PASS (A, B, C, D, E, H, I, J, K, L, M GREEN)** | `0` regressions |
| **3-stage `-O2` self-hosting (`s2.o == s3.o`, CPU 2)** | PASS | **PASS** (`s1->s2`: `11.74s`, `s2->s3`: `11.78s`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK` (`55.31s`, `0 @unsafe`, `13,657 / 15,000` LOC)** | PASS |

---

## 2. Upstream `tests/**` Before vs After by Namespace

Measured on the full non-foreign `tests/**/*.bend` suite (`1,746` non-foreign fixtures excluding the `3` transitive foreign-provider policy rejections; `tests/io/request_out_of_band.bend` is a runtime-only `#|exit 1` fixture accepted by upstream `--check-only`, matching the Proven-19 `550` true `--check-only` negative denominator).

| Namespace | POS Proven-19 | **POS L20 (`s2`)** | NEG Total | P19 FA | **L20 FA (`s2`)** | Delta FA |
|---|---:|---:|---:|---:|---:|---:|
| `base` | `42 / 42` | **`42 / 42`** | `4` | `0` | **`0`** | `0` |
| `check` | `124 / 125` | **`125 / 125`** | `167` | `65` | **`29`** | **`-36`** |
| `compile` | `138 / 139` | **`139 / 139`** | `10` | `0` | **`0`** | `0` |
| `comptime` | `29 / 29` | **`29 / 29`** | `22` | `7` | **`0`** | **`-7` (100%)** |
| `cost` | `4 / 4` | **`4 / 4`** | `1` | `0` | **`0`** | `0` |
| `eval` | `36 / 36` | **`36 / 36`** | `4` | `0` | **`0`** | `0` |
| `flatten` | `186 / 186` | **`186 / 186`** | `59` | `11` | **`3`** | **`-8`** |
| `gfx` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `grade` | `2 / 2` | **`2 / 2`** | `15` | `3` | **`0`** | **`-3` (100%)** |
| `halt` | `9 / 9` | **`9 / 9`** | `27` | `3` | **`0`** | **`-3` (100%)** |
| `import` | `31 / 31` | **`31 / 31`** | `45` | `9` | **`3`** | **`-6`** |
| `io` | `122 / 123` | **`123 / 123`** | `25` | `0` | **`0`** | `0` |
| `page` | `4 / 4` | **`4 / 4`** | `19` | `2` | **`1`** | **`-1`** |
| `parse` | `86 / 86` | **`86 / 86`** | `86` | `21` | **`1`** | **`-20`** |
| `printer` | `6 / 6` | **`6 / 6`** | `0` | `0` | **`0`** | `0` |
| `proof` | `85 / 85` | **`85 / 85`** | `35` | `2` | **`1`** | **`-1`** |
| `reg` | `111 / 111` | **`111 / 111`** | `4` | `0` | **`0`** | `0` |
| `rfc` | `14 / 14` | **`14 / 14`** | `0` | `0` | **`0`** | `0` |
| `run` | `104 / 104` | **`104 / 104`** | `6` | `0` | **`0`** | `0` |
| `show` | `13 / 13` | **`13 / 13`** | `0` | `0` | **`0`** | `0` |
| `spec` | `2 / 2` | **`2 / 2`** | `13` | `0` | **`0`** | `0` |
| `state` | `8 / 8` | **`8 / 8`** | `8` | `4` | **`2`** | **`-2`** |
| `stats` | `5 / 5` | **`5 / 5`** | `0` | `0` | **`0`** | `0` |
| `stuck` | `26 / 26` | **`26 / 26`** | `0` | `0` | **`0`** | `0` |
| **TOTAL (non-foreign)** | **`1,193 / 1,196` (`99.75%`)** | **`1,196 / 1,196` (`100.00%`)** | **`550`** | **`127`** | **`40`** | **`-87` (`-68.5%`)** |

---

## 3. Changes Implemented (`0 @unsafe`, `13,657 / 15,000` LOC)

### A. `selfhost/bend5k/lex.bend` (`tests/parse`: `21 -> 1` FA)
1. **Whitespace-aware operator tokens (`LNext.sp`)**: Distinguishes spaced binary `+` (`TkSym{276}`) from glued/binder `+` (`TkSym{43}`) and glued nat-succ `1n+` (`TkSym{277}`) / `1n++` (`TkSym{278}`), closing glued-operator calls (`operator_glued_call.bend`).
2. **Dotted bitwise operators & literal hygiene**: Distinct token codes for `.&.` (`273`), `.|.` (`274`), `.^.` (`275`) so bare `^` (`94`) is only legal in array literals; strict string escape validation (`\0 \r \t \n \\ \' \" \u{...}`); rejection of `0x`/`0X` hex literals, U32 overflow past `2^32 - 1`, and `1n+5` (nat-succ followed by U32 literal without `n` suffix).

### B. `selfhost/bend5k/parse.bend`
1. **Operator, pattern & block hygiene**: Removed unary `-`, restricted unary `+` to uppercase type names, mapped `++` (including line-continuation `++`) to `String.append`, mapped `1n+` to `Nat`-annotated addition, expanded string literal patterns `TkStr{s}` to `SCon`/`SNil` chains (`p_ev_pat_str`), rejected empty `()` patterns and inline `{let; expr}` blocks.
2. **Type arguments, `do`-binds & grades**: Tagged unparenthesized compound type arguments (`Maybe<U32 & U32>`) for checker rejection while preserving `lower.bend`'s embedded prelude; checked untyped `do`-block binds (`x <- m`) via erased `EAnn{val, EAnn{EVar{x}, ESet{}}}` with zero runtime overhead; validated `is Kind(a)` vs `Kind(b)` grade parameter mismatches in `KTypeCtors`; preserved array element type annotations in `KArrTy`.

### C. `selfhost/bend5k/main.bend` (`tests/import`: `9 -> 3` FA)
1. **Import & Base hygiene**: Line-oriented `b5k_has_base_go` (handling extra spaces and trailing comments as in `framed_cell_dep.bend`), cross-module `Base` shadowing check (`shadow_base.bend`), alias-shadowing check (`alias_shadow.bend` without breaking `sugar_alias.bend`), and `has_base` propagation into `b5k_check_ex`.

### D. `selfhost/bend5k/check.bend` (`tests/check`: `65 -> 29`, `comptime`: `7 -> 0`, `grade`: `3 -> 0`, `halt`: `3 -> 0`, `flatten`: `11 -> 3`)
1. **Closed all 3 remaining non-foreign positive rejects (`1,196 / 1,196 = 100.00%`)**:
   - `string_literal_descends.bend`: `SCon` pattern-depth tracking in `b5k_chk_pats_lit_max` and `b5k_chk_arg_is_sub`.
   - `tcp_send_slow_peer.bend`: Let-alias parameter renaming in `b5k_chk_rc_let` + `in_match` propagation on pair/ctor destructuring.
   - `closure_match_lambda.bend`: `TFun` arrow peeling in `b5k_chk_def_sig` when `nargs > total_arity`.
2. **Exhaustiveness & match soundness**: Lazy Maranget pattern-matrix exhaustiveness (`ExhWork`/`b5k_chk_exh_go`) for arbitrary N-scrutinee matches (handling `PNum{k}` as `Succ`/`Zero`, 0-ctor types, and proof-evidence families), plus `GLamMat` duplicate/missing constructor checks and point-free arm handling.
3. **Termination (`tests/halt`: `3 -> 0` FA)**: Per-parameter `SubPair{vsym, psym}` tracking, 0-field vs non-empty constructor `arg_is_same`, rebuilt-shell check (`b5k_chk_all_vars_in`), and escaping bare self-reference rejection.
4. **Comptime `~` (`tests/comptime`: `7 -> 0` FA)**: Local runtime capture rejection (`b5k_chk_expr_cap_local`), growing `~` recursion rejection (`b5k_chk_has_growing_tilde`), comptime dup vs lone tracking, and non-HOF Base `~` argument rejection.
5. **Grades, dependent conversion & proofs (`tests/grade`: `3 -> 0`, `tests/proof`: `2 -> 1`, `tests/state`: `4 -> 2`, `tests/check`: `65 -> 29` FA)**: `Data` (`#Data`) vs `Type` subtyping, invariant `TCon` universe arguments, contravariant `TFun` domains, `#StuckRwt` non-function check, `TFam{head, arg}` 1-arg type families, `ELam` vs `TEq` (no-funext) rejection, De Bruijn levels for `ELam` in neutral NbE (`hoas_alpha_capture`), `per` erasure propagation in `b5k_chk_lam_bind_arg`, O(1) user-tdef flag for literal sugar checks, and no-Base sugar gating (`b5k_chk_no_base_sugar`).

---

## 4. Remaining Gaps (`40` False-Accepts across `550` Negative Fixtures)

| Namespace | Remaining FA | Summary |
|---|---:|---|
| `check` | `29` | Deep binder-capture / dependent-domain / meet-order / template-key / `@unsafe`-propagation checks (`binder_name_capture`, `comp_splice_tuple_goal`, `let_dependent_domain_bad`, `unsafe_*`). |
| `flatten` | `3` | `consumed_column_error_002`, `destructure_let_001`, `match_as_term`. |
| `import` | `3` | Cross-module `@unsafe` propagation (`unsafe_lib`, `unsafe_unused`, `unsafe_used`). |
| `state` | `2` | `ctor_stuck_goal`, `rewrite_goal`. |
| `parse` | `1` | `rewrite_ctor_brace`. |
| `page` | `1` | `deep_list_walk`. |
| `proof` | `1` | `goal_ladder_state_015`. |

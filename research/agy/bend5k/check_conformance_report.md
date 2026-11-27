# `bend5k` Full Conformance & X86 Runnable Verification Report (L15-CHECK-2)

**Installed release baseline (`HEAD`):** `20869d9b` (L14-CHECK) · **Pre-L14 baseline:** `50507223` · **CPU pin:** `taskset -c 3`  
**Candidate `s2` SHA-256:** `c51710145dea359c8cef4ff2eb8b327460ffb9a064e5f0c33ce632d234e0f336` (`s1.o == s2.o == s3.o`, `-O2`)  
**Owned files modified:** `selfhost/bend5k/lex.bend` (`319` LOC), `selfhost/bend5k/parse.bend` (`590` LOC), `selfhost/bend5k/check.bend` (`774` LOC), `research/agy/bend5k/check_conformance.py`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (`0 @unsafe`, `12,331 / 15,000` assembled LOC)

---

## 1. Executive Summary

| Suite / Gate | Pre-L14 (`50507223`) | Installed Release (`20869d9b`, `HEAD`) | **Candidate (`s2`)** | Delta vs `HEAD` |
|---|---:|---:|---:|---:|
| **Frozen 60-case corpus: `false_accept`** | 21 | 1 | **0** | **-1 (`21 -> 1 -> 0`)** |
| **Frozen 60-case corpus: `false_reject`** | 4 | 4 | **0** | **-4 (`4 -> 0`)** |
| **Frozen 60-case corpus: invalid `.o` (`-O2`)** | 21 | 1 | **0** | **-1 (`21 -> 1 -> 0`)** |
| **New `v2_parametric` (20 cases: 12 neg + 8 pos)** | — | `8 acc / 0 rej / 12 false_acc` | **`8 acc / 12 rej / 0 false_acc / 0 false_rej`** | **-12 false_accept** |
| **Upstream `tests/` positive runnable (`1,294` files)** | — | `746 / 1,294` (`57.7%`) | **`946 / 1,294` (`73.1%`)** | **`+200` (`+15.4 pp`)** |
| **Upstream `tests/` parser rejections (of `1,294`)** | — | 338 | **143** | **-195 (`-57.7%`)** |
| **Phase182 + Observer Qualification Gate** | — | 158 / 158 | **158 / 158 PASS** | 0 regressions |
| **`bench/runtime/*` `.o` bit-identity vs `HEAD`** | — | 17 / 17 | **17 / 17 SAME** | 0 diffs |
| **3-stage `-O2` self-hosting (`s1 == s2 == s3`)** | — | PASS | **PASS** (`s1.o == s2.o == s3.o`) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | — | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK`** (`0 @unsafe`) | PASS |

---

## 2. Frozen 60-Case Differential Conformance (`60 / 60` Agreement)

The 60-case corpus (`research/agy/bend5k/check_conformance_corpus.json`, `"cases"` array) remains **100% frozen and untouched** from before L14-CHECK. Run via `research/agy/bend5k/check_conformance.py --suite frozen60 --cpu 3` against pinned upstream `research/agy/locked_bun.sh --check-only`.

| Metric | Pre-L14 (`50507223`) | Installed Release (`20869d9b`) | **Candidate (`s2`)** |
|---|---:|---:|---:|
| **1. `agree_accept`** (upstream accept, `bend5k` accept) | 19 | 19 | **23** |
| **2. `agree_reject`** (upstream reject, `bend5k` reject) | 16 | 36 | **37** |
| **3. `false_accept`** (upstream reject, `bend5k` accept) | 21 | 1 | **0** |
| **4. `false_reject`** (upstream accept, `bend5k` reject) | 4 | 4 | **0** |
| Crashes / Timeouts | 0 / 0 | 0 / 0 | **0 / 0** |
| Unsupported features (parser rejections on valid upstream) | 4 | 4 | **0** |
| **Incomplete proofs** (valid proof/grade accepted without BendTT `--verdict`) | 0 | 0 | **4** |
| **Invalid programs emitting usable `.o` under `-O2`** | **21** | **1** | **0** |

**Key boundary closures on `frozen60`:**
- `boundary_param_type_arg` (`List<&2, U32>` vs `List<&2, Bool>`): `check: bad_list: type mismatch (expected List<_, Bool>, got List<_, U32>)` (rc=1, no `.o`).
- `boundary_bad_refl` (`law bad_eq: {0 == 1 : U32}` / `def bad_eq(): {==}`): now parsed AND rejected by `check.bend` (`check: bad_eq: reflexivity mismatch`, rc=1, no `.o`).
- `upstream_reject_copy_paradox`, `upstream_reject_leak`, `upstream_reject_fn_field`: now parsed AND rejected by `check.bend`'s `Data`-kind field discipline (`check: <T>: non-Data field in Data type`, rc=1, no `.o`).
- `upstream_alpha_equivalence`, `upstream_bool_algebra`, `upstream_add_comm`, `upstream_accept_data`: all 4 now parse and pass `bend5k` (`agree_accept`, honestly counted as `4` `incomplete_proofs` because `bend5k` does not run BendTT `--verdict`).

---

## 3. New `v2_parametric` 20-Case Suite (`20 / 20` Agreement)

Separate `"v2_parametric_cases"` suite in `check_conformance_corpus.json` (`--suite v2_parametric`): 12 negative parametric mismatches + 8 positive polymorphic/parametric programs.

| Metric | Installed Release (`20869d9b`) | **Candidate (`s2`)** | Delta |
|---|---:|---:|---:|
| `agree_accept` (valid polymorphic & parametric) | 8 | **8** | 0 |
| `agree_reject` (invalid parametric mismatches) | 0 | **12** | **+12** |
| `false_accept` | 12 | **0** | **-12** |
| `false_reject` | 0 | **0** | 0 |
| Invalid `.o` emitted under `-O2` | 12 | **0** | **-12** |

- **12 negative cases (all rejected, 0 `.o`):** `List<&2, U32>` vs `List<&2, Bool>`, `Maybe<&2, U32>` vs `Maybe<&2, F32>`, `Pair(U32, Bool)` vs `Pair(Bool, U32)`, `Array<U32>` vs `Array<F32>`, nested `List<&2, Maybe<&2, U32>>` vs `List<&2, Maybe<&2, Bool>>`, call-arg `List`/`Maybe`, ctor field `Holder{xs: List<&2, U32>}`, `Some{42}` for `Maybe<&2, Bool>`, `[1,2,3]` for `List<&2, Bool>`, `match m: case Some{v}: v` returning `Bool`, and `U32 & Bool` vs `Bool & U32`.
- **8 positive cases (all accepted):** `my_id`, `my_len`, nested `List<&2, Maybe<&2, U32>>`, `Pair(U32, Bool)`, `Box<-A: Data>`, `Array<U32>`, 3-tuple `U32 & Bool & F32`, and `maybe_map`.

---

## 4. General Fixes Implemented (`lex.bend`, `parse.bend`, `check.bend`)

1. **`selfhost/bend5k/lex.bend` (`0 @unsafe`):**
   - Dotted bitwise operators `.&.`, `.|.`, `.^.` mapped to bitwise `&`, `|`, `^`.
   - Scientific notation float literals (`3.0e38`, `1.7014118346046923e38`, `1e-5`) via lazy `lex_num_flt_if`/`lex_num_dec_if` + `lex_f32_bits_exp` (preserving exact `lex_f32_bits` path when no exponent is present, keeping `17/17` `bench/runtime/*` `.o` bit-identical) and `lex_scfrac_go` (preventing U32 overflow on >6 fractional digits without truncating 10-digit U32 integers like `4294967295`).
2. **`selfhost/bend5k/parse.bend` (`0 @unsafe`):**
   - Reflexivity literal `{==}` -> `ERefl{}` in `p_ev_unary`.
   - Pi-type domain parsing `@+p: String -> Bool` and `@-x: A -> Kind(b)` inside `<...>` via `GParam{er, dup, mode}` + `KBinOnly{no_gt}` + `KPiPm{no_gt}` (eliminating `72 / 79` `expected '->'` failures and enabling `Kind(a)` / `Sigma` definitions).
   - Proof rewrite syntax `%proof : motive` via `KRewrite` / `KRewriteMotive`.
   - Empty `match e:` (0-arm `Empty` elimination) in `KMatchScruts`.
3. **`selfhost/bend5k/check.bend` (`0 @unsafe`):**
   - Structured parametric `ChkTy = TAny{} | TCon{head: String, args: List<&2, ChkTy>}` with worklist-based extraction (`b5k_chk_ty_w`), structural compatibility (`b5k_chk_ty_ok_go`), diagnostic formatting (`b5k_chk_ty_show_go`), and parametric propagation into `ECtr`, `PCtr`, `EList`, `EPair`, `PPair`, and `EMat` scrutinees.
   - Monadic `StRet{val}` goal unwrapping (`b5k_chk_monad_inner`) for `IO<T>`, `Maybe<_, T>`, and `Result<_, _, _, T>`.
   - Literal reflexivity mismatch check (`b5k_chk_refl_bad`) rejecting `{0 == 1 : U32}` (`ERefl{}`).
   - `Data`-kind field discipline (`b5k_chk_types`) rejecting live function fields (`EAll`) and live `Type`/`Kind(...)`-parameterized fields inside `is Data` types.

---

## 5. Full Upstream `tests/` Positive Runnable Screen (`1,294` Fixtures, `HEAD` vs `s2`)

Screened all `1,294` positive runnable `#|` fixtures across `tests/**/*.bend` (`#|` present and containing no error markers) with `taskset -c 3 <bin> --check-only`:

| Metric | Installed Release (`20869d9b`, `HEAD`) | **Candidate (`s2`)** | Delta |
|---|---:|---:|---:|
| **Accepted** | `746 / 1,294` (`57.7%`) | **`946 / 1,294` (`73.1%`)** | **`+200` (`+15.4 pp`)** |
| **Rejected (total)** | `548` | **`348`** | **`-200` (`-36.5%`)** |
| — `parse` rejections | `338` | **`143`** | **`-195` (`-57.7%`)** |
| — `check` rejections | `126` | **`119`** | **`-7`** |
| — `foreign` policy rejections | `84` | **`86`** | `+2` (newly parsed foreign tests) |
| Crashes | `0` | **`0`** | `0` |

### Remaining Top Rejection Buckets on `1,294` Positive Runnable Fixtures (`s2`)
1. `unexpected token in expression` (**112**, down from **240**): lambda-match `\{Zero: 9; n => ...}`, advanced proof/sugar expressions.
2. `check: <fn>: affine variable consumed more than allowed` (**16**): implicitly copyable `Data` variables without explicit `+` (e.g., `tests/base/map_set_array_kit.bend`).
3. `check: <fn>: type mismatch (expected Bool, got U32)` (**15**), `(expected Nat, got Bool)` (**8**), `(expected Bool, got F32)` (**7**): bitwise/equality/sugar tests.
4. `check: <fn>: constructor does not belong to goal or field count differs` (**9**): `gfx`/`Event` constructors.
5. `check: <fn>: unbound variable: Equal.cong` (**9**): proof library builtin not in `Base` allowlist.
6. `expected '<-'` (**8**), `unexpected top-level token` (**8**), `expected '->'` (**7**, down from **79**).

---

## 6. X86 Runnable `#|` Executable Output Audit (`tests/{base,run,rfc}`)

Compiled all `161` positive runnable `#|` fixtures in `tests/base/`, `tests/run/`, and `tests/rfc/` with `s2 -O2`, linked against `selfhost/build/agy/unified/runtime-agy.o`, executed on CPU 3, and compared stdout byte-for-byte against `#|` expected lines:

| Namespace | Total | `x86_exact_match` | `x86_output_diff` | `run_crash_or_err` | `parse_reject` | `check_reject` | `foreign`/`timeout` |
|---|---:|---:|---:|---:|---:|---:|---:|
| `tests/base/` | 42 | **10** | 9 | 19 | 2 | 2 | 0 |
| `tests/run/` | 105 | **62** | 14 | 24 | 4 | 0 | 1 (`heap.check`) |
| `tests/rfc/` | 14 | **12** | 0 | 1 | 0 | 0 | 1 (timeout) |
| **Total** | **161** | **84 (52.2%)** | **23** | **44** | **6** | **2** | **2** |

**Distinction between semantic disagreements vs backend/runtime gaps:**
- **Frontend diagnostic wording differences (non-semantic):** `bend5k --check-only` prints `CHECK OK (bend5k 1-pass: ...)` instead of `ALL PROOFS CHECK`, and prints `check: <fn>: ...` rather than upstream's multiline `SOME PROOFS FAIL` box.
- **Confirmed runtime/lowering gaps (not checker bugs):**
  - `run_crash_or_err` (**44**): primarily `bend: phase111: constructor arity mismatch` on missing `Base` primitives in `lower.bend`/fixed runtime (e.g., `F32.lerp`, `F32.hypot`, `F32.from_nat` in `tests/base/f32_*`).
  - `x86_output_diff` (**23**): e.g., `tests/base/cmp_native_model.bend` (printer emits raw `0` instead of `EQ{}` for `Cmp` ctors), `tests/base/map_ops.bend` (`got='4' exp='7'`).

---

## 7. Full Qualification & Performance Evidence (CPU 3)

| Gate | Result | Evidence |
|---|---|---|
| Upstream frontend check (`locked_bun.sh --check-only`) | **PASS** | `ALL PROOFS CHECK`, `0 @unsafe`, `12,331 / 15,000` LOC |
| 3-stage self-hosting (`s1 -> s2 -> s3`, `-O2`) | **PASS** | `s1.o == s2.o == s3.o` SHA-256 `c51710145dea359c8cef4ff2eb8b327460ffb9a064e5f0c33ce632d234e0f336` (`6.37s -> 6.74s -> 6.49s`) |
| Phase182 Qualification (`run_qual_b5k.py -O0`) | **64 / 64 PASS** | 61 exec + 3 reject (`5.74s`) |
| Phase182 Qualification (`run_qual_b5k.py -O2`) | **64 / 64 PASS** | 61 exec + 3 reject (`31.98s`) |
| Live-Metadata Observer Gate (`observer_wave2_gate` O0+O2) | **30 / 30 PASS** | 0 `OBSERVER_VIOLATION`s across `normal`, `cap-no8`, `all-hot` |
| **Combined Qualification Gate** | **158 / 158 PASS** | `64 + 64 + 30 = 158` |
| `bench/runtime/*` `.o` bit-identity vs `HEAD` | **17 / 17 SAME** | 0 diffs, 0 failures across all 17 benchmarks |

---

## 8. Honest Remaining Capability Boundary

- **Parser/Checker vs Independent BendTT Kernel (`--verdict`):** `bend5k`'s 1-pass checker enforces scope, call arity, constructor existence/membership/arity, affine use counts, fixed-runtime foreign policy, parametric type arguments (`ChkTy`), `Data`-kind field discipline, and trivial literal reflexivity mismatches. It does **not** perform full dependent conversion/normalization, propositional equality proofs (`{a == b : T}` with non-literal terms, `%rewrite` motive verification), polymorphic type-variable unification across call sites (e.g. `my_id(U32, True{})`), or exhaustiveness/termination proofs — those require upstream `bend2` + BendTT `--verdict`.
- **Smallest remaining checker boundary reproducers:**
  1. Dependent conversion: `law bad_conv: {U32.add(1, 1) == 3 : U32}` / `def bad_conv(): {==}` (requires evaluating `U32.add(1, 1)` during typechecking).
  2. Polymorphic call-site unification: `def my_id(-A: Data, x: A) -> A: x` called as `my_id(U32, True{})` (`A` maps to `TAny{}`).
  3. Parser lambda-match syntax: `run(\{Zero: 9; n => ...})` (`tests/compile/closure_match_lambda.bend`, part of the remaining `112` `unexpected token in expression` bucket).

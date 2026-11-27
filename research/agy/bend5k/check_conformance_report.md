# `bend5k` Checker Conformance & Honest Verification Report (L15-CHECK-2)

**Base commit:** `20869d9b` (L14-CHECK) · **Pre-L14 baseline:** `50507223` · **CPU pin:** `taskset -c 3`  
**Owned files modified:** `selfhost/bend5k/check.bend` (`626 -> 722` LOC, `+96` LOC, `0 @unsafe`), `research/agy/bend5k/check_conformance.py`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md`

---

## 1. Executive Summary: Closing the Last False-Accept (`21 -> 1 -> 0`)

In L14-CHECK (`20869d9b`), first-order head-type checking reduced false-accepts on the frozen 60-case differential conformance corpus from `21 -> 1`, leaving a single documented false-accept (`boundary_param_type_arg`):

```bend
import Base
def bad_list(xs: List<&2, U32>) -> List<&2, Bool>:
  xs
def main() -> U32:
  0
```

**L15-CHECK-2** upgrades `selfhost/bend5k/check.bend` from flat head-type strings (`Maybe<&2, String>`) to a structured parametric type representation (`ChkTy = TAny{} | TCon{head: String, args: List<&2, ChkTy>}`) with structural argument checking, polymorphic type-variable tolerance (`TAny{}`), and parametric constructor/list/pair/match propagation.

- **Frozen 60-case corpus:** `false_accept` drops from **`21 -> 1 -> 0`** and invalid `.o` emission under `-O2` drops from **`21 -> 1 -> 0`**.
- **Diagnostic on `boundary_param_type_arg`:**
  ```
  check: bad_list: type mismatch (expected List<_, Bool>, got List<_, U32>)
  ```
  (rc=1, no `.o` emitted under `-O2`).
- **New `v2_parametric` 20-case suite (12 negative + 8 positive):** `HEAD` had `12 / 12` false-accepts (`12` invalid `.o` emitted); L15-CHECK-2 achieves **`12 / 12 agree_reject`**, **`8 / 8 agree_accept`**, **`0 false_accept`**, **`0 false_reject`**, **`0` invalid `.o` emitted**.

---

## 2. Frozen 60-Case Differential Conformance (`21 -> 1 -> 0`)

The 60-case corpus (`research/agy/bend5k/check_conformance_corpus.json`, `"cases"` array) remains **100% frozen and untouched** from before L14-CHECK. Run via `research/agy/bend5k/check_conformance.py --suite frozen60 --cpu 3` against pinned upstream `research/agy/locked_bun.sh --check-only`.

### Core 4 Outcomes & Separate Diagnostics

| Metric | Pre-L14 (`50507223`) | L14-CHECK (`20869d9b`, `HEAD`) | **L15-CHECK-2 (`s2`)** | Total Delta |
|---|---:|---:|---:|---:|
| **1. `agree_accept`** (upstream accept, `bend5k` accept) | 19 | 19 | **19** | 0 |
| **2. `agree_reject`** (upstream reject, `bend5k` reject) | 16 | 36 | **37** | **+21** |
| **3. `false_accept`** (upstream reject, `bend5k` accept) | 21 | 1 | **0** | **-21 (-100%)** |
| **4. `false_reject`** (upstream accept, `bend5k` reject) | 4 | 4 | **4** | 0 |
| Crashes | 0 | 0 | **0** | 0 |
| Timeouts | 0 | 0 | **0** | 0 |
| Unsupported features (parser rejects `{a == b : T}` / `Kind(a)`) | 4 | 4 | **4** | 0 |
| Incomplete proofs (proof-carrying accepted without BendTT) | 0 | 0 | **0** | 0 |
| **Invalid programs emitting usable `.o` under `-O2`** | **21** | **1** | **0** | **-21 (-100%)** |
| `bend5k --check-only` median latency (CPU 3) | — | 3.92 ms | **3.74 ms** | -0.18 ms |

### Breakdown by Category (Frozen 60 Cases)

| Category | Cases | Pre-L14 (`50507223`) | L14-CHECK (`HEAD`) | **L15-CHECK-2 (`s2`)** |
|---|---:|---|---|---|
| `return_value` | 8 | 2 agree_reject, 6 false_accept | 8 agree_reject | **8 agree_reject, 0 false_accept** |
| `call_argument` | 5 | 1 agree_reject, 4 false_accept | 5 agree_reject | **5 agree_reject, 0 false_accept** |
| `ctor_field` | 4 | 1 agree_reject, 3 false_accept | 4 agree_reject | **4 agree_reject, 0 false_accept** |
| `match_branch` | 4 | 0 agree_reject, 4 false_accept | 4 agree_reject | **4 agree_reject, 0 false_accept** |
| `affine_use` | 3 | 3 agree_reject | 3 agree_reject | **3 agree_reject** |
| `unused_bad_def` | 4 | 1 agree_reject, 3 false_accept | 4 agree_reject | **4 agree_reject, 0 false_accept** |
| `valid_neighbor` | 12 | 12 agree_accept | 12 agree_accept | **12 agree_accept** |
| `qual_valid` (Phase182) | 7 | 7 agree_accept | 7 agree_accept | **7 agree_accept** |
| `qual_reject` (Phase182) | 3 | 3 agree_reject | 3 agree_reject | **3 agree_reject** |
| `upstream_reject` | 1 | 1 agree_reject | 1 agree_reject | **1 agree_reject** |
| `dependent_proof` (`boundary_bad_refl`) | 1 | 1 agree_reject (parse) | 1 agree_reject (parse) | **1 agree_reject (parse)** |
| `grade_system` (`tests/grade/*`) | 4 | 3 agree_reject, 1 false_reject (parse) | 3 agree_reject, 1 false_reject (parse) | **3 agree_reject, 1 false_reject (parse)** |
| `proof_or_dependent` (`tests/proof/*`, `alpha_equivalence`) | 3 | 3 false_reject (parse) | 3 false_reject (parse) | **3 false_reject (parse)** |
| `parametric_type_arg` (`boundary_param_type_arg`) | 1 | 1 false_accept | 1 false_accept | **1 agree_reject, 0 false_accept** |

---

## 3. New `v2_parametric` 20-Case Conformance Suite (`HEAD` vs `s2`)

Added as a separate `"v2_parametric_cases"` suite in `check_conformance_corpus.json` (`--suite v2_parametric`) covering nested `List`/`Maybe`/`Pair`/`Array`/`Sigma`, constructor fields, list literals, `match` unwrapping, and polymorphic functions (`my_id`, `my_len`, `Box<A>`, `maybe_map`, 3-tuples).

| Metric | L14-CHECK (`HEAD`) | **L15-CHECK-2 (`s2`)** | Delta |
|---|---:|---:|---:|
| `agree_accept` (valid polymorphic & parametric) | 8 | **8** | 0 |
| `agree_reject` (invalid parametric mismatches) | 0 | **12** | **+12** |
| `false_accept` | 12 | **0** | **-12** |
| `false_reject` | 0 | **0** | 0 |
| Invalid programs emitting `.o` under `-O2` | 12 | **0** | **-12** |
| `bend5k --check-only` median latency (CPU 3) | 3.83 ms | **3.91 ms** | +0.08 ms |

**All 12 negative cases rejected with `0` `.o` emitted:** `v2_neg_list_ret` (`List<&2, U32>` vs `List<&2, Bool>`), `v2_neg_maybe_ret` (`Maybe<&2, U32>` vs `Maybe<&2, F32>`), `v2_neg_pair_swap` (`Pair(U32, Bool)` vs `Pair(Bool, U32)`), `v2_neg_array_ret` (`Array<U32>` vs `Array<F32>`), `v2_neg_nested_list_maybe` (`List<&2, Maybe<&2, U32>>` vs `List<&2, Maybe<&2, Bool>>`), `v2_neg_call_arg_list`, `v2_neg_call_arg_maybe`, `v2_neg_ctor_field_list`, `v2_neg_some_ctor_elem` (`Some{42}` for `Maybe<&2, Bool>`), `v2_neg_list_lit_elem` (`[1, 2, 3]` for `List<&2, Bool>`), `v2_neg_match_maybe_unwrap` (`match m: case Some{v}: v` returning `Bool`), and `v2_neg_sigma_swap` (`U32 & Bool` vs `Bool & U32`).

**All 8 positive polymorphic & parametric cases accepted:** `v2_pos_poly_id`, `v2_pos_poly_list_len`, `v2_pos_nested_list_maybe`, `v2_pos_pair_access`, `v2_pos_poly_box_ctor`, `v2_pos_array_pass`, `v2_pos_sigma_3tuple`, `v2_pos_poly_maybe_map`.

---

## 4. Implementation Summary (`selfhost/bend5k/check.bend`, `0 @unsafe`)

- **Structured `ChkTy` ADT (`TAny{} | TCon{head: String, args: List<&2, ChkTy>}`):** Replaces `Maybe<&2, String>` everywhere (`VarBind`, `PatItem`, `CtorInfo`, `DefInfo`, `CallSig`, `LookupRes`, `ChkWork`). Type variables, universe sorts (`Type`/`Data`/`Kind`/`Set`), and grade annotations (`&1`/`&2`) extract to `TAny{}`, preserving full tolerance for polymorphic functions (`def id(-A: Data, x: A) -> A`, `RaVec<Maybe<&2, A>>`, `b5k_list_app`, etc.).
- **Worklist-based Total Extraction, Compatibility & Formatting (`0` mutual recursion, max `match` arity `<= 2`):**
  - `b5k_chk_ty_w`: extracts `TCon{head, args}` from `EApp` (including nested/curried applications) and 2-element `EOp{B5K_OP_AND()}` (`Sigma`), degrading nested `&` 3-tuples safely to head-only `TCon{"Sigma", Nil{}}`.
  - `b5k_chk_ty_ok_go`: structural compatibility via `TyPair` worklist — `TAny{}` matches anything, head-only `TCon{h, Nil{}}` matches any `TCon{h, _}`, and concrete `TCon{h, args}` compares every argument position recursively.
  - `b5k_chk_ty_show_go`: renders structured diagnostics such as `expected List<_, Bool>, got List<_, U32>`.
- **Parametric Propagation into Expressions & Patterns:**
  - `ECtr` & `PCtr` propagate parametric field goals for `Maybe`/`Some`, `List`/`Con`, `Pair`, `Sigma`/`Tuple`, and `Array`/`ALeaf`/`ANode` (while user-defined `CtorInfo.ftys` carries full `ChkTy` directly).
  - `EList` checks element expressions against the `List`'s element type when concrete; `EPair` and `PPair` propagate 2-tuple component types; `EMat` infers scrutinee `ChkTy`s into `WCases` for `PCtr`/`PPair` pattern bindings.

---

## 5. Full Qualification & Performance Evidence (CPU 3)

| Gate | Result | Evidence |
|---|---|---|
| Upstream frontend check (`locked_bun.sh --check-only`) | **PASS** | `ALL PROOFS CHECK`, `0 @unsafe`, `check.bend` `626 -> 722` LOC (`+96` LOC), `12,416 / 15,000` total LOC; `40.25s` vs `HEAD` `41.42s` (`-1.17s` faster than `HEAD` on CPU 3) |
| 3-stage self-hosting (`s1 -> s2 -> s3`, `-O2`) | **PASS** | `s1.o == s2.o == s3.o` SHA-256 `4844bdc7b203b98953ffd32b75da4edaf5e9e13f5950b0d6fe4243396df38708` |
| Phase182 Qualification (`run_qual_b5k.py -O0`) | **64 / 64 PASS** | 61 exec + 3 reject (`5.68s`) |
| Phase182 Qualification (`run_qual_b5k.py -O2`) | **64 / 64 PASS** | 61 exec + 3 reject (`33.03s`) |
| Live-Metadata Observer Gate (`observer_wave2_gate` O0+O2) | **30 / 30 PASS** | 0 `OBSERVER_VIOLATION`s across `normal`, `cap-no8`, `all-hot` |
| **Combined Qualification Gate** | **158 / 158 PASS** | `64 + 64 + 30 = 158` |
| `bench/runtime/*` `.o` bit-identity vs `HEAD` | **17 / 17 SAME** | 0 diffs, 0 failures across all 17 benchmarks |
| `-O2` self-build time (CPU 3) | `5.95s -> 6.00s` | `+0.05s` (`+0.8%`) |
| `--check-only` median latency (CPU 3, frozen 60) | `3.92 ms -> 3.74 ms` | `-0.18 ms` |

---

## 6. Next Honest Capability Boundary

With parametric type arguments now enforced (`0` false-accepts on both the frozen 60-case corpus and `v2_parametric`), the next honest capability boundary of `bend5k`'s 1-pass checker is:

1. **Dependent indices, normalization/conversion, and propositional equality (`{a == b : T}`, `{==}`, `rewrite`, `absurd` / `Empty`):** e.g., proving or refuting `{0 == 1 : U32}`, indexed families such as length-indexed `Vec<Nat, A>`, and definitional reduction inside types.
2. **Polymorphic type-variable unification across call sites:** e.g., rejecting `my_id(U32, True{})` where the explicit type argument `U32` disagrees with the value argument `True{}` (currently type variables map to `TAny{}` so polymorphic functions never falsely reject).
3. **Universe / grade / kind discipline (`Kind(a)`, `Data` vs `Type` field restrictions in `tests/grade/*`) and exhaustiveness / termination proofs:** requires upstream `bend2` + independent BendTT kernel verification (`--verdict`).
4. **Parser support for full upstream proof surface syntax:** `{a == b : T}` and `Kind(a)` (the 4 pre-existing parse rejections on `tests/proof/*`, `tests/grade/accept_data.bend`, `tests/check/alpha_equivalence.bend`).

---

## 7. Upstream `tests/` Full Corpus Screening (Next-Wave Backlog)

**Compiler revision:** base `20869d9b` + L15-CHECK-2 `selfhost/bend5k/check.bend` (`s2` SHA-256 `4844bdc7b203b98953ffd32b75da4edaf5e9e13f5950b0d6fe4243396df38708`), run via `taskset -c 3 s2 --check-only` across all `tests/**/*.bend`.

- **All `tests/**/*.bend`:** `1,860` files (`1,847` with `#|` lines) screened in `10.00s` (**`0` crashes**): `984 / 1,860` accept, `876` reject (`549` parse, `223` check, `98` foreign).
- **Positive runnable fixtures (`#|` without error markers):** **`1,294` files** — **`744 / 1,294` accept (57.5%)**, **`550` reject** (`338` parse, `128` check, `84` foreign).

### Top Rejection Buckets on Positive Runnable `tests/` Fixtures (`1,294` files)

| Count | Stage | Exact Normalized Error Message | Root Cause / Representative Examples |
|---:|---|---|---|
| **240** | `parse` | `unexpected token in expression` | Upstream expression/proof syntax (`tests/base/cmp_native_model.bend`, `tests/base/list_search_head.bend`, `tests/proof/*`) |
| **79** | `parse` | `expected '->'` | Upstream type/arrow/lambda syntax (`tests/base/string_contains.bend`, `tests/base/string_eq.bend`) |
| **32** | `check` | `check: <fn>: literal type mismatch (U32)` | `do`-block `return <num>` vs monadic `IO<U32>`/`Result<..., U32>` goal (`tests/check/do_bind_desugar.bend`) & `Word` literals (`tests/check/safe_box_word_def.bend`) |
| **15+** | `check` | `expected IO<T>/Result<...,T>, got T` | `StRet{val}` in `EDo` checks `val` against outer `IO<T>`/`Result<...,T>` instead of inner `T` (`tests/io/port_bound.bend` [7], `tests/io/file_open_read_write.bend` [4], `tests/io/fork_join.bend` [2], `tests/base/result_maybe.bend` [2]) |
| **13** | `check` | `check: <fn>: type mismatch (expected Bool, got U32)` | Generic/operator/comparison surface forms (`tests/compile/generic_flat_instance.bend`, `tests/flatten/computed_operator_match_000.bend`) |
| **9** | `check` | `check: <fn>: affine variable consumed more than allowed` | Implicitly copyable / `Data` var reuse without `+` (`tests/base/map_set_array_kit.bend`, `tests/check/canonical_freeze_000.bend`) |
| **8** | `parse` | `expected '<-'` | Channel / `do`-bind syntax (`tests/io/chan_pipe.bend`, `tests/io/chan_proof_send.bend`) |
| **7** | `check` | `check: <fn>: type mismatch (expected Bool, got F32)` | Float bitwise equality tests (`tests/check/float_bitwise_eq_000.bend`) |
| **6** | `check` | `check: <fn>: type mismatch (expected Nat, got Bool)` | Sugar/neq unfolding (`tests/eval/neq_unfold.bend`, `tests/halt/sugar_self_call.bend`) |
| **6** | `check` | `check: <fn>: constructor does not belong to goal or field count differs` | `gfx` / `Event` constructors (`tests/gfx/app_play.bend`, `tests/gfx/clicks.bend`) |

### Key Takeaways for Next Wave
1. **Top 2 parser messages (`unexpected token in expression`: 240, `expected '->'`: 79) account for `319 / 338` (94.4%) of all parser rejections** on positive runnable fixtures — high-leverage targets for the next parser wave (after L15-SIMP lands).
2. **`tests/base/` checker rejections (`4` non-parse cases):**
   - `tests/base/result_maybe.bend` -> `check: resdo: type mismatch (expected Result<_, _, U32, U32>, got U32)` (`StRet` monadic goal unwrapping in `check.bend`).
   - `tests/base/f32_lerp_boundaries.bend` -> `check: main: unbound variable: e38` (scientific notation float literal `1e38` in `lex.bend`).
   - `tests/base/f32_hypot_range.bend` -> `check: main: call arity mismatch for triangle` (partial/curried call).
   - `tests/base/map_set_array_kit.bend` -> `check: arr: affine variable consumed more than allowed`.
3. **Zero crashes** across all `1,860` upstream `tests/*.bend` files (`~5.4 ms/file` including process spawn).


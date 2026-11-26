# `bend5k` Checker Conformance & Honest Verification Report (L14-CHECK)

**Base commit:** `50507223` · **CPU pin:** `taskset -c 2`  
**Owned files modified:** `selfhost/bend5k/check.bend` (`418 -> 626` LOC, `0 @unsafe`), `selfhost/bend5k/main.bend` (`104` LOC, `0 @unsafe`)  
**New artifacts:** `research/agy/bend5k/check_conformance.py`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md`

---

## 1. Reproduction & Root-Cause Diagnosis of Codex's Discrepancy

### Reproducer & Neighbors (Before Fix, `HEAD` `bend5k_o2` vs `locked_bun.sh --check-only`)

```bend
import Base
def wrong(x: U32) -> Bool:
  x
def main() -> U32:
  7
```

| Program | `bend5k_o2 --check-only` (HEAD) | `bend5k_o2 -O2` (HEAD) | `locked_bun.sh --check-only` | `s2 --check-only` (After Fix) | `s2 -O2` (After Fix) |
|---|---|---|---|---|---|
| `wrong_unused` (`def wrong(x: U32) -> Bool: x`, unused) | `ALL PROOFS CHECK` (rc=0) | **emitted 134,000 B `.o`** (rc=0) | `SOME PROOFS FAIL` (`expected: Bool, observed: U32`, rc=1) | `check: wrong: type mismatch (expected Bool, got U32)` (rc=1) | **rejected, no `.o`** (rc=1) |
| `wrong_called` (`wrong(7)` called by `main`) | `ALL PROOFS CHECK` (rc=0) | **emitted 134,224 B `.o`** (rc=0) | `SOME PROOFS FAIL` (`expected: Bool, observed: U32`, rc=1) | `check: wrong: type mismatch (expected Bool, got U32)` (rc=1) | **rejected, no `.o`** (rc=1) |
| `ok1` (`def ok(x: U32) -> U32: x`) | `ALL PROOFS CHECK` (rc=0) | emitted 134,000 B `.o` (rc=0) | `ALL PROOFS CHECK` (rc=0) | `CHECK OK (bend5k 1-pass: scope, arity, affine, head-types; no BendTT kernel proof)` (rc=0) | emitted `.o` (rc=0) |
| `ok2` (`def ok2(x: U32) -> Bool: U32.is_eq(x, 0)`) | `ALL PROOFS CHECK` (rc=0) | emitted 134,240 B `.o` (rc=0) | `ALL PROOFS CHECK` (rc=0) | `CHECK OK (bend5k 1-pass: scope, arity, affine, head-types; no BendTT kernel proof)` (rc=0) | emitted `.o` (rc=0) |

### Exact Root Cause in `HEAD`
1. `VarBind{sym: U32, dup: Bool}` stored no type information for local variables or parameters.
2. `DefInfo{arity, total_arity, ret_fn, is_import}` stored no parameter or return head-types; `CtorInfo{type_name, arity, fdups}` stored no field head-types.
3. `WExpr` arms for `EVar{sym}`, `ERef{sym}`, and `EApp{fun, args}` completely ignored `goal`, and `EApp`/`ECtr` checked arguments/fields with `goal = None{}`.
4. `ELet`, `StLet`, and `PCtr` patterns never propagated head-types into `VarBind`.
5. `selfhost/bend5k/main.bend:57` unconditionally printed `ALL PROOFS CHECK` on `--check-only` despite running only `bend5k`'s 1-pass checker (and never invoking independent BendTT kernel verification).

---

## 2. Frozen 60-Case Differential Conformance (Before vs After)

The 60-case corpus (`research/agy/bend5k/check_conformance_corpus.json`) was frozen **before** editing `check.bend` and run via `research/agy/bend5k/check_conformance.py` on CPU 2 against pinned upstream `research/agy/locked_bun.sh --check-only`.

### Core 4 Outcomes & Separate Diagnostics

| Metric | Baseline (`HEAD` `bend5k_o2`) | After L14-CHECK (`s2`) | Delta |
|---|---:|---:|---:|
| **1. `agree_accept`** (upstream accept, `bend5k` accept) | 19 | **19** | 0 |
| **2. `agree_reject`** (upstream reject, `bend5k` reject) | 16 | **36** | **+20** |
| **3. `false_accept`** (upstream reject, `bend5k` accept) | 21 | **1** | **-20 (-95.2%)** |
| **4. `false_reject`** (upstream accept, `bend5k` reject) | 4 | **4** | 0 |
| Crashes | 0 | **0** | 0 |
| Timeouts | 0 | **0** | 0 |
| Unsupported features (parser rejects upstream `{a == b : T}` / `Kind(a)`) | 4 | **4** | 0 |
| Incomplete proofs (proof-carrying accepted without BendTT) | 0 | **0** | 0 |
| **Invalid programs emitting usable `.o` under `-O2`** | **21** | **1** | **-20** |
| `bend5k --check-only` median latency (CPU 2) | 3.69 ms | **3.74 ms** | +0.05 ms |
| `bend5k --check-only` total across 60 cases | 236.33 ms | **241.40 ms** | +5.07 ms |
| Upstream `locked_bun.sh --check-only` median latency | 513.07 ms | 513.59 ms | — |

### Breakdown by Category (Before -> After)

| Category | Cases | Baseline (`HEAD`) | After L14-CHECK (`s2`) |
|---|---:|---|---|
| `return_value` | 8 | 2 agree_reject, **6 false_accept** | **8 agree_reject, 0 false_accept** |
| `call_argument` | 5 | 1 agree_reject, **4 false_accept** | **5 agree_reject, 0 false_accept** |
| `ctor_field` | 4 | 1 agree_reject, **3 false_accept** | **4 agree_reject, 0 false_accept** |
| `match_branch` | 4 | 0 agree_reject, **4 false_accept** | **4 agree_reject, 0 false_accept** |
| `affine_use` | 3 | 3 agree_reject | **3 agree_reject** |
| `unused_bad_def` | 4 | 1 agree_reject, **3 false_accept** | **4 agree_reject, 0 false_accept** |
| `valid_neighbor` | 12 | 12 agree_accept | **12 agree_accept** |
| `qual_valid` (Phase182) | 7 | 7 agree_accept | **7 agree_accept** |
| `qual_reject` (Phase182) | 3 | 3 agree_reject | **3 agree_reject** |
| `upstream_reject` | 1 | 1 agree_reject | **1 agree_reject** |
| `dependent_proof` (`boundary_bad_refl`) | 1 | 1 agree_reject (parse) | **1 agree_reject (parse)** |
| `grade_system` (`tests/grade/*`) | 4 | 3 agree_reject, 1 false_reject (parse) | **3 agree_reject, 1 false_reject (parse)** |
| `proof_or_dependent` (`tests/proof/*`, `alpha_equivalence`) | 3 | 3 false_reject (parse) | **3 false_reject (parse)** |
| `parametric_type_arg` (`boundary_param_type_arg`) | 1 | 1 false_accept | **1 false_accept** (documented boundary) |

---

## 3. General Fix Implemented

### `selfhost/bend5k/check.bend` (`0 @unsafe`, 1-pass, max `match` arity <= 3)
Added **one reusable head-type checking rule** (`b5k_chk_head_ok` / `b5k_chk_expect`) across the checker:
- **Type & Signature Indexing:** Extended `VarBind` (`typ: Maybe<&2, String>`), `CtorInfo` (`ftys`), `DefInfo` (`param_tys`, `live_tys`, `ret_ty`), and `PatItem` (`typ_inh`). Universe sorts (`Type`, `Data`, `Kind`, `Set`) and type variables map to `None{}` so polymorphic code and type-level arguments are never falsely rejected.
- **`Base` Builtins (`b5k_chk_builtin_sig`):** Conservative head-type signatures for `U32.*`, `F32.*`, `Bool.*` (including `Bool.pick`), `Char.*`, `String.*`, and `Nat.*`, verified against `bend2/base.bend`. Unknown builtins return `CallSig{Nil{}, None{}}`.
- **Unified Enforcement (including unused `def`s):**
  - `EVar`/`ERef` checked against `goal` via `VarBind.typ`.
  - `EApp` checks argument expressions against callee `param_tys` (or `live_tys` when erased params are omitted) via `WArgs`, and checks callee `ret_ty` against `goal`.
  - `ECtr` checks field expressions against `CtorInfo.ftys` via `WArgs`.
  - `EMat` / `EIf` check all branches against `goal`, `EIf` checks condition against `Bool`, and `PCtr` patterns propagate `CtorInfo.ftys` into `VarBind`.
  - `ELet` / `StLet` propagate `b5k_chk_infer_head(val)` into `VarBind`.
  - `EAnn`, `EUnit`, `EPair` (`Sigma`/`Pair`), `EList` (`List`), `EArrNew` (`Array`), and comparison `EOp` (`Bool`) enforce head-type compatibility.

### `selfhost/bend5k/main.bend`
- Replaced `ALL PROOFS CHECK` on `--check-only` with:
  ```
  CHECK OK (bend5k 1-pass: scope, arity, affine, head-types; no BendTT kernel proof)
  ```
  reserving `ALL PROOFS CHECK` strictly for runs that invoke full upstream/BendTT proof verification.

---

## 4. Full Qualification & Performance Evidence (CPU 2)

| Gate | Result | Evidence |
|---|---|---|
| Upstream frontend check (`locked_bun.sh --check-only`) | **PASS** | `ALL PROOFS CHECK`, `0 @unsafe`, `11,823 / 15,000` LOC |
| 3-stage self-hosting (`s1 -> s2 -> s3`, `-O2`) | **PASS** | `s2.o == s3.o` SHA-256 `be3594c19a5d5166f75422fe1182515da707e0686c12ebed2646a2c13713e6db` |
| Phase182 Qualification (`run_qual_b5k.py -O0`) | **64 / 64 PASS** | 61 exec + 3 reject (`4.77s`) |
| Phase182 Qualification (`run_qual_b5k.py -O2`) | **64 / 64 PASS** | 61 exec + 3 reject (`34.09s`) |
| Live-Metadata Observer Gate (`observer_wave2_gate` O0+O2) | **30 / 30 PASS** | 0 `OBSERVER_VIOLATION`s across `normal`, `cap-no8`, `all-hot` |
| **Combined Qualification Gate** | **158 / 158 PASS** | `64 + 64 + 30 = 158` |
| `bench/runtime/*` `.o` bit-identity vs `HEAD` | **17 / 17 SAME** | 0 diffs, 0 failures across all 17 benchmarks |
| `-O2` self-build time (CPU 2) | `5.225s -> 5.532s` | `+0.307s` (+5.9%) for full 11.8k LOC head-type checking + 208 LOC |
| `--check-only` median latency (CPU 2) | `3.69 ms -> 3.74 ms` | `+0.05 ms` (+1.4%) |

---

## 5. Largest Remaining Disagreement & Honest Capability Boundary

### Largest Remaining Disagreement (Smallest Reproducer)
```bend
import Base
def bad_list(xs: List<&2, U32>) -> List<&2, Bool>:
  xs
def main() -> U32:
  0
```
- **Upstream (`locked_bun.sh --check-only`):** rejects (`expected: Bool, observed: U32`).
- **`bend5k` (`s2`):** accepts (and emits `.o` under `-O2`), because both `List<&2, U32>` and `List<&2, Bool>` share the head-type `"List"`.

### Honest Capability Boundary of `bend5k`'s 1-Pass Checker
- **Enforced:** scope (unbound vars/refs), direct call arity, constructor existence/membership/arity, affine single-use checking, fixed-runtime foreign allowlist, and **first-order head-type checking** across return values, call arguments (user defs + `Base` builtins), constructor fields, match/if branches, `let` bindings, annotations, and unused definitions.
- **Not enforced (requires upstream `bend2` + BendTT kernel `--verdict`):**
  1. Parametric type arguments / type-constructor application arguments (e.g., `List<&2, U32>` vs `List<&2, Bool>`, `Maybe<&2, A>` instantiation).
  2. Dependent indices, normalization/conversion, and propositional equality (`{a == b : T}`, `{==}`, `rewrite`, `absurd` / `Empty`).
  3. Universe / grade / kind discipline (`Kind(a)`, `Data` vs `Type` field restrictions in `tests/grade/*`) and exhaustiveness / termination proofs.
  4. Parser support for full upstream proof surface syntax (`{a == b : T}`, `Kind(a)` — 4 pre-existing parse rejections on `tests/proof/*`, `tests/grade/accept_data.bend`, `tests/check/alpha_equivalence.bend`).

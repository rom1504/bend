# `bend5k` Non-IO Closed-Main x86 Execution Conformance Report (L21-CONF-EXEC-100)

**Base commit:** `89d393d6` (Proven-20) · **CPU pin:** `taskset -c 2`  
**Candidate `s2`/`s3` SHA-256:** `b5d63cc337dc8396be0707a6f1c175678563f0c8c6f0de15720bdccfb8a76f27` (`s2.o == s3.o`, `-O2`, 3-stage bit-identical, `13,102,160 B`)  
**Files modified:** `selfhost/bend5k/parse.bend`, `selfhost/bend5k/lower.bend`, `selfhost/bend5k/main.bend`, `research/agy/bend5k/l21_exec_conformance_report.md` (**`12,933 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Proven-20 vs L21-CONF-EXEC-100)

| Suite / Gate (CPU 2) | Proven-20 (`89d393d6`) | **L21-CONF-EXEC-100 (`s2`)** | Delta |
|---|---:|---:|---:|
| **Non-IO closed-main x86 `#|` (runnable fixed-runtime, `-O0`)** | `744 / 758` (`98.2%`) | **`758 / 758` (`100.0%`)** | **`+14` fixes (`0` remaining fixable)** |
| **Non-IO closed-main x86 `#|` (runnable fixed-runtime, `-O2`)** | `744 / 758` (`98.2%`) | **`758 / 758` (`100.0%`)** | **`+14` fixes (`0` `-O2`-only failures)** |
| **Non-IO closed-main x86 `#|` (all printable, incl. 6 fixed-ABI limits)** | `744 / 764` (`97.4%`) | **`758 / 764` (`99.2%`)** | **`+14` fixes (`6` fixed-runtime ABI limits)** |
| **`tests/{base,run,rfc}` (runnable fixed-runtime)** | `162 / 163` (`99.4%`) | **`163 / 163` (`100.0%`)** | **`+1` (`run/string_contains_long.bend`)** |
| **Phase182 Qualification (`run_qual_b5k.py`, O0 + O2)** | `64/64` + `64/64` | **`64/64` (`8.89s`) + `64/64` (`103.41s`)** | `0` regressions |
| **Observer Gate (`observer_wave2_gate.py --compiler s2`)** | `15 / 15` | **`15 / 15` PASS (`0` violations)** | `0` regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 2`)** | `11/11` + `13/13` | **`11/11` STRICT + `13/13` `[GEN-MATRIX]` GREEN** | `0` regressions |
| **Differential Checker (`check_conformance.py --suite all`)** | `160 / 160` | **`160 / 160` PERFECT (`0` FA, `0` FR, `0` invalid `.o`)** | `0` regressions |
| **3-stage `-O2` self-hosting (`s2.o == s3.o`)** | PASS | **PASS** (`s1->s2`: `14.08s`, `s2->s3`: `13.88s`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK` (`66.87s`, `0 @unsafe`, `12,933/15,000` LOC)** | PASS |

---

## 2. All 14 Fixed Compiler Bugs (`0 @unsafe`, general compiler fixes)

| # | Fixture | Root Cause | General Compiler Fix |
|---:|---|---|---|
| 1 | `compile/u32_to_nat_widen.bend` | `EAnn{EOp{0, ...}, Nat}` mapped `op=0` to U32 add (`19`), truncating `1n + U32.to_nat(2^32-1)` to `0`. | `lower.bend`: 3-mode `low_map_ops` (`0=U32`, `1=F32`, `2=Nat`), mapping `Nat` `+` to `162` (`__nat_add`, 48-bit checked Nat add) and dispatching `op=162` in `low_emit_op_go`. |
| 2 | `parse/array_literal.bend` | `[x : T^d]` dropped `is_m` in `KArrLen`, routing depth `d` through count-based `log2(d)`. | `parse.bend` + `lower.bend`: preserve `is_m` in `EArrNew` (`2` elems = `*n` count, `3` elems = `^d` depth) and emit `IArrOp 71` directly with `d` for `^d`. |
| 3 | `parse/array_set_call_row.bend` | Same `[1 : U32^1n]` depth-vs-count bug. | Fixed by #2 above. |
| 4 | `parse/operator_precedence.bend` | `.|.`, `.^.`, and `.&.` shared precedence `4` in `p_binop_info`, mis-parsing `4 .^. 6 .&. 3`. | `parse.bend`: restore full Bend precedence ladder (`||` < `&&` < cmp < `.|.` < `.^.` < `.&.` < `<< >> <>` < `+ - ++` < `* / %`) and right-associative `++`. |
| 5 | `import/ctr_named_def.bend` | `main.bend` remapped defs and constructors in one `rmap`, so imported `def Done` hijacked `ECtr{Done}` / `ERef{Done}` (Base `Result.Done`). | `main.bend`: split `RemapTab` into `rmap` (types/defs/laws) and `crmap` (constructors only); remap `ECtr`, `PCtr`, `ERef`, and `CtorDef` exclusively through `crmap`. |
| 6 | `import/sugar_ctr_tld.bend` | Imported `def Con` hijacked `ECtr{Con}` from `<>` list-cons sugar. | Fixed by #5 (`crmap` separation) + #8 (canonical module stem in `show_names`). |
| 7 | `import/sugar_alias.bend` | `import ./sugar_alias_lib.bend as String` shadowed prelude `String.append` (arity 2) with 1-arg `append`. | `lower.bend`: define internal `__b5k_str_append` in prelude; route 2-arg `String.append` calls to `__b5k_str_append` when user `String.append` has arity != 2. |
| 8 | `import/ops_own.bend` | Imported constructor printed with import alias `L.True{}` instead of canonical module stem `ops_own_lib.True{}`. | `main.bend`: record `StemMap{alias ++ ".", stem ++ "."}` during `b5k_load_imports` and rewrite `IrProg.show_names` prefixes before codegen/ELF emission. |
| 9 | `import/sugar_list_own.bend` | Printed `L.B{}` instead of `sugar_list_own_lib.B{}`. | Fixed by #8 above. |
| 10 | `show/imported_adt.bend` | Printed `L.Circ`/`L.Sq` instead of `imported_adt_lib.Circ`/`Sq`. | Fixed by #8 above. |
| 11 | `show/imported_adt_alias.bend` | Printed `L.Circ` instead of `imported_adt_lib.Circ`. | Fixed by #8 above. |
| 12 | `reg/const_shared_layout.bend` | `ShowSeen` keyed only on type head `tsym` (collapsing `Choice<Choice<...U32>>` into self-cycle) and lacked sibling DAG memoization ($2^{24}$ blowup). | `lower.bend`: key `ShowSeen` on structural type equality (`low_eq_go`), thread `seen` across sibling fields/constructors in `ShowBuild` (`STAdtFSub`), and bump `low_show_go` fuel to `2048n`. |
| 13 | `reg/show_array_layout_sum.bend` | `ShowSeen` collapsed `Two<U32, Two<U32, D>>` and `Two<U32, D>` to the same descriptor, segfaulting on readback. | Fixed by #12 above (`ShowSeen` structural type key). |
| 14 | `run/string_contains_long.bend` | Non-tail-recursive prelude `String.append` overflowed the machine stack on `repeat(21n, "a")` (`2^21` chars). | `lower.bend`: implement `__b5k_str_append(a, b)` tail-recursively via `String.reverse.go(String.reverse(a), b)` (O(1) stack space). |

*(Note: `run/nat_overflow.bend` and `run/nat_overflow_wide.bend` already match their `#|bend: a Nat past the largest immediate 2^48-1` + `#|exit 1` contract on both `-O0` and `-O2`.)*

---

## 3. Genuinely Unsupported Fixed-Runtime ABI & Interpreter-Only Lanes (NOT Counted as Passes)

Per `AGENTS.md`, unsupported lanes never count as passes.

### A. Fixed Immutable `runtime-agy.o` ABI Limits (`6` printable tests)
1. **`reg/far_import.bend`** — Transitive foreign C provider `F.far.make` unavailable in fixed runtime (`runtime.c:4082`).
2. **`check/large_arity.bend`** — `def pick` has `2000` parameters, exceeding `P111_REG_CAP = 256` (`runtime.h:8`, `runtime.c:4043`: `phase111: program entry or width mismatch`).
3. **`reg/wide_record_drop.bend`** — `Mk256` (256 fields) and `Mk300` (300 fields) exceed `const uint8_t *cid_arity` max 255 (`runtime.h:44`, `runtime.c:4092`: `phase111: constructor arity mismatch`).
4. **`reg/wide_record_stale.bend`** — `MkS` (256 fields) exceeds `uint8_t cid_arity` max 255 (`runtime.h:44`, `runtime.c:4092`).
5. **`rfc/drop_spine_wide.bend`** — `WSome` (300 fields) exceeds `uint8_t cid_arity` max 255 (`runtime.h:44`, `runtime.c:4092`).
6. **`run/array_nested_fork.bend`** — `runtime-agy.o`'s `rfc_seal` (`selfhost/src/runtime/qbe/runtime.c:865`) only seals `TAG_CTR`, not `TAG_BLK`/`TAG_BUF` (`Array` inside a constructor inside `Array.fork`), whereas upstream `bend2/comp.ts:3861` seals `TAG_ARR`/`TAG_BUF` under `BLK_SHR`.

### B. Upstream Interpreter-Only Non-Printable `main` Types (`31` tests)
In upstream `gates/test.ts` (lines 13–14, 97–98), tests whose `main` type is a function, `Type`, `Quant`, `Eq`, or function-bearing ADT are checked and interpreted only (never compiled to C/JS):
- **`check/` (3):** `let_dependent_type`, `let_unsafe_dependent_type`, `linear_binder_discard`
- **`eval/` (15):** `efq_arm_value`, `eta_expand_print`, `float_builtin_print`, `forall_type_print`, `hoas_binder_refresh`, `io_effect_tree`, `nat_literal_roundtrip`, `neq_unfold`, `partial_app_snf`, `printer_fixpoint`, `stuck_rewrite_print`, `stuck_split_mint`, `toplevel_ref_print`, `underscore_print`, `wildcard_chain_print`
- **`flatten/` (1):** `ctor_continuation`
- **`parse/` (2):** `fill_quant_block`, `quant_zero_literal`
- **`reg/` (1):** `interp_arm_share`
- **`show/` (3):** `cons_chain_readback`, `nullary_adt_scalar`, `nullary_adt_table`
- **`state/` (6):** `eval_case_tree_000`, `eval_case_tree_001`, `eval_case_tree_002`, `eval_curried_tree`, `eval_refl_value`, `eval_split_apply`

# `bend5k` Full Upstream Conformance & Verification Report (L17-FULL-CONF)

**Base commit (`HEAD`):** `208dbde4` (Proven-16) · **CPU pin:** `taskset -c 2`  
**Candidate `s2`/`s3` SHA-256:** `10338463c763a84ae0d578530decc7dad6619eb560ad11cccc1671ef067e1c00` (`s2.o == s3.o`, `-O2`, `9.75s -> 7.84s`)  
**Owned files modified:** `selfhost/bend5k/lex.bend` (`328 -> 373`, `+45` LOC), `selfhost/bend5k/parse.bend` (`667 -> 694`, `+27` LOC), `selfhost/bend5k/check.bend` (`862 -> 1,062`, `+200` LOC), `selfhost/bend5k/lower.bend` (`1,589 -> 1,589`, `+0` net LOC / prelude `Set.size` + `Set.from_list`), `selfhost/bend5k/main.bend` (`94 -> 344`, `+250` LOC), `research/agy/bend5k/check_conformance.py`, `research/agy/bend5k/check_conformance_corpus.json`, `research/agy/bend5k/check_conformance_report.md` (**`13,397 / 15,000` assembled LOC**, **`0 @unsafe`**).

---

## 1. Executive Summary (Before vs After)

| Suite / Gate | Proven-16 (`208dbde4`, `HEAD`) | **L17-FULL-CONF (`s2`)** | Delta vs `HEAD` |
|---|---:|---:|---:|
| **Frozen 60-case corpus (`frozen60`)** | `23 acc / 37 rej / 0 false_acc / 0 false_rej` | **`23 acc / 37 rej / 0 false_acc / 0 false_rej`** | **60 / 60 (0 regressions)** |
| **Parametric 20-case corpus (`v2_parametric`)** | `8 acc / 12 rej / 0 false_acc / 0 false_rej` | **`8 acc / 12 rej / 0 false_acc / 0 false_rej`** | **20 / 20 (0 regressions)** |
| **NEW Dependent Proof corpus (`v3_dependent`)** | *not present* | **`4 acc / 8 rej / 0 false_acc / 0 false_rej`** | **+12 / 12 exact** |
| **Combined `check_conformance.py --suite all`** | `80 / 80` (`0` invalid `.o`) | **`92 / 92` (`0` false_acc, `0` false_rej, `0` invalid `.o`, `5.27 ms` median)** | **+12 cases, 0 regressions** |
| **Upstream `tests/**` positive `--check-only`** | `1,130 / 1,180` (`95.8%` non-foreign) | **`1,167 / 1,178` (`99.1%` non-foreign, `91.2%` of `1,279` incl. foreign)** | **`+3.3 pp` (`+37` non-foreign, incl. multi-file imports)** |
| **Parser rejections on positive `tests/**`** | `10` | **`0`** | **`-10` (`100%` parser conformance!)** |
| **Checker rejections on positive `tests/**`** | `40` (`16` non-import + `24` local-import) | **`11`** (total incl. multi-file imports) | **`-29` (`-72.5%`)** |
| **`tests/{base,run,rfc}` x86 `#|` exact stdout** | `139 / 160` (`86.9%`) | **`147 / 159` (`92.5%`)** (`base`: `41/42 = 97.6%`, `run`: `94/103 = 91.3%`, `rfc`: `12/14 = 85.7%`) | **`+8` exact (`+5.6 pp`), 7/8 float/escape diffs fixed** |
| **Full `tests/**` runnable x86 `#|` audit** | *not audited* | **`593 / 1,015` (`58.4%` overall; `593 / 774 = 76.6%` closed-main)** | Baseline established across 22 namespaces |
| **Phase182 + Observer Qualification Gate** | `64 O0 + 64 O2 + 15 Observer` PASS | **`64 O0 + 64 O2 + 15 Observer` PASS** (`0` violations) | 0 regressions |
| **Cost-Law Gate (`law_gate.py --cpu-pin 2`)** | `8/8` strict, `10/10` GREEN | **`8/8` strict, `10/10` GREEN** | 0 regressions |
| **3-stage `-O2` self-hosting (`s2 == s3`)** | PASS | **PASS** (`s2.o == s3.o`, `9.75s -> 7.84s`, bit-identical) | Bit-identical |
| **Upstream `locked_bun.sh --check-only`** | `ALL PROOFS CHECK` | **`ALL PROOFS CHECK`** (`0 @unsafe`, `13,397 / 15,000` LOC) | PASS |

---

## 2. Changes Implemented Across All 3 Pillars (`0 @unsafe`)

1. **Lexer (`selfhost/bend5k/lex.bend`, `+45` LOC):**
   - **64-bit `(hi, lo)` decimal-to-`F32` mantissa scanner (`lex_u64_m10_lo`/`hi`, `lex_u64_to_f32_go`, `lex_f32_from_dec`)** with trailing-zero deferral in `lex_scfrac_go` and exact single-rounding to IEEE-754 `F32` (fixing `0.125`, `0.0009765625`, `4294967296.0`, `281474959933440.0`, `1.0e21`, and `1.25e-2 == 0.0125`).
   - **Unicode `\u{...}` escape support in string literals** (`lex_scan_str_go`, structurally self-recursive 4-state scanner; fixes `\u{b}`, `\u{c}`, `\u{0}`, `\u{ffffffff}`).
2. **Parser (`selfhost/bend5k/parse.bend`, `+27` LOC — `10 -> 0` parser rejections!):**
   - Paren-depth-aware `p_scan_targs` so `;` inside `(...)` does not abort `<...>` type-argument lookahead (`let_in_argument.bend`, `rwt_type_share.bend`).
   - Removed `->` (`256`) from `p_scan_assign_go` stop set so typed lets with function types (`g : @+n: Nat -> ... = ...`) parse cleanly (`let_levels.bend`).
   - Layout-free `do` inside parens (`GDo` stops on `)`, `]`, `}`, `,`, `return` terminates `do`, skips inner `TkIndent`), layout-free `case` alignment (`GCases` + `GSuite`), multi-line `def ... -> \n RetType:` (`p_def_body_go`), multi-line `GCtors{False{}}` (`ctr_param_chain.bend`), `KParenTy` preserving tuple prefix (`op_let.bend`), inline `let` continuation without `;` (`expr_let_erased_lam.bend`), and `KLawWhere` clearing `where`-packed param type + handling `exs`.
3. **Checker + Dependent Proof Phase 1 (`selfhost/bend5k/check.bend`, `+200` LOC):**
   - **Dependent equality type `TEq{lhs, rhs}` & closed constant evaluator (`CVal`, `b5k_chk_eval_c`, `b5k_chk_cv_neq`)**: evaluates closed pure `U32`/`Nat` (`Zero`/`Succ`/`ENum`)/`Bool`/`String`/`EOp`/`ECtr`/`EPair` expressions; rejects invalid `{==}` reflexivity proofs (e.g. `{U32.add(2,3) == 6}`, `{Succ{Succ{Zero{}}} == Succ{Zero{}}}`, `{Bool.not(True{}) == True{}}`), rejects `{==}` against non-`Equal` goals, rejects mismatched equality proof variables (`{0==0}` for `{0==1}` or `{1==2}` for `{2==1}`), and infers `Equal.sym` / `Equal.trans` return types.
   - **Erased-context & affine accuracy**: `TErased{}` + `TFun{pdup, ret}` propagation through `WArgs`, `EAnn`, `EUnOp`, `ELam`, and `b5k_chk_env_all_dup`; `+h <> +t` scrutinee re-duplication (`b5k_chk_redup_binds`); `Word.Nil`/`Word.Con` for `Word`; `Tuple` in `b5k_chk_pair_goal_ok`; `&&`/`||` comparison annotations; type-param shadowing in `b5k_chk_index_all_ctors`; user-def shadowing of Base types (`b5k_chk_unseed_defs`); pattern fuel `256 -> 1024`.
4. **Multi-File Relative Import Loader (`selfhost/bend5k/main.bend`, `+250` LOC):**
   - Resolves local `./` and `../` `.bend` imports (including transitive imports and `as Alias` / default stem) by parsing imported modules into the shared `SymTab`, hygienically prefixing top-level types/ctors/defs/laws (respecting local binder shadowing), and merging them into the `Book` before checking and lowering.
5. **Base Prelude (`selfhost/bend5k/lower.bend`):**
   - Added `Set.size` and `Set.from_list` / `Set.from_list.go` (fixing `tests/base/map_set_array_kit.bend`).
   - Note on `bench/runtime/*` `.o` bit-identity: adding 3 prelude defs shifts prelude `fid` numbers by `+3`, so `.o` hashes differ from `HEAD` (zero codegen/perf regression; `8/8` strict Cost-Law contracts and `10/10` Generality Matrix GREEN).

---

## 3. Differential Conformance (`check_conformance.py --suite all`, CPU 2)

| Suite | `agree_accept` | `agree_reject` | `false_accept` | `false_reject` | Invalid `.o` (`-O2`) | Crashes |
|---|---:|---:|---:|---:|---:|---:|
| `frozen60` (60 cases) | **23** | **37** | **0** | **0** | **0** | 0 |
| `v2_parametric` (20 cases) | **8** | **12** | **0** | **0** | **0** | 0 |
| `v3_dependent` (12 cases) | **4** | **8** | **0** | **0** | **0** | 0 |
| **Total (`all`, 92 cases)** | **35** | **57** | **0** | **0** | **0** | **0** |

Median `bend5k --check-only` latency across all 92 cases: **`5.27 ms`** (total `516.37 ms`). (In the single CPU-2 sweep, 3 upstream `locked_bun.sh` invocations hit the 30s bun startup timeout while `bend5k` returned the exact verdict in `5.5–6.6 ms`; all 92 cases have `0` false-accepts, `0` false-rejects, and `0` invalid `.o`.)

---

## 4. Upstream `tests/**` `--check-only` (`1,167 / 1,178 = 99.1%` non-foreign)

- **Total positive `#|` fixtures:** `1,279` (`1,178` non-foreign, `101` foreign-provider rejections).
- **Accepted:** **`1,167 / 1,178` (`99.1%` non-foreign, `91.2%` overall)**.
- **Parser rejections:** **`0`** (`10 -> 0`).
- **Remaining `11` checker rejections:**
  - `5` existential `exs` law return types returning a Sigma pair (`assert_full_spec`, `division_algorithm`, `exists_where`, `exists_witness`, `nested_exists`).
  - `4` Base-free / own-lib imported namespace interactions (`ctr_named_def`, `ops_own`, `sugar_ctr_tld`, `sugar_list_own`).
  - `2` misc (`fits_residual_fallback`, `dead_arm_shared`).

---

## 5. X86 Execution Conformance (`tests/{base,run,rfc}` + Full `tests/**` Audit)

### A. `tests/{base,run,rfc}` (`147 / 159` = **`92.5%`** exact `#|` stdout, up from `139 / 160` = `86.9%`)
- `tests/base/`: **`41 / 42` (`97.6%`)** — only `list_fold.bend` (line 15: `List.sort` with `~String.is_le`) differs.
- `tests/run/`: **`94 / 103` (`91.3%`)** — `4` open-main `harness_cache_*`, `2` deep-tail stack overflow (`js_group_args`, `js_tail_closure`), `1` `map_bit_native` (`Nat.divmod` wide `Nat`), `1` `f32_read_round_once`, `1` `native_numeric_boundaries` (wide `Nat`).
- `tests/rfc/`: **`12 / 14` (`85.7%`)** — `drop_array_spine`, `drop_spine_wide` (300-field wide ctor).

### B. Full `tests/**` Single-File Runnable `#|` Audit (`593 / 1,015` = **`58.4%`** overall; **`76.6%`** of closed-main)
Audited all `1,015` positive `#|` fixtures across `22` namespaces (excluding foreign/interactive-host namespaces `io`, `gfx`, `net`, `http`, `app`, `gpu`, `metal`, `cuda`, `web`, `audio`, `window`, 3s timeout per binary, temp `.o`/exe deleted immediately):

| Namespace | Exact `#|` PASS | Total | Rate |
|---|---:|---:|---:|
| `base` | 41 | 42 | **97.6%** |
| `run` | 94 | 103 | **91.3%** |
| `reg` | 96 | 108 | **88.9%** |
| `compile` | 120 | 139 | **86.3%** |
| `rfc` | 12 | 14 | **85.7%** |
| `halt` / `cost` / `page` / `spec` | 17 | 17 | **100.0%** |
| `stats` | 4 | 5 | **80.0%** |
| `check` | 81 | 113 | **71.7%** |
| `parse` | 44 | 86 | 51.2% |
| `show` / `grade` | 7 | 14 | 50.0% |
| `eval` / `import` | 27 | 63 | 42.9% |
| `proof` / `stuck` / `comptime` | 40 | 113 | 35.4% |
| `flatten` / `printer` / `state` | 10 | 198 | 5.1% |
| **Total (`22` namespaces)** | **593** | **1,015** | **58.4%** (`76.6%` closed-main) |

**Top Gap Buckets Across `tests/**` (`422` non-exact out of `1,015`):**
1. **`204`** `runtime: main must be a closed ordinary segment` + **`37`** `symbolic_open_term_diff` (`241` total — open/lambda-printing tests, predominantly `tests/flatten/`, where upstream prints symbolic open terms).
2. **`117`** `stdout_value_diff` (value printing / prelude semantics differences on pure non-IO `main` values).
3. **`21`** `runtime: constructor arity mismatch` + **`13`** `runtime: take arity mismatch` (`34` total — wide/imported/erased constructor lowering).
4. **`11`** `check_reject`, **`5`** `runtime fail-stop`, **`5`** `Nat > 2^48-1`, **`3`** `stack overflow`, **`2`** `primitive arity mismatch`, **`2`** `link_err`, **`1`** `program entry/width mismatch`.

# Upstream Migration Boundary Report (`9a4223d5` -> `6180be5b`)

**Branch:** `l20-upstream-migrate` (based on Proven-19 `801fde8a`)  
**Target upstream commit:** `6180be5b21c4af6895395b27ad3cde026909364e` (`upstream/main`, 2026-11)  
**CPU pin:** `taskset -c 0`  
**`git diff upstream/main -- bend2/`:** **EMPTY (0 lines)** — exact upstream `bend2/` with zero hand edits to `bend2/bend.ts`.

---

## 1. Migration Scope & Boundary Preservation

- **Synced cleanly from `upstream/main` (`6180be5b`):** `bend2/`, `tests/`, `bench/`, `gates/`, `guide/`, `demos/`, `tools/`.
- **Preserved untouched:** `selfhost/`, `experiments/`, `docs/self_hosted/`, `design/`, `implementation/`, `AGENTS.md`, `README.md`, `.gitignore`, and all historical pinned reference checkouts.
- **Compatibility fixes required in `selfhost/bend5k/*.bend`:** **None (`0` LOC changed, `0 @unsafe`)**. All `12,917 / 15,000` assembled LOC of `bend5k` and `selfhost/bend5k/laws/ownership_laws.bend` pass the new upstream `6180be5b` `--check-only` verbatim.

---

## 2. Upstream Delta Summary (`bend2/` & ABI Boundaries)

| Component | Diff Stat | Key Upstream Changes | Impact on `bend5k` / `runtime-agy.o` |
|---|---:|---|---|
| `bend2/bend.ts` | `+7 / -5` (12 lines) | Memoize failed typed-let annotation offsets in `Parse.ann: Set<number>` (#2133) to prevent exponential backtracking on nested annotations. | **None.** Pure parser perf fix; no grammar or checker semantics change. |
| `bend2/base.bend` | `+293 / -138` (431 lines) | `IO.within` deadline retirement (#2206); single-division `Nat.div`/`Nat.mod` (#2173); bounded `Nat.read` length check (#2209); reverse-walk `Array.show` (#2285); `String.eq`/`ends_with`/`contains` fast paths; single-walk cursor `Map.{get,set,has,pop,union}` (#2105, #2128, #2130, #2145, #2191, #2203). | **Compatible.** Public signatures unchanged; `bend5k` checks cleanly against new `base.bend`. |
| `bend2/comp.ts` | `+187 / -188` (375 lines) | `corpus_grow`/`err_spun` stop flag, `array_swap`, nested array field counting in shared records (#2198), `Nat.mul` overflow guard above `2^32` (#2174), `arm_self` refactor (#2108), module own-exports (#2224), `emit_unfold` let-type substitution (#2288). | **Isolated.** `bend5k` compiles directly to x86-64 ELF and links `runtime-agy.o`. |
| `bend2/effs/*` | `+237 / -32` (9 files) | Per-handle `File.read_line` buffering (#2178), stdout flush before native IO (#2155), zero-cap error preservation (#2187), JS buffer reads (#2200), Node <20.16 `Process.run` loader (#2226). | **Isolated.** Fixed runtime ABI (`runtime-agy.o`) unchanged; foreign-provider tests remain explicitly rejected by policy. |
| `bend2/main.ts` | `+44 / -13` (57 lines) | Source `file:line:col` error locations (`book_location`, #2208, #2286), `checkup` import order (#2201), Node default type-stripping (`Check_Fail`, #2204), stack-overflow message guard (#2122). | **None.** `--check-only` exit status and `ALL PROOFS CHECK` contract preserved. |
| `bend2/safe.ts` | `+10 / -10` (20 lines) | Alpha-invariant `tkey` ignoring binder names in instance keys (#2099), Node type-stripping (`Regroup`). | **None.** BendTT elaboration boundary preserved. |

---

## 3. Validation Matrix (All Gates on CPU 0)

| Gate / Check | Result | Evidence / Notes |
|---|---|---|
| **Upstream `bend2/` exactness** | **PASS** | `git diff upstream/main -- bend2/` = `0` lines (`bend2/bend.ts` untouched). |
| **New upstream `--check-only` (`bend5k.bend`)** | **PASS** | `ALL PROOFS CHECK` (`12,917 / 15,000` LOC, `0 @unsafe`) via `6180be5b` `bend2/main.ts`. |
| **New upstream `--check-only` (`ownership_laws.bend`)** | **PASS** | `ALL PROOFS CHECK` via `6180be5b` `bend2/main.ts`. |
| **3-stage `-O2` self-host (`s1.o == s2.o == s3.o`)** | **PASS** | Bit-identical SHA-256 `b0827f38243880aab528250674e36c37483963b6094664db62019893a1d4a699`. |
| **Qualification Catalog (`run_qual_b5k.py`, O0)** | **64 / 64 PASS** | `61` exec + `3` reject (`33.90s`). |
| **Qualification Catalog (`run_qual_b5k.py`, O2)** | **64 / 64 PASS** | `61` exec + `3` reject (`289.80s`). |
| **Cost-Law Gate (`law_gate.py --cpu-pin 0`)** | **11 / 11 STRICT PASS** | Contracts A, B, C, D, E, H, I, J, K, L, M all PASS; `10 / 10` core GEN-MATRIX GREEN. |
| **Differential Conformance (`check_conformance.py --suite all`)** | **130 / 130 PASS** | Against NEW upstream `6180be5b`: `44 agree_accept`, `86 agree_reject`, `0` FA, `0` FR, `0` crashes, `0` timeouts, `0` invalid `.o`, `4.06 ms` median. |

---

## 4. Upstream `tests/**` `--check-only` Before vs After (`801fde8a` vs `6180be5b`)

Measured with `s2 --check-only` across all non-foreign `tests/**/*.bend` fixtures with `#|` expectations (same classification script on both trees):

| Metric | Before (`801fde8a`) | After (`6180be5b`) | Delta |
|---|---:|---:|---:|
| **Positive `--check-only` (incl. runtime `#|exit 1`)** | `1,186 / 1,194` (`99.33%`) | **`1,204 / 1,213` (`99.26%`)** | **`+18 / +19`** (`18/18 = 100%` excl. 1 transitive-foreign test) |
| **Negative `--check-only` False-Accepts (FA)** | `122 / 523` (`23.33%`) | **`122 / 524` (`23.28%`)** | **`+0` FA** (`1/1` new negative test rejected) |

### Namespace Deltas (`6180be5b` vs `801fde8a`)

| Namespace | POS Before -> After | NEG FA Before -> After | New Upstream Tests Added (`25` total `.bend`) |
|---|---:|---:|---|
| `base` | `42/42` -> **`45/45`** | `0/4` -> `0/4` | `map_get_cursor`, `map_leaf_eq`, `string_ends_with` (3/3 PASS) |
| `check` | `124/125` -> `124/125` | `61/162` -> **`61/163`** | `hole_todo_group` (1/1 NEG REJECTED) |
| `compile` | `138/139` -> **`139/140`** | `0/10` -> `0/10` | `gpu_reach_closure_name_key` (1/1 PASS) |
| `io` | `110/115` -> **`113/119`** | `0/14` -> `0/14` | Non-foreign: `file_read_line_rest`, `file_read_line_write`, `tcp_recv_cap`, `within_shutdown` (4/4 PASS); `within_overdue` (transitive foreign `Pause.hold` policy reject); foreign: `bundle_own_exports`, `cli_source_location`, `file_read_line_stdout_order`, `write_empty` (4) |
| `parse` | `86/86` -> **`87/87`** | `21/85` -> `21/85` | `annotation_nested` (1/1 PASS) |
| `proof` | `85/85` -> **`87/87`** | `2/34` -> `2/34` | `array_perfect_tree` (1,093 LOC), `template_alpha` (2/2 PASS) |
| `reg` | `108/109` -> **`110/111`** | `2/6` -> `2/6` | `arm_self_erased_lam`, `unfold_poly_hot` (2/2 PASS) |
| `run` | `103/103` -> **`108/108`** | `0/6` -> `0/6` | `array_nested_fork`, `array_wrap_high_index`, `nat_div_native`, `nat_mul_wide`, `nat_overflow_wide` (`rt_exit`), `string_contains_lent` (6/6 PASS) |

*Note:* `tests/run/array_nested_fork.bend` is a valid runtime test (`#|4`, `#|4`, `#|8`) that `bend5k --check-only` accepts; upstream `bend2 --check-only` flags `1 def relies on unsafe or foreign code: main` because `Array.fork` is `@unsafe` in `base.bend`.

---

## 5. Verdict

Upstream migration to `6180be5b21c4af6895395b27ad3cde026909364e` is **CLEAN AND QUALIFIED**:
- Exact upstream `bend2/` (`0`-line diff vs `upstream/main`).
- Zero regressions across self-hosting (`s1.o == s2.o == s3.o`), qualification (`64/64` O0 + `64/64` O2), law gate (`11/11` strict), differential conformance (`130/130`), and upstream `tests/**` (`+18/18` new non-foreign positives, `+0` false-accepts).

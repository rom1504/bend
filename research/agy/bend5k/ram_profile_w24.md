# Wave 24: `lower.bend` RC Branch-Drop `ISink`, Lazy `Bool.pick`, & Pattern-Match RC Conservation (`2,120.9 MiB -> 183.6 MiB` Peak RSS)

**Base:** `ecace29f` (Proven-23, `10,574` LOC, `0 @unsafe`)  
**Scope:** `selfhost/bend5k/lower.bend` (strict ownership; all other compiler modules and runtime untouched)  
**Measurement:** All timings & `ru_maxrss` pinned to CPU 0 (`taskset -c 0`, `os.wait4`).

---

## 1. Root Causes Fixed in `selfhost/bend5k/lower.bend`

Building on Wave 23's fused per-function streaming backend (`elf_stream_big_go`, 16B packed `.text`, chunked `File.write_bytes`), we eliminated five systematic reference-count leaks in `lower.bend`:

1. **Branch-Drop `ISink` in `EIf` and `EMat` (`low_emit_if_sinks`, `low_mat_drops_cs`, `low_emit_case_sinks`):**
   - `count_uses_go` assigns each variable `max(u_1, ..., u_k)` references across branches of `EIf` and `EMat`, but previously branch `i` never sank the `max - u_i` unconsumed references.
   - For `EIf{c, t, f}`, we now compute free variables `fvs` of `[t, f]` in `base_vm` and emit `uf - ut` `ISink` ops at the start of `then` (when `ut < uf`) and `ut - uf` `ISink` ops at the start of `else` (when `uf < ut`), skipping known scalars (`nvm == 1`).
   - For multi-case `EMat` (`LTCases`, `LTCasesGrp`, `LTCasesTake`, `LTCmpCases`), we compute `drops: List<&2, BranchDrop>` once from the original case list and emit `max_u - u_case` `ISink` ops right after all pattern tests for the matched case succeed (before `LTExpr{body}`), using the outer register from `drops` so shadowing is handled soundly.
2. **Lazy `Bool.pick(T, c, t, f)` Lowering (`LTAppPick`, `low_emit_pick_sinks`):**
   - Previously, `Bool.pick` evaluated both `t` and `f` eagerly and selected with `cmovne` without sinking the discarded arm — leaking every discarded heap value and causing exponential blowup on recursive `Bool.pick` calls (such as `check.bend:chk_expr_sym_any`).
   - Saturated `Bool.pick(T, c, t, f)` now lowers directly to `EIf{c, t, f}`, preceded by `min(ut, uf)` `ISink` ops on each non-scalar free variable of `[t, f]`. Because `min(ut, uf) + max(ut, uf) = ut + uf`, reference counts are conserved identically to `count_uses_go` while avoiding allocation of the unchosen arm altogether.
3. **Closure-Capture Use-Count Capping in `count_uses_go` (`ELam` & `EDo`):**
   - `ELam` deduplicates captured free variables via `fv_go` and consumes exactly `1` reference per captured variable in the outer scope (re-counting uses inside the lambda via `low_bind_lam_caps`), but `count_uses_go` previously returned the raw inner use count `k`, leaking `k - 1` references on every multi-use capture (e.g., `low_if` thunks).
   - `count_uses_go` now caps non-empty `ELam` (and `EDo` continuation tails) at `1`.
4. **Deferred `PWild` / 0-Use `PVar` & `low_maybe_keep` Success-Path Sinks (`low_match_pats_go`, `low_pat_did_keep`):**
   - Previously, in every non-last `case` (`has_fail = True`), `PWild{}` and 0-use `PVar` skipped `ISink`, and any scrutinee kept by `low_maybe_keep` before `ITake` leaked its extra reference whenever the case succeeded.
   - `low_match_pats_go` now accumulates deferred sinks in `sinks: List<&2, U32>` and emits them via `cfg_emit_sink_list` once all pattern tests in the case succeed.
5. **Fail-Path Cleanup Trampolines for Nested Refutable Patterns (`FailWrap`, `low_wrap_fail`, `cfg_flush_cblks`):**
   - When `low_maybe_keep` + `ITake`/`IArrOp` extracts heap fields in a nested refutable pattern (e.g. 2-element peephole rules `Con{Pat1, Con{Pat2, t}}`) and a subsequent pattern test fails, the freshly extracted heap fields (`t`, etc.) previously leaked on the jump to `fail_blk`, pinning entire `List<X64Inst>` / `List<IrOp>` tails.
   - `low_wrap_fail` allocates a chained cleanup block (`ISink` extracted non-scalar fields + `TJmp{prev_fail_blk}`) and defers flushing into `CfgSt.blocks` until Block 0 is sealed (`cfg_flush_cblks`), preserving entry-block ordering.

---

## 2. Incremental Peak RSS Progression (CPU 0, Native `--manifest` `s2 -> s3 -O2`)

| Iteration | `--check-only` RSS | `-O0` RSS | `-O2` RSS | `-O2` Wall |
|---|---:|---:|---:|---:|
| Baseline (`bend5k_o2`, Proven-23) | `633.0 MiB` | `1,077.8 MiB` | `2,120.9 MiB` | `7.284s` |
| + `EIf` / `EMat` branch-drop `ISink` | `125.0 MiB` | `468.3 MiB` | `1,007.3 MiB` | `8.481s` |
| + `ELam`/`EDo` cap + deferred `PWild`/`PVar` sinks | `117.1 MiB` | `448.3 MiB` | `981.4 MiB` | `9.562s` |
| + `low_maybe_keep` success-path sinks | `93.1 MiB` | `278.4 MiB` | `647.5 MiB` | `9.314s` |
| + Nested fail-path cleanup trampolines | `47.1 MiB` | `132.4 MiB` | `187.7 MiB` | `10.155s` |
| + Lazy `Bool.pick` -> `EIf` (`min(ut, uf)` sink) | **`47.1 MiB`** | **`138.4 MiB`** | **`183.6 MiB`** | **`7.844s`** |

---

## 3. Before / After Self-Compile Summary (CPU 0, Native `--manifest` 3-Stage Self-Host)

| Mode | Baseline (`bend5k_o2`) Wall / Peak RSS | After W24 (`s2 -> s3`) Wall / Peak RSS | Wall Delta | Peak RSS Delta |
|---|---:|---:|---:|---:|
| `--check-only` | `3.188s` / `633.0 MiB` | **`2.712s`** / **`47.1 MiB`** | **`-14.9%`** | **`-92.6%` (`13.4x` smaller)** |
| `-O0` | `4.811s` / `1,077.8 MiB` | **`4.747s`** / **`138.4 MiB`** | **`-1.3%`** | **`-87.2%` (`7.8x` smaller)** |
| `-O2` | `7.284s` / `2,120.9 MiB` | `7.844s` / **`183.6 MiB`** | `+7.7%` | **`-91.3%` (`11.6x` smaller, `-1,937.3 MiB`)** |
| `s2.o == s3.o` | PASS | **PASS (100% bit-identical, `2ead224acea73bbc`)** | — | — |

---

## 4. Micro-Reproducer & RC Stress Test Results (CPU 0)

| Benchmark | Baseline `-O0` | Baseline `-O2` | W24 `-O0` | W24 `-O2` | Output |
|---|---:|---:|---:|---:|---|
| `Bool.pick(RV, False{}, mk_rv(7n), E{})` x `1,000` | `6.8 MiB` | `6.8 MiB` | **`6.8 MiB`** | **`6.8 MiB`** | `1000` |
| `Bool.pick(RV, False{}, mk_rv(7n), E{})` x `5,000` | `17.8 MiB` | `12.0 MiB` | **`6.8 MiB`** | **`6.8 MiB`** | `5000` |
| `Bool.pick(RV, False{}, mk_rv(10n), E{})` x `5,000` | `119.9 MiB` | `82.0 MiB` | **`6.8 MiB`** | **`6.8 MiB`** | `5000` |
| Nested `if`/`match`/closure/`List`/`Tree`/`Array<U32>` x `4,000` | `15.8 MiB` | `11.9 MiB` | **`6.7 MiB`** | **`6.7 MiB`** | `260750000` |

---

## 5. Verification Gates (All Pinned to CPU 0)

1. **`0 @unsafe` in `selfhost/bend5k/`**: **PASS** (`0` `@unsafe` definitions).
2. **`build_b5k.py --check-only`**: **PASS** (`ALL PROOFS CHECK`, `54.71s`, `10,811` LOC).
3. **3-Stage Native `--manifest` Self-Host (`s2.o == s3.o`)**: **PASS** (`2ead224acea73bbc`, `183.6 MiB` `-O2` peak RSS).
4. **`reg_w22_sound.py --cpu 0`**: **`24/24` PASS** (`19.02s`).
5. **`check_conformance.py --suite all --cpu 0`**: **`200/200` PERFECT** (`52 agree_accept`, `148 agree_reject`, `0 false_accept`, `0 false_reject`, `0 crashes`, `0 timeouts`, `0 invalid .o`).
6. **`run_qual_b5k.py --opt O0` & `--opt O2`**: **`64/64` PASS** (`-O0`: `9.04s`, `-O2`: `128.40s`).
7. **`eval_split_w23/evaluate.py --split validation --skip-bun-check --cpu-pin 0`**: **PASS** (`4/4` families, `8/8` configs, `8/8` exact checksums; `vs_P22 = 0.9373x` / `1.0520x`).
8. **`law_gate.py --cpu-pin 0`**: `18/20` base contracts PASS (`12/13` `[GEN-MATRIX]`):
   - **Follow-up note for `opt.bend`/`x64.bend` owners (outside strict `lower.bend` ownership):** `Contract E (holdout:ro_arr_sum)` and `Contract T (kv_find)` now properly receive an exit-block `ISink{a}` / `ISink{req}` in `case 0n:` (fixing the leak in those loops). Whitelisting `ISink` in `opt.bend:opt_cadt_rp_safe_op` (line 2138) and `x64.bend`'s array-hoist scanner will restore both to GREEN without reintroducing leaks.

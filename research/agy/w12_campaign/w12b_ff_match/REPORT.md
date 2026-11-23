# W12-B Report: Root-Cause Fix for `ff_match` / `f_hit_rows` Exponential Wildcard-Duplication Blowup

**Status:** **PROMOTED — `64.8x` `p86_plan` speedup on unflattened `w2_asr_strip_self` (`31,276 ms -> 483 ms`), `46.2x` `p86_plan` speedup on unflattened `p186ch_expand` (`28,950 ms -> 627 ms`), `15.4x` / `8.57x` `x198pw_plan` speedups, `--check-only` PASS (`0` errors across `8,679` defs), `64/64 native64` (`-O2`) PASS, and `15/15` Observer Gate PASS (`0` violations).**

- **Dedicated CPU:** CPU `6` (`taskset -c 6`)
- **Base compiler (read-only):** [`selfhost/build/agy/wave10_unified/compiler.bend`](file:///home/ai/bend2_agy/selfhost/build/agy/wave10_unified/compiler.bend)
- **Patched compiler:** [`compiler_w12b.bend`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/compiler_w12b.bend)
- **Unified patch (`18` hunks, `431` lines):** [`w12b_ff_match.patch`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/w12b_ff_match.patch)
- **Reproducible patcher & micro-repros:** [`apply_w12b.py`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/apply_w12b.py), [`bench_repros.py`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/bench_repros.py), [`repro_p186ch.bend`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/repro_p186ch.bend), [`repro_w2_asr.bend`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/repro_w2_asr.bend), [`repro_w5b_rol16.bend`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/repro_w5b_rol16.bend), [`repro_w5b_cmp_jcc.bend`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/repro_w5b_cmp_jcc.bend)
- **Machine-readable results:** [`results.json`](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12b_ff_match/results.json)

---

## 1. Exact Root Cause Discovered

1. **Bit-level `U32` expansion in `f_context_pattern` (`compiler.bend:12570`):**
   Every `U32` literal in a `match` pattern (e.g., `N111Const{2, 0}`, `N111Const{5, 0}`, `X187Imm{65535, 0}`) was eagerly expanded by `core_literal_step` into **66 nested constructors** (`1 U32 + 32 WCon + 32 True/False + 1 WNil`).
2. **Multiplicative wildcard/overlapping-row duplication in `ff_match` (`compiler.bend:15080–15282`):**
   - In `w2_asr_strip_self`, Row 4 matches `N111Const{2, 0}` on `left` (`64` reachable `Bool` bits + `68` 1-ctor `U32`/`WCon`/`WNil` splits) while Row 5 has `+x` (`Var`) on `left` and `N111Const{2, 0}` on `right`. At **every single one of the 64 `Bool` bits** of `left`, `ff_hit_done` duplicated `[Row 5, Row 6]` into `Miss`, creating **`64 × 64 = 4,096` reachable `Mat` nodes** (and `132 × 132 = 17,424` pre-`mat_rest` splits in `parse`), with `f_pattern_sub` rebuilding a 130-constructor `head` AST at every split.
   - In `p186ch_expand`, Rows 1–2 match `N111Const{5, 0}` (`32` bits) while Row 3 has `+kind` (`Var`) followed by `N111Const{0, 0}` (`64` bits), creating **`32 × 64 = 2,048` reachable `Mat` nodes** and repeatedly substituting a growing `stmt` into `case _: P114TExpansion{[stmt], False{}}`.
   - The compiler then spent ~15 s type-checking and annotating all `4,096` `Mat` nodes in `p86_plan`, and another ~11 s in `x198pw_plan` running `nw_walk`/`nw_covered` just to collapse the 32 bits **back into a single integer comparison**!

---

## 2. Rejected Prototype vs. Promoted Fix

### Prototype 1 (Rejected): `w12_has_var` / `w12_pat_sub2` + 1-ctor word `Efq` short-circuit
- Skipped dead `Miss` branches on 1-ctor word ADTs (`U32`, `F32`, `WCon`, `WNil`) and guarded `f_pattern_sub` with a read-only `w12_has_var` / `w12_has_var2` check.
- **Result:** Did **not** eliminate the `64 × 64 = 4,096` reachable `Bool`-bit `Mat` nodes in `check`/`annotate`/`x198pw_plan`; the extra `w12_has_var` traversal actually regressed `p86_plan` (`28,950 -> 34,135 ms` on `repro_p186ch`; `31,276 -> 34,283 ms` on `repro_w2_asr`). **Rejected and preserved in `results.json`.**

### Prototype 2 (Promoted): Direct `#U32` Literal Pattern Matching + O(1) Wildcard Skip
1. **`f_context_pattern` (`L12570`):** Keep `KLiteral{"U32", n}` as a 0-field pattern `Ctr("#U32", n, Nil{})` instead of expanding into 66 bit constructors.
2. **`ff_split` / `ff_hit_done` / `ff_miss_done` / `f_hit_rows` / `f_hit_row` / `f_var_rows` (`L15103–15282`):**
   - Match `#U32` by both tag and literal value `ix(p) == ix(c)`; emit `Mat("#U32", n, [hit, miss])`; substitute `KLiteral{"U32", n}` on `Hit`.
   - If a column mixes `#U32` literals with explicit `U32{word}` patterns, `w12_split_mixed` transparently expands `#U32` back to `core_literal_step` for 100% compatibility.
   - O(1) skip of `f_pattern_sub` when the pattern variable name is `"_"` (never bound in `env`).
3. **Typechecker, Annotator, Normalizer (`check_mat`, `ka_mat`, `norm_match`, `g_match`, `w7c_norm_max_term`, `norm_max_walk`):**
   - `check_mat` & `ka_mat`: verify domain is `U32` with empty `rm`, refine the `Hit` goal with `KLiteral{"U32", ix(t)}` (preserving full dependent type refinement and affine usage merging via `ki_pair`), and check `Miss` at the same `ty`.
   - `norm_match` & `g_match`: directly compare `U32` literals (and `Ctr("U32", [word])` via `w12_word_u32`).
   - `w7c_norm_max_term` & `norm_max_walk`: exclude `ix(t)` of `Mat("#U32", ...)` from binder-ID ceiling scans so wide literals like `4294967295` (`focused/u32-wide-wrap`) never exhaust fresh binder space.
4. **Native Lowering (`nc_erase_mat`, `jd_raise_domain`, `nw_applicable`, `w12_nw_walk_lit`, `p112m_body`):**
   - Preserve `Mat("#U32", n, ...)` through `nc_erase_mat` and feed directly into existing `nw_walk` / `p112m_plan_rows` (`p112`, `p113d`, `p113p`) with zero changes to `x187` codegen!

---

## 3. Measured Speedups on Unflattened Micro-Repros (CPU `6`, `-O2` `x86-object`)

| Unflattened Repro | Golden Out | `p86_plan` Base -> W12-B | `x198pw_plan` Base -> W12-B | `-O2` Wall Base -> W12-B | `.o` Bytes Base -> W12-B |
|---|---:|---:|---:|---:|---:|
| **`repro_p186ch`** | `35` | `28,950 -> 627 ms` (**`46.2x`**) | `9,402 -> 1,097 ms` (**`8.57x`**) | `42,009 -> 5,327 ms` (**`7.89x`**) | `225,840 -> 223,184 B` |
| **`repro_w2_asr`** | `5` | `31,276 -> 483 ms` (**`64.8x`**) | `11,744 -> 764 ms` (**`15.4x`**) | `45,968 -> 4,275 ms` (**`10.8x`**) | `115,168 -> 115,168 B` |
| **`repro_w5b_rol16`** | `102` | `1,238 -> 547 ms` (**`2.26x`**) | `1,065 -> 1,027 ms` (`1.04x`) | `9,943 -> 6,406 ms` (**`1.55x`**) | `187,080 -> 187,080 B` |
| **`repro_w5b_cmp_jcc`** | `102` | `1,530 -> 685 ms` (**`2.23x`**) | `1,547 -> 1,298 ms` (`1.19x`) | `30,940 -> 29,782 ms` (`1.04x`) | `346,536 -> 346,536 B` |

*(Note on `w5b_try_rol16` / `w5b_try_cmp_jcc` in `-O2` `x187_priv`: disassembly of `repro_w5b_rol16.o` and `repro_w5b_cmp_jcc.o` showed `25,587` and `51,569` x86-64 instructions driven by `O(d^2)` inline `term_drop` sequences emitted across ~55 nested ADT `Miss` branches in `p113d`; at `-O0` `x86-object-fast`, W12-B compiles them in `3,272 ms` and `4,175 ms` total.)*

---

## 4. Verification Gates (CPU `6`)

| Gate | Result | Evidence |
|---|---|---|
| **`--check-only`** | **PASS** | `0` type/linearity errors across `8,679` defs (standard `@unsafe` audit only) |
| **`64/64 native64` (`-O2` `x86-object`)** | **64/64 PASS** | `89.9 s` on CPU `6` (incl. `focused/u32-wide-wrap` with `4294967295`) |
| **`15/15` Live-Metadata Observer Gate** | **15/15 PASS (`0` violations)** | `44+2` ABI probes + 5 probes × 3 modes (`normal`, `cap-no8`, `all-hot`) |
| **Unflattened micro-repro execution** | **4/4 EXACT MATCH** | `35`, `5`, `102`, `102` (both `-O2` and `-O0`) |

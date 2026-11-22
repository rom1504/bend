# Wave 5B Verification Track W5B-V1 · Adversarial Differential Fuzzing & Lean 4 Formal Proofs

- **Date**: `2026-11-22`
- **Target**: `selfhost/build/agy/wave5a_unified/{compiler.bend,api.mjs}` + `selfhost/build/agy/unified/runtime-agy.o`
- **Verdict**: **PASS — `87/87` adversarial Wave 5 differential tests bit-exact (`0` wrong-code bugs, `0` crashes) + `28/28` machine-checked Lean 4 theorems (`exit 0`, `0` warnings, `0` `sorry`, standard axioms only)**

---

## 1. Wave 5A Adversarial Differential Fuzzer (`research/agy/wave5_audit/fuzz_wave5.py`)

All runs were pinned to CPUs `0,1,4,5` (`taskset -c 0,1,4,5`), with Node invoked via `bash research/agy/locked_node.sh` and temporary `.o`/`.exe` artifacts deleted immediately after execution.

| Family | Target Wave 5A Pass(es) & Edge Cases | Wave 5A vs Wave 2 Oracle | Cross-Check vs Upstream `bun bend2/main.ts` | Failures |
|---|---|---:|---:|---:|
| **`11_arity64_direct`** | Arity `33..64` direct-style (`33..64` scalar/F32/Bool params, tail-rec + non-tail nested calls, non-commutative stack-slot hash) | **`15 / 15` PASS** | **`15 / 15` PASS** | **`0`** |
| **`12_nat_succ_edge`** | Inline `P111_SPECIAL_SUCC` (`1n+j`): `0n`, `1n`, crossing `2^32`, nested `1n+(1n+(1n+x))`, thunked/closure `Nat`, branchy loops | **`15 / 15` PASS** | `9 / 9` non-timeout PASS | **`0`** |
| **`13_lcu_product`** | 1-level & 2-level Loop-Carried Product Unboxing (`w5_lcu_selected`): escaping `P113DResult`, mismatched ctor `fbSym` fallback, multi-`P113DAgain`, mixed `F32`/`U32` fields | **`12 / 12` valid PASS** | `1 / 1` non-timeout PASS | **`0`** |
| **`14_peel_cmov_sink`** | 2-step tiny self-rec peeling (`w5_expand_peel`: `0,1,2,3,4,100` iters), loop-counter sinking (`w5_sink_body`), 2/3-level `cmov` diamonds, exit-block rotation | **`15 / 15` PASS** | **`15 / 15` PASS** | **`0`** |
| **`15_bce_inv_min`** | `inv_base + min(x, inv_k)` BCE & `U32` wraparound torture (`0xFFFFFFFF+1`, `0x80000000+0x80000000`, `base>mask`, `k>mask`, `base+k>mask`, `<` and `<=`) | **`15 / 15` PASS** | **`15 / 15` PASS** | **`0`** |
| **`16_xmm_gpr_peep`** | `w5_xmm_fold`, `w5_gpr_peep`, `subq $1; testq`, high-param (>8) F32/GPR regalloc, IEEE-754 (`NaN`, `-0.0`, `+0.0`, subnormals, `±Inf`), Patricia-trie `p113k_join` & `X186FactTrie` CSE | **`15 / 15` PASS** | **`15 / 15` PASS** | **`0`** |
| **TOTAL (Wave 5 Adversarial)** | **6 adversarial families targeting all 7 Wave 5A pass groups** | **`87 / 87` PASS** | **`70 / 70` PASS** | **`0`** |

- **Receipts**:
  - [wave5-fuzz-report.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave5-fuzz-report.json)
  - [wave5-fuzz-f12.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave5-fuzz-f12.json)
  - [wave5-fuzz-f13.json](file:///home/ai/bend2_agy/experiments/agy/receipts/wave5-fuzz-f13.json)
- **Notes**:
  - 3 of the 15 generated cases in `13_lcu_product` (`mode == 2`, `ASt{arr: Array<U32>, ...}`) hit a Bend frontend typecheck error (`check: ASt: type mismatch` on both Wave 2 and Wave 5A), leaving `87/87` valid adversarial programs (`>80` target), all passing bit-exact with **0 wrong-code bugs and 0 crashes**.
  - A standalone 335-case cumulative Wave 3+4 driver was also prepared at [run_cumulative_335.py](file:///home/ai/bend2_agy/research/agy/wave5_audit/run_cumulative_335.py) for post-bundle integration sweeps.

---

## 2. Machine-Checked Lean 4 Formal Proofs (`research/agy/lean_laws/Wave5Laws.lean`)

- **Toolchain**: `Lean (version 4.32.0, x86_64-unknown-linux-gnu, commit 8c9756b28d64dab099da31a4c09229a9e6a2ef35, Release)` (`/home/ai/.elan/bin/lean`, core `Init` only, zero external deps)
- **Proof Artifact**: [Wave5Laws.lean](file:///home/ai/bend2_agy/research/agy/lean_laws/Wave5Laws.lean) (`519` lines, SHA-256 `5b6ac6d6a9fa0735d1a62d6e56bb77ae9de0b734361745acccbef27cd82fc078`)
- **Verification**: `/home/ai/.elan/bin/lean research/agy/lean_laws/Wave5Laws.lean` exited with code **`0`**, **`0` errors**, **`0` warnings**, **`0` `sorry`**, and **standard axioms only** (`propext`, `Quot.sound`, `Classical.choice`).
- **Cumulative Machine-Checked Laws**: `17` (`Wave2Laws.lean`) + `28` (`Wave4Laws.lean`) + **`28` (`Wave5Laws.lean`)** = **`73` theorems (0 `sorry`)**.

| # | Wave 5A Pass | Lean 4 Theorems (`Bend.Wave5Laws`) | Formal Property Verified |
|---|---|---|---|
| 1 | **W5-R4 Inline `P111_SPECIAL_SUCC`** (`w5_succ_expand`) | `w5_succ_imm_no_overflow`, `w5_succ_tag_nat_eq`, `w5_succ_heap_ptr_bails` | `x < NAT_IMM_MAX → (x + 1).toNat = x.toNat + 1 ∧ x + 1 ≤ NAT_IMM_MAX`; parameterized `tagNat s tag (x + 1) = tagNat s tag x + (1 <<< s)`; tagged heap pointers (`≥ 2^48`) fail the guard and bail to `p111_rt_special_ctor`. |
| 2 | **W5-R1 `inv_base + min(x, inv_k)` BCE** (`w4c_bce_analyze`) | `w5_u32Min_le_right`, `w5_bce_inv_min_guard_iff`, `w5_bce_inv_min_no_wrap`, `w5_bce_inv_min_le_mask`, `w5_bce_inv_min_lt_len`, `w5_bce_wrap_counterexample` | Overflow-free `UInt32` guard `k ≤ m ∧ b ≤ m - k ↔ b.toNat + k.toNat ≤ m.toNat` implies zero wraparound, `b + min x k ≤ m`, and `b + min x k < len` (`m < len`); includes explicit counterexample (`0x80000001 + 0x80000001 = 2 ≤ 10`) showing why the overflow guard is mandatory. |
| 3 | **W5-R1 / W5-R3 Multi-Level `cmov` Diamonds** (`w4c_dia_if`, `w4g_try_diamond`) | `w5_cmov_nested_2`, `w5_cmov_nested_2_else`, `w5_cmov_nested_3`, `w5_cmov_select_equiv` | 2-level (both then- and else-nested) and 3-level nested pure scalar diamonds are identical to sequential `cmov` register updates; canonical `P113DIf` select matches `cmov (c != 0)`. |
| 4 | **W5-R1 2-Step Loop Peeling** (`w5_expand_peel`) | `w5_peel2_zero`, `w5_peel2_one`, `w5_peel2_step`, `w5_peel2_total`, `w5_peel2_repeat` | `loopPeel2 step n s = loopIter step n s` for all `n : Nat` (base cases `n = 0, 1` and inductive step `n + 2`), plus `Nat.repeat` form. |
| 5 | **W5-R4 Loop-Carried Product Unboxing** (`w5_lcu_selected`) | `w5_lcu_take_ctor`, `w5_lcu_worker_equiv`, `w5_lcu_wrapper_equiv` | `take(ctor(f)) = f`; unboxed worker equals boxed loop on all `.ctor` inputs; entry wrapper with `tag(v) == C` guard + `fbSym` fallback preserves exact semantics on ALL inputs (matching and mismatched constructors). |
| 6 | **W5-R1 / W5-R2 `subq $1; testq` ZF & GPR Peepholes** (`w4c_peep_cfg`, `w5_gpr_peep`) | `w5_sub1_test_zf_u64`, `w5_sub1_test_zf_u32`, `w5_sub1_eq_zero_iff`, `w5_gpr_g8_xor1_cancel`, `w5_gpr_g4_subl_collapse` | `((x - 1) == 0) = (((x - 1) &&& (x - 1)) == 0)` on `UInt64` and `UInt32`; `x - 1 = 0 ↔ x = 1`; G8 `(x ^^^ 1) ^^^ 1 = x`; G4 non-commutative `subl` bounce collapse. |
| 7 | **W5-C2 Patricia-Trie `p113k_join` Pruning** (`apply_struct_fast.py`) | `w5_patricia_disjoint_of_prefix_ne`, `w5_patricia_bit_split_disjoint` | `(lh ^^^ rh) &&& (mask - 1) ≠ 0 → ∀ k, ¬(patriciaMatches k lh mask ∧ patriciaMatches k rh mask)` (O(1) disjoint-subtree pruning is 100% sound); left/right split-bit partition disjointness. |

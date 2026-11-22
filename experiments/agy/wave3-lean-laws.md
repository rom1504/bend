# Wave 3 Track Q2 · Lean 4 Machine-Checked Algebraic Soundness Laws

- **Status**: **PASS — All 5 transformation families (17 exported theorems) machine-checked with exit code `0`, zero warnings, zero `sorry`, and zero custom axioms**
- **Lean Toolchain**: `Lean (version 4.32.0, x86_64-unknown-linux-gnu, commit 8c9756b28d64dab099da31a4c09229a9e6a2ef35, Release)` (`/home/ai/.elan/bin/lean`, zero external dependencies — Lean core `Init` only)
- **Proof Artifact**: [`research/agy/wave3_lean/Wave2Laws.lean`](../../research/agy/wave3_lean/Wave2Laws.lean) (`414` lines, SHA-256 `d190d40b7c8a5b1f70b5db91ef327b0b1c581a7019f775cffd51e87075d364f7`)
- **Reproduce**:
  ```bash
  /home/ai/.elan/bin/lean research/agy/wave3_lean/Wave2Laws.lean
  ```

## Summary of Proven Laws

| # | Compiler Pass | Lean Theorem(s) | Formal Statement | Axioms (`#print axioms`) |
|---|---|---|---|---|
| 1 | **`AGY-001`** (`bf_linearize`) | `agy001_bf_linearize` (+ `bfLoop_acc_shift`, `bfLoop_add`) | For any pure `base : UInt32 → UInt32`, `step x : UInt32`, and `d ≤ 31`, `bf base step d x = bfLoop base step (2 ^ d) x 0`, where `bf (p+1) x = bf p x + bf p (x + (step <<< p))` and `bfLoop` accumulates `acc + base x` with `x := x + step`. | `[propext, Quot.sound]` |
| 2 | **`AGY-005b`** (`absorbing`) | `agy005b_absorbing_repeat`, `agy005b_absorbing_runFuel` (+ `runFuel_eq_repeat`) | For any state type `S`, pure `step : S → S`, and state `st : S`, `step st = st → Nat.repeat step n st = st` and `runFuel step n st = st` for all `n : Nat`. | `[propext]` |
| 3 | **`AGY-W2B-DEADARR`** | `agy_w2b_deadarr`, `agy_w2b_deadarr_distinct` (+ `visited_indices_distinct`, `deadArrLoop_inv`) | For power-of-2 array size `K = 2 ^ cls`, `n ≤ 2 ^ cls`, initial index `i0`, `seed`, `acc0`, and arbitrary `writeVal : Nat → UInt32 → UInt32`: all `n` indices `(i0 + k) % 2 ^ cls` (`k < n`) are pairwise distinct, every read sees `seed`, every write is dead, and `deadArrLoop (2 ^ cls) writeVal n i0 (fun _ => seed) acc0 = acc0 + UInt32.ofNat n * seed`. | `[propext, Quot.sound]` |
| 4 | **`W2D`** (`U32` intervals) | `w2d_mod_sound`, `w2d_and_sound`, `w2d_add_no_wrap`, `w2d_add_sound`, `w2d_lt_sound`, `w2d_le_sound`, `w2d_ne_sound` | For closed `UInt32` intervals `[lo, hi]` (`lo ≤ hi`): `x % m ∈ [0, m - 1]` (`0 < m`); `x &&& mask ∈ [0, mask]`; if `hi1 + hi2 ≤ UInt32.size - 1`, then `(x + y).toNat = x.toNat + y.toNat` (zero wraparound) and `x + y ∈ [lo1 + lo2, hi1 + hi2]`; `hi1 < lo2 → x < y ∧ x ≠ y`; `hi1 ≤ lo2 → x ≤ y`. | `[propext, Quot.sound]` |
| 5 | **`AGY-005a`** (`ctfe_as_nat` guard) | `agy005a_guard_iff`, `agy005a_add_no_wrap`, `agy005a_u32_guard_iff`, `agy005a_u32_add_no_wrap`, `agy005a_u32_succ_no_wrap` | For `n ≤ 4294967295`: `acc + n ≤ 4294967295 ↔ acc ≤ 4294967295 - n`, and under the guard `(UInt32.ofNat acc + UInt32.ofNat n).toNat = acc + n`. Also proves the `UInt32`-level guard `acc ≤ (4294967295 : UInt32) - n` and successor guard `acc < (4294967295 : UInt32)` prevent wraparound. | `[propext, Quot.sound]` / `[propext, Classical.choice, Quot.sound]` |

## Exact `#print axioms` Verification Output

Running `/home/ai/.elan/bin/lean research/agy/wave3_lean/Wave2Laws.lean` exited with code `0` and emitted zero errors, zero warnings, and the following axiom audit:

```text
'Bend.Wave2Laws.agy001_bf_linearize' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.agy005b_absorbing_repeat' depends on axioms: [propext]
'Bend.Wave2Laws.agy005b_absorbing_runFuel' depends on axioms: [propext]
'Bend.Wave2Laws.agy_w2b_deadarr' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.agy_w2b_deadarr_distinct' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_mod_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_and_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_add_no_wrap' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_add_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_lt_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_le_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.w2d_ne_sound' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.agy005a_guard_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'Bend.Wave2Laws.agy005a_add_no_wrap' depends on axioms: [propext, Quot.sound]
'Bend.Wave2Laws.agy005a_u32_guard_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'Bend.Wave2Laws.agy005a_u32_add_no_wrap' depends on axioms: [propext, Classical.choice, Quot.sound]
'Bend.Wave2Laws.agy005a_u32_succ_no_wrap' depends on axioms: [propext, Quot.sound]
```

## Notes on Proof Scope & Boundary Conditions

1. **Exact `d ≤ 31` boundary in `AGY-001`**: In the inductive step `d = p + 1 ≤ 31`, `p < 32`, which is the exact condition ensuring `UInt32` left-shift `step <<< UInt32.ofNat p` does not wrap the shift count mod 32 and equals `step * UInt32.ofNat (2 ^ p)`. For `d ≥ 32`, `bf_linearize.bend` falls back to `f$agy_orig`.
2. **Exact `n ≤ 2 ^ cls` boundary in `AGY-W2B-DEADARR`**: `deadArrLoop_inv` proves the invariant for any modulus `K > 0` and `n ≤ K`; `agy_w2b_deadarr` instantiates `K = 2 ^ cls` (always positive via `Nat.two_pow_pos`) and quantifies over an arbitrary pure `writeVal : Nat → UInt32 → UInt32`, establishing that every write is unobservable by subsequent iterations.
3. **Exact `ctfe_as_nat` guard in `AGY-005a`**: Both the `Nat`-level equivalence (`agy005a_guard_iff`, `agy005a_add_no_wrap`) and the exact `UInt32` operations emitted in `research/agy/big_wins/ctfe.bend` (`U32.is_le(acc, U32.sub(4294967295, n))` and `U32.is_lt(acc, 4294967295)`) are proved equivalent to zero-wraparound arithmetic.
4. **Relationship to compiler implementation**: These Lean 4 theorems formally verify the **high-level mathematical / algebraic soundness** of each rewrite rule and guard condition. End-to-end lowering and IR pattern-matching fidelity are verified separately by Track Q1's differential fuzzer and the `native45`/`native64`/`runtime10` qualification gates.

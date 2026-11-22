/-
  Wave4Laws.lean — Machine-checked Lean 4 algebraic soundness proofs for
  Wave 4 general compiler transformations in Bend (`selfhost/agy`).

  Theorems proved (zero `sorry`, zero warnings, standard axioms only):
    1. W4-4 Odd-Parity Progress (`x198o_progress_eval`):
       For all `a, b, x : UInt32`, if `a % 2 = 1` and `b % 2 = 1`, then
       `a * x + b ≠ x`, `a * x - b ≠ x`, and `(a * x) ^^^ b ≠ x`.
       Hence bijective / odd-parity LCG loops never hit a fixed point in `Z/2^32Z`.
    2. W4-4 Power-of-2 Multiply Strength Reduction (`x185_immediate`):
       For all `x k : UInt32` with `k < 32`, `x * (1 <<< k) = x <<< k`,
       plus `Nat`-indexed `k < 32` and `x * 0 = 0`, `x * 1 = x`, `x <<< 0 = x`.
    3. W4-6 Bitmask Bounds-Check Soundness:
       For all `x m len : UInt32`, `(x &&& m) ≤ m`, and for `m = (1 <<< k) - 1`
       (`k < 32`), `m < len → (x &&& m) < len`, and `(x &&& m).toNat = x.toNat % 2 ^ k.toNat`.
    4. W4-1 `Bool.to_u32` / `Bool.pick` Identities & W4-4 `U32.mod` `lea` Reconstruction:
       - `boolPick b 1 0 = boolToU32 b`, `boolPick b 0 1 = boolToU32 (!b) = boolToU32 b ^^^ 1`
       - Double-XOR cancellation: `boolToU32 b ^^^ 1 ^^^ 1 = boolToU32 b`
       - Branchless `bool01` multiply: `x * boolToU32 b = x &&& (0 - boolToU32 b)`
       - `lea` reconstruction: `q + q * 2 = 3 * q`, `q + q * 4 = 5 * q`, `q + q * 8 = 9 * q`
         (and shift forms `q + (q <<< 1) = 3 * q`, `q + (q <<< 2) = 5 * q`, `q + (q <<< 3) = 9 * q`).
-/

namespace Bend.Wave4Laws

/-! ## Shared `UInt32` Helpers -/

private theorem uint32_size_eq : UInt32.size = 4294967296 := rfl

private theorem uint32_toNat_lt (x : UInt32) : x.toNat < 4294967296 :=
  x.toBitVec.isLt

private theorem uint32_add_toNat (x y : UInt32) :
    (x + y).toNat = (x.toNat + y.toNat) % 4294967296 := rfl

private theorem uint32_sub_toNat (x y : UInt32) :
    (x - y).toNat = (x.toNat + (4294967296 - y.toNat)) % 4294967296 := by
  change (x.toBitVec - y.toBitVec).toNat = _
  rw [BitVec.toNat_sub, Nat.add_comm]
  rfl

private theorem uint32_mul_toNat (x y : UInt32) :
    (x * y).toNat = (x.toNat * y.toNat) % 4294967296 := rfl

private theorem uint32_mod_two_toNat (x : UInt32) :
    (x % 2).toNat = x.toNat % 2 := rfl

private theorem mod_two_of_mod_pow32 (n : Nat) :
    (n % 4294967296) % 2 = n % 2 := by
  have hdvd : 2 ∣ 4294967296 := ⟨2147483648, rfl⟩
  exact Nat.mod_mod_of_dvd n hdvd

/-! ## 1. W4-4 Odd-Parity Progress Theorem (`x198o_progress_eval`) -/

/-- Multiplying a `UInt32` by an odd constant preserves LSB parity (`mod 2`). -/
theorem w4_odd_mul_parity (a x : UInt32) (ha : a % 2 = 1) :
    (a * x).toNat % 2 = x.toNat % 2 := by
  have ha_nat : a.toNat % 2 = 1 := by
    have h := congrArg UInt32.toNat ha
    simpa [uint32_mod_two_toNat] using h
  rw [uint32_mul_toNat, mod_two_of_mod_pow32, Nat.mul_mod, ha_nat, Nat.one_mul, Nat.mod_mod]

/-- Adding an odd constant to a `UInt32` flips LSB parity (`mod 2`). -/
theorem w4_odd_add_flips_parity (y b : UInt32) (hb : b % 2 = 1) :
    (y + b).toNat % 2 ≠ y.toNat % 2 := by
  have hb_nat : b.toNat % 2 = 1 := by
    have h := congrArg UInt32.toNat hb
    simpa [uint32_mod_two_toNat] using h
  rw [uint32_add_toNat, mod_two_of_mod_pow32]
  omega

/-- Subtracting an odd constant from a `UInt32` flips LSB parity (`mod 2`). -/
theorem w4_odd_sub_flips_parity (y b : UInt32) (hb : b % 2 = 1) :
    (y - b).toNat % 2 ≠ y.toNat % 2 := by
  have hb_nat : b.toNat % 2 = 1 := by
    have h := congrArg UInt32.toNat hb
    simpa [uint32_mod_two_toNat] using h
  have hb_lt : b.toNat < 4294967296 := uint32_toNat_lt b
  rw [uint32_sub_toNat, mod_two_of_mod_pow32]
  omega

/-- XORing a `UInt32` with an odd constant flips LSB parity (`mod 2`). -/
theorem w4_odd_xor_flips_parity (y b : UInt32) (hb : b % 2 = 1) :
    (y ^^^ b).toNat % 2 ≠ y.toNat % 2 := by
  have hb_nat : b.toNat % 2 = 1 := by
    have h := congrArg UInt32.toNat hb
    simpa [uint32_mod_two_toNat] using h
  intro heq
  have htb : (y.toNat ^^^ b.toNat).testBit 0 = (y.toNat.testBit 0 ^^ b.toNat.testBit 0) :=
    Nat.testBit_xor y.toNat b.toNat 0
  have h0 : (y.toNat ^^^ b.toNat).testBit 0 = y.toNat.testBit 0 := by
    rw [Nat.testBit_zero, Nat.testBit_zero]
    exact congrArg (fun k => decide (k = 1)) heq
  rw [h0, Nat.testBit_zero, Nat.testBit_zero, hb_nat] at htb
  cases h : decide (y.toNat % 2 = 1) <;> simp [h] at htb

/-- **W4-4 Odd-Parity Progress Theorem (LCG `+`)**:
    For all `a, b, x : UInt32`, if `a % 2 = 1` and `b % 2 = 1`, then `a * x + b ≠ x`.
    Proves bijective LCG recurrences have zero fixed points in `Z/2^32Z`. -/
theorem w4_odd_parity_progress (a b x : UInt32) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    a * x + b ≠ x := by
  intro heq
  have h1 := w4_odd_add_flips_parity (a * x) b hb
  rw [w4_odd_mul_parity a x ha] at h1
  exact h1 (congrArg (fun v : UInt32 => v.toNat % 2) heq)

/-- **W4-4 Odd-Parity Progress Theorem (LCG `-`)**:
    For all `a, b, x : UInt32`, if `a % 2 = 1` and `b % 2 = 1`, then `a * x - b ≠ x`. -/
theorem w4_odd_parity_progress_sub (a b x : UInt32) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    a * x - b ≠ x := by
  intro heq
  have h1 := w4_odd_sub_flips_parity (a * x) b hb
  rw [w4_odd_mul_parity a x ha] at h1
  exact h1 (congrArg (fun v : UInt32 => v.toNat % 2) heq)

/-- **W4-4 Odd-Parity Progress Theorem (LCG `^^^`)**:
    For all `a, b, x : UInt32`, if `a % 2 = 1` and `b % 2 = 1`, then `(a * x) ^^^ b ≠ x`. -/
theorem w4_odd_parity_progress_xor (a b x : UInt32) (ha : a % 2 = 1) (hb : b % 2 = 1) :
    (a * x) ^^^ b ≠ x := by
  intro heq
  have h1 := w4_odd_xor_flips_parity (a * x) b hb
  rw [w4_odd_mul_parity a x ha] at h1
  exact h1 (congrArg (fun v : UInt32 => v.toNat % 2) heq)

/-! ## 2. W4-4 Power-of-2 Multiply Strength Reduction (`x185_immediate`) -/

/-- **W4-4 Power-of-2 Strength Reduction (`UInt32` shift amount)**:
    For all `x k : UInt32` with `k < 32`, `x * (1 <<< k) = x <<< k`. -/
theorem w4_mul_pow2_eq_shl (x k : UInt32) (hk : k < 32) :
    x * (1 <<< k) = x <<< k := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  have hk_lt : k.toNat < 32 := hk
  have hk_mod : k.toNat % 32 = k.toNat := Nat.mod_eq_of_lt hk_lt
  have hpow_lt : 2 ^ k.toNat < 2 ^ 32 := Nat.pow_lt_pow_right (by omega) hk_lt
  have hpow_mod : (2 ^ k.toNat) % 2 ^ 32 = 2 ^ k.toNat := Nat.mod_eq_of_lt hpow_lt
  simp [Nat.shiftLeft_eq, hk_mod, hpow_mod]

/-- **W4-4 Power-of-2 Strength Reduction (`Nat` shift amount)**:
    For all `x : UInt32` and `k : Nat` with `k < 32`,
    `x * (1 <<< UInt32.ofNat k) = x <<< UInt32.ofNat k`. -/
theorem w4_mul_pow2_nat_eq_shl (x : UInt32) (k : Nat) (hk : k < 32) :
    x * (1 <<< UInt32.ofNat k) = x <<< UInt32.ofNat k := by
  apply w4_mul_pow2_eq_shl x (UInt32.ofNat k)
  change (k % 4294967296) < 32
  rw [Nat.mod_eq_of_lt (by omega)]
  exact hk

/-- **W4-1/W4-4 Algebraic Multiply & Shift Identities**: -/
theorem w4_mul_zero (x : UInt32) : x * 0 = 0 := by simp
theorem w4_mul_one (x : UInt32) : x * 1 = x := UInt32.mul_one x
theorem w4_shl_zero (x : UInt32) : x <<< 0 = x := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  simp

/-! ## 3. W4-6 Bitmask Bounds-Check Soundness -/

/-- General bitmask upper bound: for any `x m : UInt32`, `x &&& m ≤ m`. -/
theorem w4_and_le_mask (x m : UInt32) : x &&& m ≤ m := by
  change (x.toNat &&& m.toNat) ≤ m.toNat
  exact Nat.and_le_right

/-- General bitmask bounds check: if `m < len`, then `x &&& m < len`. -/
theorem w4_and_lt_of_mask_lt (x m len : UInt32) (h : m < len) : x &&& m < len := by
  have h1 : (x &&& m).toNat ≤ m.toNat := w4_and_le_mask x m
  have h2 : m.toNat < len.toNat := h
  exact Nat.lt_of_le_of_lt h1 h2

/-- **W4-6 Bitmask Bounds-Check Soundness (`m = (1 <<< k) - 1`, `k < 32`)**:
    For `m = (1 <<< k) - 1` (`k < 32`), if `m < len`, then `(x &&& m) < len`
    for all `x : UInt32`. -/
theorem w4_bitmask_bounds_sound (x k len : UInt32) (_hk : k < 32)
    (h : ((1 : UInt32) <<< k) - 1 < len) :
    (x &&& (((1 : UInt32) <<< k) - 1)) < len :=
  w4_and_lt_of_mask_lt x (((1 : UInt32) <<< k) - 1) len h

/-- Exact value of the power-of-2 mask `((1 <<< k) - 1).toNat = 2 ^ k.toNat - 1`
    for `k < 32`. -/
theorem w4_bitmask_toNat (k : UInt32) (hk : k < 32) :
    (((1 : UInt32) <<< k) - 1).toNat = 2 ^ k.toNat - 1 := by
  have hk_lt : k.toNat < 32 := hk
  have hk_mod : k.toNat % 32 = k.toNat := Nat.mod_eq_of_lt hk_lt
  have hpow_pos : 1 ≤ 2 ^ k.toNat := Nat.one_le_two_pow
  have hpow_lt : 2 ^ k.toNat < 4294967296 := Nat.pow_lt_pow_right (by omega) hk_lt
  have hshl : ((1 : UInt32) <<< k).toNat = 2 ^ k.toNat := by
    change ((1 <<< (k.toNat % 32)) % 4294967296) = 2 ^ k.toNat
    rw [hk_mod, Nat.shiftLeft_eq, Nat.one_mul, Nat.mod_eq_of_lt hpow_lt]
  rw [uint32_sub_toNat, hshl]
  change (2 ^ k.toNat + (4294967296 - 1)) % 4294967296 = 2 ^ k.toNat - 1
  have hrew : 2 ^ k.toNat + (4294967296 - 1) = (2 ^ k.toNat - 1) + 4294967296 := by omega
  rw [hrew, Nat.add_mod_right, Nat.mod_eq_of_lt (by omega)]

/-- Masking with `(1 <<< k) - 1` (`k < 32`) computes `x.toNat % 2 ^ k.toNat`. -/
theorem w4_bitmask_eq_mod_pow2 (x k : UInt32) (hk : k < 32) :
    (x &&& (((1 : UInt32) <<< k) - 1)).toNat = x.toNat % 2 ^ k.toNat := by
  change (x.toNat &&& (((1 : UInt32) <<< k) - 1).toNat) = x.toNat % 2 ^ k.toNat
  rw [w4_bitmask_toNat k hk]
  exact Nat.and_two_pow_sub_one_eq_mod x.toNat k.toNat

/-! ## 4. W4-1 `Bool.to_u32` / `Bool.pick` Identities & W4-4 `U32.mod` `lea` Reconstruction -/

/-- Scalar `Bool.to_u32` as defined in Bend Base. -/
def boolToU32 (b : Bool) : UInt32 :=
  if b then 1 else 0

/-- `Bool.pick` as defined in Bend Base. -/
def boolPick {α : Type u} (b : Bool) (t f : α) : α :=
  if b then t else f

/-- **W4-1 `Bool.pick` → `Bool.to_u32` identity**: `Bool.pick(b, 1, 0) = Bool.to_u32(b)`. -/
theorem w4_bool_pick_1_0 (b : Bool) :
    boolPick b (1 : UInt32) 0 = boolToU32 b := by
  cases b <;> rfl

/-- **W4-1 Inverted `Bool.pick` → `Bool.to_u32` XOR 1 identity**:
    `Bool.pick(b, 0, 1) = Bool.to_u32(!b) = Bool.to_u32(b) ^^^ 1`. -/
theorem w4_bool_pick_0_1 (b : Bool) :
    boolPick b (0 : UInt32) 1 = boolToU32 b ^^^ 1 := by
  cases b <;> decide

/-- **W4-1 `Bool.to_u32` negation identity**: `Bool.to_u32(!b) = Bool.to_u32(b) ^^^ 1`. -/
theorem w4_bool_to_u32_not (b : Bool) :
    boolToU32 (!b) = boolToU32 b ^^^ 1 := by
  cases b <;> decide

/-- **W4-4 Double boolean negation cancellation**: `(Bool.to_u32(b) ^^^ 1) ^^^ 1 = Bool.to_u32(b)`. -/
theorem w4_bool_xor1_xor1 (b : Bool) :
    (boolToU32 b ^^^ 1) ^^^ 1 = boolToU32 b := by
  cases b <;> decide

/-- **W4-4 Branchless `bool01` multiply lowering**:
    `x * Bool.to_u32(b) = x &&& (0 - Bool.to_u32(b))`. -/
theorem w4_bool01_mul_branchless (x : UInt32) (b : Bool) :
    x * boolToU32 b = x &&& (0 - boolToU32 b) := by
  cases b <;> simp [boolToU32]

/-- **W4-4 `U32.mod` `lea` reconstruction (`d = 3`)**: `q + q * 2 = 3 * q` in `UInt32`. -/
theorem w4_lea_mul3 (q : UInt32) : q + q * 2 = 3 * q := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  change (q.toNat + (q.toNat * 2) % 4294967296) % 4294967296 = (3 * q.toNat) % 4294967296
  rw [Nat.add_mod_mod]
  congr 1
  omega

/-- **W4-4 `U32.mod` `lea` reconstruction (`d = 5`)**: `q + q * 4 = 5 * q` in `UInt32`. -/
theorem w4_lea_mul5 (q : UInt32) : q + q * 4 = 5 * q := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  change (q.toNat + (q.toNat * 4) % 4294967296) % 4294967296 = (5 * q.toNat) % 4294967296
  rw [Nat.add_mod_mod]
  congr 1
  omega

/-- **W4-4 `U32.mod` `lea` reconstruction (`d = 9`)**: `q + q * 8 = 9 * q` in `UInt32`. -/
theorem w4_lea_mul9 (q : UInt32) : q + q * 8 = 9 * q := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  change (q.toNat + (q.toNat * 8) % 4294967296) % 4294967296 = (9 * q.toNat) % 4294967296
  rw [Nat.add_mod_mod]
  congr 1
  omega

/-- **W4-4 `U32.mod` remainder reconstruction via `lea` (`d ∈ {3, 5, 9}`)**: -/
theorem w4_lea_rem3 (n q : UInt32) : n - (q + q * 2) = n - 3 * q := by rw [w4_lea_mul3]
theorem w4_lea_rem5 (n q : UInt32) : n - (q + q * 4) = n - 5 * q := by rw [w4_lea_mul5]
theorem w4_lea_rem9 (n q : UInt32) : n - (q + q * 8) = n - 9 * q := by rw [w4_lea_mul9]

/-! ## Axiom Audit -/

#print axioms w4_odd_mul_parity
#print axioms w4_odd_add_flips_parity
#print axioms w4_odd_sub_flips_parity
#print axioms w4_odd_xor_flips_parity
#print axioms w4_odd_parity_progress
#print axioms w4_odd_parity_progress_sub
#print axioms w4_odd_parity_progress_xor
#print axioms w4_mul_pow2_eq_shl
#print axioms w4_mul_pow2_nat_eq_shl
#print axioms w4_mul_zero
#print axioms w4_mul_one
#print axioms w4_shl_zero
#print axioms w4_and_le_mask
#print axioms w4_and_lt_of_mask_lt
#print axioms w4_bitmask_bounds_sound
#print axioms w4_bitmask_toNat
#print axioms w4_bitmask_eq_mod_pow2
#print axioms w4_bool_pick_1_0
#print axioms w4_bool_pick_0_1
#print axioms w4_bool_to_u32_not
#print axioms w4_bool_xor1_xor1
#print axioms w4_bool01_mul_branchless
#print axioms w4_lea_mul3
#print axioms w4_lea_mul5
#print axioms w4_lea_mul9
#print axioms w4_lea_rem3
#print axioms w4_lea_rem5
#print axioms w4_lea_rem9

end Bend.Wave4Laws

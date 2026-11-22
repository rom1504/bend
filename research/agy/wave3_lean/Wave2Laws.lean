/-
  Wave2Laws.lean — Machine-checked Lean 4 algebraic soundness proofs for
  Wave 1 + Wave 2 compiler transformations in Bend (`selfhost/agy`).

  Theorems proved (zero `sorry`, zero custom axioms):
    1. AGY-001 (`bf_linearize`): Binary-fork `UInt32` sum equals tail-recursive
       `bfLoop` over `2^d` steps for all `d ≤ 31`.
    2. AGY-005b (`absorbing`): Fixed-point state `step st = st` is invariant
       under arbitrary iteration (`Nat.repeat` and tail-recursive `runFuel`).
    3. AGY-W2B-DEADARR: On a power-of-2 array of size `K = 2^cls`, `n ≤ K`
       consecutive modular indices `(i0 + k) % K` are pairwise distinct, so
       every read observes `seed`, every write is dead, and the accumulated
       sum equals `acc0 + UInt32.ofNat n * seed`.
    4. W2D (`U32` interval arithmetic): Soundness of `%`, `&&&`, non-wrapping
       `+`, and disjoint interval comparisons (`<`, `≤`, `≠`).
    5. AGY-005a (`ctfe_as_nat` overflow guard): Equivalence of `acc + n ≤ 2^32 - 1`
       with `acc ≤ (2^32 - 1) - n` and zero wraparound of `UInt32` addition
       and successor under the guard.
-/

namespace Bend.Wave2Laws

/-! ## Shared `UInt32` Arithmetic Helpers -/

private theorem uint32_size_eq : UInt32.size = 4294967296 := rfl

private theorem uint32_toNat_ofNat (n : Nat) :
    (UInt32.ofNat n).toNat = n % 4294967296 := rfl

private theorem uint32_toNat_lt (x : UInt32) : x.toNat < 4294967296 :=
  x.toBitVec.isLt

private theorem uint32_shiftLeft_eq_mul_two_pow (step : UInt32) (p : Nat) (hp : p < 32) :
    step <<< UInt32.ofNat p = step * UInt32.ofNat (2 ^ p) := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  have hp_mod : p % 32 = p := Nat.mod_eq_of_lt hp
  have hp_size : p % 2 ^ 32 = p := Nat.mod_eq_of_lt (by omega)
  simp [Nat.shiftLeft_eq, hp_size, hp_mod, Nat.mul_mod]

private theorem uint32_mul_succ (a : UInt32) (n : Nat) :
    a * UInt32.ofNat (n + 1) = a + a * UInt32.ofNat n := by
  apply UInt32.eq_of_toBitVec_eq
  apply BitVec.eq_of_toNat_eq
  change (a.toNat * ((n + 1) % 4294967296)) % 4294967296 =
    (a.toNat + (a.toNat * (n % 4294967296)) % 4294967296) % 4294967296
  rw [Nat.mul_mod_mod, Nat.mul_mod_mod, Nat.add_mod_mod]
  rw [Nat.mul_succ, Nat.add_comm]

private theorem uint32_succ_mul (n : Nat) (a : UInt32) :
    UInt32.ofNat (n + 1) * a = a + UInt32.ofNat n * a := by
  rw [UInt32.mul_comm, uint32_mul_succ, UInt32.mul_comm]

/-! ## 1. `AGY-001` (`bf_linearize`) -/

/-- Binary-fork `UInt32` reduction of depth `d` with stride `step`. -/
def bf (base : UInt32 → UInt32) (step : UInt32) : Nat → UInt32 → UInt32
  | 0, x => base x
  | p + 1, x => bf base step p x + bf base step p (x + (step <<< UInt32.ofNat p))

/-- Linearized tail-recursive loop summing `n` consecutive `step`-strided `base` calls. -/
def bfLoop (base : UInt32 → UInt32) (step : UInt32) : Nat → UInt32 → UInt32 → UInt32
  | 0, _, acc => acc
  | n + 1, x, acc => bfLoop base step n (x + step) (acc + base x)

theorem bfLoop_acc_shift (base : UInt32 → UInt32) (step : UInt32)
    (n : Nat) (x acc : UInt32) :
    bfLoop base step n x acc = acc + bfLoop base step n x 0 := by
  induction n generalizing x acc with
  | zero =>
    simp [bfLoop]
  | succ n ih =>
    simp only [bfLoop]
    rw [ih (x + step) (acc + base x), ih (x + step) (0 + base x)]
    rw [UInt32.zero_add, UInt32.add_assoc]

theorem bfLoop_add (base : UInt32 → UInt32) (step : UInt32)
    (n m : Nat) (x acc : UInt32) :
    bfLoop base step (n + m) x acc =
      bfLoop base step m (x + step * UInt32.ofNat n) (bfLoop base step n x acc) := by
  induction n generalizing x acc with
  | zero =>
    simp [bfLoop]
  | succ n ih =>
    rw [Nat.succ_add]
    simp only [bfLoop]
    rw [ih (x + step) (acc + base x)]
    congr 1
    rw [uint32_mul_succ, UInt32.add_assoc]

/-- **`AGY-001` (`bf_linearize`) soundness**:
    For any pure `base : UInt32 → UInt32`, depth `d ≤ 31`, and `x step : UInt32`,
    the binary-fork sum `bf base step d x` equals `bfLoop base step (2 ^ d) x 0`. -/
theorem agy001_bf_linearize (base : UInt32 → UInt32) (step : UInt32)
    (d : Nat) (hd : d ≤ 31) (x : UInt32) :
    bf base step d x = bfLoop base step (2 ^ d) x 0 := by
  induction d generalizing x with
  | zero =>
    simp [bf, bfLoop]
  | succ p ih =>
    have hp_lt : p < 32 := by omega
    have hp_le : p ≤ 31 := by omega
    have hpow : 2 ^ (p + 1) = 2 ^ p + 2 ^ p := by omega
    rw [hpow, bfLoop_add, bfLoop_acc_shift]
    simp only [bf]
    rw [ih hp_le x]
    rw [uint32_shiftLeft_eq_mul_two_pow step p hp_lt]
    rw [ih hp_le (x + step * UInt32.ofNat (2 ^ p))]

/-! ## 2. `AGY-005b` (`absorbing`) -/

/-- Tail-recursive fuel-driven iteration matching Bend's fuel-loop lowering. -/
def runFuel {S : Type u} (step : S → S) : Nat → S → S
  | 0, st => st
  | n + 1, st => runFuel step n (step st)

/-- **`AGY-005b` (`absorbing`) soundness (`Nat.repeat`)**:
    If `step st = st`, then `Nat.repeat step n st = st` for all `n : Nat`. -/
theorem agy005b_absorbing_repeat {S : Type u} (step : S → S) (st : S)
    (h : step st = st) (n : Nat) :
    Nat.repeat step n st = st := by
  induction n with
  | zero => rfl
  | succ n ih => simp [Nat.repeat, ih, h]

/-- **`AGY-005b` (`absorbing`) soundness (`runFuel`)**:
    If `step st = st`, then `runFuel step n st = st` for all `n : Nat`. -/
theorem agy005b_absorbing_runFuel {S : Type u} (step : S → S) (st : S)
    (h : step st = st) (n : Nat) :
    runFuel step n st = st := by
  induction n with
  | zero => rfl
  | succ n ih => simp [runFuel, h, ih]

theorem runFuel_eq_repeat {S : Type u} (step : S → S) (n : Nat) (st : S) :
    runFuel step n st = Nat.repeat step n st := by
  induction n generalizing st with
  | zero => rfl
  | succ n ih =>
    rw [runFuel, ih (step st)]
    clear ih
    induction n with
    | zero => rfl
    | succ m ihm => simp [Nat.repeat, ihm]

/-! ## 3. `AGY-W2B-DEADARR` -/

/-- Functional array update at index `idx`. -/
def arrSet (arr : Nat → UInt32) (idx : Nat) (val : UInt32) : Nat → UInt32 :=
  fun j => if j = idx then val else arr j

/-- Modular stride-1 read-write-accumulate loop over an array of size `K`. -/
def deadArrLoop (K : Nat) (writeVal : Nat → UInt32 → UInt32) :
    Nat → Nat → (Nat → UInt32) → UInt32 → UInt32
  | 0, _, _, acc => acc
  | n + 1, i, arr, acc =>
    let idx := i % K
    let v := arr idx
    let arr' := arrSet arr idx (writeVal i v)
    deadArrLoop K writeVal n (i + 1) arr' (acc + v)

/-- Pairwise distinctness of `n ≤ K` consecutive modular indices `(i0 + k) % K`. -/
theorem visited_indices_distinct (K i0 n : Nat) (_hK : K > 0) (hn : n ≤ K)
    {k1 k2 : Nat} (hk1 : k1 < n) (hk2 : k2 < n)
    (heq : (i0 + k1) % K = (i0 + k2) % K) :
    k1 = k2 := by
  have h1 := Nat.div_add_mod (i0 + k1) K
  have h2 := Nat.div_add_mod (i0 + k2) K
  let q1 := (i0 + k1) / K
  let q2 := (i0 + k2) / K
  have h1' : K * q1 + (i0 + k1) % K = i0 + k1 := h1
  have h2' : K * q2 + (i0 + k2) % K = i0 + k2 := h2
  by_cases hle : q1 ≤ q2
  · have hmul_le : K * q1 ≤ K * q2 := Nat.mul_le_mul_left K hle
    have hdiff : k2 - k1 = K * (q2 - q1) := by
      have hsub : K * q2 - K * q1 = K * (q2 - q1) := (Nat.mul_sub_left_distrib K q2 q1).symm
      omega
    have hq_eq : q2 = q1 := by
      match h : q2 - q1 with
      | 0 => omega
      | d + 1 =>
        rw [h, Nat.mul_succ] at hdiff
        omega
    rw [hq_eq] at h2'
    omega
  · have hge : q2 ≤ q1 := by omega
    have hmul_le : K * q2 ≤ K * q1 := Nat.mul_le_mul_left K hge
    have hdiff : k1 - k2 = K * (q1 - q2) := by
      have hsub : K * q1 - K * q2 = K * (q1 - q2) := (Nat.mul_sub_left_distrib K q1 q2).symm
      omega
    have hq_eq : q1 = q2 := by
      match h : q1 - q2 with
      | 0 => omega
      | d + 1 =>
        rw [h, Nat.mul_succ] at hdiff
        omega
    rw [hq_eq] at h1'
    omega

theorem deadArrLoop_inv (K : Nat) (hK : K > 0) (writeVal : Nat → UInt32 → UInt32)
    (seed : UInt32) (n : Nat) (hn : n ≤ K) (i : Nat) (arr : Nat → UInt32) (acc : UInt32)
    (harr : ∀ k, k < n → arr ((i + k) % K) = seed) :
    deadArrLoop K writeVal n i arr acc = acc + UInt32.ofNat n * seed := by
  induction n generalizing i arr acc with
  | zero =>
    simp [deadArrLoop]
  | succ n ih =>
    simp only [deadArrLoop]
    have hv : arr (i % K) = seed := by
      simpa using harr 0 (by omega)
    rw [hv]
    have harr' : ∀ k, k < n →
        arrSet arr (i % K) (writeVal i seed) ((i + 1 + k) % K) = seed := by
      intro k hk
      have hne : (i + (k + 1)) % K ≠ (i + 0) % K := by
        intro heq
        have := visited_indices_distinct K i (n + 1) hK hn (by omega) (by omega) heq
        omega
      have hidx : (i + 1 + k) % K ≠ i % K := by
        simpa [Nat.add_assoc, Nat.add_comm 1 k] using hne
      simp only [arrSet, hidx, ↓reduceIte]
      have hprev := harr (k + 1) (by omega)
      simpa [Nat.add_assoc, Nat.add_comm 1 k] using hprev
    rw [ih (by omega) (i + 1) (arrSet arr (i % K) (writeVal i seed)) (acc + seed) harr']
    rw [UInt32.add_assoc, uint32_succ_mul]

/-- **`AGY-W2B-DEADARR` soundness**:
    For any power-of-2 array size `K = 2 ^ cls`, initial index `i0`, `seed`,
    `acc0`, count `n ≤ 2 ^ cls`, and arbitrary write function `writeVal`,
    all `n` visited indices are pairwise distinct, every read sees `seed`,
    every write is dead, and the accumulated sum equals `acc0 + UInt32.ofNat n * seed`. -/
theorem agy_w2b_deadarr (cls i0 n : Nat) (seed acc0 : UInt32)
    (writeVal : Nat → UInt32 → UInt32) (hn : n ≤ 2 ^ cls) :
    deadArrLoop (2 ^ cls) writeVal n i0 (fun _ => seed) acc0 =
      acc0 + UInt32.ofNat n * seed := by
  exact deadArrLoop_inv (2 ^ cls) (Nat.two_pow_pos cls) writeVal seed n hn i0
    (fun _ => seed) acc0 (fun _ _ => rfl)

/-- Power-of-2 specialization of index distinctness for `AGY-W2B-DEADARR`. -/
theorem agy_w2b_deadarr_distinct (cls i0 n : Nat) (hn : n ≤ 2 ^ cls)
    {k1 k2 : Nat} (hk1 : k1 < n) (hk2 : k2 < n)
    (heq : (i0 + k1) % (2 ^ cls) = (i0 + k2) % (2 ^ cls)) :
    k1 = k2 :=
  visited_indices_distinct (2 ^ cls) i0 n (Nat.two_pow_pos cls) hn hk1 hk2 heq

/-! ## 4. `W2D` (`U32` Interval Arithmetic Soundness) -/

/-- Closed unsigned 32-bit interval `[lo, hi]` with `lo ≤ hi`. -/
structure U32Interval where
  lo : UInt32
  hi : UInt32
  valid : lo ≤ hi

/-- Membership of `x : UInt32` in `[iv.lo, iv.hi]`. -/
def U32Interval.contains (iv : U32Interval) (x : UInt32) : Prop :=
  iv.lo ≤ x ∧ x ≤ iv.hi

/-- Remainder interval soundness: for `m > 0`, `x % m ∈ [0, m - 1]`. -/
theorem w2d_mod_sound (x m : UInt32) (hm : 0 < m) :
    (⟨0, m - 1, UInt32.zero_le⟩ : U32Interval).contains (x % m) := by
  refine ⟨UInt32.zero_le, ?_⟩
  have hm_pos : 0 < m.toNat := by
    simpa [UInt32.lt_iff_toNat_lt] using hm
  have h1 : (1 : UInt32).toNat = 1 := rfl
  rw [UInt32.le_iff_toNat_le, UInt32.toNat_mod, UInt32.toNat_sub_of_le]
  · have hlt := Nat.mod_lt x.toNat hm_pos
    omega
  · rw [UInt32.le_iff_toNat_le, h1]
    omega

/-- Bitwise-AND interval soundness: `x &&& mask ∈ [0, mask]`. -/
theorem w2d_and_sound (x mask : UInt32) :
    (⟨0, mask, UInt32.zero_le⟩ : U32Interval).contains (x &&& mask) := by
  refine ⟨UInt32.zero_le, ?_⟩
  rw [UInt32.le_iff_toNat_le, UInt32.toNat_and]
  exact Nat.and_le_right

/-- Non-wrapping addition soundness: if `iv1.hi.toNat + iv2.hi.toNat ≤ UInt32.size - 1`,
    then `x + y` has no wraparound and lies in `[iv1.lo + iv2.lo, iv1.hi + iv2.hi]`. -/
theorem w2d_add_no_wrap (iv1 iv2 : U32Interval) (x y : UInt32)
    (hx : iv1.contains x) (hy : iv2.contains y)
    (hnowrap : iv1.hi.toNat + iv2.hi.toNat ≤ UInt32.size - 1) :
    (x + y).toNat = x.toNat + y.toNat := by
  have hsize : UInt32.size = 4294967296 := rfl
  have hx_hi : x.toNat ≤ iv1.hi.toNat := UInt32.le_iff_toNat_le.mp hx.2
  have hy_hi : y.toNat ≤ iv2.hi.toNat := UInt32.le_iff_toNat_le.mp hy.2
  rw [UInt32.toNat_add]
  exact Nat.mod_eq_of_lt (by omega)

theorem w2d_add_interval_valid (iv1 iv2 : U32Interval)
    (hnowrap : iv1.hi.toNat + iv2.hi.toNat ≤ UInt32.size - 1) :
    iv1.lo + iv2.lo ≤ iv1.hi + iv2.hi := by
  have hsize : UInt32.size = 4294967296 := rfl
  have h1 : iv1.lo.toNat ≤ iv1.hi.toNat := UInt32.le_iff_toNat_le.mp iv1.valid
  have h2 : iv2.lo.toNat ≤ iv2.hi.toNat := UInt32.le_iff_toNat_le.mp iv2.valid
  rw [UInt32.le_iff_toNat_le, UInt32.toNat_add, UInt32.toNat_add]
  rw [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)]
  omega

theorem w2d_add_sound (iv1 iv2 : U32Interval) (x y : UInt32)
    (hx : iv1.contains x) (hy : iv2.contains y)
    (hnowrap : iv1.hi.toNat + iv2.hi.toNat ≤ UInt32.size - 1) :
    (⟨iv1.lo + iv2.lo, iv1.hi + iv2.hi, w2d_add_interval_valid iv1 iv2 hnowrap⟩ :
      U32Interval).contains (x + y) := by
  have hsize : UInt32.size = 4294967296 := rfl
  have hx_lo : iv1.lo.toNat ≤ x.toNat := UInt32.le_iff_toNat_le.mp hx.1
  have hx_hi : x.toNat ≤ iv1.hi.toNat := UInt32.le_iff_toNat_le.mp hx.2
  have hy_lo : iv2.lo.toNat ≤ y.toNat := UInt32.le_iff_toNat_le.mp hy.1
  have hy_hi : y.toNat ≤ iv2.hi.toNat := UInt32.le_iff_toNat_le.mp hy.2
  have hxy := w2d_add_no_wrap iv1 iv2 x y hx hy hnowrap
  constructor
  · rw [UInt32.le_iff_toNat_le, hxy, UInt32.toNat_add, Nat.mod_eq_of_lt (by omega)]
    omega
  · rw [UInt32.le_iff_toNat_le, hxy, UInt32.toNat_add, Nat.mod_eq_of_lt (by omega)]
    omega

/-- Disjoint interval strict comparison soundness: `iv1.hi < iv2.lo → x < y`. -/
theorem w2d_lt_sound (iv1 iv2 : U32Interval) (x y : UInt32)
    (hx : iv1.contains x) (hy : iv2.contains y) (hdisj : iv1.hi < iv2.lo) :
    x < y := by
  have hx_hi : x.toNat ≤ iv1.hi.toNat := UInt32.le_iff_toNat_le.mp hx.2
  have hy_lo : iv2.lo.toNat ≤ y.toNat := UInt32.le_iff_toNat_le.mp hy.1
  have hd : iv1.hi.toNat < iv2.lo.toNat := UInt32.lt_iff_toNat_lt.mp hdisj
  rw [UInt32.lt_iff_toNat_lt]
  omega

/-- Disjoint interval non-strict comparison soundness: `iv1.hi ≤ iv2.lo → x ≤ y`. -/
theorem w2d_le_sound (iv1 iv2 : U32Interval) (x y : UInt32)
    (hx : iv1.contains x) (hy : iv2.contains y) (hdisj : iv1.hi ≤ iv2.lo) :
    x ≤ y := by
  have hx_hi : x.toNat ≤ iv1.hi.toNat := UInt32.le_iff_toNat_le.mp hx.2
  have hy_lo : iv2.lo.toNat ≤ y.toNat := UInt32.le_iff_toNat_le.mp hy.1
  have hd : iv1.hi.toNat ≤ iv2.lo.toNat := UInt32.le_iff_toNat_le.mp hdisj
  rw [UInt32.le_iff_toNat_le]
  omega

/-- Disjoint interval disequality soundness: `iv1.hi < iv2.lo → x ≠ y`. -/
theorem w2d_ne_sound (iv1 iv2 : U32Interval) (x y : UInt32)
    (hx : iv1.contains x) (hy : iv2.contains y) (hdisj : iv1.hi < iv2.lo) :
    x ≠ y := by
  have hlt := UInt32.lt_iff_toNat_lt.mp (w2d_lt_sound iv1 iv2 x y hx hy hdisj)
  intro heq
  subst heq
  omega

/-! ## 5. `AGY-005a` (`ctfe_as_nat` Overflow Guard) -/

/-- Exact arithmetic equivalence of the `ctfe_as_nat` overflow guard in `Nat`. -/
theorem agy005a_guard_iff (acc n : Nat) (hn : n ≤ 4294967295) :
    acc + n ≤ 4294967295 ↔ acc ≤ 4294967295 - n := by
  omega

/-- Zero-wraparound soundness of `UInt32.ofNat acc + UInt32.ofNat n` under the
    `AGY-005a` overflow guard. -/
theorem agy005a_add_no_wrap (acc n : Nat) (hn : n ≤ 4294967295)
    (hguard : acc ≤ 4294967295 - n) :
    (UInt32.ofNat acc + UInt32.ofNat n).toNat = acc + n := by
  have hacc : acc < 4294967296 := by omega
  have hn' : n < 4294967296 := by omega
  have hsum : acc + n < 4294967296 := by omega
  rw [UInt32.toNat_add, uint32_toNat_ofNat, uint32_toNat_ofNat]
  change (acc % 4294967296 + n % 4294967296) % 4294967296 = acc + n
  rw [Nat.mod_eq_of_lt hacc, Nat.mod_eq_of_lt hn', Nat.mod_eq_of_lt hsum]

/-- `UInt32`-level equivalence of `U32.is_le(acc, U32.sub(4294967295, n))` and
    non-wrapping `acc + n`. -/
theorem agy005a_u32_guard_iff (acc n : UInt32) :
    acc.toNat + n.toNat ≤ 4294967295 ↔ acc ≤ (4294967295 : UInt32) - n := by
  have hn_lt : n.toNat < 4294967296 := uint32_toNat_lt n
  have hmax : (4294967295 : UInt32).toNat = 4294967295 := rfl
  rw [UInt32.le_iff_toNat_le, UInt32.toNat_sub_of_le]
  · rw [hmax]
    omega
  · rw [UInt32.le_iff_toNat_le, hmax]
    omega

theorem agy005a_u32_add_no_wrap (acc n : UInt32)
    (hguard : acc ≤ (4294967295 : UInt32) - n) :
    (acc + n).toNat = acc.toNat + n.toNat := by
  have hsum := (agy005a_u32_guard_iff acc n).mpr hguard
  rw [UInt32.toNat_add]
  exact Nat.mod_eq_of_lt (by omega)

/-- `ctfe_as_nat_succ` guard soundness: `acc < 4294967295` prevents successor wraparound. -/
theorem agy005a_u32_succ_no_wrap (acc : UInt32)
    (hguard : acc < (4294967295 : UInt32)) :
    (acc + 1).toNat = acc.toNat + 1 := by
  have hlt : acc.toNat < 4294967295 := by
    simpa [UInt32.lt_iff_toNat_lt] using hguard
  rw [UInt32.toNat_add]
  change (acc.toNat + 1) % 4294967296 = acc.toNat + 1
  exact Nat.mod_eq_of_lt (by omega)

/-! ## Axiom Verification (must print only standard Lean axioms, no `sorryAx`) -/

#print axioms agy001_bf_linearize
#print axioms agy005b_absorbing_repeat
#print axioms agy005b_absorbing_runFuel
#print axioms agy_w2b_deadarr
#print axioms agy_w2b_deadarr_distinct
#print axioms w2d_mod_sound
#print axioms w2d_and_sound
#print axioms w2d_add_no_wrap
#print axioms w2d_add_sound
#print axioms w2d_lt_sound
#print axioms w2d_le_sound
#print axioms w2d_ne_sound
#print axioms agy005a_guard_iff
#print axioms agy005a_add_no_wrap
#print axioms agy005a_u32_guard_iff
#print axioms agy005a_u32_add_no_wrap
#print axioms agy005a_u32_succ_no_wrap

end Bend.Wave2Laws

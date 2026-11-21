import Init.Data.BitVec.Lemmas

set_option maxHeartbeats 200000

namespace Bend.WordFusion

-- One distinguished recursive child and an arbitrary previously evaluated sibling.
-- The matcher and native worker are outside this arithmetic model.
inductive Context (w : Nat) where
  | leaf (value : BitVec w)
  | add (child : Context w) (sibling : BitVec w)
  | mul (child : Context w) (sibling : BitVec w)
  | subLeft (child : Context w) (sibling : BitVec w)
  | subRight (sibling : BitVec w) (child : Context w)

def value : Context w → BitVec w
  | .leaf x => x
  | .add x s => value x + s
  | .mul x s => value x * s
  | .subLeft x s => value x - s
  | .subRight s x => s - value x

def run : Context w → BitVec w → BitVec w → BitVec w
  | .leaf x, m, b => m * x + b
  | .add x s, m, b => run x m (b + m*s)
  | .mul x s, m, b => run x (m*s) b
  | .subLeft x s, m, b => run x m (b - m*s)
  | .subRight s x, m, b => run x (-m) (b + m*s)

-- Distribute once, then rewrite only the displayed associative/commutative
-- identities. There is no AC search or unrestricted commutativity simp set.
theorem run_value (x : Context w) (m b : BitVec w) :
    run x m b = m * value x + b := by
  induction x generalizing m b with
  | leaf x => rfl
  | add child sibling ih =>
    simp only [run, value, ih, BitVec.mul_add]
    rw [BitVec.add_comm b (m * sibling), BitVec.add_assoc]
  | mul child sibling ih =>
    simp only [run, value, ih]
    rw [BitVec.mul_assoc, BitVec.mul_comm sibling (value child)]
  | subLeft child sibling ih =>
    simp only [run, value, ih, BitVec.mul_sub, BitVec.sub_eq_add_neg]
    rw [BitVec.add_comm b (-(m * sibling)), BitVec.add_assoc]
  | subRight sibling child ih =>
    simp only [run, value, ih, BitVec.mul_sub, BitVec.sub_eq_add_neg, BitVec.neg_mul]
    rw [BitVec.add_comm b (m * sibling), ← BitVec.add_assoc,
      BitVec.add_comm (-(m * value child)) (m * sibling)]

theorem identity_entry (x : Context w) : run x 1 0 = value x := by
  simp only [run_value, BitVec.one_mul, BitVec.add_zero]

#print axioms run_value
#print axioms identity_entry

end Bend.WordFusion

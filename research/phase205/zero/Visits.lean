-- Append to research/phase200/text-laws/Sequence.lean in the reproduction command.
namespace Bend.TextSequence

-- Count invocations of the element mapper. Construction, append, and final
-- output traversal are outside this cost metric.
def countedMap (f : α → List β) : List α → List β × Nat
  | [] => ([], 0)
  | a :: xs =>
    let (ys, visits) := countedMap f xs
    (f a ++ ys, visits + 1)

theorem countedMap_spec (f : α → List β) (xs : List α) :
    countedMap f xs = (xs.flatMap f, xs.length) := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [countedMap, ih]

def guardMap (f : α → List β) (xs : List α) : Nat → List β × Nat
  | 0 => ([], 0)
  | n+1 =>
    let (ys, visits) := countedMap f xs
    (repeatSeq ys (n+1), visits)

theorem repeatSeq_length (xs : List α) (n : Nat) :
    (repeatSeq xs n).length = n * xs.length := by
  induction n with
  | zero => simp [repeatSeq]
  | succ n ih => simp [repeatSeq, ih, Nat.succ_mul, Nat.add_comm]

theorem guarded_value_and_visits (f : α → List β) (xs : List α) (n : Nat) :
    guardMap f xs n =
      ((countedMap f (repeatSeq xs n)).1, if n = 0 then 0 else xs.length) := by
  cases n with
  | zero => rfl
  | succ n => simp [guardMap, countedMap_spec, flatMap_repeat]

theorem original_visits (f : α → List β) (xs : List α) (n : Nat) :
    (countedMap f (repeatSeq xs n)).2 = n * xs.length := by
  simp [countedMap_spec, repeatSeq_length]

end Bend.TextSequence

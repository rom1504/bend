import Init.Data.List.Lemmas

set_option maxHeartbeats 200000

namespace Bend.TextSequence

-- Nonempty chunks: first chunk and remaining chunks. Empty chunks are retained.
abbrev Chunks (α : Type u) := List α × List (List α)

def push (a : α) (p : Chunks α) : Chunks α := (a :: p.1, p.2)
def cut (p : Chunks α) : Chunks α := ([], p.1 :: p.2)

def split [DecidableEq α] (d : α) : List α → Chunks α
  | [] => ([], [])
  | a :: xs => if a = d then cut (split d xs) else push a (split d xs)

def join (s : List α) (p : Chunks α) : List α :=
  p.1 ++ p.2.flatMap (fun chunk => s ++ chunk)

def replacement [DecidableEq α] (d : α) (s : List α) (a : α) : List α :=
  if a = d then s else [a]

theorem join_push (s : List α) (a : α) (p : Chunks α) :
    join s (push a p) = a :: join s p := by
  cases p
  rfl

theorem join_cut (s : List α) (p : Chunks α) :
    join s (cut p) = s ++ join s p := by
  cases p
  simp [join, cut, List.append_assoc]

-- Arbitrary element type; in particular arbitrary full-width U32 words.
-- No Unicode validity, nonempty replacement, or delimiter-free replacement premise.
theorem join_split [DecidableEq α] (d : α) (s xs : List α) :
    join s (split d xs) = xs.flatMap (replacement d s) := by
  induction xs with
  | nil => rfl
  | cons a xs ih =>
    by_cases h : a = d
    · simp [split, h, replacement, join_cut, ih]
    · simp [split, h, replacement, join_push, ih]

def repeatSeq (xs : List α) : Nat → List α
  | 0 => []
  | n + 1 => xs ++ repeatSeq xs n

theorem flatMap_repeat (f : α → List β) (xs : List α) (n : Nat) :
    (repeatSeq xs n).flatMap f = repeatSeq (xs.flatMap f) n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [repeatSeq, List.flatMap_append, ih]

theorem join_split_append [DecidableEq α] (d : α) (s xs ys : List α) :
    join s (split d (xs ++ ys)) = join s (split d xs) ++ join s (split d ys) := by
  simp only [join_split, List.flatMap_append]

theorem join_split_repeat [DecidableEq α] (d : α) (s xs : List α) (n : Nat) :
    join s (split d (repeatSeq xs n)) = repeatSeq (join s (split d xs)) n := by
  rw [join_split, flatMap_repeat, join_split]

#print axioms join_split
#print axioms join_split_append
#print axioms join_split_repeat

end Bend.TextSequence

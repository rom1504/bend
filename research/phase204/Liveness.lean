import Std.Tactic.BVDecide

namespace Phase204

/-- A liveness transfer after substituting the fixed statement operands and
    block-exit mask. The sole variable is the unknown loop-header mask. -/
inductive Transfer where
  | fixed (bits : BitVec 32)
  | header
  | join (left right : Transfer)
  | retain (bits : BitVec 32) (arg : Transfer)

def eval : Transfer → BitVec 32 → BitVec 32
  | .fixed b, _ => b
  | .header, h => h
  | .join a b, h => eval a h ||| eval b h
  | .retain mask e, h => mask &&& eval e h

def passthrough : Transfer → BitVec 32
  | .fixed _ => 0
  | .header => 0xffffffff
  | .join a b => passthrough a ||| passthrough b
  | .retain m e => m &&& passthrough e

theorem affine (e : Transfer) (h : BitVec 32) :
    eval e h = eval e 0 ||| (passthrough e &&& h) := by
  induction e with
  | fixed b => simp [eval, passthrough]
  | header => simp [eval, passthrough] <;> bv_decide
  | join a b ha hb =>
    simp only [eval, passthrough]
    rw [ha, hb]
    bv_decide
  | retain m e he =>
    simp only [eval, passthrough]
    rw [he]
    bv_decide

theorem one_pass (e : Transfer) : eval e (eval e 0) = eval e 0 := by
  rw [affine e (eval e 0)]
  bv_decide

end Phase204

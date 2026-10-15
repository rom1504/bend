import Base
import ./production.bend as P
import ./candidate.bend as H
import ./baseline.bend as B

# Support: exact D04 recursive body and the candidate recursive body coincide.
# They are imported separately so candidate-only changes cannot alter the oracle.
law held_walk_equal:
  for a: String
  for b: String
  for same: Bool
  {P.p88_string_eq_go(a, b, same) == H.p88_string_eq_go(a, b, same) : Bool}

def held_walk_equal(a, b, same):
  match a b same:
    case SNil{} SNil{} result: {==}
    case SNil{} SCon{head, tail} result: {==}
    case SCon{head, tail} SNil{} result: {==}
    case SCon{ah, at} SCon{bh, bt} False{}: {==}
    case SCon{ah, at} SCon{bh, bt} True{}:
      held_walk_equal(at, bt, Char.is_eq(ah, bh))

# Public replacement contract for every pair of arbitrary strings.
# This statement is byte-identical to held-exact.bend. The removed carrier
# observation has no counterpart; this module does not claim that result law.
law held_comparison_preserves:
  for +a: String
  for +b: String
  {P.p88_string_eq(a, b) == H.p88_string_eq(a, b) : Bool}

def held_comparison_preserves(a, b):
  held_walk_equal(a, b, True{})

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

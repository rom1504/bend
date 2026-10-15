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
    case SCon{Chr{av}, at} SCon{Chr{bv}, bt} True{}:
      held_walk_equal(at, bt, U32.is_eq(av, bv))

# Public full-value contract: both entire original strings survive unchanged,
# in their original positions, along with exact production comparator output.
law held_observation_complete:
  for +a: String
  for +b: String
  {H.P98EqHeld{P.p88_string_eq(a, b), a, b} == H.p98_eq_observe(a, b) : H.P98EqHeld}

def held_observation_complete(a, b):
  %held_walk_equal(a, b, True{}) : {H.P98EqHeld{P.p88_string_eq(a, b), a, b} == H.P98EqHeld{_, a, b} : H.P98EqHeld}
  {==}

# Public replacement contract for every pair of arbitrary strings.
law held_comparison_preserves:
  for +a: String
  for +b: String
  {P.p88_string_eq(a, b) == H.p88_string_eq(a, b) : Bool}

def held_comparison_preserves(a, b):
  %held_observation_complete(a, b) : {P.p88_string_eq(a, b) == H.p98_eq_finish(_) : Bool}
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

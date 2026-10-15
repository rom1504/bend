import Base
import ./production.bend as P
import ./candidate.bend as H
import ./baseline.bend as B

# Support: exact recursive bodies differ only in their private function names.
law held_walk_equal:
  for a: String
  for b: String
  for same: Bool
  {P.p88_string_eq_go(a, b, same) == H.p98_eq_walk(a, b, same) : Bool}

def held_walk_equal(a, b, same):
  match a b same:
    case SNil{} SNil{} result: {==}
    case SNil{} SCon{head, tail} result: {==}
    case SCon{head, tail} SNil{} result: {==}
    case SCon{ah, at} SCon{bh, bt} False{}: {==}
    case SCon{ah, at} SCon{bh, bt} True{}:
      held_walk_equal(at, bt, Char.is_eq(ah, bh))

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
  {P.p88_string_eq(a, b) == H.p98_string_eq(a, b) : Bool}

def held_comparison_preserves(a, b):
  %held_observation_complete(a, b) : {P.p88_string_eq(a, b) == H.p98_eq_finish(_) : Bool}
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

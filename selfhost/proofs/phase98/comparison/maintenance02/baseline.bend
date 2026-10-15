import Base
import ./production.bend as P
import ./reference.bend as R

# Supporting invariant includes the actual production loop's arbitrary pending
# comparison flag. A prior mismatch cannot become equal at the end of a string.
law consuming_equal_invariant:
  for a: String
  for b: String
  for same: Bool
  {P.p88_string_eq_go(a, b, same) == Bool.and(same, R.structural_equal(a, b)) : Bool}

def consuming_equal_invariant(a, b, same):
  match a b same:
    case SNil{} SNil{} False{}: {==}
    case SNil{} SNil{} True{}: {==}
    case SNil{} SCon{head, tail} False{}: {==}
    case SNil{} SCon{head, tail} True{}: {==}
    case SCon{head, tail} SNil{} False{}: {==}
    case SCon{head, tail} SNil{} True{}: {==}
    case SCon{ah, at} SCon{bh, bt} False{}: {==}
    case SCon{ah, at} SCon{bh, bt} True{}:
      consuming_equal_invariant(at, bt, Char.is_eq(ah, bh))

# Public production contract. Exact D04 helper bodies are extracted unchanged;
# no opaque comparator or unsafe callback is assumed by this theorem.
law consuming_equal_specification:
  for a: String
  for b: String
  {P.p88_string_eq(a, b) == R.structural_equal(a, b) : Bool}

def consuming_equal_specification(a, b):
  consuming_equal_invariant(a, b, True{})

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

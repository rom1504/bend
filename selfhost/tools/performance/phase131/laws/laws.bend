import Base
import ./production.bend as A
import ./reference.bend as R

law saturated_sequence_exact:
  for a: R.P131Count
  for b: R.P131Count
  {A.p131a_add(R.encode(a),R.encode(b)) == R.encode(R.sequence(a,b)) : U32}

def saturated_sequence_exact(a, b):
  match a b:
    case R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Zero{} R.P131Once{}: {==}
    case R.P131Zero{} R.P131Many{}: {==}
    case R.P131Once{} R.P131Zero{}: {==}
    case R.P131Once{} R.P131Once{}: {==}
    case R.P131Once{} R.P131Many{}: {==}
    case R.P131Many{} R.P131Zero{}: {==}
    case R.P131Many{} R.P131Once{}: {==}
    case R.P131Many{} R.P131Many{}: {==}

law lower_combination_exact:
  for kind: R.P131Mode
  for a: R.P131Count
  for b: R.P131Count
  {A.p131a_low(R.mode(kind),R.encode(a),R.encode(b)) == R.encode(R.low(kind,a,b)) : U32}

def lower_combination_exact(kind, a, b):
  match kind a b:
    case R.P131Sequence{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Many{}: {==}

law upper_combination_exact:
  for kind: R.P131Mode
  for a: R.P131Count
  for b: R.P131Count
  {A.p131a_high(R.mode(kind),R.encode(a),R.encode(b)) == R.encode(R.high(kind,a,b)) : U32}

def upper_combination_exact(kind, a, b):
  match kind a b:
    case R.P131Sequence{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Many{} R.P131Many{}: {==}

law saturated_sequence_associative:
  for a: R.P131Count
  for b: R.P131Count
  for c: R.P131Count
  {A.p131a_add(A.p131a_add(R.encode(a),R.encode(b)),R.encode(c)) == A.p131a_add(R.encode(a),A.p131a_add(R.encode(b),R.encode(c))) : U32}

def saturated_sequence_associative(a, b, c):
  match a b c:
    case R.P131Zero{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Zero{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Zero{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Zero{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Zero{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Zero{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Zero{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Zero{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Zero{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Once{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Once{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Once{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Once{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Once{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Once{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Once{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Once{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Once{} R.P131Many{} R.P131Many{}: {==}
    case R.P131Many{} R.P131Zero{} R.P131Zero{}: {==}
    case R.P131Many{} R.P131Zero{} R.P131Once{}: {==}
    case R.P131Many{} R.P131Zero{} R.P131Many{}: {==}
    case R.P131Many{} R.P131Once{} R.P131Zero{}: {==}
    case R.P131Many{} R.P131Once{} R.P131Once{}: {==}
    case R.P131Many{} R.P131Once{} R.P131Many{}: {==}
    case R.P131Many{} R.P131Many{} R.P131Zero{}: {==}
    case R.P131Many{} R.P131Many{} R.P131Once{}: {==}
    case R.P131Many{} R.P131Many{} R.P131Many{}: {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

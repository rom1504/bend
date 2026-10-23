import Base
import ./production.bend as A
import ./reference.bend as R

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

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

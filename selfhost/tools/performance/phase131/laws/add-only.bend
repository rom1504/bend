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

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

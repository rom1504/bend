import Base

# Public laws over the actual Base implementation, not a duplicate list model.
law append_right_identity:
  for -A: Data
  for xs: List<&2, A>
  {xs == List.append(&2, A, xs, Nil{}) : List<&2, A>}

def append_right_identity(A, xs):
  match xs:
    case Nil{}: {==}
    case head <> rest:
      %append_right_identity(A, rest) : {head <> rest == head <> _ : List<&2, A>}
      {==}

law append_associative:
  for -A: Data
  for xs: List<&2, A>
  for ys: List<&2, A>
  for zs: List<&2, A>
  {List.append(&2, A, List.append(&2, A, xs, ys), zs) == List.append(&2, A, xs, List.append(&2, A, ys, zs)) : List<&2, A>}

def append_associative(A, xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case head <> rest:
      %append_associative(A, rest, ys, zs) : {head <> List.append(&2, A, List.append(&2, A, rest, ys), zs) == head <> _ : List<&2, A>}
      {==}

law append_length:
  for -A: Data
  for xs: List<&2, A>
  for ys: List<&2, A>
  {List.length(&2, A, List.append(&2, A, xs, ys)) == Nat.add(List.length(&2, A, xs), List.length(&2, A, ys)) : Nat}

def append_length(A, xs, ys):
  match xs:
    case Nil{}: {==}
    case head <> rest:
      %append_length(A, rest, ys) : {1n+List.length(&2, A, List.append(&2, A, rest, ys)) == 1n+_ : Nat}
      {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

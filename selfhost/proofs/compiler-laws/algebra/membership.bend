import Base

# Supporting Boolean lemmas; these impose no assumptions on the comparator.
law or_associative:
  for a: Bool
  for b: Bool
  for c: Bool
  {Bool.or(a, Bool.or(b, c)) == Bool.or(Bool.or(a, b), c) : Bool}

def or_associative(a, b, c):
  match a:
    case False{}: {==}
    case True{}: {==}

law or_idempotent:
  for value: Bool
  {Bool.or(value, value) == value : Bool}

def or_idempotent(value):
  match value:
    case False{}: {==}
    case True{}: {==}

# Supporting Boolean lemma for the singleton semantic anchor.
law or_right_identity:
  for value: Bool
  {Bool.or(value, False{}) == value : Bool}

def or_right_identity(value):
  match value:
    case False{}: {==}
    case True{}: {==}

# Current Base defers the remaining scan behind List.any.if. Its Boolean
# result agrees with or; this lemma makes that change of definition explicit.
law or_matches_any_if:
  for rest: Unit -> Bool
  for hit: Bool
  {Bool.or(hit, rest(Unit{})) == List.any.if(rest, hit) : Bool}

def or_matches_any_if(rest, hit):
  match hit:
    case False{}: {==}
    case True{}: {==}

# Match the Boolean once so the singleton proof consumes its affine head once.
law any_if_empty_tail:
  for hit: Bool
  {List.any.if(u => False{}, hit) == hit : Bool}

def any_if_empty_tail(hit):
  match hit:
    case False{}: {==}
    case True{}: {==}

# Public semantic anchor: an always-False observer cannot satisfy this law for
# an arbitrary comparator. No reflexivity or equality axiom is assumed.
law contains_singleton:
  for ~A: Data
  for ~eq: A -> A -> Bool
  for head: A
  for +key: A
  {List.contains(~A, ~eq, Con{head, Nil{}}, key) == eq(head, key) : Bool}

def contains_singleton(A, eq, head, key):
  any_if_empty_tail(eq(head, key))

# Public: splitting a membership scan preserves the exact Boolean result.
law contains_append:
  for ~A: Data
  for ~eq: A -> A -> Bool
  for +xs: List<&2, A>
  for +ys: List<&2, A>
  for +key: A
  {List.contains(~A, ~eq, List.append(&2, A, xs, ys), key) == Bool.or(List.contains(~A, ~eq, xs, key), List.contains(~A, ~eq, ys, key)) : Bool}

def contains_append(A, eq, xs, ys, key):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %or_matches_any_if(u => List.contains(~A, ~eq, List.append(&2, A, rest, ys), key), eq(head, key)) : {_ == Bool.or(List.contains(~A, ~eq, head <> rest, key), List.contains(~A, ~eq, ys, key)) : Bool}
      %or_matches_any_if(u => List.contains(~A, ~eq, rest, key), eq(head, key)) : {Bool.or(eq(head, key), List.contains(~A, ~eq, List.append(&2, A, rest, ys), key)) == Bool.or(_, List.contains(~A, ~eq, ys, key)) : Bool}
      %or_associative(eq(head, key), List.contains(~A, ~eq, rest, key), List.contains(~A, ~eq, ys, key)) : {Bool.or(eq(head, key), List.contains(~A, ~eq, List.append(&2, A, rest, ys), key)) == _ : Bool}
      %contains_append(~A, ~eq, rest, ys, key) : {Bool.or(eq(head, key), List.contains(~A, ~eq, List.append(&2, A, rest, ys), key)) == Bool.or(eq(head, key), _) : Bool}
      {==}

# Public: duplicating the entire list changes no membership result. This does
# not license deduplicating an ordered compiler output or changing first-match.
law contains_duplicate:
  for ~A: Data
  for ~eq: A -> A -> Bool
  for +xs: List<&2, A>
  for +key: A
  {List.contains(~A, ~eq, List.append(&2, A, xs, xs), key) == List.contains(~A, ~eq, xs, key) : Bool}

def contains_duplicate(A, eq, xs, key):
  %or_idempotent(List.contains(~A, ~eq, xs, key)) : {List.contains(~A, ~eq, List.append(&2, A, xs, xs), key) == _ : Bool}
  contains_append(~A, ~eq, xs, xs, key)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

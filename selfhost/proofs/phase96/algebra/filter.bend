import Base

# Public semantic anchor: the actual predicate decides whether this head is
# retained, and the exact filtered tail is preserved. Always-empty filtering
# does not satisfy this equation for an arbitrary predicate.
law filter_cons_decision:
  for ~A: Data
  for ~keep: A -> Bool
  for +head: A
  for rest: List<&2, A>
  {List.filter(~A, ~keep, Con{head, rest}) == List.filter.put(A, head, List.filter(~A, ~keep, rest), keep(head)) : List<&2, A>}

def filter_cons_decision(A, keep, head, rest):
  {==}

# Supporting one-step lemma for actual Base filtering and concatenation.
law filter_put_append:
  for -A: Data
  for head: A
  for xs: List<&2, A>
  for ys: List<&2, A>
  for keep: Bool
  {List.filter.put(A, head, List.append(&2, A, xs, ys), keep) == List.append(&2, A, List.filter.put(A, head, xs, keep), ys) : List<&2, A>}

def filter_put_append(A, head, xs, ys, keep):
  match keep:
    case False{}: {==}
    case True{}: {==}

law filter_append:
  for ~A: Data
  for ~keep: A -> Bool
  for +xs: List<&2, A>
  for +ys: List<&2, A>
  {List.filter(~A, ~keep, List.append(&2, A, xs, ys)) == List.append(&2, A, List.filter(~A, ~keep, xs), List.filter(~A, ~keep, ys)) : List<&2, A>}

def filter_append(A, keep, xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %filter_put_append(A, head, List.filter(~A, ~keep, rest), List.filter(~A, ~keep, ys), keep(head)) : {List.filter(~A, ~keep, List.append(&2, A, head <> rest, ys)) == _ : List<&2, A>}
      %filter_append(~A, ~keep, rest, ys) : {List.filter.put(A, head, List.filter(~A, ~keep, List.append(&2, A, rest, ys)), keep(head)) == List.filter.put(A, head, _, keep(head)) : List<&2, A>}
      {==}

# Supporting lemma: the second filter sees the same predicate at a kept head.
# Explicit evidence connects a matched Bool parameter with the opaque predicate.
law filter_recheck:
  for ~A: Data
  for ~keep: A -> Bool
  for +head: A
  for +rest: List<&2, A>
  for live: Bool
  for eq: {live == keep(head) : Bool}
  {List.filter(~A, ~keep, List.filter.put(A, head, rest, live)) == List.filter.put(A, head, List.filter(~A, ~keep, rest), live) : List<&2, A>}

def filter_recheck(A, keep, head, rest, live, eq):
  match live:
    case False{}: {==}
    case True{}:
      %eq : {List.filter.put(A, head, List.filter(~A, ~keep, rest), _) == head <> List.filter(~A, ~keep, rest) : List<&2, A>}
      {==}

law filter_idempotent:
  for ~A: Data
  for ~keep: A -> Bool
  for +xs: List<&2, A>
  {List.filter(~A, ~keep, List.filter(~A, ~keep, xs)) == List.filter(~A, ~keep, xs) : List<&2, A>}

def filter_idempotent(A, keep, xs):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %filter_idempotent(~A, ~keep, rest) : {List.filter(~A, ~keep, List.filter.put(A, head, List.filter(~A, ~keep, rest), keep(head))) == List.filter.put(A, head, _, keep(head)) : List<&2, A>}
      filter_recheck(~A, ~keep, head, List.filter(~A, ~keep, rest), keep(head), {==})

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

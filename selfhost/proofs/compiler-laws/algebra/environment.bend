import Base
import ./phase94/helper.bend as H
import ./phase94/reference.bend as R

# The exact unpromoted Phase94 candidate helper is imported, byte-for-byte.
# No production adapter or liveness analysis is included in these claims.
law prefix_chunking:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for +state: S
  for xs: List<&2, A>
  for +ys: List<&2, A>
  for +more: H.NPE_Part<A, D>
  {H.npe_prefix(~A, ~S, ~D, ~hit, state, List.append(&2, A, xs, ys), more) == H.npe_prefix(~A, ~S, ~D, ~hit, state, xs, H.npe_prefix(~A, ~S, ~D, ~hit, state, ys, more)) : H.NPE_Part<A, D>}

def prefix_chunking(A, S, D, hit, state, xs, ys, more):
  match xs:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %prefix_chunking(~A, ~S, ~D, ~hit, state, rest, ys, more) : {H.npe_prefix_step(A, D, head, hit(state, head), H.npe_prefix(~A, ~S, ~D, ~hit, state, List.append(&2, A, rest, ys), more)) == H.npe_prefix_step(A, D, head, hit(state, head), _) : H.NPE_Part<A, D>}
      {==}

# Supporting constructor/Bool lemma. The complete accumulator remains visible.
law prefix_step_order:
  for -A: Data
  for -D: Data
  for head: A
  for rows: List<&2, A>
  for tail: List<&2, A>
  for out: D
  for live: Bool
  {H.NPE_Part{List.append(&2, A, R.npe_ref_filter_step(A, head, rows, live), tail), out} == H.npe_prefix_step(A, D, head, live, H.NPE_Part{List.append(&2, A, rows, tail), out}) : H.NPE_Part<A, D>}

def prefix_step_order(A, D, head, rows, tail, out, live):
  match live:
    case False{}: {==}
    case True{}: {==}

# Public: retained prefix order and the entire arbitrary drop accumulator are
# preserved together, with no uniqueness, commutativity or predicate axiom.
law prefix_order_and_drop:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for +state: S
  for rows: List<&2, A>
  for +tail: List<&2, A>
  for +out: D
  {H.NPE_Part{List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, rows), tail), out} == H.npe_prefix(~A, ~S, ~D, ~hit, state, rows, H.NPE_Part{tail, out}) : H.NPE_Part<A, D>}

def prefix_order_and_drop(A, S, D, hit, state, rows, tail, out):
  match rows:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %prefix_order_and_drop(~A, ~S, ~D, ~hit, state, rest, tail, out) : {H.NPE_Part{List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, head <> rest), tail), out} == H.npe_prefix_step(A, D, head, hit(state, head), _) : H.NPE_Part<A, D>}
      prefix_step_order(A, D, head, R.npe_ref_filter(~A, ~S, ~hit, state, rest), tail, out, hit(state, head))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

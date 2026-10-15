import Base
import ./helper.bend as H
import ./reference.bend as R

# Expose the accumulator constructor: two independently defined functions that
# match a neutral accumulator need an extensional equality, not reflexivity.
law npe_kept_step_contract:
  for ~A: Data
  for ~D: Data
  for ~drop: A -> D -> D
  for head: A
  for more: H.NPE_Part<A, D>
  {R.npe_ref_partition_step(~A, ~D, ~drop, head, True{}, more) == H.npe_prefix_step(A, D, head, True{}, more) : H.NPE_Part<A, D>}

def npe_kept_step_contract(A, D, drop, head, more):
  match more:
    case H.NPE_Part{rows, out}: {==}

# A Boolean decision is an explicit parameter because Bend does not mint
# equality evidence when matching an arbitrary computed expression.
law npe_prefix_step_contract:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for ~drop: A -> D -> D
  for +state: S
  for +head: A
  for +rows: List<&2, A>
  for +tail: List<&2, A>
  for +zero: D
  for live: Bool
  for eq: {live == hit(state, head) : Bool}
  {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, R.npe_ref_filter_step(A, head, rows, live), tail), zero) == H.npe_prefix_step(A, D, head, live, R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, rows, tail), zero)) : H.NPE_Part<A, D>}

def npe_prefix_step_contract(A, S, D, hit, drop, state, head, rows, tail, zero, live, eq):
  match live:
    case False{}: {==}
    case True{}:
      %eq : {R.npe_ref_partition_step(~A, ~D, ~drop, head, _, R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, rows, tail), zero)) == H.npe_prefix_step(A, D, head, True{}, R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, rows, tail), zero)) : H.NPE_Part<A, D>}
      npe_kept_step_contract(~A, ~D, ~drop, head, R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, rows, tail), zero))

# General fusion theorem: all retained prefix rows preserve order, and an
# arbitrary suffix's complete drop accumulator is preserved exactly. No laws
# about the drop combiner, membership predicate, row IDs or zero are assumed.
law npe_prefix_contract:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for ~drop: A -> D -> D
  for +state: S
  for rows: List<&2, A>
  for +tail: List<&2, A>
  for +zero: D
  {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, rows), tail), zero) == H.npe_prefix(~A, ~S, ~D, ~hit, state, rows, R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, tail, zero)) : H.NPE_Part<A, D>}

def npe_prefix_contract(A, S, D, hit, drop, state, rows, tail, zero):
  match rows:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %npe_prefix_contract(~A, ~S, ~D, ~hit, ~drop, state, rest, tail, zero) : {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, Con{head, rest}), tail), zero) == H.npe_prefix_step(A, D, head, hit(state, head), _) : H.NPE_Part<A, D>}
      npe_prefix_step_contract(~A, ~S, ~D, ~hit, ~drop, state, head, R.npe_ref_filter(~A, ~S, ~hit, state, rest), tail, zero, hit(state, head), {==})

# The independent reference and candidate singleton branches also require an
# explicit Boolean case split when the membership decision is neutral.
law npe_single_step_contract:
  for ~A: Data
  for ~D: Data
  for ~drop: A -> D -> D
  for binding: A
  for live: Bool
  for zero: D
  {R.npe_ref_partition_step(~A, ~D, ~drop, binding, live, H.NPE_Part{Nil{}, zero}) == H.npe_single_step(~A, ~D, ~drop, binding, live, zero) : H.NPE_Part<A, D>}

def npe_single_step_contract(A, D, drop, binding, live, zero):
  match live:
    case False{}: {==}
    case True{}: {==}

law npe_single_contract:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for ~drop: A -> D -> D
  for state: S
  for +binding: A
  for zero: D
  {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, Con{binding, Nil{}}, zero) == H.npe_single(~A, ~S, ~D, ~hit, ~drop, state, binding, zero) : H.NPE_Part<A, D>}

def npe_single_contract(A, S, D, hit, drop, state, binding, zero):
  npe_single_step_contract(~A, ~D, ~drop, binding, hit(state, binding), zero)

# The production call's contract is the arbitrary-suffix theorem instantiated
# at the singleton new binding. Its membership is evaluated once by the helper.
law npe_extend_contract:
  for ~A: Data
  for ~S: Data
  for ~D: Data
  for ~hit: S -> A -> Bool
  for ~drop: A -> D -> D
  for +state: S
  for rows: List<&2, A>
  for +binding: A
  for +zero: D
  {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, rows), Con{binding, Nil{}}), zero) == H.npe_extend(~A, ~S, ~D, ~hit, ~drop, state, rows, binding, zero) : H.NPE_Part<A, D>}

def npe_extend_contract(A, S, D, hit, drop, state, rows, binding, zero):
  %npe_single_contract(~A, ~S, ~D, ~hit, ~drop, state, binding, zero) : {R.npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, List.append(&2, A, R.npe_ref_filter(~A, ~S, ~hit, state, rows), Con{binding, Nil{}}), zero) == H.npe_prefix(~A, ~S, ~D, ~hit, state, rows, _) : H.NPE_Part<A, D>}
  npe_prefix_contract(~A, ~S, ~D, ~hit, ~drop, state, rows, Con{binding, Nil{}}, zero)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

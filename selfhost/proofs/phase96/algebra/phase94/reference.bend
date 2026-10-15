import Base
import ./helper.bend as H

# Reference specification. Keep this file frozen once its first check passes.
# This deliberately constructs the filtered list and partitions it separately.
def npe_ref_filter_step(-A: Data, head: A, rest: List<&2, A>, live: Bool) -> List<&2, A>:
  match live:
    case False{}: rest
    case True{}: Con{head, rest}

def npe_ref_filter(~A: Data, ~S: Data, ~hit: S -> A -> Bool, +state: S, rows: List<&2, A>) -> List<&2, A>:
  match rows:
    case Nil{}: Nil{}
    case Con{+head, rest}:
      npe_ref_filter_step(A, head, npe_ref_filter(~A, ~S, ~hit, state, rest), hit(state, head))

def npe_ref_partition_step(~A: Data, ~D: Data, ~drop: A -> D -> D, head: A, live: Bool, more: H.NPE_Part<A, D>) -> H.NPE_Part<A, D>:
  match live:
    case False{}:
      match more:
        case H.NPE_Part{rows, out}: H.NPE_Part{rows, drop(head, out)}
    case True{}:
      match more:
        case H.NPE_Part{rows, out}: H.NPE_Part{Con{head, rows}, out}

def npe_ref_partition(~A: Data, ~S: Data, ~D: Data, ~hit: S -> A -> Bool, ~drop: A -> D -> D, +state: S, rows: List<&2, A>, zero: D) -> H.NPE_Part<A, D>:
  match rows:
    case Nil{}: H.NPE_Part{Nil{}, zero}
    case Con{+head, rest}:
      npe_ref_partition_step(~A, ~D, ~drop, head, hit(state, head), npe_ref_partition(~A, ~S, ~D, ~hit, ~drop, state, rest, zero))

import Base

# Production candidate: keep the ordered live prefix, then extend it with one
# binding. Membership is computed once per input row. The drop accumulator is
# arbitrary Data; the helper neither interprets nor reorders its contents.
type NPE_Part<-A: Data, -D: Data> is Data:
  NPE_Part{live: List<&2, A>, drop: D}

def npe_prefix_step(-A: Data, -D: Data, head: A, live: Bool, more: NPE_Part<A, D>) -> NPE_Part<A, D>:
  match live:
    case False{}: more
    case True{}:
      match more:
        case NPE_Part{rows, drop}: NPE_Part{Con{head, rows}, drop}

def npe_prefix(~A: Data, ~S: Data, ~D: Data, ~hit: S -> A -> Bool, +state: S, rows: List<&2, A>, more: NPE_Part<A, D>) -> NPE_Part<A, D>:
  match rows:
    case Nil{}: more
    case Con{+head, rest}:
      npe_prefix_step(A, D, head, hit(state, head), npe_prefix(~A, ~S, ~D, ~hit, state, rest, more))

def npe_single_step(~A: Data, ~D: Data, ~drop: A -> D -> D, binding: A, live: Bool, zero: D) -> NPE_Part<A, D>:
  match live:
    case True{}: NPE_Part{Con{binding, Nil{}}, zero}
    case False{}: NPE_Part{Nil{}, drop(binding, zero)}

def npe_single(~A: Data, ~S: Data, ~D: Data, ~hit: S -> A -> Bool, ~drop: A -> D -> D, state: S, +binding: A, zero: D) -> NPE_Part<A, D>:
  npe_single_step(~A, ~D, ~drop, binding, hit(state, binding), zero)

def npe_extend(~A: Data, ~S: Data, ~D: Data, ~hit: S -> A -> Bool, ~drop: A -> D -> D, +state: S, rows: List<&2, A>, binding: A, zero: D) -> NPE_Part<A, D>:
  npe_prefix(~A, ~S, ~D, ~hit, state, rows, npe_single(~A, ~S, ~D, ~hit, ~drop, state, binding, zero))

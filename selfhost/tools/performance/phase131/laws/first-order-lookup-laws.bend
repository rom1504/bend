import Base
import ./absent-production.bend as A
import ./lookup-production-v02.bend as L
import ./lookup-first-order-v02.bend as F

law maximum_loop_exact:
  for +entries: List<&2,A.P131UEntry>
  for +id: U32
  for +order: Cmp
  for +value: U32
  {F.p131u_max_loop(entries,id,order,value) == L.p131u_choose(value,u => L.p131u_max(entries,id),order) : U32}

def maximum_loop_exact(entries,id,order,value):
  match entries order:
    case Nil{} LT{}: {==}
    case Nil{} EQ{}: {==}
    case Nil{} GT{}: {==}
    case Con{A.P131UEntry{key,low,high},rest} LT{}:
      maximum_loop_exact(rest,id,U32.cmp(key,id),high)
    case Con{A.P131UEntry{key,low,high},rest} EQ{}: {==}
    case Con{A.P131UEntry{key,low,high},rest} GT{}: {==}

law maximum_exact:
  for +entries: List<&2,A.P131UEntry>
  for +id: U32
  {F.p131u_max(entries,id) == L.p131u_max(entries,id) : U32}

def maximum_exact(entries,id):
  maximum_loop_exact(entries,id,LT{},0)

law minimum_loop_exact:
  for +entries: List<&2,A.P131UEntry>
  for +id: U32
  for +order: Cmp
  for +value: U32
  {F.p131u_min_loop(entries,id,order,value) == L.p131u_choose(value,u => L.p131u_min(entries,id),order) : U32}

def minimum_loop_exact(entries,id,order,value):
  match entries order:
    case Nil{} LT{}: {==}
    case Nil{} EQ{}: {==}
    case Nil{} GT{}: {==}
    case Con{A.P131UEntry{key,low,high},rest} LT{}:
      minimum_loop_exact(rest,id,U32.cmp(key,id),low)
    case Con{A.P131UEntry{key,low,high},rest} EQ{}: {==}
    case Con{A.P131UEntry{key,low,high},rest} GT{}: {==}

law minimum_exact:
  for +entries: List<&2,A.P131UEntry>
  for +id: U32
  {F.p131u_min(entries,id) == L.p131u_min(entries,id) : U32}

def minimum_exact(entries,id):
  minimum_loop_exact(entries,id,LT{},0)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

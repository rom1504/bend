import Base
import ./absent-production.bend as A
import ./lookup-production-v02.bend as L

law choose_zero:
  for order: Cmp
  {L.p131u_choose(0,u => 0,order) == 0 : U32}

def choose_zero(order):
  match order:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: {==}

# The claim holds for every list, including unsorted lists and duplicate keys.
# No comparison oracle or sorting assumption is imported.
law missing_branch_maximum:
  for entries: List<&2,A.P131UEntry>
  for +id: U32
  {L.p131u_max(A.p131u_absent(entries,1),id) == L.p131u_max(entries,id) : U32}

def missing_branch_maximum(entries,id):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{+key,low,+high},+rest}:
      %missing_branch_maximum(rest,id) : {L.p131u_choose(high,u => L.p131u_max(A.p131u_absent(rest,1),id),U32.cmp(key,id)) == L.p131u_choose(high,u => _,U32.cmp(key,id)) : U32}
      {==}

law missing_branch_minimum:
  for entries: List<&2,A.P131UEntry>
  for +id: U32
  {L.p131u_min(A.p131u_absent(entries,1),id) == 0 : U32}

def missing_branch_minimum(entries,id):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{+key,low,high},+rest}:
      %choose_zero(U32.cmp(key,id)) : {L.p131u_choose(0,u => L.p131u_min(A.p131u_absent(rest,1),id),U32.cmp(key,id)) == _ : U32}
      %missing_branch_minimum(rest,id) : {L.p131u_choose(0,u => L.p131u_min(A.p131u_absent(rest,1),id),U32.cmp(key,id)) == L.p131u_choose(0,u => _,U32.cmp(key,id)) : U32}
      {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

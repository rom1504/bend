import Base
import ./production.bend as P
import ./absent-production.bend as A

def p131u_merge_choose(less: Unit -> List<&2,A.P131UEntry>, equal: Unit -> List<&2,A.P131UEntry>, greater: Unit -> List<&2,A.P131UEntry>, order: Cmp) -> List<&2,A.P131UEntry>:
  match order:
    case LT{}: less(Unit{})
    case EQ{}: equal(Unit{})
    case GT{}: greater(Unit{})

# No fuel, no runtime proof argument; recursion decreases one input list.
def p131u_merge(+left: List<&2,A.P131UEntry>, +right: List<&2,A.P131UEntry>, +mode: U32) -> List<&2,A.P131UEntry>:
  match left right:
    case Nil{} values: A.p131u_absent(values,mode)
    case values Nil{}: A.p131u_absent(values,mode)
    case Con{A.P131UEntry{+li,+ll,+lh},+lr} Con{A.P131UEntry{+ri,+rl,+rh},+rr}:
      p131u_merge_choose(
        u => Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},p131u_merge(lr,right,mode)},
        u => Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},p131u_merge(lr,rr,mode)},
        u => Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},p131u_merge(left,rr,mode)},
        U32.cmp(li,ri))

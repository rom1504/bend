import Base
import ./production.bend as P
import ./absent-production.bend as A

# The current heads stay scalar; only the two tails participate in structural
# descent. Pending comparison is explicit state, never a runtime callback.
def p131u_merge_loop(+left: List<&2,A.P131UEntry>, +right: List<&2,A.P131UEntry>, +mode: U32, order: Cmp, +li: U32, +ll: U32, +lh: U32, +ri: U32, +rl: U32, +rh: U32) -> List<&2,A.P131UEntry>:
  match left right order:
    case Nil{} values LT{}:
      Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},A.p131u_absent(Con{A.P131UEntry{ri,rl,rh},values},mode)}
    case Con{A.P131UEntry{+ni,nl,nh},rest} values LT{}:
      Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},p131u_merge_loop(rest,values,mode,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh)}
    case values Nil{} GT{}:
      Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},A.p131u_absent(Con{A.P131UEntry{li,ll,lh},values},mode)}
    case values Con{A.P131UEntry{+ni,nl,nh},rest} GT{}:
      Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},p131u_merge_loop(values,rest,mode,U32.cmp(li,ni),li,ll,lh,ni,nl,nh)}
    case Nil{} values EQ{}:
      Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},A.p131u_absent(values,mode)}
    case values Nil{} EQ{}:
      Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},A.p131u_absent(values,mode)}
    case Con{A.P131UEntry{+ni,nl,nh},xs} Con{A.P131UEntry{+mi,ml,mh},ys} EQ{}:
      Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},p131u_merge_loop(xs,ys,mode,U32.cmp(ni,mi),ni,nl,nh,mi,ml,mh)}

def p131u_merge(left: List<&2,A.P131UEntry>, right: List<&2,A.P131UEntry>, +mode: U32) -> List<&2,A.P131UEntry>:
  match left right:
    case Nil{} values: A.p131u_absent(values,mode)
    case values Nil{}: A.p131u_absent(values,mode)
    case Con{A.P131UEntry{+li,ll,lh},lr} Con{A.P131UEntry{+ri,rl,rh},rr}:
      p131u_merge_loop(lr,rr,mode,U32.cmp(li,ri),li,ll,lh,ri,rl,rh)

import Base
import ./production.bend as P
import ./absent-production.bend as A
import ./merge-production-v01.bend as M
import ./merge-first-order-v01.bend as F

# Exact one-step expansion of the previously proved merge with explicit heads.
def original_step(+left: List<&2,A.P131UEntry>, +right: List<&2,A.P131UEntry>, +mode: U32, order: Cmp, +li: U32, +ll: U32, +lh: U32, +ri: U32, +rl: U32, +rh: U32) -> List<&2,A.P131UEntry>:
  M.p131u_merge_choose(
    u => Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},M.p131u_merge(left,Con{A.P131UEntry{ri,rl,rh},right},mode)},
    u => Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},M.p131u_merge(left,right,mode)},
    u => Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},M.p131u_merge(Con{A.P131UEntry{li,ll,lh},left},right,mode)},
    order)

law merge_loop_exact:
  for +left: List<&2,A.P131UEntry>
  for +right: List<&2,A.P131UEntry>
  for +mode: U32
  for +order: Cmp
  for +li: U32
  for +ll: U32
  for +lh: U32
  for +ri: U32
  for +rl: U32
  for +rh: U32
  {F.p131u_merge_loop(left,right,mode,order,li,ll,lh,ri,rl,rh) == original_step(left,right,mode,order,li,ll,lh,ri,rl,rh) : List<&2,A.P131UEntry>}

def merge_loop_exact(left,right,mode,order,li,ll,lh,ri,rl,rh):
  match left right order:
    case Nil{} Nil{} LT{}: {==}
    case Nil{} Nil{} EQ{}: {==}
    case Nil{} Nil{} GT{}: {==}
    case Nil{} Con{A.P131UEntry{+mi,+ml,+mh},+ys} LT{}: {==}
    case Nil{} Con{A.P131UEntry{+mi,+ml,+mh},+ys} EQ{}: {==}
    case Nil{} Con{A.P131UEntry{+mi,+ml,+mh},+ys} GT{}:
      %merge_loop_exact(left,ys,mode,U32.cmp(li,mi),li,ll,lh,mi,ml,mh) : {F.p131u_merge_loop(left,right,mode,GT{},li,ll,lh,ri,rl,rh) == Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},_} : List<&2,A.P131UEntry>}
      {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Nil{} LT{}:
      %merge_loop_exact(xs,right,mode,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh) : {F.p131u_merge_loop(left,right,mode,LT{},li,ll,lh,ri,rl,rh) == Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},_} : List<&2,A.P131UEntry>}
      {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Nil{} EQ{}: {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Nil{} GT{}: {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Con{A.P131UEntry{+mi,+ml,+mh},+ys} LT{}:
      %merge_loop_exact(xs,right,mode,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh) : {F.p131u_merge_loop(left,right,mode,LT{},li,ll,lh,ri,rl,rh) == Con{A.P131UEntry{li,P.p131a_low(mode,ll,0),P.p131a_high(mode,lh,0)},_} : List<&2,A.P131UEntry>}
      {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Con{A.P131UEntry{+mi,+ml,+mh},+ys} EQ{}:
      %merge_loop_exact(xs,ys,mode,U32.cmp(ni,mi),ni,nl,nh,mi,ml,mh) : {F.p131u_merge_loop(left,right,mode,EQ{},li,ll,lh,ri,rl,rh) == Con{A.P131UEntry{li,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},_} : List<&2,A.P131UEntry>}
      {==}
    case Con{A.P131UEntry{+ni,+nl,+nh},+xs} Con{A.P131UEntry{+mi,+ml,+mh},+ys} GT{}:
      %merge_loop_exact(left,ys,mode,U32.cmp(li,mi),li,ll,lh,mi,ml,mh) : {F.p131u_merge_loop(left,right,mode,GT{},li,ll,lh,ri,rl,rh) == Con{A.P131UEntry{ri,P.p131a_low(mode,0,rl),P.p131a_high(mode,0,rh)},_} : List<&2,A.P131UEntry>}
      {==}

law merge_exact:
  for +left: List<&2,A.P131UEntry>
  for +right: List<&2,A.P131UEntry>
  for +mode: U32
  {F.p131u_merge(left,right,mode) == M.p131u_merge(left,right,mode) : List<&2,A.P131UEntry>}

def merge_exact(left,right,mode):
  match left right:
    case Nil{} Nil{}: {==}
    case Nil{} Con{A.P131UEntry{ri,rl,rh},rr}: {==}
    case Con{A.P131UEntry{li,ll,lh},lr} Nil{}: {==}
    case Con{A.P131UEntry{+li,ll,lh},lr} Con{A.P131UEntry{+ri,rl,rh},rr}:
      merge_loop_exact(lr,rr,mode,U32.cmp(li,ri),li,ll,lh,ri,rl,rh)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

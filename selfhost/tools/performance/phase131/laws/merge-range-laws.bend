import Base
import ./reference.bend as R
import ./absent-production.bend as A
import ./bounded-domain.bend as B
import ./merge-first-order-v01.bend as F
import ./merge-range-domain.bend as D
import ./merge-range-helpers.bend as H

# All key domains, all query-independent order states: no aligned-map,
# sortedness, uniqueness or opaque comparison premise appears in this law.
law merge_loop_preserves_count_bounds:
  for +left: List<&2,B.P131UBounded>
  for +right: List<&2,B.P131UBounded>
  for +kind: R.P131Mode
  for +order: Cmp
  for +li: U32
  for +ll: R.P131Count
  for +lh: R.P131Count
  for +ri: U32
  for +rl: R.P131Count
  for +rh: R.P131Count
  {D.all_counts_bounded(F.p131u_merge_loop(B.encode(left),B.encode(right),R.mode(kind),order,li,R.encode(ll),R.encode(lh),ri,R.encode(rl),R.encode(rh))) == True{} : Bool}

def merge_loop_preserves_count_bounds(left,right,kind,order,li,ll,lh,ri,rl,rh):
  match left right order:
    case Nil{} Nil{} LT{}:
      H.combined_cell_bounded(kind,li,ll,lh,R.P131Zero{},R.P131Zero{},A.p131u_absent(B.encode(Con{B.P131UBounded{ri,rl,rh},right}),R.mode(kind)),H.absence_preserves_bounds(Con{B.P131UBounded{ri,rl,rh},right},kind))
    case Nil{} Nil{} EQ{}:
      H.combined_cell_bounded(kind,li,ll,lh,rl,rh,A.p131u_absent(B.encode(right),R.mode(kind)),H.absence_preserves_bounds(right,kind))
    case Nil{} Nil{} GT{}:
      H.combined_cell_bounded(kind,ri,R.P131Zero{},R.P131Zero{},rl,rh,A.p131u_absent(B.encode(Con{B.P131UBounded{li,ll,lh},left}),R.mode(kind)),H.absence_preserves_bounds(Con{B.P131UBounded{li,ll,lh},left},kind))
    case Nil{} Con{B.P131UBounded{+mi,+ml,+mh},+ys} LT{}:
      H.combined_cell_bounded(kind,li,ll,lh,R.P131Zero{},R.P131Zero{},A.p131u_absent(B.encode(Con{B.P131UBounded{ri,rl,rh},right}),R.mode(kind)),H.absence_preserves_bounds(Con{B.P131UBounded{ri,rl,rh},right},kind))
    case Nil{} Con{B.P131UBounded{+mi,+ml,+mh},+ys} EQ{}:
      H.combined_cell_bounded(kind,li,ll,lh,rl,rh,A.p131u_absent(B.encode(right),R.mode(kind)),H.absence_preserves_bounds(right,kind))
    case Nil{} Con{B.P131UBounded{+mi,+ml,+mh},+ys} GT{}:
      H.combined_cell_bounded(kind,ri,R.P131Zero{},R.P131Zero{},rl,rh,F.p131u_merge_loop(B.encode(left),B.encode(ys),R.mode(kind),U32.cmp(li,mi),li,R.encode(ll),R.encode(lh),mi,R.encode(ml),R.encode(mh)),merge_loop_preserves_count_bounds(left,ys,kind,U32.cmp(li,mi),li,ll,lh,mi,ml,mh))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Nil{} LT{}:
      H.combined_cell_bounded(kind,li,ll,lh,R.P131Zero{},R.P131Zero{},F.p131u_merge_loop(B.encode(xs),B.encode(right),R.mode(kind),U32.cmp(ni,ri),ni,R.encode(nl),R.encode(nh),ri,R.encode(rl),R.encode(rh)),merge_loop_preserves_count_bounds(xs,right,kind,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Nil{} EQ{}:
      H.combined_cell_bounded(kind,li,ll,lh,rl,rh,A.p131u_absent(B.encode(left),R.mode(kind)),H.absence_preserves_bounds(left,kind))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Nil{} GT{}:
      H.combined_cell_bounded(kind,ri,R.P131Zero{},R.P131Zero{},rl,rh,A.p131u_absent(B.encode(Con{B.P131UBounded{li,ll,lh},left}),R.mode(kind)),H.absence_preserves_bounds(Con{B.P131UBounded{li,ll,lh},left},kind))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Con{B.P131UBounded{+mi,+ml,+mh},+ys} LT{}:
      H.combined_cell_bounded(kind,li,ll,lh,R.P131Zero{},R.P131Zero{},F.p131u_merge_loop(B.encode(xs),B.encode(right),R.mode(kind),U32.cmp(ni,ri),ni,R.encode(nl),R.encode(nh),ri,R.encode(rl),R.encode(rh)),merge_loop_preserves_count_bounds(xs,right,kind,U32.cmp(ni,ri),ni,nl,nh,ri,rl,rh))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Con{B.P131UBounded{+mi,+ml,+mh},+ys} EQ{}:
      H.combined_cell_bounded(kind,li,ll,lh,rl,rh,F.p131u_merge_loop(B.encode(xs),B.encode(ys),R.mode(kind),U32.cmp(ni,mi),ni,R.encode(nl),R.encode(nh),mi,R.encode(ml),R.encode(mh)),merge_loop_preserves_count_bounds(xs,ys,kind,U32.cmp(ni,mi),ni,nl,nh,mi,ml,mh))
    case Con{B.P131UBounded{+ni,+nl,+nh},+xs} Con{B.P131UBounded{+mi,+ml,+mh},+ys} GT{}:
      H.combined_cell_bounded(kind,ri,R.P131Zero{},R.P131Zero{},rl,rh,F.p131u_merge_loop(B.encode(left),B.encode(ys),R.mode(kind),U32.cmp(li,mi),li,R.encode(ll),R.encode(lh),mi,R.encode(ml),R.encode(mh)),merge_loop_preserves_count_bounds(left,ys,kind,U32.cmp(li,mi),li,ll,lh,mi,ml,mh))

law merge_preserves_count_bounds:
  for +left: List<&2,B.P131UBounded>
  for +right: List<&2,B.P131UBounded>
  for +kind: R.P131Mode
  {D.all_counts_bounded(F.p131u_merge(B.encode(left),B.encode(right),R.mode(kind))) == True{} : Bool}

def merge_preserves_count_bounds(left,right,kind):
  match left right:
    case Nil{} Nil{}: H.absence_preserves_bounds(Nil{},kind)
    case Nil{} Con{B.P131UBounded{ri,rl,rh},rr}: H.absence_preserves_bounds(right,kind)
    case Con{B.P131UBounded{li,ll,lh},lr} Nil{}: H.absence_preserves_bounds(left,kind)
    case Con{B.P131UBounded{+li,ll,lh},lr} Con{B.P131UBounded{+ri,rl,rh},rr}:
      merge_loop_preserves_count_bounds(lr,rr,kind,U32.cmp(li,ri),li,ll,lh,ri,rl,rh)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

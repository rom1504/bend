import Base
import ./production.bend as P
import ./reference.bend as R
import ./absent-production.bend as A
import ./aligned-production.bend as V
import ./aligned-lookup-laws.bend as T
import ./merge-production-v01.bend as M
import ./lookup-production-v02.bend as L
import ./merge-first-order-v01.bend as FM
import ./lookup-first-order-v02.bend as FL
import ./first-order-merge-laws.bend as EM
import ./first-order-lookup-laws.bend as EL

# Directly usable contract: first-order production algorithms implement the
# independently proved reference lookup-combination result on aligned maps.
law first_order_merged_maximum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {FL.p131u_max(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id) == P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)) : U32}

def first_order_merged_maximum(entries,kind,id):
  Equal.trans(U32,
    FL.p131u_max(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    L.p131u_max(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)),
    EL.maximum_exact(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    Equal.trans(U32,
      L.p131u_max(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
      L.p131u_max(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
      P.p131a_high(R.mode(kind),L.p131u_max(V.left(entries),id),L.p131u_max(V.right(entries),id)),
      Equal.cong(List<&2,A.P131UEntry>,U32,values => L.p131u_max(values,id),
        FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),EM.merge_exact(V.left(entries),V.right(entries),R.mode(kind))),
      T.merged_maximum(entries,kind,id)))

law first_order_merged_minimum:
  for +entries: List<&2,V.P131UAligned>
  for +kind: R.P131Mode
  for +id: U32
  {FL.p131u_min(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id) == P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)) : U32}

def first_order_merged_minimum(entries,kind,id):
  Equal.trans(U32,
    FL.p131u_min(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    L.p131u_min(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)),
    EL.minimum_exact(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
    Equal.trans(U32,
      L.p131u_min(FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
      L.p131u_min(M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),id),
      P.p131a_low(R.mode(kind),L.p131u_min(V.left(entries),id),L.p131u_min(V.right(entries),id)),
      Equal.cong(List<&2,A.P131UEntry>,U32,values => L.p131u_min(values,id),
        FM.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),M.p131u_merge(V.left(entries),V.right(entries),R.mode(kind)),EM.merge_exact(V.left(entries),V.right(entries),R.mode(kind))),
      T.merged_minimum(entries,kind,id)))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

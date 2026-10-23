import Base
import ./production.bend as P
import ./reference.bend as R
import ./absent-production.bend as A
import ./bounded-domain.bend as B
import ./bounded-lookup-laws.bend as C
import ./lookup-production-v02.bend as L
import ./lookup-first-order-v02.bend as FL
import ./merge-first-order-v01.bend as FM
import ./first-order-lookup-laws.bend as E

# All three admitted modes preserve maximums when the other map has no entry.
law maximum_absence:
  for +entries: List<&2,A.P131UEntry>
  for +kind: R.P131Mode
  for +id: U32
  {L.p131u_max(A.p131u_absent(entries,R.mode(kind)),id) == L.p131u_max(entries,id) : U32}

def maximum_absence(entries,kind,id):
  match entries kind:
    case Nil{} R.P131Sequence{}: {==}
    case Nil{} R.P131Branch{}: {==}
    case Nil{} R.P131Pattern{}: {==}
    case Con{A.P131UEntry{key,low,high},rest} R.P131Sequence{}: {==}
    case Con{A.P131UEntry{+key,low,+high},+rest} R.P131Branch{}:
      %maximum_absence(rest,R.P131Branch{},id) : {L.p131u_choose(high,u => L.p131u_max(A.p131u_absent(rest,1),id),U32.cmp(key,id)) == L.p131u_choose(high,u => _,U32.cmp(key,id)) : U32}
      {==}
    case Con{A.P131UEntry{+key,low,+high},+rest} R.P131Pattern{}:
      %maximum_absence(rest,R.P131Pattern{},id) : {L.p131u_choose(high,u => L.p131u_max(A.p131u_absent(rest,2),id),U32.cmp(key,id)) == L.p131u_choose(high,u => _,U32.cmp(key,id)) : U32}
      {==}

law first_order_maximum_absence:
  for +entries: List<&2,A.P131UEntry>
  for +kind: R.P131Mode
  for +id: U32
  {FL.p131u_max(A.p131u_absent(entries,R.mode(kind)),id) == L.p131u_max(entries,id) : U32}

def first_order_maximum_absence(entries,kind,id):
  Equal.trans(U32,FL.p131u_max(A.p131u_absent(entries,R.mode(kind)),id),L.p131u_max(A.p131u_absent(entries,R.mode(kind)),id),L.p131u_max(entries,id),E.maximum_exact(A.p131u_absent(entries,R.mode(kind)),id),maximum_absence(entries,kind,id))

law merge_right_empty:
  for +entries: List<&2,A.P131UEntry>
  for +mode: U32
  {FM.p131u_merge(entries,Nil{},mode) == A.p131u_absent(entries,mode) : List<&2,A.P131UEntry>}

def merge_right_empty(entries,mode):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{id,low,high},rest}: {==}

law high_zero:
  for +kind: R.P131Mode
  for +count: R.P131Count
  {P.p131a_high(R.mode(kind),R.encode(count),0) == R.encode(count) : U32}

def high_zero(kind,count):
  match kind count:
    case R.P131Sequence{} R.P131Zero{}: {==}
    case R.P131Sequence{} R.P131Once{}: {==}
    case R.P131Sequence{} R.P131Many{}: {==}
    case R.P131Branch{} R.P131Zero{}: {==}
    case R.P131Branch{} R.P131Once{}: {==}
    case R.P131Branch{} R.P131Many{}: {==}
    case R.P131Pattern{} R.P131Zero{}: {==}
    case R.P131Pattern{} R.P131Once{}: {==}
    case R.P131Pattern{} R.P131Many{}: {==}

law lookup_high_zero:
  for +entries: List<&2,B.P131UBounded>
  for +kind: R.P131Mode
  for +id: U32
  {P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0) == L.p131u_max(B.encode(entries),id) : U32}

def lookup_high_zero(entries,kind,id):
  Equal.trans(U32,
    P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0),
    P.p131a_high(R.mode(kind),R.encode(B.maximum(entries,id)),0),
    L.p131u_max(B.encode(entries),id),
    Equal.cong(U32,U32,n => P.p131a_high(R.mode(kind),n,0),L.p131u_max(B.encode(entries),id),R.encode(B.maximum(entries,id)),C.maximum_count_exact(entries,id)),
    Equal.trans(U32,P.p131a_high(R.mode(kind),R.encode(B.maximum(entries,id)),0),R.encode(B.maximum(entries,id)),L.p131u_max(B.encode(entries),id),high_zero(kind,B.maximum(entries,id)),Equal.sym(U32,L.p131u_max(B.encode(entries),id),R.encode(B.maximum(entries,id)),C.maximum_count_exact(entries,id))))

# A full map-domain base case: no alignment/sortedness/uniqueness assumptions.
# The count-domain witness is essential; unbounded U32 fields are not summaries.
law right_empty_maximum:
  for +entries: List<&2,B.P131UBounded>
  for +kind: R.P131Mode
  for +id: U32
  {FL.p131u_max(FM.p131u_merge(B.encode(entries),Nil{},R.mode(kind)),id) == P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0) : U32}

def right_empty_maximum(entries,kind,id):
  Equal.trans(U32,
    FL.p131u_max(FM.p131u_merge(B.encode(entries),Nil{},R.mode(kind)),id),
    FL.p131u_max(A.p131u_absent(B.encode(entries),R.mode(kind)),id),
    P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0),
    Equal.cong(List<&2,A.P131UEntry>,U32,values => FL.p131u_max(values,id),FM.p131u_merge(B.encode(entries),Nil{},R.mode(kind)),A.p131u_absent(B.encode(entries),R.mode(kind)),merge_right_empty(B.encode(entries),R.mode(kind))),
    Equal.trans(U32,
      FL.p131u_max(A.p131u_absent(B.encode(entries),R.mode(kind)),id),L.p131u_max(B.encode(entries),id),P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0),
      first_order_maximum_absence(B.encode(entries),kind,id),
      Equal.sym(U32,P.p131a_high(R.mode(kind),L.p131u_max(B.encode(entries),id),0),L.p131u_max(B.encode(entries),id),lookup_high_zero(entries,kind,id))))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

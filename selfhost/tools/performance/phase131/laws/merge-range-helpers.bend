import Base
import ./production.bend as P
import ./reference.bend as R
import ./absent-production.bend as A
import ./bounded-domain.bend as B
import ./bounded-lookup-laws.bend as C
import ./low-only.bend as LO
import ./high-only.bend as HI
import ./merge-range-domain.bend as D

law both_true:
  for +a: Bool
  for +b: Bool
  for pa: {a == True{} : Bool}
  for pb: {b == True{} : Bool}
  {Bool.and(a,b) == True{} : Bool}

def both_true(a,b,pa,pb):
  %pa : {Bool.and(a,b) == Bool.and(_,True{}) : Bool}
  %pb : {Bool.and(a,b) == Bool.and(a,_) : Bool}
  {==}

law combined_low_bounded:
  for +kind: R.P131Mode
  for +a: R.P131Count
  for +b: R.P131Count
  {U32.is_le(P.p131a_low(R.mode(kind),R.encode(a),R.encode(b)),2) == True{} : Bool}

def combined_low_bounded(kind,a,b):
  %C.bounded_count(R.low(kind,a,b)) : {U32.is_le(P.p131a_low(R.mode(kind),R.encode(a),R.encode(b)),2) == _ : Bool}
  %LO.lower_combination_exact(kind,a,b) : {U32.is_le(P.p131a_low(R.mode(kind),R.encode(a),R.encode(b)),2) == U32.is_le(_,2) : Bool}
  {==}

law combined_high_bounded:
  for +kind: R.P131Mode
  for +a: R.P131Count
  for +b: R.P131Count
  {U32.is_le(P.p131a_high(R.mode(kind),R.encode(a),R.encode(b)),2) == True{} : Bool}

def combined_high_bounded(kind,a,b):
  %C.bounded_count(R.high(kind,a,b)) : {U32.is_le(P.p131a_high(R.mode(kind),R.encode(a),R.encode(b)),2) == _ : Bool}
  %HI.upper_combination_exact(kind,a,b) : {U32.is_le(P.p131a_high(R.mode(kind),R.encode(a),R.encode(b)),2) == U32.is_le(_,2) : Bool}
  {==}

law raw_cell_bounded:
  for +id: U32
  for +low: U32
  for +high: U32
  for +tail: List<&2,A.P131UEntry>
  for lo: {U32.is_le(low,2) == True{} : Bool}
  for hi: {U32.is_le(high,2) == True{} : Bool}
  for rest: {D.all_counts_bounded(tail) == True{} : Bool}
  {D.all_counts_bounded(Con{A.P131UEntry{id,low,high},tail}) == True{} : Bool}

def raw_cell_bounded(id,low,high,tail,lo,hi,rest):
  both_true(U32.is_le(low,2),Bool.and(U32.is_le(high,2),D.all_counts_bounded(tail)),lo,both_true(U32.is_le(high,2),D.all_counts_bounded(tail),hi,rest))

law count_cell_bounded:
  for +id: U32
  for +low: R.P131Count
  for +high: R.P131Count
  for +tail: List<&2,A.P131UEntry>
  for rest: {D.all_counts_bounded(tail) == True{} : Bool}
  {D.all_counts_bounded(Con{A.P131UEntry{id,R.encode(low),R.encode(high)},tail}) == True{} : Bool}

def count_cell_bounded(id,low,high,tail,rest):
  raw_cell_bounded(id,R.encode(low),R.encode(high),tail,C.bounded_count(low),C.bounded_count(high),rest)

law combined_cell_bounded:
  for +kind: R.P131Mode
  for +id: U32
  for +ll: R.P131Count
  for +lh: R.P131Count
  for +rl: R.P131Count
  for +rh: R.P131Count
  for +tail: List<&2,A.P131UEntry>
  for rest: {D.all_counts_bounded(tail) == True{} : Bool}
  {D.all_counts_bounded(Con{A.P131UEntry{id,P.p131a_low(R.mode(kind),R.encode(ll),R.encode(rl)),P.p131a_high(R.mode(kind),R.encode(lh),R.encode(rh))},tail}) == True{} : Bool}

def combined_cell_bounded(kind,id,ll,lh,rl,rh,tail,rest):
  raw_cell_bounded(id,P.p131a_low(R.mode(kind),R.encode(ll),R.encode(rl)),P.p131a_high(R.mode(kind),R.encode(lh),R.encode(rh)),tail,combined_low_bounded(kind,ll,rl),combined_high_bounded(kind,lh,rh),rest)

law encoded_entries_bounded:
  for +entries: List<&2,B.P131UBounded>
  {D.all_counts_bounded(B.encode(entries)) == True{} : Bool}

def encoded_entries_bounded(entries):
  match entries:
    case Nil{}: {==}
    case Con{B.P131UBounded{id,low,high},rest}:
      count_cell_bounded(id,low,high,B.encode(rest),encoded_entries_bounded(rest))

law absence_preserves_bounds:
  for +entries: List<&2,B.P131UBounded>
  for +kind: R.P131Mode
  {D.all_counts_bounded(A.p131u_absent(B.encode(entries),R.mode(kind))) == True{} : Bool}

def absence_preserves_bounds(entries,kind):
  match entries kind:
    case Nil{} R.P131Sequence{}: {==}
    case Nil{} R.P131Branch{}: {==}
    case Nil{} R.P131Pattern{}: {==}
    case Con{B.P131UBounded{id,low,high},rest} R.P131Sequence{}:
      count_cell_bounded(id,low,high,B.encode(rest),encoded_entries_bounded(rest))
    case Con{B.P131UBounded{id,low,high},rest} R.P131Branch{}:
      count_cell_bounded(id,R.P131Zero{},high,A.p131u_absent(B.encode(rest),1),absence_preserves_bounds(rest,R.P131Branch{}))
    case Con{B.P131UBounded{id,low,high},rest} R.P131Pattern{}:
      count_cell_bounded(id,R.P131Zero{},high,A.p131u_absent(B.encode(rest),2),absence_preserves_bounds(rest,R.P131Pattern{}))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

import Base
import ./reference.bend as R
import ./bounded-domain.bend as B
import ./lookup-production-v02.bend as L
import ./lookup-first-order-v02.bend as F
import ./first-order-lookup-laws.bend as E

law encode_choice:
  for -value: R.P131Count
  for -tail: Unit -> R.P131Count
  for +order: Cmp
  {L.p131u_choose(R.encode(value),u => R.encode(tail(Unit{})),order) == R.encode(B.choose(value,tail,order)) : U32}

def encode_choice(value,tail,order):
  match order:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: {==}

law maximum_count_exact:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {L.p131u_max(B.encode(entries),id) == R.encode(B.maximum(entries,id)) : U32}

def maximum_count_exact(entries,id):
  match entries:
    case Nil{}: {==}
    case Con{B.P131UBounded{+key,low,+high},+rest}:
      %encode_choice(high,u => B.maximum(rest,id),U32.cmp(key,id)) : {L.p131u_max(B.encode(Con{B.P131UBounded{key,low,high},rest}),id) == _ : U32}
      %maximum_count_exact(rest,id) : {L.p131u_choose(R.encode(high),u => L.p131u_max(B.encode(rest),id),U32.cmp(key,id)) == L.p131u_choose(R.encode(high),u => _,U32.cmp(key,id)) : U32}
      {==}

law minimum_count_exact:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {L.p131u_min(B.encode(entries),id) == R.encode(B.minimum(entries,id)) : U32}

def minimum_count_exact(entries,id):
  match entries:
    case Nil{}: {==}
    case Con{B.P131UBounded{+key,+low,high},+rest}:
      %encode_choice(low,u => B.minimum(rest,id),U32.cmp(key,id)) : {L.p131u_min(B.encode(Con{B.P131UBounded{key,low,high},rest}),id) == _ : U32}
      %minimum_count_exact(rest,id) : {L.p131u_choose(R.encode(low),u => L.p131u_min(B.encode(rest),id),U32.cmp(key,id)) == L.p131u_choose(R.encode(low),u => _,U32.cmp(key,id)) : U32}
      {==}

law bounded_count:
  for count: R.P131Count
  {U32.is_le(R.encode(count),2) == True{} : Bool}

def bounded_count(count):
  match count:
    case R.P131Zero{}: {==}
    case R.P131Once{}: {==}
    case R.P131Many{}: {==}

law first_order_maximum_count:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {F.p131u_max(B.encode(entries),id) == R.encode(B.maximum(entries,id)) : U32}

def first_order_maximum_count(entries,id):
  Equal.trans(U32,F.p131u_max(B.encode(entries),id),L.p131u_max(B.encode(entries),id),R.encode(B.maximum(entries,id)),E.maximum_exact(B.encode(entries),id),maximum_count_exact(entries,id))

law first_order_minimum_count:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {F.p131u_min(B.encode(entries),id) == R.encode(B.minimum(entries,id)) : U32}

def first_order_minimum_count(entries,id):
  Equal.trans(U32,F.p131u_min(B.encode(entries),id),L.p131u_min(B.encode(entries),id),R.encode(B.minimum(entries,id)),E.minimum_exact(B.encode(entries),id),minimum_count_exact(entries,id))

law maximum_bounded:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {U32.is_le(F.p131u_max(B.encode(entries),id),2) == True{} : Bool}

def maximum_bounded(entries,id):
  %bounded_count(B.maximum(entries,id)) : {U32.is_le(F.p131u_max(B.encode(entries),id),2) == _ : Bool}
  %first_order_maximum_count(entries,id) : {U32.is_le(F.p131u_max(B.encode(entries),id),2) == U32.is_le(_,2) : Bool}
  {==}

law minimum_bounded:
  for +entries: List<&2,B.P131UBounded>
  for +id: U32
  {U32.is_le(F.p131u_min(B.encode(entries),id),2) == True{} : Bool}

def minimum_bounded(entries,id):
  %bounded_count(B.minimum(entries,id)) : {U32.is_le(F.p131u_min(B.encode(entries),id),2) == _ : Bool}
  %first_order_minimum_count(entries,id) : {U32.is_le(F.p131u_min(B.encode(entries),id),2) == U32.is_le(_,2) : Bool}
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.

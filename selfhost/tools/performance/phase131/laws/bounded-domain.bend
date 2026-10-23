import Base
import ./reference.bend as R
import ./absent-production.bend as A

# Domain witness for arbitrary maps whose individual counts are 0/1/many.
# It introduces no assumption about order, uniqueness or matching query IDs.
type P131UBounded is Data:
  P131UBounded{+id: U32, +low: R.P131Count, +high: R.P131Count}

def encode(entries: List<&2,P131UBounded>) -> List<&2,A.P131UEntry>:
  match entries:
    case Nil{}: []
    case Con{P131UBounded{id,low,high},rest}:
      Con{A.P131UEntry{id,R.encode(low),R.encode(high)},encode(rest)}

def choose(value: R.P131Count, tail: Unit -> R.P131Count, order: Cmp) -> R.P131Count:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: R.P131Zero{}

def maximum(entries: List<&2,P131UBounded>, +id: U32) -> R.P131Count:
  match entries:
    case Nil{}: R.P131Zero{}
    case Con{P131UBounded{key,low,high},rest}:
      choose(high,u => maximum(rest,id),U32.cmp(key,id))

def minimum(entries: List<&2,P131UBounded>, +id: U32) -> R.P131Count:
  match entries:
    case Nil{}: R.P131Zero{}
    case Con{P131UBounded{key,low,high},rest}:
      choose(low,u => minimum(rest,id),U32.cmp(key,id))

import Base
import ./absent-production.bend as A

# Move the pending comparison into first-order recursive state. Each LT step
# consumes one entry; EQ/GT return without inspecting the remaining list.
def p131u_max_loop(order: Cmp, value: U32, entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match order:
    case EQ{}: value
    case GT{}: 0
    case LT{}:
      match entries:
        case Nil{}: 0
        case Con{A.P131UEntry{key,low,high},rest}:
          p131u_max_loop(U32.cmp(key,id),high,rest,id)

def p131u_max(entries: List<&2,A.P131UEntry>, id: U32) -> U32:
  p131u_max_loop(LT{},0,entries,id)

def p131u_min_loop(order: Cmp, value: U32, entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match order:
    case EQ{}: value
    case GT{}: 0
    case LT{}:
      match entries:
        case Nil{}: 0
        case Con{A.P131UEntry{key,low,high},rest}:
          p131u_min_loop(U32.cmp(key,id),low,rest,id)

def p131u_min(entries: List<&2,A.P131UEntry>, id: U32) -> U32:
  p131u_min_loop(LT{},0,entries,id)

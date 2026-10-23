import Base
import ./absent-production.bend as A

# Safe candidate: identical comparison branches, preserving early stop.
def p131u_max(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{+key,low,high},rest}:
      order : Cmp = U32.cmp(key,id)
      match order:
        case LT{}: p131u_max(rest,id)
        case EQ{}: high
        case GT{}: 0

def p131u_min(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{+key,low,high},rest}:
      order : Cmp = U32.cmp(key,id)
      match order:
        case LT{}: p131u_min(rest,id)
        case EQ{}: low
        case GT{}: 0

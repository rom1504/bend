import Base
import ./absent-production.bend as A

# Safe candidate: exact comparison branches, preserving deferred tail lookup.
def p131u_choose(value: U32, tail: Unit -> U32, order: Cmp) -> U32:
  match order:
    case LT{}: tail(Unit{})
    case EQ{}: value
    case GT{}: 0

def p131u_max(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{key,low,high},rest}:
      p131u_choose(high,u => p131u_max(rest,id),U32.cmp(key,id))

def p131u_min(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{key,low,high},rest}:
      p131u_choose(low,u => p131u_min(rest,id),U32.cmp(key,id))

import Base
import ./absent-production.bend as A

def p131u_template_choose(~next: List<&2,A.P131UEntry> -> U32 -> U32, rest: List<&2,A.P131UEntry>, id: U32, value: U32, order: Cmp) -> U32:
  match order:
    case LT{}: next(rest,id)
    case EQ{}: value
    case GT{}: 0

def p131u_max(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{key,low,high},rest}:
      p131u_template_choose(~p131u_max,rest,id,high,U32.cmp(key,id))

def p131u_min(entries: List<&2,A.P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{A.P131UEntry{key,low,high},rest}:
      p131u_template_choose(~p131u_min,rest,id,low,U32.cmp(key,id))

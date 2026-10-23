import Base
import ./absent-production.bend as A

# Lists precede changing scalar state, satisfying lexicographic safe descent.
# EQ/GT do no further comparison or recursion; pattern dispatch may inspect
# the remaining list constructor before releasing its owned value.
def p131u_max_loop(entries: List<&2,A.P131UEntry>, +id: U32, order: Cmp, value: U32) -> U32:
  match entries order:
    case values EQ{}: value
    case values GT{}: 0
    case Nil{} LT{}: 0
    case Con{A.P131UEntry{key,low,high},rest} LT{}:
      p131u_max_loop(rest,id,U32.cmp(key,id),high)

def p131u_max(entries: List<&2,A.P131UEntry>, id: U32) -> U32:
  p131u_max_loop(entries,id,LT{},0)

def p131u_min_loop(entries: List<&2,A.P131UEntry>, +id: U32, order: Cmp, value: U32) -> U32:
  match entries order:
    case values EQ{}: value
    case values GT{}: 0
    case Nil{} LT{}: 0
    case Con{A.P131UEntry{key,low,high},rest} LT{}:
      p131u_min_loop(rest,id,U32.cmp(key,id),low)

def p131u_min(entries: List<&2,A.P131UEntry>, id: U32) -> U32:
  p131u_min_loop(entries,id,LT{},0)

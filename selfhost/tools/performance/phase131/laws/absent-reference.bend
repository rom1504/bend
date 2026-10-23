import Base
import ./absent-production.bend as A

# Complete-value reference, preserving arbitrary IDs, highs, order and duplicates.
def clear_minima(entries: List<&2,A.P131UEntry>) -> List<&2,A.P131UEntry>:
  match entries:
    case Nil{}: []
    case Con{A.P131UEntry{id,low,high},rest}:
      Con{A.P131UEntry{id,0,high},clear_minima(rest)}

def high_fields(entries: List<&2,A.P131UEntry>) -> List<&2,U32>:
  match entries:
    case Nil{}: []
    case Con{A.P131UEntry{id,low,high},rest}: Con{high,high_fields(rest)}

def identities(entries: List<&2,A.P131UEntry>) -> List<&2,U32>:
  match entries:
    case Nil{}: []
    case Con{A.P131UEntry{id,low,high},rest}: Con{id,identities(rest)}

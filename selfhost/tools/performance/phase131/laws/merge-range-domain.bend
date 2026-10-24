import Base
import ./absent-production.bend as A

# This predicate observes the actual raw entry-list output of production merge.
def all_counts_bounded(entries: List<&2,A.P131UEntry>) -> Bool:
  match entries:
    case Nil{}: True{}
    case Con{A.P131UEntry{id,low,high},rest}:
      Bool.and(U32.is_le(low,2),Bool.and(U32.is_le(high,2),all_counts_bounded(rest)))

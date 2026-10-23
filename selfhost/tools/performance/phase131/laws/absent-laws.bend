import Base
import ./absent-production.bend as A
import ./absent-reference.bend as R

law sequence_missing_identity:
  for entries: List<&2,A.P131UEntry>
  {A.p131u_absent(entries,0) == entries : List<&2,A.P131UEntry>}

def sequence_missing_identity(entries):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{id,low,high},rest}: {==}

law branch_missing_exact:
  for entries: List<&2,A.P131UEntry>
  {A.p131u_absent(entries,1) == R.clear_minima(entries) : List<&2,A.P131UEntry>}

def branch_missing_exact(entries):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{id,low,high},rest}:
      %branch_missing_exact(rest) : {Con{A.P131UEntry{id,0,high},A.p131u_absent(rest,1)} == Con{A.P131UEntry{id,0,high},_} : List<&2,A.P131UEntry>}
      {==}

law pattern_missing_exact:
  for entries: List<&2,A.P131UEntry>
  {A.p131u_absent(entries,2) == R.clear_minima(entries) : List<&2,A.P131UEntry>}

def pattern_missing_exact(entries):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{id,low,high},rest}:
      %pattern_missing_exact(rest) : {Con{A.P131UEntry{id,0,high},A.p131u_absent(rest,2)} == Con{A.P131UEntry{id,0,high},_} : List<&2,A.P131UEntry>}
      {==}

law clear_preserves_highs:
  for entries: List<&2,A.P131UEntry>
  {R.high_fields(R.clear_minima(entries)) == R.high_fields(entries) : List<&2,U32>}

def clear_preserves_highs(entries):
  match entries:
    case Nil{}: {==}
    case Con{A.P131UEntry{id,low,high},rest}:
      %clear_preserves_highs(rest) : {Con{high,R.high_fields(R.clear_minima(rest))} == Con{high,_} : List<&2,U32>}
      {==}

import Base
import ./production.bend as P
import ./absent-production.bend as A

# A quantified domain witness: two maps have the same key sequence.
# This is proof input encoding, never a runtime summary representation.
type P131UAligned is Data:
  P131UAligned{+key: U32, +leftLow: U32, +leftHigh: U32, +rightLow: U32, +rightHigh: U32}

def left(entries: List<&2,P131UAligned>) -> List<&2,A.P131UEntry>:
  match entries:
    case Nil{}: []
    case Con{P131UAligned{key,ll,lh,rl,rh},rest}:
      Con{A.P131UEntry{key,ll,lh},left(rest)}

def right(entries: List<&2,P131UAligned>) -> List<&2,A.P131UEntry>:
  match entries:
    case Nil{}: []
    case Con{P131UAligned{key,ll,lh,rl,rh},rest}:
      Con{A.P131UEntry{key,rl,rh},right(rest)}

def combine(entries: List<&2,P131UAligned>, +mode: U32) -> List<&2,A.P131UEntry>:
  match entries:
    case Nil{}: []
    case Con{P131UAligned{key,ll,lh,rl,rh},rest}:
      Con{A.P131UEntry{key,P.p131a_low(mode,ll,rl),P.p131a_high(mode,lh,rh)},combine(rest,mode)}

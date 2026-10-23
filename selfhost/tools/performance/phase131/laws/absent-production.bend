import Base

type P131UEntry is Data:
  P131UEntry{+id: U32, +low: U32, +high: U32}

def p131u_absent(entries: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match entries mode:
    case values 0: values
    case Nil{} other: []
    case Con{P131UEntry{id,low,high},rest} other:
      Con{P131UEntry{id,0,high},p131u_absent(rest,mode)}


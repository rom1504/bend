import Base

# A constructor's erased Type field determines the next field's type.
type P175Hidden is Type:
  P175Hidden{-A: Type, payload: A, tag: U32}

def p175sd_hidden(-A: Type, payload: A, tag: U32) -> P175Hidden:
  P175Hidden{A,payload,tag}

def p175sd_tag(value: P175Hidden) -> U32:
  match value:
    case P175Hidden{A,payload,tag}: tag

# Type parameters and explicit erased value fields coexist with live values.
type P175Box<-A: Data> is Data:
  P175Box{-key: U32, first: A, second: A}

def p175sd_make(-A: Data, first: A, second: A) -> P175Box<A>:
  P175Box{999,first,second}

def p175sd_unpack(value: P175Box<U32>) -> U32 & U32:
  match value:
    case P175Box{key,first,second}: (first,second)

def main() -> (U32 & U32) & U32:
  (p175sd_unpack(p175sd_make(U32,17,23)),p175sd_tag(p175sd_hidden(Nat,5n,73)))

#|((17, 23), 73)

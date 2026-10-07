import Base

def Alias(T: Data) -> Data:
  T

def Alias2(T: Data) -> Data:
  Alias(Alias(T))

type Wrapped is Data:
  Wrapped{value: Alias2(U32)}

def unwrap(w: Wrapped) -> U32:
  match w:
    case Wrapped{x}: x

def probe(x: U32) -> U32:
  U32.add(unwrap(Wrapped{x}), 1)

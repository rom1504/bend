import Base

def Alias(T: Data) -> Data:
  T

@unsafe
def unused_loop(x: U32) -> U32:
  unused_loop(x)

def erased_identity(-T: Data, x: T, -proof: {x == x : T}) -> T:
  x

def probe(+x: U32) -> U32:
  unused = unused_loop(x)
  U32.add(erased_identity(Alias(U32), x, {==}), 1)

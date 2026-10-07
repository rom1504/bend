import Base

def Family(x: U32) -> Data:
  U32

def PartialFamily(n: Nat, x: U32) -> Data:
  Family(x)

def read_first(p: Sigma<&2, &2, U32, a => PartialFamily(1n, a)>) -> U32:
  (a, b) = p
  a

def read_second(p: Sigma<&2, &2, U32, a => PartialFamily(1n, a)>) -> U32:
  (a, b) = p
  b

def combine(+p: Sigma<&2, &2, U32, a => PartialFamily(1n, a)>) -> U32:
  U32.add(U32.mul(read_first(p), 10), read_second(p))

def probe() -> U32:
  combine((3, 7))

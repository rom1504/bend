import Base

def multiply.complex(f: U32 -> U32, n: U32) -> U32:
  U32.mul(f(n), 3)

def multiply.prior(f: U32 -> U32, n: U32) -> U32:
  value = f(n)
  U32.mul(value, 3)

def doubled(f: U32 -> U32) -> Nat:
  Nat.double(U32.to_nat(f(0)))

def store(a: Array<U32>, i: U32, value: U32) -> Array<U32>:
  Array.set(U32, a, i, value)

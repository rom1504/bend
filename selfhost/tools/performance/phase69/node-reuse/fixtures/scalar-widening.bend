import Base

def wide_add(a: U32, b: U32) -> Nat:
  Nat.add(U32.to_nat(a), U32.to_nat(b))

def wide_mul(a: U32, b: U32) -> Nat:
  Nat.mul(U32.to_nat(a), U32.to_nat(b))

def wrap_add(a: U32, b: U32) -> U32:
  U32.add(a, b)

def main() -> Nat:
  Nat.add(wide_add(4294967295, 4294967295), Nat.add(wide_mul(65536, 65536), U32.to_nat(wrap_add(4294967295, 2))))

#|12884901887n

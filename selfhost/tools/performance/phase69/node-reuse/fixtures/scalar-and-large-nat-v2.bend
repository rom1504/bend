import Base

def pass_u32(x: U32) -> U32:
  x

def pass_nat(x: Nat) -> Nat:
  x

def main() -> Nat:
  Nat.add(U32.to_nat(pass_u32(4294967295)), pass_nat(Nat.add(Nat.mul(65536n, 65536n), 15n)))

#|8589934606n

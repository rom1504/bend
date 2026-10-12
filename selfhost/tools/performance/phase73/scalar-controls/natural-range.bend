import Base

def held(+n: Nat) -> Nat:
  Nat.sub(n, Nat.sub(n, 0n))

def boundary(+n: Nat) -> Nat:
  Nat.add(n, held(n))

def main() -> Nat:
  boundary(Nat.mul(16777215n, 16777217n))

#|281474976710655n

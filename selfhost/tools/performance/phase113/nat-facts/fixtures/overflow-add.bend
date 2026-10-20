import Base

def ignore(value: Nat) -> Nat:
  7n

def add_one(value: Nat) -> Nat:
  Nat.add(value,1n)

def main() -> Nat:
  ignore(add_one(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n))))

import Base

def ignore(value: Nat) -> Nat:
  7n

def grow(value: Nat) -> Nat:
  Succ{value}

def main() -> Nat:
  ignore(grow(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n))))

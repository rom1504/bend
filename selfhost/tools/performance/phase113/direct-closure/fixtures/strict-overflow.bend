import Base

def apply(f: Nat -> Nat, value: Nat) -> Nat:
  f(value)

def overflow(value: Nat) -> Nat:
  1n+value

def main() -> Nat:
  apply(value => 7n,overflow(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n))))

# The nonliteral second actual must overflow before the literal body can
# discard it. The independent oracle is native failure, not a printed 7.

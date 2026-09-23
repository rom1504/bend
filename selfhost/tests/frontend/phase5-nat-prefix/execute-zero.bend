import Base
def nat_count(n: Nat) -> U32:
  match n:
    case Zero{}: 0
    case Succ{p}: U32.add(1, nat_count(p))
def main() -> U32:
  nat_count(0n+3n)

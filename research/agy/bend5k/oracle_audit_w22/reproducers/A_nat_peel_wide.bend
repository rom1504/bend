import Base

def peel(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n: 10n
    case 2n: 20n
    case 3n+rest: Nat.add(30n, rest)

def main() -> IO(Unit):
  IO.print(Nat.show(peel(0n)) ++ "," ++ Nat.show(peel(1n)) ++ "," ++ Nat.show(peel(2n)) ++ "," ++ Nat.show(peel(Nat.add(Nat.mul(5n, 1000000000n), 3n))))

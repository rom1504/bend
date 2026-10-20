import Base

def overflow(n: Nat) -> Nat:
  1n+n

def choose(flag: Bool, yes: Unit -> Nat, no: Unit -> Nat) -> Nat:
  match flag:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def main() -> IO(Unit):
  IO.print(Nat.show(choose(True{}, u => 7n,
    u => overflow(Nat.add(Nat.pow(2n, 47n), Nat.sub(Nat.pow(2n, 47n), 1n))))))

#|7

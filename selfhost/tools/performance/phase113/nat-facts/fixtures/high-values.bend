import Base

def identity(value: Nat) -> Nat:
  value

def predecessor(value: Nat) -> Nat:
  match value:
    case Zero{}: 0n
    case Succ{rest}: rest

def capture(value: Nat) -> (Nat -> Nat):
  extra => Nat.add(value,extra)

def observe(+value: Nat) -> IO(Unit):
  closure = capture(value)
  do IO<Unit>:
    Unit <- IO.print(Nat.show(identity(value)))
    Unit <- IO.print(Nat.show(closure(0n)))
    IO.print(Nat.show(predecessor(value)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- observe(Nat.pow(2n,32n))
    Unit <- observe(Nat.pow(2n,40n))
    observe(Nat.add(Nat.pow(2n,47n),Nat.sub(Nat.pow(2n,47n),1n)))

#|4294967296
#|4294967296
#|4294967295
#|1099511627776
#|1099511627776
#|1099511627775
#|281474976710655
#|281474976710655
#|281474976710654

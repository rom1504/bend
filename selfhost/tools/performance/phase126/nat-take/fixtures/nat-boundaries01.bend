# Ordinary semantic Nat values, using an effectful matcher for generic emission.
import Base

def natural.observe(value: Nat) -> IO(Unit):
  match value:
    case 0n: IO.print("zero")
    case 1n+p: IO.print(Nat.show(p))

def natural.retained(+value: Nat) -> IO(Unit):
  do IO<Unit>:
    Unit <- natural.observe(value)
    IO.print(Nat.show(value))

def natural.walk(n: Nat, sum: U32) -> IO(Unit):
  match n:
    case 0n: IO.print(U32.show(sum))
    case 1n+p:
      +next = {p : Nat}
      natural.walk(next, U32.add(sum, U32.from_nat(next)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- natural.retained(0n)
    Unit <- natural.retained(1n)
    Unit <- natural.retained(2n)
    Unit <- natural.retained(4294967296n)
    Unit <- natural.retained(1099511627776n)
    Unit <- natural.retained(281474976710655n)
    natural.walk(4096n, 0)

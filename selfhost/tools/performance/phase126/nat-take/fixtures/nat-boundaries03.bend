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
    Unit <- natural.retained(Nat.mul(65536n,65536n))
    Unit <- natural.retained(Nat.mul(Nat.mul(65536n,65536n),256n))
    Unit <- natural.retained(Nat.add(Nat.mul(Nat.mul(65536n,65536n),65535n),Nat.sub(Nat.mul(65536n,65536n),1n)))
    natural.walk(4096n, 0)

import Base

def held(+n: Nat) -> Nat:
  Nat.sub(n, Nat.sub(n, 0n))

def boundary(+n: Nat) -> Nat:
  Nat.add(n, held(n))

def answer() -> Nat:
  boundary(Nat.mul(16777215n, 16777217n))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(Nat.show(answer()))

#|281474976710655

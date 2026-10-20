import Base

# Closed scalar return facts must survive a call inside a complete tail loop.
def step(x: U32) -> U32:
  U32.add(U32.mul(x, 1664525), 1013904223)

def loop(n: Nat, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: loop(p, step(x))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(loop(0n, 0)))
    Unit <- IO.print(U32.show(loop(1n, 0)))
    Unit <- IO.print(U32.show(loop(31n, 0)))
    Unit <- IO.print(U32.show(loop(257n, 7)))
    IO.print(U32.show(loop(100001n, 123)))

#|0
#|1013904223
#|1473591045
#|3609971386
#|1522340798

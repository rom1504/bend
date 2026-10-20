import Base

# A local-loop jump must transfer all old arguments before overwriting any.
def rotate(n: Nat, a: U32, b: U32, c: U32) -> U32:
  match n:
    case 0n: U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))
    case 1n+p: rotate(p, b, c, a)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(rotate(0n, 1, 2, 3)))
    Unit <- IO.print(U32.show(rotate(1n, 1, 2, 3)))
    Unit <- IO.print(U32.show(rotate(2n, 1, 2, 3)))
    IO.print(U32.show(rotate(100001n, 1, 2, 3)))

#|123
#|231
#|312
#|312

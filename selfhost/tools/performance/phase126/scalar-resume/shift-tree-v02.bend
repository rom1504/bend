import Base
# Ordinary source: a scalar conditional shift is evaluated between two recursive
# calls. Bounded depth keeps the independent control economical.
def sumtree(depth: Nat, +step: Nat, +x: U32) -> U32:
  match depth:
    case 0n:
      x
    case 1n+p:
      a b = sumtree(p, step, x) sumtree(p, step, U32.add(x, U32.shln(1, step)))
      U32.add(a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(sumtree(10n, 0n, 0)))
    Unit <- IO.print(U32.show(sumtree(10n, 7n, 3)))
    Unit <- IO.print(U32.show(sumtree(10n, 31n, 0)))
    Unit <- IO.print(U32.show(sumtree(10n, 32n, 7)))
    Unit <- IO.print(U32.show(sumtree(10n, 40n, 9)))
    IO.print(U32.show(sumtree(0n, 40n, 9)))

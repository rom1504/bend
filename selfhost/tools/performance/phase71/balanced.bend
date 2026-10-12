import Base

def p71.leaf(n: Nat, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: p71.leaf(p, U32.add(U32.mul(x, 1664525), 1013904223))

def p71.tree(+n: Nat, x: U32) -> U32:
  match n:
    case 0n: p71.leaf(4000000n, x)
    case 1n+p:
      +y = U32.mul(x, 2)
      a b = p71.tree(p, y) p71.tree(p, U32.add(y, 1))
      U32.add(a, b)

def main() -> IO(Unit):
  IO.print(U32.show(p71.tree(10n, 17)))

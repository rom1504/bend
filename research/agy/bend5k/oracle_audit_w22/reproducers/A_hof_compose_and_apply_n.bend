import Base

def compose(f: U32 -> U32, g: U32 -> U32) -> U32 -> U32:
  x => f(g(x))

def apply_n(~f: U32 -> U32, n: Nat, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: apply_n(f, p, f(x))

def main() -> IO(Unit):
  f : U32 -> U32 = x => U32.add(U32.mul(2, x), 1)
  g : U32 -> U32 = x => U32.add(x, 3)
  r1 = compose(f, g)(10)
  r2 = apply_n(x => U32.add(U32.mul(2, x), 1), 4n, 1)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2))

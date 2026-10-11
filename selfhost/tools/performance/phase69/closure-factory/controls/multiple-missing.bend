import Base

def tri(a: U32, b: U32, c: U32) -> U32:
  U32.add(U32.add(U32.mul(a, 100), U32.mul(b, 10)), c)

def main() -> IO(Unit):
  f = {tri(1) : U32 -> U32 -> U32}
  g = {f(2) : U32 -> U32}
  IO.print(U32.show(g(3)))

#|123

import Base

def flip(f: U32 -> U32 -> U32, b: U32, a: U32) -> U32:
  f(a, b)

def main() -> IO(Unit):
  f = {flip(a => b => U32.add(U32.mul(a, 10), b), 7) : U32 -> U32}
  IO.print(U32.show(f(9)))

#|97

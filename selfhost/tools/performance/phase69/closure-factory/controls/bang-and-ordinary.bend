import Base

def plus(a: U32, b: U32) -> U32:
  U32.add(a, b)

def main() -> IO(Unit):
  f = {plus(10) : U32 -> U32}
  g = {plus!(20) : U32 -> U32}
  a b = f(1) g(2)
  IO.print(U32.show(U32.add(a, b)))

#|33

import Base

def twice(+f: U32 -> U32, x: U32) -> U32:
  f(f(x))

def ignore(f: U32 -> U32, x: U32) -> U32:
  x

def main() -> IO(Unit):
  f = {twice(x => U32.add(x, 1)) : U32 -> U32}
  g = {ignore(x => U32.add(x, 100)) : U32 -> U32}
  IO.print(U32.show(U32.add(f(10), g(20))))

#|32

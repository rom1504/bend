import Base

def repeated(f: U32 -> U32 -> U32, +x: U32) -> U32:
  f(x, x)

def ignore(f: U32 -> U32, x: U32) -> U32:
  x

def main() -> IO(Unit):
  f = {repeated(a => b => U32.add(a, b)) : @+x: U32 -> U32}
  g = {ignore(x => U32.add(x, 100)) : U32 -> U32}
  IO.print(U32.show(U32.add(f(6), g(20))))

#|32

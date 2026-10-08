# A parallel let in an argument exercises JDOrdered's demanded RHS selection.
import Base

def bench(+x: U32, +y: U32) -> U32:
  U32.add((a b = U32.add(x, 1) U32.add(y, 2); U32.add(a, b)), U32.add(x, y))

def main() -> IO(Unit):
  IO.print(U32.show(bench(3, 5)))

#|19

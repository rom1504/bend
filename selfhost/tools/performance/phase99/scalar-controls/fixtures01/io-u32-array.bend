import Base

def finish(r: Array<U32> & U32) -> U32:
  (a, x) = r
  x

def swapped(r: Array<U32> & U32) -> U32:
  (a, old) = r
  U32.add(old, finish(Array.get(U32, a, 1)))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(U32.show(swapped(Array.swap(U32, Array.new(U32, 1n, 4294967295), 1, 17))))

#|16

import Base

def finish(r: Array<F32> & F32) -> F32:
  (a, x) = r
  x

def swapped(r: Array<F32> & F32) -> F32:
  (a, old) = r
  F32.add(old, finish(Array.get(F32, a, 1)))

def main() -> IO(Unit):
  IO.print(F32.show(swapped(Array.swap(F32, Array.new(F32, 2n, F32.neg(1.25)), 1, 0.75))))

#|-0.5

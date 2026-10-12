import Base
import common.bend as C

type Signal is Data:
  Off{}
  On{}

def signal(s: Signal) -> U32:
  match s:
    case Off{}: 0
    case On{}: 10

def read(r: Array<Signal> & Signal) -> U32:
  (a, x) = r
  signal(x)

def main() -> IO(Unit):
  IO.print(U32.show(U32.add(C.stored(True{}), read(Array.get(Signal, Array.new(Signal, 1n, On{}), 1)))))

#|11

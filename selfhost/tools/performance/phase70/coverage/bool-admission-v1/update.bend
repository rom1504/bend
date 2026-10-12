import Base
import common.bend as C

def finish(r: Array<Bool> & Bool) -> U32:
  (a, old) = r
  U32.add(U32.mul(10, Bool.to_u32(old)), C.read(Array.get(Bool, a, 1)))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(finish(Array.swap(Bool, Array.set(Bool, Array.new(Bool, 2n, False{}), 0, True{}), 1, True{}))))
    IO.print(U32.show(finish(Array.swap(Bool, Array.set(Bool, Array.new(Bool, 2n, True{}), 0, False{}), 1, False{}))))

#|1
#|10

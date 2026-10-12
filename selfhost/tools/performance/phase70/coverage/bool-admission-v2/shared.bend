import Base
import common.bend as C

# A fork shares mutable cells; a clone has independent cells.
def finish(right: Array<Bool>, result: Array<Bool> & Bool) -> U32:
  (left, old) = result
  U32.add(U32.mul(100, Bool.to_u32(old)), U32.add(U32.mul(10, C.sum(left)), C.sum(right)))

def change(replacement: Bool, handles: Array<Bool> & Array<Bool>) -> U32:
  (left, right) = handles
  finish(right, Array.swap(Bool, left, 1, replacement))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(change(True{}, Array.fork(Bool, Array.new(Bool, 2n, False{})))))
    IO.print(U32.show(change(False{}, Array.fork(Bool, Array.new(Bool, 2n, True{})))))

#|11
#|133

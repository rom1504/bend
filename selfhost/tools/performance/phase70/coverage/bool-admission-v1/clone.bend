import Base
import common.bend as C

def finish(original: Array<Bool>, result: Array<Bool> & Bool) -> U32:
  (copy, old) = result
  U32.add(U32.mul(100, C.sum(original)), U32.add(U32.mul(10, Bool.to_u32(old)), C.sum(copy)))

def change(replacement: Bool, clones: Array<Bool> & Array<Bool>) -> U32:
  (original, copy) = clones
  finish(original, Array.swap(Bool, copy, 2, replacement))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(change(True{}, Array.clone(Bool, Array.new(Bool, 2n, False{})))))
    IO.print(U32.show(change(False{}, Array.clone(Bool, Array.new(Bool, 2n, True{})))))

#|1
#|413

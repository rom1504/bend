import Base

def typed_affine(value: U32, step: U32) -> U32:
  U32.add(U32.mul(value, 3), step)

def typed_fork(depth: Nat, +value: U32) -> U32:
  match depth:
    case 0n: typed_affine(value, 7)
    case 1n+pred:
      left right = typed_fork(pred, U32.inc(value)) typed_fork(pred, U32.add(value, 2))
      U32.add(left, right)

# Any reachable bang must keep the old scheduler/device-capable lowering.
def main() -> IO(Unit):
  result = typed_fork!(3n, 11)
  IO.print(U32.show(result))

#|428

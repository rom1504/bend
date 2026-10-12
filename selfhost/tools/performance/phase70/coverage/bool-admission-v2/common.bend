import Base

def sum(a: Array<Bool>) -> U32:
  match a:
    case ALeaf{x}: Bool.to_u32(x)
    case ANode{left, right}: U32.add(sum(left), sum(right))

def read(r: Array<Bool> & Bool) -> U32:
  (a, x) = r
  Bool.to_u32(x)

def stored(b: Bool) -> U32:
  sum(Array.new(Bool, 0n, b))

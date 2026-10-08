# False drops a fresh owned product; True reads both arrays in field order.
# An unboxed product parameter must not silently change the False drop path.
# 7*100 + (11*100+31) = 1831.
import Base

type DropProduct68 is Type:
  DropProduct68{left: Array<U32>, right: Array<U32>}

def drop_product_right68(left: U32, pair: Array<U32> & U32) -> U32:
  (rest, right) = pair
  U32.add(U32.mul(left, 100), right)

def drop_product_left68(pair: Array<U32> & U32, right: Array<U32>) -> U32:
  (rest, left) = pair
  drop_product_right68(left, Array.get(U32, right, 0))

def drop_product_branch68(flag: Bool, value: DropProduct68) -> U32:
  match flag:
    case False{}:
      7
    case True{}:
      match value:
        case DropProduct68{left, right}:
          drop_product_left68(Array.get(U32, left, 0), right)

def drop_product_make68() -> DropProduct68:
  DropProduct68{ALeaf{11}, ALeaf{31}}

def main() -> U32:
  U32.add(U32.mul(drop_product_branch68(False{}, drop_product_make68()), 100),
    drop_product_branch68(True{}, drop_product_make68()))

#|1831

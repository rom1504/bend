# Two initializers remain in one body. Each computed pair is passed to a
# separate function before destructuring its parameter. The independent result
# is 7*1000000 + 7*10000 + 11*100 + 13 + 9 = 7071122.
import Base

def scratch_finish68(old0: U32, old1: U32, left: U32, right: U32, salt_pair: Array<U32> & U32) -> U32:
  (b, salt) = salt_pair
  U32.add(U32.mul(old0, 1000000),
    U32.add(U32.mul(old1, 10000),
      U32.add(U32.mul(left, 100), U32.add(right, salt))))

def scratch_right68(old0: U32, old1: U32, left: U32, pair: Array<U32> & U32, salt_pair: Array<U32> & U32) -> U32:
  (a3, right) = pair
  scratch_finish68(old0, old1, left, right, salt_pair)

def scratch_left68(old0: U32, old1: U32, pair: Array<U32> & U32, salt_pair: Array<U32> & U32) -> U32:
  (a2, left) = pair
  scratch_right68(old0, old1, left, Array.get(U32, a2, 1), salt_pair)

def scratch_second68(old0: U32, pair: Array<U32> & U32, salt_pair: Array<U32> & U32) -> U32:
  (a1, old1) = pair
  scratch_left68(old0, old1, Array.get(U32, a1, 0), salt_pair)

def scratch_first68(pair: Array<U32> & U32, salt_pair: Array<U32> & U32) -> U32:
  (a0, old0) = pair
  scratch_second68(old0, Array.swap(U32, a0, 1, 13), salt_pair)

def main() -> U32:
  a = {[7 : U32*2n] : Array<U32>}
  b = {[9 : U32*2n] : Array<U32>}
  scratch_first68(Array.swap(U32, a, 0, 11), Array.get(U32, b, 0))

#|7071122

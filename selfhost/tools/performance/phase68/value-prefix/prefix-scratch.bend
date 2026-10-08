# Two array initializers, two swaps and repeated reads in the local pipeline.
# Scratch names init/at/old must remain private to each emitted value prefix.
# 7*1000000 + 7*10000 + 11*100 + 13 + 9 = 7071122.
import Base

def main() -> U32:
  (a0, old0) = Array.swap(U32, [7 : U32*2n], 0, 11)
  (a1, old1) = Array.swap(U32, a0, 1, 13)
  (a2, left) = Array.get(U32, a1, 0)
  (a3, right) = Array.get(U32, a2, 1)
  (b, salt) = Array.get(U32, [9 : U32*2n], 0)
  U32.add(U32.mul(old0, 1000000),
    U32.add(U32.mul(old1, 10000),
      U32.add(U32.mul(left, 100), U32.add(right, salt))))

#|7071122

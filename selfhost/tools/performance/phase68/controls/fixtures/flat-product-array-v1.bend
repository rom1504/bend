# A primitive pair result crosses a named return and a consuming parameter.
# Retaining and reading the returned array exposes field reversal or disposal.
# The two reads are 29 then 17, so the independent result is 29*100+17=2917.
import Base

def product_array_finish68(first: U32, pair: Array<U32> & U32) -> U32:
  (rest, second) = pair
  U32.add(U32.mul(first, 100), second)

def product_array_consume68(pair: Array<U32> & U32) -> U32:
  (array, first) = pair
  product_array_finish68(first, Array.get(U32, array, 0))

def product_array_read68(array: Array<U32>) -> Array<U32> & U32:
  Array.get(U32, array, 1)

def main() -> U32:
  product_array_consume68(product_array_read68(ANode{ALeaf{17}, ALeaf{29}}))

#|2917

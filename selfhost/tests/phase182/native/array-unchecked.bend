import Base

# Destructure parameter values; computed matches require a separate definition.
def finish(x: U32, pair: Array<U32> & U32) -> U32:
  (a, y) = pair
  U32.add(x, y)

def first(pair: Array<U32> & U32) -> U32:
  (a, x) = pair
  finish(x, Array.get(U32, a, 0))

@unsafe
def main() -> U32:
  a = Array.new(U32, 2n, 7)
  b = Array.set(U32, a, 3, 91)
  first(Array.get_unchecked(U32, b, 3))

#|98

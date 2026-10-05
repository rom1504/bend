import Base

def delayed(value: U32) -> (U32 -> U32) -> U32:
  saved = U32.add(value, 0)
  h => h(saved)

def probe(f: U32 -> U32, g: U32 -> U32, h: U32 -> U32, +n: U32) -> U32:
  delayed(U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3)))(h)

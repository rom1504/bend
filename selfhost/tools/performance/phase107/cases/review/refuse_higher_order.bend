import Base

def apply(f: U32 -> U32, value: U32) -> U32:
  f(value)

def bench(n: U32, seed: U32) -> U32:
  apply(x => U32.add(x, n), seed)

def main() -> U32:
  bench(19, 23)

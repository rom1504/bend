import Base

def tagged(-tag: Nat, x: U32) -> U32:
  U32.xor(x, 2654435769)

def bench(n: U32, seed: U32) -> U32:
  tagged(17n, U32.add(n, seed))

def main() -> U32:
  bench(19, 23)

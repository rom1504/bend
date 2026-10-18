import Base

def bench(n: U32, seed: U32) -> U32:
  -ignored : Nat = Nat.add(123n, 456n)
  U32.add(n, seed)

def main() -> U32:
  bench(19, 23)

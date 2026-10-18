import Base

def bench(n: U32, seed: U32) -> U32:
  U32.shln(n, U32.to_nat(seed))

def main() -> U32:
  bench(19, 23)

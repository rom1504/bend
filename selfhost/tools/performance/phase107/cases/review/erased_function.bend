import Base

def ignore(-f: U32 -> U32, value: U32) -> U32:
  value

def bench(n: U32, seed: U32) -> U32:
  ignore(x => U32.add(x, seed), n)

def main() -> U32:
  bench(19, 23)

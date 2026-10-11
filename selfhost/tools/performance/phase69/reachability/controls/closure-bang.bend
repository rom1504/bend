import Base

def worker(n: U32) -> U32:
  U32.add(n, 1)

def make(offset: U32) -> U32 -> U32:
  n => worker!(U32.add(offset, n))

def invoke(f: U32 -> U32, n: U32) -> U32:
  f(n)

def main() -> U32:
  invoke(make(10), 31)

#|42

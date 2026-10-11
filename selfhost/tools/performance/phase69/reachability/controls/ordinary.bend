import Base

def worker(n: U32) -> U32:
  U32.add(n, 1)

def main() -> U32:
  worker(41)

#|42

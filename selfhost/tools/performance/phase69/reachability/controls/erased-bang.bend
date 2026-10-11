import Base

def worker(n: U32) -> U32:
  U32.add(n, 1)

law keep:
  for -unused: U32
  for value: U32
  U32

def keep(unused, value):
  value

def main() -> U32:
  keep(worker!(100), worker(41))

#|42

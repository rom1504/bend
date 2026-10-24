import Base

def retained(+x: U32) -> U32:
  x

def edited() -> U32:
  11

def main() -> U32:
  U32.add(retained(7), edited())

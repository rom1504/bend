import Base

def twice(f: Unit -> U32) -> U32:
  U32.add(f(Unit{}), f(Unit{}))

def main() -> U32:
  twice(u => 1)

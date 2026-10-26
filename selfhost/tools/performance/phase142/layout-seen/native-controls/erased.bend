import Base

def wrap(-T: Type, x: T) -> Array<T>:
  ALeaf{x}

def sink(-x: Array<U32>) -> U32:
  7

def main() -> U32:
  sink(wrap(U32, 3))

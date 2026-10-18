import Base

type Box is Data:
  Box{+value: U32}

def read(box: Box) -> U32:
  match box:
    case Box{value}: value

def bench(n: U32, seed: U32) -> U32:
  read(Box{U32.add(n, seed)})

def main() -> U32:
  bench(19, 23)

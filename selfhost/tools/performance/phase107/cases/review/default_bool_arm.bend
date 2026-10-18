import Base

def choose(b: Bool, x: U32, y: U32) -> U32:
  match b:
    case True{}: x
    case _: y

def bench(+n: U32, +seed: U32) -> U32:
  choose(U32.is_lt(n, seed), n, seed)

def main() -> U32:
  bench(19, 23)

import Base

def choose(b: Bool, x: U32) -> U32:
  match b:
    case True{}: U32.add(x, 7)
    case False{}: U32.xor(x, 2147483648)

def bench(+n: U32, seed: U32) -> U32:
  choose(U32.is_lt(n, seed), n)

def main() -> U32:
  bench(19, 23)

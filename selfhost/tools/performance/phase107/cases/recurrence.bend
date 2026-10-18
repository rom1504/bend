import Base

@unsafe
def walk(done: Bool, +n: U32, +seed: U32) -> U32:
  match done:
    case True{}: seed
    case False{}:
      walk(U32.is_eq(n, 1), U32.sub(n, 1), U32.xor(U32.add(U32.mul(seed, 33), n), 2654435769))

def bench(+n: U32, seed: U32) -> U32:
  walk(U32.is_zero(n), n, seed)

def main() -> U32:
  bench(19, 23)

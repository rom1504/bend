import Base

@unsafe
def held_tri(done: Bool, +n: U32) -> U32:
  match done:
    case True{}: 0
    case False{}:
      U32.add(n, held_tri(U32.is_eq(n, 1), U32.sub(n, 1)))

def bench(n: U32, seed: U32) -> U32:
  +bound = U32.and(n, 1023)
  U32.add(held_tri(U32.is_zero(bound), bound), seed)

def main() -> U32:
  bench(511, 1234567890)
